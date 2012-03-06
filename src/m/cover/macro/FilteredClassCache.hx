/****
* Copyright 2012 Massive Interactive. All rights reserved.
* 
* Redistribution and use in source and binary forms, with or without modification, are
* permitted provided that the following conditions are met:
* 
*    1. Redistributions of source code must retain the above copyright notice, this list of
*       conditions and the following disclaimer.
* 
*    2. Redistributions in binary form must reproduce the above copyright notice, this list
*       of conditions and the following disclaimer in the documentation and/or other materials
*       provided with the distribution.
* 
* THIS SOFTWARE IS PROVIDED BY MASSIVE INTERACTIVE ``AS IS'' AND ANY EXPRESS OR IMPLIED
* WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
* FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL MASSIVE INTERACTIVE OR
* CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
* CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
* ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
* ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
* 
* The views and conclusions contained in the software and documentation are those of the
* authors and should not be interpreted as representing official policies, either expressed
* or implied, of Massive Interactive.
****/

package m.cover.macro;

/**
Loads and Saves a cache of previously filtered classes for files.

- cache is cleared if filter conditions have changed
- cached values are only returned if file has not changed (based on modified date)

Format:

@id
file|stamp|included class,included class|excluded class,excluded class

*/
#if macro
class FilteredClassCache
{
	var file:String;

	var id:String;
	var fileHash:Hash<CachedClasses>;

	public function new(path:String)
	{
		fileHash = new Hash();

		#if !MCOVER_NO_CACHE
			file = m.cover.MCover.TEMP_DIR + "/" + path;
			if(neko.FileSystem.exists(file))
			{
				load(file);
			}
		#end
	}

	/**
	Creates a string representation of the current filters to use as an id for the cache (to determine if conditions have changed since cache was saved)

	@param classPaths 	array of class path directories (defaults to [''])
	@param packages 	array of packages (defaults to [''])
	@param exclusions 	array of classes or wildcards to ignored (defaults to [''])
	*/
	public function init(?classPaths : Array<String>, ?packages : Array<String>, ?exclusions : Array<String>)
	{
		trace("init");
		var tempId = "";
		if(classPaths != null) tempId += classPaths.join(",");
		tempId += ",";
		if(packages != null) tempId += packages.join(",");
		tempId += ",";
		if(exclusions != null) tempId += exclusions.join(",");

		trace("tempId = " + tempId);
		trace("id = " + id);
		if(tempId != id)
		{
			trace("reset");
			id = tempId;
			fileHash = new Hash();
		}
	}

	/**
	Checks if file is in cache and has not been modified.

	@param path 	path to file
	@return true if cached version has same modifed date as current file. 
	*/
	public function isCached(path:String):Bool
	{
		#if MCOVER_NO_CACHE
			return false;
		#end

		if(fileHash.exists(path))
		{
			var file = fileHash.get(path);
			var stamp = getStamp(path);

			if(file.stamp == stamp) return true;	
		}
		return false;
	}

	/**
	Returns the cached included classes in a file
	
	@param path 	to file
	@return array of qualified classes (example.Foo)
	*/
	public function getIncludedClassesInFile(path:String):Array<String>
	{
		var file = fileHash.get(path);

		return file.includes != "" ? file.includes.split(",") : [];		
	}

	/**
	Returns the cached excluded classes in a file
	
	@param path 	to file
	@return array of qualified classes (example.Foo)
	*/
	public function getExcludedClassesInFile(path:String):Array<String>
	{
		var file = fileHash.get(path);

		return file.excludes != "" ? file.excludes.split(",") : [];		
	}

	/**
	Adds a files included/excluded classes to the cache
	*/
	public function addToCache(path:String, includes:Array<String>,excludes:Array<String>)
	{
		var stamp = getStamp(path);
		var cache:CachedClasses = {stamp:stamp, includes:includes.join(","), excludes:excludes.join(",")};
		fileHash.set(path, cache);
	}

	/**
	Writes the current cache to file
	*/
	public function save()
	{
		#if MCOVER_NO_CACHE
			return;
		#end
		var buf = new StringBuf();

		buf.add("@" + id + "\n");

		for(path in fileHash.keys())
		{
			var file = fileHash.get(path);
			buf.add(path + "|" + file.stamp + "|" + file.includes + "|" + file.excludes + "\n");
		}

		var f = neko.io.File.write(file, false);
		f.writeString(buf.toString());
		f.close();
	}


	function load(file:String)
	{
		var f = neko.io.File.read(file, true);
		try
		{
			while( true )
			{
				var line = StringTools.trim(f.readLine());
				
				if(line.charAt(0) == "@")
				{
					id = line.substr(1);
				}
				else
				{
					var a = line.split("|");
					var cache:CachedClasses = {stamp:a[1], includes:a[2],excludes:a[3]};
						fileHash.set(a[0], cache);
				}
			}
		}
		catch( e : haxe.io.Eof ){}
		f.close();
	}

	/**
	Utility for generating the modified time stamp for a file

	@param path 	a file path
	@return a timestamp in format yyyy-mm-dd hh:mm:ss
	*/
	function getStamp(path:String):String
	{
		if(neko.FileSystem.exists(path) && !neko.FileSystem.isDirectory(path))
		{
			var stat = neko.FileSystem.stat(path);
			return stat.mtime.toString();
		}
		return null;
	}
}

typedef CachedClasses =
{
	stamp:String,
	includes:String,
	excludes:String
}
#end
