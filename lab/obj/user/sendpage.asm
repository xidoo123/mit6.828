
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
  800039:	e8 01 0f 00 00       	call   800f3f <fork>
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
  800057:	e8 9a 10 00 00       	call   8010f6 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 c0 26 80 00       	push   $0x8026c0
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
  80009d:	68 d4 26 80 00       	push   $0x8026d4
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
  8000db:	e8 7d 10 00 00       	call   80115d <ipc_send>
		return;
  8000e0:	83 c4 20             	add    $0x20,%esp
  8000e3:	e9 af 00 00 00       	jmp    800197 <umain+0x164>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e8:	a1 08 40 80 00       	mov    0x804008,%eax
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
  800131:	e8 27 10 00 00       	call   80115d <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 ad 0f 00 00       	call   8010f6 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 c0 26 80 00       	push   $0x8026c0
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
  80018a:	68 f4 26 80 00       	push   $0x8026f4
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
  8001b6:	a3 08 40 80 00       	mov    %eax,0x804008

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
  8001e5:	e8 cb 11 00 00       	call   8013b5 <close_all>
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
  8002ef:	e8 2c 21 00 00       	call   802420 <__udivdi3>
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
  800332:	e8 19 22 00 00       	call   802550 <__umoddi3>
  800337:	83 c4 14             	add    $0x14,%esp
  80033a:	0f be 80 6c 27 80 00 	movsbl 0x80276c(%eax),%eax
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
  800436:	ff 24 85 a0 28 80 00 	jmp    *0x8028a0(,%eax,4)
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
  8004fa:	8b 14 85 00 2a 80 00 	mov    0x802a00(,%eax,4),%edx
  800501:	85 d2                	test   %edx,%edx
  800503:	75 18                	jne    80051d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800505:	50                   	push   %eax
  800506:	68 84 27 80 00       	push   $0x802784
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
  80051e:	68 01 2c 80 00       	push   $0x802c01
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
  800542:	b8 7d 27 80 00       	mov    $0x80277d,%eax
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
  800bbd:	68 5f 2a 80 00       	push   $0x802a5f
  800bc2:	6a 23                	push   $0x23
  800bc4:	68 7c 2a 80 00       	push   $0x802a7c
  800bc9:	e8 60 17 00 00       	call   80232e <_panic>

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
  800c3e:	68 5f 2a 80 00       	push   $0x802a5f
  800c43:	6a 23                	push   $0x23
  800c45:	68 7c 2a 80 00       	push   $0x802a7c
  800c4a:	e8 df 16 00 00       	call   80232e <_panic>

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
  800c80:	68 5f 2a 80 00       	push   $0x802a5f
  800c85:	6a 23                	push   $0x23
  800c87:	68 7c 2a 80 00       	push   $0x802a7c
  800c8c:	e8 9d 16 00 00       	call   80232e <_panic>

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
  800cc2:	68 5f 2a 80 00       	push   $0x802a5f
  800cc7:	6a 23                	push   $0x23
  800cc9:	68 7c 2a 80 00       	push   $0x802a7c
  800cce:	e8 5b 16 00 00       	call   80232e <_panic>

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
  800d04:	68 5f 2a 80 00       	push   $0x802a5f
  800d09:	6a 23                	push   $0x23
  800d0b:	68 7c 2a 80 00       	push   $0x802a7c
  800d10:	e8 19 16 00 00       	call   80232e <_panic>

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
  800d46:	68 5f 2a 80 00       	push   $0x802a5f
  800d4b:	6a 23                	push   $0x23
  800d4d:	68 7c 2a 80 00       	push   $0x802a7c
  800d52:	e8 d7 15 00 00       	call   80232e <_panic>

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
  800d88:	68 5f 2a 80 00       	push   $0x802a5f
  800d8d:	6a 23                	push   $0x23
  800d8f:	68 7c 2a 80 00       	push   $0x802a7c
  800d94:	e8 95 15 00 00       	call   80232e <_panic>

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
  800dec:	68 5f 2a 80 00       	push   $0x802a5f
  800df1:	6a 23                	push   $0x23
  800df3:	68 7c 2a 80 00       	push   $0x802a7c
  800df8:	e8 31 15 00 00       	call   80232e <_panic>

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

00800e05 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	57                   	push   %edi
  800e09:	56                   	push   %esi
  800e0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e10:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e15:	89 d1                	mov    %edx,%ecx
  800e17:	89 d3                	mov    %edx,%ebx
  800e19:	89 d7                	mov    %edx,%edi
  800e1b:	89 d6                	mov    %edx,%esi
  800e1d:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	57                   	push   %edi
  800e28:	56                   	push   %esi
  800e29:	53                   	push   %ebx
  800e2a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e32:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3d:	89 df                	mov    %ebx,%edi
  800e3f:	89 de                	mov    %ebx,%esi
  800e41:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e43:	85 c0                	test   %eax,%eax
  800e45:	7e 17                	jle    800e5e <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e47:	83 ec 0c             	sub    $0xc,%esp
  800e4a:	50                   	push   %eax
  800e4b:	6a 0f                	push   $0xf
  800e4d:	68 5f 2a 80 00       	push   $0x802a5f
  800e52:	6a 23                	push   $0x23
  800e54:	68 7c 2a 80 00       	push   $0x802a7c
  800e59:	e8 d0 14 00 00       	call   80232e <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800e5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e61:	5b                   	pop    %ebx
  800e62:	5e                   	pop    %esi
  800e63:	5f                   	pop    %edi
  800e64:	5d                   	pop    %ebp
  800e65:	c3                   	ret    

00800e66 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	56                   	push   %esi
  800e6a:	53                   	push   %ebx
  800e6b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e6e:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800e70:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e74:	75 25                	jne    800e9b <pgfault+0x35>
  800e76:	89 d8                	mov    %ebx,%eax
  800e78:	c1 e8 0c             	shr    $0xc,%eax
  800e7b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e82:	f6 c4 08             	test   $0x8,%ah
  800e85:	75 14                	jne    800e9b <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800e87:	83 ec 04             	sub    $0x4,%esp
  800e8a:	68 8c 2a 80 00       	push   $0x802a8c
  800e8f:	6a 1e                	push   $0x1e
  800e91:	68 20 2b 80 00       	push   $0x802b20
  800e96:	e8 93 14 00 00       	call   80232e <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800e9b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800ea1:	e8 30 fd ff ff       	call   800bd6 <sys_getenvid>
  800ea6:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800ea8:	83 ec 04             	sub    $0x4,%esp
  800eab:	6a 07                	push   $0x7
  800ead:	68 00 f0 7f 00       	push   $0x7ff000
  800eb2:	50                   	push   %eax
  800eb3:	e8 5c fd ff ff       	call   800c14 <sys_page_alloc>
	if (r < 0)
  800eb8:	83 c4 10             	add    $0x10,%esp
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	79 12                	jns    800ed1 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800ebf:	50                   	push   %eax
  800ec0:	68 b8 2a 80 00       	push   $0x802ab8
  800ec5:	6a 33                	push   $0x33
  800ec7:	68 20 2b 80 00       	push   $0x802b20
  800ecc:	e8 5d 14 00 00       	call   80232e <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800ed1:	83 ec 04             	sub    $0x4,%esp
  800ed4:	68 00 10 00 00       	push   $0x1000
  800ed9:	53                   	push   %ebx
  800eda:	68 00 f0 7f 00       	push   $0x7ff000
  800edf:	e8 27 fb ff ff       	call   800a0b <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800ee4:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800eeb:	53                   	push   %ebx
  800eec:	56                   	push   %esi
  800eed:	68 00 f0 7f 00       	push   $0x7ff000
  800ef2:	56                   	push   %esi
  800ef3:	e8 5f fd ff ff       	call   800c57 <sys_page_map>
	if (r < 0)
  800ef8:	83 c4 20             	add    $0x20,%esp
  800efb:	85 c0                	test   %eax,%eax
  800efd:	79 12                	jns    800f11 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800eff:	50                   	push   %eax
  800f00:	68 dc 2a 80 00       	push   $0x802adc
  800f05:	6a 3b                	push   $0x3b
  800f07:	68 20 2b 80 00       	push   $0x802b20
  800f0c:	e8 1d 14 00 00       	call   80232e <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800f11:	83 ec 08             	sub    $0x8,%esp
  800f14:	68 00 f0 7f 00       	push   $0x7ff000
  800f19:	56                   	push   %esi
  800f1a:	e8 7a fd ff ff       	call   800c99 <sys_page_unmap>
	if (r < 0)
  800f1f:	83 c4 10             	add    $0x10,%esp
  800f22:	85 c0                	test   %eax,%eax
  800f24:	79 12                	jns    800f38 <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800f26:	50                   	push   %eax
  800f27:	68 00 2b 80 00       	push   $0x802b00
  800f2c:	6a 40                	push   $0x40
  800f2e:	68 20 2b 80 00       	push   $0x802b20
  800f33:	e8 f6 13 00 00       	call   80232e <_panic>
}
  800f38:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f3b:	5b                   	pop    %ebx
  800f3c:	5e                   	pop    %esi
  800f3d:	5d                   	pop    %ebp
  800f3e:	c3                   	ret    

00800f3f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	57                   	push   %edi
  800f43:	56                   	push   %esi
  800f44:	53                   	push   %ebx
  800f45:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800f48:	68 66 0e 80 00       	push   $0x800e66
  800f4d:	e8 22 14 00 00       	call   802374 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f52:	b8 07 00 00 00       	mov    $0x7,%eax
  800f57:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800f59:	83 c4 10             	add    $0x10,%esp
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	0f 88 64 01 00 00    	js     8010c8 <fork+0x189>
  800f64:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800f69:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	75 21                	jne    800f93 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f72:	e8 5f fc ff ff       	call   800bd6 <sys_getenvid>
  800f77:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f7c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f7f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f84:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  800f89:	ba 00 00 00 00       	mov    $0x0,%edx
  800f8e:	e9 3f 01 00 00       	jmp    8010d2 <fork+0x193>
  800f93:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f96:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800f98:	89 d8                	mov    %ebx,%eax
  800f9a:	c1 e8 16             	shr    $0x16,%eax
  800f9d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fa4:	a8 01                	test   $0x1,%al
  800fa6:	0f 84 bd 00 00 00    	je     801069 <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800fac:	89 d8                	mov    %ebx,%eax
  800fae:	c1 e8 0c             	shr    $0xc,%eax
  800fb1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fb8:	f6 c2 01             	test   $0x1,%dl
  800fbb:	0f 84 a8 00 00 00    	je     801069 <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  800fc1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fc8:	a8 04                	test   $0x4,%al
  800fca:	0f 84 99 00 00 00    	je     801069 <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800fd0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fd7:	f6 c4 04             	test   $0x4,%ah
  800fda:	74 17                	je     800ff3 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800fdc:	83 ec 0c             	sub    $0xc,%esp
  800fdf:	68 07 0e 00 00       	push   $0xe07
  800fe4:	53                   	push   %ebx
  800fe5:	57                   	push   %edi
  800fe6:	53                   	push   %ebx
  800fe7:	6a 00                	push   $0x0
  800fe9:	e8 69 fc ff ff       	call   800c57 <sys_page_map>
  800fee:	83 c4 20             	add    $0x20,%esp
  800ff1:	eb 76                	jmp    801069 <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800ff3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ffa:	a8 02                	test   $0x2,%al
  800ffc:	75 0c                	jne    80100a <fork+0xcb>
  800ffe:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801005:	f6 c4 08             	test   $0x8,%ah
  801008:	74 3f                	je     801049 <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  80100a:	83 ec 0c             	sub    $0xc,%esp
  80100d:	68 05 08 00 00       	push   $0x805
  801012:	53                   	push   %ebx
  801013:	57                   	push   %edi
  801014:	53                   	push   %ebx
  801015:	6a 00                	push   $0x0
  801017:	e8 3b fc ff ff       	call   800c57 <sys_page_map>
		if (r < 0)
  80101c:	83 c4 20             	add    $0x20,%esp
  80101f:	85 c0                	test   %eax,%eax
  801021:	0f 88 a5 00 00 00    	js     8010cc <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  801027:	83 ec 0c             	sub    $0xc,%esp
  80102a:	68 05 08 00 00       	push   $0x805
  80102f:	53                   	push   %ebx
  801030:	6a 00                	push   $0x0
  801032:	53                   	push   %ebx
  801033:	6a 00                	push   $0x0
  801035:	e8 1d fc ff ff       	call   800c57 <sys_page_map>
  80103a:	83 c4 20             	add    $0x20,%esp
  80103d:	85 c0                	test   %eax,%eax
  80103f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801044:	0f 4f c1             	cmovg  %ecx,%eax
  801047:	eb 1c                	jmp    801065 <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  801049:	83 ec 0c             	sub    $0xc,%esp
  80104c:	6a 05                	push   $0x5
  80104e:	53                   	push   %ebx
  80104f:	57                   	push   %edi
  801050:	53                   	push   %ebx
  801051:	6a 00                	push   $0x0
  801053:	e8 ff fb ff ff       	call   800c57 <sys_page_map>
  801058:	83 c4 20             	add    $0x20,%esp
  80105b:	85 c0                	test   %eax,%eax
  80105d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801062:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  801065:	85 c0                	test   %eax,%eax
  801067:	78 67                	js     8010d0 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801069:	83 c6 01             	add    $0x1,%esi
  80106c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801072:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  801078:	0f 85 1a ff ff ff    	jne    800f98 <fork+0x59>
  80107e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  801081:	83 ec 04             	sub    $0x4,%esp
  801084:	6a 07                	push   $0x7
  801086:	68 00 f0 bf ee       	push   $0xeebff000
  80108b:	57                   	push   %edi
  80108c:	e8 83 fb ff ff       	call   800c14 <sys_page_alloc>
	if (r < 0)
  801091:	83 c4 10             	add    $0x10,%esp
		return r;
  801094:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  801096:	85 c0                	test   %eax,%eax
  801098:	78 38                	js     8010d2 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80109a:	83 ec 08             	sub    $0x8,%esp
  80109d:	68 bb 23 80 00       	push   $0x8023bb
  8010a2:	57                   	push   %edi
  8010a3:	e8 b7 fc ff ff       	call   800d5f <sys_env_set_pgfault_upcall>
	if (r < 0)
  8010a8:	83 c4 10             	add    $0x10,%esp
		return r;
  8010ab:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  8010ad:	85 c0                	test   %eax,%eax
  8010af:	78 21                	js     8010d2 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  8010b1:	83 ec 08             	sub    $0x8,%esp
  8010b4:	6a 02                	push   $0x2
  8010b6:	57                   	push   %edi
  8010b7:	e8 1f fc ff ff       	call   800cdb <sys_env_set_status>
	if (r < 0)
  8010bc:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  8010bf:	85 c0                	test   %eax,%eax
  8010c1:	0f 48 f8             	cmovs  %eax,%edi
  8010c4:	89 fa                	mov    %edi,%edx
  8010c6:	eb 0a                	jmp    8010d2 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  8010c8:	89 c2                	mov    %eax,%edx
  8010ca:	eb 06                	jmp    8010d2 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  8010cc:	89 c2                	mov    %eax,%edx
  8010ce:	eb 02                	jmp    8010d2 <fork+0x193>
  8010d0:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  8010d2:	89 d0                	mov    %edx,%eax
  8010d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d7:	5b                   	pop    %ebx
  8010d8:	5e                   	pop    %esi
  8010d9:	5f                   	pop    %edi
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    

008010dc <sfork>:

// Challenge!
int
sfork(void)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010e2:	68 2b 2b 80 00       	push   $0x802b2b
  8010e7:	68 c9 00 00 00       	push   $0xc9
  8010ec:	68 20 2b 80 00       	push   $0x802b20
  8010f1:	e8 38 12 00 00       	call   80232e <_panic>

008010f6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010f6:	55                   	push   %ebp
  8010f7:	89 e5                	mov    %esp,%ebp
  8010f9:	56                   	push   %esi
  8010fa:	53                   	push   %ebx
  8010fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8010fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801101:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801104:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801106:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80110b:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  80110e:	83 ec 0c             	sub    $0xc,%esp
  801111:	50                   	push   %eax
  801112:	e8 ad fc ff ff       	call   800dc4 <sys_ipc_recv>

	if (from_env_store != NULL)
  801117:	83 c4 10             	add    $0x10,%esp
  80111a:	85 f6                	test   %esi,%esi
  80111c:	74 14                	je     801132 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  80111e:	ba 00 00 00 00       	mov    $0x0,%edx
  801123:	85 c0                	test   %eax,%eax
  801125:	78 09                	js     801130 <ipc_recv+0x3a>
  801127:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80112d:	8b 52 74             	mov    0x74(%edx),%edx
  801130:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801132:	85 db                	test   %ebx,%ebx
  801134:	74 14                	je     80114a <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801136:	ba 00 00 00 00       	mov    $0x0,%edx
  80113b:	85 c0                	test   %eax,%eax
  80113d:	78 09                	js     801148 <ipc_recv+0x52>
  80113f:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801145:	8b 52 78             	mov    0x78(%edx),%edx
  801148:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80114a:	85 c0                	test   %eax,%eax
  80114c:	78 08                	js     801156 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  80114e:	a1 08 40 80 00       	mov    0x804008,%eax
  801153:	8b 40 70             	mov    0x70(%eax),%eax
}
  801156:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801159:	5b                   	pop    %ebx
  80115a:	5e                   	pop    %esi
  80115b:	5d                   	pop    %ebp
  80115c:	c3                   	ret    

0080115d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80115d:	55                   	push   %ebp
  80115e:	89 e5                	mov    %esp,%ebp
  801160:	57                   	push   %edi
  801161:	56                   	push   %esi
  801162:	53                   	push   %ebx
  801163:	83 ec 0c             	sub    $0xc,%esp
  801166:	8b 7d 08             	mov    0x8(%ebp),%edi
  801169:	8b 75 0c             	mov    0xc(%ebp),%esi
  80116c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  80116f:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801171:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801176:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801179:	ff 75 14             	pushl  0x14(%ebp)
  80117c:	53                   	push   %ebx
  80117d:	56                   	push   %esi
  80117e:	57                   	push   %edi
  80117f:	e8 1d fc ff ff       	call   800da1 <sys_ipc_try_send>

		if (err < 0) {
  801184:	83 c4 10             	add    $0x10,%esp
  801187:	85 c0                	test   %eax,%eax
  801189:	79 1e                	jns    8011a9 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  80118b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80118e:	75 07                	jne    801197 <ipc_send+0x3a>
				sys_yield();
  801190:	e8 60 fa ff ff       	call   800bf5 <sys_yield>
  801195:	eb e2                	jmp    801179 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801197:	50                   	push   %eax
  801198:	68 41 2b 80 00       	push   $0x802b41
  80119d:	6a 49                	push   $0x49
  80119f:	68 4e 2b 80 00       	push   $0x802b4e
  8011a4:	e8 85 11 00 00       	call   80232e <_panic>
		}

	} while (err < 0);

}
  8011a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ac:	5b                   	pop    %ebx
  8011ad:	5e                   	pop    %esi
  8011ae:	5f                   	pop    %edi
  8011af:	5d                   	pop    %ebp
  8011b0:	c3                   	ret    

008011b1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
  8011b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011b7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011bc:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011bf:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011c5:	8b 52 50             	mov    0x50(%edx),%edx
  8011c8:	39 ca                	cmp    %ecx,%edx
  8011ca:	75 0d                	jne    8011d9 <ipc_find_env+0x28>
			return envs[i].env_id;
  8011cc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011cf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011d4:	8b 40 48             	mov    0x48(%eax),%eax
  8011d7:	eb 0f                	jmp    8011e8 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011d9:	83 c0 01             	add    $0x1,%eax
  8011dc:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011e1:	75 d9                	jne    8011bc <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011e8:	5d                   	pop    %ebp
  8011e9:	c3                   	ret    

008011ea <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011ea:	55                   	push   %ebp
  8011eb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f0:	05 00 00 00 30       	add    $0x30000000,%eax
  8011f5:	c1 e8 0c             	shr    $0xc,%eax
}
  8011f8:	5d                   	pop    %ebp
  8011f9:	c3                   	ret    

008011fa <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801200:	05 00 00 00 30       	add    $0x30000000,%eax
  801205:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80120a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80120f:	5d                   	pop    %ebp
  801210:	c3                   	ret    

00801211 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801217:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80121c:	89 c2                	mov    %eax,%edx
  80121e:	c1 ea 16             	shr    $0x16,%edx
  801221:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801228:	f6 c2 01             	test   $0x1,%dl
  80122b:	74 11                	je     80123e <fd_alloc+0x2d>
  80122d:	89 c2                	mov    %eax,%edx
  80122f:	c1 ea 0c             	shr    $0xc,%edx
  801232:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801239:	f6 c2 01             	test   $0x1,%dl
  80123c:	75 09                	jne    801247 <fd_alloc+0x36>
			*fd_store = fd;
  80123e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801240:	b8 00 00 00 00       	mov    $0x0,%eax
  801245:	eb 17                	jmp    80125e <fd_alloc+0x4d>
  801247:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80124c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801251:	75 c9                	jne    80121c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801253:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801259:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80125e:	5d                   	pop    %ebp
  80125f:	c3                   	ret    

00801260 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801266:	83 f8 1f             	cmp    $0x1f,%eax
  801269:	77 36                	ja     8012a1 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80126b:	c1 e0 0c             	shl    $0xc,%eax
  80126e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801273:	89 c2                	mov    %eax,%edx
  801275:	c1 ea 16             	shr    $0x16,%edx
  801278:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80127f:	f6 c2 01             	test   $0x1,%dl
  801282:	74 24                	je     8012a8 <fd_lookup+0x48>
  801284:	89 c2                	mov    %eax,%edx
  801286:	c1 ea 0c             	shr    $0xc,%edx
  801289:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801290:	f6 c2 01             	test   $0x1,%dl
  801293:	74 1a                	je     8012af <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801295:	8b 55 0c             	mov    0xc(%ebp),%edx
  801298:	89 02                	mov    %eax,(%edx)
	return 0;
  80129a:	b8 00 00 00 00       	mov    $0x0,%eax
  80129f:	eb 13                	jmp    8012b4 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a6:	eb 0c                	jmp    8012b4 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ad:	eb 05                	jmp    8012b4 <fd_lookup+0x54>
  8012af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012b4:	5d                   	pop    %ebp
  8012b5:	c3                   	ret    

008012b6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012b6:	55                   	push   %ebp
  8012b7:	89 e5                	mov    %esp,%ebp
  8012b9:	83 ec 08             	sub    $0x8,%esp
  8012bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012bf:	ba d4 2b 80 00       	mov    $0x802bd4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012c4:	eb 13                	jmp    8012d9 <dev_lookup+0x23>
  8012c6:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012c9:	39 08                	cmp    %ecx,(%eax)
  8012cb:	75 0c                	jne    8012d9 <dev_lookup+0x23>
			*dev = devtab[i];
  8012cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d7:	eb 2e                	jmp    801307 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012d9:	8b 02                	mov    (%edx),%eax
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	75 e7                	jne    8012c6 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012df:	a1 08 40 80 00       	mov    0x804008,%eax
  8012e4:	8b 40 48             	mov    0x48(%eax),%eax
  8012e7:	83 ec 04             	sub    $0x4,%esp
  8012ea:	51                   	push   %ecx
  8012eb:	50                   	push   %eax
  8012ec:	68 58 2b 80 00       	push   $0x802b58
  8012f1:	e8 96 ef ff ff       	call   80028c <cprintf>
	*dev = 0;
  8012f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012f9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012ff:	83 c4 10             	add    $0x10,%esp
  801302:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801307:	c9                   	leave  
  801308:	c3                   	ret    

00801309 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801309:	55                   	push   %ebp
  80130a:	89 e5                	mov    %esp,%ebp
  80130c:	56                   	push   %esi
  80130d:	53                   	push   %ebx
  80130e:	83 ec 10             	sub    $0x10,%esp
  801311:	8b 75 08             	mov    0x8(%ebp),%esi
  801314:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801317:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131a:	50                   	push   %eax
  80131b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801321:	c1 e8 0c             	shr    $0xc,%eax
  801324:	50                   	push   %eax
  801325:	e8 36 ff ff ff       	call   801260 <fd_lookup>
  80132a:	83 c4 08             	add    $0x8,%esp
  80132d:	85 c0                	test   %eax,%eax
  80132f:	78 05                	js     801336 <fd_close+0x2d>
	    || fd != fd2)
  801331:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801334:	74 0c                	je     801342 <fd_close+0x39>
		return (must_exist ? r : 0);
  801336:	84 db                	test   %bl,%bl
  801338:	ba 00 00 00 00       	mov    $0x0,%edx
  80133d:	0f 44 c2             	cmove  %edx,%eax
  801340:	eb 41                	jmp    801383 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801342:	83 ec 08             	sub    $0x8,%esp
  801345:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801348:	50                   	push   %eax
  801349:	ff 36                	pushl  (%esi)
  80134b:	e8 66 ff ff ff       	call   8012b6 <dev_lookup>
  801350:	89 c3                	mov    %eax,%ebx
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	85 c0                	test   %eax,%eax
  801357:	78 1a                	js     801373 <fd_close+0x6a>
		if (dev->dev_close)
  801359:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80135f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801364:	85 c0                	test   %eax,%eax
  801366:	74 0b                	je     801373 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801368:	83 ec 0c             	sub    $0xc,%esp
  80136b:	56                   	push   %esi
  80136c:	ff d0                	call   *%eax
  80136e:	89 c3                	mov    %eax,%ebx
  801370:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801373:	83 ec 08             	sub    $0x8,%esp
  801376:	56                   	push   %esi
  801377:	6a 00                	push   $0x0
  801379:	e8 1b f9 ff ff       	call   800c99 <sys_page_unmap>
	return r;
  80137e:	83 c4 10             	add    $0x10,%esp
  801381:	89 d8                	mov    %ebx,%eax
}
  801383:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801386:	5b                   	pop    %ebx
  801387:	5e                   	pop    %esi
  801388:	5d                   	pop    %ebp
  801389:	c3                   	ret    

0080138a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80138a:	55                   	push   %ebp
  80138b:	89 e5                	mov    %esp,%ebp
  80138d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801390:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801393:	50                   	push   %eax
  801394:	ff 75 08             	pushl  0x8(%ebp)
  801397:	e8 c4 fe ff ff       	call   801260 <fd_lookup>
  80139c:	83 c4 08             	add    $0x8,%esp
  80139f:	85 c0                	test   %eax,%eax
  8013a1:	78 10                	js     8013b3 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013a3:	83 ec 08             	sub    $0x8,%esp
  8013a6:	6a 01                	push   $0x1
  8013a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8013ab:	e8 59 ff ff ff       	call   801309 <fd_close>
  8013b0:	83 c4 10             	add    $0x10,%esp
}
  8013b3:	c9                   	leave  
  8013b4:	c3                   	ret    

008013b5 <close_all>:

void
close_all(void)
{
  8013b5:	55                   	push   %ebp
  8013b6:	89 e5                	mov    %esp,%ebp
  8013b8:	53                   	push   %ebx
  8013b9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013bc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013c1:	83 ec 0c             	sub    $0xc,%esp
  8013c4:	53                   	push   %ebx
  8013c5:	e8 c0 ff ff ff       	call   80138a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013ca:	83 c3 01             	add    $0x1,%ebx
  8013cd:	83 c4 10             	add    $0x10,%esp
  8013d0:	83 fb 20             	cmp    $0x20,%ebx
  8013d3:	75 ec                	jne    8013c1 <close_all+0xc>
		close(i);
}
  8013d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d8:	c9                   	leave  
  8013d9:	c3                   	ret    

008013da <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013da:	55                   	push   %ebp
  8013db:	89 e5                	mov    %esp,%ebp
  8013dd:	57                   	push   %edi
  8013de:	56                   	push   %esi
  8013df:	53                   	push   %ebx
  8013e0:	83 ec 2c             	sub    $0x2c,%esp
  8013e3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013e6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013e9:	50                   	push   %eax
  8013ea:	ff 75 08             	pushl  0x8(%ebp)
  8013ed:	e8 6e fe ff ff       	call   801260 <fd_lookup>
  8013f2:	83 c4 08             	add    $0x8,%esp
  8013f5:	85 c0                	test   %eax,%eax
  8013f7:	0f 88 c1 00 00 00    	js     8014be <dup+0xe4>
		return r;
	close(newfdnum);
  8013fd:	83 ec 0c             	sub    $0xc,%esp
  801400:	56                   	push   %esi
  801401:	e8 84 ff ff ff       	call   80138a <close>

	newfd = INDEX2FD(newfdnum);
  801406:	89 f3                	mov    %esi,%ebx
  801408:	c1 e3 0c             	shl    $0xc,%ebx
  80140b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801411:	83 c4 04             	add    $0x4,%esp
  801414:	ff 75 e4             	pushl  -0x1c(%ebp)
  801417:	e8 de fd ff ff       	call   8011fa <fd2data>
  80141c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80141e:	89 1c 24             	mov    %ebx,(%esp)
  801421:	e8 d4 fd ff ff       	call   8011fa <fd2data>
  801426:	83 c4 10             	add    $0x10,%esp
  801429:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80142c:	89 f8                	mov    %edi,%eax
  80142e:	c1 e8 16             	shr    $0x16,%eax
  801431:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801438:	a8 01                	test   $0x1,%al
  80143a:	74 37                	je     801473 <dup+0x99>
  80143c:	89 f8                	mov    %edi,%eax
  80143e:	c1 e8 0c             	shr    $0xc,%eax
  801441:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801448:	f6 c2 01             	test   $0x1,%dl
  80144b:	74 26                	je     801473 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80144d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801454:	83 ec 0c             	sub    $0xc,%esp
  801457:	25 07 0e 00 00       	and    $0xe07,%eax
  80145c:	50                   	push   %eax
  80145d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801460:	6a 00                	push   $0x0
  801462:	57                   	push   %edi
  801463:	6a 00                	push   $0x0
  801465:	e8 ed f7 ff ff       	call   800c57 <sys_page_map>
  80146a:	89 c7                	mov    %eax,%edi
  80146c:	83 c4 20             	add    $0x20,%esp
  80146f:	85 c0                	test   %eax,%eax
  801471:	78 2e                	js     8014a1 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801473:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801476:	89 d0                	mov    %edx,%eax
  801478:	c1 e8 0c             	shr    $0xc,%eax
  80147b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801482:	83 ec 0c             	sub    $0xc,%esp
  801485:	25 07 0e 00 00       	and    $0xe07,%eax
  80148a:	50                   	push   %eax
  80148b:	53                   	push   %ebx
  80148c:	6a 00                	push   $0x0
  80148e:	52                   	push   %edx
  80148f:	6a 00                	push   $0x0
  801491:	e8 c1 f7 ff ff       	call   800c57 <sys_page_map>
  801496:	89 c7                	mov    %eax,%edi
  801498:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80149b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80149d:	85 ff                	test   %edi,%edi
  80149f:	79 1d                	jns    8014be <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014a1:	83 ec 08             	sub    $0x8,%esp
  8014a4:	53                   	push   %ebx
  8014a5:	6a 00                	push   $0x0
  8014a7:	e8 ed f7 ff ff       	call   800c99 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014ac:	83 c4 08             	add    $0x8,%esp
  8014af:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014b2:	6a 00                	push   $0x0
  8014b4:	e8 e0 f7 ff ff       	call   800c99 <sys_page_unmap>
	return r;
  8014b9:	83 c4 10             	add    $0x10,%esp
  8014bc:	89 f8                	mov    %edi,%eax
}
  8014be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014c1:	5b                   	pop    %ebx
  8014c2:	5e                   	pop    %esi
  8014c3:	5f                   	pop    %edi
  8014c4:	5d                   	pop    %ebp
  8014c5:	c3                   	ret    

008014c6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014c6:	55                   	push   %ebp
  8014c7:	89 e5                	mov    %esp,%ebp
  8014c9:	53                   	push   %ebx
  8014ca:	83 ec 14             	sub    $0x14,%esp
  8014cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d3:	50                   	push   %eax
  8014d4:	53                   	push   %ebx
  8014d5:	e8 86 fd ff ff       	call   801260 <fd_lookup>
  8014da:	83 c4 08             	add    $0x8,%esp
  8014dd:	89 c2                	mov    %eax,%edx
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	78 6d                	js     801550 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e3:	83 ec 08             	sub    $0x8,%esp
  8014e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e9:	50                   	push   %eax
  8014ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ed:	ff 30                	pushl  (%eax)
  8014ef:	e8 c2 fd ff ff       	call   8012b6 <dev_lookup>
  8014f4:	83 c4 10             	add    $0x10,%esp
  8014f7:	85 c0                	test   %eax,%eax
  8014f9:	78 4c                	js     801547 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014fe:	8b 42 08             	mov    0x8(%edx),%eax
  801501:	83 e0 03             	and    $0x3,%eax
  801504:	83 f8 01             	cmp    $0x1,%eax
  801507:	75 21                	jne    80152a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801509:	a1 08 40 80 00       	mov    0x804008,%eax
  80150e:	8b 40 48             	mov    0x48(%eax),%eax
  801511:	83 ec 04             	sub    $0x4,%esp
  801514:	53                   	push   %ebx
  801515:	50                   	push   %eax
  801516:	68 99 2b 80 00       	push   $0x802b99
  80151b:	e8 6c ed ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  801520:	83 c4 10             	add    $0x10,%esp
  801523:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801528:	eb 26                	jmp    801550 <read+0x8a>
	}
	if (!dev->dev_read)
  80152a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80152d:	8b 40 08             	mov    0x8(%eax),%eax
  801530:	85 c0                	test   %eax,%eax
  801532:	74 17                	je     80154b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801534:	83 ec 04             	sub    $0x4,%esp
  801537:	ff 75 10             	pushl  0x10(%ebp)
  80153a:	ff 75 0c             	pushl  0xc(%ebp)
  80153d:	52                   	push   %edx
  80153e:	ff d0                	call   *%eax
  801540:	89 c2                	mov    %eax,%edx
  801542:	83 c4 10             	add    $0x10,%esp
  801545:	eb 09                	jmp    801550 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801547:	89 c2                	mov    %eax,%edx
  801549:	eb 05                	jmp    801550 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80154b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801550:	89 d0                	mov    %edx,%eax
  801552:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801555:	c9                   	leave  
  801556:	c3                   	ret    

00801557 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801557:	55                   	push   %ebp
  801558:	89 e5                	mov    %esp,%ebp
  80155a:	57                   	push   %edi
  80155b:	56                   	push   %esi
  80155c:	53                   	push   %ebx
  80155d:	83 ec 0c             	sub    $0xc,%esp
  801560:	8b 7d 08             	mov    0x8(%ebp),%edi
  801563:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801566:	bb 00 00 00 00       	mov    $0x0,%ebx
  80156b:	eb 21                	jmp    80158e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80156d:	83 ec 04             	sub    $0x4,%esp
  801570:	89 f0                	mov    %esi,%eax
  801572:	29 d8                	sub    %ebx,%eax
  801574:	50                   	push   %eax
  801575:	89 d8                	mov    %ebx,%eax
  801577:	03 45 0c             	add    0xc(%ebp),%eax
  80157a:	50                   	push   %eax
  80157b:	57                   	push   %edi
  80157c:	e8 45 ff ff ff       	call   8014c6 <read>
		if (m < 0)
  801581:	83 c4 10             	add    $0x10,%esp
  801584:	85 c0                	test   %eax,%eax
  801586:	78 10                	js     801598 <readn+0x41>
			return m;
		if (m == 0)
  801588:	85 c0                	test   %eax,%eax
  80158a:	74 0a                	je     801596 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80158c:	01 c3                	add    %eax,%ebx
  80158e:	39 f3                	cmp    %esi,%ebx
  801590:	72 db                	jb     80156d <readn+0x16>
  801592:	89 d8                	mov    %ebx,%eax
  801594:	eb 02                	jmp    801598 <readn+0x41>
  801596:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801598:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80159b:	5b                   	pop    %ebx
  80159c:	5e                   	pop    %esi
  80159d:	5f                   	pop    %edi
  80159e:	5d                   	pop    %ebp
  80159f:	c3                   	ret    

008015a0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015a0:	55                   	push   %ebp
  8015a1:	89 e5                	mov    %esp,%ebp
  8015a3:	53                   	push   %ebx
  8015a4:	83 ec 14             	sub    $0x14,%esp
  8015a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ad:	50                   	push   %eax
  8015ae:	53                   	push   %ebx
  8015af:	e8 ac fc ff ff       	call   801260 <fd_lookup>
  8015b4:	83 c4 08             	add    $0x8,%esp
  8015b7:	89 c2                	mov    %eax,%edx
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	78 68                	js     801625 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015bd:	83 ec 08             	sub    $0x8,%esp
  8015c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c3:	50                   	push   %eax
  8015c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c7:	ff 30                	pushl  (%eax)
  8015c9:	e8 e8 fc ff ff       	call   8012b6 <dev_lookup>
  8015ce:	83 c4 10             	add    $0x10,%esp
  8015d1:	85 c0                	test   %eax,%eax
  8015d3:	78 47                	js     80161c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015dc:	75 21                	jne    8015ff <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015de:	a1 08 40 80 00       	mov    0x804008,%eax
  8015e3:	8b 40 48             	mov    0x48(%eax),%eax
  8015e6:	83 ec 04             	sub    $0x4,%esp
  8015e9:	53                   	push   %ebx
  8015ea:	50                   	push   %eax
  8015eb:	68 b5 2b 80 00       	push   $0x802bb5
  8015f0:	e8 97 ec ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  8015f5:	83 c4 10             	add    $0x10,%esp
  8015f8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015fd:	eb 26                	jmp    801625 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801602:	8b 52 0c             	mov    0xc(%edx),%edx
  801605:	85 d2                	test   %edx,%edx
  801607:	74 17                	je     801620 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801609:	83 ec 04             	sub    $0x4,%esp
  80160c:	ff 75 10             	pushl  0x10(%ebp)
  80160f:	ff 75 0c             	pushl  0xc(%ebp)
  801612:	50                   	push   %eax
  801613:	ff d2                	call   *%edx
  801615:	89 c2                	mov    %eax,%edx
  801617:	83 c4 10             	add    $0x10,%esp
  80161a:	eb 09                	jmp    801625 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161c:	89 c2                	mov    %eax,%edx
  80161e:	eb 05                	jmp    801625 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801620:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801625:	89 d0                	mov    %edx,%eax
  801627:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162a:	c9                   	leave  
  80162b:	c3                   	ret    

0080162c <seek>:

int
seek(int fdnum, off_t offset)
{
  80162c:	55                   	push   %ebp
  80162d:	89 e5                	mov    %esp,%ebp
  80162f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801632:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801635:	50                   	push   %eax
  801636:	ff 75 08             	pushl  0x8(%ebp)
  801639:	e8 22 fc ff ff       	call   801260 <fd_lookup>
  80163e:	83 c4 08             	add    $0x8,%esp
  801641:	85 c0                	test   %eax,%eax
  801643:	78 0e                	js     801653 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801645:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801648:	8b 55 0c             	mov    0xc(%ebp),%edx
  80164b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80164e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801653:	c9                   	leave  
  801654:	c3                   	ret    

00801655 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801655:	55                   	push   %ebp
  801656:	89 e5                	mov    %esp,%ebp
  801658:	53                   	push   %ebx
  801659:	83 ec 14             	sub    $0x14,%esp
  80165c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80165f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801662:	50                   	push   %eax
  801663:	53                   	push   %ebx
  801664:	e8 f7 fb ff ff       	call   801260 <fd_lookup>
  801669:	83 c4 08             	add    $0x8,%esp
  80166c:	89 c2                	mov    %eax,%edx
  80166e:	85 c0                	test   %eax,%eax
  801670:	78 65                	js     8016d7 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801672:	83 ec 08             	sub    $0x8,%esp
  801675:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801678:	50                   	push   %eax
  801679:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167c:	ff 30                	pushl  (%eax)
  80167e:	e8 33 fc ff ff       	call   8012b6 <dev_lookup>
  801683:	83 c4 10             	add    $0x10,%esp
  801686:	85 c0                	test   %eax,%eax
  801688:	78 44                	js     8016ce <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80168a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801691:	75 21                	jne    8016b4 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801693:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801698:	8b 40 48             	mov    0x48(%eax),%eax
  80169b:	83 ec 04             	sub    $0x4,%esp
  80169e:	53                   	push   %ebx
  80169f:	50                   	push   %eax
  8016a0:	68 78 2b 80 00       	push   $0x802b78
  8016a5:	e8 e2 eb ff ff       	call   80028c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016aa:	83 c4 10             	add    $0x10,%esp
  8016ad:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016b2:	eb 23                	jmp    8016d7 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016b7:	8b 52 18             	mov    0x18(%edx),%edx
  8016ba:	85 d2                	test   %edx,%edx
  8016bc:	74 14                	je     8016d2 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016be:	83 ec 08             	sub    $0x8,%esp
  8016c1:	ff 75 0c             	pushl  0xc(%ebp)
  8016c4:	50                   	push   %eax
  8016c5:	ff d2                	call   *%edx
  8016c7:	89 c2                	mov    %eax,%edx
  8016c9:	83 c4 10             	add    $0x10,%esp
  8016cc:	eb 09                	jmp    8016d7 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ce:	89 c2                	mov    %eax,%edx
  8016d0:	eb 05                	jmp    8016d7 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016d2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016d7:	89 d0                	mov    %edx,%eax
  8016d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016dc:	c9                   	leave  
  8016dd:	c3                   	ret    

008016de <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
  8016e1:	53                   	push   %ebx
  8016e2:	83 ec 14             	sub    $0x14,%esp
  8016e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016eb:	50                   	push   %eax
  8016ec:	ff 75 08             	pushl  0x8(%ebp)
  8016ef:	e8 6c fb ff ff       	call   801260 <fd_lookup>
  8016f4:	83 c4 08             	add    $0x8,%esp
  8016f7:	89 c2                	mov    %eax,%edx
  8016f9:	85 c0                	test   %eax,%eax
  8016fb:	78 58                	js     801755 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fd:	83 ec 08             	sub    $0x8,%esp
  801700:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801703:	50                   	push   %eax
  801704:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801707:	ff 30                	pushl  (%eax)
  801709:	e8 a8 fb ff ff       	call   8012b6 <dev_lookup>
  80170e:	83 c4 10             	add    $0x10,%esp
  801711:	85 c0                	test   %eax,%eax
  801713:	78 37                	js     80174c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801715:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801718:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80171c:	74 32                	je     801750 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80171e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801721:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801728:	00 00 00 
	stat->st_isdir = 0;
  80172b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801732:	00 00 00 
	stat->st_dev = dev;
  801735:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80173b:	83 ec 08             	sub    $0x8,%esp
  80173e:	53                   	push   %ebx
  80173f:	ff 75 f0             	pushl  -0x10(%ebp)
  801742:	ff 50 14             	call   *0x14(%eax)
  801745:	89 c2                	mov    %eax,%edx
  801747:	83 c4 10             	add    $0x10,%esp
  80174a:	eb 09                	jmp    801755 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174c:	89 c2                	mov    %eax,%edx
  80174e:	eb 05                	jmp    801755 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801750:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801755:	89 d0                	mov    %edx,%eax
  801757:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80175a:	c9                   	leave  
  80175b:	c3                   	ret    

0080175c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	56                   	push   %esi
  801760:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801761:	83 ec 08             	sub    $0x8,%esp
  801764:	6a 00                	push   $0x0
  801766:	ff 75 08             	pushl  0x8(%ebp)
  801769:	e8 d6 01 00 00       	call   801944 <open>
  80176e:	89 c3                	mov    %eax,%ebx
  801770:	83 c4 10             	add    $0x10,%esp
  801773:	85 c0                	test   %eax,%eax
  801775:	78 1b                	js     801792 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801777:	83 ec 08             	sub    $0x8,%esp
  80177a:	ff 75 0c             	pushl  0xc(%ebp)
  80177d:	50                   	push   %eax
  80177e:	e8 5b ff ff ff       	call   8016de <fstat>
  801783:	89 c6                	mov    %eax,%esi
	close(fd);
  801785:	89 1c 24             	mov    %ebx,(%esp)
  801788:	e8 fd fb ff ff       	call   80138a <close>
	return r;
  80178d:	83 c4 10             	add    $0x10,%esp
  801790:	89 f0                	mov    %esi,%eax
}
  801792:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801795:	5b                   	pop    %ebx
  801796:	5e                   	pop    %esi
  801797:	5d                   	pop    %ebp
  801798:	c3                   	ret    

00801799 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801799:	55                   	push   %ebp
  80179a:	89 e5                	mov    %esp,%ebp
  80179c:	56                   	push   %esi
  80179d:	53                   	push   %ebx
  80179e:	89 c6                	mov    %eax,%esi
  8017a0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017a2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017a9:	75 12                	jne    8017bd <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017ab:	83 ec 0c             	sub    $0xc,%esp
  8017ae:	6a 01                	push   $0x1
  8017b0:	e8 fc f9 ff ff       	call   8011b1 <ipc_find_env>
  8017b5:	a3 00 40 80 00       	mov    %eax,0x804000
  8017ba:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017bd:	6a 07                	push   $0x7
  8017bf:	68 00 50 80 00       	push   $0x805000
  8017c4:	56                   	push   %esi
  8017c5:	ff 35 00 40 80 00    	pushl  0x804000
  8017cb:	e8 8d f9 ff ff       	call   80115d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017d0:	83 c4 0c             	add    $0xc,%esp
  8017d3:	6a 00                	push   $0x0
  8017d5:	53                   	push   %ebx
  8017d6:	6a 00                	push   $0x0
  8017d8:	e8 19 f9 ff ff       	call   8010f6 <ipc_recv>
}
  8017dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e0:	5b                   	pop    %ebx
  8017e1:	5e                   	pop    %esi
  8017e2:	5d                   	pop    %ebp
  8017e3:	c3                   	ret    

008017e4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017e4:	55                   	push   %ebp
  8017e5:	89 e5                	mov    %esp,%ebp
  8017e7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801802:	b8 02 00 00 00       	mov    $0x2,%eax
  801807:	e8 8d ff ff ff       	call   801799 <fsipc>
}
  80180c:	c9                   	leave  
  80180d:	c3                   	ret    

0080180e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80180e:	55                   	push   %ebp
  80180f:	89 e5                	mov    %esp,%ebp
  801811:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801814:	8b 45 08             	mov    0x8(%ebp),%eax
  801817:	8b 40 0c             	mov    0xc(%eax),%eax
  80181a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80181f:	ba 00 00 00 00       	mov    $0x0,%edx
  801824:	b8 06 00 00 00       	mov    $0x6,%eax
  801829:	e8 6b ff ff ff       	call   801799 <fsipc>
}
  80182e:	c9                   	leave  
  80182f:	c3                   	ret    

00801830 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	53                   	push   %ebx
  801834:	83 ec 04             	sub    $0x4,%esp
  801837:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80183a:	8b 45 08             	mov    0x8(%ebp),%eax
  80183d:	8b 40 0c             	mov    0xc(%eax),%eax
  801840:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801845:	ba 00 00 00 00       	mov    $0x0,%edx
  80184a:	b8 05 00 00 00       	mov    $0x5,%eax
  80184f:	e8 45 ff ff ff       	call   801799 <fsipc>
  801854:	85 c0                	test   %eax,%eax
  801856:	78 2c                	js     801884 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801858:	83 ec 08             	sub    $0x8,%esp
  80185b:	68 00 50 80 00       	push   $0x805000
  801860:	53                   	push   %ebx
  801861:	e8 ab ef ff ff       	call   800811 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801866:	a1 80 50 80 00       	mov    0x805080,%eax
  80186b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801871:	a1 84 50 80 00       	mov    0x805084,%eax
  801876:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80187c:	83 c4 10             	add    $0x10,%esp
  80187f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801884:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801887:	c9                   	leave  
  801888:	c3                   	ret    

00801889 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801889:	55                   	push   %ebp
  80188a:	89 e5                	mov    %esp,%ebp
  80188c:	83 ec 0c             	sub    $0xc,%esp
  80188f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801892:	8b 55 08             	mov    0x8(%ebp),%edx
  801895:	8b 52 0c             	mov    0xc(%edx),%edx
  801898:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80189e:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018a3:	50                   	push   %eax
  8018a4:	ff 75 0c             	pushl  0xc(%ebp)
  8018a7:	68 08 50 80 00       	push   $0x805008
  8018ac:	e8 f2 f0 ff ff       	call   8009a3 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8018b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b6:	b8 04 00 00 00       	mov    $0x4,%eax
  8018bb:	e8 d9 fe ff ff       	call   801799 <fsipc>

}
  8018c0:	c9                   	leave  
  8018c1:	c3                   	ret    

008018c2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018c2:	55                   	push   %ebp
  8018c3:	89 e5                	mov    %esp,%ebp
  8018c5:	56                   	push   %esi
  8018c6:	53                   	push   %ebx
  8018c7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018d5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018db:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e0:	b8 03 00 00 00       	mov    $0x3,%eax
  8018e5:	e8 af fe ff ff       	call   801799 <fsipc>
  8018ea:	89 c3                	mov    %eax,%ebx
  8018ec:	85 c0                	test   %eax,%eax
  8018ee:	78 4b                	js     80193b <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018f0:	39 c6                	cmp    %eax,%esi
  8018f2:	73 16                	jae    80190a <devfile_read+0x48>
  8018f4:	68 e8 2b 80 00       	push   $0x802be8
  8018f9:	68 ef 2b 80 00       	push   $0x802bef
  8018fe:	6a 7c                	push   $0x7c
  801900:	68 04 2c 80 00       	push   $0x802c04
  801905:	e8 24 0a 00 00       	call   80232e <_panic>
	assert(r <= PGSIZE);
  80190a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80190f:	7e 16                	jle    801927 <devfile_read+0x65>
  801911:	68 0f 2c 80 00       	push   $0x802c0f
  801916:	68 ef 2b 80 00       	push   $0x802bef
  80191b:	6a 7d                	push   $0x7d
  80191d:	68 04 2c 80 00       	push   $0x802c04
  801922:	e8 07 0a 00 00       	call   80232e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801927:	83 ec 04             	sub    $0x4,%esp
  80192a:	50                   	push   %eax
  80192b:	68 00 50 80 00       	push   $0x805000
  801930:	ff 75 0c             	pushl  0xc(%ebp)
  801933:	e8 6b f0 ff ff       	call   8009a3 <memmove>
	return r;
  801938:	83 c4 10             	add    $0x10,%esp
}
  80193b:	89 d8                	mov    %ebx,%eax
  80193d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801940:	5b                   	pop    %ebx
  801941:	5e                   	pop    %esi
  801942:	5d                   	pop    %ebp
  801943:	c3                   	ret    

00801944 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
  801947:	53                   	push   %ebx
  801948:	83 ec 20             	sub    $0x20,%esp
  80194b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80194e:	53                   	push   %ebx
  80194f:	e8 84 ee ff ff       	call   8007d8 <strlen>
  801954:	83 c4 10             	add    $0x10,%esp
  801957:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80195c:	7f 67                	jg     8019c5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80195e:	83 ec 0c             	sub    $0xc,%esp
  801961:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801964:	50                   	push   %eax
  801965:	e8 a7 f8 ff ff       	call   801211 <fd_alloc>
  80196a:	83 c4 10             	add    $0x10,%esp
		return r;
  80196d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80196f:	85 c0                	test   %eax,%eax
  801971:	78 57                	js     8019ca <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801973:	83 ec 08             	sub    $0x8,%esp
  801976:	53                   	push   %ebx
  801977:	68 00 50 80 00       	push   $0x805000
  80197c:	e8 90 ee ff ff       	call   800811 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801981:	8b 45 0c             	mov    0xc(%ebp),%eax
  801984:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801989:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80198c:	b8 01 00 00 00       	mov    $0x1,%eax
  801991:	e8 03 fe ff ff       	call   801799 <fsipc>
  801996:	89 c3                	mov    %eax,%ebx
  801998:	83 c4 10             	add    $0x10,%esp
  80199b:	85 c0                	test   %eax,%eax
  80199d:	79 14                	jns    8019b3 <open+0x6f>
		fd_close(fd, 0);
  80199f:	83 ec 08             	sub    $0x8,%esp
  8019a2:	6a 00                	push   $0x0
  8019a4:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a7:	e8 5d f9 ff ff       	call   801309 <fd_close>
		return r;
  8019ac:	83 c4 10             	add    $0x10,%esp
  8019af:	89 da                	mov    %ebx,%edx
  8019b1:	eb 17                	jmp    8019ca <open+0x86>
	}

	return fd2num(fd);
  8019b3:	83 ec 0c             	sub    $0xc,%esp
  8019b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b9:	e8 2c f8 ff ff       	call   8011ea <fd2num>
  8019be:	89 c2                	mov    %eax,%edx
  8019c0:	83 c4 10             	add    $0x10,%esp
  8019c3:	eb 05                	jmp    8019ca <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019c5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019ca:	89 d0                	mov    %edx,%eax
  8019cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019cf:	c9                   	leave  
  8019d0:	c3                   	ret    

008019d1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019d1:	55                   	push   %ebp
  8019d2:	89 e5                	mov    %esp,%ebp
  8019d4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019dc:	b8 08 00 00 00       	mov    $0x8,%eax
  8019e1:	e8 b3 fd ff ff       	call   801799 <fsipc>
}
  8019e6:	c9                   	leave  
  8019e7:	c3                   	ret    

008019e8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019e8:	55                   	push   %ebp
  8019e9:	89 e5                	mov    %esp,%ebp
  8019eb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019ee:	68 1b 2c 80 00       	push   $0x802c1b
  8019f3:	ff 75 0c             	pushl  0xc(%ebp)
  8019f6:	e8 16 ee ff ff       	call   800811 <strcpy>
	return 0;
}
  8019fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801a00:	c9                   	leave  
  801a01:	c3                   	ret    

00801a02 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a02:	55                   	push   %ebp
  801a03:	89 e5                	mov    %esp,%ebp
  801a05:	53                   	push   %ebx
  801a06:	83 ec 10             	sub    $0x10,%esp
  801a09:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a0c:	53                   	push   %ebx
  801a0d:	e8 cd 09 00 00       	call   8023df <pageref>
  801a12:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a15:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a1a:	83 f8 01             	cmp    $0x1,%eax
  801a1d:	75 10                	jne    801a2f <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a1f:	83 ec 0c             	sub    $0xc,%esp
  801a22:	ff 73 0c             	pushl  0xc(%ebx)
  801a25:	e8 c0 02 00 00       	call   801cea <nsipc_close>
  801a2a:	89 c2                	mov    %eax,%edx
  801a2c:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a2f:	89 d0                	mov    %edx,%eax
  801a31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a34:	c9                   	leave  
  801a35:	c3                   	ret    

00801a36 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a36:	55                   	push   %ebp
  801a37:	89 e5                	mov    %esp,%ebp
  801a39:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a3c:	6a 00                	push   $0x0
  801a3e:	ff 75 10             	pushl  0x10(%ebp)
  801a41:	ff 75 0c             	pushl  0xc(%ebp)
  801a44:	8b 45 08             	mov    0x8(%ebp),%eax
  801a47:	ff 70 0c             	pushl  0xc(%eax)
  801a4a:	e8 78 03 00 00       	call   801dc7 <nsipc_send>
}
  801a4f:	c9                   	leave  
  801a50:	c3                   	ret    

00801a51 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a51:	55                   	push   %ebp
  801a52:	89 e5                	mov    %esp,%ebp
  801a54:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a57:	6a 00                	push   $0x0
  801a59:	ff 75 10             	pushl  0x10(%ebp)
  801a5c:	ff 75 0c             	pushl  0xc(%ebp)
  801a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a62:	ff 70 0c             	pushl  0xc(%eax)
  801a65:	e8 f1 02 00 00       	call   801d5b <nsipc_recv>
}
  801a6a:	c9                   	leave  
  801a6b:	c3                   	ret    

00801a6c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a72:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a75:	52                   	push   %edx
  801a76:	50                   	push   %eax
  801a77:	e8 e4 f7 ff ff       	call   801260 <fd_lookup>
  801a7c:	83 c4 10             	add    $0x10,%esp
  801a7f:	85 c0                	test   %eax,%eax
  801a81:	78 17                	js     801a9a <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a86:	8b 0d 28 30 80 00    	mov    0x803028,%ecx
  801a8c:	39 08                	cmp    %ecx,(%eax)
  801a8e:	75 05                	jne    801a95 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a90:	8b 40 0c             	mov    0xc(%eax),%eax
  801a93:	eb 05                	jmp    801a9a <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a95:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a9a:	c9                   	leave  
  801a9b:	c3                   	ret    

00801a9c <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	56                   	push   %esi
  801aa0:	53                   	push   %ebx
  801aa1:	83 ec 1c             	sub    $0x1c,%esp
  801aa4:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801aa6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa9:	50                   	push   %eax
  801aaa:	e8 62 f7 ff ff       	call   801211 <fd_alloc>
  801aaf:	89 c3                	mov    %eax,%ebx
  801ab1:	83 c4 10             	add    $0x10,%esp
  801ab4:	85 c0                	test   %eax,%eax
  801ab6:	78 1b                	js     801ad3 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801ab8:	83 ec 04             	sub    $0x4,%esp
  801abb:	68 07 04 00 00       	push   $0x407
  801ac0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac3:	6a 00                	push   $0x0
  801ac5:	e8 4a f1 ff ff       	call   800c14 <sys_page_alloc>
  801aca:	89 c3                	mov    %eax,%ebx
  801acc:	83 c4 10             	add    $0x10,%esp
  801acf:	85 c0                	test   %eax,%eax
  801ad1:	79 10                	jns    801ae3 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801ad3:	83 ec 0c             	sub    $0xc,%esp
  801ad6:	56                   	push   %esi
  801ad7:	e8 0e 02 00 00       	call   801cea <nsipc_close>
		return r;
  801adc:	83 c4 10             	add    $0x10,%esp
  801adf:	89 d8                	mov    %ebx,%eax
  801ae1:	eb 24                	jmp    801b07 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801ae3:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aec:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801af8:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801afb:	83 ec 0c             	sub    $0xc,%esp
  801afe:	50                   	push   %eax
  801aff:	e8 e6 f6 ff ff       	call   8011ea <fd2num>
  801b04:	83 c4 10             	add    $0x10,%esp
}
  801b07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b0a:	5b                   	pop    %ebx
  801b0b:	5e                   	pop    %esi
  801b0c:	5d                   	pop    %ebp
  801b0d:	c3                   	ret    

00801b0e <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b0e:	55                   	push   %ebp
  801b0f:	89 e5                	mov    %esp,%ebp
  801b11:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b14:	8b 45 08             	mov    0x8(%ebp),%eax
  801b17:	e8 50 ff ff ff       	call   801a6c <fd2sockid>
		return r;
  801b1c:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b1e:	85 c0                	test   %eax,%eax
  801b20:	78 1f                	js     801b41 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b22:	83 ec 04             	sub    $0x4,%esp
  801b25:	ff 75 10             	pushl  0x10(%ebp)
  801b28:	ff 75 0c             	pushl  0xc(%ebp)
  801b2b:	50                   	push   %eax
  801b2c:	e8 12 01 00 00       	call   801c43 <nsipc_accept>
  801b31:	83 c4 10             	add    $0x10,%esp
		return r;
  801b34:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b36:	85 c0                	test   %eax,%eax
  801b38:	78 07                	js     801b41 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b3a:	e8 5d ff ff ff       	call   801a9c <alloc_sockfd>
  801b3f:	89 c1                	mov    %eax,%ecx
}
  801b41:	89 c8                	mov    %ecx,%eax
  801b43:	c9                   	leave  
  801b44:	c3                   	ret    

00801b45 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b45:	55                   	push   %ebp
  801b46:	89 e5                	mov    %esp,%ebp
  801b48:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4e:	e8 19 ff ff ff       	call   801a6c <fd2sockid>
  801b53:	85 c0                	test   %eax,%eax
  801b55:	78 12                	js     801b69 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801b57:	83 ec 04             	sub    $0x4,%esp
  801b5a:	ff 75 10             	pushl  0x10(%ebp)
  801b5d:	ff 75 0c             	pushl  0xc(%ebp)
  801b60:	50                   	push   %eax
  801b61:	e8 2d 01 00 00       	call   801c93 <nsipc_bind>
  801b66:	83 c4 10             	add    $0x10,%esp
}
  801b69:	c9                   	leave  
  801b6a:	c3                   	ret    

00801b6b <shutdown>:

int
shutdown(int s, int how)
{
  801b6b:	55                   	push   %ebp
  801b6c:	89 e5                	mov    %esp,%ebp
  801b6e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b71:	8b 45 08             	mov    0x8(%ebp),%eax
  801b74:	e8 f3 fe ff ff       	call   801a6c <fd2sockid>
  801b79:	85 c0                	test   %eax,%eax
  801b7b:	78 0f                	js     801b8c <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b7d:	83 ec 08             	sub    $0x8,%esp
  801b80:	ff 75 0c             	pushl  0xc(%ebp)
  801b83:	50                   	push   %eax
  801b84:	e8 3f 01 00 00       	call   801cc8 <nsipc_shutdown>
  801b89:	83 c4 10             	add    $0x10,%esp
}
  801b8c:	c9                   	leave  
  801b8d:	c3                   	ret    

00801b8e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b8e:	55                   	push   %ebp
  801b8f:	89 e5                	mov    %esp,%ebp
  801b91:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b94:	8b 45 08             	mov    0x8(%ebp),%eax
  801b97:	e8 d0 fe ff ff       	call   801a6c <fd2sockid>
  801b9c:	85 c0                	test   %eax,%eax
  801b9e:	78 12                	js     801bb2 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801ba0:	83 ec 04             	sub    $0x4,%esp
  801ba3:	ff 75 10             	pushl  0x10(%ebp)
  801ba6:	ff 75 0c             	pushl  0xc(%ebp)
  801ba9:	50                   	push   %eax
  801baa:	e8 55 01 00 00       	call   801d04 <nsipc_connect>
  801baf:	83 c4 10             	add    $0x10,%esp
}
  801bb2:	c9                   	leave  
  801bb3:	c3                   	ret    

00801bb4 <listen>:

int
listen(int s, int backlog)
{
  801bb4:	55                   	push   %ebp
  801bb5:	89 e5                	mov    %esp,%ebp
  801bb7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bba:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbd:	e8 aa fe ff ff       	call   801a6c <fd2sockid>
  801bc2:	85 c0                	test   %eax,%eax
  801bc4:	78 0f                	js     801bd5 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801bc6:	83 ec 08             	sub    $0x8,%esp
  801bc9:	ff 75 0c             	pushl  0xc(%ebp)
  801bcc:	50                   	push   %eax
  801bcd:	e8 67 01 00 00       	call   801d39 <nsipc_listen>
  801bd2:	83 c4 10             	add    $0x10,%esp
}
  801bd5:	c9                   	leave  
  801bd6:	c3                   	ret    

00801bd7 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801bd7:	55                   	push   %ebp
  801bd8:	89 e5                	mov    %esp,%ebp
  801bda:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bdd:	ff 75 10             	pushl  0x10(%ebp)
  801be0:	ff 75 0c             	pushl  0xc(%ebp)
  801be3:	ff 75 08             	pushl  0x8(%ebp)
  801be6:	e8 3a 02 00 00       	call   801e25 <nsipc_socket>
  801beb:	83 c4 10             	add    $0x10,%esp
  801bee:	85 c0                	test   %eax,%eax
  801bf0:	78 05                	js     801bf7 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801bf2:	e8 a5 fe ff ff       	call   801a9c <alloc_sockfd>
}
  801bf7:	c9                   	leave  
  801bf8:	c3                   	ret    

00801bf9 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801bf9:	55                   	push   %ebp
  801bfa:	89 e5                	mov    %esp,%ebp
  801bfc:	53                   	push   %ebx
  801bfd:	83 ec 04             	sub    $0x4,%esp
  801c00:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c02:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c09:	75 12                	jne    801c1d <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c0b:	83 ec 0c             	sub    $0xc,%esp
  801c0e:	6a 02                	push   $0x2
  801c10:	e8 9c f5 ff ff       	call   8011b1 <ipc_find_env>
  801c15:	a3 04 40 80 00       	mov    %eax,0x804004
  801c1a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c1d:	6a 07                	push   $0x7
  801c1f:	68 00 60 80 00       	push   $0x806000
  801c24:	53                   	push   %ebx
  801c25:	ff 35 04 40 80 00    	pushl  0x804004
  801c2b:	e8 2d f5 ff ff       	call   80115d <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c30:	83 c4 0c             	add    $0xc,%esp
  801c33:	6a 00                	push   $0x0
  801c35:	6a 00                	push   $0x0
  801c37:	6a 00                	push   $0x0
  801c39:	e8 b8 f4 ff ff       	call   8010f6 <ipc_recv>
}
  801c3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c41:	c9                   	leave  
  801c42:	c3                   	ret    

00801c43 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c43:	55                   	push   %ebp
  801c44:	89 e5                	mov    %esp,%ebp
  801c46:	56                   	push   %esi
  801c47:	53                   	push   %ebx
  801c48:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c53:	8b 06                	mov    (%esi),%eax
  801c55:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c5a:	b8 01 00 00 00       	mov    $0x1,%eax
  801c5f:	e8 95 ff ff ff       	call   801bf9 <nsipc>
  801c64:	89 c3                	mov    %eax,%ebx
  801c66:	85 c0                	test   %eax,%eax
  801c68:	78 20                	js     801c8a <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c6a:	83 ec 04             	sub    $0x4,%esp
  801c6d:	ff 35 10 60 80 00    	pushl  0x806010
  801c73:	68 00 60 80 00       	push   $0x806000
  801c78:	ff 75 0c             	pushl  0xc(%ebp)
  801c7b:	e8 23 ed ff ff       	call   8009a3 <memmove>
		*addrlen = ret->ret_addrlen;
  801c80:	a1 10 60 80 00       	mov    0x806010,%eax
  801c85:	89 06                	mov    %eax,(%esi)
  801c87:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c8a:	89 d8                	mov    %ebx,%eax
  801c8c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c8f:	5b                   	pop    %ebx
  801c90:	5e                   	pop    %esi
  801c91:	5d                   	pop    %ebp
  801c92:	c3                   	ret    

00801c93 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	53                   	push   %ebx
  801c97:	83 ec 08             	sub    $0x8,%esp
  801c9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca0:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801ca5:	53                   	push   %ebx
  801ca6:	ff 75 0c             	pushl  0xc(%ebp)
  801ca9:	68 04 60 80 00       	push   $0x806004
  801cae:	e8 f0 ec ff ff       	call   8009a3 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801cb3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801cb9:	b8 02 00 00 00       	mov    $0x2,%eax
  801cbe:	e8 36 ff ff ff       	call   801bf9 <nsipc>
}
  801cc3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cc6:	c9                   	leave  
  801cc7:	c3                   	ret    

00801cc8 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801cc8:	55                   	push   %ebp
  801cc9:	89 e5                	mov    %esp,%ebp
  801ccb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801cce:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801cd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd9:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801cde:	b8 03 00 00 00       	mov    $0x3,%eax
  801ce3:	e8 11 ff ff ff       	call   801bf9 <nsipc>
}
  801ce8:	c9                   	leave  
  801ce9:	c3                   	ret    

00801cea <nsipc_close>:

int
nsipc_close(int s)
{
  801cea:	55                   	push   %ebp
  801ceb:	89 e5                	mov    %esp,%ebp
  801ced:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf3:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801cf8:	b8 04 00 00 00       	mov    $0x4,%eax
  801cfd:	e8 f7 fe ff ff       	call   801bf9 <nsipc>
}
  801d02:	c9                   	leave  
  801d03:	c3                   	ret    

00801d04 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d04:	55                   	push   %ebp
  801d05:	89 e5                	mov    %esp,%ebp
  801d07:	53                   	push   %ebx
  801d08:	83 ec 08             	sub    $0x8,%esp
  801d0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d11:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d16:	53                   	push   %ebx
  801d17:	ff 75 0c             	pushl  0xc(%ebp)
  801d1a:	68 04 60 80 00       	push   $0x806004
  801d1f:	e8 7f ec ff ff       	call   8009a3 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d24:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d2a:	b8 05 00 00 00       	mov    $0x5,%eax
  801d2f:	e8 c5 fe ff ff       	call   801bf9 <nsipc>
}
  801d34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d37:	c9                   	leave  
  801d38:	c3                   	ret    

00801d39 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d39:	55                   	push   %ebp
  801d3a:	89 e5                	mov    %esp,%ebp
  801d3c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d42:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d47:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d4a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d4f:	b8 06 00 00 00       	mov    $0x6,%eax
  801d54:	e8 a0 fe ff ff       	call   801bf9 <nsipc>
}
  801d59:	c9                   	leave  
  801d5a:	c3                   	ret    

00801d5b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	56                   	push   %esi
  801d5f:	53                   	push   %ebx
  801d60:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d63:	8b 45 08             	mov    0x8(%ebp),%eax
  801d66:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d6b:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d71:	8b 45 14             	mov    0x14(%ebp),%eax
  801d74:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d79:	b8 07 00 00 00       	mov    $0x7,%eax
  801d7e:	e8 76 fe ff ff       	call   801bf9 <nsipc>
  801d83:	89 c3                	mov    %eax,%ebx
  801d85:	85 c0                	test   %eax,%eax
  801d87:	78 35                	js     801dbe <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d89:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d8e:	7f 04                	jg     801d94 <nsipc_recv+0x39>
  801d90:	39 c6                	cmp    %eax,%esi
  801d92:	7d 16                	jge    801daa <nsipc_recv+0x4f>
  801d94:	68 27 2c 80 00       	push   $0x802c27
  801d99:	68 ef 2b 80 00       	push   $0x802bef
  801d9e:	6a 62                	push   $0x62
  801da0:	68 3c 2c 80 00       	push   $0x802c3c
  801da5:	e8 84 05 00 00       	call   80232e <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801daa:	83 ec 04             	sub    $0x4,%esp
  801dad:	50                   	push   %eax
  801dae:	68 00 60 80 00       	push   $0x806000
  801db3:	ff 75 0c             	pushl  0xc(%ebp)
  801db6:	e8 e8 eb ff ff       	call   8009a3 <memmove>
  801dbb:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801dbe:	89 d8                	mov    %ebx,%eax
  801dc0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dc3:	5b                   	pop    %ebx
  801dc4:	5e                   	pop    %esi
  801dc5:	5d                   	pop    %ebp
  801dc6:	c3                   	ret    

00801dc7 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801dc7:	55                   	push   %ebp
  801dc8:	89 e5                	mov    %esp,%ebp
  801dca:	53                   	push   %ebx
  801dcb:	83 ec 04             	sub    $0x4,%esp
  801dce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801dd1:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd4:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801dd9:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801ddf:	7e 16                	jle    801df7 <nsipc_send+0x30>
  801de1:	68 48 2c 80 00       	push   $0x802c48
  801de6:	68 ef 2b 80 00       	push   $0x802bef
  801deb:	6a 6d                	push   $0x6d
  801ded:	68 3c 2c 80 00       	push   $0x802c3c
  801df2:	e8 37 05 00 00       	call   80232e <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801df7:	83 ec 04             	sub    $0x4,%esp
  801dfa:	53                   	push   %ebx
  801dfb:	ff 75 0c             	pushl  0xc(%ebp)
  801dfe:	68 0c 60 80 00       	push   $0x80600c
  801e03:	e8 9b eb ff ff       	call   8009a3 <memmove>
	nsipcbuf.send.req_size = size;
  801e08:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e0e:	8b 45 14             	mov    0x14(%ebp),%eax
  801e11:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e16:	b8 08 00 00 00       	mov    $0x8,%eax
  801e1b:	e8 d9 fd ff ff       	call   801bf9 <nsipc>
}
  801e20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e23:	c9                   	leave  
  801e24:	c3                   	ret    

00801e25 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e25:	55                   	push   %ebp
  801e26:	89 e5                	mov    %esp,%ebp
  801e28:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e33:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e36:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e3b:	8b 45 10             	mov    0x10(%ebp),%eax
  801e3e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e43:	b8 09 00 00 00       	mov    $0x9,%eax
  801e48:	e8 ac fd ff ff       	call   801bf9 <nsipc>
}
  801e4d:	c9                   	leave  
  801e4e:	c3                   	ret    

00801e4f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e4f:	55                   	push   %ebp
  801e50:	89 e5                	mov    %esp,%ebp
  801e52:	56                   	push   %esi
  801e53:	53                   	push   %ebx
  801e54:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e57:	83 ec 0c             	sub    $0xc,%esp
  801e5a:	ff 75 08             	pushl  0x8(%ebp)
  801e5d:	e8 98 f3 ff ff       	call   8011fa <fd2data>
  801e62:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e64:	83 c4 08             	add    $0x8,%esp
  801e67:	68 54 2c 80 00       	push   $0x802c54
  801e6c:	53                   	push   %ebx
  801e6d:	e8 9f e9 ff ff       	call   800811 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e72:	8b 46 04             	mov    0x4(%esi),%eax
  801e75:	2b 06                	sub    (%esi),%eax
  801e77:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e7d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e84:	00 00 00 
	stat->st_dev = &devpipe;
  801e87:	c7 83 88 00 00 00 44 	movl   $0x803044,0x88(%ebx)
  801e8e:	30 80 00 
	return 0;
}
  801e91:	b8 00 00 00 00       	mov    $0x0,%eax
  801e96:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e99:	5b                   	pop    %ebx
  801e9a:	5e                   	pop    %esi
  801e9b:	5d                   	pop    %ebp
  801e9c:	c3                   	ret    

00801e9d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e9d:	55                   	push   %ebp
  801e9e:	89 e5                	mov    %esp,%ebp
  801ea0:	53                   	push   %ebx
  801ea1:	83 ec 0c             	sub    $0xc,%esp
  801ea4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ea7:	53                   	push   %ebx
  801ea8:	6a 00                	push   $0x0
  801eaa:	e8 ea ed ff ff       	call   800c99 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801eaf:	89 1c 24             	mov    %ebx,(%esp)
  801eb2:	e8 43 f3 ff ff       	call   8011fa <fd2data>
  801eb7:	83 c4 08             	add    $0x8,%esp
  801eba:	50                   	push   %eax
  801ebb:	6a 00                	push   $0x0
  801ebd:	e8 d7 ed ff ff       	call   800c99 <sys_page_unmap>
}
  801ec2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ec5:	c9                   	leave  
  801ec6:	c3                   	ret    

00801ec7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ec7:	55                   	push   %ebp
  801ec8:	89 e5                	mov    %esp,%ebp
  801eca:	57                   	push   %edi
  801ecb:	56                   	push   %esi
  801ecc:	53                   	push   %ebx
  801ecd:	83 ec 1c             	sub    $0x1c,%esp
  801ed0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ed3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ed5:	a1 08 40 80 00       	mov    0x804008,%eax
  801eda:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801edd:	83 ec 0c             	sub    $0xc,%esp
  801ee0:	ff 75 e0             	pushl  -0x20(%ebp)
  801ee3:	e8 f7 04 00 00       	call   8023df <pageref>
  801ee8:	89 c3                	mov    %eax,%ebx
  801eea:	89 3c 24             	mov    %edi,(%esp)
  801eed:	e8 ed 04 00 00       	call   8023df <pageref>
  801ef2:	83 c4 10             	add    $0x10,%esp
  801ef5:	39 c3                	cmp    %eax,%ebx
  801ef7:	0f 94 c1             	sete   %cl
  801efa:	0f b6 c9             	movzbl %cl,%ecx
  801efd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f00:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f06:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f09:	39 ce                	cmp    %ecx,%esi
  801f0b:	74 1b                	je     801f28 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f0d:	39 c3                	cmp    %eax,%ebx
  801f0f:	75 c4                	jne    801ed5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f11:	8b 42 58             	mov    0x58(%edx),%eax
  801f14:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f17:	50                   	push   %eax
  801f18:	56                   	push   %esi
  801f19:	68 5b 2c 80 00       	push   $0x802c5b
  801f1e:	e8 69 e3 ff ff       	call   80028c <cprintf>
  801f23:	83 c4 10             	add    $0x10,%esp
  801f26:	eb ad                	jmp    801ed5 <_pipeisclosed+0xe>
	}
}
  801f28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f2e:	5b                   	pop    %ebx
  801f2f:	5e                   	pop    %esi
  801f30:	5f                   	pop    %edi
  801f31:	5d                   	pop    %ebp
  801f32:	c3                   	ret    

00801f33 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f33:	55                   	push   %ebp
  801f34:	89 e5                	mov    %esp,%ebp
  801f36:	57                   	push   %edi
  801f37:	56                   	push   %esi
  801f38:	53                   	push   %ebx
  801f39:	83 ec 28             	sub    $0x28,%esp
  801f3c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f3f:	56                   	push   %esi
  801f40:	e8 b5 f2 ff ff       	call   8011fa <fd2data>
  801f45:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f47:	83 c4 10             	add    $0x10,%esp
  801f4a:	bf 00 00 00 00       	mov    $0x0,%edi
  801f4f:	eb 4b                	jmp    801f9c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f51:	89 da                	mov    %ebx,%edx
  801f53:	89 f0                	mov    %esi,%eax
  801f55:	e8 6d ff ff ff       	call   801ec7 <_pipeisclosed>
  801f5a:	85 c0                	test   %eax,%eax
  801f5c:	75 48                	jne    801fa6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f5e:	e8 92 ec ff ff       	call   800bf5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f63:	8b 43 04             	mov    0x4(%ebx),%eax
  801f66:	8b 0b                	mov    (%ebx),%ecx
  801f68:	8d 51 20             	lea    0x20(%ecx),%edx
  801f6b:	39 d0                	cmp    %edx,%eax
  801f6d:	73 e2                	jae    801f51 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f72:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f76:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f79:	89 c2                	mov    %eax,%edx
  801f7b:	c1 fa 1f             	sar    $0x1f,%edx
  801f7e:	89 d1                	mov    %edx,%ecx
  801f80:	c1 e9 1b             	shr    $0x1b,%ecx
  801f83:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f86:	83 e2 1f             	and    $0x1f,%edx
  801f89:	29 ca                	sub    %ecx,%edx
  801f8b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f8f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f93:	83 c0 01             	add    $0x1,%eax
  801f96:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f99:	83 c7 01             	add    $0x1,%edi
  801f9c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f9f:	75 c2                	jne    801f63 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fa1:	8b 45 10             	mov    0x10(%ebp),%eax
  801fa4:	eb 05                	jmp    801fab <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fa6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fae:	5b                   	pop    %ebx
  801faf:	5e                   	pop    %esi
  801fb0:	5f                   	pop    %edi
  801fb1:	5d                   	pop    %ebp
  801fb2:	c3                   	ret    

00801fb3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fb3:	55                   	push   %ebp
  801fb4:	89 e5                	mov    %esp,%ebp
  801fb6:	57                   	push   %edi
  801fb7:	56                   	push   %esi
  801fb8:	53                   	push   %ebx
  801fb9:	83 ec 18             	sub    $0x18,%esp
  801fbc:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fbf:	57                   	push   %edi
  801fc0:	e8 35 f2 ff ff       	call   8011fa <fd2data>
  801fc5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fc7:	83 c4 10             	add    $0x10,%esp
  801fca:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fcf:	eb 3d                	jmp    80200e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801fd1:	85 db                	test   %ebx,%ebx
  801fd3:	74 04                	je     801fd9 <devpipe_read+0x26>
				return i;
  801fd5:	89 d8                	mov    %ebx,%eax
  801fd7:	eb 44                	jmp    80201d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fd9:	89 f2                	mov    %esi,%edx
  801fdb:	89 f8                	mov    %edi,%eax
  801fdd:	e8 e5 fe ff ff       	call   801ec7 <_pipeisclosed>
  801fe2:	85 c0                	test   %eax,%eax
  801fe4:	75 32                	jne    802018 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801fe6:	e8 0a ec ff ff       	call   800bf5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801feb:	8b 06                	mov    (%esi),%eax
  801fed:	3b 46 04             	cmp    0x4(%esi),%eax
  801ff0:	74 df                	je     801fd1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ff2:	99                   	cltd   
  801ff3:	c1 ea 1b             	shr    $0x1b,%edx
  801ff6:	01 d0                	add    %edx,%eax
  801ff8:	83 e0 1f             	and    $0x1f,%eax
  801ffb:	29 d0                	sub    %edx,%eax
  801ffd:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802002:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802005:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802008:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80200b:	83 c3 01             	add    $0x1,%ebx
  80200e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802011:	75 d8                	jne    801feb <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802013:	8b 45 10             	mov    0x10(%ebp),%eax
  802016:	eb 05                	jmp    80201d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802018:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80201d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802020:	5b                   	pop    %ebx
  802021:	5e                   	pop    %esi
  802022:	5f                   	pop    %edi
  802023:	5d                   	pop    %ebp
  802024:	c3                   	ret    

00802025 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802025:	55                   	push   %ebp
  802026:	89 e5                	mov    %esp,%ebp
  802028:	56                   	push   %esi
  802029:	53                   	push   %ebx
  80202a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80202d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802030:	50                   	push   %eax
  802031:	e8 db f1 ff ff       	call   801211 <fd_alloc>
  802036:	83 c4 10             	add    $0x10,%esp
  802039:	89 c2                	mov    %eax,%edx
  80203b:	85 c0                	test   %eax,%eax
  80203d:	0f 88 2c 01 00 00    	js     80216f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802043:	83 ec 04             	sub    $0x4,%esp
  802046:	68 07 04 00 00       	push   $0x407
  80204b:	ff 75 f4             	pushl  -0xc(%ebp)
  80204e:	6a 00                	push   $0x0
  802050:	e8 bf eb ff ff       	call   800c14 <sys_page_alloc>
  802055:	83 c4 10             	add    $0x10,%esp
  802058:	89 c2                	mov    %eax,%edx
  80205a:	85 c0                	test   %eax,%eax
  80205c:	0f 88 0d 01 00 00    	js     80216f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802062:	83 ec 0c             	sub    $0xc,%esp
  802065:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802068:	50                   	push   %eax
  802069:	e8 a3 f1 ff ff       	call   801211 <fd_alloc>
  80206e:	89 c3                	mov    %eax,%ebx
  802070:	83 c4 10             	add    $0x10,%esp
  802073:	85 c0                	test   %eax,%eax
  802075:	0f 88 e2 00 00 00    	js     80215d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80207b:	83 ec 04             	sub    $0x4,%esp
  80207e:	68 07 04 00 00       	push   $0x407
  802083:	ff 75 f0             	pushl  -0x10(%ebp)
  802086:	6a 00                	push   $0x0
  802088:	e8 87 eb ff ff       	call   800c14 <sys_page_alloc>
  80208d:	89 c3                	mov    %eax,%ebx
  80208f:	83 c4 10             	add    $0x10,%esp
  802092:	85 c0                	test   %eax,%eax
  802094:	0f 88 c3 00 00 00    	js     80215d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80209a:	83 ec 0c             	sub    $0xc,%esp
  80209d:	ff 75 f4             	pushl  -0xc(%ebp)
  8020a0:	e8 55 f1 ff ff       	call   8011fa <fd2data>
  8020a5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020a7:	83 c4 0c             	add    $0xc,%esp
  8020aa:	68 07 04 00 00       	push   $0x407
  8020af:	50                   	push   %eax
  8020b0:	6a 00                	push   $0x0
  8020b2:	e8 5d eb ff ff       	call   800c14 <sys_page_alloc>
  8020b7:	89 c3                	mov    %eax,%ebx
  8020b9:	83 c4 10             	add    $0x10,%esp
  8020bc:	85 c0                	test   %eax,%eax
  8020be:	0f 88 89 00 00 00    	js     80214d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020c4:	83 ec 0c             	sub    $0xc,%esp
  8020c7:	ff 75 f0             	pushl  -0x10(%ebp)
  8020ca:	e8 2b f1 ff ff       	call   8011fa <fd2data>
  8020cf:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020d6:	50                   	push   %eax
  8020d7:	6a 00                	push   $0x0
  8020d9:	56                   	push   %esi
  8020da:	6a 00                	push   $0x0
  8020dc:	e8 76 eb ff ff       	call   800c57 <sys_page_map>
  8020e1:	89 c3                	mov    %eax,%ebx
  8020e3:	83 c4 20             	add    $0x20,%esp
  8020e6:	85 c0                	test   %eax,%eax
  8020e8:	78 55                	js     80213f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020ea:	8b 15 44 30 80 00    	mov    0x803044,%edx
  8020f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020ff:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802105:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802108:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80210a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80210d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802114:	83 ec 0c             	sub    $0xc,%esp
  802117:	ff 75 f4             	pushl  -0xc(%ebp)
  80211a:	e8 cb f0 ff ff       	call   8011ea <fd2num>
  80211f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802122:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802124:	83 c4 04             	add    $0x4,%esp
  802127:	ff 75 f0             	pushl  -0x10(%ebp)
  80212a:	e8 bb f0 ff ff       	call   8011ea <fd2num>
  80212f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802132:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802135:	83 c4 10             	add    $0x10,%esp
  802138:	ba 00 00 00 00       	mov    $0x0,%edx
  80213d:	eb 30                	jmp    80216f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80213f:	83 ec 08             	sub    $0x8,%esp
  802142:	56                   	push   %esi
  802143:	6a 00                	push   $0x0
  802145:	e8 4f eb ff ff       	call   800c99 <sys_page_unmap>
  80214a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80214d:	83 ec 08             	sub    $0x8,%esp
  802150:	ff 75 f0             	pushl  -0x10(%ebp)
  802153:	6a 00                	push   $0x0
  802155:	e8 3f eb ff ff       	call   800c99 <sys_page_unmap>
  80215a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80215d:	83 ec 08             	sub    $0x8,%esp
  802160:	ff 75 f4             	pushl  -0xc(%ebp)
  802163:	6a 00                	push   $0x0
  802165:	e8 2f eb ff ff       	call   800c99 <sys_page_unmap>
  80216a:	83 c4 10             	add    $0x10,%esp
  80216d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80216f:	89 d0                	mov    %edx,%eax
  802171:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802174:	5b                   	pop    %ebx
  802175:	5e                   	pop    %esi
  802176:	5d                   	pop    %ebp
  802177:	c3                   	ret    

00802178 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802178:	55                   	push   %ebp
  802179:	89 e5                	mov    %esp,%ebp
  80217b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80217e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802181:	50                   	push   %eax
  802182:	ff 75 08             	pushl  0x8(%ebp)
  802185:	e8 d6 f0 ff ff       	call   801260 <fd_lookup>
  80218a:	83 c4 10             	add    $0x10,%esp
  80218d:	85 c0                	test   %eax,%eax
  80218f:	78 18                	js     8021a9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802191:	83 ec 0c             	sub    $0xc,%esp
  802194:	ff 75 f4             	pushl  -0xc(%ebp)
  802197:	e8 5e f0 ff ff       	call   8011fa <fd2data>
	return _pipeisclosed(fd, p);
  80219c:	89 c2                	mov    %eax,%edx
  80219e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021a1:	e8 21 fd ff ff       	call   801ec7 <_pipeisclosed>
  8021a6:	83 c4 10             	add    $0x10,%esp
}
  8021a9:	c9                   	leave  
  8021aa:	c3                   	ret    

008021ab <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021ab:	55                   	push   %ebp
  8021ac:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8021b3:	5d                   	pop    %ebp
  8021b4:	c3                   	ret    

008021b5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021b5:	55                   	push   %ebp
  8021b6:	89 e5                	mov    %esp,%ebp
  8021b8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021bb:	68 73 2c 80 00       	push   $0x802c73
  8021c0:	ff 75 0c             	pushl  0xc(%ebp)
  8021c3:	e8 49 e6 ff ff       	call   800811 <strcpy>
	return 0;
}
  8021c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8021cd:	c9                   	leave  
  8021ce:	c3                   	ret    

008021cf <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021cf:	55                   	push   %ebp
  8021d0:	89 e5                	mov    %esp,%ebp
  8021d2:	57                   	push   %edi
  8021d3:	56                   	push   %esi
  8021d4:	53                   	push   %ebx
  8021d5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021db:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021e0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021e6:	eb 2d                	jmp    802215 <devcons_write+0x46>
		m = n - tot;
  8021e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021eb:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8021ed:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8021f0:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8021f5:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021f8:	83 ec 04             	sub    $0x4,%esp
  8021fb:	53                   	push   %ebx
  8021fc:	03 45 0c             	add    0xc(%ebp),%eax
  8021ff:	50                   	push   %eax
  802200:	57                   	push   %edi
  802201:	e8 9d e7 ff ff       	call   8009a3 <memmove>
		sys_cputs(buf, m);
  802206:	83 c4 08             	add    $0x8,%esp
  802209:	53                   	push   %ebx
  80220a:	57                   	push   %edi
  80220b:	e8 48 e9 ff ff       	call   800b58 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802210:	01 de                	add    %ebx,%esi
  802212:	83 c4 10             	add    $0x10,%esp
  802215:	89 f0                	mov    %esi,%eax
  802217:	3b 75 10             	cmp    0x10(%ebp),%esi
  80221a:	72 cc                	jb     8021e8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80221c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80221f:	5b                   	pop    %ebx
  802220:	5e                   	pop    %esi
  802221:	5f                   	pop    %edi
  802222:	5d                   	pop    %ebp
  802223:	c3                   	ret    

00802224 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802224:	55                   	push   %ebp
  802225:	89 e5                	mov    %esp,%ebp
  802227:	83 ec 08             	sub    $0x8,%esp
  80222a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80222f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802233:	74 2a                	je     80225f <devcons_read+0x3b>
  802235:	eb 05                	jmp    80223c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802237:	e8 b9 e9 ff ff       	call   800bf5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80223c:	e8 35 e9 ff ff       	call   800b76 <sys_cgetc>
  802241:	85 c0                	test   %eax,%eax
  802243:	74 f2                	je     802237 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802245:	85 c0                	test   %eax,%eax
  802247:	78 16                	js     80225f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802249:	83 f8 04             	cmp    $0x4,%eax
  80224c:	74 0c                	je     80225a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80224e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802251:	88 02                	mov    %al,(%edx)
	return 1;
  802253:	b8 01 00 00 00       	mov    $0x1,%eax
  802258:	eb 05                	jmp    80225f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80225a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80225f:	c9                   	leave  
  802260:	c3                   	ret    

00802261 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802261:	55                   	push   %ebp
  802262:	89 e5                	mov    %esp,%ebp
  802264:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802267:	8b 45 08             	mov    0x8(%ebp),%eax
  80226a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80226d:	6a 01                	push   $0x1
  80226f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802272:	50                   	push   %eax
  802273:	e8 e0 e8 ff ff       	call   800b58 <sys_cputs>
}
  802278:	83 c4 10             	add    $0x10,%esp
  80227b:	c9                   	leave  
  80227c:	c3                   	ret    

0080227d <getchar>:

int
getchar(void)
{
  80227d:	55                   	push   %ebp
  80227e:	89 e5                	mov    %esp,%ebp
  802280:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802283:	6a 01                	push   $0x1
  802285:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802288:	50                   	push   %eax
  802289:	6a 00                	push   $0x0
  80228b:	e8 36 f2 ff ff       	call   8014c6 <read>
	if (r < 0)
  802290:	83 c4 10             	add    $0x10,%esp
  802293:	85 c0                	test   %eax,%eax
  802295:	78 0f                	js     8022a6 <getchar+0x29>
		return r;
	if (r < 1)
  802297:	85 c0                	test   %eax,%eax
  802299:	7e 06                	jle    8022a1 <getchar+0x24>
		return -E_EOF;
	return c;
  80229b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80229f:	eb 05                	jmp    8022a6 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022a1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022a6:	c9                   	leave  
  8022a7:	c3                   	ret    

008022a8 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022a8:	55                   	push   %ebp
  8022a9:	89 e5                	mov    %esp,%ebp
  8022ab:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022b1:	50                   	push   %eax
  8022b2:	ff 75 08             	pushl  0x8(%ebp)
  8022b5:	e8 a6 ef ff ff       	call   801260 <fd_lookup>
  8022ba:	83 c4 10             	add    $0x10,%esp
  8022bd:	85 c0                	test   %eax,%eax
  8022bf:	78 11                	js     8022d2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022c4:	8b 15 60 30 80 00    	mov    0x803060,%edx
  8022ca:	39 10                	cmp    %edx,(%eax)
  8022cc:	0f 94 c0             	sete   %al
  8022cf:	0f b6 c0             	movzbl %al,%eax
}
  8022d2:	c9                   	leave  
  8022d3:	c3                   	ret    

008022d4 <opencons>:

int
opencons(void)
{
  8022d4:	55                   	push   %ebp
  8022d5:	89 e5                	mov    %esp,%ebp
  8022d7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022dd:	50                   	push   %eax
  8022de:	e8 2e ef ff ff       	call   801211 <fd_alloc>
  8022e3:	83 c4 10             	add    $0x10,%esp
		return r;
  8022e6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022e8:	85 c0                	test   %eax,%eax
  8022ea:	78 3e                	js     80232a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022ec:	83 ec 04             	sub    $0x4,%esp
  8022ef:	68 07 04 00 00       	push   $0x407
  8022f4:	ff 75 f4             	pushl  -0xc(%ebp)
  8022f7:	6a 00                	push   $0x0
  8022f9:	e8 16 e9 ff ff       	call   800c14 <sys_page_alloc>
  8022fe:	83 c4 10             	add    $0x10,%esp
		return r;
  802301:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802303:	85 c0                	test   %eax,%eax
  802305:	78 23                	js     80232a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802307:	8b 15 60 30 80 00    	mov    0x803060,%edx
  80230d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802310:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802312:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802315:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80231c:	83 ec 0c             	sub    $0xc,%esp
  80231f:	50                   	push   %eax
  802320:	e8 c5 ee ff ff       	call   8011ea <fd2num>
  802325:	89 c2                	mov    %eax,%edx
  802327:	83 c4 10             	add    $0x10,%esp
}
  80232a:	89 d0                	mov    %edx,%eax
  80232c:	c9                   	leave  
  80232d:	c3                   	ret    

0080232e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80232e:	55                   	push   %ebp
  80232f:	89 e5                	mov    %esp,%ebp
  802331:	56                   	push   %esi
  802332:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802333:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802336:	8b 35 08 30 80 00    	mov    0x803008,%esi
  80233c:	e8 95 e8 ff ff       	call   800bd6 <sys_getenvid>
  802341:	83 ec 0c             	sub    $0xc,%esp
  802344:	ff 75 0c             	pushl  0xc(%ebp)
  802347:	ff 75 08             	pushl  0x8(%ebp)
  80234a:	56                   	push   %esi
  80234b:	50                   	push   %eax
  80234c:	68 80 2c 80 00       	push   $0x802c80
  802351:	e8 36 df ff ff       	call   80028c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802356:	83 c4 18             	add    $0x18,%esp
  802359:	53                   	push   %ebx
  80235a:	ff 75 10             	pushl  0x10(%ebp)
  80235d:	e8 d9 de ff ff       	call   80023b <vcprintf>
	cprintf("\n");
  802362:	c7 04 24 6c 2c 80 00 	movl   $0x802c6c,(%esp)
  802369:	e8 1e df ff ff       	call   80028c <cprintf>
  80236e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802371:	cc                   	int3   
  802372:	eb fd                	jmp    802371 <_panic+0x43>

00802374 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802374:	55                   	push   %ebp
  802375:	89 e5                	mov    %esp,%ebp
  802377:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80237a:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802381:	75 2e                	jne    8023b1 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  802383:	e8 4e e8 ff ff       	call   800bd6 <sys_getenvid>
  802388:	83 ec 04             	sub    $0x4,%esp
  80238b:	68 07 0e 00 00       	push   $0xe07
  802390:	68 00 f0 bf ee       	push   $0xeebff000
  802395:	50                   	push   %eax
  802396:	e8 79 e8 ff ff       	call   800c14 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  80239b:	e8 36 e8 ff ff       	call   800bd6 <sys_getenvid>
  8023a0:	83 c4 08             	add    $0x8,%esp
  8023a3:	68 bb 23 80 00       	push   $0x8023bb
  8023a8:	50                   	push   %eax
  8023a9:	e8 b1 e9 ff ff       	call   800d5f <sys_env_set_pgfault_upcall>
  8023ae:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8023b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8023b4:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8023b9:	c9                   	leave  
  8023ba:	c3                   	ret    

008023bb <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023bb:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023bc:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8023c1:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8023c3:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  8023c6:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  8023ca:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  8023ce:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  8023d1:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  8023d4:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  8023d5:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  8023d8:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  8023d9:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  8023da:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  8023de:	c3                   	ret    

008023df <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023df:	55                   	push   %ebp
  8023e0:	89 e5                	mov    %esp,%ebp
  8023e2:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023e5:	89 d0                	mov    %edx,%eax
  8023e7:	c1 e8 16             	shr    $0x16,%eax
  8023ea:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023f1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023f6:	f6 c1 01             	test   $0x1,%cl
  8023f9:	74 1d                	je     802418 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023fb:	c1 ea 0c             	shr    $0xc,%edx
  8023fe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802405:	f6 c2 01             	test   $0x1,%dl
  802408:	74 0e                	je     802418 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80240a:	c1 ea 0c             	shr    $0xc,%edx
  80240d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802414:	ef 
  802415:	0f b7 c0             	movzwl %ax,%eax
}
  802418:	5d                   	pop    %ebp
  802419:	c3                   	ret    
  80241a:	66 90                	xchg   %ax,%ax
  80241c:	66 90                	xchg   %ax,%ax
  80241e:	66 90                	xchg   %ax,%ax

00802420 <__udivdi3>:
  802420:	55                   	push   %ebp
  802421:	57                   	push   %edi
  802422:	56                   	push   %esi
  802423:	53                   	push   %ebx
  802424:	83 ec 1c             	sub    $0x1c,%esp
  802427:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80242b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80242f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802433:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802437:	85 f6                	test   %esi,%esi
  802439:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80243d:	89 ca                	mov    %ecx,%edx
  80243f:	89 f8                	mov    %edi,%eax
  802441:	75 3d                	jne    802480 <__udivdi3+0x60>
  802443:	39 cf                	cmp    %ecx,%edi
  802445:	0f 87 c5 00 00 00    	ja     802510 <__udivdi3+0xf0>
  80244b:	85 ff                	test   %edi,%edi
  80244d:	89 fd                	mov    %edi,%ebp
  80244f:	75 0b                	jne    80245c <__udivdi3+0x3c>
  802451:	b8 01 00 00 00       	mov    $0x1,%eax
  802456:	31 d2                	xor    %edx,%edx
  802458:	f7 f7                	div    %edi
  80245a:	89 c5                	mov    %eax,%ebp
  80245c:	89 c8                	mov    %ecx,%eax
  80245e:	31 d2                	xor    %edx,%edx
  802460:	f7 f5                	div    %ebp
  802462:	89 c1                	mov    %eax,%ecx
  802464:	89 d8                	mov    %ebx,%eax
  802466:	89 cf                	mov    %ecx,%edi
  802468:	f7 f5                	div    %ebp
  80246a:	89 c3                	mov    %eax,%ebx
  80246c:	89 d8                	mov    %ebx,%eax
  80246e:	89 fa                	mov    %edi,%edx
  802470:	83 c4 1c             	add    $0x1c,%esp
  802473:	5b                   	pop    %ebx
  802474:	5e                   	pop    %esi
  802475:	5f                   	pop    %edi
  802476:	5d                   	pop    %ebp
  802477:	c3                   	ret    
  802478:	90                   	nop
  802479:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802480:	39 ce                	cmp    %ecx,%esi
  802482:	77 74                	ja     8024f8 <__udivdi3+0xd8>
  802484:	0f bd fe             	bsr    %esi,%edi
  802487:	83 f7 1f             	xor    $0x1f,%edi
  80248a:	0f 84 98 00 00 00    	je     802528 <__udivdi3+0x108>
  802490:	bb 20 00 00 00       	mov    $0x20,%ebx
  802495:	89 f9                	mov    %edi,%ecx
  802497:	89 c5                	mov    %eax,%ebp
  802499:	29 fb                	sub    %edi,%ebx
  80249b:	d3 e6                	shl    %cl,%esi
  80249d:	89 d9                	mov    %ebx,%ecx
  80249f:	d3 ed                	shr    %cl,%ebp
  8024a1:	89 f9                	mov    %edi,%ecx
  8024a3:	d3 e0                	shl    %cl,%eax
  8024a5:	09 ee                	or     %ebp,%esi
  8024a7:	89 d9                	mov    %ebx,%ecx
  8024a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024ad:	89 d5                	mov    %edx,%ebp
  8024af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024b3:	d3 ed                	shr    %cl,%ebp
  8024b5:	89 f9                	mov    %edi,%ecx
  8024b7:	d3 e2                	shl    %cl,%edx
  8024b9:	89 d9                	mov    %ebx,%ecx
  8024bb:	d3 e8                	shr    %cl,%eax
  8024bd:	09 c2                	or     %eax,%edx
  8024bf:	89 d0                	mov    %edx,%eax
  8024c1:	89 ea                	mov    %ebp,%edx
  8024c3:	f7 f6                	div    %esi
  8024c5:	89 d5                	mov    %edx,%ebp
  8024c7:	89 c3                	mov    %eax,%ebx
  8024c9:	f7 64 24 0c          	mull   0xc(%esp)
  8024cd:	39 d5                	cmp    %edx,%ebp
  8024cf:	72 10                	jb     8024e1 <__udivdi3+0xc1>
  8024d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8024d5:	89 f9                	mov    %edi,%ecx
  8024d7:	d3 e6                	shl    %cl,%esi
  8024d9:	39 c6                	cmp    %eax,%esi
  8024db:	73 07                	jae    8024e4 <__udivdi3+0xc4>
  8024dd:	39 d5                	cmp    %edx,%ebp
  8024df:	75 03                	jne    8024e4 <__udivdi3+0xc4>
  8024e1:	83 eb 01             	sub    $0x1,%ebx
  8024e4:	31 ff                	xor    %edi,%edi
  8024e6:	89 d8                	mov    %ebx,%eax
  8024e8:	89 fa                	mov    %edi,%edx
  8024ea:	83 c4 1c             	add    $0x1c,%esp
  8024ed:	5b                   	pop    %ebx
  8024ee:	5e                   	pop    %esi
  8024ef:	5f                   	pop    %edi
  8024f0:	5d                   	pop    %ebp
  8024f1:	c3                   	ret    
  8024f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024f8:	31 ff                	xor    %edi,%edi
  8024fa:	31 db                	xor    %ebx,%ebx
  8024fc:	89 d8                	mov    %ebx,%eax
  8024fe:	89 fa                	mov    %edi,%edx
  802500:	83 c4 1c             	add    $0x1c,%esp
  802503:	5b                   	pop    %ebx
  802504:	5e                   	pop    %esi
  802505:	5f                   	pop    %edi
  802506:	5d                   	pop    %ebp
  802507:	c3                   	ret    
  802508:	90                   	nop
  802509:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802510:	89 d8                	mov    %ebx,%eax
  802512:	f7 f7                	div    %edi
  802514:	31 ff                	xor    %edi,%edi
  802516:	89 c3                	mov    %eax,%ebx
  802518:	89 d8                	mov    %ebx,%eax
  80251a:	89 fa                	mov    %edi,%edx
  80251c:	83 c4 1c             	add    $0x1c,%esp
  80251f:	5b                   	pop    %ebx
  802520:	5e                   	pop    %esi
  802521:	5f                   	pop    %edi
  802522:	5d                   	pop    %ebp
  802523:	c3                   	ret    
  802524:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802528:	39 ce                	cmp    %ecx,%esi
  80252a:	72 0c                	jb     802538 <__udivdi3+0x118>
  80252c:	31 db                	xor    %ebx,%ebx
  80252e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802532:	0f 87 34 ff ff ff    	ja     80246c <__udivdi3+0x4c>
  802538:	bb 01 00 00 00       	mov    $0x1,%ebx
  80253d:	e9 2a ff ff ff       	jmp    80246c <__udivdi3+0x4c>
  802542:	66 90                	xchg   %ax,%ax
  802544:	66 90                	xchg   %ax,%ax
  802546:	66 90                	xchg   %ax,%ax
  802548:	66 90                	xchg   %ax,%ax
  80254a:	66 90                	xchg   %ax,%ax
  80254c:	66 90                	xchg   %ax,%ax
  80254e:	66 90                	xchg   %ax,%ax

00802550 <__umoddi3>:
  802550:	55                   	push   %ebp
  802551:	57                   	push   %edi
  802552:	56                   	push   %esi
  802553:	53                   	push   %ebx
  802554:	83 ec 1c             	sub    $0x1c,%esp
  802557:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80255b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80255f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802563:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802567:	85 d2                	test   %edx,%edx
  802569:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80256d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802571:	89 f3                	mov    %esi,%ebx
  802573:	89 3c 24             	mov    %edi,(%esp)
  802576:	89 74 24 04          	mov    %esi,0x4(%esp)
  80257a:	75 1c                	jne    802598 <__umoddi3+0x48>
  80257c:	39 f7                	cmp    %esi,%edi
  80257e:	76 50                	jbe    8025d0 <__umoddi3+0x80>
  802580:	89 c8                	mov    %ecx,%eax
  802582:	89 f2                	mov    %esi,%edx
  802584:	f7 f7                	div    %edi
  802586:	89 d0                	mov    %edx,%eax
  802588:	31 d2                	xor    %edx,%edx
  80258a:	83 c4 1c             	add    $0x1c,%esp
  80258d:	5b                   	pop    %ebx
  80258e:	5e                   	pop    %esi
  80258f:	5f                   	pop    %edi
  802590:	5d                   	pop    %ebp
  802591:	c3                   	ret    
  802592:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802598:	39 f2                	cmp    %esi,%edx
  80259a:	89 d0                	mov    %edx,%eax
  80259c:	77 52                	ja     8025f0 <__umoddi3+0xa0>
  80259e:	0f bd ea             	bsr    %edx,%ebp
  8025a1:	83 f5 1f             	xor    $0x1f,%ebp
  8025a4:	75 5a                	jne    802600 <__umoddi3+0xb0>
  8025a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8025aa:	0f 82 e0 00 00 00    	jb     802690 <__umoddi3+0x140>
  8025b0:	39 0c 24             	cmp    %ecx,(%esp)
  8025b3:	0f 86 d7 00 00 00    	jbe    802690 <__umoddi3+0x140>
  8025b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025c1:	83 c4 1c             	add    $0x1c,%esp
  8025c4:	5b                   	pop    %ebx
  8025c5:	5e                   	pop    %esi
  8025c6:	5f                   	pop    %edi
  8025c7:	5d                   	pop    %ebp
  8025c8:	c3                   	ret    
  8025c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025d0:	85 ff                	test   %edi,%edi
  8025d2:	89 fd                	mov    %edi,%ebp
  8025d4:	75 0b                	jne    8025e1 <__umoddi3+0x91>
  8025d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025db:	31 d2                	xor    %edx,%edx
  8025dd:	f7 f7                	div    %edi
  8025df:	89 c5                	mov    %eax,%ebp
  8025e1:	89 f0                	mov    %esi,%eax
  8025e3:	31 d2                	xor    %edx,%edx
  8025e5:	f7 f5                	div    %ebp
  8025e7:	89 c8                	mov    %ecx,%eax
  8025e9:	f7 f5                	div    %ebp
  8025eb:	89 d0                	mov    %edx,%eax
  8025ed:	eb 99                	jmp    802588 <__umoddi3+0x38>
  8025ef:	90                   	nop
  8025f0:	89 c8                	mov    %ecx,%eax
  8025f2:	89 f2                	mov    %esi,%edx
  8025f4:	83 c4 1c             	add    $0x1c,%esp
  8025f7:	5b                   	pop    %ebx
  8025f8:	5e                   	pop    %esi
  8025f9:	5f                   	pop    %edi
  8025fa:	5d                   	pop    %ebp
  8025fb:	c3                   	ret    
  8025fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802600:	8b 34 24             	mov    (%esp),%esi
  802603:	bf 20 00 00 00       	mov    $0x20,%edi
  802608:	89 e9                	mov    %ebp,%ecx
  80260a:	29 ef                	sub    %ebp,%edi
  80260c:	d3 e0                	shl    %cl,%eax
  80260e:	89 f9                	mov    %edi,%ecx
  802610:	89 f2                	mov    %esi,%edx
  802612:	d3 ea                	shr    %cl,%edx
  802614:	89 e9                	mov    %ebp,%ecx
  802616:	09 c2                	or     %eax,%edx
  802618:	89 d8                	mov    %ebx,%eax
  80261a:	89 14 24             	mov    %edx,(%esp)
  80261d:	89 f2                	mov    %esi,%edx
  80261f:	d3 e2                	shl    %cl,%edx
  802621:	89 f9                	mov    %edi,%ecx
  802623:	89 54 24 04          	mov    %edx,0x4(%esp)
  802627:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80262b:	d3 e8                	shr    %cl,%eax
  80262d:	89 e9                	mov    %ebp,%ecx
  80262f:	89 c6                	mov    %eax,%esi
  802631:	d3 e3                	shl    %cl,%ebx
  802633:	89 f9                	mov    %edi,%ecx
  802635:	89 d0                	mov    %edx,%eax
  802637:	d3 e8                	shr    %cl,%eax
  802639:	89 e9                	mov    %ebp,%ecx
  80263b:	09 d8                	or     %ebx,%eax
  80263d:	89 d3                	mov    %edx,%ebx
  80263f:	89 f2                	mov    %esi,%edx
  802641:	f7 34 24             	divl   (%esp)
  802644:	89 d6                	mov    %edx,%esi
  802646:	d3 e3                	shl    %cl,%ebx
  802648:	f7 64 24 04          	mull   0x4(%esp)
  80264c:	39 d6                	cmp    %edx,%esi
  80264e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802652:	89 d1                	mov    %edx,%ecx
  802654:	89 c3                	mov    %eax,%ebx
  802656:	72 08                	jb     802660 <__umoddi3+0x110>
  802658:	75 11                	jne    80266b <__umoddi3+0x11b>
  80265a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80265e:	73 0b                	jae    80266b <__umoddi3+0x11b>
  802660:	2b 44 24 04          	sub    0x4(%esp),%eax
  802664:	1b 14 24             	sbb    (%esp),%edx
  802667:	89 d1                	mov    %edx,%ecx
  802669:	89 c3                	mov    %eax,%ebx
  80266b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80266f:	29 da                	sub    %ebx,%edx
  802671:	19 ce                	sbb    %ecx,%esi
  802673:	89 f9                	mov    %edi,%ecx
  802675:	89 f0                	mov    %esi,%eax
  802677:	d3 e0                	shl    %cl,%eax
  802679:	89 e9                	mov    %ebp,%ecx
  80267b:	d3 ea                	shr    %cl,%edx
  80267d:	89 e9                	mov    %ebp,%ecx
  80267f:	d3 ee                	shr    %cl,%esi
  802681:	09 d0                	or     %edx,%eax
  802683:	89 f2                	mov    %esi,%edx
  802685:	83 c4 1c             	add    $0x1c,%esp
  802688:	5b                   	pop    %ebx
  802689:	5e                   	pop    %esi
  80268a:	5f                   	pop    %edi
  80268b:	5d                   	pop    %ebp
  80268c:	c3                   	ret    
  80268d:	8d 76 00             	lea    0x0(%esi),%esi
  802690:	29 f9                	sub    %edi,%ecx
  802692:	19 d6                	sbb    %edx,%esi
  802694:	89 74 24 04          	mov    %esi,0x4(%esp)
  802698:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80269c:	e9 18 ff ff ff       	jmp    8025b9 <__umoddi3+0x69>
