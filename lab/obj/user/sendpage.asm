
obj/user/sendpage.debug:     file format elf32-i386


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
  800039:	e8 a0 0e 00 00       	call   800ede <fork>
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
  800057:	e8 3c 10 00 00       	call   801098 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 00 22 80 00       	push   $0x802200
  80006c:	e8 1b 02 00 00       	call   80028c <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800071:	83 c4 04             	add    $0x4,%esp
  800074:	ff 35 04 30 80 00    	pushl  0x803004
  80007a:	e8 59 07 00 00       	call   8007d8 <strlen>
  80007f:	83 c4 0c             	add    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	ff 35 04 30 80 00    	pushl  0x803004
  800089:	68 00 00 b0 00       	push   $0xb00000
  80008e:	e8 4e 08 00 00       	call   8008e1 <strncmp>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	75 10                	jne    8000aa <umain+0x77>
			cprintf("child received correct message\n");
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	68 14 22 80 00       	push   $0x802214
  8000a2:	e8 e5 01 00 00       	call   80028c <cprintf>
  8000a7:	83 c4 10             	add    $0x10,%esp

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	ff 35 00 30 80 00    	pushl  0x803000
  8000b3:	e8 20 07 00 00       	call   8007d8 <strlen>
  8000b8:	83 c4 0c             	add    $0xc,%esp
  8000bb:	83 c0 01             	add    $0x1,%eax
  8000be:	50                   	push   %eax
  8000bf:	ff 35 00 30 80 00    	pushl  0x803000
  8000c5:	68 00 00 b0 00       	push   $0xb00000
  8000ca:	e8 3c 09 00 00       	call   800a0b <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000cf:	6a 07                	push   $0x7
  8000d1:	68 00 00 b0 00       	push   $0xb00000
  8000d6:	6a 00                	push   $0x0
  8000d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8000db:	e8 1f 10 00 00       	call   8010ff <ipc_send>
		return;
  8000e0:	83 c4 20             	add    $0x20,%esp
  8000e3:	e9 af 00 00 00       	jmp    800197 <umain+0x164>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ed:	8b 40 48             	mov    0x48(%eax),%eax
  8000f0:	83 ec 04             	sub    $0x4,%esp
  8000f3:	6a 07                	push   $0x7
  8000f5:	68 00 00 a0 00       	push   $0xa00000
  8000fa:	50                   	push   %eax
  8000fb:	e8 14 0b 00 00       	call   800c14 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800100:	83 c4 04             	add    $0x4,%esp
  800103:	ff 35 04 30 80 00    	pushl  0x803004
  800109:	e8 ca 06 00 00       	call   8007d8 <strlen>
  80010e:	83 c4 0c             	add    $0xc,%esp
  800111:	83 c0 01             	add    $0x1,%eax
  800114:	50                   	push   %eax
  800115:	ff 35 04 30 80 00    	pushl  0x803004
  80011b:	68 00 00 a0 00       	push   $0xa00000
  800120:	e8 e6 08 00 00       	call   800a0b <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800125:	6a 07                	push   $0x7
  800127:	68 00 00 a0 00       	push   $0xa00000
  80012c:	6a 00                	push   $0x0
  80012e:	ff 75 f4             	pushl  -0xc(%ebp)
  800131:	e8 c9 0f 00 00       	call   8010ff <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 4f 0f 00 00       	call   801098 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 00 22 80 00       	push   $0x802200
  800159:	e8 2e 01 00 00       	call   80028c <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015e:	83 c4 04             	add    $0x4,%esp
  800161:	ff 35 00 30 80 00    	pushl  0x803000
  800167:	e8 6c 06 00 00       	call   8007d8 <strlen>
  80016c:	83 c4 0c             	add    $0xc,%esp
  80016f:	50                   	push   %eax
  800170:	ff 35 00 30 80 00    	pushl  0x803000
  800176:	68 00 00 a0 00       	push   $0xa00000
  80017b:	e8 61 07 00 00       	call   8008e1 <strncmp>
  800180:	83 c4 10             	add    $0x10,%esp
  800183:	85 c0                	test   %eax,%eax
  800185:	75 10                	jne    800197 <umain+0x164>
		cprintf("parent received correct message\n");
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	68 34 22 80 00       	push   $0x802234
  80018f:	e8 f8 00 00 00       	call   80028c <cprintf>
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
  8001a4:	e8 2d 0a 00 00       	call   800bd6 <sys_getenvid>
  8001a9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ae:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001b1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001b6:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001bb:	85 db                	test   %ebx,%ebx
  8001bd:	7e 07                	jle    8001c6 <libmain+0x2d>
		binaryname = argv[0];
  8001bf:	8b 06                	mov    (%esi),%eax
  8001c1:	a3 08 30 80 00       	mov    %eax,0x803008

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
  8001e2:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001e5:	e8 6d 11 00 00       	call   801357 <close_all>
	sys_env_destroy(0);
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	6a 00                	push   $0x0
  8001ef:	e8 a1 09 00 00       	call   800b95 <sys_env_destroy>
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	c9                   	leave  
  8001f8:	c3                   	ret    

008001f9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f9:	55                   	push   %ebp
  8001fa:	89 e5                	mov    %esp,%ebp
  8001fc:	53                   	push   %ebx
  8001fd:	83 ec 04             	sub    $0x4,%esp
  800200:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800203:	8b 13                	mov    (%ebx),%edx
  800205:	8d 42 01             	lea    0x1(%edx),%eax
  800208:	89 03                	mov    %eax,(%ebx)
  80020a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800211:	3d ff 00 00 00       	cmp    $0xff,%eax
  800216:	75 1a                	jne    800232 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800218:	83 ec 08             	sub    $0x8,%esp
  80021b:	68 ff 00 00 00       	push   $0xff
  800220:	8d 43 08             	lea    0x8(%ebx),%eax
  800223:	50                   	push   %eax
  800224:	e8 2f 09 00 00       	call   800b58 <sys_cputs>
		b->idx = 0;
  800229:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80022f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800232:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800236:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800244:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024b:	00 00 00 
	b.cnt = 0;
  80024e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800255:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800258:	ff 75 0c             	pushl  0xc(%ebp)
  80025b:	ff 75 08             	pushl  0x8(%ebp)
  80025e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800264:	50                   	push   %eax
  800265:	68 f9 01 80 00       	push   $0x8001f9
  80026a:	e8 54 01 00 00       	call   8003c3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026f:	83 c4 08             	add    $0x8,%esp
  800272:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800278:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027e:	50                   	push   %eax
  80027f:	e8 d4 08 00 00       	call   800b58 <sys_cputs>

	return b.cnt;
}
  800284:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028a:	c9                   	leave  
  80028b:	c3                   	ret    

0080028c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800292:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800295:	50                   	push   %eax
  800296:	ff 75 08             	pushl  0x8(%ebp)
  800299:	e8 9d ff ff ff       	call   80023b <vcprintf>
	va_end(ap);

	return cnt;
}
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 1c             	sub    $0x1c,%esp
  8002a9:	89 c7                	mov    %eax,%edi
  8002ab:	89 d6                	mov    %edx,%esi
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002c4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002c7:	39 d3                	cmp    %edx,%ebx
  8002c9:	72 05                	jb     8002d0 <printnum+0x30>
  8002cb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ce:	77 45                	ja     800315 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	ff 75 18             	pushl  0x18(%ebp)
  8002d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002dc:	53                   	push   %ebx
  8002dd:	ff 75 10             	pushl  0x10(%ebp)
  8002e0:	83 ec 08             	sub    $0x8,%esp
  8002e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ef:	e8 6c 1c 00 00       	call   801f60 <__udivdi3>
  8002f4:	83 c4 18             	add    $0x18,%esp
  8002f7:	52                   	push   %edx
  8002f8:	50                   	push   %eax
  8002f9:	89 f2                	mov    %esi,%edx
  8002fb:	89 f8                	mov    %edi,%eax
  8002fd:	e8 9e ff ff ff       	call   8002a0 <printnum>
  800302:	83 c4 20             	add    $0x20,%esp
  800305:	eb 18                	jmp    80031f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	56                   	push   %esi
  80030b:	ff 75 18             	pushl  0x18(%ebp)
  80030e:	ff d7                	call   *%edi
  800310:	83 c4 10             	add    $0x10,%esp
  800313:	eb 03                	jmp    800318 <printnum+0x78>
  800315:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800318:	83 eb 01             	sub    $0x1,%ebx
  80031b:	85 db                	test   %ebx,%ebx
  80031d:	7f e8                	jg     800307 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031f:	83 ec 08             	sub    $0x8,%esp
  800322:	56                   	push   %esi
  800323:	83 ec 04             	sub    $0x4,%esp
  800326:	ff 75 e4             	pushl  -0x1c(%ebp)
  800329:	ff 75 e0             	pushl  -0x20(%ebp)
  80032c:	ff 75 dc             	pushl  -0x24(%ebp)
  80032f:	ff 75 d8             	pushl  -0x28(%ebp)
  800332:	e8 59 1d 00 00       	call   802090 <__umoddi3>
  800337:	83 c4 14             	add    $0x14,%esp
  80033a:	0f be 80 ac 22 80 00 	movsbl 0x8022ac(%eax),%eax
  800341:	50                   	push   %eax
  800342:	ff d7                	call   *%edi
}
  800344:	83 c4 10             	add    $0x10,%esp
  800347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800352:	83 fa 01             	cmp    $0x1,%edx
  800355:	7e 0e                	jle    800365 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800357:	8b 10                	mov    (%eax),%edx
  800359:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035c:	89 08                	mov    %ecx,(%eax)
  80035e:	8b 02                	mov    (%edx),%eax
  800360:	8b 52 04             	mov    0x4(%edx),%edx
  800363:	eb 22                	jmp    800387 <getuint+0x38>
	else if (lflag)
  800365:	85 d2                	test   %edx,%edx
  800367:	74 10                	je     800379 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800369:	8b 10                	mov    (%eax),%edx
  80036b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036e:	89 08                	mov    %ecx,(%eax)
  800370:	8b 02                	mov    (%edx),%eax
  800372:	ba 00 00 00 00       	mov    $0x0,%edx
  800377:	eb 0e                	jmp    800387 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800379:	8b 10                	mov    (%eax),%edx
  80037b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037e:	89 08                	mov    %ecx,(%eax)
  800380:	8b 02                	mov    (%edx),%eax
  800382:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800387:	5d                   	pop    %ebp
  800388:	c3                   	ret    

00800389 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80038f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800393:	8b 10                	mov    (%eax),%edx
  800395:	3b 50 04             	cmp    0x4(%eax),%edx
  800398:	73 0a                	jae    8003a4 <sprintputch+0x1b>
		*b->buf++ = ch;
  80039a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80039d:	89 08                	mov    %ecx,(%eax)
  80039f:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a2:	88 02                	mov    %al,(%edx)
}
  8003a4:	5d                   	pop    %ebp
  8003a5:	c3                   	ret    

008003a6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003af:	50                   	push   %eax
  8003b0:	ff 75 10             	pushl  0x10(%ebp)
  8003b3:	ff 75 0c             	pushl  0xc(%ebp)
  8003b6:	ff 75 08             	pushl  0x8(%ebp)
  8003b9:	e8 05 00 00 00       	call   8003c3 <vprintfmt>
	va_end(ap);
}
  8003be:	83 c4 10             	add    $0x10,%esp
  8003c1:	c9                   	leave  
  8003c2:	c3                   	ret    

008003c3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	57                   	push   %edi
  8003c7:	56                   	push   %esi
  8003c8:	53                   	push   %ebx
  8003c9:	83 ec 2c             	sub    $0x2c,%esp
  8003cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8003cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003d5:	eb 12                	jmp    8003e9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d7:	85 c0                	test   %eax,%eax
  8003d9:	0f 84 89 03 00 00    	je     800768 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003df:	83 ec 08             	sub    $0x8,%esp
  8003e2:	53                   	push   %ebx
  8003e3:	50                   	push   %eax
  8003e4:	ff d6                	call   *%esi
  8003e6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e9:	83 c7 01             	add    $0x1,%edi
  8003ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003f0:	83 f8 25             	cmp    $0x25,%eax
  8003f3:	75 e2                	jne    8003d7 <vprintfmt+0x14>
  8003f5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003f9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800400:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800407:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80040e:	ba 00 00 00 00       	mov    $0x0,%edx
  800413:	eb 07                	jmp    80041c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800418:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	8d 47 01             	lea    0x1(%edi),%eax
  80041f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800422:	0f b6 07             	movzbl (%edi),%eax
  800425:	0f b6 c8             	movzbl %al,%ecx
  800428:	83 e8 23             	sub    $0x23,%eax
  80042b:	3c 55                	cmp    $0x55,%al
  80042d:	0f 87 1a 03 00 00    	ja     80074d <vprintfmt+0x38a>
  800433:	0f b6 c0             	movzbl %al,%eax
  800436:	ff 24 85 e0 23 80 00 	jmp    *0x8023e0(,%eax,4)
  80043d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800440:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800444:	eb d6                	jmp    80041c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800446:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800449:	b8 00 00 00 00       	mov    $0x0,%eax
  80044e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800451:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800454:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800458:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80045b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80045e:	83 fa 09             	cmp    $0x9,%edx
  800461:	77 39                	ja     80049c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800463:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800466:	eb e9                	jmp    800451 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800468:	8b 45 14             	mov    0x14(%ebp),%eax
  80046b:	8d 48 04             	lea    0x4(%eax),%ecx
  80046e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800471:	8b 00                	mov    (%eax),%eax
  800473:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800476:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800479:	eb 27                	jmp    8004a2 <vprintfmt+0xdf>
  80047b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80047e:	85 c0                	test   %eax,%eax
  800480:	b9 00 00 00 00       	mov    $0x0,%ecx
  800485:	0f 49 c8             	cmovns %eax,%ecx
  800488:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80048e:	eb 8c                	jmp    80041c <vprintfmt+0x59>
  800490:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800493:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80049a:	eb 80                	jmp    80041c <vprintfmt+0x59>
  80049c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80049f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004a2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a6:	0f 89 70 ff ff ff    	jns    80041c <vprintfmt+0x59>
				width = precision, precision = -1;
  8004ac:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004b9:	e9 5e ff ff ff       	jmp    80041c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004be:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004c4:	e9 53 ff ff ff       	jmp    80041c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cc:	8d 50 04             	lea    0x4(%eax),%edx
  8004cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d2:	83 ec 08             	sub    $0x8,%esp
  8004d5:	53                   	push   %ebx
  8004d6:	ff 30                	pushl  (%eax)
  8004d8:	ff d6                	call   *%esi
			break;
  8004da:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004e0:	e9 04 ff ff ff       	jmp    8003e9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e8:	8d 50 04             	lea    0x4(%eax),%edx
  8004eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ee:	8b 00                	mov    (%eax),%eax
  8004f0:	99                   	cltd   
  8004f1:	31 d0                	xor    %edx,%eax
  8004f3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f5:	83 f8 0f             	cmp    $0xf,%eax
  8004f8:	7f 0b                	jg     800505 <vprintfmt+0x142>
  8004fa:	8b 14 85 40 25 80 00 	mov    0x802540(,%eax,4),%edx
  800501:	85 d2                	test   %edx,%edx
  800503:	75 18                	jne    80051d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800505:	50                   	push   %eax
  800506:	68 c4 22 80 00       	push   $0x8022c4
  80050b:	53                   	push   %ebx
  80050c:	56                   	push   %esi
  80050d:	e8 94 fe ff ff       	call   8003a6 <printfmt>
  800512:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800515:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800518:	e9 cc fe ff ff       	jmp    8003e9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80051d:	52                   	push   %edx
  80051e:	68 3d 27 80 00       	push   $0x80273d
  800523:	53                   	push   %ebx
  800524:	56                   	push   %esi
  800525:	e8 7c fe ff ff       	call   8003a6 <printfmt>
  80052a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800530:	e9 b4 fe ff ff       	jmp    8003e9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800535:	8b 45 14             	mov    0x14(%ebp),%eax
  800538:	8d 50 04             	lea    0x4(%eax),%edx
  80053b:	89 55 14             	mov    %edx,0x14(%ebp)
  80053e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800540:	85 ff                	test   %edi,%edi
  800542:	b8 bd 22 80 00       	mov    $0x8022bd,%eax
  800547:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80054a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80054e:	0f 8e 94 00 00 00    	jle    8005e8 <vprintfmt+0x225>
  800554:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800558:	0f 84 98 00 00 00    	je     8005f6 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	ff 75 d0             	pushl  -0x30(%ebp)
  800564:	57                   	push   %edi
  800565:	e8 86 02 00 00       	call   8007f0 <strnlen>
  80056a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80056d:	29 c1                	sub    %eax,%ecx
  80056f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800572:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800575:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800579:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80057c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80057f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800581:	eb 0f                	jmp    800592 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800583:	83 ec 08             	sub    $0x8,%esp
  800586:	53                   	push   %ebx
  800587:	ff 75 e0             	pushl  -0x20(%ebp)
  80058a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058c:	83 ef 01             	sub    $0x1,%edi
  80058f:	83 c4 10             	add    $0x10,%esp
  800592:	85 ff                	test   %edi,%edi
  800594:	7f ed                	jg     800583 <vprintfmt+0x1c0>
  800596:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800599:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80059c:	85 c9                	test   %ecx,%ecx
  80059e:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a3:	0f 49 c1             	cmovns %ecx,%eax
  8005a6:	29 c1                	sub    %eax,%ecx
  8005a8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ab:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ae:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b1:	89 cb                	mov    %ecx,%ebx
  8005b3:	eb 4d                	jmp    800602 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005b9:	74 1b                	je     8005d6 <vprintfmt+0x213>
  8005bb:	0f be c0             	movsbl %al,%eax
  8005be:	83 e8 20             	sub    $0x20,%eax
  8005c1:	83 f8 5e             	cmp    $0x5e,%eax
  8005c4:	76 10                	jbe    8005d6 <vprintfmt+0x213>
					putch('?', putdat);
  8005c6:	83 ec 08             	sub    $0x8,%esp
  8005c9:	ff 75 0c             	pushl  0xc(%ebp)
  8005cc:	6a 3f                	push   $0x3f
  8005ce:	ff 55 08             	call   *0x8(%ebp)
  8005d1:	83 c4 10             	add    $0x10,%esp
  8005d4:	eb 0d                	jmp    8005e3 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005d6:	83 ec 08             	sub    $0x8,%esp
  8005d9:	ff 75 0c             	pushl  0xc(%ebp)
  8005dc:	52                   	push   %edx
  8005dd:	ff 55 08             	call   *0x8(%ebp)
  8005e0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e3:	83 eb 01             	sub    $0x1,%ebx
  8005e6:	eb 1a                	jmp    800602 <vprintfmt+0x23f>
  8005e8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005eb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005f4:	eb 0c                	jmp    800602 <vprintfmt+0x23f>
  8005f6:	89 75 08             	mov    %esi,0x8(%ebp)
  8005f9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005fc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ff:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800602:	83 c7 01             	add    $0x1,%edi
  800605:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800609:	0f be d0             	movsbl %al,%edx
  80060c:	85 d2                	test   %edx,%edx
  80060e:	74 23                	je     800633 <vprintfmt+0x270>
  800610:	85 f6                	test   %esi,%esi
  800612:	78 a1                	js     8005b5 <vprintfmt+0x1f2>
  800614:	83 ee 01             	sub    $0x1,%esi
  800617:	79 9c                	jns    8005b5 <vprintfmt+0x1f2>
  800619:	89 df                	mov    %ebx,%edi
  80061b:	8b 75 08             	mov    0x8(%ebp),%esi
  80061e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800621:	eb 18                	jmp    80063b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800623:	83 ec 08             	sub    $0x8,%esp
  800626:	53                   	push   %ebx
  800627:	6a 20                	push   $0x20
  800629:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80062b:	83 ef 01             	sub    $0x1,%edi
  80062e:	83 c4 10             	add    $0x10,%esp
  800631:	eb 08                	jmp    80063b <vprintfmt+0x278>
  800633:	89 df                	mov    %ebx,%edi
  800635:	8b 75 08             	mov    0x8(%ebp),%esi
  800638:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80063b:	85 ff                	test   %edi,%edi
  80063d:	7f e4                	jg     800623 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800642:	e9 a2 fd ff ff       	jmp    8003e9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800647:	83 fa 01             	cmp    $0x1,%edx
  80064a:	7e 16                	jle    800662 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8d 50 08             	lea    0x8(%eax),%edx
  800652:	89 55 14             	mov    %edx,0x14(%ebp)
  800655:	8b 50 04             	mov    0x4(%eax),%edx
  800658:	8b 00                	mov    (%eax),%eax
  80065a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800660:	eb 32                	jmp    800694 <vprintfmt+0x2d1>
	else if (lflag)
  800662:	85 d2                	test   %edx,%edx
  800664:	74 18                	je     80067e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8d 50 04             	lea    0x4(%eax),%edx
  80066c:	89 55 14             	mov    %edx,0x14(%ebp)
  80066f:	8b 00                	mov    (%eax),%eax
  800671:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800674:	89 c1                	mov    %eax,%ecx
  800676:	c1 f9 1f             	sar    $0x1f,%ecx
  800679:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80067c:	eb 16                	jmp    800694 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8d 50 04             	lea    0x4(%eax),%edx
  800684:	89 55 14             	mov    %edx,0x14(%ebp)
  800687:	8b 00                	mov    (%eax),%eax
  800689:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068c:	89 c1                	mov    %eax,%ecx
  80068e:	c1 f9 1f             	sar    $0x1f,%ecx
  800691:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800694:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800697:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80069a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80069f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006a3:	79 74                	jns    800719 <vprintfmt+0x356>
				putch('-', putdat);
  8006a5:	83 ec 08             	sub    $0x8,%esp
  8006a8:	53                   	push   %ebx
  8006a9:	6a 2d                	push   $0x2d
  8006ab:	ff d6                	call   *%esi
				num = -(long long) num;
  8006ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006b0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006b3:	f7 d8                	neg    %eax
  8006b5:	83 d2 00             	adc    $0x0,%edx
  8006b8:	f7 da                	neg    %edx
  8006ba:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006bd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006c2:	eb 55                	jmp    800719 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006c4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c7:	e8 83 fc ff ff       	call   80034f <getuint>
			base = 10;
  8006cc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006d1:	eb 46                	jmp    800719 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8006d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d6:	e8 74 fc ff ff       	call   80034f <getuint>
			base = 8;
  8006db:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006e0:	eb 37                	jmp    800719 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	6a 30                	push   $0x30
  8006e8:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ea:	83 c4 08             	add    $0x8,%esp
  8006ed:	53                   	push   %ebx
  8006ee:	6a 78                	push   $0x78
  8006f0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8d 50 04             	lea    0x4(%eax),%edx
  8006f8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006fb:	8b 00                	mov    (%eax),%eax
  8006fd:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800702:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800705:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80070a:	eb 0d                	jmp    800719 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80070c:	8d 45 14             	lea    0x14(%ebp),%eax
  80070f:	e8 3b fc ff ff       	call   80034f <getuint>
			base = 16;
  800714:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800719:	83 ec 0c             	sub    $0xc,%esp
  80071c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800720:	57                   	push   %edi
  800721:	ff 75 e0             	pushl  -0x20(%ebp)
  800724:	51                   	push   %ecx
  800725:	52                   	push   %edx
  800726:	50                   	push   %eax
  800727:	89 da                	mov    %ebx,%edx
  800729:	89 f0                	mov    %esi,%eax
  80072b:	e8 70 fb ff ff       	call   8002a0 <printnum>
			break;
  800730:	83 c4 20             	add    $0x20,%esp
  800733:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800736:	e9 ae fc ff ff       	jmp    8003e9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80073b:	83 ec 08             	sub    $0x8,%esp
  80073e:	53                   	push   %ebx
  80073f:	51                   	push   %ecx
  800740:	ff d6                	call   *%esi
			break;
  800742:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800745:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800748:	e9 9c fc ff ff       	jmp    8003e9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80074d:	83 ec 08             	sub    $0x8,%esp
  800750:	53                   	push   %ebx
  800751:	6a 25                	push   $0x25
  800753:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800755:	83 c4 10             	add    $0x10,%esp
  800758:	eb 03                	jmp    80075d <vprintfmt+0x39a>
  80075a:	83 ef 01             	sub    $0x1,%edi
  80075d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800761:	75 f7                	jne    80075a <vprintfmt+0x397>
  800763:	e9 81 fc ff ff       	jmp    8003e9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800768:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076b:	5b                   	pop    %ebx
  80076c:	5e                   	pop    %esi
  80076d:	5f                   	pop    %edi
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	83 ec 18             	sub    $0x18,%esp
  800776:	8b 45 08             	mov    0x8(%ebp),%eax
  800779:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80077f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800783:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800786:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80078d:	85 c0                	test   %eax,%eax
  80078f:	74 26                	je     8007b7 <vsnprintf+0x47>
  800791:	85 d2                	test   %edx,%edx
  800793:	7e 22                	jle    8007b7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800795:	ff 75 14             	pushl  0x14(%ebp)
  800798:	ff 75 10             	pushl  0x10(%ebp)
  80079b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80079e:	50                   	push   %eax
  80079f:	68 89 03 80 00       	push   $0x800389
  8007a4:	e8 1a fc ff ff       	call   8003c3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ac:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b2:	83 c4 10             	add    $0x10,%esp
  8007b5:	eb 05                	jmp    8007bc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007bc:	c9                   	leave  
  8007bd:	c3                   	ret    

008007be <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c7:	50                   	push   %eax
  8007c8:	ff 75 10             	pushl  0x10(%ebp)
  8007cb:	ff 75 0c             	pushl  0xc(%ebp)
  8007ce:	ff 75 08             	pushl  0x8(%ebp)
  8007d1:	e8 9a ff ff ff       	call   800770 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    

008007d8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007de:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e3:	eb 03                	jmp    8007e8 <strlen+0x10>
		n++;
  8007e5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ec:	75 f7                	jne    8007e5 <strlen+0xd>
		n++;
	return n;
}
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007fe:	eb 03                	jmp    800803 <strnlen+0x13>
		n++;
  800800:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800803:	39 c2                	cmp    %eax,%edx
  800805:	74 08                	je     80080f <strnlen+0x1f>
  800807:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80080b:	75 f3                	jne    800800 <strnlen+0x10>
  80080d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80080f:	5d                   	pop    %ebp
  800810:	c3                   	ret    

00800811 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	53                   	push   %ebx
  800815:	8b 45 08             	mov    0x8(%ebp),%eax
  800818:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80081b:	89 c2                	mov    %eax,%edx
  80081d:	83 c2 01             	add    $0x1,%edx
  800820:	83 c1 01             	add    $0x1,%ecx
  800823:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800827:	88 5a ff             	mov    %bl,-0x1(%edx)
  80082a:	84 db                	test   %bl,%bl
  80082c:	75 ef                	jne    80081d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80082e:	5b                   	pop    %ebx
  80082f:	5d                   	pop    %ebp
  800830:	c3                   	ret    

00800831 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	53                   	push   %ebx
  800835:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800838:	53                   	push   %ebx
  800839:	e8 9a ff ff ff       	call   8007d8 <strlen>
  80083e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800841:	ff 75 0c             	pushl  0xc(%ebp)
  800844:	01 d8                	add    %ebx,%eax
  800846:	50                   	push   %eax
  800847:	e8 c5 ff ff ff       	call   800811 <strcpy>
	return dst;
}
  80084c:	89 d8                	mov    %ebx,%eax
  80084e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800851:	c9                   	leave  
  800852:	c3                   	ret    

00800853 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	56                   	push   %esi
  800857:	53                   	push   %ebx
  800858:	8b 75 08             	mov    0x8(%ebp),%esi
  80085b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085e:	89 f3                	mov    %esi,%ebx
  800860:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800863:	89 f2                	mov    %esi,%edx
  800865:	eb 0f                	jmp    800876 <strncpy+0x23>
		*dst++ = *src;
  800867:	83 c2 01             	add    $0x1,%edx
  80086a:	0f b6 01             	movzbl (%ecx),%eax
  80086d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800870:	80 39 01             	cmpb   $0x1,(%ecx)
  800873:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800876:	39 da                	cmp    %ebx,%edx
  800878:	75 ed                	jne    800867 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80087a:	89 f0                	mov    %esi,%eax
  80087c:	5b                   	pop    %ebx
  80087d:	5e                   	pop    %esi
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	56                   	push   %esi
  800884:	53                   	push   %ebx
  800885:	8b 75 08             	mov    0x8(%ebp),%esi
  800888:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088b:	8b 55 10             	mov    0x10(%ebp),%edx
  80088e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800890:	85 d2                	test   %edx,%edx
  800892:	74 21                	je     8008b5 <strlcpy+0x35>
  800894:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800898:	89 f2                	mov    %esi,%edx
  80089a:	eb 09                	jmp    8008a5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089c:	83 c2 01             	add    $0x1,%edx
  80089f:	83 c1 01             	add    $0x1,%ecx
  8008a2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a5:	39 c2                	cmp    %eax,%edx
  8008a7:	74 09                	je     8008b2 <strlcpy+0x32>
  8008a9:	0f b6 19             	movzbl (%ecx),%ebx
  8008ac:	84 db                	test   %bl,%bl
  8008ae:	75 ec                	jne    80089c <strlcpy+0x1c>
  8008b0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008b2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b5:	29 f0                	sub    %esi,%eax
}
  8008b7:	5b                   	pop    %ebx
  8008b8:	5e                   	pop    %esi
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c4:	eb 06                	jmp    8008cc <strcmp+0x11>
		p++, q++;
  8008c6:	83 c1 01             	add    $0x1,%ecx
  8008c9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008cc:	0f b6 01             	movzbl (%ecx),%eax
  8008cf:	84 c0                	test   %al,%al
  8008d1:	74 04                	je     8008d7 <strcmp+0x1c>
  8008d3:	3a 02                	cmp    (%edx),%al
  8008d5:	74 ef                	je     8008c6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d7:	0f b6 c0             	movzbl %al,%eax
  8008da:	0f b6 12             	movzbl (%edx),%edx
  8008dd:	29 d0                	sub    %edx,%eax
}
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	53                   	push   %ebx
  8008e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008eb:	89 c3                	mov    %eax,%ebx
  8008ed:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f0:	eb 06                	jmp    8008f8 <strncmp+0x17>
		n--, p++, q++;
  8008f2:	83 c0 01             	add    $0x1,%eax
  8008f5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f8:	39 d8                	cmp    %ebx,%eax
  8008fa:	74 15                	je     800911 <strncmp+0x30>
  8008fc:	0f b6 08             	movzbl (%eax),%ecx
  8008ff:	84 c9                	test   %cl,%cl
  800901:	74 04                	je     800907 <strncmp+0x26>
  800903:	3a 0a                	cmp    (%edx),%cl
  800905:	74 eb                	je     8008f2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800907:	0f b6 00             	movzbl (%eax),%eax
  80090a:	0f b6 12             	movzbl (%edx),%edx
  80090d:	29 d0                	sub    %edx,%eax
  80090f:	eb 05                	jmp    800916 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800911:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800916:	5b                   	pop    %ebx
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800923:	eb 07                	jmp    80092c <strchr+0x13>
		if (*s == c)
  800925:	38 ca                	cmp    %cl,%dl
  800927:	74 0f                	je     800938 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800929:	83 c0 01             	add    $0x1,%eax
  80092c:	0f b6 10             	movzbl (%eax),%edx
  80092f:	84 d2                	test   %dl,%dl
  800931:	75 f2                	jne    800925 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800933:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
  800940:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800944:	eb 03                	jmp    800949 <strfind+0xf>
  800946:	83 c0 01             	add    $0x1,%eax
  800949:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80094c:	38 ca                	cmp    %cl,%dl
  80094e:	74 04                	je     800954 <strfind+0x1a>
  800950:	84 d2                	test   %dl,%dl
  800952:	75 f2                	jne    800946 <strfind+0xc>
			break;
	return (char *) s;
}
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	57                   	push   %edi
  80095a:	56                   	push   %esi
  80095b:	53                   	push   %ebx
  80095c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800962:	85 c9                	test   %ecx,%ecx
  800964:	74 36                	je     80099c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800966:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096c:	75 28                	jne    800996 <memset+0x40>
  80096e:	f6 c1 03             	test   $0x3,%cl
  800971:	75 23                	jne    800996 <memset+0x40>
		c &= 0xFF;
  800973:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800977:	89 d3                	mov    %edx,%ebx
  800979:	c1 e3 08             	shl    $0x8,%ebx
  80097c:	89 d6                	mov    %edx,%esi
  80097e:	c1 e6 18             	shl    $0x18,%esi
  800981:	89 d0                	mov    %edx,%eax
  800983:	c1 e0 10             	shl    $0x10,%eax
  800986:	09 f0                	or     %esi,%eax
  800988:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80098a:	89 d8                	mov    %ebx,%eax
  80098c:	09 d0                	or     %edx,%eax
  80098e:	c1 e9 02             	shr    $0x2,%ecx
  800991:	fc                   	cld    
  800992:	f3 ab                	rep stos %eax,%es:(%edi)
  800994:	eb 06                	jmp    80099c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800996:	8b 45 0c             	mov    0xc(%ebp),%eax
  800999:	fc                   	cld    
  80099a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80099c:	89 f8                	mov    %edi,%eax
  80099e:	5b                   	pop    %ebx
  80099f:	5e                   	pop    %esi
  8009a0:	5f                   	pop    %edi
  8009a1:	5d                   	pop    %ebp
  8009a2:	c3                   	ret    

008009a3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	57                   	push   %edi
  8009a7:	56                   	push   %esi
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b1:	39 c6                	cmp    %eax,%esi
  8009b3:	73 35                	jae    8009ea <memmove+0x47>
  8009b5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b8:	39 d0                	cmp    %edx,%eax
  8009ba:	73 2e                	jae    8009ea <memmove+0x47>
		s += n;
		d += n;
  8009bc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bf:	89 d6                	mov    %edx,%esi
  8009c1:	09 fe                	or     %edi,%esi
  8009c3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c9:	75 13                	jne    8009de <memmove+0x3b>
  8009cb:	f6 c1 03             	test   $0x3,%cl
  8009ce:	75 0e                	jne    8009de <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009d0:	83 ef 04             	sub    $0x4,%edi
  8009d3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d6:	c1 e9 02             	shr    $0x2,%ecx
  8009d9:	fd                   	std    
  8009da:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009dc:	eb 09                	jmp    8009e7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009de:	83 ef 01             	sub    $0x1,%edi
  8009e1:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009e4:	fd                   	std    
  8009e5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e7:	fc                   	cld    
  8009e8:	eb 1d                	jmp    800a07 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ea:	89 f2                	mov    %esi,%edx
  8009ec:	09 c2                	or     %eax,%edx
  8009ee:	f6 c2 03             	test   $0x3,%dl
  8009f1:	75 0f                	jne    800a02 <memmove+0x5f>
  8009f3:	f6 c1 03             	test   $0x3,%cl
  8009f6:	75 0a                	jne    800a02 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009f8:	c1 e9 02             	shr    $0x2,%ecx
  8009fb:	89 c7                	mov    %eax,%edi
  8009fd:	fc                   	cld    
  8009fe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a00:	eb 05                	jmp    800a07 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a02:	89 c7                	mov    %eax,%edi
  800a04:	fc                   	cld    
  800a05:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a07:	5e                   	pop    %esi
  800a08:	5f                   	pop    %edi
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a0e:	ff 75 10             	pushl  0x10(%ebp)
  800a11:	ff 75 0c             	pushl  0xc(%ebp)
  800a14:	ff 75 08             	pushl  0x8(%ebp)
  800a17:	e8 87 ff ff ff       	call   8009a3 <memmove>
}
  800a1c:	c9                   	leave  
  800a1d:	c3                   	ret    

00800a1e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	56                   	push   %esi
  800a22:	53                   	push   %ebx
  800a23:	8b 45 08             	mov    0x8(%ebp),%eax
  800a26:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a29:	89 c6                	mov    %eax,%esi
  800a2b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2e:	eb 1a                	jmp    800a4a <memcmp+0x2c>
		if (*s1 != *s2)
  800a30:	0f b6 08             	movzbl (%eax),%ecx
  800a33:	0f b6 1a             	movzbl (%edx),%ebx
  800a36:	38 d9                	cmp    %bl,%cl
  800a38:	74 0a                	je     800a44 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a3a:	0f b6 c1             	movzbl %cl,%eax
  800a3d:	0f b6 db             	movzbl %bl,%ebx
  800a40:	29 d8                	sub    %ebx,%eax
  800a42:	eb 0f                	jmp    800a53 <memcmp+0x35>
		s1++, s2++;
  800a44:	83 c0 01             	add    $0x1,%eax
  800a47:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4a:	39 f0                	cmp    %esi,%eax
  800a4c:	75 e2                	jne    800a30 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a53:	5b                   	pop    %ebx
  800a54:	5e                   	pop    %esi
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    

00800a57 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	53                   	push   %ebx
  800a5b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a5e:	89 c1                	mov    %eax,%ecx
  800a60:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a63:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a67:	eb 0a                	jmp    800a73 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a69:	0f b6 10             	movzbl (%eax),%edx
  800a6c:	39 da                	cmp    %ebx,%edx
  800a6e:	74 07                	je     800a77 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a70:	83 c0 01             	add    $0x1,%eax
  800a73:	39 c8                	cmp    %ecx,%eax
  800a75:	72 f2                	jb     800a69 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a77:	5b                   	pop    %ebx
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	57                   	push   %edi
  800a7e:	56                   	push   %esi
  800a7f:	53                   	push   %ebx
  800a80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a83:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a86:	eb 03                	jmp    800a8b <strtol+0x11>
		s++;
  800a88:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8b:	0f b6 01             	movzbl (%ecx),%eax
  800a8e:	3c 20                	cmp    $0x20,%al
  800a90:	74 f6                	je     800a88 <strtol+0xe>
  800a92:	3c 09                	cmp    $0x9,%al
  800a94:	74 f2                	je     800a88 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a96:	3c 2b                	cmp    $0x2b,%al
  800a98:	75 0a                	jne    800aa4 <strtol+0x2a>
		s++;
  800a9a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9d:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa2:	eb 11                	jmp    800ab5 <strtol+0x3b>
  800aa4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aa9:	3c 2d                	cmp    $0x2d,%al
  800aab:	75 08                	jne    800ab5 <strtol+0x3b>
		s++, neg = 1;
  800aad:	83 c1 01             	add    $0x1,%ecx
  800ab0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800abb:	75 15                	jne    800ad2 <strtol+0x58>
  800abd:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac0:	75 10                	jne    800ad2 <strtol+0x58>
  800ac2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ac6:	75 7c                	jne    800b44 <strtol+0xca>
		s += 2, base = 16;
  800ac8:	83 c1 02             	add    $0x2,%ecx
  800acb:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad0:	eb 16                	jmp    800ae8 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ad2:	85 db                	test   %ebx,%ebx
  800ad4:	75 12                	jne    800ae8 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ad6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800adb:	80 39 30             	cmpb   $0x30,(%ecx)
  800ade:	75 08                	jne    800ae8 <strtol+0x6e>
		s++, base = 8;
  800ae0:	83 c1 01             	add    $0x1,%ecx
  800ae3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ae8:	b8 00 00 00 00       	mov    $0x0,%eax
  800aed:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af0:	0f b6 11             	movzbl (%ecx),%edx
  800af3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800af6:	89 f3                	mov    %esi,%ebx
  800af8:	80 fb 09             	cmp    $0x9,%bl
  800afb:	77 08                	ja     800b05 <strtol+0x8b>
			dig = *s - '0';
  800afd:	0f be d2             	movsbl %dl,%edx
  800b00:	83 ea 30             	sub    $0x30,%edx
  800b03:	eb 22                	jmp    800b27 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b05:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b08:	89 f3                	mov    %esi,%ebx
  800b0a:	80 fb 19             	cmp    $0x19,%bl
  800b0d:	77 08                	ja     800b17 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b0f:	0f be d2             	movsbl %dl,%edx
  800b12:	83 ea 57             	sub    $0x57,%edx
  800b15:	eb 10                	jmp    800b27 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b17:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b1a:	89 f3                	mov    %esi,%ebx
  800b1c:	80 fb 19             	cmp    $0x19,%bl
  800b1f:	77 16                	ja     800b37 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b21:	0f be d2             	movsbl %dl,%edx
  800b24:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b27:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b2a:	7d 0b                	jge    800b37 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b2c:	83 c1 01             	add    $0x1,%ecx
  800b2f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b33:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b35:	eb b9                	jmp    800af0 <strtol+0x76>

	if (endptr)
  800b37:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b3b:	74 0d                	je     800b4a <strtol+0xd0>
		*endptr = (char *) s;
  800b3d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b40:	89 0e                	mov    %ecx,(%esi)
  800b42:	eb 06                	jmp    800b4a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b44:	85 db                	test   %ebx,%ebx
  800b46:	74 98                	je     800ae0 <strtol+0x66>
  800b48:	eb 9e                	jmp    800ae8 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b4a:	89 c2                	mov    %eax,%edx
  800b4c:	f7 da                	neg    %edx
  800b4e:	85 ff                	test   %edi,%edi
  800b50:	0f 45 c2             	cmovne %edx,%eax
}
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5f                   	pop    %edi
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b66:	8b 55 08             	mov    0x8(%ebp),%edx
  800b69:	89 c3                	mov    %eax,%ebx
  800b6b:	89 c7                	mov    %eax,%edi
  800b6d:	89 c6                	mov    %eax,%esi
  800b6f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b81:	b8 01 00 00 00       	mov    $0x1,%eax
  800b86:	89 d1                	mov    %edx,%ecx
  800b88:	89 d3                	mov    %edx,%ebx
  800b8a:	89 d7                	mov    %edx,%edi
  800b8c:	89 d6                	mov    %edx,%esi
  800b8e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b90:	5b                   	pop    %ebx
  800b91:	5e                   	pop    %esi
  800b92:	5f                   	pop    %edi
  800b93:	5d                   	pop    %ebp
  800b94:	c3                   	ret    

00800b95 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	57                   	push   %edi
  800b99:	56                   	push   %esi
  800b9a:	53                   	push   %ebx
  800b9b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bab:	89 cb                	mov    %ecx,%ebx
  800bad:	89 cf                	mov    %ecx,%edi
  800baf:	89 ce                	mov    %ecx,%esi
  800bb1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb3:	85 c0                	test   %eax,%eax
  800bb5:	7e 17                	jle    800bce <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb7:	83 ec 0c             	sub    $0xc,%esp
  800bba:	50                   	push   %eax
  800bbb:	6a 03                	push   $0x3
  800bbd:	68 9f 25 80 00       	push   $0x80259f
  800bc2:	6a 23                	push   $0x23
  800bc4:	68 bc 25 80 00       	push   $0x8025bc
  800bc9:	e8 9b 12 00 00       	call   801e69 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800be1:	b8 02 00 00 00       	mov    $0x2,%eax
  800be6:	89 d1                	mov    %edx,%ecx
  800be8:	89 d3                	mov    %edx,%ebx
  800bea:	89 d7                	mov    %edx,%edi
  800bec:	89 d6                	mov    %edx,%esi
  800bee:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_yield>:

void
sys_yield(void)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800c00:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c05:	89 d1                	mov    %edx,%ecx
  800c07:	89 d3                	mov    %edx,%ebx
  800c09:	89 d7                	mov    %edx,%edi
  800c0b:	89 d6                	mov    %edx,%esi
  800c0d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
  800c1a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1d:	be 00 00 00 00       	mov    $0x0,%esi
  800c22:	b8 04 00 00 00       	mov    $0x4,%eax
  800c27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c30:	89 f7                	mov    %esi,%edi
  800c32:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c34:	85 c0                	test   %eax,%eax
  800c36:	7e 17                	jle    800c4f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c38:	83 ec 0c             	sub    $0xc,%esp
  800c3b:	50                   	push   %eax
  800c3c:	6a 04                	push   $0x4
  800c3e:	68 9f 25 80 00       	push   $0x80259f
  800c43:	6a 23                	push   $0x23
  800c45:	68 bc 25 80 00       	push   $0x8025bc
  800c4a:	e8 1a 12 00 00       	call   801e69 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c60:	b8 05 00 00 00       	mov    $0x5,%eax
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c71:	8b 75 18             	mov    0x18(%ebp),%esi
  800c74:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c76:	85 c0                	test   %eax,%eax
  800c78:	7e 17                	jle    800c91 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7a:	83 ec 0c             	sub    $0xc,%esp
  800c7d:	50                   	push   %eax
  800c7e:	6a 05                	push   $0x5
  800c80:	68 9f 25 80 00       	push   $0x80259f
  800c85:	6a 23                	push   $0x23
  800c87:	68 bc 25 80 00       	push   $0x8025bc
  800c8c:	e8 d8 11 00 00       	call   801e69 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
  800c9f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca7:	b8 06 00 00 00       	mov    $0x6,%eax
  800cac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb2:	89 df                	mov    %ebx,%edi
  800cb4:	89 de                	mov    %ebx,%esi
  800cb6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb8:	85 c0                	test   %eax,%eax
  800cba:	7e 17                	jle    800cd3 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbc:	83 ec 0c             	sub    $0xc,%esp
  800cbf:	50                   	push   %eax
  800cc0:	6a 06                	push   $0x6
  800cc2:	68 9f 25 80 00       	push   $0x80259f
  800cc7:	6a 23                	push   $0x23
  800cc9:	68 bc 25 80 00       	push   $0x8025bc
  800cce:	e8 96 11 00 00       	call   801e69 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
  800ce1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce9:	b8 08 00 00 00       	mov    $0x8,%eax
  800cee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf4:	89 df                	mov    %ebx,%edi
  800cf6:	89 de                	mov    %ebx,%esi
  800cf8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	7e 17                	jle    800d15 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfe:	83 ec 0c             	sub    $0xc,%esp
  800d01:	50                   	push   %eax
  800d02:	6a 08                	push   $0x8
  800d04:	68 9f 25 80 00       	push   $0x80259f
  800d09:	6a 23                	push   $0x23
  800d0b:	68 bc 25 80 00       	push   $0x8025bc
  800d10:	e8 54 11 00 00       	call   801e69 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	57                   	push   %edi
  800d21:	56                   	push   %esi
  800d22:	53                   	push   %ebx
  800d23:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d26:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2b:	b8 09 00 00 00       	mov    $0x9,%eax
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
  800d36:	89 df                	mov    %ebx,%edi
  800d38:	89 de                	mov    %ebx,%esi
  800d3a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3c:	85 c0                	test   %eax,%eax
  800d3e:	7e 17                	jle    800d57 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d40:	83 ec 0c             	sub    $0xc,%esp
  800d43:	50                   	push   %eax
  800d44:	6a 09                	push   $0x9
  800d46:	68 9f 25 80 00       	push   $0x80259f
  800d4b:	6a 23                	push   $0x23
  800d4d:	68 bc 25 80 00       	push   $0x8025bc
  800d52:	e8 12 11 00 00       	call   801e69 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5a:	5b                   	pop    %ebx
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	57                   	push   %edi
  800d63:	56                   	push   %esi
  800d64:	53                   	push   %ebx
  800d65:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d68:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d75:	8b 55 08             	mov    0x8(%ebp),%edx
  800d78:	89 df                	mov    %ebx,%edi
  800d7a:	89 de                	mov    %ebx,%esi
  800d7c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7e:	85 c0                	test   %eax,%eax
  800d80:	7e 17                	jle    800d99 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d82:	83 ec 0c             	sub    $0xc,%esp
  800d85:	50                   	push   %eax
  800d86:	6a 0a                	push   $0xa
  800d88:	68 9f 25 80 00       	push   $0x80259f
  800d8d:	6a 23                	push   $0x23
  800d8f:	68 bc 25 80 00       	push   $0x8025bc
  800d94:	e8 d0 10 00 00       	call   801e69 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	57                   	push   %edi
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da7:	be 00 00 00 00       	mov    $0x0,%esi
  800dac:	b8 0c 00 00 00       	mov    $0xc,%eax
  800db1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db4:	8b 55 08             	mov    0x8(%ebp),%edx
  800db7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dba:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dbd:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	57                   	push   %edi
  800dc8:	56                   	push   %esi
  800dc9:	53                   	push   %ebx
  800dca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd2:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dda:	89 cb                	mov    %ecx,%ebx
  800ddc:	89 cf                	mov    %ecx,%edi
  800dde:	89 ce                	mov    %ecx,%esi
  800de0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de2:	85 c0                	test   %eax,%eax
  800de4:	7e 17                	jle    800dfd <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de6:	83 ec 0c             	sub    $0xc,%esp
  800de9:	50                   	push   %eax
  800dea:	6a 0d                	push   $0xd
  800dec:	68 9f 25 80 00       	push   $0x80259f
  800df1:	6a 23                	push   $0x23
  800df3:	68 bc 25 80 00       	push   $0x8025bc
  800df8:	e8 6c 10 00 00       	call   801e69 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	56                   	push   %esi
  800e09:	53                   	push   %ebx
  800e0a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e0d:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800e0f:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e13:	75 25                	jne    800e3a <pgfault+0x35>
  800e15:	89 d8                	mov    %ebx,%eax
  800e17:	c1 e8 0c             	shr    $0xc,%eax
  800e1a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e21:	f6 c4 08             	test   $0x8,%ah
  800e24:	75 14                	jne    800e3a <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800e26:	83 ec 04             	sub    $0x4,%esp
  800e29:	68 cc 25 80 00       	push   $0x8025cc
  800e2e:	6a 1e                	push   $0x1e
  800e30:	68 60 26 80 00       	push   $0x802660
  800e35:	e8 2f 10 00 00       	call   801e69 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800e3a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800e40:	e8 91 fd ff ff       	call   800bd6 <sys_getenvid>
  800e45:	89 c6                	mov    %eax,%esi

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800e47:	83 ec 04             	sub    $0x4,%esp
  800e4a:	6a 07                	push   $0x7
  800e4c:	68 00 f0 7f 00       	push   $0x7ff000
  800e51:	50                   	push   %eax
  800e52:	e8 bd fd ff ff       	call   800c14 <sys_page_alloc>
	if (r < 0)
  800e57:	83 c4 10             	add    $0x10,%esp
  800e5a:	85 c0                	test   %eax,%eax
  800e5c:	79 12                	jns    800e70 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800e5e:	50                   	push   %eax
  800e5f:	68 f8 25 80 00       	push   $0x8025f8
  800e64:	6a 31                	push   $0x31
  800e66:	68 60 26 80 00       	push   $0x802660
  800e6b:	e8 f9 0f 00 00       	call   801e69 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800e70:	83 ec 04             	sub    $0x4,%esp
  800e73:	68 00 10 00 00       	push   $0x1000
  800e78:	53                   	push   %ebx
  800e79:	68 00 f0 7f 00       	push   $0x7ff000
  800e7e:	e8 88 fb ff ff       	call   800a0b <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800e83:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e8a:	53                   	push   %ebx
  800e8b:	56                   	push   %esi
  800e8c:	68 00 f0 7f 00       	push   $0x7ff000
  800e91:	56                   	push   %esi
  800e92:	e8 c0 fd ff ff       	call   800c57 <sys_page_map>
	if (r < 0)
  800e97:	83 c4 20             	add    $0x20,%esp
  800e9a:	85 c0                	test   %eax,%eax
  800e9c:	79 12                	jns    800eb0 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800e9e:	50                   	push   %eax
  800e9f:	68 1c 26 80 00       	push   $0x80261c
  800ea4:	6a 39                	push   $0x39
  800ea6:	68 60 26 80 00       	push   $0x802660
  800eab:	e8 b9 0f 00 00       	call   801e69 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800eb0:	83 ec 08             	sub    $0x8,%esp
  800eb3:	68 00 f0 7f 00       	push   $0x7ff000
  800eb8:	56                   	push   %esi
  800eb9:	e8 db fd ff ff       	call   800c99 <sys_page_unmap>
	if (r < 0)
  800ebe:	83 c4 10             	add    $0x10,%esp
  800ec1:	85 c0                	test   %eax,%eax
  800ec3:	79 12                	jns    800ed7 <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800ec5:	50                   	push   %eax
  800ec6:	68 40 26 80 00       	push   $0x802640
  800ecb:	6a 3e                	push   $0x3e
  800ecd:	68 60 26 80 00       	push   $0x802660
  800ed2:	e8 92 0f 00 00       	call   801e69 <_panic>
}
  800ed7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eda:	5b                   	pop    %ebx
  800edb:	5e                   	pop    %esi
  800edc:	5d                   	pop    %ebp
  800edd:	c3                   	ret    

00800ede <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
  800ee1:	57                   	push   %edi
  800ee2:	56                   	push   %esi
  800ee3:	53                   	push   %ebx
  800ee4:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800ee7:	68 05 0e 80 00       	push   $0x800e05
  800eec:	e8 be 0f 00 00       	call   801eaf <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ef1:	b8 07 00 00 00       	mov    $0x7,%eax
  800ef6:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800ef8:	83 c4 10             	add    $0x10,%esp
  800efb:	85 c0                	test   %eax,%eax
  800efd:	0f 88 67 01 00 00    	js     80106a <fork+0x18c>
  800f03:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800f08:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800f0d:	85 c0                	test   %eax,%eax
  800f0f:	75 21                	jne    800f32 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f11:	e8 c0 fc ff ff       	call   800bd6 <sys_getenvid>
  800f16:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f1b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f1e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f23:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  800f28:	ba 00 00 00 00       	mov    $0x0,%edx
  800f2d:	e9 42 01 00 00       	jmp    801074 <fork+0x196>
  800f32:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f35:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800f37:	89 d8                	mov    %ebx,%eax
  800f39:	c1 e8 16             	shr    $0x16,%eax
  800f3c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f43:	a8 01                	test   $0x1,%al
  800f45:	0f 84 c0 00 00 00    	je     80100b <fork+0x12d>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800f4b:	89 d8                	mov    %ebx,%eax
  800f4d:	c1 e8 0c             	shr    $0xc,%eax
  800f50:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f57:	f6 c2 01             	test   $0x1,%dl
  800f5a:	0f 84 ab 00 00 00    	je     80100b <fork+0x12d>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
  800f60:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f67:	a9 02 08 00 00       	test   $0x802,%eax
  800f6c:	0f 84 99 00 00 00    	je     80100b <fork+0x12d>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800f72:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f79:	f6 c4 04             	test   $0x4,%ah
  800f7c:	74 17                	je     800f95 <fork+0xb7>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800f7e:	83 ec 0c             	sub    $0xc,%esp
  800f81:	68 07 0e 00 00       	push   $0xe07
  800f86:	53                   	push   %ebx
  800f87:	57                   	push   %edi
  800f88:	53                   	push   %ebx
  800f89:	6a 00                	push   $0x0
  800f8b:	e8 c7 fc ff ff       	call   800c57 <sys_page_map>
  800f90:	83 c4 20             	add    $0x20,%esp
  800f93:	eb 76                	jmp    80100b <fork+0x12d>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f95:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f9c:	a8 02                	test   $0x2,%al
  800f9e:	75 0c                	jne    800fac <fork+0xce>
  800fa0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fa7:	f6 c4 08             	test   $0x8,%ah
  800faa:	74 3f                	je     800feb <fork+0x10d>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800fac:	83 ec 0c             	sub    $0xc,%esp
  800faf:	68 05 08 00 00       	push   $0x805
  800fb4:	53                   	push   %ebx
  800fb5:	57                   	push   %edi
  800fb6:	53                   	push   %ebx
  800fb7:	6a 00                	push   $0x0
  800fb9:	e8 99 fc ff ff       	call   800c57 <sys_page_map>
		if (r < 0)
  800fbe:	83 c4 20             	add    $0x20,%esp
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	0f 88 a5 00 00 00    	js     80106e <fork+0x190>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800fc9:	83 ec 0c             	sub    $0xc,%esp
  800fcc:	68 05 08 00 00       	push   $0x805
  800fd1:	53                   	push   %ebx
  800fd2:	6a 00                	push   $0x0
  800fd4:	53                   	push   %ebx
  800fd5:	6a 00                	push   $0x0
  800fd7:	e8 7b fc ff ff       	call   800c57 <sys_page_map>
  800fdc:	83 c4 20             	add    $0x20,%esp
  800fdf:	85 c0                	test   %eax,%eax
  800fe1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe6:	0f 4f c1             	cmovg  %ecx,%eax
  800fe9:	eb 1c                	jmp    801007 <fork+0x129>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800feb:	83 ec 0c             	sub    $0xc,%esp
  800fee:	6a 05                	push   $0x5
  800ff0:	53                   	push   %ebx
  800ff1:	57                   	push   %edi
  800ff2:	53                   	push   %ebx
  800ff3:	6a 00                	push   $0x0
  800ff5:	e8 5d fc ff ff       	call   800c57 <sys_page_map>
  800ffa:	83 c4 20             	add    $0x20,%esp
  800ffd:	85 c0                	test   %eax,%eax
  800fff:	b9 00 00 00 00       	mov    $0x0,%ecx
  801004:	0f 4f c1             	cmovg  %ecx,%eax
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  801007:	85 c0                	test   %eax,%eax
  801009:	78 67                	js     801072 <fork+0x194>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  80100b:	83 c6 01             	add    $0x1,%esi
  80100e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801014:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  80101a:	0f 85 17 ff ff ff    	jne    800f37 <fork+0x59>
  801020:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  801023:	83 ec 04             	sub    $0x4,%esp
  801026:	6a 07                	push   $0x7
  801028:	68 00 f0 bf ee       	push   $0xeebff000
  80102d:	57                   	push   %edi
  80102e:	e8 e1 fb ff ff       	call   800c14 <sys_page_alloc>
	if (r < 0)
  801033:	83 c4 10             	add    $0x10,%esp
		return r;
  801036:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  801038:	85 c0                	test   %eax,%eax
  80103a:	78 38                	js     801074 <fork+0x196>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80103c:	83 ec 08             	sub    $0x8,%esp
  80103f:	68 f6 1e 80 00       	push   $0x801ef6
  801044:	57                   	push   %edi
  801045:	e8 15 fd ff ff       	call   800d5f <sys_env_set_pgfault_upcall>
	if (r < 0)
  80104a:	83 c4 10             	add    $0x10,%esp
		return r;
  80104d:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  80104f:	85 c0                	test   %eax,%eax
  801051:	78 21                	js     801074 <fork+0x196>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801053:	83 ec 08             	sub    $0x8,%esp
  801056:	6a 02                	push   $0x2
  801058:	57                   	push   %edi
  801059:	e8 7d fc ff ff       	call   800cdb <sys_env_set_status>
	if (r < 0)
  80105e:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801061:	85 c0                	test   %eax,%eax
  801063:	0f 48 f8             	cmovs  %eax,%edi
  801066:	89 fa                	mov    %edi,%edx
  801068:	eb 0a                	jmp    801074 <fork+0x196>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  80106a:	89 c2                	mov    %eax,%edx
  80106c:	eb 06                	jmp    801074 <fork+0x196>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  80106e:	89 c2                	mov    %eax,%edx
  801070:	eb 02                	jmp    801074 <fork+0x196>
  801072:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  801074:	89 d0                	mov    %edx,%eax
  801076:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801079:	5b                   	pop    %ebx
  80107a:	5e                   	pop    %esi
  80107b:	5f                   	pop    %edi
  80107c:	5d                   	pop    %ebp
  80107d:	c3                   	ret    

0080107e <sfork>:

// Challenge!
int
sfork(void)
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801084:	68 6b 26 80 00       	push   $0x80266b
  801089:	68 c6 00 00 00       	push   $0xc6
  80108e:	68 60 26 80 00       	push   $0x802660
  801093:	e8 d1 0d 00 00       	call   801e69 <_panic>

00801098 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	56                   	push   %esi
  80109c:	53                   	push   %ebx
  80109d:	8b 75 08             	mov    0x8(%ebp),%esi
  8010a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8010a6:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8010a8:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8010ad:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8010b0:	83 ec 0c             	sub    $0xc,%esp
  8010b3:	50                   	push   %eax
  8010b4:	e8 0b fd ff ff       	call   800dc4 <sys_ipc_recv>

	if (from_env_store != NULL)
  8010b9:	83 c4 10             	add    $0x10,%esp
  8010bc:	85 f6                	test   %esi,%esi
  8010be:	74 14                	je     8010d4 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8010c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8010c5:	85 c0                	test   %eax,%eax
  8010c7:	78 09                	js     8010d2 <ipc_recv+0x3a>
  8010c9:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8010cf:	8b 52 74             	mov    0x74(%edx),%edx
  8010d2:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8010d4:	85 db                	test   %ebx,%ebx
  8010d6:	74 14                	je     8010ec <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8010d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8010dd:	85 c0                	test   %eax,%eax
  8010df:	78 09                	js     8010ea <ipc_recv+0x52>
  8010e1:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8010e7:	8b 52 78             	mov    0x78(%edx),%edx
  8010ea:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8010ec:	85 c0                	test   %eax,%eax
  8010ee:	78 08                	js     8010f8 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8010f0:	a1 04 40 80 00       	mov    0x804004,%eax
  8010f5:	8b 40 70             	mov    0x70(%eax),%eax
}
  8010f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010fb:	5b                   	pop    %ebx
  8010fc:	5e                   	pop    %esi
  8010fd:	5d                   	pop    %ebp
  8010fe:	c3                   	ret    

008010ff <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	57                   	push   %edi
  801103:	56                   	push   %esi
  801104:	53                   	push   %ebx
  801105:	83 ec 0c             	sub    $0xc,%esp
  801108:	8b 7d 08             	mov    0x8(%ebp),%edi
  80110b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80110e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801111:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801113:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801118:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80111b:	ff 75 14             	pushl  0x14(%ebp)
  80111e:	53                   	push   %ebx
  80111f:	56                   	push   %esi
  801120:	57                   	push   %edi
  801121:	e8 7b fc ff ff       	call   800da1 <sys_ipc_try_send>

		if (err < 0) {
  801126:	83 c4 10             	add    $0x10,%esp
  801129:	85 c0                	test   %eax,%eax
  80112b:	79 1e                	jns    80114b <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  80112d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801130:	75 07                	jne    801139 <ipc_send+0x3a>
				sys_yield();
  801132:	e8 be fa ff ff       	call   800bf5 <sys_yield>
  801137:	eb e2                	jmp    80111b <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801139:	50                   	push   %eax
  80113a:	68 81 26 80 00       	push   $0x802681
  80113f:	6a 49                	push   $0x49
  801141:	68 8e 26 80 00       	push   $0x80268e
  801146:	e8 1e 0d 00 00       	call   801e69 <_panic>
		}

	} while (err < 0);

}
  80114b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80114e:	5b                   	pop    %ebx
  80114f:	5e                   	pop    %esi
  801150:	5f                   	pop    %edi
  801151:	5d                   	pop    %ebp
  801152:	c3                   	ret    

00801153 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801159:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80115e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801161:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801167:	8b 52 50             	mov    0x50(%edx),%edx
  80116a:	39 ca                	cmp    %ecx,%edx
  80116c:	75 0d                	jne    80117b <ipc_find_env+0x28>
			return envs[i].env_id;
  80116e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801171:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801176:	8b 40 48             	mov    0x48(%eax),%eax
  801179:	eb 0f                	jmp    80118a <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80117b:	83 c0 01             	add    $0x1,%eax
  80117e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801183:	75 d9                	jne    80115e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801185:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80118a:	5d                   	pop    %ebp
  80118b:	c3                   	ret    

0080118c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80118f:	8b 45 08             	mov    0x8(%ebp),%eax
  801192:	05 00 00 00 30       	add    $0x30000000,%eax
  801197:	c1 e8 0c             	shr    $0xc,%eax
}
  80119a:	5d                   	pop    %ebp
  80119b:	c3                   	ret    

0080119c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80119f:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a2:	05 00 00 00 30       	add    $0x30000000,%eax
  8011a7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011ac:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011b1:	5d                   	pop    %ebp
  8011b2:	c3                   	ret    

008011b3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011b3:	55                   	push   %ebp
  8011b4:	89 e5                	mov    %esp,%ebp
  8011b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011b9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011be:	89 c2                	mov    %eax,%edx
  8011c0:	c1 ea 16             	shr    $0x16,%edx
  8011c3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011ca:	f6 c2 01             	test   $0x1,%dl
  8011cd:	74 11                	je     8011e0 <fd_alloc+0x2d>
  8011cf:	89 c2                	mov    %eax,%edx
  8011d1:	c1 ea 0c             	shr    $0xc,%edx
  8011d4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011db:	f6 c2 01             	test   $0x1,%dl
  8011de:	75 09                	jne    8011e9 <fd_alloc+0x36>
			*fd_store = fd;
  8011e0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e7:	eb 17                	jmp    801200 <fd_alloc+0x4d>
  8011e9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011ee:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011f3:	75 c9                	jne    8011be <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011f5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011fb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801200:	5d                   	pop    %ebp
  801201:	c3                   	ret    

00801202 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801202:	55                   	push   %ebp
  801203:	89 e5                	mov    %esp,%ebp
  801205:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801208:	83 f8 1f             	cmp    $0x1f,%eax
  80120b:	77 36                	ja     801243 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80120d:	c1 e0 0c             	shl    $0xc,%eax
  801210:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801215:	89 c2                	mov    %eax,%edx
  801217:	c1 ea 16             	shr    $0x16,%edx
  80121a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801221:	f6 c2 01             	test   $0x1,%dl
  801224:	74 24                	je     80124a <fd_lookup+0x48>
  801226:	89 c2                	mov    %eax,%edx
  801228:	c1 ea 0c             	shr    $0xc,%edx
  80122b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801232:	f6 c2 01             	test   $0x1,%dl
  801235:	74 1a                	je     801251 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801237:	8b 55 0c             	mov    0xc(%ebp),%edx
  80123a:	89 02                	mov    %eax,(%edx)
	return 0;
  80123c:	b8 00 00 00 00       	mov    $0x0,%eax
  801241:	eb 13                	jmp    801256 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801243:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801248:	eb 0c                	jmp    801256 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80124a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80124f:	eb 05                	jmp    801256 <fd_lookup+0x54>
  801251:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801256:	5d                   	pop    %ebp
  801257:	c3                   	ret    

00801258 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	83 ec 08             	sub    $0x8,%esp
  80125e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801261:	ba 14 27 80 00       	mov    $0x802714,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801266:	eb 13                	jmp    80127b <dev_lookup+0x23>
  801268:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80126b:	39 08                	cmp    %ecx,(%eax)
  80126d:	75 0c                	jne    80127b <dev_lookup+0x23>
			*dev = devtab[i];
  80126f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801272:	89 01                	mov    %eax,(%ecx)
			return 0;
  801274:	b8 00 00 00 00       	mov    $0x0,%eax
  801279:	eb 2e                	jmp    8012a9 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80127b:	8b 02                	mov    (%edx),%eax
  80127d:	85 c0                	test   %eax,%eax
  80127f:	75 e7                	jne    801268 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801281:	a1 04 40 80 00       	mov    0x804004,%eax
  801286:	8b 40 48             	mov    0x48(%eax),%eax
  801289:	83 ec 04             	sub    $0x4,%esp
  80128c:	51                   	push   %ecx
  80128d:	50                   	push   %eax
  80128e:	68 98 26 80 00       	push   $0x802698
  801293:	e8 f4 ef ff ff       	call   80028c <cprintf>
	*dev = 0;
  801298:	8b 45 0c             	mov    0xc(%ebp),%eax
  80129b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012a1:	83 c4 10             	add    $0x10,%esp
  8012a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012a9:	c9                   	leave  
  8012aa:	c3                   	ret    

008012ab <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012ab:	55                   	push   %ebp
  8012ac:	89 e5                	mov    %esp,%ebp
  8012ae:	56                   	push   %esi
  8012af:	53                   	push   %ebx
  8012b0:	83 ec 10             	sub    $0x10,%esp
  8012b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8012b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012bc:	50                   	push   %eax
  8012bd:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012c3:	c1 e8 0c             	shr    $0xc,%eax
  8012c6:	50                   	push   %eax
  8012c7:	e8 36 ff ff ff       	call   801202 <fd_lookup>
  8012cc:	83 c4 08             	add    $0x8,%esp
  8012cf:	85 c0                	test   %eax,%eax
  8012d1:	78 05                	js     8012d8 <fd_close+0x2d>
	    || fd != fd2)
  8012d3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012d6:	74 0c                	je     8012e4 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012d8:	84 db                	test   %bl,%bl
  8012da:	ba 00 00 00 00       	mov    $0x0,%edx
  8012df:	0f 44 c2             	cmove  %edx,%eax
  8012e2:	eb 41                	jmp    801325 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012e4:	83 ec 08             	sub    $0x8,%esp
  8012e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ea:	50                   	push   %eax
  8012eb:	ff 36                	pushl  (%esi)
  8012ed:	e8 66 ff ff ff       	call   801258 <dev_lookup>
  8012f2:	89 c3                	mov    %eax,%ebx
  8012f4:	83 c4 10             	add    $0x10,%esp
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	78 1a                	js     801315 <fd_close+0x6a>
		if (dev->dev_close)
  8012fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fe:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801301:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801306:	85 c0                	test   %eax,%eax
  801308:	74 0b                	je     801315 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80130a:	83 ec 0c             	sub    $0xc,%esp
  80130d:	56                   	push   %esi
  80130e:	ff d0                	call   *%eax
  801310:	89 c3                	mov    %eax,%ebx
  801312:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801315:	83 ec 08             	sub    $0x8,%esp
  801318:	56                   	push   %esi
  801319:	6a 00                	push   $0x0
  80131b:	e8 79 f9 ff ff       	call   800c99 <sys_page_unmap>
	return r;
  801320:	83 c4 10             	add    $0x10,%esp
  801323:	89 d8                	mov    %ebx,%eax
}
  801325:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801328:	5b                   	pop    %ebx
  801329:	5e                   	pop    %esi
  80132a:	5d                   	pop    %ebp
  80132b:	c3                   	ret    

0080132c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
  80132f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801332:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801335:	50                   	push   %eax
  801336:	ff 75 08             	pushl  0x8(%ebp)
  801339:	e8 c4 fe ff ff       	call   801202 <fd_lookup>
  80133e:	83 c4 08             	add    $0x8,%esp
  801341:	85 c0                	test   %eax,%eax
  801343:	78 10                	js     801355 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801345:	83 ec 08             	sub    $0x8,%esp
  801348:	6a 01                	push   $0x1
  80134a:	ff 75 f4             	pushl  -0xc(%ebp)
  80134d:	e8 59 ff ff ff       	call   8012ab <fd_close>
  801352:	83 c4 10             	add    $0x10,%esp
}
  801355:	c9                   	leave  
  801356:	c3                   	ret    

00801357 <close_all>:

void
close_all(void)
{
  801357:	55                   	push   %ebp
  801358:	89 e5                	mov    %esp,%ebp
  80135a:	53                   	push   %ebx
  80135b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80135e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801363:	83 ec 0c             	sub    $0xc,%esp
  801366:	53                   	push   %ebx
  801367:	e8 c0 ff ff ff       	call   80132c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80136c:	83 c3 01             	add    $0x1,%ebx
  80136f:	83 c4 10             	add    $0x10,%esp
  801372:	83 fb 20             	cmp    $0x20,%ebx
  801375:	75 ec                	jne    801363 <close_all+0xc>
		close(i);
}
  801377:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137a:	c9                   	leave  
  80137b:	c3                   	ret    

0080137c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	57                   	push   %edi
  801380:	56                   	push   %esi
  801381:	53                   	push   %ebx
  801382:	83 ec 2c             	sub    $0x2c,%esp
  801385:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801388:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80138b:	50                   	push   %eax
  80138c:	ff 75 08             	pushl  0x8(%ebp)
  80138f:	e8 6e fe ff ff       	call   801202 <fd_lookup>
  801394:	83 c4 08             	add    $0x8,%esp
  801397:	85 c0                	test   %eax,%eax
  801399:	0f 88 c1 00 00 00    	js     801460 <dup+0xe4>
		return r;
	close(newfdnum);
  80139f:	83 ec 0c             	sub    $0xc,%esp
  8013a2:	56                   	push   %esi
  8013a3:	e8 84 ff ff ff       	call   80132c <close>

	newfd = INDEX2FD(newfdnum);
  8013a8:	89 f3                	mov    %esi,%ebx
  8013aa:	c1 e3 0c             	shl    $0xc,%ebx
  8013ad:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013b3:	83 c4 04             	add    $0x4,%esp
  8013b6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013b9:	e8 de fd ff ff       	call   80119c <fd2data>
  8013be:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013c0:	89 1c 24             	mov    %ebx,(%esp)
  8013c3:	e8 d4 fd ff ff       	call   80119c <fd2data>
  8013c8:	83 c4 10             	add    $0x10,%esp
  8013cb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013ce:	89 f8                	mov    %edi,%eax
  8013d0:	c1 e8 16             	shr    $0x16,%eax
  8013d3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013da:	a8 01                	test   $0x1,%al
  8013dc:	74 37                	je     801415 <dup+0x99>
  8013de:	89 f8                	mov    %edi,%eax
  8013e0:	c1 e8 0c             	shr    $0xc,%eax
  8013e3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013ea:	f6 c2 01             	test   $0x1,%dl
  8013ed:	74 26                	je     801415 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013ef:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013f6:	83 ec 0c             	sub    $0xc,%esp
  8013f9:	25 07 0e 00 00       	and    $0xe07,%eax
  8013fe:	50                   	push   %eax
  8013ff:	ff 75 d4             	pushl  -0x2c(%ebp)
  801402:	6a 00                	push   $0x0
  801404:	57                   	push   %edi
  801405:	6a 00                	push   $0x0
  801407:	e8 4b f8 ff ff       	call   800c57 <sys_page_map>
  80140c:	89 c7                	mov    %eax,%edi
  80140e:	83 c4 20             	add    $0x20,%esp
  801411:	85 c0                	test   %eax,%eax
  801413:	78 2e                	js     801443 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801415:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801418:	89 d0                	mov    %edx,%eax
  80141a:	c1 e8 0c             	shr    $0xc,%eax
  80141d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801424:	83 ec 0c             	sub    $0xc,%esp
  801427:	25 07 0e 00 00       	and    $0xe07,%eax
  80142c:	50                   	push   %eax
  80142d:	53                   	push   %ebx
  80142e:	6a 00                	push   $0x0
  801430:	52                   	push   %edx
  801431:	6a 00                	push   $0x0
  801433:	e8 1f f8 ff ff       	call   800c57 <sys_page_map>
  801438:	89 c7                	mov    %eax,%edi
  80143a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80143d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80143f:	85 ff                	test   %edi,%edi
  801441:	79 1d                	jns    801460 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801443:	83 ec 08             	sub    $0x8,%esp
  801446:	53                   	push   %ebx
  801447:	6a 00                	push   $0x0
  801449:	e8 4b f8 ff ff       	call   800c99 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80144e:	83 c4 08             	add    $0x8,%esp
  801451:	ff 75 d4             	pushl  -0x2c(%ebp)
  801454:	6a 00                	push   $0x0
  801456:	e8 3e f8 ff ff       	call   800c99 <sys_page_unmap>
	return r;
  80145b:	83 c4 10             	add    $0x10,%esp
  80145e:	89 f8                	mov    %edi,%eax
}
  801460:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801463:	5b                   	pop    %ebx
  801464:	5e                   	pop    %esi
  801465:	5f                   	pop    %edi
  801466:	5d                   	pop    %ebp
  801467:	c3                   	ret    

00801468 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	53                   	push   %ebx
  80146c:	83 ec 14             	sub    $0x14,%esp
  80146f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801472:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801475:	50                   	push   %eax
  801476:	53                   	push   %ebx
  801477:	e8 86 fd ff ff       	call   801202 <fd_lookup>
  80147c:	83 c4 08             	add    $0x8,%esp
  80147f:	89 c2                	mov    %eax,%edx
  801481:	85 c0                	test   %eax,%eax
  801483:	78 6d                	js     8014f2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801485:	83 ec 08             	sub    $0x8,%esp
  801488:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148b:	50                   	push   %eax
  80148c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80148f:	ff 30                	pushl  (%eax)
  801491:	e8 c2 fd ff ff       	call   801258 <dev_lookup>
  801496:	83 c4 10             	add    $0x10,%esp
  801499:	85 c0                	test   %eax,%eax
  80149b:	78 4c                	js     8014e9 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80149d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014a0:	8b 42 08             	mov    0x8(%edx),%eax
  8014a3:	83 e0 03             	and    $0x3,%eax
  8014a6:	83 f8 01             	cmp    $0x1,%eax
  8014a9:	75 21                	jne    8014cc <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ab:	a1 04 40 80 00       	mov    0x804004,%eax
  8014b0:	8b 40 48             	mov    0x48(%eax),%eax
  8014b3:	83 ec 04             	sub    $0x4,%esp
  8014b6:	53                   	push   %ebx
  8014b7:	50                   	push   %eax
  8014b8:	68 d9 26 80 00       	push   $0x8026d9
  8014bd:	e8 ca ed ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  8014c2:	83 c4 10             	add    $0x10,%esp
  8014c5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014ca:	eb 26                	jmp    8014f2 <read+0x8a>
	}
	if (!dev->dev_read)
  8014cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014cf:	8b 40 08             	mov    0x8(%eax),%eax
  8014d2:	85 c0                	test   %eax,%eax
  8014d4:	74 17                	je     8014ed <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014d6:	83 ec 04             	sub    $0x4,%esp
  8014d9:	ff 75 10             	pushl  0x10(%ebp)
  8014dc:	ff 75 0c             	pushl  0xc(%ebp)
  8014df:	52                   	push   %edx
  8014e0:	ff d0                	call   *%eax
  8014e2:	89 c2                	mov    %eax,%edx
  8014e4:	83 c4 10             	add    $0x10,%esp
  8014e7:	eb 09                	jmp    8014f2 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e9:	89 c2                	mov    %eax,%edx
  8014eb:	eb 05                	jmp    8014f2 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014ed:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014f2:	89 d0                	mov    %edx,%eax
  8014f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f7:	c9                   	leave  
  8014f8:	c3                   	ret    

008014f9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014f9:	55                   	push   %ebp
  8014fa:	89 e5                	mov    %esp,%ebp
  8014fc:	57                   	push   %edi
  8014fd:	56                   	push   %esi
  8014fe:	53                   	push   %ebx
  8014ff:	83 ec 0c             	sub    $0xc,%esp
  801502:	8b 7d 08             	mov    0x8(%ebp),%edi
  801505:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801508:	bb 00 00 00 00       	mov    $0x0,%ebx
  80150d:	eb 21                	jmp    801530 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80150f:	83 ec 04             	sub    $0x4,%esp
  801512:	89 f0                	mov    %esi,%eax
  801514:	29 d8                	sub    %ebx,%eax
  801516:	50                   	push   %eax
  801517:	89 d8                	mov    %ebx,%eax
  801519:	03 45 0c             	add    0xc(%ebp),%eax
  80151c:	50                   	push   %eax
  80151d:	57                   	push   %edi
  80151e:	e8 45 ff ff ff       	call   801468 <read>
		if (m < 0)
  801523:	83 c4 10             	add    $0x10,%esp
  801526:	85 c0                	test   %eax,%eax
  801528:	78 10                	js     80153a <readn+0x41>
			return m;
		if (m == 0)
  80152a:	85 c0                	test   %eax,%eax
  80152c:	74 0a                	je     801538 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80152e:	01 c3                	add    %eax,%ebx
  801530:	39 f3                	cmp    %esi,%ebx
  801532:	72 db                	jb     80150f <readn+0x16>
  801534:	89 d8                	mov    %ebx,%eax
  801536:	eb 02                	jmp    80153a <readn+0x41>
  801538:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80153a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80153d:	5b                   	pop    %ebx
  80153e:	5e                   	pop    %esi
  80153f:	5f                   	pop    %edi
  801540:	5d                   	pop    %ebp
  801541:	c3                   	ret    

00801542 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801542:	55                   	push   %ebp
  801543:	89 e5                	mov    %esp,%ebp
  801545:	53                   	push   %ebx
  801546:	83 ec 14             	sub    $0x14,%esp
  801549:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80154f:	50                   	push   %eax
  801550:	53                   	push   %ebx
  801551:	e8 ac fc ff ff       	call   801202 <fd_lookup>
  801556:	83 c4 08             	add    $0x8,%esp
  801559:	89 c2                	mov    %eax,%edx
  80155b:	85 c0                	test   %eax,%eax
  80155d:	78 68                	js     8015c7 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155f:	83 ec 08             	sub    $0x8,%esp
  801562:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801565:	50                   	push   %eax
  801566:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801569:	ff 30                	pushl  (%eax)
  80156b:	e8 e8 fc ff ff       	call   801258 <dev_lookup>
  801570:	83 c4 10             	add    $0x10,%esp
  801573:	85 c0                	test   %eax,%eax
  801575:	78 47                	js     8015be <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801577:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80157e:	75 21                	jne    8015a1 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801580:	a1 04 40 80 00       	mov    0x804004,%eax
  801585:	8b 40 48             	mov    0x48(%eax),%eax
  801588:	83 ec 04             	sub    $0x4,%esp
  80158b:	53                   	push   %ebx
  80158c:	50                   	push   %eax
  80158d:	68 f5 26 80 00       	push   $0x8026f5
  801592:	e8 f5 ec ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80159f:	eb 26                	jmp    8015c7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a4:	8b 52 0c             	mov    0xc(%edx),%edx
  8015a7:	85 d2                	test   %edx,%edx
  8015a9:	74 17                	je     8015c2 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015ab:	83 ec 04             	sub    $0x4,%esp
  8015ae:	ff 75 10             	pushl  0x10(%ebp)
  8015b1:	ff 75 0c             	pushl  0xc(%ebp)
  8015b4:	50                   	push   %eax
  8015b5:	ff d2                	call   *%edx
  8015b7:	89 c2                	mov    %eax,%edx
  8015b9:	83 c4 10             	add    $0x10,%esp
  8015bc:	eb 09                	jmp    8015c7 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015be:	89 c2                	mov    %eax,%edx
  8015c0:	eb 05                	jmp    8015c7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015c2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015c7:	89 d0                	mov    %edx,%eax
  8015c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cc:	c9                   	leave  
  8015cd:	c3                   	ret    

008015ce <seek>:

int
seek(int fdnum, off_t offset)
{
  8015ce:	55                   	push   %ebp
  8015cf:	89 e5                	mov    %esp,%ebp
  8015d1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015d4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015d7:	50                   	push   %eax
  8015d8:	ff 75 08             	pushl  0x8(%ebp)
  8015db:	e8 22 fc ff ff       	call   801202 <fd_lookup>
  8015e0:	83 c4 08             	add    $0x8,%esp
  8015e3:	85 c0                	test   %eax,%eax
  8015e5:	78 0e                	js     8015f5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ed:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015f5:	c9                   	leave  
  8015f6:	c3                   	ret    

008015f7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015f7:	55                   	push   %ebp
  8015f8:	89 e5                	mov    %esp,%ebp
  8015fa:	53                   	push   %ebx
  8015fb:	83 ec 14             	sub    $0x14,%esp
  8015fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801601:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801604:	50                   	push   %eax
  801605:	53                   	push   %ebx
  801606:	e8 f7 fb ff ff       	call   801202 <fd_lookup>
  80160b:	83 c4 08             	add    $0x8,%esp
  80160e:	89 c2                	mov    %eax,%edx
  801610:	85 c0                	test   %eax,%eax
  801612:	78 65                	js     801679 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801614:	83 ec 08             	sub    $0x8,%esp
  801617:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161a:	50                   	push   %eax
  80161b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161e:	ff 30                	pushl  (%eax)
  801620:	e8 33 fc ff ff       	call   801258 <dev_lookup>
  801625:	83 c4 10             	add    $0x10,%esp
  801628:	85 c0                	test   %eax,%eax
  80162a:	78 44                	js     801670 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80162c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801633:	75 21                	jne    801656 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801635:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80163a:	8b 40 48             	mov    0x48(%eax),%eax
  80163d:	83 ec 04             	sub    $0x4,%esp
  801640:	53                   	push   %ebx
  801641:	50                   	push   %eax
  801642:	68 b8 26 80 00       	push   $0x8026b8
  801647:	e8 40 ec ff ff       	call   80028c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801654:	eb 23                	jmp    801679 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801656:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801659:	8b 52 18             	mov    0x18(%edx),%edx
  80165c:	85 d2                	test   %edx,%edx
  80165e:	74 14                	je     801674 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801660:	83 ec 08             	sub    $0x8,%esp
  801663:	ff 75 0c             	pushl  0xc(%ebp)
  801666:	50                   	push   %eax
  801667:	ff d2                	call   *%edx
  801669:	89 c2                	mov    %eax,%edx
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	eb 09                	jmp    801679 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801670:	89 c2                	mov    %eax,%edx
  801672:	eb 05                	jmp    801679 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801674:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801679:	89 d0                	mov    %edx,%eax
  80167b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167e:	c9                   	leave  
  80167f:	c3                   	ret    

00801680 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	53                   	push   %ebx
  801684:	83 ec 14             	sub    $0x14,%esp
  801687:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80168d:	50                   	push   %eax
  80168e:	ff 75 08             	pushl  0x8(%ebp)
  801691:	e8 6c fb ff ff       	call   801202 <fd_lookup>
  801696:	83 c4 08             	add    $0x8,%esp
  801699:	89 c2                	mov    %eax,%edx
  80169b:	85 c0                	test   %eax,%eax
  80169d:	78 58                	js     8016f7 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169f:	83 ec 08             	sub    $0x8,%esp
  8016a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a5:	50                   	push   %eax
  8016a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a9:	ff 30                	pushl  (%eax)
  8016ab:	e8 a8 fb ff ff       	call   801258 <dev_lookup>
  8016b0:	83 c4 10             	add    $0x10,%esp
  8016b3:	85 c0                	test   %eax,%eax
  8016b5:	78 37                	js     8016ee <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ba:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016be:	74 32                	je     8016f2 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016c0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016c3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016ca:	00 00 00 
	stat->st_isdir = 0;
  8016cd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016d4:	00 00 00 
	stat->st_dev = dev;
  8016d7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016dd:	83 ec 08             	sub    $0x8,%esp
  8016e0:	53                   	push   %ebx
  8016e1:	ff 75 f0             	pushl  -0x10(%ebp)
  8016e4:	ff 50 14             	call   *0x14(%eax)
  8016e7:	89 c2                	mov    %eax,%edx
  8016e9:	83 c4 10             	add    $0x10,%esp
  8016ec:	eb 09                	jmp    8016f7 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ee:	89 c2                	mov    %eax,%edx
  8016f0:	eb 05                	jmp    8016f7 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016f2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016f7:	89 d0                	mov    %edx,%eax
  8016f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016fc:	c9                   	leave  
  8016fd:	c3                   	ret    

008016fe <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	56                   	push   %esi
  801702:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801703:	83 ec 08             	sub    $0x8,%esp
  801706:	6a 00                	push   $0x0
  801708:	ff 75 08             	pushl  0x8(%ebp)
  80170b:	e8 d6 01 00 00       	call   8018e6 <open>
  801710:	89 c3                	mov    %eax,%ebx
  801712:	83 c4 10             	add    $0x10,%esp
  801715:	85 c0                	test   %eax,%eax
  801717:	78 1b                	js     801734 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801719:	83 ec 08             	sub    $0x8,%esp
  80171c:	ff 75 0c             	pushl  0xc(%ebp)
  80171f:	50                   	push   %eax
  801720:	e8 5b ff ff ff       	call   801680 <fstat>
  801725:	89 c6                	mov    %eax,%esi
	close(fd);
  801727:	89 1c 24             	mov    %ebx,(%esp)
  80172a:	e8 fd fb ff ff       	call   80132c <close>
	return r;
  80172f:	83 c4 10             	add    $0x10,%esp
  801732:	89 f0                	mov    %esi,%eax
}
  801734:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801737:	5b                   	pop    %ebx
  801738:	5e                   	pop    %esi
  801739:	5d                   	pop    %ebp
  80173a:	c3                   	ret    

0080173b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80173b:	55                   	push   %ebp
  80173c:	89 e5                	mov    %esp,%ebp
  80173e:	56                   	push   %esi
  80173f:	53                   	push   %ebx
  801740:	89 c6                	mov    %eax,%esi
  801742:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801744:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80174b:	75 12                	jne    80175f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80174d:	83 ec 0c             	sub    $0xc,%esp
  801750:	6a 01                	push   $0x1
  801752:	e8 fc f9 ff ff       	call   801153 <ipc_find_env>
  801757:	a3 00 40 80 00       	mov    %eax,0x804000
  80175c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80175f:	6a 07                	push   $0x7
  801761:	68 00 50 80 00       	push   $0x805000
  801766:	56                   	push   %esi
  801767:	ff 35 00 40 80 00    	pushl  0x804000
  80176d:	e8 8d f9 ff ff       	call   8010ff <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801772:	83 c4 0c             	add    $0xc,%esp
  801775:	6a 00                	push   $0x0
  801777:	53                   	push   %ebx
  801778:	6a 00                	push   $0x0
  80177a:	e8 19 f9 ff ff       	call   801098 <ipc_recv>
}
  80177f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801782:	5b                   	pop    %ebx
  801783:	5e                   	pop    %esi
  801784:	5d                   	pop    %ebp
  801785:	c3                   	ret    

00801786 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801786:	55                   	push   %ebp
  801787:	89 e5                	mov    %esp,%ebp
  801789:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80178c:	8b 45 08             	mov    0x8(%ebp),%eax
  80178f:	8b 40 0c             	mov    0xc(%eax),%eax
  801792:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801797:	8b 45 0c             	mov    0xc(%ebp),%eax
  80179a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80179f:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a4:	b8 02 00 00 00       	mov    $0x2,%eax
  8017a9:	e8 8d ff ff ff       	call   80173b <fsipc>
}
  8017ae:	c9                   	leave  
  8017af:	c3                   	ret    

008017b0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8017bc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c6:	b8 06 00 00 00       	mov    $0x6,%eax
  8017cb:	e8 6b ff ff ff       	call   80173b <fsipc>
}
  8017d0:	c9                   	leave  
  8017d1:	c3                   	ret    

008017d2 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017d2:	55                   	push   %ebp
  8017d3:	89 e5                	mov    %esp,%ebp
  8017d5:	53                   	push   %ebx
  8017d6:	83 ec 04             	sub    $0x4,%esp
  8017d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017df:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ec:	b8 05 00 00 00       	mov    $0x5,%eax
  8017f1:	e8 45 ff ff ff       	call   80173b <fsipc>
  8017f6:	85 c0                	test   %eax,%eax
  8017f8:	78 2c                	js     801826 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017fa:	83 ec 08             	sub    $0x8,%esp
  8017fd:	68 00 50 80 00       	push   $0x805000
  801802:	53                   	push   %ebx
  801803:	e8 09 f0 ff ff       	call   800811 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801808:	a1 80 50 80 00       	mov    0x805080,%eax
  80180d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801813:	a1 84 50 80 00       	mov    0x805084,%eax
  801818:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80181e:	83 c4 10             	add    $0x10,%esp
  801821:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801826:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801829:	c9                   	leave  
  80182a:	c3                   	ret    

0080182b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
  80182e:	83 ec 0c             	sub    $0xc,%esp
  801831:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801834:	8b 55 08             	mov    0x8(%ebp),%edx
  801837:	8b 52 0c             	mov    0xc(%edx),%edx
  80183a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801840:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801845:	50                   	push   %eax
  801846:	ff 75 0c             	pushl  0xc(%ebp)
  801849:	68 08 50 80 00       	push   $0x805008
  80184e:	e8 50 f1 ff ff       	call   8009a3 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801853:	ba 00 00 00 00       	mov    $0x0,%edx
  801858:	b8 04 00 00 00       	mov    $0x4,%eax
  80185d:	e8 d9 fe ff ff       	call   80173b <fsipc>

}
  801862:	c9                   	leave  
  801863:	c3                   	ret    

00801864 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801864:	55                   	push   %ebp
  801865:	89 e5                	mov    %esp,%ebp
  801867:	56                   	push   %esi
  801868:	53                   	push   %ebx
  801869:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80186c:	8b 45 08             	mov    0x8(%ebp),%eax
  80186f:	8b 40 0c             	mov    0xc(%eax),%eax
  801872:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801877:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80187d:	ba 00 00 00 00       	mov    $0x0,%edx
  801882:	b8 03 00 00 00       	mov    $0x3,%eax
  801887:	e8 af fe ff ff       	call   80173b <fsipc>
  80188c:	89 c3                	mov    %eax,%ebx
  80188e:	85 c0                	test   %eax,%eax
  801890:	78 4b                	js     8018dd <devfile_read+0x79>
		return r;
	assert(r <= n);
  801892:	39 c6                	cmp    %eax,%esi
  801894:	73 16                	jae    8018ac <devfile_read+0x48>
  801896:	68 24 27 80 00       	push   $0x802724
  80189b:	68 2b 27 80 00       	push   $0x80272b
  8018a0:	6a 7c                	push   $0x7c
  8018a2:	68 40 27 80 00       	push   $0x802740
  8018a7:	e8 bd 05 00 00       	call   801e69 <_panic>
	assert(r <= PGSIZE);
  8018ac:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018b1:	7e 16                	jle    8018c9 <devfile_read+0x65>
  8018b3:	68 4b 27 80 00       	push   $0x80274b
  8018b8:	68 2b 27 80 00       	push   $0x80272b
  8018bd:	6a 7d                	push   $0x7d
  8018bf:	68 40 27 80 00       	push   $0x802740
  8018c4:	e8 a0 05 00 00       	call   801e69 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018c9:	83 ec 04             	sub    $0x4,%esp
  8018cc:	50                   	push   %eax
  8018cd:	68 00 50 80 00       	push   $0x805000
  8018d2:	ff 75 0c             	pushl  0xc(%ebp)
  8018d5:	e8 c9 f0 ff ff       	call   8009a3 <memmove>
	return r;
  8018da:	83 c4 10             	add    $0x10,%esp
}
  8018dd:	89 d8                	mov    %ebx,%eax
  8018df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e2:	5b                   	pop    %ebx
  8018e3:	5e                   	pop    %esi
  8018e4:	5d                   	pop    %ebp
  8018e5:	c3                   	ret    

008018e6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018e6:	55                   	push   %ebp
  8018e7:	89 e5                	mov    %esp,%ebp
  8018e9:	53                   	push   %ebx
  8018ea:	83 ec 20             	sub    $0x20,%esp
  8018ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018f0:	53                   	push   %ebx
  8018f1:	e8 e2 ee ff ff       	call   8007d8 <strlen>
  8018f6:	83 c4 10             	add    $0x10,%esp
  8018f9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018fe:	7f 67                	jg     801967 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801900:	83 ec 0c             	sub    $0xc,%esp
  801903:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801906:	50                   	push   %eax
  801907:	e8 a7 f8 ff ff       	call   8011b3 <fd_alloc>
  80190c:	83 c4 10             	add    $0x10,%esp
		return r;
  80190f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801911:	85 c0                	test   %eax,%eax
  801913:	78 57                	js     80196c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801915:	83 ec 08             	sub    $0x8,%esp
  801918:	53                   	push   %ebx
  801919:	68 00 50 80 00       	push   $0x805000
  80191e:	e8 ee ee ff ff       	call   800811 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801923:	8b 45 0c             	mov    0xc(%ebp),%eax
  801926:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80192b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80192e:	b8 01 00 00 00       	mov    $0x1,%eax
  801933:	e8 03 fe ff ff       	call   80173b <fsipc>
  801938:	89 c3                	mov    %eax,%ebx
  80193a:	83 c4 10             	add    $0x10,%esp
  80193d:	85 c0                	test   %eax,%eax
  80193f:	79 14                	jns    801955 <open+0x6f>
		fd_close(fd, 0);
  801941:	83 ec 08             	sub    $0x8,%esp
  801944:	6a 00                	push   $0x0
  801946:	ff 75 f4             	pushl  -0xc(%ebp)
  801949:	e8 5d f9 ff ff       	call   8012ab <fd_close>
		return r;
  80194e:	83 c4 10             	add    $0x10,%esp
  801951:	89 da                	mov    %ebx,%edx
  801953:	eb 17                	jmp    80196c <open+0x86>
	}

	return fd2num(fd);
  801955:	83 ec 0c             	sub    $0xc,%esp
  801958:	ff 75 f4             	pushl  -0xc(%ebp)
  80195b:	e8 2c f8 ff ff       	call   80118c <fd2num>
  801960:	89 c2                	mov    %eax,%edx
  801962:	83 c4 10             	add    $0x10,%esp
  801965:	eb 05                	jmp    80196c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801967:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80196c:	89 d0                	mov    %edx,%eax
  80196e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801971:	c9                   	leave  
  801972:	c3                   	ret    

00801973 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801979:	ba 00 00 00 00       	mov    $0x0,%edx
  80197e:	b8 08 00 00 00       	mov    $0x8,%eax
  801983:	e8 b3 fd ff ff       	call   80173b <fsipc>
}
  801988:	c9                   	leave  
  801989:	c3                   	ret    

0080198a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	56                   	push   %esi
  80198e:	53                   	push   %ebx
  80198f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801992:	83 ec 0c             	sub    $0xc,%esp
  801995:	ff 75 08             	pushl  0x8(%ebp)
  801998:	e8 ff f7 ff ff       	call   80119c <fd2data>
  80199d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80199f:	83 c4 08             	add    $0x8,%esp
  8019a2:	68 57 27 80 00       	push   $0x802757
  8019a7:	53                   	push   %ebx
  8019a8:	e8 64 ee ff ff       	call   800811 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019ad:	8b 46 04             	mov    0x4(%esi),%eax
  8019b0:	2b 06                	sub    (%esi),%eax
  8019b2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019b8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019bf:	00 00 00 
	stat->st_dev = &devpipe;
  8019c2:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  8019c9:	30 80 00 
	return 0;
}
  8019cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d4:	5b                   	pop    %ebx
  8019d5:	5e                   	pop    %esi
  8019d6:	5d                   	pop    %ebp
  8019d7:	c3                   	ret    

008019d8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	53                   	push   %ebx
  8019dc:	83 ec 0c             	sub    $0xc,%esp
  8019df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019e2:	53                   	push   %ebx
  8019e3:	6a 00                	push   $0x0
  8019e5:	e8 af f2 ff ff       	call   800c99 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019ea:	89 1c 24             	mov    %ebx,(%esp)
  8019ed:	e8 aa f7 ff ff       	call   80119c <fd2data>
  8019f2:	83 c4 08             	add    $0x8,%esp
  8019f5:	50                   	push   %eax
  8019f6:	6a 00                	push   $0x0
  8019f8:	e8 9c f2 ff ff       	call   800c99 <sys_page_unmap>
}
  8019fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a00:	c9                   	leave  
  801a01:	c3                   	ret    

00801a02 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a02:	55                   	push   %ebp
  801a03:	89 e5                	mov    %esp,%ebp
  801a05:	57                   	push   %edi
  801a06:	56                   	push   %esi
  801a07:	53                   	push   %ebx
  801a08:	83 ec 1c             	sub    $0x1c,%esp
  801a0b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a0e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a10:	a1 04 40 80 00       	mov    0x804004,%eax
  801a15:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a18:	83 ec 0c             	sub    $0xc,%esp
  801a1b:	ff 75 e0             	pushl  -0x20(%ebp)
  801a1e:	e8 f7 04 00 00       	call   801f1a <pageref>
  801a23:	89 c3                	mov    %eax,%ebx
  801a25:	89 3c 24             	mov    %edi,(%esp)
  801a28:	e8 ed 04 00 00       	call   801f1a <pageref>
  801a2d:	83 c4 10             	add    $0x10,%esp
  801a30:	39 c3                	cmp    %eax,%ebx
  801a32:	0f 94 c1             	sete   %cl
  801a35:	0f b6 c9             	movzbl %cl,%ecx
  801a38:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a3b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a41:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a44:	39 ce                	cmp    %ecx,%esi
  801a46:	74 1b                	je     801a63 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a48:	39 c3                	cmp    %eax,%ebx
  801a4a:	75 c4                	jne    801a10 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a4c:	8b 42 58             	mov    0x58(%edx),%eax
  801a4f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a52:	50                   	push   %eax
  801a53:	56                   	push   %esi
  801a54:	68 5e 27 80 00       	push   $0x80275e
  801a59:	e8 2e e8 ff ff       	call   80028c <cprintf>
  801a5e:	83 c4 10             	add    $0x10,%esp
  801a61:	eb ad                	jmp    801a10 <_pipeisclosed+0xe>
	}
}
  801a63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a69:	5b                   	pop    %ebx
  801a6a:	5e                   	pop    %esi
  801a6b:	5f                   	pop    %edi
  801a6c:	5d                   	pop    %ebp
  801a6d:	c3                   	ret    

00801a6e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	57                   	push   %edi
  801a72:	56                   	push   %esi
  801a73:	53                   	push   %ebx
  801a74:	83 ec 28             	sub    $0x28,%esp
  801a77:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a7a:	56                   	push   %esi
  801a7b:	e8 1c f7 ff ff       	call   80119c <fd2data>
  801a80:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a82:	83 c4 10             	add    $0x10,%esp
  801a85:	bf 00 00 00 00       	mov    $0x0,%edi
  801a8a:	eb 4b                	jmp    801ad7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a8c:	89 da                	mov    %ebx,%edx
  801a8e:	89 f0                	mov    %esi,%eax
  801a90:	e8 6d ff ff ff       	call   801a02 <_pipeisclosed>
  801a95:	85 c0                	test   %eax,%eax
  801a97:	75 48                	jne    801ae1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a99:	e8 57 f1 ff ff       	call   800bf5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a9e:	8b 43 04             	mov    0x4(%ebx),%eax
  801aa1:	8b 0b                	mov    (%ebx),%ecx
  801aa3:	8d 51 20             	lea    0x20(%ecx),%edx
  801aa6:	39 d0                	cmp    %edx,%eax
  801aa8:	73 e2                	jae    801a8c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801aaa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aad:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ab1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ab4:	89 c2                	mov    %eax,%edx
  801ab6:	c1 fa 1f             	sar    $0x1f,%edx
  801ab9:	89 d1                	mov    %edx,%ecx
  801abb:	c1 e9 1b             	shr    $0x1b,%ecx
  801abe:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ac1:	83 e2 1f             	and    $0x1f,%edx
  801ac4:	29 ca                	sub    %ecx,%edx
  801ac6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801aca:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ace:	83 c0 01             	add    $0x1,%eax
  801ad1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ad4:	83 c7 01             	add    $0x1,%edi
  801ad7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ada:	75 c2                	jne    801a9e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801adc:	8b 45 10             	mov    0x10(%ebp),%eax
  801adf:	eb 05                	jmp    801ae6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ae1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ae6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae9:	5b                   	pop    %ebx
  801aea:	5e                   	pop    %esi
  801aeb:	5f                   	pop    %edi
  801aec:	5d                   	pop    %ebp
  801aed:	c3                   	ret    

00801aee <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801aee:	55                   	push   %ebp
  801aef:	89 e5                	mov    %esp,%ebp
  801af1:	57                   	push   %edi
  801af2:	56                   	push   %esi
  801af3:	53                   	push   %ebx
  801af4:	83 ec 18             	sub    $0x18,%esp
  801af7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801afa:	57                   	push   %edi
  801afb:	e8 9c f6 ff ff       	call   80119c <fd2data>
  801b00:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b02:	83 c4 10             	add    $0x10,%esp
  801b05:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b0a:	eb 3d                	jmp    801b49 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b0c:	85 db                	test   %ebx,%ebx
  801b0e:	74 04                	je     801b14 <devpipe_read+0x26>
				return i;
  801b10:	89 d8                	mov    %ebx,%eax
  801b12:	eb 44                	jmp    801b58 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b14:	89 f2                	mov    %esi,%edx
  801b16:	89 f8                	mov    %edi,%eax
  801b18:	e8 e5 fe ff ff       	call   801a02 <_pipeisclosed>
  801b1d:	85 c0                	test   %eax,%eax
  801b1f:	75 32                	jne    801b53 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b21:	e8 cf f0 ff ff       	call   800bf5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b26:	8b 06                	mov    (%esi),%eax
  801b28:	3b 46 04             	cmp    0x4(%esi),%eax
  801b2b:	74 df                	je     801b0c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b2d:	99                   	cltd   
  801b2e:	c1 ea 1b             	shr    $0x1b,%edx
  801b31:	01 d0                	add    %edx,%eax
  801b33:	83 e0 1f             	and    $0x1f,%eax
  801b36:	29 d0                	sub    %edx,%eax
  801b38:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b40:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b43:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b46:	83 c3 01             	add    $0x1,%ebx
  801b49:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b4c:	75 d8                	jne    801b26 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b4e:	8b 45 10             	mov    0x10(%ebp),%eax
  801b51:	eb 05                	jmp    801b58 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b53:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b5b:	5b                   	pop    %ebx
  801b5c:	5e                   	pop    %esi
  801b5d:	5f                   	pop    %edi
  801b5e:	5d                   	pop    %ebp
  801b5f:	c3                   	ret    

00801b60 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	56                   	push   %esi
  801b64:	53                   	push   %ebx
  801b65:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b6b:	50                   	push   %eax
  801b6c:	e8 42 f6 ff ff       	call   8011b3 <fd_alloc>
  801b71:	83 c4 10             	add    $0x10,%esp
  801b74:	89 c2                	mov    %eax,%edx
  801b76:	85 c0                	test   %eax,%eax
  801b78:	0f 88 2c 01 00 00    	js     801caa <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b7e:	83 ec 04             	sub    $0x4,%esp
  801b81:	68 07 04 00 00       	push   $0x407
  801b86:	ff 75 f4             	pushl  -0xc(%ebp)
  801b89:	6a 00                	push   $0x0
  801b8b:	e8 84 f0 ff ff       	call   800c14 <sys_page_alloc>
  801b90:	83 c4 10             	add    $0x10,%esp
  801b93:	89 c2                	mov    %eax,%edx
  801b95:	85 c0                	test   %eax,%eax
  801b97:	0f 88 0d 01 00 00    	js     801caa <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b9d:	83 ec 0c             	sub    $0xc,%esp
  801ba0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ba3:	50                   	push   %eax
  801ba4:	e8 0a f6 ff ff       	call   8011b3 <fd_alloc>
  801ba9:	89 c3                	mov    %eax,%ebx
  801bab:	83 c4 10             	add    $0x10,%esp
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	0f 88 e2 00 00 00    	js     801c98 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb6:	83 ec 04             	sub    $0x4,%esp
  801bb9:	68 07 04 00 00       	push   $0x407
  801bbe:	ff 75 f0             	pushl  -0x10(%ebp)
  801bc1:	6a 00                	push   $0x0
  801bc3:	e8 4c f0 ff ff       	call   800c14 <sys_page_alloc>
  801bc8:	89 c3                	mov    %eax,%ebx
  801bca:	83 c4 10             	add    $0x10,%esp
  801bcd:	85 c0                	test   %eax,%eax
  801bcf:	0f 88 c3 00 00 00    	js     801c98 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bd5:	83 ec 0c             	sub    $0xc,%esp
  801bd8:	ff 75 f4             	pushl  -0xc(%ebp)
  801bdb:	e8 bc f5 ff ff       	call   80119c <fd2data>
  801be0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be2:	83 c4 0c             	add    $0xc,%esp
  801be5:	68 07 04 00 00       	push   $0x407
  801bea:	50                   	push   %eax
  801beb:	6a 00                	push   $0x0
  801bed:	e8 22 f0 ff ff       	call   800c14 <sys_page_alloc>
  801bf2:	89 c3                	mov    %eax,%ebx
  801bf4:	83 c4 10             	add    $0x10,%esp
  801bf7:	85 c0                	test   %eax,%eax
  801bf9:	0f 88 89 00 00 00    	js     801c88 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bff:	83 ec 0c             	sub    $0xc,%esp
  801c02:	ff 75 f0             	pushl  -0x10(%ebp)
  801c05:	e8 92 f5 ff ff       	call   80119c <fd2data>
  801c0a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c11:	50                   	push   %eax
  801c12:	6a 00                	push   $0x0
  801c14:	56                   	push   %esi
  801c15:	6a 00                	push   $0x0
  801c17:	e8 3b f0 ff ff       	call   800c57 <sys_page_map>
  801c1c:	89 c3                	mov    %eax,%ebx
  801c1e:	83 c4 20             	add    $0x20,%esp
  801c21:	85 c0                	test   %eax,%eax
  801c23:	78 55                	js     801c7a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c25:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c2e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c33:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c3a:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801c40:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c43:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c48:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c4f:	83 ec 0c             	sub    $0xc,%esp
  801c52:	ff 75 f4             	pushl  -0xc(%ebp)
  801c55:	e8 32 f5 ff ff       	call   80118c <fd2num>
  801c5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c5d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c5f:	83 c4 04             	add    $0x4,%esp
  801c62:	ff 75 f0             	pushl  -0x10(%ebp)
  801c65:	e8 22 f5 ff ff       	call   80118c <fd2num>
  801c6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c6d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c70:	83 c4 10             	add    $0x10,%esp
  801c73:	ba 00 00 00 00       	mov    $0x0,%edx
  801c78:	eb 30                	jmp    801caa <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c7a:	83 ec 08             	sub    $0x8,%esp
  801c7d:	56                   	push   %esi
  801c7e:	6a 00                	push   $0x0
  801c80:	e8 14 f0 ff ff       	call   800c99 <sys_page_unmap>
  801c85:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c88:	83 ec 08             	sub    $0x8,%esp
  801c8b:	ff 75 f0             	pushl  -0x10(%ebp)
  801c8e:	6a 00                	push   $0x0
  801c90:	e8 04 f0 ff ff       	call   800c99 <sys_page_unmap>
  801c95:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c98:	83 ec 08             	sub    $0x8,%esp
  801c9b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c9e:	6a 00                	push   $0x0
  801ca0:	e8 f4 ef ff ff       	call   800c99 <sys_page_unmap>
  801ca5:	83 c4 10             	add    $0x10,%esp
  801ca8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801caa:	89 d0                	mov    %edx,%eax
  801cac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801caf:	5b                   	pop    %ebx
  801cb0:	5e                   	pop    %esi
  801cb1:	5d                   	pop    %ebp
  801cb2:	c3                   	ret    

00801cb3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cb3:	55                   	push   %ebp
  801cb4:	89 e5                	mov    %esp,%ebp
  801cb6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbc:	50                   	push   %eax
  801cbd:	ff 75 08             	pushl  0x8(%ebp)
  801cc0:	e8 3d f5 ff ff       	call   801202 <fd_lookup>
  801cc5:	83 c4 10             	add    $0x10,%esp
  801cc8:	85 c0                	test   %eax,%eax
  801cca:	78 18                	js     801ce4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ccc:	83 ec 0c             	sub    $0xc,%esp
  801ccf:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd2:	e8 c5 f4 ff ff       	call   80119c <fd2data>
	return _pipeisclosed(fd, p);
  801cd7:	89 c2                	mov    %eax,%edx
  801cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cdc:	e8 21 fd ff ff       	call   801a02 <_pipeisclosed>
  801ce1:	83 c4 10             	add    $0x10,%esp
}
  801ce4:	c9                   	leave  
  801ce5:	c3                   	ret    

00801ce6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ce6:	55                   	push   %ebp
  801ce7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ce9:	b8 00 00 00 00       	mov    $0x0,%eax
  801cee:	5d                   	pop    %ebp
  801cef:	c3                   	ret    

00801cf0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cf0:	55                   	push   %ebp
  801cf1:	89 e5                	mov    %esp,%ebp
  801cf3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cf6:	68 76 27 80 00       	push   $0x802776
  801cfb:	ff 75 0c             	pushl  0xc(%ebp)
  801cfe:	e8 0e eb ff ff       	call   800811 <strcpy>
	return 0;
}
  801d03:	b8 00 00 00 00       	mov    $0x0,%eax
  801d08:	c9                   	leave  
  801d09:	c3                   	ret    

00801d0a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d0a:	55                   	push   %ebp
  801d0b:	89 e5                	mov    %esp,%ebp
  801d0d:	57                   	push   %edi
  801d0e:	56                   	push   %esi
  801d0f:	53                   	push   %ebx
  801d10:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d16:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d1b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d21:	eb 2d                	jmp    801d50 <devcons_write+0x46>
		m = n - tot;
  801d23:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d26:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d28:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d2b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d30:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d33:	83 ec 04             	sub    $0x4,%esp
  801d36:	53                   	push   %ebx
  801d37:	03 45 0c             	add    0xc(%ebp),%eax
  801d3a:	50                   	push   %eax
  801d3b:	57                   	push   %edi
  801d3c:	e8 62 ec ff ff       	call   8009a3 <memmove>
		sys_cputs(buf, m);
  801d41:	83 c4 08             	add    $0x8,%esp
  801d44:	53                   	push   %ebx
  801d45:	57                   	push   %edi
  801d46:	e8 0d ee ff ff       	call   800b58 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d4b:	01 de                	add    %ebx,%esi
  801d4d:	83 c4 10             	add    $0x10,%esp
  801d50:	89 f0                	mov    %esi,%eax
  801d52:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d55:	72 cc                	jb     801d23 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d5a:	5b                   	pop    %ebx
  801d5b:	5e                   	pop    %esi
  801d5c:	5f                   	pop    %edi
  801d5d:	5d                   	pop    %ebp
  801d5e:	c3                   	ret    

00801d5f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d5f:	55                   	push   %ebp
  801d60:	89 e5                	mov    %esp,%ebp
  801d62:	83 ec 08             	sub    $0x8,%esp
  801d65:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d6a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d6e:	74 2a                	je     801d9a <devcons_read+0x3b>
  801d70:	eb 05                	jmp    801d77 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d72:	e8 7e ee ff ff       	call   800bf5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d77:	e8 fa ed ff ff       	call   800b76 <sys_cgetc>
  801d7c:	85 c0                	test   %eax,%eax
  801d7e:	74 f2                	je     801d72 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d80:	85 c0                	test   %eax,%eax
  801d82:	78 16                	js     801d9a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d84:	83 f8 04             	cmp    $0x4,%eax
  801d87:	74 0c                	je     801d95 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d89:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d8c:	88 02                	mov    %al,(%edx)
	return 1;
  801d8e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d93:	eb 05                	jmp    801d9a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d95:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d9a:	c9                   	leave  
  801d9b:	c3                   	ret    

00801d9c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d9c:	55                   	push   %ebp
  801d9d:	89 e5                	mov    %esp,%ebp
  801d9f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801da2:	8b 45 08             	mov    0x8(%ebp),%eax
  801da5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801da8:	6a 01                	push   $0x1
  801daa:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dad:	50                   	push   %eax
  801dae:	e8 a5 ed ff ff       	call   800b58 <sys_cputs>
}
  801db3:	83 c4 10             	add    $0x10,%esp
  801db6:	c9                   	leave  
  801db7:	c3                   	ret    

00801db8 <getchar>:

int
getchar(void)
{
  801db8:	55                   	push   %ebp
  801db9:	89 e5                	mov    %esp,%ebp
  801dbb:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dbe:	6a 01                	push   $0x1
  801dc0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dc3:	50                   	push   %eax
  801dc4:	6a 00                	push   $0x0
  801dc6:	e8 9d f6 ff ff       	call   801468 <read>
	if (r < 0)
  801dcb:	83 c4 10             	add    $0x10,%esp
  801dce:	85 c0                	test   %eax,%eax
  801dd0:	78 0f                	js     801de1 <getchar+0x29>
		return r;
	if (r < 1)
  801dd2:	85 c0                	test   %eax,%eax
  801dd4:	7e 06                	jle    801ddc <getchar+0x24>
		return -E_EOF;
	return c;
  801dd6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801dda:	eb 05                	jmp    801de1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ddc:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801de1:	c9                   	leave  
  801de2:	c3                   	ret    

00801de3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801de3:	55                   	push   %ebp
  801de4:	89 e5                	mov    %esp,%ebp
  801de6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801de9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dec:	50                   	push   %eax
  801ded:	ff 75 08             	pushl  0x8(%ebp)
  801df0:	e8 0d f4 ff ff       	call   801202 <fd_lookup>
  801df5:	83 c4 10             	add    $0x10,%esp
  801df8:	85 c0                	test   %eax,%eax
  801dfa:	78 11                	js     801e0d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dff:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801e05:	39 10                	cmp    %edx,(%eax)
  801e07:	0f 94 c0             	sete   %al
  801e0a:	0f b6 c0             	movzbl %al,%eax
}
  801e0d:	c9                   	leave  
  801e0e:	c3                   	ret    

00801e0f <opencons>:

int
opencons(void)
{
  801e0f:	55                   	push   %ebp
  801e10:	89 e5                	mov    %esp,%ebp
  801e12:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e15:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e18:	50                   	push   %eax
  801e19:	e8 95 f3 ff ff       	call   8011b3 <fd_alloc>
  801e1e:	83 c4 10             	add    $0x10,%esp
		return r;
  801e21:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e23:	85 c0                	test   %eax,%eax
  801e25:	78 3e                	js     801e65 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e27:	83 ec 04             	sub    $0x4,%esp
  801e2a:	68 07 04 00 00       	push   $0x407
  801e2f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e32:	6a 00                	push   $0x0
  801e34:	e8 db ed ff ff       	call   800c14 <sys_page_alloc>
  801e39:	83 c4 10             	add    $0x10,%esp
		return r;
  801e3c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e3e:	85 c0                	test   %eax,%eax
  801e40:	78 23                	js     801e65 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e42:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e50:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e57:	83 ec 0c             	sub    $0xc,%esp
  801e5a:	50                   	push   %eax
  801e5b:	e8 2c f3 ff ff       	call   80118c <fd2num>
  801e60:	89 c2                	mov    %eax,%edx
  801e62:	83 c4 10             	add    $0x10,%esp
}
  801e65:	89 d0                	mov    %edx,%eax
  801e67:	c9                   	leave  
  801e68:	c3                   	ret    

00801e69 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e69:	55                   	push   %ebp
  801e6a:	89 e5                	mov    %esp,%ebp
  801e6c:	56                   	push   %esi
  801e6d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e6e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e71:	8b 35 08 30 80 00    	mov    0x803008,%esi
  801e77:	e8 5a ed ff ff       	call   800bd6 <sys_getenvid>
  801e7c:	83 ec 0c             	sub    $0xc,%esp
  801e7f:	ff 75 0c             	pushl  0xc(%ebp)
  801e82:	ff 75 08             	pushl  0x8(%ebp)
  801e85:	56                   	push   %esi
  801e86:	50                   	push   %eax
  801e87:	68 84 27 80 00       	push   $0x802784
  801e8c:	e8 fb e3 ff ff       	call   80028c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e91:	83 c4 18             	add    $0x18,%esp
  801e94:	53                   	push   %ebx
  801e95:	ff 75 10             	pushl  0x10(%ebp)
  801e98:	e8 9e e3 ff ff       	call   80023b <vcprintf>
	cprintf("\n");
  801e9d:	c7 04 24 6f 27 80 00 	movl   $0x80276f,(%esp)
  801ea4:	e8 e3 e3 ff ff       	call   80028c <cprintf>
  801ea9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801eac:	cc                   	int3   
  801ead:	eb fd                	jmp    801eac <_panic+0x43>

00801eaf <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801eaf:	55                   	push   %ebp
  801eb0:	89 e5                	mov    %esp,%ebp
  801eb2:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801eb5:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ebc:	75 2e                	jne    801eec <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801ebe:	e8 13 ed ff ff       	call   800bd6 <sys_getenvid>
  801ec3:	83 ec 04             	sub    $0x4,%esp
  801ec6:	68 07 0e 00 00       	push   $0xe07
  801ecb:	68 00 f0 bf ee       	push   $0xeebff000
  801ed0:	50                   	push   %eax
  801ed1:	e8 3e ed ff ff       	call   800c14 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801ed6:	e8 fb ec ff ff       	call   800bd6 <sys_getenvid>
  801edb:	83 c4 08             	add    $0x8,%esp
  801ede:	68 f6 1e 80 00       	push   $0x801ef6
  801ee3:	50                   	push   %eax
  801ee4:	e8 76 ee ff ff       	call   800d5f <sys_env_set_pgfault_upcall>
  801ee9:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801eec:	8b 45 08             	mov    0x8(%ebp),%eax
  801eef:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801ef4:	c9                   	leave  
  801ef5:	c3                   	ret    

00801ef6 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801ef6:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801ef7:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801efc:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801efe:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  801f01:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  801f05:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  801f09:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  801f0c:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  801f0f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  801f10:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  801f13:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  801f14:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  801f15:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801f19:	c3                   	ret    

00801f1a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f1a:	55                   	push   %ebp
  801f1b:	89 e5                	mov    %esp,%ebp
  801f1d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f20:	89 d0                	mov    %edx,%eax
  801f22:	c1 e8 16             	shr    $0x16,%eax
  801f25:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f2c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f31:	f6 c1 01             	test   $0x1,%cl
  801f34:	74 1d                	je     801f53 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f36:	c1 ea 0c             	shr    $0xc,%edx
  801f39:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f40:	f6 c2 01             	test   $0x1,%dl
  801f43:	74 0e                	je     801f53 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f45:	c1 ea 0c             	shr    $0xc,%edx
  801f48:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f4f:	ef 
  801f50:	0f b7 c0             	movzwl %ax,%eax
}
  801f53:	5d                   	pop    %ebp
  801f54:	c3                   	ret    
  801f55:	66 90                	xchg   %ax,%ax
  801f57:	66 90                	xchg   %ax,%ax
  801f59:	66 90                	xchg   %ax,%ax
  801f5b:	66 90                	xchg   %ax,%ax
  801f5d:	66 90                	xchg   %ax,%ax
  801f5f:	90                   	nop

00801f60 <__udivdi3>:
  801f60:	55                   	push   %ebp
  801f61:	57                   	push   %edi
  801f62:	56                   	push   %esi
  801f63:	53                   	push   %ebx
  801f64:	83 ec 1c             	sub    $0x1c,%esp
  801f67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f77:	85 f6                	test   %esi,%esi
  801f79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f7d:	89 ca                	mov    %ecx,%edx
  801f7f:	89 f8                	mov    %edi,%eax
  801f81:	75 3d                	jne    801fc0 <__udivdi3+0x60>
  801f83:	39 cf                	cmp    %ecx,%edi
  801f85:	0f 87 c5 00 00 00    	ja     802050 <__udivdi3+0xf0>
  801f8b:	85 ff                	test   %edi,%edi
  801f8d:	89 fd                	mov    %edi,%ebp
  801f8f:	75 0b                	jne    801f9c <__udivdi3+0x3c>
  801f91:	b8 01 00 00 00       	mov    $0x1,%eax
  801f96:	31 d2                	xor    %edx,%edx
  801f98:	f7 f7                	div    %edi
  801f9a:	89 c5                	mov    %eax,%ebp
  801f9c:	89 c8                	mov    %ecx,%eax
  801f9e:	31 d2                	xor    %edx,%edx
  801fa0:	f7 f5                	div    %ebp
  801fa2:	89 c1                	mov    %eax,%ecx
  801fa4:	89 d8                	mov    %ebx,%eax
  801fa6:	89 cf                	mov    %ecx,%edi
  801fa8:	f7 f5                	div    %ebp
  801faa:	89 c3                	mov    %eax,%ebx
  801fac:	89 d8                	mov    %ebx,%eax
  801fae:	89 fa                	mov    %edi,%edx
  801fb0:	83 c4 1c             	add    $0x1c,%esp
  801fb3:	5b                   	pop    %ebx
  801fb4:	5e                   	pop    %esi
  801fb5:	5f                   	pop    %edi
  801fb6:	5d                   	pop    %ebp
  801fb7:	c3                   	ret    
  801fb8:	90                   	nop
  801fb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fc0:	39 ce                	cmp    %ecx,%esi
  801fc2:	77 74                	ja     802038 <__udivdi3+0xd8>
  801fc4:	0f bd fe             	bsr    %esi,%edi
  801fc7:	83 f7 1f             	xor    $0x1f,%edi
  801fca:	0f 84 98 00 00 00    	je     802068 <__udivdi3+0x108>
  801fd0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fd5:	89 f9                	mov    %edi,%ecx
  801fd7:	89 c5                	mov    %eax,%ebp
  801fd9:	29 fb                	sub    %edi,%ebx
  801fdb:	d3 e6                	shl    %cl,%esi
  801fdd:	89 d9                	mov    %ebx,%ecx
  801fdf:	d3 ed                	shr    %cl,%ebp
  801fe1:	89 f9                	mov    %edi,%ecx
  801fe3:	d3 e0                	shl    %cl,%eax
  801fe5:	09 ee                	or     %ebp,%esi
  801fe7:	89 d9                	mov    %ebx,%ecx
  801fe9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fed:	89 d5                	mov    %edx,%ebp
  801fef:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ff3:	d3 ed                	shr    %cl,%ebp
  801ff5:	89 f9                	mov    %edi,%ecx
  801ff7:	d3 e2                	shl    %cl,%edx
  801ff9:	89 d9                	mov    %ebx,%ecx
  801ffb:	d3 e8                	shr    %cl,%eax
  801ffd:	09 c2                	or     %eax,%edx
  801fff:	89 d0                	mov    %edx,%eax
  802001:	89 ea                	mov    %ebp,%edx
  802003:	f7 f6                	div    %esi
  802005:	89 d5                	mov    %edx,%ebp
  802007:	89 c3                	mov    %eax,%ebx
  802009:	f7 64 24 0c          	mull   0xc(%esp)
  80200d:	39 d5                	cmp    %edx,%ebp
  80200f:	72 10                	jb     802021 <__udivdi3+0xc1>
  802011:	8b 74 24 08          	mov    0x8(%esp),%esi
  802015:	89 f9                	mov    %edi,%ecx
  802017:	d3 e6                	shl    %cl,%esi
  802019:	39 c6                	cmp    %eax,%esi
  80201b:	73 07                	jae    802024 <__udivdi3+0xc4>
  80201d:	39 d5                	cmp    %edx,%ebp
  80201f:	75 03                	jne    802024 <__udivdi3+0xc4>
  802021:	83 eb 01             	sub    $0x1,%ebx
  802024:	31 ff                	xor    %edi,%edi
  802026:	89 d8                	mov    %ebx,%eax
  802028:	89 fa                	mov    %edi,%edx
  80202a:	83 c4 1c             	add    $0x1c,%esp
  80202d:	5b                   	pop    %ebx
  80202e:	5e                   	pop    %esi
  80202f:	5f                   	pop    %edi
  802030:	5d                   	pop    %ebp
  802031:	c3                   	ret    
  802032:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802038:	31 ff                	xor    %edi,%edi
  80203a:	31 db                	xor    %ebx,%ebx
  80203c:	89 d8                	mov    %ebx,%eax
  80203e:	89 fa                	mov    %edi,%edx
  802040:	83 c4 1c             	add    $0x1c,%esp
  802043:	5b                   	pop    %ebx
  802044:	5e                   	pop    %esi
  802045:	5f                   	pop    %edi
  802046:	5d                   	pop    %ebp
  802047:	c3                   	ret    
  802048:	90                   	nop
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	89 d8                	mov    %ebx,%eax
  802052:	f7 f7                	div    %edi
  802054:	31 ff                	xor    %edi,%edi
  802056:	89 c3                	mov    %eax,%ebx
  802058:	89 d8                	mov    %ebx,%eax
  80205a:	89 fa                	mov    %edi,%edx
  80205c:	83 c4 1c             	add    $0x1c,%esp
  80205f:	5b                   	pop    %ebx
  802060:	5e                   	pop    %esi
  802061:	5f                   	pop    %edi
  802062:	5d                   	pop    %ebp
  802063:	c3                   	ret    
  802064:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802068:	39 ce                	cmp    %ecx,%esi
  80206a:	72 0c                	jb     802078 <__udivdi3+0x118>
  80206c:	31 db                	xor    %ebx,%ebx
  80206e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802072:	0f 87 34 ff ff ff    	ja     801fac <__udivdi3+0x4c>
  802078:	bb 01 00 00 00       	mov    $0x1,%ebx
  80207d:	e9 2a ff ff ff       	jmp    801fac <__udivdi3+0x4c>
  802082:	66 90                	xchg   %ax,%ax
  802084:	66 90                	xchg   %ax,%ax
  802086:	66 90                	xchg   %ax,%ax
  802088:	66 90                	xchg   %ax,%ax
  80208a:	66 90                	xchg   %ax,%ax
  80208c:	66 90                	xchg   %ax,%ax
  80208e:	66 90                	xchg   %ax,%ax

00802090 <__umoddi3>:
  802090:	55                   	push   %ebp
  802091:	57                   	push   %edi
  802092:	56                   	push   %esi
  802093:	53                   	push   %ebx
  802094:	83 ec 1c             	sub    $0x1c,%esp
  802097:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80209b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80209f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020a7:	85 d2                	test   %edx,%edx
  8020a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020b1:	89 f3                	mov    %esi,%ebx
  8020b3:	89 3c 24             	mov    %edi,(%esp)
  8020b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ba:	75 1c                	jne    8020d8 <__umoddi3+0x48>
  8020bc:	39 f7                	cmp    %esi,%edi
  8020be:	76 50                	jbe    802110 <__umoddi3+0x80>
  8020c0:	89 c8                	mov    %ecx,%eax
  8020c2:	89 f2                	mov    %esi,%edx
  8020c4:	f7 f7                	div    %edi
  8020c6:	89 d0                	mov    %edx,%eax
  8020c8:	31 d2                	xor    %edx,%edx
  8020ca:	83 c4 1c             	add    $0x1c,%esp
  8020cd:	5b                   	pop    %ebx
  8020ce:	5e                   	pop    %esi
  8020cf:	5f                   	pop    %edi
  8020d0:	5d                   	pop    %ebp
  8020d1:	c3                   	ret    
  8020d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020d8:	39 f2                	cmp    %esi,%edx
  8020da:	89 d0                	mov    %edx,%eax
  8020dc:	77 52                	ja     802130 <__umoddi3+0xa0>
  8020de:	0f bd ea             	bsr    %edx,%ebp
  8020e1:	83 f5 1f             	xor    $0x1f,%ebp
  8020e4:	75 5a                	jne    802140 <__umoddi3+0xb0>
  8020e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020ea:	0f 82 e0 00 00 00    	jb     8021d0 <__umoddi3+0x140>
  8020f0:	39 0c 24             	cmp    %ecx,(%esp)
  8020f3:	0f 86 d7 00 00 00    	jbe    8021d0 <__umoddi3+0x140>
  8020f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802101:	83 c4 1c             	add    $0x1c,%esp
  802104:	5b                   	pop    %ebx
  802105:	5e                   	pop    %esi
  802106:	5f                   	pop    %edi
  802107:	5d                   	pop    %ebp
  802108:	c3                   	ret    
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	85 ff                	test   %edi,%edi
  802112:	89 fd                	mov    %edi,%ebp
  802114:	75 0b                	jne    802121 <__umoddi3+0x91>
  802116:	b8 01 00 00 00       	mov    $0x1,%eax
  80211b:	31 d2                	xor    %edx,%edx
  80211d:	f7 f7                	div    %edi
  80211f:	89 c5                	mov    %eax,%ebp
  802121:	89 f0                	mov    %esi,%eax
  802123:	31 d2                	xor    %edx,%edx
  802125:	f7 f5                	div    %ebp
  802127:	89 c8                	mov    %ecx,%eax
  802129:	f7 f5                	div    %ebp
  80212b:	89 d0                	mov    %edx,%eax
  80212d:	eb 99                	jmp    8020c8 <__umoddi3+0x38>
  80212f:	90                   	nop
  802130:	89 c8                	mov    %ecx,%eax
  802132:	89 f2                	mov    %esi,%edx
  802134:	83 c4 1c             	add    $0x1c,%esp
  802137:	5b                   	pop    %ebx
  802138:	5e                   	pop    %esi
  802139:	5f                   	pop    %edi
  80213a:	5d                   	pop    %ebp
  80213b:	c3                   	ret    
  80213c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802140:	8b 34 24             	mov    (%esp),%esi
  802143:	bf 20 00 00 00       	mov    $0x20,%edi
  802148:	89 e9                	mov    %ebp,%ecx
  80214a:	29 ef                	sub    %ebp,%edi
  80214c:	d3 e0                	shl    %cl,%eax
  80214e:	89 f9                	mov    %edi,%ecx
  802150:	89 f2                	mov    %esi,%edx
  802152:	d3 ea                	shr    %cl,%edx
  802154:	89 e9                	mov    %ebp,%ecx
  802156:	09 c2                	or     %eax,%edx
  802158:	89 d8                	mov    %ebx,%eax
  80215a:	89 14 24             	mov    %edx,(%esp)
  80215d:	89 f2                	mov    %esi,%edx
  80215f:	d3 e2                	shl    %cl,%edx
  802161:	89 f9                	mov    %edi,%ecx
  802163:	89 54 24 04          	mov    %edx,0x4(%esp)
  802167:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80216b:	d3 e8                	shr    %cl,%eax
  80216d:	89 e9                	mov    %ebp,%ecx
  80216f:	89 c6                	mov    %eax,%esi
  802171:	d3 e3                	shl    %cl,%ebx
  802173:	89 f9                	mov    %edi,%ecx
  802175:	89 d0                	mov    %edx,%eax
  802177:	d3 e8                	shr    %cl,%eax
  802179:	89 e9                	mov    %ebp,%ecx
  80217b:	09 d8                	or     %ebx,%eax
  80217d:	89 d3                	mov    %edx,%ebx
  80217f:	89 f2                	mov    %esi,%edx
  802181:	f7 34 24             	divl   (%esp)
  802184:	89 d6                	mov    %edx,%esi
  802186:	d3 e3                	shl    %cl,%ebx
  802188:	f7 64 24 04          	mull   0x4(%esp)
  80218c:	39 d6                	cmp    %edx,%esi
  80218e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802192:	89 d1                	mov    %edx,%ecx
  802194:	89 c3                	mov    %eax,%ebx
  802196:	72 08                	jb     8021a0 <__umoddi3+0x110>
  802198:	75 11                	jne    8021ab <__umoddi3+0x11b>
  80219a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80219e:	73 0b                	jae    8021ab <__umoddi3+0x11b>
  8021a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021a4:	1b 14 24             	sbb    (%esp),%edx
  8021a7:	89 d1                	mov    %edx,%ecx
  8021a9:	89 c3                	mov    %eax,%ebx
  8021ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021af:	29 da                	sub    %ebx,%edx
  8021b1:	19 ce                	sbb    %ecx,%esi
  8021b3:	89 f9                	mov    %edi,%ecx
  8021b5:	89 f0                	mov    %esi,%eax
  8021b7:	d3 e0                	shl    %cl,%eax
  8021b9:	89 e9                	mov    %ebp,%ecx
  8021bb:	d3 ea                	shr    %cl,%edx
  8021bd:	89 e9                	mov    %ebp,%ecx
  8021bf:	d3 ee                	shr    %cl,%esi
  8021c1:	09 d0                	or     %edx,%eax
  8021c3:	89 f2                	mov    %esi,%edx
  8021c5:	83 c4 1c             	add    $0x1c,%esp
  8021c8:	5b                   	pop    %ebx
  8021c9:	5e                   	pop    %esi
  8021ca:	5f                   	pop    %edi
  8021cb:	5d                   	pop    %ebp
  8021cc:	c3                   	ret    
  8021cd:	8d 76 00             	lea    0x0(%esi),%esi
  8021d0:	29 f9                	sub    %edi,%ecx
  8021d2:	19 d6                	sbb    %edx,%esi
  8021d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021dc:	e9 18 ff ff ff       	jmp    8020f9 <__umoddi3+0x69>
