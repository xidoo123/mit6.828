
obj/user/sendpage:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 68 01 00 00       	call   800199 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 56 0e 00 00       	call   800e94 <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 85 9f 00 00 00    	jne    8000e8 <umain+0xb5>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  800049:	83 ec 04             	sub    $0x4,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	68 00 00 b0 00       	push   $0xb00000
  800053:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800056:	50                   	push   %eax
  800057:	e8 b9 0f 00 00       	call   801015 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 c0 13 80 00       	push   $0x8013c0
  80006c:	e8 13 02 00 00       	call   800284 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800071:	83 c4 04             	add    $0x4,%esp
  800074:	ff 35 04 20 80 00    	pushl  0x802004
  80007a:	e8 51 07 00 00       	call   8007d0 <strlen>
  80007f:	83 c4 0c             	add    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	ff 35 04 20 80 00    	pushl  0x802004
  800089:	68 00 00 b0 00       	push   $0xb00000
  80008e:	e8 46 08 00 00       	call   8008d9 <strncmp>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	75 10                	jne    8000aa <umain+0x77>
			cprintf("child received correct message\n");
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	68 d4 13 80 00       	push   $0x8013d4
  8000a2:	e8 dd 01 00 00       	call   800284 <cprintf>
  8000a7:	83 c4 10             	add    $0x10,%esp

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	ff 35 00 20 80 00    	pushl  0x802000
  8000b3:	e8 18 07 00 00       	call   8007d0 <strlen>
  8000b8:	83 c4 0c             	add    $0xc,%esp
  8000bb:	83 c0 01             	add    $0x1,%eax
  8000be:	50                   	push   %eax
  8000bf:	ff 35 00 20 80 00    	pushl  0x802000
  8000c5:	68 00 00 b0 00       	push   $0xb00000
  8000ca:	e8 34 09 00 00       	call   800a03 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000cf:	6a 07                	push   $0x7
  8000d1:	68 00 00 b0 00       	push   $0xb00000
  8000d6:	6a 00                	push   $0x0
  8000d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8000db:	e8 4c 0f 00 00       	call   80102c <ipc_send>
		return;
  8000e0:	83 c4 20             	add    $0x20,%esp
  8000e3:	e9 af 00 00 00       	jmp    800197 <umain+0x164>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e8:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8000ed:	8b 40 48             	mov    0x48(%eax),%eax
  8000f0:	83 ec 04             	sub    $0x4,%esp
  8000f3:	6a 07                	push   $0x7
  8000f5:	68 00 00 a0 00       	push   $0xa00000
  8000fa:	50                   	push   %eax
  8000fb:	e8 0c 0b 00 00       	call   800c0c <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800100:	83 c4 04             	add    $0x4,%esp
  800103:	ff 35 04 20 80 00    	pushl  0x802004
  800109:	e8 c2 06 00 00       	call   8007d0 <strlen>
  80010e:	83 c4 0c             	add    $0xc,%esp
  800111:	83 c0 01             	add    $0x1,%eax
  800114:	50                   	push   %eax
  800115:	ff 35 04 20 80 00    	pushl  0x802004
  80011b:	68 00 00 a0 00       	push   $0xa00000
  800120:	e8 de 08 00 00       	call   800a03 <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800125:	6a 07                	push   $0x7
  800127:	68 00 00 a0 00       	push   $0xa00000
  80012c:	6a 00                	push   $0x0
  80012e:	ff 75 f4             	pushl  -0xc(%ebp)
  800131:	e8 f6 0e 00 00       	call   80102c <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 cc 0e 00 00       	call   801015 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 c0 13 80 00       	push   $0x8013c0
  800159:	e8 26 01 00 00       	call   800284 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015e:	83 c4 04             	add    $0x4,%esp
  800161:	ff 35 00 20 80 00    	pushl  0x802000
  800167:	e8 64 06 00 00       	call   8007d0 <strlen>
  80016c:	83 c4 0c             	add    $0xc,%esp
  80016f:	50                   	push   %eax
  800170:	ff 35 00 20 80 00    	pushl  0x802000
  800176:	68 00 00 a0 00       	push   $0xa00000
  80017b:	e8 59 07 00 00       	call   8008d9 <strncmp>
  800180:	83 c4 10             	add    $0x10,%esp
  800183:	85 c0                	test   %eax,%eax
  800185:	75 10                	jne    800197 <umain+0x164>
		cprintf("parent received correct message\n");
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	68 f4 13 80 00       	push   $0x8013f4
  80018f:	e8 f0 00 00 00       	call   800284 <cprintf>
  800194:	83 c4 10             	add    $0x10,%esp
	return;
}
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001a1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001a4:	e8 25 0a 00 00       	call   800bce <sys_getenvid>
  8001a9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ae:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001b1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001b6:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001bb:	85 db                	test   %ebx,%ebx
  8001bd:	7e 07                	jle    8001c6 <libmain+0x2d>
		binaryname = argv[0];
  8001bf:	8b 06                	mov    (%esi),%eax
  8001c1:	a3 08 20 80 00       	mov    %eax,0x802008

	// call user main routine
	umain(argc, argv);
  8001c6:	83 ec 08             	sub    $0x8,%esp
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	e8 63 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001d0:	e8 0a 00 00 00       	call   8001df <exit>
}
  8001d5:	83 c4 10             	add    $0x10,%esp
  8001d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001db:	5b                   	pop    %ebx
  8001dc:	5e                   	pop    %esi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8001e5:	6a 00                	push   $0x0
  8001e7:	e8 a1 09 00 00       	call   800b8d <sys_env_destroy>
}
  8001ec:	83 c4 10             	add    $0x10,%esp
  8001ef:	c9                   	leave  
  8001f0:	c3                   	ret    

008001f1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	53                   	push   %ebx
  8001f5:	83 ec 04             	sub    $0x4,%esp
  8001f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001fb:	8b 13                	mov    (%ebx),%edx
  8001fd:	8d 42 01             	lea    0x1(%edx),%eax
  800200:	89 03                	mov    %eax,(%ebx)
  800202:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800205:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800209:	3d ff 00 00 00       	cmp    $0xff,%eax
  80020e:	75 1a                	jne    80022a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800210:	83 ec 08             	sub    $0x8,%esp
  800213:	68 ff 00 00 00       	push   $0xff
  800218:	8d 43 08             	lea    0x8(%ebx),%eax
  80021b:	50                   	push   %eax
  80021c:	e8 2f 09 00 00       	call   800b50 <sys_cputs>
		b->idx = 0;
  800221:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800227:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80022a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80022e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800231:	c9                   	leave  
  800232:	c3                   	ret    

00800233 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80023c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800243:	00 00 00 
	b.cnt = 0;
  800246:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80024d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800250:	ff 75 0c             	pushl  0xc(%ebp)
  800253:	ff 75 08             	pushl  0x8(%ebp)
  800256:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80025c:	50                   	push   %eax
  80025d:	68 f1 01 80 00       	push   $0x8001f1
  800262:	e8 54 01 00 00       	call   8003bb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800267:	83 c4 08             	add    $0x8,%esp
  80026a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800270:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800276:	50                   	push   %eax
  800277:	e8 d4 08 00 00       	call   800b50 <sys_cputs>

	return b.cnt;
}
  80027c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800282:	c9                   	leave  
  800283:	c3                   	ret    

00800284 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80028a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80028d:	50                   	push   %eax
  80028e:	ff 75 08             	pushl  0x8(%ebp)
  800291:	e8 9d ff ff ff       	call   800233 <vcprintf>
	va_end(ap);

	return cnt;
}
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	57                   	push   %edi
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	83 ec 1c             	sub    $0x1c,%esp
  8002a1:	89 c7                	mov    %eax,%edi
  8002a3:	89 d6                	mov    %edx,%esi
  8002a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ae:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002bc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002bf:	39 d3                	cmp    %edx,%ebx
  8002c1:	72 05                	jb     8002c8 <printnum+0x30>
  8002c3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002c6:	77 45                	ja     80030d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002c8:	83 ec 0c             	sub    $0xc,%esp
  8002cb:	ff 75 18             	pushl  0x18(%ebp)
  8002ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002d4:	53                   	push   %ebx
  8002d5:	ff 75 10             	pushl  0x10(%ebp)
  8002d8:	83 ec 08             	sub    $0x8,%esp
  8002db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002de:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002e4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002e7:	e8 44 0e 00 00       	call   801130 <__udivdi3>
  8002ec:	83 c4 18             	add    $0x18,%esp
  8002ef:	52                   	push   %edx
  8002f0:	50                   	push   %eax
  8002f1:	89 f2                	mov    %esi,%edx
  8002f3:	89 f8                	mov    %edi,%eax
  8002f5:	e8 9e ff ff ff       	call   800298 <printnum>
  8002fa:	83 c4 20             	add    $0x20,%esp
  8002fd:	eb 18                	jmp    800317 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	56                   	push   %esi
  800303:	ff 75 18             	pushl  0x18(%ebp)
  800306:	ff d7                	call   *%edi
  800308:	83 c4 10             	add    $0x10,%esp
  80030b:	eb 03                	jmp    800310 <printnum+0x78>
  80030d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800310:	83 eb 01             	sub    $0x1,%ebx
  800313:	85 db                	test   %ebx,%ebx
  800315:	7f e8                	jg     8002ff <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800317:	83 ec 08             	sub    $0x8,%esp
  80031a:	56                   	push   %esi
  80031b:	83 ec 04             	sub    $0x4,%esp
  80031e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800321:	ff 75 e0             	pushl  -0x20(%ebp)
  800324:	ff 75 dc             	pushl  -0x24(%ebp)
  800327:	ff 75 d8             	pushl  -0x28(%ebp)
  80032a:	e8 31 0f 00 00       	call   801260 <__umoddi3>
  80032f:	83 c4 14             	add    $0x14,%esp
  800332:	0f be 80 6c 14 80 00 	movsbl 0x80146c(%eax),%eax
  800339:	50                   	push   %eax
  80033a:	ff d7                	call   *%edi
}
  80033c:	83 c4 10             	add    $0x10,%esp
  80033f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800342:	5b                   	pop    %ebx
  800343:	5e                   	pop    %esi
  800344:	5f                   	pop    %edi
  800345:	5d                   	pop    %ebp
  800346:	c3                   	ret    

00800347 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80034a:	83 fa 01             	cmp    $0x1,%edx
  80034d:	7e 0e                	jle    80035d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80034f:	8b 10                	mov    (%eax),%edx
  800351:	8d 4a 08             	lea    0x8(%edx),%ecx
  800354:	89 08                	mov    %ecx,(%eax)
  800356:	8b 02                	mov    (%edx),%eax
  800358:	8b 52 04             	mov    0x4(%edx),%edx
  80035b:	eb 22                	jmp    80037f <getuint+0x38>
	else if (lflag)
  80035d:	85 d2                	test   %edx,%edx
  80035f:	74 10                	je     800371 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800361:	8b 10                	mov    (%eax),%edx
  800363:	8d 4a 04             	lea    0x4(%edx),%ecx
  800366:	89 08                	mov    %ecx,(%eax)
  800368:	8b 02                	mov    (%edx),%eax
  80036a:	ba 00 00 00 00       	mov    $0x0,%edx
  80036f:	eb 0e                	jmp    80037f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800371:	8b 10                	mov    (%eax),%edx
  800373:	8d 4a 04             	lea    0x4(%edx),%ecx
  800376:	89 08                	mov    %ecx,(%eax)
  800378:	8b 02                	mov    (%edx),%eax
  80037a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80037f:	5d                   	pop    %ebp
  800380:	c3                   	ret    

00800381 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
  800384:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800387:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80038b:	8b 10                	mov    (%eax),%edx
  80038d:	3b 50 04             	cmp    0x4(%eax),%edx
  800390:	73 0a                	jae    80039c <sprintputch+0x1b>
		*b->buf++ = ch;
  800392:	8d 4a 01             	lea    0x1(%edx),%ecx
  800395:	89 08                	mov    %ecx,(%eax)
  800397:	8b 45 08             	mov    0x8(%ebp),%eax
  80039a:	88 02                	mov    %al,(%edx)
}
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    

0080039e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a7:	50                   	push   %eax
  8003a8:	ff 75 10             	pushl  0x10(%ebp)
  8003ab:	ff 75 0c             	pushl  0xc(%ebp)
  8003ae:	ff 75 08             	pushl  0x8(%ebp)
  8003b1:	e8 05 00 00 00       	call   8003bb <vprintfmt>
	va_end(ap);
}
  8003b6:	83 c4 10             	add    $0x10,%esp
  8003b9:	c9                   	leave  
  8003ba:	c3                   	ret    

008003bb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
  8003be:	57                   	push   %edi
  8003bf:	56                   	push   %esi
  8003c0:	53                   	push   %ebx
  8003c1:	83 ec 2c             	sub    $0x2c,%esp
  8003c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8003c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003ca:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003cd:	eb 12                	jmp    8003e1 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003cf:	85 c0                	test   %eax,%eax
  8003d1:	0f 84 89 03 00 00    	je     800760 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003d7:	83 ec 08             	sub    $0x8,%esp
  8003da:	53                   	push   %ebx
  8003db:	50                   	push   %eax
  8003dc:	ff d6                	call   *%esi
  8003de:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e1:	83 c7 01             	add    $0x1,%edi
  8003e4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003e8:	83 f8 25             	cmp    $0x25,%eax
  8003eb:	75 e2                	jne    8003cf <vprintfmt+0x14>
  8003ed:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003f1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003f8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ff:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800406:	ba 00 00 00 00       	mov    $0x0,%edx
  80040b:	eb 07                	jmp    800414 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800410:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8d 47 01             	lea    0x1(%edi),%eax
  800417:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80041a:	0f b6 07             	movzbl (%edi),%eax
  80041d:	0f b6 c8             	movzbl %al,%ecx
  800420:	83 e8 23             	sub    $0x23,%eax
  800423:	3c 55                	cmp    $0x55,%al
  800425:	0f 87 1a 03 00 00    	ja     800745 <vprintfmt+0x38a>
  80042b:	0f b6 c0             	movzbl %al,%eax
  80042e:	ff 24 85 40 15 80 00 	jmp    *0x801540(,%eax,4)
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800438:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80043c:	eb d6                	jmp    800414 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800441:	b8 00 00 00 00       	mov    $0x0,%eax
  800446:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800449:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80044c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800450:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800453:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800456:	83 fa 09             	cmp    $0x9,%edx
  800459:	77 39                	ja     800494 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80045b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80045e:	eb e9                	jmp    800449 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8d 48 04             	lea    0x4(%eax),%ecx
  800466:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800469:	8b 00                	mov    (%eax),%eax
  80046b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800471:	eb 27                	jmp    80049a <vprintfmt+0xdf>
  800473:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800476:	85 c0                	test   %eax,%eax
  800478:	b9 00 00 00 00       	mov    $0x0,%ecx
  80047d:	0f 49 c8             	cmovns %eax,%ecx
  800480:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800483:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800486:	eb 8c                	jmp    800414 <vprintfmt+0x59>
  800488:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80048b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800492:	eb 80                	jmp    800414 <vprintfmt+0x59>
  800494:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800497:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80049a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80049e:	0f 89 70 ff ff ff    	jns    800414 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004a4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004aa:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004b1:	e9 5e ff ff ff       	jmp    800414 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004b6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004bc:	e9 53 ff ff ff       	jmp    800414 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c4:	8d 50 04             	lea    0x4(%eax),%edx
  8004c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	53                   	push   %ebx
  8004ce:	ff 30                	pushl  (%eax)
  8004d0:	ff d6                	call   *%esi
			break;
  8004d2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004d8:	e9 04 ff ff ff       	jmp    8003e1 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e0:	8d 50 04             	lea    0x4(%eax),%edx
  8004e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e6:	8b 00                	mov    (%eax),%eax
  8004e8:	99                   	cltd   
  8004e9:	31 d0                	xor    %edx,%eax
  8004eb:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ed:	83 f8 08             	cmp    $0x8,%eax
  8004f0:	7f 0b                	jg     8004fd <vprintfmt+0x142>
  8004f2:	8b 14 85 a0 16 80 00 	mov    0x8016a0(,%eax,4),%edx
  8004f9:	85 d2                	test   %edx,%edx
  8004fb:	75 18                	jne    800515 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004fd:	50                   	push   %eax
  8004fe:	68 84 14 80 00       	push   $0x801484
  800503:	53                   	push   %ebx
  800504:	56                   	push   %esi
  800505:	e8 94 fe ff ff       	call   80039e <printfmt>
  80050a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800510:	e9 cc fe ff ff       	jmp    8003e1 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800515:	52                   	push   %edx
  800516:	68 8d 14 80 00       	push   $0x80148d
  80051b:	53                   	push   %ebx
  80051c:	56                   	push   %esi
  80051d:	e8 7c fe ff ff       	call   80039e <printfmt>
  800522:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800525:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800528:	e9 b4 fe ff ff       	jmp    8003e1 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80052d:	8b 45 14             	mov    0x14(%ebp),%eax
  800530:	8d 50 04             	lea    0x4(%eax),%edx
  800533:	89 55 14             	mov    %edx,0x14(%ebp)
  800536:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800538:	85 ff                	test   %edi,%edi
  80053a:	b8 7d 14 80 00       	mov    $0x80147d,%eax
  80053f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800542:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800546:	0f 8e 94 00 00 00    	jle    8005e0 <vprintfmt+0x225>
  80054c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800550:	0f 84 98 00 00 00    	je     8005ee <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800556:	83 ec 08             	sub    $0x8,%esp
  800559:	ff 75 d0             	pushl  -0x30(%ebp)
  80055c:	57                   	push   %edi
  80055d:	e8 86 02 00 00       	call   8007e8 <strnlen>
  800562:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800565:	29 c1                	sub    %eax,%ecx
  800567:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80056a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80056d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800571:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800574:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800577:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800579:	eb 0f                	jmp    80058a <vprintfmt+0x1cf>
					putch(padc, putdat);
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	53                   	push   %ebx
  80057f:	ff 75 e0             	pushl  -0x20(%ebp)
  800582:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800584:	83 ef 01             	sub    $0x1,%edi
  800587:	83 c4 10             	add    $0x10,%esp
  80058a:	85 ff                	test   %edi,%edi
  80058c:	7f ed                	jg     80057b <vprintfmt+0x1c0>
  80058e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800591:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800594:	85 c9                	test   %ecx,%ecx
  800596:	b8 00 00 00 00       	mov    $0x0,%eax
  80059b:	0f 49 c1             	cmovns %ecx,%eax
  80059e:	29 c1                	sub    %eax,%ecx
  8005a0:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a9:	89 cb                	mov    %ecx,%ebx
  8005ab:	eb 4d                	jmp    8005fa <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005ad:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005b1:	74 1b                	je     8005ce <vprintfmt+0x213>
  8005b3:	0f be c0             	movsbl %al,%eax
  8005b6:	83 e8 20             	sub    $0x20,%eax
  8005b9:	83 f8 5e             	cmp    $0x5e,%eax
  8005bc:	76 10                	jbe    8005ce <vprintfmt+0x213>
					putch('?', putdat);
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	ff 75 0c             	pushl  0xc(%ebp)
  8005c4:	6a 3f                	push   $0x3f
  8005c6:	ff 55 08             	call   *0x8(%ebp)
  8005c9:	83 c4 10             	add    $0x10,%esp
  8005cc:	eb 0d                	jmp    8005db <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005ce:	83 ec 08             	sub    $0x8,%esp
  8005d1:	ff 75 0c             	pushl  0xc(%ebp)
  8005d4:	52                   	push   %edx
  8005d5:	ff 55 08             	call   *0x8(%ebp)
  8005d8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005db:	83 eb 01             	sub    $0x1,%ebx
  8005de:	eb 1a                	jmp    8005fa <vprintfmt+0x23f>
  8005e0:	89 75 08             	mov    %esi,0x8(%ebp)
  8005e3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005ec:	eb 0c                	jmp    8005fa <vprintfmt+0x23f>
  8005ee:	89 75 08             	mov    %esi,0x8(%ebp)
  8005f1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005f4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005fa:	83 c7 01             	add    $0x1,%edi
  8005fd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800601:	0f be d0             	movsbl %al,%edx
  800604:	85 d2                	test   %edx,%edx
  800606:	74 23                	je     80062b <vprintfmt+0x270>
  800608:	85 f6                	test   %esi,%esi
  80060a:	78 a1                	js     8005ad <vprintfmt+0x1f2>
  80060c:	83 ee 01             	sub    $0x1,%esi
  80060f:	79 9c                	jns    8005ad <vprintfmt+0x1f2>
  800611:	89 df                	mov    %ebx,%edi
  800613:	8b 75 08             	mov    0x8(%ebp),%esi
  800616:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800619:	eb 18                	jmp    800633 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80061b:	83 ec 08             	sub    $0x8,%esp
  80061e:	53                   	push   %ebx
  80061f:	6a 20                	push   $0x20
  800621:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800623:	83 ef 01             	sub    $0x1,%edi
  800626:	83 c4 10             	add    $0x10,%esp
  800629:	eb 08                	jmp    800633 <vprintfmt+0x278>
  80062b:	89 df                	mov    %ebx,%edi
  80062d:	8b 75 08             	mov    0x8(%ebp),%esi
  800630:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800633:	85 ff                	test   %edi,%edi
  800635:	7f e4                	jg     80061b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800637:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80063a:	e9 a2 fd ff ff       	jmp    8003e1 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80063f:	83 fa 01             	cmp    $0x1,%edx
  800642:	7e 16                	jle    80065a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8d 50 08             	lea    0x8(%eax),%edx
  80064a:	89 55 14             	mov    %edx,0x14(%ebp)
  80064d:	8b 50 04             	mov    0x4(%eax),%edx
  800650:	8b 00                	mov    (%eax),%eax
  800652:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800655:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800658:	eb 32                	jmp    80068c <vprintfmt+0x2d1>
	else if (lflag)
  80065a:	85 d2                	test   %edx,%edx
  80065c:	74 18                	je     800676 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8d 50 04             	lea    0x4(%eax),%edx
  800664:	89 55 14             	mov    %edx,0x14(%ebp)
  800667:	8b 00                	mov    (%eax),%eax
  800669:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066c:	89 c1                	mov    %eax,%ecx
  80066e:	c1 f9 1f             	sar    $0x1f,%ecx
  800671:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800674:	eb 16                	jmp    80068c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800676:	8b 45 14             	mov    0x14(%ebp),%eax
  800679:	8d 50 04             	lea    0x4(%eax),%edx
  80067c:	89 55 14             	mov    %edx,0x14(%ebp)
  80067f:	8b 00                	mov    (%eax),%eax
  800681:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800684:	89 c1                	mov    %eax,%ecx
  800686:	c1 f9 1f             	sar    $0x1f,%ecx
  800689:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80068c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80068f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800692:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800697:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80069b:	79 74                	jns    800711 <vprintfmt+0x356>
				putch('-', putdat);
  80069d:	83 ec 08             	sub    $0x8,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	6a 2d                	push   $0x2d
  8006a3:	ff d6                	call   *%esi
				num = -(long long) num;
  8006a5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006a8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006ab:	f7 d8                	neg    %eax
  8006ad:	83 d2 00             	adc    $0x0,%edx
  8006b0:	f7 da                	neg    %edx
  8006b2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006b5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006ba:	eb 55                	jmp    800711 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006bc:	8d 45 14             	lea    0x14(%ebp),%eax
  8006bf:	e8 83 fc ff ff       	call   800347 <getuint>
			base = 10;
  8006c4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006c9:	eb 46                	jmp    800711 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8006cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ce:	e8 74 fc ff ff       	call   800347 <getuint>
			base = 8;
  8006d3:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006d8:	eb 37                	jmp    800711 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006da:	83 ec 08             	sub    $0x8,%esp
  8006dd:	53                   	push   %ebx
  8006de:	6a 30                	push   $0x30
  8006e0:	ff d6                	call   *%esi
			putch('x', putdat);
  8006e2:	83 c4 08             	add    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	6a 78                	push   $0x78
  8006e8:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ed:	8d 50 04             	lea    0x4(%eax),%edx
  8006f0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006f3:	8b 00                	mov    (%eax),%eax
  8006f5:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006fa:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006fd:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800702:	eb 0d                	jmp    800711 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800704:	8d 45 14             	lea    0x14(%ebp),%eax
  800707:	e8 3b fc ff ff       	call   800347 <getuint>
			base = 16;
  80070c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800711:	83 ec 0c             	sub    $0xc,%esp
  800714:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800718:	57                   	push   %edi
  800719:	ff 75 e0             	pushl  -0x20(%ebp)
  80071c:	51                   	push   %ecx
  80071d:	52                   	push   %edx
  80071e:	50                   	push   %eax
  80071f:	89 da                	mov    %ebx,%edx
  800721:	89 f0                	mov    %esi,%eax
  800723:	e8 70 fb ff ff       	call   800298 <printnum>
			break;
  800728:	83 c4 20             	add    $0x20,%esp
  80072b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80072e:	e9 ae fc ff ff       	jmp    8003e1 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800733:	83 ec 08             	sub    $0x8,%esp
  800736:	53                   	push   %ebx
  800737:	51                   	push   %ecx
  800738:	ff d6                	call   *%esi
			break;
  80073a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800740:	e9 9c fc ff ff       	jmp    8003e1 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	53                   	push   %ebx
  800749:	6a 25                	push   $0x25
  80074b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80074d:	83 c4 10             	add    $0x10,%esp
  800750:	eb 03                	jmp    800755 <vprintfmt+0x39a>
  800752:	83 ef 01             	sub    $0x1,%edi
  800755:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800759:	75 f7                	jne    800752 <vprintfmt+0x397>
  80075b:	e9 81 fc ff ff       	jmp    8003e1 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800760:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800763:	5b                   	pop    %ebx
  800764:	5e                   	pop    %esi
  800765:	5f                   	pop    %edi
  800766:	5d                   	pop    %ebp
  800767:	c3                   	ret    

00800768 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	83 ec 18             	sub    $0x18,%esp
  80076e:	8b 45 08             	mov    0x8(%ebp),%eax
  800771:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800774:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800777:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80077b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80077e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800785:	85 c0                	test   %eax,%eax
  800787:	74 26                	je     8007af <vsnprintf+0x47>
  800789:	85 d2                	test   %edx,%edx
  80078b:	7e 22                	jle    8007af <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80078d:	ff 75 14             	pushl  0x14(%ebp)
  800790:	ff 75 10             	pushl  0x10(%ebp)
  800793:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800796:	50                   	push   %eax
  800797:	68 81 03 80 00       	push   $0x800381
  80079c:	e8 1a fc ff ff       	call   8003bb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007aa:	83 c4 10             	add    $0x10,%esp
  8007ad:	eb 05                	jmp    8007b4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007b4:	c9                   	leave  
  8007b5:	c3                   	ret    

008007b6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007bc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007bf:	50                   	push   %eax
  8007c0:	ff 75 10             	pushl  0x10(%ebp)
  8007c3:	ff 75 0c             	pushl  0xc(%ebp)
  8007c6:	ff 75 08             	pushl  0x8(%ebp)
  8007c9:	e8 9a ff ff ff       	call   800768 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ce:	c9                   	leave  
  8007cf:	c3                   	ret    

008007d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007db:	eb 03                	jmp    8007e0 <strlen+0x10>
		n++;
  8007dd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e4:	75 f7                	jne    8007dd <strlen+0xd>
		n++;
	return n;
}
  8007e6:	5d                   	pop    %ebp
  8007e7:	c3                   	ret    

008007e8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ee:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8007f6:	eb 03                	jmp    8007fb <strnlen+0x13>
		n++;
  8007f8:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fb:	39 c2                	cmp    %eax,%edx
  8007fd:	74 08                	je     800807 <strnlen+0x1f>
  8007ff:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800803:	75 f3                	jne    8007f8 <strnlen+0x10>
  800805:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	53                   	push   %ebx
  80080d:	8b 45 08             	mov    0x8(%ebp),%eax
  800810:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800813:	89 c2                	mov    %eax,%edx
  800815:	83 c2 01             	add    $0x1,%edx
  800818:	83 c1 01             	add    $0x1,%ecx
  80081b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80081f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800822:	84 db                	test   %bl,%bl
  800824:	75 ef                	jne    800815 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800826:	5b                   	pop    %ebx
  800827:	5d                   	pop    %ebp
  800828:	c3                   	ret    

00800829 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	53                   	push   %ebx
  80082d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800830:	53                   	push   %ebx
  800831:	e8 9a ff ff ff       	call   8007d0 <strlen>
  800836:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800839:	ff 75 0c             	pushl  0xc(%ebp)
  80083c:	01 d8                	add    %ebx,%eax
  80083e:	50                   	push   %eax
  80083f:	e8 c5 ff ff ff       	call   800809 <strcpy>
	return dst;
}
  800844:	89 d8                	mov    %ebx,%eax
  800846:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800849:	c9                   	leave  
  80084a:	c3                   	ret    

0080084b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	56                   	push   %esi
  80084f:	53                   	push   %ebx
  800850:	8b 75 08             	mov    0x8(%ebp),%esi
  800853:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800856:	89 f3                	mov    %esi,%ebx
  800858:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80085b:	89 f2                	mov    %esi,%edx
  80085d:	eb 0f                	jmp    80086e <strncpy+0x23>
		*dst++ = *src;
  80085f:	83 c2 01             	add    $0x1,%edx
  800862:	0f b6 01             	movzbl (%ecx),%eax
  800865:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800868:	80 39 01             	cmpb   $0x1,(%ecx)
  80086b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086e:	39 da                	cmp    %ebx,%edx
  800870:	75 ed                	jne    80085f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800872:	89 f0                	mov    %esi,%eax
  800874:	5b                   	pop    %ebx
  800875:	5e                   	pop    %esi
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	56                   	push   %esi
  80087c:	53                   	push   %ebx
  80087d:	8b 75 08             	mov    0x8(%ebp),%esi
  800880:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800883:	8b 55 10             	mov    0x10(%ebp),%edx
  800886:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800888:	85 d2                	test   %edx,%edx
  80088a:	74 21                	je     8008ad <strlcpy+0x35>
  80088c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800890:	89 f2                	mov    %esi,%edx
  800892:	eb 09                	jmp    80089d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800894:	83 c2 01             	add    $0x1,%edx
  800897:	83 c1 01             	add    $0x1,%ecx
  80089a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80089d:	39 c2                	cmp    %eax,%edx
  80089f:	74 09                	je     8008aa <strlcpy+0x32>
  8008a1:	0f b6 19             	movzbl (%ecx),%ebx
  8008a4:	84 db                	test   %bl,%bl
  8008a6:	75 ec                	jne    800894 <strlcpy+0x1c>
  8008a8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008aa:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ad:	29 f0                	sub    %esi,%eax
}
  8008af:	5b                   	pop    %ebx
  8008b0:	5e                   	pop    %esi
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008bc:	eb 06                	jmp    8008c4 <strcmp+0x11>
		p++, q++;
  8008be:	83 c1 01             	add    $0x1,%ecx
  8008c1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008c4:	0f b6 01             	movzbl (%ecx),%eax
  8008c7:	84 c0                	test   %al,%al
  8008c9:	74 04                	je     8008cf <strcmp+0x1c>
  8008cb:	3a 02                	cmp    (%edx),%al
  8008cd:	74 ef                	je     8008be <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cf:	0f b6 c0             	movzbl %al,%eax
  8008d2:	0f b6 12             	movzbl (%edx),%edx
  8008d5:	29 d0                	sub    %edx,%eax
}
  8008d7:	5d                   	pop    %ebp
  8008d8:	c3                   	ret    

008008d9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	53                   	push   %ebx
  8008dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e3:	89 c3                	mov    %eax,%ebx
  8008e5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008e8:	eb 06                	jmp    8008f0 <strncmp+0x17>
		n--, p++, q++;
  8008ea:	83 c0 01             	add    $0x1,%eax
  8008ed:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f0:	39 d8                	cmp    %ebx,%eax
  8008f2:	74 15                	je     800909 <strncmp+0x30>
  8008f4:	0f b6 08             	movzbl (%eax),%ecx
  8008f7:	84 c9                	test   %cl,%cl
  8008f9:	74 04                	je     8008ff <strncmp+0x26>
  8008fb:	3a 0a                	cmp    (%edx),%cl
  8008fd:	74 eb                	je     8008ea <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ff:	0f b6 00             	movzbl (%eax),%eax
  800902:	0f b6 12             	movzbl (%edx),%edx
  800905:	29 d0                	sub    %edx,%eax
  800907:	eb 05                	jmp    80090e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800909:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80090e:	5b                   	pop    %ebx
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	8b 45 08             	mov    0x8(%ebp),%eax
  800917:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80091b:	eb 07                	jmp    800924 <strchr+0x13>
		if (*s == c)
  80091d:	38 ca                	cmp    %cl,%dl
  80091f:	74 0f                	je     800930 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800921:	83 c0 01             	add    $0x1,%eax
  800924:	0f b6 10             	movzbl (%eax),%edx
  800927:	84 d2                	test   %dl,%dl
  800929:	75 f2                	jne    80091d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80092b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80093c:	eb 03                	jmp    800941 <strfind+0xf>
  80093e:	83 c0 01             	add    $0x1,%eax
  800941:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800944:	38 ca                	cmp    %cl,%dl
  800946:	74 04                	je     80094c <strfind+0x1a>
  800948:	84 d2                	test   %dl,%dl
  80094a:	75 f2                	jne    80093e <strfind+0xc>
			break;
	return (char *) s;
}
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	57                   	push   %edi
  800952:	56                   	push   %esi
  800953:	53                   	push   %ebx
  800954:	8b 7d 08             	mov    0x8(%ebp),%edi
  800957:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80095a:	85 c9                	test   %ecx,%ecx
  80095c:	74 36                	je     800994 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80095e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800964:	75 28                	jne    80098e <memset+0x40>
  800966:	f6 c1 03             	test   $0x3,%cl
  800969:	75 23                	jne    80098e <memset+0x40>
		c &= 0xFF;
  80096b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80096f:	89 d3                	mov    %edx,%ebx
  800971:	c1 e3 08             	shl    $0x8,%ebx
  800974:	89 d6                	mov    %edx,%esi
  800976:	c1 e6 18             	shl    $0x18,%esi
  800979:	89 d0                	mov    %edx,%eax
  80097b:	c1 e0 10             	shl    $0x10,%eax
  80097e:	09 f0                	or     %esi,%eax
  800980:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800982:	89 d8                	mov    %ebx,%eax
  800984:	09 d0                	or     %edx,%eax
  800986:	c1 e9 02             	shr    $0x2,%ecx
  800989:	fc                   	cld    
  80098a:	f3 ab                	rep stos %eax,%es:(%edi)
  80098c:	eb 06                	jmp    800994 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80098e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800991:	fc                   	cld    
  800992:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800994:	89 f8                	mov    %edi,%eax
  800996:	5b                   	pop    %ebx
  800997:	5e                   	pop    %esi
  800998:	5f                   	pop    %edi
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	57                   	push   %edi
  80099f:	56                   	push   %esi
  8009a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a9:	39 c6                	cmp    %eax,%esi
  8009ab:	73 35                	jae    8009e2 <memmove+0x47>
  8009ad:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b0:	39 d0                	cmp    %edx,%eax
  8009b2:	73 2e                	jae    8009e2 <memmove+0x47>
		s += n;
		d += n;
  8009b4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b7:	89 d6                	mov    %edx,%esi
  8009b9:	09 fe                	or     %edi,%esi
  8009bb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c1:	75 13                	jne    8009d6 <memmove+0x3b>
  8009c3:	f6 c1 03             	test   $0x3,%cl
  8009c6:	75 0e                	jne    8009d6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009c8:	83 ef 04             	sub    $0x4,%edi
  8009cb:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009ce:	c1 e9 02             	shr    $0x2,%ecx
  8009d1:	fd                   	std    
  8009d2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d4:	eb 09                	jmp    8009df <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009d6:	83 ef 01             	sub    $0x1,%edi
  8009d9:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009dc:	fd                   	std    
  8009dd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009df:	fc                   	cld    
  8009e0:	eb 1d                	jmp    8009ff <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e2:	89 f2                	mov    %esi,%edx
  8009e4:	09 c2                	or     %eax,%edx
  8009e6:	f6 c2 03             	test   $0x3,%dl
  8009e9:	75 0f                	jne    8009fa <memmove+0x5f>
  8009eb:	f6 c1 03             	test   $0x3,%cl
  8009ee:	75 0a                	jne    8009fa <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009f0:	c1 e9 02             	shr    $0x2,%ecx
  8009f3:	89 c7                	mov    %eax,%edi
  8009f5:	fc                   	cld    
  8009f6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f8:	eb 05                	jmp    8009ff <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009fa:	89 c7                	mov    %eax,%edi
  8009fc:	fc                   	cld    
  8009fd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ff:	5e                   	pop    %esi
  800a00:	5f                   	pop    %edi
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a06:	ff 75 10             	pushl  0x10(%ebp)
  800a09:	ff 75 0c             	pushl  0xc(%ebp)
  800a0c:	ff 75 08             	pushl  0x8(%ebp)
  800a0f:	e8 87 ff ff ff       	call   80099b <memmove>
}
  800a14:	c9                   	leave  
  800a15:	c3                   	ret    

00800a16 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	56                   	push   %esi
  800a1a:	53                   	push   %ebx
  800a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a21:	89 c6                	mov    %eax,%esi
  800a23:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a26:	eb 1a                	jmp    800a42 <memcmp+0x2c>
		if (*s1 != *s2)
  800a28:	0f b6 08             	movzbl (%eax),%ecx
  800a2b:	0f b6 1a             	movzbl (%edx),%ebx
  800a2e:	38 d9                	cmp    %bl,%cl
  800a30:	74 0a                	je     800a3c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a32:	0f b6 c1             	movzbl %cl,%eax
  800a35:	0f b6 db             	movzbl %bl,%ebx
  800a38:	29 d8                	sub    %ebx,%eax
  800a3a:	eb 0f                	jmp    800a4b <memcmp+0x35>
		s1++, s2++;
  800a3c:	83 c0 01             	add    $0x1,%eax
  800a3f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a42:	39 f0                	cmp    %esi,%eax
  800a44:	75 e2                	jne    800a28 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a46:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4b:	5b                   	pop    %ebx
  800a4c:	5e                   	pop    %esi
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	53                   	push   %ebx
  800a53:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a56:	89 c1                	mov    %eax,%ecx
  800a58:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a5f:	eb 0a                	jmp    800a6b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a61:	0f b6 10             	movzbl (%eax),%edx
  800a64:	39 da                	cmp    %ebx,%edx
  800a66:	74 07                	je     800a6f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a68:	83 c0 01             	add    $0x1,%eax
  800a6b:	39 c8                	cmp    %ecx,%eax
  800a6d:	72 f2                	jb     800a61 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a6f:	5b                   	pop    %ebx
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	57                   	push   %edi
  800a76:	56                   	push   %esi
  800a77:	53                   	push   %ebx
  800a78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7e:	eb 03                	jmp    800a83 <strtol+0x11>
		s++;
  800a80:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a83:	0f b6 01             	movzbl (%ecx),%eax
  800a86:	3c 20                	cmp    $0x20,%al
  800a88:	74 f6                	je     800a80 <strtol+0xe>
  800a8a:	3c 09                	cmp    $0x9,%al
  800a8c:	74 f2                	je     800a80 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a8e:	3c 2b                	cmp    $0x2b,%al
  800a90:	75 0a                	jne    800a9c <strtol+0x2a>
		s++;
  800a92:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a95:	bf 00 00 00 00       	mov    $0x0,%edi
  800a9a:	eb 11                	jmp    800aad <strtol+0x3b>
  800a9c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aa1:	3c 2d                	cmp    $0x2d,%al
  800aa3:	75 08                	jne    800aad <strtol+0x3b>
		s++, neg = 1;
  800aa5:	83 c1 01             	add    $0x1,%ecx
  800aa8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aad:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ab3:	75 15                	jne    800aca <strtol+0x58>
  800ab5:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab8:	75 10                	jne    800aca <strtol+0x58>
  800aba:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800abe:	75 7c                	jne    800b3c <strtol+0xca>
		s += 2, base = 16;
  800ac0:	83 c1 02             	add    $0x2,%ecx
  800ac3:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac8:	eb 16                	jmp    800ae0 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800aca:	85 db                	test   %ebx,%ebx
  800acc:	75 12                	jne    800ae0 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ace:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad3:	80 39 30             	cmpb   $0x30,(%ecx)
  800ad6:	75 08                	jne    800ae0 <strtol+0x6e>
		s++, base = 8;
  800ad8:	83 c1 01             	add    $0x1,%ecx
  800adb:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ae0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ae8:	0f b6 11             	movzbl (%ecx),%edx
  800aeb:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aee:	89 f3                	mov    %esi,%ebx
  800af0:	80 fb 09             	cmp    $0x9,%bl
  800af3:	77 08                	ja     800afd <strtol+0x8b>
			dig = *s - '0';
  800af5:	0f be d2             	movsbl %dl,%edx
  800af8:	83 ea 30             	sub    $0x30,%edx
  800afb:	eb 22                	jmp    800b1f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800afd:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b00:	89 f3                	mov    %esi,%ebx
  800b02:	80 fb 19             	cmp    $0x19,%bl
  800b05:	77 08                	ja     800b0f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b07:	0f be d2             	movsbl %dl,%edx
  800b0a:	83 ea 57             	sub    $0x57,%edx
  800b0d:	eb 10                	jmp    800b1f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b0f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b12:	89 f3                	mov    %esi,%ebx
  800b14:	80 fb 19             	cmp    $0x19,%bl
  800b17:	77 16                	ja     800b2f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b19:	0f be d2             	movsbl %dl,%edx
  800b1c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b1f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b22:	7d 0b                	jge    800b2f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b24:	83 c1 01             	add    $0x1,%ecx
  800b27:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b2b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b2d:	eb b9                	jmp    800ae8 <strtol+0x76>

	if (endptr)
  800b2f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b33:	74 0d                	je     800b42 <strtol+0xd0>
		*endptr = (char *) s;
  800b35:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b38:	89 0e                	mov    %ecx,(%esi)
  800b3a:	eb 06                	jmp    800b42 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b3c:	85 db                	test   %ebx,%ebx
  800b3e:	74 98                	je     800ad8 <strtol+0x66>
  800b40:	eb 9e                	jmp    800ae0 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b42:	89 c2                	mov    %eax,%edx
  800b44:	f7 da                	neg    %edx
  800b46:	85 ff                	test   %edi,%edi
  800b48:	0f 45 c2             	cmovne %edx,%eax
}
  800b4b:	5b                   	pop    %ebx
  800b4c:	5e                   	pop    %esi
  800b4d:	5f                   	pop    %edi
  800b4e:	5d                   	pop    %ebp
  800b4f:	c3                   	ret    

00800b50 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	57                   	push   %edi
  800b54:	56                   	push   %esi
  800b55:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b56:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b61:	89 c3                	mov    %eax,%ebx
  800b63:	89 c7                	mov    %eax,%edi
  800b65:	89 c6                	mov    %eax,%esi
  800b67:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b69:	5b                   	pop    %ebx
  800b6a:	5e                   	pop    %esi
  800b6b:	5f                   	pop    %edi
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    

00800b6e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b74:	ba 00 00 00 00       	mov    $0x0,%edx
  800b79:	b8 01 00 00 00       	mov    $0x1,%eax
  800b7e:	89 d1                	mov    %edx,%ecx
  800b80:	89 d3                	mov    %edx,%ebx
  800b82:	89 d7                	mov    %edx,%edi
  800b84:	89 d6                	mov    %edx,%esi
  800b86:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b88:	5b                   	pop    %ebx
  800b89:	5e                   	pop    %esi
  800b8a:	5f                   	pop    %edi
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	57                   	push   %edi
  800b91:	56                   	push   %esi
  800b92:	53                   	push   %ebx
  800b93:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b96:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b9b:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba3:	89 cb                	mov    %ecx,%ebx
  800ba5:	89 cf                	mov    %ecx,%edi
  800ba7:	89 ce                	mov    %ecx,%esi
  800ba9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bab:	85 c0                	test   %eax,%eax
  800bad:	7e 17                	jle    800bc6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800baf:	83 ec 0c             	sub    $0xc,%esp
  800bb2:	50                   	push   %eax
  800bb3:	6a 03                	push   $0x3
  800bb5:	68 c4 16 80 00       	push   $0x8016c4
  800bba:	6a 23                	push   $0x23
  800bbc:	68 e1 16 80 00       	push   $0x8016e1
  800bc1:	e8 b6 04 00 00       	call   80107c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd9:	b8 02 00 00 00       	mov    $0x2,%eax
  800bde:	89 d1                	mov    %edx,%ecx
  800be0:	89 d3                	mov    %edx,%ebx
  800be2:	89 d7                	mov    %edx,%edi
  800be4:	89 d6                	mov    %edx,%esi
  800be6:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5f                   	pop    %edi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    

00800bed <sys_yield>:

void
sys_yield(void)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	57                   	push   %edi
  800bf1:	56                   	push   %esi
  800bf2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bfd:	89 d1                	mov    %edx,%ecx
  800bff:	89 d3                	mov    %edx,%ebx
  800c01:	89 d7                	mov    %edx,%edi
  800c03:	89 d6                	mov    %edx,%esi
  800c05:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c07:	5b                   	pop    %ebx
  800c08:	5e                   	pop    %esi
  800c09:	5f                   	pop    %edi
  800c0a:	5d                   	pop    %ebp
  800c0b:	c3                   	ret    

00800c0c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	57                   	push   %edi
  800c10:	56                   	push   %esi
  800c11:	53                   	push   %ebx
  800c12:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c15:	be 00 00 00 00       	mov    $0x0,%esi
  800c1a:	b8 04 00 00 00       	mov    $0x4,%eax
  800c1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c22:	8b 55 08             	mov    0x8(%ebp),%edx
  800c25:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c28:	89 f7                	mov    %esi,%edi
  800c2a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c2c:	85 c0                	test   %eax,%eax
  800c2e:	7e 17                	jle    800c47 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c30:	83 ec 0c             	sub    $0xc,%esp
  800c33:	50                   	push   %eax
  800c34:	6a 04                	push   $0x4
  800c36:	68 c4 16 80 00       	push   $0x8016c4
  800c3b:	6a 23                	push   $0x23
  800c3d:	68 e1 16 80 00       	push   $0x8016e1
  800c42:	e8 35 04 00 00       	call   80107c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	57                   	push   %edi
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
  800c55:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c58:	b8 05 00 00 00       	mov    $0x5,%eax
  800c5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c60:	8b 55 08             	mov    0x8(%ebp),%edx
  800c63:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c66:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c69:	8b 75 18             	mov    0x18(%ebp),%esi
  800c6c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c6e:	85 c0                	test   %eax,%eax
  800c70:	7e 17                	jle    800c89 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c72:	83 ec 0c             	sub    $0xc,%esp
  800c75:	50                   	push   %eax
  800c76:	6a 05                	push   $0x5
  800c78:	68 c4 16 80 00       	push   $0x8016c4
  800c7d:	6a 23                	push   $0x23
  800c7f:	68 e1 16 80 00       	push   $0x8016e1
  800c84:	e8 f3 03 00 00       	call   80107c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8c:	5b                   	pop    %ebx
  800c8d:	5e                   	pop    %esi
  800c8e:	5f                   	pop    %edi
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    

00800c91 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	57                   	push   %edi
  800c95:	56                   	push   %esi
  800c96:	53                   	push   %ebx
  800c97:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9f:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca7:	8b 55 08             	mov    0x8(%ebp),%edx
  800caa:	89 df                	mov    %ebx,%edi
  800cac:	89 de                	mov    %ebx,%esi
  800cae:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb0:	85 c0                	test   %eax,%eax
  800cb2:	7e 17                	jle    800ccb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb4:	83 ec 0c             	sub    $0xc,%esp
  800cb7:	50                   	push   %eax
  800cb8:	6a 06                	push   $0x6
  800cba:	68 c4 16 80 00       	push   $0x8016c4
  800cbf:	6a 23                	push   $0x23
  800cc1:	68 e1 16 80 00       	push   $0x8016e1
  800cc6:	e8 b1 03 00 00       	call   80107c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ccb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cce:	5b                   	pop    %ebx
  800ccf:	5e                   	pop    %esi
  800cd0:	5f                   	pop    %edi
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    

00800cd3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	57                   	push   %edi
  800cd7:	56                   	push   %esi
  800cd8:	53                   	push   %ebx
  800cd9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce1:	b8 08 00 00 00       	mov    $0x8,%eax
  800ce6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cec:	89 df                	mov    %ebx,%edi
  800cee:	89 de                	mov    %ebx,%esi
  800cf0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf2:	85 c0                	test   %eax,%eax
  800cf4:	7e 17                	jle    800d0d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf6:	83 ec 0c             	sub    $0xc,%esp
  800cf9:	50                   	push   %eax
  800cfa:	6a 08                	push   $0x8
  800cfc:	68 c4 16 80 00       	push   $0x8016c4
  800d01:	6a 23                	push   $0x23
  800d03:	68 e1 16 80 00       	push   $0x8016e1
  800d08:	e8 6f 03 00 00       	call   80107c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    

00800d15 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	57                   	push   %edi
  800d19:	56                   	push   %esi
  800d1a:	53                   	push   %ebx
  800d1b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d23:	b8 09 00 00 00       	mov    $0x9,%eax
  800d28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2e:	89 df                	mov    %ebx,%edi
  800d30:	89 de                	mov    %ebx,%esi
  800d32:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d34:	85 c0                	test   %eax,%eax
  800d36:	7e 17                	jle    800d4f <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d38:	83 ec 0c             	sub    $0xc,%esp
  800d3b:	50                   	push   %eax
  800d3c:	6a 09                	push   $0x9
  800d3e:	68 c4 16 80 00       	push   $0x8016c4
  800d43:	6a 23                	push   $0x23
  800d45:	68 e1 16 80 00       	push   $0x8016e1
  800d4a:	e8 2d 03 00 00       	call   80107c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d52:	5b                   	pop    %ebx
  800d53:	5e                   	pop    %esi
  800d54:	5f                   	pop    %edi
  800d55:	5d                   	pop    %ebp
  800d56:	c3                   	ret    

00800d57 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	57                   	push   %edi
  800d5b:	56                   	push   %esi
  800d5c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5d:	be 00 00 00 00       	mov    $0x0,%esi
  800d62:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d70:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d73:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d75:	5b                   	pop    %ebx
  800d76:	5e                   	pop    %esi
  800d77:	5f                   	pop    %edi
  800d78:	5d                   	pop    %ebp
  800d79:	c3                   	ret    

00800d7a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	57                   	push   %edi
  800d7e:	56                   	push   %esi
  800d7f:	53                   	push   %ebx
  800d80:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d83:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d88:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d90:	89 cb                	mov    %ecx,%ebx
  800d92:	89 cf                	mov    %ecx,%edi
  800d94:	89 ce                	mov    %ecx,%esi
  800d96:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d98:	85 c0                	test   %eax,%eax
  800d9a:	7e 17                	jle    800db3 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9c:	83 ec 0c             	sub    $0xc,%esp
  800d9f:	50                   	push   %eax
  800da0:	6a 0c                	push   $0xc
  800da2:	68 c4 16 80 00       	push   $0x8016c4
  800da7:	6a 23                	push   $0x23
  800da9:	68 e1 16 80 00       	push   $0x8016e1
  800dae:	e8 c9 02 00 00       	call   80107c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800db3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db6:	5b                   	pop    %ebx
  800db7:	5e                   	pop    %esi
  800db8:	5f                   	pop    %edi
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	56                   	push   %esi
  800dbf:	53                   	push   %ebx
  800dc0:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dc3:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800dc5:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dc9:	75 25                	jne    800df0 <pgfault+0x35>
  800dcb:	89 d8                	mov    %ebx,%eax
  800dcd:	c1 e8 0c             	shr    $0xc,%eax
  800dd0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dd7:	f6 c4 08             	test   $0x8,%ah
  800dda:	75 14                	jne    800df0 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800ddc:	83 ec 04             	sub    $0x4,%esp
  800ddf:	68 f0 16 80 00       	push   $0x8016f0
  800de4:	6a 1e                	push   $0x1e
  800de6:	68 84 17 80 00       	push   $0x801784
  800deb:	e8 8c 02 00 00       	call   80107c <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800df0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800df6:	e8 d3 fd ff ff       	call   800bce <sys_getenvid>
  800dfb:	89 c6                	mov    %eax,%esi

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800dfd:	83 ec 04             	sub    $0x4,%esp
  800e00:	6a 07                	push   $0x7
  800e02:	68 00 f0 7f 00       	push   $0x7ff000
  800e07:	50                   	push   %eax
  800e08:	e8 ff fd ff ff       	call   800c0c <sys_page_alloc>
	if (r < 0)
  800e0d:	83 c4 10             	add    $0x10,%esp
  800e10:	85 c0                	test   %eax,%eax
  800e12:	79 12                	jns    800e26 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800e14:	50                   	push   %eax
  800e15:	68 1c 17 80 00       	push   $0x80171c
  800e1a:	6a 31                	push   $0x31
  800e1c:	68 84 17 80 00       	push   $0x801784
  800e21:	e8 56 02 00 00       	call   80107c <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800e26:	83 ec 04             	sub    $0x4,%esp
  800e29:	68 00 10 00 00       	push   $0x1000
  800e2e:	53                   	push   %ebx
  800e2f:	68 00 f0 7f 00       	push   $0x7ff000
  800e34:	e8 ca fb ff ff       	call   800a03 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800e39:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e40:	53                   	push   %ebx
  800e41:	56                   	push   %esi
  800e42:	68 00 f0 7f 00       	push   $0x7ff000
  800e47:	56                   	push   %esi
  800e48:	e8 02 fe ff ff       	call   800c4f <sys_page_map>
	if (r < 0)
  800e4d:	83 c4 20             	add    $0x20,%esp
  800e50:	85 c0                	test   %eax,%eax
  800e52:	79 12                	jns    800e66 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800e54:	50                   	push   %eax
  800e55:	68 40 17 80 00       	push   $0x801740
  800e5a:	6a 39                	push   $0x39
  800e5c:	68 84 17 80 00       	push   $0x801784
  800e61:	e8 16 02 00 00       	call   80107c <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800e66:	83 ec 08             	sub    $0x8,%esp
  800e69:	68 00 f0 7f 00       	push   $0x7ff000
  800e6e:	56                   	push   %esi
  800e6f:	e8 1d fe ff ff       	call   800c91 <sys_page_unmap>
	if (r < 0)
  800e74:	83 c4 10             	add    $0x10,%esp
  800e77:	85 c0                	test   %eax,%eax
  800e79:	79 12                	jns    800e8d <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800e7b:	50                   	push   %eax
  800e7c:	68 64 17 80 00       	push   $0x801764
  800e81:	6a 3e                	push   $0x3e
  800e83:	68 84 17 80 00       	push   $0x801784
  800e88:	e8 ef 01 00 00       	call   80107c <_panic>
}
  800e8d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e90:	5b                   	pop    %ebx
  800e91:	5e                   	pop    %esi
  800e92:	5d                   	pop    %ebp
  800e93:	c3                   	ret    

00800e94 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	57                   	push   %edi
  800e98:	56                   	push   %esi
  800e99:	53                   	push   %ebx
  800e9a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800e9d:	68 bb 0d 80 00       	push   $0x800dbb
  800ea2:	e8 1b 02 00 00       	call   8010c2 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ea7:	b8 07 00 00 00       	mov    $0x7,%eax
  800eac:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800eae:	83 c4 10             	add    $0x10,%esp
  800eb1:	85 c0                	test   %eax,%eax
  800eb3:	0f 88 3a 01 00 00    	js     800ff3 <fork+0x15f>
  800eb9:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800ebe:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800ec3:	85 c0                	test   %eax,%eax
  800ec5:	75 21                	jne    800ee8 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ec7:	e8 02 fd ff ff       	call   800bce <sys_getenvid>
  800ecc:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ed1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ed4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ed9:	a3 0c 20 80 00       	mov    %eax,0x80200c
        return 0;
  800ede:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee3:	e9 0b 01 00 00       	jmp    800ff3 <fork+0x15f>
  800ee8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800eeb:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800eed:	89 d8                	mov    %ebx,%eax
  800eef:	c1 e8 16             	shr    $0x16,%eax
  800ef2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ef9:	a8 01                	test   $0x1,%al
  800efb:	0f 84 99 00 00 00    	je     800f9a <fork+0x106>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800f01:	89 d8                	mov    %ebx,%eax
  800f03:	c1 e8 0c             	shr    $0xc,%eax
  800f06:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f0d:	f6 c2 01             	test   $0x1,%dl
  800f10:	0f 84 84 00 00 00    	je     800f9a <fork+0x106>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
  800f16:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f1d:	a9 02 08 00 00       	test   $0x802,%eax
  800f22:	74 76                	je     800f9a <fork+0x106>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;
	
	if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f24:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f2b:	a8 02                	test   $0x2,%al
  800f2d:	75 0c                	jne    800f3b <fork+0xa7>
  800f2f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f36:	f6 c4 08             	test   $0x8,%ah
  800f39:	74 3f                	je     800f7a <fork+0xe6>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f3b:	83 ec 0c             	sub    $0xc,%esp
  800f3e:	68 05 08 00 00       	push   $0x805
  800f43:	53                   	push   %ebx
  800f44:	57                   	push   %edi
  800f45:	53                   	push   %ebx
  800f46:	6a 00                	push   $0x0
  800f48:	e8 02 fd ff ff       	call   800c4f <sys_page_map>
		if (r < 0)
  800f4d:	83 c4 20             	add    $0x20,%esp
  800f50:	85 c0                	test   %eax,%eax
  800f52:	0f 88 9b 00 00 00    	js     800ff3 <fork+0x15f>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f58:	83 ec 0c             	sub    $0xc,%esp
  800f5b:	68 05 08 00 00       	push   $0x805
  800f60:	53                   	push   %ebx
  800f61:	6a 00                	push   $0x0
  800f63:	53                   	push   %ebx
  800f64:	6a 00                	push   $0x0
  800f66:	e8 e4 fc ff ff       	call   800c4f <sys_page_map>
  800f6b:	83 c4 20             	add    $0x20,%esp
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f75:	0f 4f c1             	cmovg  %ecx,%eax
  800f78:	eb 1c                	jmp    800f96 <fork+0x102>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800f7a:	83 ec 0c             	sub    $0xc,%esp
  800f7d:	6a 05                	push   $0x5
  800f7f:	53                   	push   %ebx
  800f80:	57                   	push   %edi
  800f81:	53                   	push   %ebx
  800f82:	6a 00                	push   $0x0
  800f84:	e8 c6 fc ff ff       	call   800c4f <sys_page_map>
  800f89:	83 c4 20             	add    $0x20,%esp
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f93:	0f 4f c1             	cmovg  %ecx,%eax
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  800f96:	85 c0                	test   %eax,%eax
  800f98:	78 59                	js     800ff3 <fork+0x15f>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  800f9a:	83 c6 01             	add    $0x1,%esi
  800f9d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fa3:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  800fa9:	0f 85 3e ff ff ff    	jne    800eed <fork+0x59>
  800faf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  800fb2:	83 ec 04             	sub    $0x4,%esp
  800fb5:	6a 07                	push   $0x7
  800fb7:	68 00 f0 bf ee       	push   $0xeebff000
  800fbc:	57                   	push   %edi
  800fbd:	e8 4a fc ff ff       	call   800c0c <sys_page_alloc>
	if (r < 0)
  800fc2:	83 c4 10             	add    $0x10,%esp
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	78 2a                	js     800ff3 <fork+0x15f>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800fc9:	83 ec 08             	sub    $0x8,%esp
  800fcc:	68 09 11 80 00       	push   $0x801109
  800fd1:	57                   	push   %edi
  800fd2:	e8 3e fd ff ff       	call   800d15 <sys_env_set_pgfault_upcall>
	if (r < 0)
  800fd7:	83 c4 10             	add    $0x10,%esp
  800fda:	85 c0                	test   %eax,%eax
  800fdc:	78 15                	js     800ff3 <fork+0x15f>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  800fde:	83 ec 08             	sub    $0x8,%esp
  800fe1:	6a 02                	push   $0x2
  800fe3:	57                   	push   %edi
  800fe4:	e8 ea fc ff ff       	call   800cd3 <sys_env_set_status>
	if (r < 0)
  800fe9:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  800fec:	85 c0                	test   %eax,%eax
  800fee:	0f 49 c7             	cmovns %edi,%eax
  800ff1:	eb 00                	jmp    800ff3 <fork+0x15f>
	// panic("fork not implemented");
}
  800ff3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff6:	5b                   	pop    %ebx
  800ff7:	5e                   	pop    %esi
  800ff8:	5f                   	pop    %edi
  800ff9:	5d                   	pop    %ebp
  800ffa:	c3                   	ret    

00800ffb <sfork>:

// Challenge!
int
sfork(void)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801001:	68 8f 17 80 00       	push   $0x80178f
  801006:	68 c3 00 00 00       	push   $0xc3
  80100b:	68 84 17 80 00       	push   $0x801784
  801010:	e8 67 00 00 00       	call   80107c <_panic>

00801015 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
  801018:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  80101b:	68 a5 17 80 00       	push   $0x8017a5
  801020:	6a 1a                	push   $0x1a
  801022:	68 be 17 80 00       	push   $0x8017be
  801027:	e8 50 00 00 00       	call   80107c <_panic>

0080102c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  801032:	68 c8 17 80 00       	push   $0x8017c8
  801037:	6a 2a                	push   $0x2a
  801039:	68 be 17 80 00       	push   $0x8017be
  80103e:	e8 39 00 00 00       	call   80107c <_panic>

00801043 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801049:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80104e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801051:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801057:	8b 52 50             	mov    0x50(%edx),%edx
  80105a:	39 ca                	cmp    %ecx,%edx
  80105c:	75 0d                	jne    80106b <ipc_find_env+0x28>
			return envs[i].env_id;
  80105e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801061:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801066:	8b 40 48             	mov    0x48(%eax),%eax
  801069:	eb 0f                	jmp    80107a <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80106b:	83 c0 01             	add    $0x1,%eax
  80106e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801073:	75 d9                	jne    80104e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801075:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80107a:	5d                   	pop    %ebp
  80107b:	c3                   	ret    

0080107c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80107c:	55                   	push   %ebp
  80107d:	89 e5                	mov    %esp,%ebp
  80107f:	56                   	push   %esi
  801080:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801081:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801084:	8b 35 08 20 80 00    	mov    0x802008,%esi
  80108a:	e8 3f fb ff ff       	call   800bce <sys_getenvid>
  80108f:	83 ec 0c             	sub    $0xc,%esp
  801092:	ff 75 0c             	pushl  0xc(%ebp)
  801095:	ff 75 08             	pushl  0x8(%ebp)
  801098:	56                   	push   %esi
  801099:	50                   	push   %eax
  80109a:	68 e4 17 80 00       	push   $0x8017e4
  80109f:	e8 e0 f1 ff ff       	call   800284 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010a4:	83 c4 18             	add    $0x18,%esp
  8010a7:	53                   	push   %ebx
  8010a8:	ff 75 10             	pushl  0x10(%ebp)
  8010ab:	e8 83 f1 ff ff       	call   800233 <vcprintf>
	cprintf("\n");
  8010b0:	c7 04 24 d2 13 80 00 	movl   $0x8013d2,(%esp)
  8010b7:	e8 c8 f1 ff ff       	call   800284 <cprintf>
  8010bc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010bf:	cc                   	int3   
  8010c0:	eb fd                	jmp    8010bf <_panic+0x43>

008010c2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8010c2:	55                   	push   %ebp
  8010c3:	89 e5                	mov    %esp,%ebp
  8010c5:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8010c8:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  8010cf:	75 2e                	jne    8010ff <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8010d1:	e8 f8 fa ff ff       	call   800bce <sys_getenvid>
  8010d6:	83 ec 04             	sub    $0x4,%esp
  8010d9:	68 07 0e 00 00       	push   $0xe07
  8010de:	68 00 f0 bf ee       	push   $0xeebff000
  8010e3:	50                   	push   %eax
  8010e4:	e8 23 fb ff ff       	call   800c0c <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8010e9:	e8 e0 fa ff ff       	call   800bce <sys_getenvid>
  8010ee:	83 c4 08             	add    $0x8,%esp
  8010f1:	68 09 11 80 00       	push   $0x801109
  8010f6:	50                   	push   %eax
  8010f7:	e8 19 fc ff ff       	call   800d15 <sys_env_set_pgfault_upcall>
  8010fc:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8010ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801102:	a3 10 20 80 00       	mov    %eax,0x802010
}
  801107:	c9                   	leave  
  801108:	c3                   	ret    

00801109 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801109:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80110a:	a1 10 20 80 00       	mov    0x802010,%eax
	call *%eax
  80110f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801111:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  801114:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  801118:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  80111c:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  80111f:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  801122:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  801123:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  801126:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  801127:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  801128:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  80112c:	c3                   	ret    
  80112d:	66 90                	xchg   %ax,%ax
  80112f:	90                   	nop

00801130 <__udivdi3>:
  801130:	55                   	push   %ebp
  801131:	57                   	push   %edi
  801132:	56                   	push   %esi
  801133:	53                   	push   %ebx
  801134:	83 ec 1c             	sub    $0x1c,%esp
  801137:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80113b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80113f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801143:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801147:	85 f6                	test   %esi,%esi
  801149:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80114d:	89 ca                	mov    %ecx,%edx
  80114f:	89 f8                	mov    %edi,%eax
  801151:	75 3d                	jne    801190 <__udivdi3+0x60>
  801153:	39 cf                	cmp    %ecx,%edi
  801155:	0f 87 c5 00 00 00    	ja     801220 <__udivdi3+0xf0>
  80115b:	85 ff                	test   %edi,%edi
  80115d:	89 fd                	mov    %edi,%ebp
  80115f:	75 0b                	jne    80116c <__udivdi3+0x3c>
  801161:	b8 01 00 00 00       	mov    $0x1,%eax
  801166:	31 d2                	xor    %edx,%edx
  801168:	f7 f7                	div    %edi
  80116a:	89 c5                	mov    %eax,%ebp
  80116c:	89 c8                	mov    %ecx,%eax
  80116e:	31 d2                	xor    %edx,%edx
  801170:	f7 f5                	div    %ebp
  801172:	89 c1                	mov    %eax,%ecx
  801174:	89 d8                	mov    %ebx,%eax
  801176:	89 cf                	mov    %ecx,%edi
  801178:	f7 f5                	div    %ebp
  80117a:	89 c3                	mov    %eax,%ebx
  80117c:	89 d8                	mov    %ebx,%eax
  80117e:	89 fa                	mov    %edi,%edx
  801180:	83 c4 1c             	add    $0x1c,%esp
  801183:	5b                   	pop    %ebx
  801184:	5e                   	pop    %esi
  801185:	5f                   	pop    %edi
  801186:	5d                   	pop    %ebp
  801187:	c3                   	ret    
  801188:	90                   	nop
  801189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801190:	39 ce                	cmp    %ecx,%esi
  801192:	77 74                	ja     801208 <__udivdi3+0xd8>
  801194:	0f bd fe             	bsr    %esi,%edi
  801197:	83 f7 1f             	xor    $0x1f,%edi
  80119a:	0f 84 98 00 00 00    	je     801238 <__udivdi3+0x108>
  8011a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8011a5:	89 f9                	mov    %edi,%ecx
  8011a7:	89 c5                	mov    %eax,%ebp
  8011a9:	29 fb                	sub    %edi,%ebx
  8011ab:	d3 e6                	shl    %cl,%esi
  8011ad:	89 d9                	mov    %ebx,%ecx
  8011af:	d3 ed                	shr    %cl,%ebp
  8011b1:	89 f9                	mov    %edi,%ecx
  8011b3:	d3 e0                	shl    %cl,%eax
  8011b5:	09 ee                	or     %ebp,%esi
  8011b7:	89 d9                	mov    %ebx,%ecx
  8011b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011bd:	89 d5                	mov    %edx,%ebp
  8011bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8011c3:	d3 ed                	shr    %cl,%ebp
  8011c5:	89 f9                	mov    %edi,%ecx
  8011c7:	d3 e2                	shl    %cl,%edx
  8011c9:	89 d9                	mov    %ebx,%ecx
  8011cb:	d3 e8                	shr    %cl,%eax
  8011cd:	09 c2                	or     %eax,%edx
  8011cf:	89 d0                	mov    %edx,%eax
  8011d1:	89 ea                	mov    %ebp,%edx
  8011d3:	f7 f6                	div    %esi
  8011d5:	89 d5                	mov    %edx,%ebp
  8011d7:	89 c3                	mov    %eax,%ebx
  8011d9:	f7 64 24 0c          	mull   0xc(%esp)
  8011dd:	39 d5                	cmp    %edx,%ebp
  8011df:	72 10                	jb     8011f1 <__udivdi3+0xc1>
  8011e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8011e5:	89 f9                	mov    %edi,%ecx
  8011e7:	d3 e6                	shl    %cl,%esi
  8011e9:	39 c6                	cmp    %eax,%esi
  8011eb:	73 07                	jae    8011f4 <__udivdi3+0xc4>
  8011ed:	39 d5                	cmp    %edx,%ebp
  8011ef:	75 03                	jne    8011f4 <__udivdi3+0xc4>
  8011f1:	83 eb 01             	sub    $0x1,%ebx
  8011f4:	31 ff                	xor    %edi,%edi
  8011f6:	89 d8                	mov    %ebx,%eax
  8011f8:	89 fa                	mov    %edi,%edx
  8011fa:	83 c4 1c             	add    $0x1c,%esp
  8011fd:	5b                   	pop    %ebx
  8011fe:	5e                   	pop    %esi
  8011ff:	5f                   	pop    %edi
  801200:	5d                   	pop    %ebp
  801201:	c3                   	ret    
  801202:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801208:	31 ff                	xor    %edi,%edi
  80120a:	31 db                	xor    %ebx,%ebx
  80120c:	89 d8                	mov    %ebx,%eax
  80120e:	89 fa                	mov    %edi,%edx
  801210:	83 c4 1c             	add    $0x1c,%esp
  801213:	5b                   	pop    %ebx
  801214:	5e                   	pop    %esi
  801215:	5f                   	pop    %edi
  801216:	5d                   	pop    %ebp
  801217:	c3                   	ret    
  801218:	90                   	nop
  801219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801220:	89 d8                	mov    %ebx,%eax
  801222:	f7 f7                	div    %edi
  801224:	31 ff                	xor    %edi,%edi
  801226:	89 c3                	mov    %eax,%ebx
  801228:	89 d8                	mov    %ebx,%eax
  80122a:	89 fa                	mov    %edi,%edx
  80122c:	83 c4 1c             	add    $0x1c,%esp
  80122f:	5b                   	pop    %ebx
  801230:	5e                   	pop    %esi
  801231:	5f                   	pop    %edi
  801232:	5d                   	pop    %ebp
  801233:	c3                   	ret    
  801234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801238:	39 ce                	cmp    %ecx,%esi
  80123a:	72 0c                	jb     801248 <__udivdi3+0x118>
  80123c:	31 db                	xor    %ebx,%ebx
  80123e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801242:	0f 87 34 ff ff ff    	ja     80117c <__udivdi3+0x4c>
  801248:	bb 01 00 00 00       	mov    $0x1,%ebx
  80124d:	e9 2a ff ff ff       	jmp    80117c <__udivdi3+0x4c>
  801252:	66 90                	xchg   %ax,%ax
  801254:	66 90                	xchg   %ax,%ax
  801256:	66 90                	xchg   %ax,%ax
  801258:	66 90                	xchg   %ax,%ax
  80125a:	66 90                	xchg   %ax,%ax
  80125c:	66 90                	xchg   %ax,%ax
  80125e:	66 90                	xchg   %ax,%ax

00801260 <__umoddi3>:
  801260:	55                   	push   %ebp
  801261:	57                   	push   %edi
  801262:	56                   	push   %esi
  801263:	53                   	push   %ebx
  801264:	83 ec 1c             	sub    $0x1c,%esp
  801267:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80126b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80126f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801273:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801277:	85 d2                	test   %edx,%edx
  801279:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80127d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801281:	89 f3                	mov    %esi,%ebx
  801283:	89 3c 24             	mov    %edi,(%esp)
  801286:	89 74 24 04          	mov    %esi,0x4(%esp)
  80128a:	75 1c                	jne    8012a8 <__umoddi3+0x48>
  80128c:	39 f7                	cmp    %esi,%edi
  80128e:	76 50                	jbe    8012e0 <__umoddi3+0x80>
  801290:	89 c8                	mov    %ecx,%eax
  801292:	89 f2                	mov    %esi,%edx
  801294:	f7 f7                	div    %edi
  801296:	89 d0                	mov    %edx,%eax
  801298:	31 d2                	xor    %edx,%edx
  80129a:	83 c4 1c             	add    $0x1c,%esp
  80129d:	5b                   	pop    %ebx
  80129e:	5e                   	pop    %esi
  80129f:	5f                   	pop    %edi
  8012a0:	5d                   	pop    %ebp
  8012a1:	c3                   	ret    
  8012a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012a8:	39 f2                	cmp    %esi,%edx
  8012aa:	89 d0                	mov    %edx,%eax
  8012ac:	77 52                	ja     801300 <__umoddi3+0xa0>
  8012ae:	0f bd ea             	bsr    %edx,%ebp
  8012b1:	83 f5 1f             	xor    $0x1f,%ebp
  8012b4:	75 5a                	jne    801310 <__umoddi3+0xb0>
  8012b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8012ba:	0f 82 e0 00 00 00    	jb     8013a0 <__umoddi3+0x140>
  8012c0:	39 0c 24             	cmp    %ecx,(%esp)
  8012c3:	0f 86 d7 00 00 00    	jbe    8013a0 <__umoddi3+0x140>
  8012c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8012d1:	83 c4 1c             	add    $0x1c,%esp
  8012d4:	5b                   	pop    %ebx
  8012d5:	5e                   	pop    %esi
  8012d6:	5f                   	pop    %edi
  8012d7:	5d                   	pop    %ebp
  8012d8:	c3                   	ret    
  8012d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012e0:	85 ff                	test   %edi,%edi
  8012e2:	89 fd                	mov    %edi,%ebp
  8012e4:	75 0b                	jne    8012f1 <__umoddi3+0x91>
  8012e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8012eb:	31 d2                	xor    %edx,%edx
  8012ed:	f7 f7                	div    %edi
  8012ef:	89 c5                	mov    %eax,%ebp
  8012f1:	89 f0                	mov    %esi,%eax
  8012f3:	31 d2                	xor    %edx,%edx
  8012f5:	f7 f5                	div    %ebp
  8012f7:	89 c8                	mov    %ecx,%eax
  8012f9:	f7 f5                	div    %ebp
  8012fb:	89 d0                	mov    %edx,%eax
  8012fd:	eb 99                	jmp    801298 <__umoddi3+0x38>
  8012ff:	90                   	nop
  801300:	89 c8                	mov    %ecx,%eax
  801302:	89 f2                	mov    %esi,%edx
  801304:	83 c4 1c             	add    $0x1c,%esp
  801307:	5b                   	pop    %ebx
  801308:	5e                   	pop    %esi
  801309:	5f                   	pop    %edi
  80130a:	5d                   	pop    %ebp
  80130b:	c3                   	ret    
  80130c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801310:	8b 34 24             	mov    (%esp),%esi
  801313:	bf 20 00 00 00       	mov    $0x20,%edi
  801318:	89 e9                	mov    %ebp,%ecx
  80131a:	29 ef                	sub    %ebp,%edi
  80131c:	d3 e0                	shl    %cl,%eax
  80131e:	89 f9                	mov    %edi,%ecx
  801320:	89 f2                	mov    %esi,%edx
  801322:	d3 ea                	shr    %cl,%edx
  801324:	89 e9                	mov    %ebp,%ecx
  801326:	09 c2                	or     %eax,%edx
  801328:	89 d8                	mov    %ebx,%eax
  80132a:	89 14 24             	mov    %edx,(%esp)
  80132d:	89 f2                	mov    %esi,%edx
  80132f:	d3 e2                	shl    %cl,%edx
  801331:	89 f9                	mov    %edi,%ecx
  801333:	89 54 24 04          	mov    %edx,0x4(%esp)
  801337:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80133b:	d3 e8                	shr    %cl,%eax
  80133d:	89 e9                	mov    %ebp,%ecx
  80133f:	89 c6                	mov    %eax,%esi
  801341:	d3 e3                	shl    %cl,%ebx
  801343:	89 f9                	mov    %edi,%ecx
  801345:	89 d0                	mov    %edx,%eax
  801347:	d3 e8                	shr    %cl,%eax
  801349:	89 e9                	mov    %ebp,%ecx
  80134b:	09 d8                	or     %ebx,%eax
  80134d:	89 d3                	mov    %edx,%ebx
  80134f:	89 f2                	mov    %esi,%edx
  801351:	f7 34 24             	divl   (%esp)
  801354:	89 d6                	mov    %edx,%esi
  801356:	d3 e3                	shl    %cl,%ebx
  801358:	f7 64 24 04          	mull   0x4(%esp)
  80135c:	39 d6                	cmp    %edx,%esi
  80135e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801362:	89 d1                	mov    %edx,%ecx
  801364:	89 c3                	mov    %eax,%ebx
  801366:	72 08                	jb     801370 <__umoddi3+0x110>
  801368:	75 11                	jne    80137b <__umoddi3+0x11b>
  80136a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80136e:	73 0b                	jae    80137b <__umoddi3+0x11b>
  801370:	2b 44 24 04          	sub    0x4(%esp),%eax
  801374:	1b 14 24             	sbb    (%esp),%edx
  801377:	89 d1                	mov    %edx,%ecx
  801379:	89 c3                	mov    %eax,%ebx
  80137b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80137f:	29 da                	sub    %ebx,%edx
  801381:	19 ce                	sbb    %ecx,%esi
  801383:	89 f9                	mov    %edi,%ecx
  801385:	89 f0                	mov    %esi,%eax
  801387:	d3 e0                	shl    %cl,%eax
  801389:	89 e9                	mov    %ebp,%ecx
  80138b:	d3 ea                	shr    %cl,%edx
  80138d:	89 e9                	mov    %ebp,%ecx
  80138f:	d3 ee                	shr    %cl,%esi
  801391:	09 d0                	or     %edx,%eax
  801393:	89 f2                	mov    %esi,%edx
  801395:	83 c4 1c             	add    $0x1c,%esp
  801398:	5b                   	pop    %ebx
  801399:	5e                   	pop    %esi
  80139a:	5f                   	pop    %edi
  80139b:	5d                   	pop    %ebp
  80139c:	c3                   	ret    
  80139d:	8d 76 00             	lea    0x0(%esi),%esi
  8013a0:	29 f9                	sub    %edi,%ecx
  8013a2:	19 d6                	sbb    %edx,%esi
  8013a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013ac:	e9 18 ff ff ff       	jmp    8012c9 <__umoddi3+0x69>
