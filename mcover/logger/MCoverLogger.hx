/****
* Copyright 2023 Massive Interactive. All rights reserved.
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



package mcover.logger;


#if ((haxe_ver >= 4.0) && (neko||cpp||java||hl||eval))
import sys.thread.Mutex;
#elseif neko
import neko.vm.Mutex;
#elseif cpp
import cpp.vm.Mutex;
#end

import mcover.logger.Logger;
import mcover.logger.LoggerImpl;

@IgnoreLogging
@IgnoreCover
class MCoverLogger
{
	#if (neko||cpp||java||hl||eval)
		static public var mutex:Mutex;
	#end

	static public var logger(default, null):Logger;

	@IgnoreLogging
	@IgnoreCover
	public static function getLogger():Logger
	{
		#if (neko||cpp||java||hl||eval)
			if(mutex == null) mutex = new Mutex();
		 	mutex.acquire();
		#end
		if(logger == null)
		{
			logger = new LoggerImpl();
		}
		#if (neko||cpp||java||hl||eval) mutex.release(); #end
		return logger;
	}

	function new()
	{

	}
}
