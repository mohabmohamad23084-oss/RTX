
var targetAddr = Module.findBaseAddress('libanogs.so').add(0x2467);
Interceptor.attach(targetAddr, {
        onEnter: function(args) {
            console.log('[+] Called: AnoSDKInit @ ' + targetAddr);
            for (var i = 0; i < 8; i++) {
                if (args[i] && !args[i].isNull()) {
                    try {
                        var str = args[i].readCString(64);
                        console.log('    arg[' + i + '] = ' + str);
                    } catch(e) {
                        console.log('    arg[' + i + '] = ' + args[i]);
                    }
                }
            }
        },
        onLeave: function(retval) {
            console.log('    retval = ' + retval);
        }

});
------ [Memory Address Reference] ------
-- uintptr_t func_addr = libBase + 0x2467;


var targetAddr = Module.findBaseAddress('libanogs.so').add(0x2472);
Interceptor.attach(targetAddr, {
        onEnter: function(args) {
            console.log('[+] Called: AnoSDKInitEx @ ' + targetAddr);
            for (var i = 0; i < 8; i++) {
                if (args[i] && !args[i].isNull()) {
                    try {
                        var str = args[i].readCString(64);
                        console.log('    arg[' + i + '] = ' + str);
                    } catch(e) {
                        console.log('    arg[' + i + '] = ' + args[i]);
                    }
                }
            }
        },
        onLeave: function(retval) {
            console.log('    retval = ' + retval);
        }

});
------ [Memory Address Reference] ------
-- uintptr_t func_addr = libBase + 0x2472;


var targetAddr = Module.findBaseAddress('libanogs.so').add(0x247F);
Interceptor.attach(targetAddr, {
        onEnter: function(args) {
            console.log('[+] Called: AnoSDKSetUserInfo @ ' + targetAddr);
            for (var i = 0; i < 8; i++) {
                if (args[i] && !args[i].isNull()) {
                    try {
                        var str = args[i].readCString(64);
                        console.log('    arg[' + i + '] = ' + str);
                    } catch(e) {
                        console.log('    arg[' + i + '] = ' + args[i]);
                    }
                }
            }
        },
        onLeave: function(retval) {
            console.log('    retval = ' + retval);
        }

});
------ [Memory Address Reference] ------
-- uintptr_t func_addr = libBase + 0x247F;

var targetAddr = Module.findBaseAddress('libanogs.so').add(0x2491);
Interceptor.attach(targetAddr, {
        onEnter: function(args) {
            console.log('[+] Called: AnoSDKSetUserInfoWithLicense @ ' + targetAddr);
            for (var i = 0; i < 8; i++) {
                if (args[i] && !args[i].isNull()) {
                    try {
                        var str = args[i].readCString(64);
                        console.log('    arg[' + i + '] = ' + str);
                    } catch(e) {
                        console.log('    arg[' + i + '] = ' + args[i]);
                    }
                }
            }
        },
        onLeave: function(retval) {
            console.log('    retval = ' + retval);
        }

});
------ [Memory Address Reference] ------
-- uintptr_t func_addr = libBase + 0x2491;


var targetAddr = Module.findBaseAddress('libanogs.so').add(0x24CB);
Interceptor.attach(targetAddr, {
        onEnter: function(args) {
            console.log('[+] Called: AnoSDKGetReportData @ ' + targetAddr);
            for (var i = 0; i < 8; i++) {
                if (args[i] && !args[i].isNull()) {
                    try {
                        var str = args[i].readCString(64);
                        console.log('    arg[' + i + '] = ' + str);
                    } catch(e) {
                        console.log('    arg[' + i + '] = ' + args[i]);
                    }
                }
            }
        },
        onLeave: function(retval) {
            console.log('    retval = ' + retval);
        }

});


var targetAddr = Module.findBaseAddress('libanogs.so').add(0x252A);
Interceptor.attach(targetAddr, {
        onEnter: function(args) {
            console.log('[+] Called: AnoSDKGetReportData2 @ ' + targetAddr);
            for (var i = 0; i < 8; i++) {
                if (args[i] && !args[i].isNull()) {
                    try {
                        var str = args[i].readCString(64);
                        console.log('    arg[' + i + '] = ' + str);
                    } catch(e) {
                        console.log('    arg[' + i + '] = ' + args[i]);
                    }
                }
            }
        },
        onLeave: function(retval) {
            console.log('    retval = ' + retval);
        }

});


var targetAddr = Module.findBaseAddress('libanogs.so').add(0x253F);
Interceptor.attach(targetAddr, {
        onEnter: function(args) {
            console.log('[+] Called: AnoSDKGetReportData3 @ ' + targetAddr);
            for (var i = 0; i < 8; i++) {
                if (args[i] && !args[i].isNull()) {
                    try {
                        var str = args[i].readCString(64);
                        console.log('    arg[' + i + '] = ' + str);
                    } catch(e) {
                        console.log('    arg[' + i + '] = ' + args[i]);
                    }
                }
            }
        },
        onLeave: function(retval) {
            console.log('    retval = ' + retval);
        }

});


var targetAddr = Module.findBaseAddress('libanogs.so').add(0x2569);
Interceptor.attach(targetAddr, {
        onEnter: function(args) {
            console.log('[+] Called: AnoSDKGetReportData4 @ ' + targetAddr);
            for (var i = 0; i < 8; i++) {
                if (args[i] && !args[i].isNull()) {
                    try {
                        var str = args[i].readCString(64);
                        console.log('    arg[' + i + '] = ' + str);
                    } catch(e) {
                        console.log('    arg[' + i + '] = ' + args[i]);
                    }
                }
            }
        },
        onLeave: function(retval) {
            console.log('    retval = ' + retval);
        }

});


var targetAddr = Module.findBaseAddress('libanogs.so').add(0x24DF);
Interceptor.attach(targetAddr, {
        onEnter: function(args) {
            console.log('[+] Called: AnoSDKDelReportData @ ' + targetAddr);
            for (var i = 0; i < 8; i++) {
                if (args[i] && !args[i].isNull()) {
                    try {
                        var str = args[i].readCString(64);
                        console.log('    arg[' + i + '] = ' + str);
                    } catch(e) {
                        console.log('    arg[' + i + '] = ' + args[i]);
                    }
                }
            }
        },
        onLeave: function(retval) {
            console.log('    retval = ' + retval);
        }

});


var targetAddr = Module.findBaseAddress('libanogs.so').add(0x2554);
Interceptor.attach(targetAddr, {
        onEnter: function(args) {
            console.log('[+] Called: AnoSDKDelReportData3 @ ' + targetAddr);
            for (var i = 0; i < 8; i++) {
                if (args[i] && !args[i].isNull()) {
                    try {
                        var str = args[i].readCString(64);
                        console.log('    arg[' + i + '] = ' + str);
                    } catch(e) {
                        console.log('    arg[' + i + '] = ' + args[i]);
                    }
                }
            }
        },
        onLeave: function(retval) {
            console.log('    retval = ' + retval);
        }

});



var targetAddr = Module.findBaseAddress('libanogs.so').add(0x257E);
Interceptor.attach(targetAddr, {
        onEnter: function(args) {
            console.log('[+] Called: AnoSDKDelReportData4 @ ' + targetAddr);
            for (var i = 0; i < 8; i++) {
                if (args[i] && !args[i].isNull()) {
                    try {
                        var str = args[i].readCString(64);
                        console.log('    arg[' + i + '] = ' + str);
                    } catch(e) {
                        console.log('    arg[' + i + '] = ' + args[i]);
                    }
                }
            }
        },
        onLeave: function(retval) {
            console.log('    retval = ' + retval);
        }

});


var targetAddr = Module.findBaseAddress('libanogs.so').add(0x2513);
Interceptor.attach(targetAddr, {
        onEnter: function(args) {
            console.log('[+] Called: AnoSDKIoctl @ ' + targetAddr);
            for (var i = 0; i < 8; i++) {
                if (args[i] && !args[i].isNull()) {
                    try {
                        var str = args[i].readCString(64);
                        console.log('    arg[' + i + '] = ' + str);
                    } catch(e) {
                        console.log('    arg[' + i + '] = ' + args[i]);
                    }
                }
            }
        },
        onLeave: function(retval) {
            console.log('    retval = ' + retval);
        }

});
------ [Memory Address Reference] ------
-- uintptr_t func_addr = libBase + 0x2513;


var targetAddr = Module.findBaseAddress('libanogs.so').add(0x2504);
Interceptor.attach(targetAddr, {
        onEnter: function(args) {
            console.log('[+] Called: AnoSDKIoctlOld @ ' + targetAddr);
            for (var i = 0; i < 8; i++) {
                if (args[i] && !args[i].isNull()) {
                    try {
                        var str = args[i].readCString(64);
                        console.log('    arg[' + i + '] = ' + str);
                    } catch(e) {
                        console.log('    arg[' + i + '] = ' + args[i]);
                    }
                }
            }
        },
        onLeave: function(retval) {
            console.log('    retval = ' + retval);
        }

});
------ [Memory Address Reference] ------
-- uintptr_t func_addr = libBase + 0x2504;

var targetAddr = Module.findBaseAddress('libanogs.so').add(0x24AE);
Interceptor.attach(targetAddr, {
        onEnter: function(args) {
            console.log('[+] Called: AnoSDKOnPause @ ' + targetAddr);
            for (var i = 0; i < 8; i++) {
                if (args[i] && !args[i].isNull()) {
                    try {
                        var str = args[i].readCString(64);
                        console.log('    arg[' + i + '] = ' + str);
                    } catch(e) {
                        console.log('    arg[' + i + '] = ' + args[i]);
                    }
                }
            }
        },
        onLeave: function(retval) {
            console.log('    retval = ' + retval);
        }

});
------ [Memory Address Reference] ------
-- uintptr_t func_addr = libBase + 0x24AE;

var targetAddr = Module.findBaseAddress('libanogs.so').add(0x24BC);
Interceptor.attach(targetAddr, {
        onEnter: function(args) {
            console.log('[+] Called: AnoSDKOnResume @ ' + targetAddr);
            for (var i = 0; i < 8; i++) {
                if (args[i] && !args[i].isNull()) {
                    try {
                        var str = args[i].readCString(64);
                        console.log('    arg[' + i + '] = ' + str);
                    } catch(e) {
                        console.log('    arg[' + i + '] = ' + args[i]);
                    }
                }
            }
        },
        onLeave: function(retval) {
            console.log('    retval = ' + retval);
        }

});
------ [Memory Address Reference] ------
-- uintptr_t func_addr = libBase + 0x24BC;


var targetAddr = Module.findBaseAddress('libanogs.so').add(0x24F3);
Interceptor.attach(targetAddr, {
        onEnter: function(args) {
            console.log('[+] Called: AnoSDKOnRecvData @ ' + targetAddr);
            for (var i = 0; i < 8; i++) {
                if (args[i] && !args[i].isNull()) {
                    try {
                        var str = args[i].readCString(64);
                        console.log('    arg[' + i + '] = ' + str);
                    } catch(e) {
                        console.log('    arg[' + i + '] = ' + args[i]);
                    }
                }
            }
        },
        onLeave: function(retval) {
            console.log('    retval = ' + retval);
        }

});
------ [Memory Address Reference] ------
-- uintptr_t func_addr = libBase + 0x24F3;

var targetAddr = Module.findBaseAddress('libanogs.so').add(0x25A9);
Interceptor.attach(targetAddr, {
        onEnter: function(args) {
            console.log('[+] Called: AnoSDKRegistInfoListener @ ' + targetAddr);
            for (var i = 0; i < 8; i++) {
                if (args[i] && !args[i].isNull()) {
                    try {
                        var str = args[i].readCString(64);
                        console.log('    arg[' + i + '] = ' + str);
                    } catch(e) {
                        console.log('    arg[' + i + '] = ' + args[i]);
                    }
                }
            }
        },
        onLeave: function(retval) {
            console.log('    retval = ' + retval);
        }

});
------ [Memory Address Reference] ------
-- uintptr_t func_addr = libBase + 0x25A9;

var targetAddr = Module.findBaseAddress('libanogs.so').add(0x251F);
Interceptor.attach(targetAddr, {
        onEnter: function(args) {
            console.log('[+] Called: AnoSDKFree @ ' + targetAddr);
            for (var i = 0; i < 8; i++) {
                if (args[i] && !args[i].isNull()) {
                    try {
                        var str = args[i].readCString(64);
                        console.log('    arg[' + i + '] = ' + str);
                    } catch(e) {
                        console.log('    arg[' + i + '] = ' + args[i]);
                    }
                }
            }
        },
        onLeave: function(retval) {
            console.log('    retval = ' + retval);
        }

});
------ [Memory Address Reference] ------
-- uintptr_t func_addr = libBase + 0x251F;


var targetAddr = Module.findBaseAddress('libanogs.so').add(0x2593);
Interceptor.attach(targetAddr, {
        onEnter: function(args) {
            console.log('[+] Called: AnoSDKOnRecvSignature @ ' + targetAddr);
            for (var i = 0; i < 8; i++) {
                if (args[i] && !args[i].isNull()) {
                    try {
                        var str = args[i].readCString(64);
                        console.log('    arg[' + i + '] = ' + str);
                    } catch(e) {
                        console.log('    arg[' + i + '] = ' + args[i]);
                    }
                }
            }
        },
        onLeave: function(retval) {
            console.log('    retval = ' + retval);
        }

});
------ [Memory Address Reference] ------
-- uintptr_t func_addr = libBase + 0x2593;

------------------------------------------------------------------------
------ [Frida - Tracer] ------
var targetAddr = Module.findBaseAddress('libanogs.so').add(0x25C2);
Interceptor.attach(targetAddr, {
        onEnter: function(args) {
            console.log('[+] Called: AnoSDKForExport @ ' + targetAddr);
            for (var i = 0; i < 8; i++) {
                if (args[i] && !args[i].isNull()) {
                    try {
                        var str = args[i].readCString(64);
                        console.log('    arg[' + i + '] = ' + str);
                    } catch(e) {
                        console.log('    arg[' + i + '] = ' + args[i]);
                    }
                }
            }
        },
        onLeave: function(retval) {
            console.log('    retval = ' + retval);
        }

});
------ [Memory Address Reference] ------
-- uintptr_t func_addr = libBase + 0x25C2;


var libBase = Module.findBaseAddress('libanogs.so');
if (libBase) {
    console.log('[+] Base Address: ' + libBase);
    var addr_AnoSDKInit = libBase.add(0x2467);
    Interceptor.attach(addr_AnoSDKInit, {
        onEnter: function(args) { console.log('[Tracer] AnoSDKInit called', args); },
        onLeave: function(retval) { console.log('[Tracer] retval:', retval); }
    });
    var addr_AnoSDKInitEx = libBase.add(0x2472);
    Interceptor.attach(addr_AnoSDKInitEx, {
        onEnter: function(args) { console.log('[Tracer] AnoSDKInitEx called', args); },
        onLeave: function(retval) { console.log('[Tracer] retval:', retval); }
    });
    var addr_AnoSDKSetUserInfo = libBase.add(0x247F);
    Interceptor.attach(addr_AnoSDKSetUserInfo, {
        onEnter: function(args) { console.log('[Tracer] AnoSDKSetUserInfo called', args); },
        onLeave: function(retval) { console.log('[Tracer] retval:', retval); }
    });
    var addr_AnoSDKSetUserInfoWithLicense = libBase.add(0x2491);
    Interceptor.attach(addr_AnoSDKSetUserInfoWithLicense, {
        onEnter: function(args) { console.log('[Tracer] AnoSDKSetUserInfoWithLicense called', args); },
        onLeave: function(retval) { console.log('[Tracer] retval:', retval); }
    });
    var addr_AnoSDKGetReportData = libBase.add(0x24CB);
    Interceptor.attach(addr_AnoSDKGetReportData, {
        onEnter: function(args) { console.log('[Tracer] AnoSDKGetReportData called', args); },
        onLeave: function(retval) { console.log('[Tracer] retval:', retval); }
    });
    var addr_AnoSDKGetReportData2 = libBase.add(0x252A);
    Interceptor.attach(addr_AnoSDKGetReportData2, {
        onEnter: function(args) { console.log('[Tracer] AnoSDKGetReportData2 called', args); },
        onLeave: function(retval) { console.log('[Tracer] retval:', retval); }
    });
    var addr_AnoSDKGetReportData3 = libBase.add(0x253F);
    Interceptor.attach(addr_AnoSDKGetReportData3, {
        onEnter: function(args) { console.log('[Tracer] AnoSDKGetReportData3 called', args); },
        onLeave: function(retval) { console.log('[Tracer] retval:', retval); }
    });
    var addr_AnoSDKGetReportData4 = libBase.add(0x2569);
    Interceptor.attach(addr_AnoSDKGetReportData4, {
        onEnter: function(args) { console.log('[Tracer] AnoSDKGetReportData4 called', args); },
        onLeave: function(retval) { console.log('[Tracer] retval:', retval); }
    });
    var addr_AnoSDKDelReportData = libBase.add(0x24DF);
    Interceptor.attach(addr_AnoSDKDelReportData, {
        onEnter: function(args) { console.log('[Tracer] AnoSDKDelReportData called', args); },
        onLeave: function(retval) { console.log('[Tracer] retval:', retval); }
    });
    var addr_AnoSDKDelReportData3 = libBase.add(0x2554);
    Interceptor.attach(addr_AnoSDKDelReportData3, {
        onEnter: function(args) { console.log('[Tracer] AnoSDKDelReportData3 called', args); },
        onLeave: function(retval) { console.log('[Tracer] retval:', retval); }
    });
    var addr_AnoSDKDelReportData4 = libBase.add(0x257E);
    Interceptor.attach(addr_AnoSDKDelReportData4, {
        onEnter: function(args) { console.log('[Tracer] AnoSDKDelReportData4 called', args); },
        onLeave: function(retval) { console.log('[Tracer] retval:', retval); }
    });
    var addr_AnoSDKIoctl = libBase.add(0x2513);
    Interceptor.attach(addr_AnoSDKIoctl, {
        onEnter: function(args) { console.log('[Tracer] AnoSDKIoctl called', args); },
        onLeave: function(retval) { console.log('[Tracer] retval:', retval); }
    });
    var addr_AnoSDKIoctlOld = libBase.add(0x2504);
    Interceptor.attach(addr_AnoSDKIoctlOld, {
        onEnter: function(args) { console.log('[Tracer] AnoSDKIoctlOld called', args); },
        onLeave: function(retval) { console.log('[Tracer] retval:', retval); }
    });
    var addr_AnoSDKOnPause = libBase.add(0x24AE);
    Interceptor.attach(addr_AnoSDKOnPause, {
        onEnter: function(args) { console.log('[Tracer] AnoSDKOnPause called', args); },
        onLeave: function(retval) { console.log('[Tracer] retval:', retval); }
    });
    var addr_AnoSDKOnResume = libBase.add(0x24BC);
    Interceptor.attach(addr_AnoSDKOnResume, {
        onEnter: function(args) { console.log('[Tracer] AnoSDKOnResume called', args); },
        onLeave: function(retval) { console.log('[Tracer] retval:', retval); }
    });
    var addr_AnoSDKOnRecvData = libBase.add(0x24F3);
    Interceptor.attach(addr_AnoSDKOnRecvData, {
        onEnter: function(args) { console.log('[Tracer] AnoSDKOnRecvData called', args); },
        onLeave: function(retval) { console.log('[Tracer] retval:', retval); }
    });
    var addr_AnoSDKRegistInfoListener = libBase.add(0x25A9);
    Interceptor.attach(addr_AnoSDKRegistInfoListener, {
        onEnter: function(args) { console.log('[Tracer] AnoSDKRegistInfoListener called', args); },
        onLeave: function(retval) { console.log('[Tracer] retval:', retval); }
    });
    var addr_AnoSDKFree = libBase.add(0x251F);
    Interceptor.attach(addr_AnoSDKFree, {
        onEnter: function(args) { console.log('[Tracer] AnoSDKFree called', args); },
        onLeave: function(retval) { console.log('[Tracer] retval:', retval); }
    });
    var addr_AnoSDKOnRecvSignature = libBase.add(0x2593);
    Interceptor.attach(addr_AnoSDKOnRecvSignature, {
        onEnter: function(args) { console.log('[Tracer] AnoSDKOnRecvSignature called', args); },
        onLeave: function(retval) { console.log('[Tracer] retval:', retval); }
    });
    var addr_AnoSDKForExport = libBase.add(0x25C2);
    Interceptor.attach(addr_AnoSDKForExport, {
        onEnter: function(args) { console.log('[Tracer] AnoSDKForExport called', args); },
        onLeave: function(retval) { console.log('[Tracer] retval:', retval); }
    });
    -- Bypass ptrace
    var ptracePtr = Module.findExportByName(null, 'ptrace');
    if (ptracePtr) {
        Interceptor.attach(ptracePtr, {
            onEnter: function(args) { console.log('[Tracer] ptrace', args); },
            onLeave: function(retval) { console.log('[Tracer] ptrace ret:', retval); }
        });
    }
} else {
    console.log('[-] libanogs.so not loaded.');
}
