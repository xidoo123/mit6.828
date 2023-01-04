
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
  800057:	e8 03 10 00 00       	call   80105f <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 c0 21 80 00       	push   $0x8021c0
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
  80009d:	68 d4 21 80 00       	push   $0x8021d4
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
  8000db:	e8 e6 0f 00 00       	call   8010c6 <ipc_send>
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
  800131:	e8 90 0f 00 00       	call   8010c6 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 16 0f 00 00       	call   80105f <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 c0 21 80 00       	push   $0x8021c0
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
  80018a:	68 f4 21 80 00       	push   $0x8021f4
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
  8001e5:	e8 34 11 00 00       	call   80131e <close_all>
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
  8002ef:	e8 2c 1c 00 00       	call   801f20 <__udivdi3>
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
  800332:	e8 19 1d 00 00       	call   802050 <__umoddi3>
  800337:	83 c4 14             	add    $0x14,%esp
  80033a:	0f be 80 6c 22 80 00 	movsbl 0x80226c(%eax),%eax
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
  800436:	ff 24 85 a0 23 80 00 	jmp    *0x8023a0(,%eax,4)
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
  8004fa:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  800501:	85 d2                	test   %edx,%edx
  800503:	75 18                	jne    80051d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800505:	50                   	push   %eax
  800506:	68 84 22 80 00       	push   $0x802284
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
  80051e:	68 fd 26 80 00       	push   $0x8026fd
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
  800542:	b8 7d 22 80 00       	mov    $0x80227d,%eax
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
  800bbd:	68 5f 25 80 00       	push   $0x80255f
  800bc2:	6a 23                	push   $0x23
  800bc4:	68 7c 25 80 00       	push   $0x80257c
  800bc9:	e8 62 12 00 00       	call   801e30 <_panic>

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
  800c3e:	68 5f 25 80 00       	push   $0x80255f
  800c43:	6a 23                	push   $0x23
  800c45:	68 7c 25 80 00       	push   $0x80257c
  800c4a:	e8 e1 11 00 00       	call   801e30 <_panic>

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
  800c80:	68 5f 25 80 00       	push   $0x80255f
  800c85:	6a 23                	push   $0x23
  800c87:	68 7c 25 80 00       	push   $0x80257c
  800c8c:	e8 9f 11 00 00       	call   801e30 <_panic>

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
  800cc2:	68 5f 25 80 00       	push   $0x80255f
  800cc7:	6a 23                	push   $0x23
  800cc9:	68 7c 25 80 00       	push   $0x80257c
  800cce:	e8 5d 11 00 00       	call   801e30 <_panic>

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
  800d04:	68 5f 25 80 00       	push   $0x80255f
  800d09:	6a 23                	push   $0x23
  800d0b:	68 7c 25 80 00       	push   $0x80257c
  800d10:	e8 1b 11 00 00       	call   801e30 <_panic>

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
  800d46:	68 5f 25 80 00       	push   $0x80255f
  800d4b:	6a 23                	push   $0x23
  800d4d:	68 7c 25 80 00       	push   $0x80257c
  800d52:	e8 d9 10 00 00       	call   801e30 <_panic>

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
  800d88:	68 5f 25 80 00       	push   $0x80255f
  800d8d:	6a 23                	push   $0x23
  800d8f:	68 7c 25 80 00       	push   $0x80257c
  800d94:	e8 97 10 00 00       	call   801e30 <_panic>

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
  800dec:	68 5f 25 80 00       	push   $0x80255f
  800df1:	6a 23                	push   $0x23
  800df3:	68 7c 25 80 00       	push   $0x80257c
  800df8:	e8 33 10 00 00       	call   801e30 <_panic>

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
  800e29:	68 8c 25 80 00       	push   $0x80258c
  800e2e:	6a 1e                	push   $0x1e
  800e30:	68 20 26 80 00       	push   $0x802620
  800e35:	e8 f6 0f 00 00       	call   801e30 <_panic>

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
  800e5f:	68 b8 25 80 00       	push   $0x8025b8
  800e64:	6a 31                	push   $0x31
  800e66:	68 20 26 80 00       	push   $0x802620
  800e6b:	e8 c0 0f 00 00       	call   801e30 <_panic>
	
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
  800e9f:	68 dc 25 80 00       	push   $0x8025dc
  800ea4:	6a 39                	push   $0x39
  800ea6:	68 20 26 80 00       	push   $0x802620
  800eab:	e8 80 0f 00 00       	call   801e30 <_panic>

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
  800ec6:	68 00 26 80 00       	push   $0x802600
  800ecb:	6a 3e                	push   $0x3e
  800ecd:	68 20 26 80 00       	push   $0x802620
  800ed2:	e8 59 0f 00 00       	call   801e30 <_panic>
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
  800eec:	e8 85 0f 00 00       	call   801e76 <set_pgfault_handler>
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
  800efd:	0f 88 3a 01 00 00    	js     80103d <fork+0x15f>
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
  800f28:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2d:	e9 0b 01 00 00       	jmp    80103d <fork+0x15f>
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
  800f45:	0f 84 99 00 00 00    	je     800fe4 <fork+0x106>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800f4b:	89 d8                	mov    %ebx,%eax
  800f4d:	c1 e8 0c             	shr    $0xc,%eax
  800f50:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f57:	f6 c2 01             	test   $0x1,%dl
  800f5a:	0f 84 84 00 00 00    	je     800fe4 <fork+0x106>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
  800f60:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f67:	a9 02 08 00 00       	test   $0x802,%eax
  800f6c:	74 76                	je     800fe4 <fork+0x106>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;
	
	if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f6e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f75:	a8 02                	test   $0x2,%al
  800f77:	75 0c                	jne    800f85 <fork+0xa7>
  800f79:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f80:	f6 c4 08             	test   $0x8,%ah
  800f83:	74 3f                	je     800fc4 <fork+0xe6>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f85:	83 ec 0c             	sub    $0xc,%esp
  800f88:	68 05 08 00 00       	push   $0x805
  800f8d:	53                   	push   %ebx
  800f8e:	57                   	push   %edi
  800f8f:	53                   	push   %ebx
  800f90:	6a 00                	push   $0x0
  800f92:	e8 c0 fc ff ff       	call   800c57 <sys_page_map>
		if (r < 0)
  800f97:	83 c4 20             	add    $0x20,%esp
  800f9a:	85 c0                	test   %eax,%eax
  800f9c:	0f 88 9b 00 00 00    	js     80103d <fork+0x15f>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800fa2:	83 ec 0c             	sub    $0xc,%esp
  800fa5:	68 05 08 00 00       	push   $0x805
  800faa:	53                   	push   %ebx
  800fab:	6a 00                	push   $0x0
  800fad:	53                   	push   %ebx
  800fae:	6a 00                	push   $0x0
  800fb0:	e8 a2 fc ff ff       	call   800c57 <sys_page_map>
  800fb5:	83 c4 20             	add    $0x20,%esp
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fbf:	0f 4f c1             	cmovg  %ecx,%eax
  800fc2:	eb 1c                	jmp    800fe0 <fork+0x102>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800fc4:	83 ec 0c             	sub    $0xc,%esp
  800fc7:	6a 05                	push   $0x5
  800fc9:	53                   	push   %ebx
  800fca:	57                   	push   %edi
  800fcb:	53                   	push   %ebx
  800fcc:	6a 00                	push   $0x0
  800fce:	e8 84 fc ff ff       	call   800c57 <sys_page_map>
  800fd3:	83 c4 20             	add    $0x20,%esp
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fdd:	0f 4f c1             	cmovg  %ecx,%eax
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  800fe0:	85 c0                	test   %eax,%eax
  800fe2:	78 59                	js     80103d <fork+0x15f>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  800fe4:	83 c6 01             	add    $0x1,%esi
  800fe7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fed:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  800ff3:	0f 85 3e ff ff ff    	jne    800f37 <fork+0x59>
  800ff9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  800ffc:	83 ec 04             	sub    $0x4,%esp
  800fff:	6a 07                	push   $0x7
  801001:	68 00 f0 bf ee       	push   $0xeebff000
  801006:	57                   	push   %edi
  801007:	e8 08 fc ff ff       	call   800c14 <sys_page_alloc>
	if (r < 0)
  80100c:	83 c4 10             	add    $0x10,%esp
  80100f:	85 c0                	test   %eax,%eax
  801011:	78 2a                	js     80103d <fork+0x15f>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801013:	83 ec 08             	sub    $0x8,%esp
  801016:	68 bd 1e 80 00       	push   $0x801ebd
  80101b:	57                   	push   %edi
  80101c:	e8 3e fd ff ff       	call   800d5f <sys_env_set_pgfault_upcall>
	if (r < 0)
  801021:	83 c4 10             	add    $0x10,%esp
  801024:	85 c0                	test   %eax,%eax
  801026:	78 15                	js     80103d <fork+0x15f>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801028:	83 ec 08             	sub    $0x8,%esp
  80102b:	6a 02                	push   $0x2
  80102d:	57                   	push   %edi
  80102e:	e8 a8 fc ff ff       	call   800cdb <sys_env_set_status>
	if (r < 0)
  801033:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801036:	85 c0                	test   %eax,%eax
  801038:	0f 49 c7             	cmovns %edi,%eax
  80103b:	eb 00                	jmp    80103d <fork+0x15f>
	// panic("fork not implemented");
}
  80103d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801040:	5b                   	pop    %ebx
  801041:	5e                   	pop    %esi
  801042:	5f                   	pop    %edi
  801043:	5d                   	pop    %ebp
  801044:	c3                   	ret    

00801045 <sfork>:

// Challenge!
int
sfork(void)
{
  801045:	55                   	push   %ebp
  801046:	89 e5                	mov    %esp,%ebp
  801048:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80104b:	68 2b 26 80 00       	push   $0x80262b
  801050:	68 c3 00 00 00       	push   $0xc3
  801055:	68 20 26 80 00       	push   $0x802620
  80105a:	e8 d1 0d 00 00       	call   801e30 <_panic>

0080105f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80105f:	55                   	push   %ebp
  801060:	89 e5                	mov    %esp,%ebp
  801062:	56                   	push   %esi
  801063:	53                   	push   %ebx
  801064:	8b 75 08             	mov    0x8(%ebp),%esi
  801067:	8b 45 0c             	mov    0xc(%ebp),%eax
  80106a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  80106d:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  80106f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801074:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801077:	83 ec 0c             	sub    $0xc,%esp
  80107a:	50                   	push   %eax
  80107b:	e8 44 fd ff ff       	call   800dc4 <sys_ipc_recv>

	if (from_env_store != NULL)
  801080:	83 c4 10             	add    $0x10,%esp
  801083:	85 f6                	test   %esi,%esi
  801085:	74 14                	je     80109b <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801087:	ba 00 00 00 00       	mov    $0x0,%edx
  80108c:	85 c0                	test   %eax,%eax
  80108e:	78 09                	js     801099 <ipc_recv+0x3a>
  801090:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801096:	8b 52 74             	mov    0x74(%edx),%edx
  801099:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  80109b:	85 db                	test   %ebx,%ebx
  80109d:	74 14                	je     8010b3 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  80109f:	ba 00 00 00 00       	mov    $0x0,%edx
  8010a4:	85 c0                	test   %eax,%eax
  8010a6:	78 09                	js     8010b1 <ipc_recv+0x52>
  8010a8:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8010ae:	8b 52 78             	mov    0x78(%edx),%edx
  8010b1:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	78 08                	js     8010bf <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8010b7:	a1 04 40 80 00       	mov    0x804004,%eax
  8010bc:	8b 40 70             	mov    0x70(%eax),%eax
}
  8010bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010c2:	5b                   	pop    %ebx
  8010c3:	5e                   	pop    %esi
  8010c4:	5d                   	pop    %ebp
  8010c5:	c3                   	ret    

008010c6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010c6:	55                   	push   %ebp
  8010c7:	89 e5                	mov    %esp,%ebp
  8010c9:	57                   	push   %edi
  8010ca:	56                   	push   %esi
  8010cb:	53                   	push   %ebx
  8010cc:	83 ec 0c             	sub    $0xc,%esp
  8010cf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010d2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8010d8:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8010da:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8010df:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8010e2:	ff 75 14             	pushl  0x14(%ebp)
  8010e5:	53                   	push   %ebx
  8010e6:	56                   	push   %esi
  8010e7:	57                   	push   %edi
  8010e8:	e8 b4 fc ff ff       	call   800da1 <sys_ipc_try_send>

		if (err < 0) {
  8010ed:	83 c4 10             	add    $0x10,%esp
  8010f0:	85 c0                	test   %eax,%eax
  8010f2:	79 1e                	jns    801112 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8010f4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8010f7:	75 07                	jne    801100 <ipc_send+0x3a>
				sys_yield();
  8010f9:	e8 f7 fa ff ff       	call   800bf5 <sys_yield>
  8010fe:	eb e2                	jmp    8010e2 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801100:	50                   	push   %eax
  801101:	68 41 26 80 00       	push   $0x802641
  801106:	6a 49                	push   $0x49
  801108:	68 4e 26 80 00       	push   $0x80264e
  80110d:	e8 1e 0d 00 00       	call   801e30 <_panic>
		}

	} while (err < 0);

}
  801112:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801115:	5b                   	pop    %ebx
  801116:	5e                   	pop    %esi
  801117:	5f                   	pop    %edi
  801118:	5d                   	pop    %ebp
  801119:	c3                   	ret    

0080111a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801120:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801125:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801128:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80112e:	8b 52 50             	mov    0x50(%edx),%edx
  801131:	39 ca                	cmp    %ecx,%edx
  801133:	75 0d                	jne    801142 <ipc_find_env+0x28>
			return envs[i].env_id;
  801135:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801138:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80113d:	8b 40 48             	mov    0x48(%eax),%eax
  801140:	eb 0f                	jmp    801151 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801142:	83 c0 01             	add    $0x1,%eax
  801145:	3d 00 04 00 00       	cmp    $0x400,%eax
  80114a:	75 d9                	jne    801125 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80114c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801151:	5d                   	pop    %ebp
  801152:	c3                   	ret    

00801153 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801156:	8b 45 08             	mov    0x8(%ebp),%eax
  801159:	05 00 00 00 30       	add    $0x30000000,%eax
  80115e:	c1 e8 0c             	shr    $0xc,%eax
}
  801161:	5d                   	pop    %ebp
  801162:	c3                   	ret    

00801163 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801163:	55                   	push   %ebp
  801164:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801166:	8b 45 08             	mov    0x8(%ebp),%eax
  801169:	05 00 00 00 30       	add    $0x30000000,%eax
  80116e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801173:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801178:	5d                   	pop    %ebp
  801179:	c3                   	ret    

0080117a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
  80117d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801180:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801185:	89 c2                	mov    %eax,%edx
  801187:	c1 ea 16             	shr    $0x16,%edx
  80118a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801191:	f6 c2 01             	test   $0x1,%dl
  801194:	74 11                	je     8011a7 <fd_alloc+0x2d>
  801196:	89 c2                	mov    %eax,%edx
  801198:	c1 ea 0c             	shr    $0xc,%edx
  80119b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011a2:	f6 c2 01             	test   $0x1,%dl
  8011a5:	75 09                	jne    8011b0 <fd_alloc+0x36>
			*fd_store = fd;
  8011a7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ae:	eb 17                	jmp    8011c7 <fd_alloc+0x4d>
  8011b0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011b5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011ba:	75 c9                	jne    801185 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011bc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011c2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011c7:	5d                   	pop    %ebp
  8011c8:	c3                   	ret    

008011c9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011c9:	55                   	push   %ebp
  8011ca:	89 e5                	mov    %esp,%ebp
  8011cc:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011cf:	83 f8 1f             	cmp    $0x1f,%eax
  8011d2:	77 36                	ja     80120a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011d4:	c1 e0 0c             	shl    $0xc,%eax
  8011d7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011dc:	89 c2                	mov    %eax,%edx
  8011de:	c1 ea 16             	shr    $0x16,%edx
  8011e1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011e8:	f6 c2 01             	test   $0x1,%dl
  8011eb:	74 24                	je     801211 <fd_lookup+0x48>
  8011ed:	89 c2                	mov    %eax,%edx
  8011ef:	c1 ea 0c             	shr    $0xc,%edx
  8011f2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f9:	f6 c2 01             	test   $0x1,%dl
  8011fc:	74 1a                	je     801218 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801201:	89 02                	mov    %eax,(%edx)
	return 0;
  801203:	b8 00 00 00 00       	mov    $0x0,%eax
  801208:	eb 13                	jmp    80121d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80120a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80120f:	eb 0c                	jmp    80121d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801211:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801216:	eb 05                	jmp    80121d <fd_lookup+0x54>
  801218:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80121d:	5d                   	pop    %ebp
  80121e:	c3                   	ret    

0080121f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	83 ec 08             	sub    $0x8,%esp
  801225:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801228:	ba d4 26 80 00       	mov    $0x8026d4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80122d:	eb 13                	jmp    801242 <dev_lookup+0x23>
  80122f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801232:	39 08                	cmp    %ecx,(%eax)
  801234:	75 0c                	jne    801242 <dev_lookup+0x23>
			*dev = devtab[i];
  801236:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801239:	89 01                	mov    %eax,(%ecx)
			return 0;
  80123b:	b8 00 00 00 00       	mov    $0x0,%eax
  801240:	eb 2e                	jmp    801270 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801242:	8b 02                	mov    (%edx),%eax
  801244:	85 c0                	test   %eax,%eax
  801246:	75 e7                	jne    80122f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801248:	a1 04 40 80 00       	mov    0x804004,%eax
  80124d:	8b 40 48             	mov    0x48(%eax),%eax
  801250:	83 ec 04             	sub    $0x4,%esp
  801253:	51                   	push   %ecx
  801254:	50                   	push   %eax
  801255:	68 58 26 80 00       	push   $0x802658
  80125a:	e8 2d f0 ff ff       	call   80028c <cprintf>
	*dev = 0;
  80125f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801262:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801268:	83 c4 10             	add    $0x10,%esp
  80126b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801270:	c9                   	leave  
  801271:	c3                   	ret    

00801272 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	56                   	push   %esi
  801276:	53                   	push   %ebx
  801277:	83 ec 10             	sub    $0x10,%esp
  80127a:	8b 75 08             	mov    0x8(%ebp),%esi
  80127d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801280:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801283:	50                   	push   %eax
  801284:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80128a:	c1 e8 0c             	shr    $0xc,%eax
  80128d:	50                   	push   %eax
  80128e:	e8 36 ff ff ff       	call   8011c9 <fd_lookup>
  801293:	83 c4 08             	add    $0x8,%esp
  801296:	85 c0                	test   %eax,%eax
  801298:	78 05                	js     80129f <fd_close+0x2d>
	    || fd != fd2)
  80129a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80129d:	74 0c                	je     8012ab <fd_close+0x39>
		return (must_exist ? r : 0);
  80129f:	84 db                	test   %bl,%bl
  8012a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8012a6:	0f 44 c2             	cmove  %edx,%eax
  8012a9:	eb 41                	jmp    8012ec <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012ab:	83 ec 08             	sub    $0x8,%esp
  8012ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b1:	50                   	push   %eax
  8012b2:	ff 36                	pushl  (%esi)
  8012b4:	e8 66 ff ff ff       	call   80121f <dev_lookup>
  8012b9:	89 c3                	mov    %eax,%ebx
  8012bb:	83 c4 10             	add    $0x10,%esp
  8012be:	85 c0                	test   %eax,%eax
  8012c0:	78 1a                	js     8012dc <fd_close+0x6a>
		if (dev->dev_close)
  8012c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c5:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012c8:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012cd:	85 c0                	test   %eax,%eax
  8012cf:	74 0b                	je     8012dc <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012d1:	83 ec 0c             	sub    $0xc,%esp
  8012d4:	56                   	push   %esi
  8012d5:	ff d0                	call   *%eax
  8012d7:	89 c3                	mov    %eax,%ebx
  8012d9:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012dc:	83 ec 08             	sub    $0x8,%esp
  8012df:	56                   	push   %esi
  8012e0:	6a 00                	push   $0x0
  8012e2:	e8 b2 f9 ff ff       	call   800c99 <sys_page_unmap>
	return r;
  8012e7:	83 c4 10             	add    $0x10,%esp
  8012ea:	89 d8                	mov    %ebx,%eax
}
  8012ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ef:	5b                   	pop    %ebx
  8012f0:	5e                   	pop    %esi
  8012f1:	5d                   	pop    %ebp
  8012f2:	c3                   	ret    

008012f3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012f3:	55                   	push   %ebp
  8012f4:	89 e5                	mov    %esp,%ebp
  8012f6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012fc:	50                   	push   %eax
  8012fd:	ff 75 08             	pushl  0x8(%ebp)
  801300:	e8 c4 fe ff ff       	call   8011c9 <fd_lookup>
  801305:	83 c4 08             	add    $0x8,%esp
  801308:	85 c0                	test   %eax,%eax
  80130a:	78 10                	js     80131c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80130c:	83 ec 08             	sub    $0x8,%esp
  80130f:	6a 01                	push   $0x1
  801311:	ff 75 f4             	pushl  -0xc(%ebp)
  801314:	e8 59 ff ff ff       	call   801272 <fd_close>
  801319:	83 c4 10             	add    $0x10,%esp
}
  80131c:	c9                   	leave  
  80131d:	c3                   	ret    

0080131e <close_all>:

void
close_all(void)
{
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
  801321:	53                   	push   %ebx
  801322:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801325:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80132a:	83 ec 0c             	sub    $0xc,%esp
  80132d:	53                   	push   %ebx
  80132e:	e8 c0 ff ff ff       	call   8012f3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801333:	83 c3 01             	add    $0x1,%ebx
  801336:	83 c4 10             	add    $0x10,%esp
  801339:	83 fb 20             	cmp    $0x20,%ebx
  80133c:	75 ec                	jne    80132a <close_all+0xc>
		close(i);
}
  80133e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801341:	c9                   	leave  
  801342:	c3                   	ret    

00801343 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801343:	55                   	push   %ebp
  801344:	89 e5                	mov    %esp,%ebp
  801346:	57                   	push   %edi
  801347:	56                   	push   %esi
  801348:	53                   	push   %ebx
  801349:	83 ec 2c             	sub    $0x2c,%esp
  80134c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80134f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801352:	50                   	push   %eax
  801353:	ff 75 08             	pushl  0x8(%ebp)
  801356:	e8 6e fe ff ff       	call   8011c9 <fd_lookup>
  80135b:	83 c4 08             	add    $0x8,%esp
  80135e:	85 c0                	test   %eax,%eax
  801360:	0f 88 c1 00 00 00    	js     801427 <dup+0xe4>
		return r;
	close(newfdnum);
  801366:	83 ec 0c             	sub    $0xc,%esp
  801369:	56                   	push   %esi
  80136a:	e8 84 ff ff ff       	call   8012f3 <close>

	newfd = INDEX2FD(newfdnum);
  80136f:	89 f3                	mov    %esi,%ebx
  801371:	c1 e3 0c             	shl    $0xc,%ebx
  801374:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80137a:	83 c4 04             	add    $0x4,%esp
  80137d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801380:	e8 de fd ff ff       	call   801163 <fd2data>
  801385:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801387:	89 1c 24             	mov    %ebx,(%esp)
  80138a:	e8 d4 fd ff ff       	call   801163 <fd2data>
  80138f:	83 c4 10             	add    $0x10,%esp
  801392:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801395:	89 f8                	mov    %edi,%eax
  801397:	c1 e8 16             	shr    $0x16,%eax
  80139a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013a1:	a8 01                	test   $0x1,%al
  8013a3:	74 37                	je     8013dc <dup+0x99>
  8013a5:	89 f8                	mov    %edi,%eax
  8013a7:	c1 e8 0c             	shr    $0xc,%eax
  8013aa:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013b1:	f6 c2 01             	test   $0x1,%dl
  8013b4:	74 26                	je     8013dc <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013b6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013bd:	83 ec 0c             	sub    $0xc,%esp
  8013c0:	25 07 0e 00 00       	and    $0xe07,%eax
  8013c5:	50                   	push   %eax
  8013c6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013c9:	6a 00                	push   $0x0
  8013cb:	57                   	push   %edi
  8013cc:	6a 00                	push   $0x0
  8013ce:	e8 84 f8 ff ff       	call   800c57 <sys_page_map>
  8013d3:	89 c7                	mov    %eax,%edi
  8013d5:	83 c4 20             	add    $0x20,%esp
  8013d8:	85 c0                	test   %eax,%eax
  8013da:	78 2e                	js     80140a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013df:	89 d0                	mov    %edx,%eax
  8013e1:	c1 e8 0c             	shr    $0xc,%eax
  8013e4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013eb:	83 ec 0c             	sub    $0xc,%esp
  8013ee:	25 07 0e 00 00       	and    $0xe07,%eax
  8013f3:	50                   	push   %eax
  8013f4:	53                   	push   %ebx
  8013f5:	6a 00                	push   $0x0
  8013f7:	52                   	push   %edx
  8013f8:	6a 00                	push   $0x0
  8013fa:	e8 58 f8 ff ff       	call   800c57 <sys_page_map>
  8013ff:	89 c7                	mov    %eax,%edi
  801401:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801404:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801406:	85 ff                	test   %edi,%edi
  801408:	79 1d                	jns    801427 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80140a:	83 ec 08             	sub    $0x8,%esp
  80140d:	53                   	push   %ebx
  80140e:	6a 00                	push   $0x0
  801410:	e8 84 f8 ff ff       	call   800c99 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801415:	83 c4 08             	add    $0x8,%esp
  801418:	ff 75 d4             	pushl  -0x2c(%ebp)
  80141b:	6a 00                	push   $0x0
  80141d:	e8 77 f8 ff ff       	call   800c99 <sys_page_unmap>
	return r;
  801422:	83 c4 10             	add    $0x10,%esp
  801425:	89 f8                	mov    %edi,%eax
}
  801427:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80142a:	5b                   	pop    %ebx
  80142b:	5e                   	pop    %esi
  80142c:	5f                   	pop    %edi
  80142d:	5d                   	pop    %ebp
  80142e:	c3                   	ret    

0080142f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80142f:	55                   	push   %ebp
  801430:	89 e5                	mov    %esp,%ebp
  801432:	53                   	push   %ebx
  801433:	83 ec 14             	sub    $0x14,%esp
  801436:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801439:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80143c:	50                   	push   %eax
  80143d:	53                   	push   %ebx
  80143e:	e8 86 fd ff ff       	call   8011c9 <fd_lookup>
  801443:	83 c4 08             	add    $0x8,%esp
  801446:	89 c2                	mov    %eax,%edx
  801448:	85 c0                	test   %eax,%eax
  80144a:	78 6d                	js     8014b9 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80144c:	83 ec 08             	sub    $0x8,%esp
  80144f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801452:	50                   	push   %eax
  801453:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801456:	ff 30                	pushl  (%eax)
  801458:	e8 c2 fd ff ff       	call   80121f <dev_lookup>
  80145d:	83 c4 10             	add    $0x10,%esp
  801460:	85 c0                	test   %eax,%eax
  801462:	78 4c                	js     8014b0 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801464:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801467:	8b 42 08             	mov    0x8(%edx),%eax
  80146a:	83 e0 03             	and    $0x3,%eax
  80146d:	83 f8 01             	cmp    $0x1,%eax
  801470:	75 21                	jne    801493 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801472:	a1 04 40 80 00       	mov    0x804004,%eax
  801477:	8b 40 48             	mov    0x48(%eax),%eax
  80147a:	83 ec 04             	sub    $0x4,%esp
  80147d:	53                   	push   %ebx
  80147e:	50                   	push   %eax
  80147f:	68 99 26 80 00       	push   $0x802699
  801484:	e8 03 ee ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  801489:	83 c4 10             	add    $0x10,%esp
  80148c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801491:	eb 26                	jmp    8014b9 <read+0x8a>
	}
	if (!dev->dev_read)
  801493:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801496:	8b 40 08             	mov    0x8(%eax),%eax
  801499:	85 c0                	test   %eax,%eax
  80149b:	74 17                	je     8014b4 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80149d:	83 ec 04             	sub    $0x4,%esp
  8014a0:	ff 75 10             	pushl  0x10(%ebp)
  8014a3:	ff 75 0c             	pushl  0xc(%ebp)
  8014a6:	52                   	push   %edx
  8014a7:	ff d0                	call   *%eax
  8014a9:	89 c2                	mov    %eax,%edx
  8014ab:	83 c4 10             	add    $0x10,%esp
  8014ae:	eb 09                	jmp    8014b9 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b0:	89 c2                	mov    %eax,%edx
  8014b2:	eb 05                	jmp    8014b9 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014b4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014b9:	89 d0                	mov    %edx,%eax
  8014bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014be:	c9                   	leave  
  8014bf:	c3                   	ret    

008014c0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	57                   	push   %edi
  8014c4:	56                   	push   %esi
  8014c5:	53                   	push   %ebx
  8014c6:	83 ec 0c             	sub    $0xc,%esp
  8014c9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014cc:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014d4:	eb 21                	jmp    8014f7 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014d6:	83 ec 04             	sub    $0x4,%esp
  8014d9:	89 f0                	mov    %esi,%eax
  8014db:	29 d8                	sub    %ebx,%eax
  8014dd:	50                   	push   %eax
  8014de:	89 d8                	mov    %ebx,%eax
  8014e0:	03 45 0c             	add    0xc(%ebp),%eax
  8014e3:	50                   	push   %eax
  8014e4:	57                   	push   %edi
  8014e5:	e8 45 ff ff ff       	call   80142f <read>
		if (m < 0)
  8014ea:	83 c4 10             	add    $0x10,%esp
  8014ed:	85 c0                	test   %eax,%eax
  8014ef:	78 10                	js     801501 <readn+0x41>
			return m;
		if (m == 0)
  8014f1:	85 c0                	test   %eax,%eax
  8014f3:	74 0a                	je     8014ff <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f5:	01 c3                	add    %eax,%ebx
  8014f7:	39 f3                	cmp    %esi,%ebx
  8014f9:	72 db                	jb     8014d6 <readn+0x16>
  8014fb:	89 d8                	mov    %ebx,%eax
  8014fd:	eb 02                	jmp    801501 <readn+0x41>
  8014ff:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801501:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801504:	5b                   	pop    %ebx
  801505:	5e                   	pop    %esi
  801506:	5f                   	pop    %edi
  801507:	5d                   	pop    %ebp
  801508:	c3                   	ret    

00801509 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801509:	55                   	push   %ebp
  80150a:	89 e5                	mov    %esp,%ebp
  80150c:	53                   	push   %ebx
  80150d:	83 ec 14             	sub    $0x14,%esp
  801510:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801513:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801516:	50                   	push   %eax
  801517:	53                   	push   %ebx
  801518:	e8 ac fc ff ff       	call   8011c9 <fd_lookup>
  80151d:	83 c4 08             	add    $0x8,%esp
  801520:	89 c2                	mov    %eax,%edx
  801522:	85 c0                	test   %eax,%eax
  801524:	78 68                	js     80158e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801526:	83 ec 08             	sub    $0x8,%esp
  801529:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152c:	50                   	push   %eax
  80152d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801530:	ff 30                	pushl  (%eax)
  801532:	e8 e8 fc ff ff       	call   80121f <dev_lookup>
  801537:	83 c4 10             	add    $0x10,%esp
  80153a:	85 c0                	test   %eax,%eax
  80153c:	78 47                	js     801585 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80153e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801541:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801545:	75 21                	jne    801568 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801547:	a1 04 40 80 00       	mov    0x804004,%eax
  80154c:	8b 40 48             	mov    0x48(%eax),%eax
  80154f:	83 ec 04             	sub    $0x4,%esp
  801552:	53                   	push   %ebx
  801553:	50                   	push   %eax
  801554:	68 b5 26 80 00       	push   $0x8026b5
  801559:	e8 2e ed ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  80155e:	83 c4 10             	add    $0x10,%esp
  801561:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801566:	eb 26                	jmp    80158e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801568:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80156b:	8b 52 0c             	mov    0xc(%edx),%edx
  80156e:	85 d2                	test   %edx,%edx
  801570:	74 17                	je     801589 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801572:	83 ec 04             	sub    $0x4,%esp
  801575:	ff 75 10             	pushl  0x10(%ebp)
  801578:	ff 75 0c             	pushl  0xc(%ebp)
  80157b:	50                   	push   %eax
  80157c:	ff d2                	call   *%edx
  80157e:	89 c2                	mov    %eax,%edx
  801580:	83 c4 10             	add    $0x10,%esp
  801583:	eb 09                	jmp    80158e <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801585:	89 c2                	mov    %eax,%edx
  801587:	eb 05                	jmp    80158e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801589:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80158e:	89 d0                	mov    %edx,%eax
  801590:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801593:	c9                   	leave  
  801594:	c3                   	ret    

00801595 <seek>:

int
seek(int fdnum, off_t offset)
{
  801595:	55                   	push   %ebp
  801596:	89 e5                	mov    %esp,%ebp
  801598:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80159b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80159e:	50                   	push   %eax
  80159f:	ff 75 08             	pushl  0x8(%ebp)
  8015a2:	e8 22 fc ff ff       	call   8011c9 <fd_lookup>
  8015a7:	83 c4 08             	add    $0x8,%esp
  8015aa:	85 c0                	test   %eax,%eax
  8015ac:	78 0e                	js     8015bc <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015b4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015bc:	c9                   	leave  
  8015bd:	c3                   	ret    

008015be <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015be:	55                   	push   %ebp
  8015bf:	89 e5                	mov    %esp,%ebp
  8015c1:	53                   	push   %ebx
  8015c2:	83 ec 14             	sub    $0x14,%esp
  8015c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015cb:	50                   	push   %eax
  8015cc:	53                   	push   %ebx
  8015cd:	e8 f7 fb ff ff       	call   8011c9 <fd_lookup>
  8015d2:	83 c4 08             	add    $0x8,%esp
  8015d5:	89 c2                	mov    %eax,%edx
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	78 65                	js     801640 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015db:	83 ec 08             	sub    $0x8,%esp
  8015de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e1:	50                   	push   %eax
  8015e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e5:	ff 30                	pushl  (%eax)
  8015e7:	e8 33 fc ff ff       	call   80121f <dev_lookup>
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	78 44                	js     801637 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015fa:	75 21                	jne    80161d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015fc:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801601:	8b 40 48             	mov    0x48(%eax),%eax
  801604:	83 ec 04             	sub    $0x4,%esp
  801607:	53                   	push   %ebx
  801608:	50                   	push   %eax
  801609:	68 78 26 80 00       	push   $0x802678
  80160e:	e8 79 ec ff ff       	call   80028c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801613:	83 c4 10             	add    $0x10,%esp
  801616:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80161b:	eb 23                	jmp    801640 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80161d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801620:	8b 52 18             	mov    0x18(%edx),%edx
  801623:	85 d2                	test   %edx,%edx
  801625:	74 14                	je     80163b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801627:	83 ec 08             	sub    $0x8,%esp
  80162a:	ff 75 0c             	pushl  0xc(%ebp)
  80162d:	50                   	push   %eax
  80162e:	ff d2                	call   *%edx
  801630:	89 c2                	mov    %eax,%edx
  801632:	83 c4 10             	add    $0x10,%esp
  801635:	eb 09                	jmp    801640 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801637:	89 c2                	mov    %eax,%edx
  801639:	eb 05                	jmp    801640 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80163b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801640:	89 d0                	mov    %edx,%eax
  801642:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801645:	c9                   	leave  
  801646:	c3                   	ret    

00801647 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	53                   	push   %ebx
  80164b:	83 ec 14             	sub    $0x14,%esp
  80164e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801651:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801654:	50                   	push   %eax
  801655:	ff 75 08             	pushl  0x8(%ebp)
  801658:	e8 6c fb ff ff       	call   8011c9 <fd_lookup>
  80165d:	83 c4 08             	add    $0x8,%esp
  801660:	89 c2                	mov    %eax,%edx
  801662:	85 c0                	test   %eax,%eax
  801664:	78 58                	js     8016be <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801666:	83 ec 08             	sub    $0x8,%esp
  801669:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166c:	50                   	push   %eax
  80166d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801670:	ff 30                	pushl  (%eax)
  801672:	e8 a8 fb ff ff       	call   80121f <dev_lookup>
  801677:	83 c4 10             	add    $0x10,%esp
  80167a:	85 c0                	test   %eax,%eax
  80167c:	78 37                	js     8016b5 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80167e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801681:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801685:	74 32                	je     8016b9 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801687:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80168a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801691:	00 00 00 
	stat->st_isdir = 0;
  801694:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80169b:	00 00 00 
	stat->st_dev = dev;
  80169e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016a4:	83 ec 08             	sub    $0x8,%esp
  8016a7:	53                   	push   %ebx
  8016a8:	ff 75 f0             	pushl  -0x10(%ebp)
  8016ab:	ff 50 14             	call   *0x14(%eax)
  8016ae:	89 c2                	mov    %eax,%edx
  8016b0:	83 c4 10             	add    $0x10,%esp
  8016b3:	eb 09                	jmp    8016be <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b5:	89 c2                	mov    %eax,%edx
  8016b7:	eb 05                	jmp    8016be <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016b9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016be:	89 d0                	mov    %edx,%eax
  8016c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c3:	c9                   	leave  
  8016c4:	c3                   	ret    

008016c5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	56                   	push   %esi
  8016c9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016ca:	83 ec 08             	sub    $0x8,%esp
  8016cd:	6a 00                	push   $0x0
  8016cf:	ff 75 08             	pushl  0x8(%ebp)
  8016d2:	e8 d6 01 00 00       	call   8018ad <open>
  8016d7:	89 c3                	mov    %eax,%ebx
  8016d9:	83 c4 10             	add    $0x10,%esp
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	78 1b                	js     8016fb <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016e0:	83 ec 08             	sub    $0x8,%esp
  8016e3:	ff 75 0c             	pushl  0xc(%ebp)
  8016e6:	50                   	push   %eax
  8016e7:	e8 5b ff ff ff       	call   801647 <fstat>
  8016ec:	89 c6                	mov    %eax,%esi
	close(fd);
  8016ee:	89 1c 24             	mov    %ebx,(%esp)
  8016f1:	e8 fd fb ff ff       	call   8012f3 <close>
	return r;
  8016f6:	83 c4 10             	add    $0x10,%esp
  8016f9:	89 f0                	mov    %esi,%eax
}
  8016fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016fe:	5b                   	pop    %ebx
  8016ff:	5e                   	pop    %esi
  801700:	5d                   	pop    %ebp
  801701:	c3                   	ret    

00801702 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801702:	55                   	push   %ebp
  801703:	89 e5                	mov    %esp,%ebp
  801705:	56                   	push   %esi
  801706:	53                   	push   %ebx
  801707:	89 c6                	mov    %eax,%esi
  801709:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80170b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801712:	75 12                	jne    801726 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801714:	83 ec 0c             	sub    $0xc,%esp
  801717:	6a 01                	push   $0x1
  801719:	e8 fc f9 ff ff       	call   80111a <ipc_find_env>
  80171e:	a3 00 40 80 00       	mov    %eax,0x804000
  801723:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801726:	6a 07                	push   $0x7
  801728:	68 00 50 80 00       	push   $0x805000
  80172d:	56                   	push   %esi
  80172e:	ff 35 00 40 80 00    	pushl  0x804000
  801734:	e8 8d f9 ff ff       	call   8010c6 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801739:	83 c4 0c             	add    $0xc,%esp
  80173c:	6a 00                	push   $0x0
  80173e:	53                   	push   %ebx
  80173f:	6a 00                	push   $0x0
  801741:	e8 19 f9 ff ff       	call   80105f <ipc_recv>
}
  801746:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801749:	5b                   	pop    %ebx
  80174a:	5e                   	pop    %esi
  80174b:	5d                   	pop    %ebp
  80174c:	c3                   	ret    

0080174d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80174d:	55                   	push   %ebp
  80174e:	89 e5                	mov    %esp,%ebp
  801750:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801753:	8b 45 08             	mov    0x8(%ebp),%eax
  801756:	8b 40 0c             	mov    0xc(%eax),%eax
  801759:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80175e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801761:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801766:	ba 00 00 00 00       	mov    $0x0,%edx
  80176b:	b8 02 00 00 00       	mov    $0x2,%eax
  801770:	e8 8d ff ff ff       	call   801702 <fsipc>
}
  801775:	c9                   	leave  
  801776:	c3                   	ret    

00801777 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801777:	55                   	push   %ebp
  801778:	89 e5                	mov    %esp,%ebp
  80177a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80177d:	8b 45 08             	mov    0x8(%ebp),%eax
  801780:	8b 40 0c             	mov    0xc(%eax),%eax
  801783:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801788:	ba 00 00 00 00       	mov    $0x0,%edx
  80178d:	b8 06 00 00 00       	mov    $0x6,%eax
  801792:	e8 6b ff ff ff       	call   801702 <fsipc>
}
  801797:	c9                   	leave  
  801798:	c3                   	ret    

00801799 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801799:	55                   	push   %ebp
  80179a:	89 e5                	mov    %esp,%ebp
  80179c:	53                   	push   %ebx
  80179d:	83 ec 04             	sub    $0x4,%esp
  8017a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b3:	b8 05 00 00 00       	mov    $0x5,%eax
  8017b8:	e8 45 ff ff ff       	call   801702 <fsipc>
  8017bd:	85 c0                	test   %eax,%eax
  8017bf:	78 2c                	js     8017ed <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017c1:	83 ec 08             	sub    $0x8,%esp
  8017c4:	68 00 50 80 00       	push   $0x805000
  8017c9:	53                   	push   %ebx
  8017ca:	e8 42 f0 ff ff       	call   800811 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017cf:	a1 80 50 80 00       	mov    0x805080,%eax
  8017d4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017da:	a1 84 50 80 00       	mov    0x805084,%eax
  8017df:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017e5:	83 c4 10             	add    $0x10,%esp
  8017e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f0:	c9                   	leave  
  8017f1:	c3                   	ret    

008017f2 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	83 ec 0c             	sub    $0xc,%esp
  8017f8:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8017fe:	8b 52 0c             	mov    0xc(%edx),%edx
  801801:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801807:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80180c:	50                   	push   %eax
  80180d:	ff 75 0c             	pushl  0xc(%ebp)
  801810:	68 08 50 80 00       	push   $0x805008
  801815:	e8 89 f1 ff ff       	call   8009a3 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80181a:	ba 00 00 00 00       	mov    $0x0,%edx
  80181f:	b8 04 00 00 00       	mov    $0x4,%eax
  801824:	e8 d9 fe ff ff       	call   801702 <fsipc>

}
  801829:	c9                   	leave  
  80182a:	c3                   	ret    

0080182b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
  80182e:	56                   	push   %esi
  80182f:	53                   	push   %ebx
  801830:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801833:	8b 45 08             	mov    0x8(%ebp),%eax
  801836:	8b 40 0c             	mov    0xc(%eax),%eax
  801839:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80183e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801844:	ba 00 00 00 00       	mov    $0x0,%edx
  801849:	b8 03 00 00 00       	mov    $0x3,%eax
  80184e:	e8 af fe ff ff       	call   801702 <fsipc>
  801853:	89 c3                	mov    %eax,%ebx
  801855:	85 c0                	test   %eax,%eax
  801857:	78 4b                	js     8018a4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801859:	39 c6                	cmp    %eax,%esi
  80185b:	73 16                	jae    801873 <devfile_read+0x48>
  80185d:	68 e4 26 80 00       	push   $0x8026e4
  801862:	68 eb 26 80 00       	push   $0x8026eb
  801867:	6a 7c                	push   $0x7c
  801869:	68 00 27 80 00       	push   $0x802700
  80186e:	e8 bd 05 00 00       	call   801e30 <_panic>
	assert(r <= PGSIZE);
  801873:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801878:	7e 16                	jle    801890 <devfile_read+0x65>
  80187a:	68 0b 27 80 00       	push   $0x80270b
  80187f:	68 eb 26 80 00       	push   $0x8026eb
  801884:	6a 7d                	push   $0x7d
  801886:	68 00 27 80 00       	push   $0x802700
  80188b:	e8 a0 05 00 00       	call   801e30 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801890:	83 ec 04             	sub    $0x4,%esp
  801893:	50                   	push   %eax
  801894:	68 00 50 80 00       	push   $0x805000
  801899:	ff 75 0c             	pushl  0xc(%ebp)
  80189c:	e8 02 f1 ff ff       	call   8009a3 <memmove>
	return r;
  8018a1:	83 c4 10             	add    $0x10,%esp
}
  8018a4:	89 d8                	mov    %ebx,%eax
  8018a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a9:	5b                   	pop    %ebx
  8018aa:	5e                   	pop    %esi
  8018ab:	5d                   	pop    %ebp
  8018ac:	c3                   	ret    

008018ad <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018ad:	55                   	push   %ebp
  8018ae:	89 e5                	mov    %esp,%ebp
  8018b0:	53                   	push   %ebx
  8018b1:	83 ec 20             	sub    $0x20,%esp
  8018b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018b7:	53                   	push   %ebx
  8018b8:	e8 1b ef ff ff       	call   8007d8 <strlen>
  8018bd:	83 c4 10             	add    $0x10,%esp
  8018c0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018c5:	7f 67                	jg     80192e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018c7:	83 ec 0c             	sub    $0xc,%esp
  8018ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018cd:	50                   	push   %eax
  8018ce:	e8 a7 f8 ff ff       	call   80117a <fd_alloc>
  8018d3:	83 c4 10             	add    $0x10,%esp
		return r;
  8018d6:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018d8:	85 c0                	test   %eax,%eax
  8018da:	78 57                	js     801933 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018dc:	83 ec 08             	sub    $0x8,%esp
  8018df:	53                   	push   %ebx
  8018e0:	68 00 50 80 00       	push   $0x805000
  8018e5:	e8 27 ef ff ff       	call   800811 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ed:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8018fa:	e8 03 fe ff ff       	call   801702 <fsipc>
  8018ff:	89 c3                	mov    %eax,%ebx
  801901:	83 c4 10             	add    $0x10,%esp
  801904:	85 c0                	test   %eax,%eax
  801906:	79 14                	jns    80191c <open+0x6f>
		fd_close(fd, 0);
  801908:	83 ec 08             	sub    $0x8,%esp
  80190b:	6a 00                	push   $0x0
  80190d:	ff 75 f4             	pushl  -0xc(%ebp)
  801910:	e8 5d f9 ff ff       	call   801272 <fd_close>
		return r;
  801915:	83 c4 10             	add    $0x10,%esp
  801918:	89 da                	mov    %ebx,%edx
  80191a:	eb 17                	jmp    801933 <open+0x86>
	}

	return fd2num(fd);
  80191c:	83 ec 0c             	sub    $0xc,%esp
  80191f:	ff 75 f4             	pushl  -0xc(%ebp)
  801922:	e8 2c f8 ff ff       	call   801153 <fd2num>
  801927:	89 c2                	mov    %eax,%edx
  801929:	83 c4 10             	add    $0x10,%esp
  80192c:	eb 05                	jmp    801933 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80192e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801933:	89 d0                	mov    %edx,%eax
  801935:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801938:	c9                   	leave  
  801939:	c3                   	ret    

0080193a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80193a:	55                   	push   %ebp
  80193b:	89 e5                	mov    %esp,%ebp
  80193d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801940:	ba 00 00 00 00       	mov    $0x0,%edx
  801945:	b8 08 00 00 00       	mov    $0x8,%eax
  80194a:	e8 b3 fd ff ff       	call   801702 <fsipc>
}
  80194f:	c9                   	leave  
  801950:	c3                   	ret    

00801951 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801951:	55                   	push   %ebp
  801952:	89 e5                	mov    %esp,%ebp
  801954:	56                   	push   %esi
  801955:	53                   	push   %ebx
  801956:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801959:	83 ec 0c             	sub    $0xc,%esp
  80195c:	ff 75 08             	pushl  0x8(%ebp)
  80195f:	e8 ff f7 ff ff       	call   801163 <fd2data>
  801964:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801966:	83 c4 08             	add    $0x8,%esp
  801969:	68 17 27 80 00       	push   $0x802717
  80196e:	53                   	push   %ebx
  80196f:	e8 9d ee ff ff       	call   800811 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801974:	8b 46 04             	mov    0x4(%esi),%eax
  801977:	2b 06                	sub    (%esi),%eax
  801979:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80197f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801986:	00 00 00 
	stat->st_dev = &devpipe;
  801989:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801990:	30 80 00 
	return 0;
}
  801993:	b8 00 00 00 00       	mov    $0x0,%eax
  801998:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80199b:	5b                   	pop    %ebx
  80199c:	5e                   	pop    %esi
  80199d:	5d                   	pop    %ebp
  80199e:	c3                   	ret    

0080199f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80199f:	55                   	push   %ebp
  8019a0:	89 e5                	mov    %esp,%ebp
  8019a2:	53                   	push   %ebx
  8019a3:	83 ec 0c             	sub    $0xc,%esp
  8019a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019a9:	53                   	push   %ebx
  8019aa:	6a 00                	push   $0x0
  8019ac:	e8 e8 f2 ff ff       	call   800c99 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019b1:	89 1c 24             	mov    %ebx,(%esp)
  8019b4:	e8 aa f7 ff ff       	call   801163 <fd2data>
  8019b9:	83 c4 08             	add    $0x8,%esp
  8019bc:	50                   	push   %eax
  8019bd:	6a 00                	push   $0x0
  8019bf:	e8 d5 f2 ff ff       	call   800c99 <sys_page_unmap>
}
  8019c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c7:	c9                   	leave  
  8019c8:	c3                   	ret    

008019c9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019c9:	55                   	push   %ebp
  8019ca:	89 e5                	mov    %esp,%ebp
  8019cc:	57                   	push   %edi
  8019cd:	56                   	push   %esi
  8019ce:	53                   	push   %ebx
  8019cf:	83 ec 1c             	sub    $0x1c,%esp
  8019d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019d5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019d7:	a1 04 40 80 00       	mov    0x804004,%eax
  8019dc:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019df:	83 ec 0c             	sub    $0xc,%esp
  8019e2:	ff 75 e0             	pushl  -0x20(%ebp)
  8019e5:	e8 f7 04 00 00       	call   801ee1 <pageref>
  8019ea:	89 c3                	mov    %eax,%ebx
  8019ec:	89 3c 24             	mov    %edi,(%esp)
  8019ef:	e8 ed 04 00 00       	call   801ee1 <pageref>
  8019f4:	83 c4 10             	add    $0x10,%esp
  8019f7:	39 c3                	cmp    %eax,%ebx
  8019f9:	0f 94 c1             	sete   %cl
  8019fc:	0f b6 c9             	movzbl %cl,%ecx
  8019ff:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a02:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a08:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a0b:	39 ce                	cmp    %ecx,%esi
  801a0d:	74 1b                	je     801a2a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a0f:	39 c3                	cmp    %eax,%ebx
  801a11:	75 c4                	jne    8019d7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a13:	8b 42 58             	mov    0x58(%edx),%eax
  801a16:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a19:	50                   	push   %eax
  801a1a:	56                   	push   %esi
  801a1b:	68 1e 27 80 00       	push   $0x80271e
  801a20:	e8 67 e8 ff ff       	call   80028c <cprintf>
  801a25:	83 c4 10             	add    $0x10,%esp
  801a28:	eb ad                	jmp    8019d7 <_pipeisclosed+0xe>
	}
}
  801a2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a30:	5b                   	pop    %ebx
  801a31:	5e                   	pop    %esi
  801a32:	5f                   	pop    %edi
  801a33:	5d                   	pop    %ebp
  801a34:	c3                   	ret    

00801a35 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	57                   	push   %edi
  801a39:	56                   	push   %esi
  801a3a:	53                   	push   %ebx
  801a3b:	83 ec 28             	sub    $0x28,%esp
  801a3e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a41:	56                   	push   %esi
  801a42:	e8 1c f7 ff ff       	call   801163 <fd2data>
  801a47:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a49:	83 c4 10             	add    $0x10,%esp
  801a4c:	bf 00 00 00 00       	mov    $0x0,%edi
  801a51:	eb 4b                	jmp    801a9e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a53:	89 da                	mov    %ebx,%edx
  801a55:	89 f0                	mov    %esi,%eax
  801a57:	e8 6d ff ff ff       	call   8019c9 <_pipeisclosed>
  801a5c:	85 c0                	test   %eax,%eax
  801a5e:	75 48                	jne    801aa8 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a60:	e8 90 f1 ff ff       	call   800bf5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a65:	8b 43 04             	mov    0x4(%ebx),%eax
  801a68:	8b 0b                	mov    (%ebx),%ecx
  801a6a:	8d 51 20             	lea    0x20(%ecx),%edx
  801a6d:	39 d0                	cmp    %edx,%eax
  801a6f:	73 e2                	jae    801a53 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a74:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a78:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a7b:	89 c2                	mov    %eax,%edx
  801a7d:	c1 fa 1f             	sar    $0x1f,%edx
  801a80:	89 d1                	mov    %edx,%ecx
  801a82:	c1 e9 1b             	shr    $0x1b,%ecx
  801a85:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a88:	83 e2 1f             	and    $0x1f,%edx
  801a8b:	29 ca                	sub    %ecx,%edx
  801a8d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a91:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a95:	83 c0 01             	add    $0x1,%eax
  801a98:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a9b:	83 c7 01             	add    $0x1,%edi
  801a9e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801aa1:	75 c2                	jne    801a65 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801aa3:	8b 45 10             	mov    0x10(%ebp),%eax
  801aa6:	eb 05                	jmp    801aad <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aa8:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801aad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab0:	5b                   	pop    %ebx
  801ab1:	5e                   	pop    %esi
  801ab2:	5f                   	pop    %edi
  801ab3:	5d                   	pop    %ebp
  801ab4:	c3                   	ret    

00801ab5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ab5:	55                   	push   %ebp
  801ab6:	89 e5                	mov    %esp,%ebp
  801ab8:	57                   	push   %edi
  801ab9:	56                   	push   %esi
  801aba:	53                   	push   %ebx
  801abb:	83 ec 18             	sub    $0x18,%esp
  801abe:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ac1:	57                   	push   %edi
  801ac2:	e8 9c f6 ff ff       	call   801163 <fd2data>
  801ac7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac9:	83 c4 10             	add    $0x10,%esp
  801acc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ad1:	eb 3d                	jmp    801b10 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ad3:	85 db                	test   %ebx,%ebx
  801ad5:	74 04                	je     801adb <devpipe_read+0x26>
				return i;
  801ad7:	89 d8                	mov    %ebx,%eax
  801ad9:	eb 44                	jmp    801b1f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801adb:	89 f2                	mov    %esi,%edx
  801add:	89 f8                	mov    %edi,%eax
  801adf:	e8 e5 fe ff ff       	call   8019c9 <_pipeisclosed>
  801ae4:	85 c0                	test   %eax,%eax
  801ae6:	75 32                	jne    801b1a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ae8:	e8 08 f1 ff ff       	call   800bf5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801aed:	8b 06                	mov    (%esi),%eax
  801aef:	3b 46 04             	cmp    0x4(%esi),%eax
  801af2:	74 df                	je     801ad3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801af4:	99                   	cltd   
  801af5:	c1 ea 1b             	shr    $0x1b,%edx
  801af8:	01 d0                	add    %edx,%eax
  801afa:	83 e0 1f             	and    $0x1f,%eax
  801afd:	29 d0                	sub    %edx,%eax
  801aff:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b07:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b0a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b0d:	83 c3 01             	add    $0x1,%ebx
  801b10:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b13:	75 d8                	jne    801aed <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b15:	8b 45 10             	mov    0x10(%ebp),%eax
  801b18:	eb 05                	jmp    801b1f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b1a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b22:	5b                   	pop    %ebx
  801b23:	5e                   	pop    %esi
  801b24:	5f                   	pop    %edi
  801b25:	5d                   	pop    %ebp
  801b26:	c3                   	ret    

00801b27 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	56                   	push   %esi
  801b2b:	53                   	push   %ebx
  801b2c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b32:	50                   	push   %eax
  801b33:	e8 42 f6 ff ff       	call   80117a <fd_alloc>
  801b38:	83 c4 10             	add    $0x10,%esp
  801b3b:	89 c2                	mov    %eax,%edx
  801b3d:	85 c0                	test   %eax,%eax
  801b3f:	0f 88 2c 01 00 00    	js     801c71 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b45:	83 ec 04             	sub    $0x4,%esp
  801b48:	68 07 04 00 00       	push   $0x407
  801b4d:	ff 75 f4             	pushl  -0xc(%ebp)
  801b50:	6a 00                	push   $0x0
  801b52:	e8 bd f0 ff ff       	call   800c14 <sys_page_alloc>
  801b57:	83 c4 10             	add    $0x10,%esp
  801b5a:	89 c2                	mov    %eax,%edx
  801b5c:	85 c0                	test   %eax,%eax
  801b5e:	0f 88 0d 01 00 00    	js     801c71 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b64:	83 ec 0c             	sub    $0xc,%esp
  801b67:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b6a:	50                   	push   %eax
  801b6b:	e8 0a f6 ff ff       	call   80117a <fd_alloc>
  801b70:	89 c3                	mov    %eax,%ebx
  801b72:	83 c4 10             	add    $0x10,%esp
  801b75:	85 c0                	test   %eax,%eax
  801b77:	0f 88 e2 00 00 00    	js     801c5f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b7d:	83 ec 04             	sub    $0x4,%esp
  801b80:	68 07 04 00 00       	push   $0x407
  801b85:	ff 75 f0             	pushl  -0x10(%ebp)
  801b88:	6a 00                	push   $0x0
  801b8a:	e8 85 f0 ff ff       	call   800c14 <sys_page_alloc>
  801b8f:	89 c3                	mov    %eax,%ebx
  801b91:	83 c4 10             	add    $0x10,%esp
  801b94:	85 c0                	test   %eax,%eax
  801b96:	0f 88 c3 00 00 00    	js     801c5f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b9c:	83 ec 0c             	sub    $0xc,%esp
  801b9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba2:	e8 bc f5 ff ff       	call   801163 <fd2data>
  801ba7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba9:	83 c4 0c             	add    $0xc,%esp
  801bac:	68 07 04 00 00       	push   $0x407
  801bb1:	50                   	push   %eax
  801bb2:	6a 00                	push   $0x0
  801bb4:	e8 5b f0 ff ff       	call   800c14 <sys_page_alloc>
  801bb9:	89 c3                	mov    %eax,%ebx
  801bbb:	83 c4 10             	add    $0x10,%esp
  801bbe:	85 c0                	test   %eax,%eax
  801bc0:	0f 88 89 00 00 00    	js     801c4f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc6:	83 ec 0c             	sub    $0xc,%esp
  801bc9:	ff 75 f0             	pushl  -0x10(%ebp)
  801bcc:	e8 92 f5 ff ff       	call   801163 <fd2data>
  801bd1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bd8:	50                   	push   %eax
  801bd9:	6a 00                	push   $0x0
  801bdb:	56                   	push   %esi
  801bdc:	6a 00                	push   $0x0
  801bde:	e8 74 f0 ff ff       	call   800c57 <sys_page_map>
  801be3:	89 c3                	mov    %eax,%ebx
  801be5:	83 c4 20             	add    $0x20,%esp
  801be8:	85 c0                	test   %eax,%eax
  801bea:	78 55                	js     801c41 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bec:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfa:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c01:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801c07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c0a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c0f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c16:	83 ec 0c             	sub    $0xc,%esp
  801c19:	ff 75 f4             	pushl  -0xc(%ebp)
  801c1c:	e8 32 f5 ff ff       	call   801153 <fd2num>
  801c21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c24:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c26:	83 c4 04             	add    $0x4,%esp
  801c29:	ff 75 f0             	pushl  -0x10(%ebp)
  801c2c:	e8 22 f5 ff ff       	call   801153 <fd2num>
  801c31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c34:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c37:	83 c4 10             	add    $0x10,%esp
  801c3a:	ba 00 00 00 00       	mov    $0x0,%edx
  801c3f:	eb 30                	jmp    801c71 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c41:	83 ec 08             	sub    $0x8,%esp
  801c44:	56                   	push   %esi
  801c45:	6a 00                	push   $0x0
  801c47:	e8 4d f0 ff ff       	call   800c99 <sys_page_unmap>
  801c4c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c4f:	83 ec 08             	sub    $0x8,%esp
  801c52:	ff 75 f0             	pushl  -0x10(%ebp)
  801c55:	6a 00                	push   $0x0
  801c57:	e8 3d f0 ff ff       	call   800c99 <sys_page_unmap>
  801c5c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c5f:	83 ec 08             	sub    $0x8,%esp
  801c62:	ff 75 f4             	pushl  -0xc(%ebp)
  801c65:	6a 00                	push   $0x0
  801c67:	e8 2d f0 ff ff       	call   800c99 <sys_page_unmap>
  801c6c:	83 c4 10             	add    $0x10,%esp
  801c6f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c71:	89 d0                	mov    %edx,%eax
  801c73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c76:	5b                   	pop    %ebx
  801c77:	5e                   	pop    %esi
  801c78:	5d                   	pop    %ebp
  801c79:	c3                   	ret    

00801c7a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c7a:	55                   	push   %ebp
  801c7b:	89 e5                	mov    %esp,%ebp
  801c7d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c83:	50                   	push   %eax
  801c84:	ff 75 08             	pushl  0x8(%ebp)
  801c87:	e8 3d f5 ff ff       	call   8011c9 <fd_lookup>
  801c8c:	83 c4 10             	add    $0x10,%esp
  801c8f:	85 c0                	test   %eax,%eax
  801c91:	78 18                	js     801cab <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c93:	83 ec 0c             	sub    $0xc,%esp
  801c96:	ff 75 f4             	pushl  -0xc(%ebp)
  801c99:	e8 c5 f4 ff ff       	call   801163 <fd2data>
	return _pipeisclosed(fd, p);
  801c9e:	89 c2                	mov    %eax,%edx
  801ca0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca3:	e8 21 fd ff ff       	call   8019c9 <_pipeisclosed>
  801ca8:	83 c4 10             	add    $0x10,%esp
}
  801cab:	c9                   	leave  
  801cac:	c3                   	ret    

00801cad <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cad:	55                   	push   %ebp
  801cae:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cb0:	b8 00 00 00 00       	mov    $0x0,%eax
  801cb5:	5d                   	pop    %ebp
  801cb6:	c3                   	ret    

00801cb7 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cb7:	55                   	push   %ebp
  801cb8:	89 e5                	mov    %esp,%ebp
  801cba:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cbd:	68 36 27 80 00       	push   $0x802736
  801cc2:	ff 75 0c             	pushl  0xc(%ebp)
  801cc5:	e8 47 eb ff ff       	call   800811 <strcpy>
	return 0;
}
  801cca:	b8 00 00 00 00       	mov    $0x0,%eax
  801ccf:	c9                   	leave  
  801cd0:	c3                   	ret    

00801cd1 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cd1:	55                   	push   %ebp
  801cd2:	89 e5                	mov    %esp,%ebp
  801cd4:	57                   	push   %edi
  801cd5:	56                   	push   %esi
  801cd6:	53                   	push   %ebx
  801cd7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cdd:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ce2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ce8:	eb 2d                	jmp    801d17 <devcons_write+0x46>
		m = n - tot;
  801cea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ced:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801cef:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801cf2:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801cf7:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cfa:	83 ec 04             	sub    $0x4,%esp
  801cfd:	53                   	push   %ebx
  801cfe:	03 45 0c             	add    0xc(%ebp),%eax
  801d01:	50                   	push   %eax
  801d02:	57                   	push   %edi
  801d03:	e8 9b ec ff ff       	call   8009a3 <memmove>
		sys_cputs(buf, m);
  801d08:	83 c4 08             	add    $0x8,%esp
  801d0b:	53                   	push   %ebx
  801d0c:	57                   	push   %edi
  801d0d:	e8 46 ee ff ff       	call   800b58 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d12:	01 de                	add    %ebx,%esi
  801d14:	83 c4 10             	add    $0x10,%esp
  801d17:	89 f0                	mov    %esi,%eax
  801d19:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d1c:	72 cc                	jb     801cea <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d21:	5b                   	pop    %ebx
  801d22:	5e                   	pop    %esi
  801d23:	5f                   	pop    %edi
  801d24:	5d                   	pop    %ebp
  801d25:	c3                   	ret    

00801d26 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d26:	55                   	push   %ebp
  801d27:	89 e5                	mov    %esp,%ebp
  801d29:	83 ec 08             	sub    $0x8,%esp
  801d2c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d31:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d35:	74 2a                	je     801d61 <devcons_read+0x3b>
  801d37:	eb 05                	jmp    801d3e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d39:	e8 b7 ee ff ff       	call   800bf5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d3e:	e8 33 ee ff ff       	call   800b76 <sys_cgetc>
  801d43:	85 c0                	test   %eax,%eax
  801d45:	74 f2                	je     801d39 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d47:	85 c0                	test   %eax,%eax
  801d49:	78 16                	js     801d61 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d4b:	83 f8 04             	cmp    $0x4,%eax
  801d4e:	74 0c                	je     801d5c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d50:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d53:	88 02                	mov    %al,(%edx)
	return 1;
  801d55:	b8 01 00 00 00       	mov    $0x1,%eax
  801d5a:	eb 05                	jmp    801d61 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d5c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d61:	c9                   	leave  
  801d62:	c3                   	ret    

00801d63 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d63:	55                   	push   %ebp
  801d64:	89 e5                	mov    %esp,%ebp
  801d66:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d69:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d6f:	6a 01                	push   $0x1
  801d71:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d74:	50                   	push   %eax
  801d75:	e8 de ed ff ff       	call   800b58 <sys_cputs>
}
  801d7a:	83 c4 10             	add    $0x10,%esp
  801d7d:	c9                   	leave  
  801d7e:	c3                   	ret    

00801d7f <getchar>:

int
getchar(void)
{
  801d7f:	55                   	push   %ebp
  801d80:	89 e5                	mov    %esp,%ebp
  801d82:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d85:	6a 01                	push   $0x1
  801d87:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d8a:	50                   	push   %eax
  801d8b:	6a 00                	push   $0x0
  801d8d:	e8 9d f6 ff ff       	call   80142f <read>
	if (r < 0)
  801d92:	83 c4 10             	add    $0x10,%esp
  801d95:	85 c0                	test   %eax,%eax
  801d97:	78 0f                	js     801da8 <getchar+0x29>
		return r;
	if (r < 1)
  801d99:	85 c0                	test   %eax,%eax
  801d9b:	7e 06                	jle    801da3 <getchar+0x24>
		return -E_EOF;
	return c;
  801d9d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801da1:	eb 05                	jmp    801da8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801da3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801da8:	c9                   	leave  
  801da9:	c3                   	ret    

00801daa <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801daa:	55                   	push   %ebp
  801dab:	89 e5                	mov    %esp,%ebp
  801dad:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801db0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db3:	50                   	push   %eax
  801db4:	ff 75 08             	pushl  0x8(%ebp)
  801db7:	e8 0d f4 ff ff       	call   8011c9 <fd_lookup>
  801dbc:	83 c4 10             	add    $0x10,%esp
  801dbf:	85 c0                	test   %eax,%eax
  801dc1:	78 11                	js     801dd4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801dc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc6:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801dcc:	39 10                	cmp    %edx,(%eax)
  801dce:	0f 94 c0             	sete   %al
  801dd1:	0f b6 c0             	movzbl %al,%eax
}
  801dd4:	c9                   	leave  
  801dd5:	c3                   	ret    

00801dd6 <opencons>:

int
opencons(void)
{
  801dd6:	55                   	push   %ebp
  801dd7:	89 e5                	mov    %esp,%ebp
  801dd9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ddc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ddf:	50                   	push   %eax
  801de0:	e8 95 f3 ff ff       	call   80117a <fd_alloc>
  801de5:	83 c4 10             	add    $0x10,%esp
		return r;
  801de8:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dea:	85 c0                	test   %eax,%eax
  801dec:	78 3e                	js     801e2c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dee:	83 ec 04             	sub    $0x4,%esp
  801df1:	68 07 04 00 00       	push   $0x407
  801df6:	ff 75 f4             	pushl  -0xc(%ebp)
  801df9:	6a 00                	push   $0x0
  801dfb:	e8 14 ee ff ff       	call   800c14 <sys_page_alloc>
  801e00:	83 c4 10             	add    $0x10,%esp
		return r;
  801e03:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e05:	85 c0                	test   %eax,%eax
  801e07:	78 23                	js     801e2c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e09:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e12:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e17:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e1e:	83 ec 0c             	sub    $0xc,%esp
  801e21:	50                   	push   %eax
  801e22:	e8 2c f3 ff ff       	call   801153 <fd2num>
  801e27:	89 c2                	mov    %eax,%edx
  801e29:	83 c4 10             	add    $0x10,%esp
}
  801e2c:	89 d0                	mov    %edx,%eax
  801e2e:	c9                   	leave  
  801e2f:	c3                   	ret    

00801e30 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e30:	55                   	push   %ebp
  801e31:	89 e5                	mov    %esp,%ebp
  801e33:	56                   	push   %esi
  801e34:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e35:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e38:	8b 35 08 30 80 00    	mov    0x803008,%esi
  801e3e:	e8 93 ed ff ff       	call   800bd6 <sys_getenvid>
  801e43:	83 ec 0c             	sub    $0xc,%esp
  801e46:	ff 75 0c             	pushl  0xc(%ebp)
  801e49:	ff 75 08             	pushl  0x8(%ebp)
  801e4c:	56                   	push   %esi
  801e4d:	50                   	push   %eax
  801e4e:	68 44 27 80 00       	push   $0x802744
  801e53:	e8 34 e4 ff ff       	call   80028c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e58:	83 c4 18             	add    $0x18,%esp
  801e5b:	53                   	push   %ebx
  801e5c:	ff 75 10             	pushl  0x10(%ebp)
  801e5f:	e8 d7 e3 ff ff       	call   80023b <vcprintf>
	cprintf("\n");
  801e64:	c7 04 24 2f 27 80 00 	movl   $0x80272f,(%esp)
  801e6b:	e8 1c e4 ff ff       	call   80028c <cprintf>
  801e70:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e73:	cc                   	int3   
  801e74:	eb fd                	jmp    801e73 <_panic+0x43>

00801e76 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e76:	55                   	push   %ebp
  801e77:	89 e5                	mov    %esp,%ebp
  801e79:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e7c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e83:	75 2e                	jne    801eb3 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801e85:	e8 4c ed ff ff       	call   800bd6 <sys_getenvid>
  801e8a:	83 ec 04             	sub    $0x4,%esp
  801e8d:	68 07 0e 00 00       	push   $0xe07
  801e92:	68 00 f0 bf ee       	push   $0xeebff000
  801e97:	50                   	push   %eax
  801e98:	e8 77 ed ff ff       	call   800c14 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801e9d:	e8 34 ed ff ff       	call   800bd6 <sys_getenvid>
  801ea2:	83 c4 08             	add    $0x8,%esp
  801ea5:	68 bd 1e 80 00       	push   $0x801ebd
  801eaa:	50                   	push   %eax
  801eab:	e8 af ee ff ff       	call   800d5f <sys_env_set_pgfault_upcall>
  801eb0:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801eb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb6:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801ebb:	c9                   	leave  
  801ebc:	c3                   	ret    

00801ebd <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801ebd:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801ebe:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801ec3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801ec5:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  801ec8:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  801ecc:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  801ed0:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  801ed3:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  801ed6:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  801ed7:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  801eda:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  801edb:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  801edc:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801ee0:	c3                   	ret    

00801ee1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ee1:	55                   	push   %ebp
  801ee2:	89 e5                	mov    %esp,%ebp
  801ee4:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ee7:	89 d0                	mov    %edx,%eax
  801ee9:	c1 e8 16             	shr    $0x16,%eax
  801eec:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ef3:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ef8:	f6 c1 01             	test   $0x1,%cl
  801efb:	74 1d                	je     801f1a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801efd:	c1 ea 0c             	shr    $0xc,%edx
  801f00:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f07:	f6 c2 01             	test   $0x1,%dl
  801f0a:	74 0e                	je     801f1a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f0c:	c1 ea 0c             	shr    $0xc,%edx
  801f0f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f16:	ef 
  801f17:	0f b7 c0             	movzwl %ax,%eax
}
  801f1a:	5d                   	pop    %ebp
  801f1b:	c3                   	ret    
  801f1c:	66 90                	xchg   %ax,%ax
  801f1e:	66 90                	xchg   %ax,%ax

00801f20 <__udivdi3>:
  801f20:	55                   	push   %ebp
  801f21:	57                   	push   %edi
  801f22:	56                   	push   %esi
  801f23:	53                   	push   %ebx
  801f24:	83 ec 1c             	sub    $0x1c,%esp
  801f27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f37:	85 f6                	test   %esi,%esi
  801f39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f3d:	89 ca                	mov    %ecx,%edx
  801f3f:	89 f8                	mov    %edi,%eax
  801f41:	75 3d                	jne    801f80 <__udivdi3+0x60>
  801f43:	39 cf                	cmp    %ecx,%edi
  801f45:	0f 87 c5 00 00 00    	ja     802010 <__udivdi3+0xf0>
  801f4b:	85 ff                	test   %edi,%edi
  801f4d:	89 fd                	mov    %edi,%ebp
  801f4f:	75 0b                	jne    801f5c <__udivdi3+0x3c>
  801f51:	b8 01 00 00 00       	mov    $0x1,%eax
  801f56:	31 d2                	xor    %edx,%edx
  801f58:	f7 f7                	div    %edi
  801f5a:	89 c5                	mov    %eax,%ebp
  801f5c:	89 c8                	mov    %ecx,%eax
  801f5e:	31 d2                	xor    %edx,%edx
  801f60:	f7 f5                	div    %ebp
  801f62:	89 c1                	mov    %eax,%ecx
  801f64:	89 d8                	mov    %ebx,%eax
  801f66:	89 cf                	mov    %ecx,%edi
  801f68:	f7 f5                	div    %ebp
  801f6a:	89 c3                	mov    %eax,%ebx
  801f6c:	89 d8                	mov    %ebx,%eax
  801f6e:	89 fa                	mov    %edi,%edx
  801f70:	83 c4 1c             	add    $0x1c,%esp
  801f73:	5b                   	pop    %ebx
  801f74:	5e                   	pop    %esi
  801f75:	5f                   	pop    %edi
  801f76:	5d                   	pop    %ebp
  801f77:	c3                   	ret    
  801f78:	90                   	nop
  801f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f80:	39 ce                	cmp    %ecx,%esi
  801f82:	77 74                	ja     801ff8 <__udivdi3+0xd8>
  801f84:	0f bd fe             	bsr    %esi,%edi
  801f87:	83 f7 1f             	xor    $0x1f,%edi
  801f8a:	0f 84 98 00 00 00    	je     802028 <__udivdi3+0x108>
  801f90:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f95:	89 f9                	mov    %edi,%ecx
  801f97:	89 c5                	mov    %eax,%ebp
  801f99:	29 fb                	sub    %edi,%ebx
  801f9b:	d3 e6                	shl    %cl,%esi
  801f9d:	89 d9                	mov    %ebx,%ecx
  801f9f:	d3 ed                	shr    %cl,%ebp
  801fa1:	89 f9                	mov    %edi,%ecx
  801fa3:	d3 e0                	shl    %cl,%eax
  801fa5:	09 ee                	or     %ebp,%esi
  801fa7:	89 d9                	mov    %ebx,%ecx
  801fa9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fad:	89 d5                	mov    %edx,%ebp
  801faf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fb3:	d3 ed                	shr    %cl,%ebp
  801fb5:	89 f9                	mov    %edi,%ecx
  801fb7:	d3 e2                	shl    %cl,%edx
  801fb9:	89 d9                	mov    %ebx,%ecx
  801fbb:	d3 e8                	shr    %cl,%eax
  801fbd:	09 c2                	or     %eax,%edx
  801fbf:	89 d0                	mov    %edx,%eax
  801fc1:	89 ea                	mov    %ebp,%edx
  801fc3:	f7 f6                	div    %esi
  801fc5:	89 d5                	mov    %edx,%ebp
  801fc7:	89 c3                	mov    %eax,%ebx
  801fc9:	f7 64 24 0c          	mull   0xc(%esp)
  801fcd:	39 d5                	cmp    %edx,%ebp
  801fcf:	72 10                	jb     801fe1 <__udivdi3+0xc1>
  801fd1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801fd5:	89 f9                	mov    %edi,%ecx
  801fd7:	d3 e6                	shl    %cl,%esi
  801fd9:	39 c6                	cmp    %eax,%esi
  801fdb:	73 07                	jae    801fe4 <__udivdi3+0xc4>
  801fdd:	39 d5                	cmp    %edx,%ebp
  801fdf:	75 03                	jne    801fe4 <__udivdi3+0xc4>
  801fe1:	83 eb 01             	sub    $0x1,%ebx
  801fe4:	31 ff                	xor    %edi,%edi
  801fe6:	89 d8                	mov    %ebx,%eax
  801fe8:	89 fa                	mov    %edi,%edx
  801fea:	83 c4 1c             	add    $0x1c,%esp
  801fed:	5b                   	pop    %ebx
  801fee:	5e                   	pop    %esi
  801fef:	5f                   	pop    %edi
  801ff0:	5d                   	pop    %ebp
  801ff1:	c3                   	ret    
  801ff2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ff8:	31 ff                	xor    %edi,%edi
  801ffa:	31 db                	xor    %ebx,%ebx
  801ffc:	89 d8                	mov    %ebx,%eax
  801ffe:	89 fa                	mov    %edi,%edx
  802000:	83 c4 1c             	add    $0x1c,%esp
  802003:	5b                   	pop    %ebx
  802004:	5e                   	pop    %esi
  802005:	5f                   	pop    %edi
  802006:	5d                   	pop    %ebp
  802007:	c3                   	ret    
  802008:	90                   	nop
  802009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802010:	89 d8                	mov    %ebx,%eax
  802012:	f7 f7                	div    %edi
  802014:	31 ff                	xor    %edi,%edi
  802016:	89 c3                	mov    %eax,%ebx
  802018:	89 d8                	mov    %ebx,%eax
  80201a:	89 fa                	mov    %edi,%edx
  80201c:	83 c4 1c             	add    $0x1c,%esp
  80201f:	5b                   	pop    %ebx
  802020:	5e                   	pop    %esi
  802021:	5f                   	pop    %edi
  802022:	5d                   	pop    %ebp
  802023:	c3                   	ret    
  802024:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802028:	39 ce                	cmp    %ecx,%esi
  80202a:	72 0c                	jb     802038 <__udivdi3+0x118>
  80202c:	31 db                	xor    %ebx,%ebx
  80202e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802032:	0f 87 34 ff ff ff    	ja     801f6c <__udivdi3+0x4c>
  802038:	bb 01 00 00 00       	mov    $0x1,%ebx
  80203d:	e9 2a ff ff ff       	jmp    801f6c <__udivdi3+0x4c>
  802042:	66 90                	xchg   %ax,%ax
  802044:	66 90                	xchg   %ax,%ax
  802046:	66 90                	xchg   %ax,%ax
  802048:	66 90                	xchg   %ax,%ax
  80204a:	66 90                	xchg   %ax,%ax
  80204c:	66 90                	xchg   %ax,%ax
  80204e:	66 90                	xchg   %ax,%ax

00802050 <__umoddi3>:
  802050:	55                   	push   %ebp
  802051:	57                   	push   %edi
  802052:	56                   	push   %esi
  802053:	53                   	push   %ebx
  802054:	83 ec 1c             	sub    $0x1c,%esp
  802057:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80205b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80205f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802063:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802067:	85 d2                	test   %edx,%edx
  802069:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80206d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802071:	89 f3                	mov    %esi,%ebx
  802073:	89 3c 24             	mov    %edi,(%esp)
  802076:	89 74 24 04          	mov    %esi,0x4(%esp)
  80207a:	75 1c                	jne    802098 <__umoddi3+0x48>
  80207c:	39 f7                	cmp    %esi,%edi
  80207e:	76 50                	jbe    8020d0 <__umoddi3+0x80>
  802080:	89 c8                	mov    %ecx,%eax
  802082:	89 f2                	mov    %esi,%edx
  802084:	f7 f7                	div    %edi
  802086:	89 d0                	mov    %edx,%eax
  802088:	31 d2                	xor    %edx,%edx
  80208a:	83 c4 1c             	add    $0x1c,%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    
  802092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802098:	39 f2                	cmp    %esi,%edx
  80209a:	89 d0                	mov    %edx,%eax
  80209c:	77 52                	ja     8020f0 <__umoddi3+0xa0>
  80209e:	0f bd ea             	bsr    %edx,%ebp
  8020a1:	83 f5 1f             	xor    $0x1f,%ebp
  8020a4:	75 5a                	jne    802100 <__umoddi3+0xb0>
  8020a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020aa:	0f 82 e0 00 00 00    	jb     802190 <__umoddi3+0x140>
  8020b0:	39 0c 24             	cmp    %ecx,(%esp)
  8020b3:	0f 86 d7 00 00 00    	jbe    802190 <__umoddi3+0x140>
  8020b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020c1:	83 c4 1c             	add    $0x1c,%esp
  8020c4:	5b                   	pop    %ebx
  8020c5:	5e                   	pop    %esi
  8020c6:	5f                   	pop    %edi
  8020c7:	5d                   	pop    %ebp
  8020c8:	c3                   	ret    
  8020c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d0:	85 ff                	test   %edi,%edi
  8020d2:	89 fd                	mov    %edi,%ebp
  8020d4:	75 0b                	jne    8020e1 <__umoddi3+0x91>
  8020d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020db:	31 d2                	xor    %edx,%edx
  8020dd:	f7 f7                	div    %edi
  8020df:	89 c5                	mov    %eax,%ebp
  8020e1:	89 f0                	mov    %esi,%eax
  8020e3:	31 d2                	xor    %edx,%edx
  8020e5:	f7 f5                	div    %ebp
  8020e7:	89 c8                	mov    %ecx,%eax
  8020e9:	f7 f5                	div    %ebp
  8020eb:	89 d0                	mov    %edx,%eax
  8020ed:	eb 99                	jmp    802088 <__umoddi3+0x38>
  8020ef:	90                   	nop
  8020f0:	89 c8                	mov    %ecx,%eax
  8020f2:	89 f2                	mov    %esi,%edx
  8020f4:	83 c4 1c             	add    $0x1c,%esp
  8020f7:	5b                   	pop    %ebx
  8020f8:	5e                   	pop    %esi
  8020f9:	5f                   	pop    %edi
  8020fa:	5d                   	pop    %ebp
  8020fb:	c3                   	ret    
  8020fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802100:	8b 34 24             	mov    (%esp),%esi
  802103:	bf 20 00 00 00       	mov    $0x20,%edi
  802108:	89 e9                	mov    %ebp,%ecx
  80210a:	29 ef                	sub    %ebp,%edi
  80210c:	d3 e0                	shl    %cl,%eax
  80210e:	89 f9                	mov    %edi,%ecx
  802110:	89 f2                	mov    %esi,%edx
  802112:	d3 ea                	shr    %cl,%edx
  802114:	89 e9                	mov    %ebp,%ecx
  802116:	09 c2                	or     %eax,%edx
  802118:	89 d8                	mov    %ebx,%eax
  80211a:	89 14 24             	mov    %edx,(%esp)
  80211d:	89 f2                	mov    %esi,%edx
  80211f:	d3 e2                	shl    %cl,%edx
  802121:	89 f9                	mov    %edi,%ecx
  802123:	89 54 24 04          	mov    %edx,0x4(%esp)
  802127:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80212b:	d3 e8                	shr    %cl,%eax
  80212d:	89 e9                	mov    %ebp,%ecx
  80212f:	89 c6                	mov    %eax,%esi
  802131:	d3 e3                	shl    %cl,%ebx
  802133:	89 f9                	mov    %edi,%ecx
  802135:	89 d0                	mov    %edx,%eax
  802137:	d3 e8                	shr    %cl,%eax
  802139:	89 e9                	mov    %ebp,%ecx
  80213b:	09 d8                	or     %ebx,%eax
  80213d:	89 d3                	mov    %edx,%ebx
  80213f:	89 f2                	mov    %esi,%edx
  802141:	f7 34 24             	divl   (%esp)
  802144:	89 d6                	mov    %edx,%esi
  802146:	d3 e3                	shl    %cl,%ebx
  802148:	f7 64 24 04          	mull   0x4(%esp)
  80214c:	39 d6                	cmp    %edx,%esi
  80214e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802152:	89 d1                	mov    %edx,%ecx
  802154:	89 c3                	mov    %eax,%ebx
  802156:	72 08                	jb     802160 <__umoddi3+0x110>
  802158:	75 11                	jne    80216b <__umoddi3+0x11b>
  80215a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80215e:	73 0b                	jae    80216b <__umoddi3+0x11b>
  802160:	2b 44 24 04          	sub    0x4(%esp),%eax
  802164:	1b 14 24             	sbb    (%esp),%edx
  802167:	89 d1                	mov    %edx,%ecx
  802169:	89 c3                	mov    %eax,%ebx
  80216b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80216f:	29 da                	sub    %ebx,%edx
  802171:	19 ce                	sbb    %ecx,%esi
  802173:	89 f9                	mov    %edi,%ecx
  802175:	89 f0                	mov    %esi,%eax
  802177:	d3 e0                	shl    %cl,%eax
  802179:	89 e9                	mov    %ebp,%ecx
  80217b:	d3 ea                	shr    %cl,%edx
  80217d:	89 e9                	mov    %ebp,%ecx
  80217f:	d3 ee                	shr    %cl,%esi
  802181:	09 d0                	or     %edx,%eax
  802183:	89 f2                	mov    %esi,%edx
  802185:	83 c4 1c             	add    $0x1c,%esp
  802188:	5b                   	pop    %ebx
  802189:	5e                   	pop    %esi
  80218a:	5f                   	pop    %edi
  80218b:	5d                   	pop    %ebp
  80218c:	c3                   	ret    
  80218d:	8d 76 00             	lea    0x0(%esi),%esi
  802190:	29 f9                	sub    %edi,%ecx
  802192:	19 d6                	sbb    %edx,%esi
  802194:	89 74 24 04          	mov    %esi,0x4(%esp)
  802198:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80219c:	e9 18 ff ff ff       	jmp    8020b9 <__umoddi3+0x69>
