
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
  800039:	e8 bf 0e 00 00       	call   800efd <fork>
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
  800057:	e8 58 10 00 00       	call   8010b4 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 80 26 80 00       	push   $0x802680
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
  80009d:	68 94 26 80 00       	push   $0x802694
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
  8000db:	e8 3b 10 00 00       	call   80111b <ipc_send>
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
  800131:	e8 e5 0f 00 00       	call   80111b <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 6b 0f 00 00       	call   8010b4 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 80 26 80 00       	push   $0x802680
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
  80018a:	68 b4 26 80 00       	push   $0x8026b4
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
  8001e5:	e8 89 11 00 00       	call   801373 <close_all>
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
  8002ef:	e8 ec 20 00 00       	call   8023e0 <__udivdi3>
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
  800332:	e8 d9 21 00 00       	call   802510 <__umoddi3>
  800337:	83 c4 14             	add    $0x14,%esp
  80033a:	0f be 80 2c 27 80 00 	movsbl 0x80272c(%eax),%eax
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
  800436:	ff 24 85 60 28 80 00 	jmp    *0x802860(,%eax,4)
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
  8004fa:	8b 14 85 c0 29 80 00 	mov    0x8029c0(,%eax,4),%edx
  800501:	85 d2                	test   %edx,%edx
  800503:	75 18                	jne    80051d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800505:	50                   	push   %eax
  800506:	68 44 27 80 00       	push   $0x802744
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
  80051e:	68 c1 2b 80 00       	push   $0x802bc1
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
  800542:	b8 3d 27 80 00       	mov    $0x80273d,%eax
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
  800bbd:	68 1f 2a 80 00       	push   $0x802a1f
  800bc2:	6a 23                	push   $0x23
  800bc4:	68 3c 2a 80 00       	push   $0x802a3c
  800bc9:	e8 1e 17 00 00       	call   8022ec <_panic>

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
  800c3e:	68 1f 2a 80 00       	push   $0x802a1f
  800c43:	6a 23                	push   $0x23
  800c45:	68 3c 2a 80 00       	push   $0x802a3c
  800c4a:	e8 9d 16 00 00       	call   8022ec <_panic>

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
  800c80:	68 1f 2a 80 00       	push   $0x802a1f
  800c85:	6a 23                	push   $0x23
  800c87:	68 3c 2a 80 00       	push   $0x802a3c
  800c8c:	e8 5b 16 00 00       	call   8022ec <_panic>

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
  800cc2:	68 1f 2a 80 00       	push   $0x802a1f
  800cc7:	6a 23                	push   $0x23
  800cc9:	68 3c 2a 80 00       	push   $0x802a3c
  800cce:	e8 19 16 00 00       	call   8022ec <_panic>

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
  800d04:	68 1f 2a 80 00       	push   $0x802a1f
  800d09:	6a 23                	push   $0x23
  800d0b:	68 3c 2a 80 00       	push   $0x802a3c
  800d10:	e8 d7 15 00 00       	call   8022ec <_panic>

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
  800d46:	68 1f 2a 80 00       	push   $0x802a1f
  800d4b:	6a 23                	push   $0x23
  800d4d:	68 3c 2a 80 00       	push   $0x802a3c
  800d52:	e8 95 15 00 00       	call   8022ec <_panic>

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
  800d88:	68 1f 2a 80 00       	push   $0x802a1f
  800d8d:	6a 23                	push   $0x23
  800d8f:	68 3c 2a 80 00       	push   $0x802a3c
  800d94:	e8 53 15 00 00       	call   8022ec <_panic>

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
  800dec:	68 1f 2a 80 00       	push   $0x802a1f
  800df1:	6a 23                	push   $0x23
  800df3:	68 3c 2a 80 00       	push   $0x802a3c
  800df8:	e8 ef 14 00 00       	call   8022ec <_panic>

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

00800e24 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	56                   	push   %esi
  800e28:	53                   	push   %ebx
  800e29:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e2c:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800e2e:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e32:	75 25                	jne    800e59 <pgfault+0x35>
  800e34:	89 d8                	mov    %ebx,%eax
  800e36:	c1 e8 0c             	shr    $0xc,%eax
  800e39:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e40:	f6 c4 08             	test   $0x8,%ah
  800e43:	75 14                	jne    800e59 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800e45:	83 ec 04             	sub    $0x4,%esp
  800e48:	68 4c 2a 80 00       	push   $0x802a4c
  800e4d:	6a 1e                	push   $0x1e
  800e4f:	68 e0 2a 80 00       	push   $0x802ae0
  800e54:	e8 93 14 00 00       	call   8022ec <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800e59:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800e5f:	e8 72 fd ff ff       	call   800bd6 <sys_getenvid>
  800e64:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800e66:	83 ec 04             	sub    $0x4,%esp
  800e69:	6a 07                	push   $0x7
  800e6b:	68 00 f0 7f 00       	push   $0x7ff000
  800e70:	50                   	push   %eax
  800e71:	e8 9e fd ff ff       	call   800c14 <sys_page_alloc>
	if (r < 0)
  800e76:	83 c4 10             	add    $0x10,%esp
  800e79:	85 c0                	test   %eax,%eax
  800e7b:	79 12                	jns    800e8f <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800e7d:	50                   	push   %eax
  800e7e:	68 78 2a 80 00       	push   $0x802a78
  800e83:	6a 33                	push   $0x33
  800e85:	68 e0 2a 80 00       	push   $0x802ae0
  800e8a:	e8 5d 14 00 00       	call   8022ec <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800e8f:	83 ec 04             	sub    $0x4,%esp
  800e92:	68 00 10 00 00       	push   $0x1000
  800e97:	53                   	push   %ebx
  800e98:	68 00 f0 7f 00       	push   $0x7ff000
  800e9d:	e8 69 fb ff ff       	call   800a0b <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800ea2:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ea9:	53                   	push   %ebx
  800eaa:	56                   	push   %esi
  800eab:	68 00 f0 7f 00       	push   $0x7ff000
  800eb0:	56                   	push   %esi
  800eb1:	e8 a1 fd ff ff       	call   800c57 <sys_page_map>
	if (r < 0)
  800eb6:	83 c4 20             	add    $0x20,%esp
  800eb9:	85 c0                	test   %eax,%eax
  800ebb:	79 12                	jns    800ecf <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800ebd:	50                   	push   %eax
  800ebe:	68 9c 2a 80 00       	push   $0x802a9c
  800ec3:	6a 3b                	push   $0x3b
  800ec5:	68 e0 2a 80 00       	push   $0x802ae0
  800eca:	e8 1d 14 00 00       	call   8022ec <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800ecf:	83 ec 08             	sub    $0x8,%esp
  800ed2:	68 00 f0 7f 00       	push   $0x7ff000
  800ed7:	56                   	push   %esi
  800ed8:	e8 bc fd ff ff       	call   800c99 <sys_page_unmap>
	if (r < 0)
  800edd:	83 c4 10             	add    $0x10,%esp
  800ee0:	85 c0                	test   %eax,%eax
  800ee2:	79 12                	jns    800ef6 <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800ee4:	50                   	push   %eax
  800ee5:	68 c0 2a 80 00       	push   $0x802ac0
  800eea:	6a 40                	push   $0x40
  800eec:	68 e0 2a 80 00       	push   $0x802ae0
  800ef1:	e8 f6 13 00 00       	call   8022ec <_panic>
}
  800ef6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ef9:	5b                   	pop    %ebx
  800efa:	5e                   	pop    %esi
  800efb:	5d                   	pop    %ebp
  800efc:	c3                   	ret    

00800efd <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800efd:	55                   	push   %ebp
  800efe:	89 e5                	mov    %esp,%ebp
  800f00:	57                   	push   %edi
  800f01:	56                   	push   %esi
  800f02:	53                   	push   %ebx
  800f03:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800f06:	68 24 0e 80 00       	push   $0x800e24
  800f0b:	e8 22 14 00 00       	call   802332 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f10:	b8 07 00 00 00       	mov    $0x7,%eax
  800f15:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800f17:	83 c4 10             	add    $0x10,%esp
  800f1a:	85 c0                	test   %eax,%eax
  800f1c:	0f 88 64 01 00 00    	js     801086 <fork+0x189>
  800f22:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800f27:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	75 21                	jne    800f51 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f30:	e8 a1 fc ff ff       	call   800bd6 <sys_getenvid>
  800f35:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f3a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f3d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f42:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  800f47:	ba 00 00 00 00       	mov    $0x0,%edx
  800f4c:	e9 3f 01 00 00       	jmp    801090 <fork+0x193>
  800f51:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f54:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800f56:	89 d8                	mov    %ebx,%eax
  800f58:	c1 e8 16             	shr    $0x16,%eax
  800f5b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f62:	a8 01                	test   $0x1,%al
  800f64:	0f 84 bd 00 00 00    	je     801027 <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800f6a:	89 d8                	mov    %ebx,%eax
  800f6c:	c1 e8 0c             	shr    $0xc,%eax
  800f6f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f76:	f6 c2 01             	test   $0x1,%dl
  800f79:	0f 84 a8 00 00 00    	je     801027 <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  800f7f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f86:	a8 04                	test   $0x4,%al
  800f88:	0f 84 99 00 00 00    	je     801027 <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800f8e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f95:	f6 c4 04             	test   $0x4,%ah
  800f98:	74 17                	je     800fb1 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800f9a:	83 ec 0c             	sub    $0xc,%esp
  800f9d:	68 07 0e 00 00       	push   $0xe07
  800fa2:	53                   	push   %ebx
  800fa3:	57                   	push   %edi
  800fa4:	53                   	push   %ebx
  800fa5:	6a 00                	push   $0x0
  800fa7:	e8 ab fc ff ff       	call   800c57 <sys_page_map>
  800fac:	83 c4 20             	add    $0x20,%esp
  800faf:	eb 76                	jmp    801027 <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800fb1:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fb8:	a8 02                	test   $0x2,%al
  800fba:	75 0c                	jne    800fc8 <fork+0xcb>
  800fbc:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fc3:	f6 c4 08             	test   $0x8,%ah
  800fc6:	74 3f                	je     801007 <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800fc8:	83 ec 0c             	sub    $0xc,%esp
  800fcb:	68 05 08 00 00       	push   $0x805
  800fd0:	53                   	push   %ebx
  800fd1:	57                   	push   %edi
  800fd2:	53                   	push   %ebx
  800fd3:	6a 00                	push   $0x0
  800fd5:	e8 7d fc ff ff       	call   800c57 <sys_page_map>
		if (r < 0)
  800fda:	83 c4 20             	add    $0x20,%esp
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	0f 88 a5 00 00 00    	js     80108a <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800fe5:	83 ec 0c             	sub    $0xc,%esp
  800fe8:	68 05 08 00 00       	push   $0x805
  800fed:	53                   	push   %ebx
  800fee:	6a 00                	push   $0x0
  800ff0:	53                   	push   %ebx
  800ff1:	6a 00                	push   $0x0
  800ff3:	e8 5f fc ff ff       	call   800c57 <sys_page_map>
  800ff8:	83 c4 20             	add    $0x20,%esp
  800ffb:	85 c0                	test   %eax,%eax
  800ffd:	b9 00 00 00 00       	mov    $0x0,%ecx
  801002:	0f 4f c1             	cmovg  %ecx,%eax
  801005:	eb 1c                	jmp    801023 <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  801007:	83 ec 0c             	sub    $0xc,%esp
  80100a:	6a 05                	push   $0x5
  80100c:	53                   	push   %ebx
  80100d:	57                   	push   %edi
  80100e:	53                   	push   %ebx
  80100f:	6a 00                	push   $0x0
  801011:	e8 41 fc ff ff       	call   800c57 <sys_page_map>
  801016:	83 c4 20             	add    $0x20,%esp
  801019:	85 c0                	test   %eax,%eax
  80101b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801020:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  801023:	85 c0                	test   %eax,%eax
  801025:	78 67                	js     80108e <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801027:	83 c6 01             	add    $0x1,%esi
  80102a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801030:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  801036:	0f 85 1a ff ff ff    	jne    800f56 <fork+0x59>
  80103c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  80103f:	83 ec 04             	sub    $0x4,%esp
  801042:	6a 07                	push   $0x7
  801044:	68 00 f0 bf ee       	push   $0xeebff000
  801049:	57                   	push   %edi
  80104a:	e8 c5 fb ff ff       	call   800c14 <sys_page_alloc>
	if (r < 0)
  80104f:	83 c4 10             	add    $0x10,%esp
		return r;
  801052:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  801054:	85 c0                	test   %eax,%eax
  801056:	78 38                	js     801090 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801058:	83 ec 08             	sub    $0x8,%esp
  80105b:	68 79 23 80 00       	push   $0x802379
  801060:	57                   	push   %edi
  801061:	e8 f9 fc ff ff       	call   800d5f <sys_env_set_pgfault_upcall>
	if (r < 0)
  801066:	83 c4 10             	add    $0x10,%esp
		return r;
  801069:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  80106b:	85 c0                	test   %eax,%eax
  80106d:	78 21                	js     801090 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  80106f:	83 ec 08             	sub    $0x8,%esp
  801072:	6a 02                	push   $0x2
  801074:	57                   	push   %edi
  801075:	e8 61 fc ff ff       	call   800cdb <sys_env_set_status>
	if (r < 0)
  80107a:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  80107d:	85 c0                	test   %eax,%eax
  80107f:	0f 48 f8             	cmovs  %eax,%edi
  801082:	89 fa                	mov    %edi,%edx
  801084:	eb 0a                	jmp    801090 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  801086:	89 c2                	mov    %eax,%edx
  801088:	eb 06                	jmp    801090 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  80108a:	89 c2                	mov    %eax,%edx
  80108c:	eb 02                	jmp    801090 <fork+0x193>
  80108e:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  801090:	89 d0                	mov    %edx,%eax
  801092:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801095:	5b                   	pop    %ebx
  801096:	5e                   	pop    %esi
  801097:	5f                   	pop    %edi
  801098:	5d                   	pop    %ebp
  801099:	c3                   	ret    

0080109a <sfork>:

// Challenge!
int
sfork(void)
{
  80109a:	55                   	push   %ebp
  80109b:	89 e5                	mov    %esp,%ebp
  80109d:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010a0:	68 eb 2a 80 00       	push   $0x802aeb
  8010a5:	68 c9 00 00 00       	push   $0xc9
  8010aa:	68 e0 2a 80 00       	push   $0x802ae0
  8010af:	e8 38 12 00 00       	call   8022ec <_panic>

008010b4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	56                   	push   %esi
  8010b8:	53                   	push   %ebx
  8010b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8010bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8010c2:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8010c4:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8010c9:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8010cc:	83 ec 0c             	sub    $0xc,%esp
  8010cf:	50                   	push   %eax
  8010d0:	e8 ef fc ff ff       	call   800dc4 <sys_ipc_recv>

	if (from_env_store != NULL)
  8010d5:	83 c4 10             	add    $0x10,%esp
  8010d8:	85 f6                	test   %esi,%esi
  8010da:	74 14                	je     8010f0 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8010dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8010e1:	85 c0                	test   %eax,%eax
  8010e3:	78 09                	js     8010ee <ipc_recv+0x3a>
  8010e5:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010eb:	8b 52 74             	mov    0x74(%edx),%edx
  8010ee:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8010f0:	85 db                	test   %ebx,%ebx
  8010f2:	74 14                	je     801108 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8010f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8010f9:	85 c0                	test   %eax,%eax
  8010fb:	78 09                	js     801106 <ipc_recv+0x52>
  8010fd:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801103:	8b 52 78             	mov    0x78(%edx),%edx
  801106:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801108:	85 c0                	test   %eax,%eax
  80110a:	78 08                	js     801114 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  80110c:	a1 08 40 80 00       	mov    0x804008,%eax
  801111:	8b 40 70             	mov    0x70(%eax),%eax
}
  801114:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801117:	5b                   	pop    %ebx
  801118:	5e                   	pop    %esi
  801119:	5d                   	pop    %ebp
  80111a:	c3                   	ret    

0080111b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	57                   	push   %edi
  80111f:	56                   	push   %esi
  801120:	53                   	push   %ebx
  801121:	83 ec 0c             	sub    $0xc,%esp
  801124:	8b 7d 08             	mov    0x8(%ebp),%edi
  801127:	8b 75 0c             	mov    0xc(%ebp),%esi
  80112a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  80112d:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  80112f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801134:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801137:	ff 75 14             	pushl  0x14(%ebp)
  80113a:	53                   	push   %ebx
  80113b:	56                   	push   %esi
  80113c:	57                   	push   %edi
  80113d:	e8 5f fc ff ff       	call   800da1 <sys_ipc_try_send>

		if (err < 0) {
  801142:	83 c4 10             	add    $0x10,%esp
  801145:	85 c0                	test   %eax,%eax
  801147:	79 1e                	jns    801167 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801149:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80114c:	75 07                	jne    801155 <ipc_send+0x3a>
				sys_yield();
  80114e:	e8 a2 fa ff ff       	call   800bf5 <sys_yield>
  801153:	eb e2                	jmp    801137 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801155:	50                   	push   %eax
  801156:	68 01 2b 80 00       	push   $0x802b01
  80115b:	6a 49                	push   $0x49
  80115d:	68 0e 2b 80 00       	push   $0x802b0e
  801162:	e8 85 11 00 00       	call   8022ec <_panic>
		}

	} while (err < 0);

}
  801167:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116a:	5b                   	pop    %ebx
  80116b:	5e                   	pop    %esi
  80116c:	5f                   	pop    %edi
  80116d:	5d                   	pop    %ebp
  80116e:	c3                   	ret    

0080116f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80116f:	55                   	push   %ebp
  801170:	89 e5                	mov    %esp,%ebp
  801172:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801175:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80117a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80117d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801183:	8b 52 50             	mov    0x50(%edx),%edx
  801186:	39 ca                	cmp    %ecx,%edx
  801188:	75 0d                	jne    801197 <ipc_find_env+0x28>
			return envs[i].env_id;
  80118a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80118d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801192:	8b 40 48             	mov    0x48(%eax),%eax
  801195:	eb 0f                	jmp    8011a6 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801197:	83 c0 01             	add    $0x1,%eax
  80119a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80119f:	75 d9                	jne    80117a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011a6:	5d                   	pop    %ebp
  8011a7:	c3                   	ret    

008011a8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ae:	05 00 00 00 30       	add    $0x30000000,%eax
  8011b3:	c1 e8 0c             	shr    $0xc,%eax
}
  8011b6:	5d                   	pop    %ebp
  8011b7:	c3                   	ret    

008011b8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8011be:	05 00 00 00 30       	add    $0x30000000,%eax
  8011c3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011c8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011cd:	5d                   	pop    %ebp
  8011ce:	c3                   	ret    

008011cf <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011cf:	55                   	push   %ebp
  8011d0:	89 e5                	mov    %esp,%ebp
  8011d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011da:	89 c2                	mov    %eax,%edx
  8011dc:	c1 ea 16             	shr    $0x16,%edx
  8011df:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011e6:	f6 c2 01             	test   $0x1,%dl
  8011e9:	74 11                	je     8011fc <fd_alloc+0x2d>
  8011eb:	89 c2                	mov    %eax,%edx
  8011ed:	c1 ea 0c             	shr    $0xc,%edx
  8011f0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f7:	f6 c2 01             	test   $0x1,%dl
  8011fa:	75 09                	jne    801205 <fd_alloc+0x36>
			*fd_store = fd;
  8011fc:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801203:	eb 17                	jmp    80121c <fd_alloc+0x4d>
  801205:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80120a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80120f:	75 c9                	jne    8011da <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801211:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801217:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80121c:	5d                   	pop    %ebp
  80121d:	c3                   	ret    

0080121e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80121e:	55                   	push   %ebp
  80121f:	89 e5                	mov    %esp,%ebp
  801221:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801224:	83 f8 1f             	cmp    $0x1f,%eax
  801227:	77 36                	ja     80125f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801229:	c1 e0 0c             	shl    $0xc,%eax
  80122c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801231:	89 c2                	mov    %eax,%edx
  801233:	c1 ea 16             	shr    $0x16,%edx
  801236:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80123d:	f6 c2 01             	test   $0x1,%dl
  801240:	74 24                	je     801266 <fd_lookup+0x48>
  801242:	89 c2                	mov    %eax,%edx
  801244:	c1 ea 0c             	shr    $0xc,%edx
  801247:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80124e:	f6 c2 01             	test   $0x1,%dl
  801251:	74 1a                	je     80126d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801253:	8b 55 0c             	mov    0xc(%ebp),%edx
  801256:	89 02                	mov    %eax,(%edx)
	return 0;
  801258:	b8 00 00 00 00       	mov    $0x0,%eax
  80125d:	eb 13                	jmp    801272 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80125f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801264:	eb 0c                	jmp    801272 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801266:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80126b:	eb 05                	jmp    801272 <fd_lookup+0x54>
  80126d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801272:	5d                   	pop    %ebp
  801273:	c3                   	ret    

00801274 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801274:	55                   	push   %ebp
  801275:	89 e5                	mov    %esp,%ebp
  801277:	83 ec 08             	sub    $0x8,%esp
  80127a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80127d:	ba 94 2b 80 00       	mov    $0x802b94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801282:	eb 13                	jmp    801297 <dev_lookup+0x23>
  801284:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801287:	39 08                	cmp    %ecx,(%eax)
  801289:	75 0c                	jne    801297 <dev_lookup+0x23>
			*dev = devtab[i];
  80128b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80128e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801290:	b8 00 00 00 00       	mov    $0x0,%eax
  801295:	eb 2e                	jmp    8012c5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801297:	8b 02                	mov    (%edx),%eax
  801299:	85 c0                	test   %eax,%eax
  80129b:	75 e7                	jne    801284 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80129d:	a1 08 40 80 00       	mov    0x804008,%eax
  8012a2:	8b 40 48             	mov    0x48(%eax),%eax
  8012a5:	83 ec 04             	sub    $0x4,%esp
  8012a8:	51                   	push   %ecx
  8012a9:	50                   	push   %eax
  8012aa:	68 18 2b 80 00       	push   $0x802b18
  8012af:	e8 d8 ef ff ff       	call   80028c <cprintf>
	*dev = 0;
  8012b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012b7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012bd:	83 c4 10             	add    $0x10,%esp
  8012c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012c5:	c9                   	leave  
  8012c6:	c3                   	ret    

008012c7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012c7:	55                   	push   %ebp
  8012c8:	89 e5                	mov    %esp,%ebp
  8012ca:	56                   	push   %esi
  8012cb:	53                   	push   %ebx
  8012cc:	83 ec 10             	sub    $0x10,%esp
  8012cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8012d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d8:	50                   	push   %eax
  8012d9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012df:	c1 e8 0c             	shr    $0xc,%eax
  8012e2:	50                   	push   %eax
  8012e3:	e8 36 ff ff ff       	call   80121e <fd_lookup>
  8012e8:	83 c4 08             	add    $0x8,%esp
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	78 05                	js     8012f4 <fd_close+0x2d>
	    || fd != fd2)
  8012ef:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012f2:	74 0c                	je     801300 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012f4:	84 db                	test   %bl,%bl
  8012f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8012fb:	0f 44 c2             	cmove  %edx,%eax
  8012fe:	eb 41                	jmp    801341 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801300:	83 ec 08             	sub    $0x8,%esp
  801303:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801306:	50                   	push   %eax
  801307:	ff 36                	pushl  (%esi)
  801309:	e8 66 ff ff ff       	call   801274 <dev_lookup>
  80130e:	89 c3                	mov    %eax,%ebx
  801310:	83 c4 10             	add    $0x10,%esp
  801313:	85 c0                	test   %eax,%eax
  801315:	78 1a                	js     801331 <fd_close+0x6a>
		if (dev->dev_close)
  801317:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80131d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801322:	85 c0                	test   %eax,%eax
  801324:	74 0b                	je     801331 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801326:	83 ec 0c             	sub    $0xc,%esp
  801329:	56                   	push   %esi
  80132a:	ff d0                	call   *%eax
  80132c:	89 c3                	mov    %eax,%ebx
  80132e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801331:	83 ec 08             	sub    $0x8,%esp
  801334:	56                   	push   %esi
  801335:	6a 00                	push   $0x0
  801337:	e8 5d f9 ff ff       	call   800c99 <sys_page_unmap>
	return r;
  80133c:	83 c4 10             	add    $0x10,%esp
  80133f:	89 d8                	mov    %ebx,%eax
}
  801341:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801344:	5b                   	pop    %ebx
  801345:	5e                   	pop    %esi
  801346:	5d                   	pop    %ebp
  801347:	c3                   	ret    

00801348 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801348:	55                   	push   %ebp
  801349:	89 e5                	mov    %esp,%ebp
  80134b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80134e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801351:	50                   	push   %eax
  801352:	ff 75 08             	pushl  0x8(%ebp)
  801355:	e8 c4 fe ff ff       	call   80121e <fd_lookup>
  80135a:	83 c4 08             	add    $0x8,%esp
  80135d:	85 c0                	test   %eax,%eax
  80135f:	78 10                	js     801371 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801361:	83 ec 08             	sub    $0x8,%esp
  801364:	6a 01                	push   $0x1
  801366:	ff 75 f4             	pushl  -0xc(%ebp)
  801369:	e8 59 ff ff ff       	call   8012c7 <fd_close>
  80136e:	83 c4 10             	add    $0x10,%esp
}
  801371:	c9                   	leave  
  801372:	c3                   	ret    

00801373 <close_all>:

void
close_all(void)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	53                   	push   %ebx
  801377:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80137a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80137f:	83 ec 0c             	sub    $0xc,%esp
  801382:	53                   	push   %ebx
  801383:	e8 c0 ff ff ff       	call   801348 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801388:	83 c3 01             	add    $0x1,%ebx
  80138b:	83 c4 10             	add    $0x10,%esp
  80138e:	83 fb 20             	cmp    $0x20,%ebx
  801391:	75 ec                	jne    80137f <close_all+0xc>
		close(i);
}
  801393:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801396:	c9                   	leave  
  801397:	c3                   	ret    

00801398 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801398:	55                   	push   %ebp
  801399:	89 e5                	mov    %esp,%ebp
  80139b:	57                   	push   %edi
  80139c:	56                   	push   %esi
  80139d:	53                   	push   %ebx
  80139e:	83 ec 2c             	sub    $0x2c,%esp
  8013a1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013a4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013a7:	50                   	push   %eax
  8013a8:	ff 75 08             	pushl  0x8(%ebp)
  8013ab:	e8 6e fe ff ff       	call   80121e <fd_lookup>
  8013b0:	83 c4 08             	add    $0x8,%esp
  8013b3:	85 c0                	test   %eax,%eax
  8013b5:	0f 88 c1 00 00 00    	js     80147c <dup+0xe4>
		return r;
	close(newfdnum);
  8013bb:	83 ec 0c             	sub    $0xc,%esp
  8013be:	56                   	push   %esi
  8013bf:	e8 84 ff ff ff       	call   801348 <close>

	newfd = INDEX2FD(newfdnum);
  8013c4:	89 f3                	mov    %esi,%ebx
  8013c6:	c1 e3 0c             	shl    $0xc,%ebx
  8013c9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013cf:	83 c4 04             	add    $0x4,%esp
  8013d2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013d5:	e8 de fd ff ff       	call   8011b8 <fd2data>
  8013da:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013dc:	89 1c 24             	mov    %ebx,(%esp)
  8013df:	e8 d4 fd ff ff       	call   8011b8 <fd2data>
  8013e4:	83 c4 10             	add    $0x10,%esp
  8013e7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013ea:	89 f8                	mov    %edi,%eax
  8013ec:	c1 e8 16             	shr    $0x16,%eax
  8013ef:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013f6:	a8 01                	test   $0x1,%al
  8013f8:	74 37                	je     801431 <dup+0x99>
  8013fa:	89 f8                	mov    %edi,%eax
  8013fc:	c1 e8 0c             	shr    $0xc,%eax
  8013ff:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801406:	f6 c2 01             	test   $0x1,%dl
  801409:	74 26                	je     801431 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80140b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801412:	83 ec 0c             	sub    $0xc,%esp
  801415:	25 07 0e 00 00       	and    $0xe07,%eax
  80141a:	50                   	push   %eax
  80141b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80141e:	6a 00                	push   $0x0
  801420:	57                   	push   %edi
  801421:	6a 00                	push   $0x0
  801423:	e8 2f f8 ff ff       	call   800c57 <sys_page_map>
  801428:	89 c7                	mov    %eax,%edi
  80142a:	83 c4 20             	add    $0x20,%esp
  80142d:	85 c0                	test   %eax,%eax
  80142f:	78 2e                	js     80145f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801431:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801434:	89 d0                	mov    %edx,%eax
  801436:	c1 e8 0c             	shr    $0xc,%eax
  801439:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801440:	83 ec 0c             	sub    $0xc,%esp
  801443:	25 07 0e 00 00       	and    $0xe07,%eax
  801448:	50                   	push   %eax
  801449:	53                   	push   %ebx
  80144a:	6a 00                	push   $0x0
  80144c:	52                   	push   %edx
  80144d:	6a 00                	push   $0x0
  80144f:	e8 03 f8 ff ff       	call   800c57 <sys_page_map>
  801454:	89 c7                	mov    %eax,%edi
  801456:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801459:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80145b:	85 ff                	test   %edi,%edi
  80145d:	79 1d                	jns    80147c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80145f:	83 ec 08             	sub    $0x8,%esp
  801462:	53                   	push   %ebx
  801463:	6a 00                	push   $0x0
  801465:	e8 2f f8 ff ff       	call   800c99 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80146a:	83 c4 08             	add    $0x8,%esp
  80146d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801470:	6a 00                	push   $0x0
  801472:	e8 22 f8 ff ff       	call   800c99 <sys_page_unmap>
	return r;
  801477:	83 c4 10             	add    $0x10,%esp
  80147a:	89 f8                	mov    %edi,%eax
}
  80147c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80147f:	5b                   	pop    %ebx
  801480:	5e                   	pop    %esi
  801481:	5f                   	pop    %edi
  801482:	5d                   	pop    %ebp
  801483:	c3                   	ret    

00801484 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801484:	55                   	push   %ebp
  801485:	89 e5                	mov    %esp,%ebp
  801487:	53                   	push   %ebx
  801488:	83 ec 14             	sub    $0x14,%esp
  80148b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80148e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801491:	50                   	push   %eax
  801492:	53                   	push   %ebx
  801493:	e8 86 fd ff ff       	call   80121e <fd_lookup>
  801498:	83 c4 08             	add    $0x8,%esp
  80149b:	89 c2                	mov    %eax,%edx
  80149d:	85 c0                	test   %eax,%eax
  80149f:	78 6d                	js     80150e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a1:	83 ec 08             	sub    $0x8,%esp
  8014a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a7:	50                   	push   %eax
  8014a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ab:	ff 30                	pushl  (%eax)
  8014ad:	e8 c2 fd ff ff       	call   801274 <dev_lookup>
  8014b2:	83 c4 10             	add    $0x10,%esp
  8014b5:	85 c0                	test   %eax,%eax
  8014b7:	78 4c                	js     801505 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014b9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014bc:	8b 42 08             	mov    0x8(%edx),%eax
  8014bf:	83 e0 03             	and    $0x3,%eax
  8014c2:	83 f8 01             	cmp    $0x1,%eax
  8014c5:	75 21                	jne    8014e8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014c7:	a1 08 40 80 00       	mov    0x804008,%eax
  8014cc:	8b 40 48             	mov    0x48(%eax),%eax
  8014cf:	83 ec 04             	sub    $0x4,%esp
  8014d2:	53                   	push   %ebx
  8014d3:	50                   	push   %eax
  8014d4:	68 59 2b 80 00       	push   $0x802b59
  8014d9:	e8 ae ed ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  8014de:	83 c4 10             	add    $0x10,%esp
  8014e1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014e6:	eb 26                	jmp    80150e <read+0x8a>
	}
	if (!dev->dev_read)
  8014e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014eb:	8b 40 08             	mov    0x8(%eax),%eax
  8014ee:	85 c0                	test   %eax,%eax
  8014f0:	74 17                	je     801509 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014f2:	83 ec 04             	sub    $0x4,%esp
  8014f5:	ff 75 10             	pushl  0x10(%ebp)
  8014f8:	ff 75 0c             	pushl  0xc(%ebp)
  8014fb:	52                   	push   %edx
  8014fc:	ff d0                	call   *%eax
  8014fe:	89 c2                	mov    %eax,%edx
  801500:	83 c4 10             	add    $0x10,%esp
  801503:	eb 09                	jmp    80150e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801505:	89 c2                	mov    %eax,%edx
  801507:	eb 05                	jmp    80150e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801509:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80150e:	89 d0                	mov    %edx,%eax
  801510:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801513:	c9                   	leave  
  801514:	c3                   	ret    

00801515 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	57                   	push   %edi
  801519:	56                   	push   %esi
  80151a:	53                   	push   %ebx
  80151b:	83 ec 0c             	sub    $0xc,%esp
  80151e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801521:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801524:	bb 00 00 00 00       	mov    $0x0,%ebx
  801529:	eb 21                	jmp    80154c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80152b:	83 ec 04             	sub    $0x4,%esp
  80152e:	89 f0                	mov    %esi,%eax
  801530:	29 d8                	sub    %ebx,%eax
  801532:	50                   	push   %eax
  801533:	89 d8                	mov    %ebx,%eax
  801535:	03 45 0c             	add    0xc(%ebp),%eax
  801538:	50                   	push   %eax
  801539:	57                   	push   %edi
  80153a:	e8 45 ff ff ff       	call   801484 <read>
		if (m < 0)
  80153f:	83 c4 10             	add    $0x10,%esp
  801542:	85 c0                	test   %eax,%eax
  801544:	78 10                	js     801556 <readn+0x41>
			return m;
		if (m == 0)
  801546:	85 c0                	test   %eax,%eax
  801548:	74 0a                	je     801554 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80154a:	01 c3                	add    %eax,%ebx
  80154c:	39 f3                	cmp    %esi,%ebx
  80154e:	72 db                	jb     80152b <readn+0x16>
  801550:	89 d8                	mov    %ebx,%eax
  801552:	eb 02                	jmp    801556 <readn+0x41>
  801554:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801556:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801559:	5b                   	pop    %ebx
  80155a:	5e                   	pop    %esi
  80155b:	5f                   	pop    %edi
  80155c:	5d                   	pop    %ebp
  80155d:	c3                   	ret    

0080155e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80155e:	55                   	push   %ebp
  80155f:	89 e5                	mov    %esp,%ebp
  801561:	53                   	push   %ebx
  801562:	83 ec 14             	sub    $0x14,%esp
  801565:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801568:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80156b:	50                   	push   %eax
  80156c:	53                   	push   %ebx
  80156d:	e8 ac fc ff ff       	call   80121e <fd_lookup>
  801572:	83 c4 08             	add    $0x8,%esp
  801575:	89 c2                	mov    %eax,%edx
  801577:	85 c0                	test   %eax,%eax
  801579:	78 68                	js     8015e3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157b:	83 ec 08             	sub    $0x8,%esp
  80157e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801581:	50                   	push   %eax
  801582:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801585:	ff 30                	pushl  (%eax)
  801587:	e8 e8 fc ff ff       	call   801274 <dev_lookup>
  80158c:	83 c4 10             	add    $0x10,%esp
  80158f:	85 c0                	test   %eax,%eax
  801591:	78 47                	js     8015da <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801593:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801596:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80159a:	75 21                	jne    8015bd <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80159c:	a1 08 40 80 00       	mov    0x804008,%eax
  8015a1:	8b 40 48             	mov    0x48(%eax),%eax
  8015a4:	83 ec 04             	sub    $0x4,%esp
  8015a7:	53                   	push   %ebx
  8015a8:	50                   	push   %eax
  8015a9:	68 75 2b 80 00       	push   $0x802b75
  8015ae:	e8 d9 ec ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  8015b3:	83 c4 10             	add    $0x10,%esp
  8015b6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015bb:	eb 26                	jmp    8015e3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015c0:	8b 52 0c             	mov    0xc(%edx),%edx
  8015c3:	85 d2                	test   %edx,%edx
  8015c5:	74 17                	je     8015de <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015c7:	83 ec 04             	sub    $0x4,%esp
  8015ca:	ff 75 10             	pushl  0x10(%ebp)
  8015cd:	ff 75 0c             	pushl  0xc(%ebp)
  8015d0:	50                   	push   %eax
  8015d1:	ff d2                	call   *%edx
  8015d3:	89 c2                	mov    %eax,%edx
  8015d5:	83 c4 10             	add    $0x10,%esp
  8015d8:	eb 09                	jmp    8015e3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015da:	89 c2                	mov    %eax,%edx
  8015dc:	eb 05                	jmp    8015e3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015de:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015e3:	89 d0                	mov    %edx,%eax
  8015e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e8:	c9                   	leave  
  8015e9:	c3                   	ret    

008015ea <seek>:

int
seek(int fdnum, off_t offset)
{
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015f0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015f3:	50                   	push   %eax
  8015f4:	ff 75 08             	pushl  0x8(%ebp)
  8015f7:	e8 22 fc ff ff       	call   80121e <fd_lookup>
  8015fc:	83 c4 08             	add    $0x8,%esp
  8015ff:	85 c0                	test   %eax,%eax
  801601:	78 0e                	js     801611 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801603:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801606:	8b 55 0c             	mov    0xc(%ebp),%edx
  801609:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80160c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801611:	c9                   	leave  
  801612:	c3                   	ret    

00801613 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801613:	55                   	push   %ebp
  801614:	89 e5                	mov    %esp,%ebp
  801616:	53                   	push   %ebx
  801617:	83 ec 14             	sub    $0x14,%esp
  80161a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80161d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801620:	50                   	push   %eax
  801621:	53                   	push   %ebx
  801622:	e8 f7 fb ff ff       	call   80121e <fd_lookup>
  801627:	83 c4 08             	add    $0x8,%esp
  80162a:	89 c2                	mov    %eax,%edx
  80162c:	85 c0                	test   %eax,%eax
  80162e:	78 65                	js     801695 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801630:	83 ec 08             	sub    $0x8,%esp
  801633:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801636:	50                   	push   %eax
  801637:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163a:	ff 30                	pushl  (%eax)
  80163c:	e8 33 fc ff ff       	call   801274 <dev_lookup>
  801641:	83 c4 10             	add    $0x10,%esp
  801644:	85 c0                	test   %eax,%eax
  801646:	78 44                	js     80168c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801648:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80164f:	75 21                	jne    801672 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801651:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801656:	8b 40 48             	mov    0x48(%eax),%eax
  801659:	83 ec 04             	sub    $0x4,%esp
  80165c:	53                   	push   %ebx
  80165d:	50                   	push   %eax
  80165e:	68 38 2b 80 00       	push   $0x802b38
  801663:	e8 24 ec ff ff       	call   80028c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801670:	eb 23                	jmp    801695 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801672:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801675:	8b 52 18             	mov    0x18(%edx),%edx
  801678:	85 d2                	test   %edx,%edx
  80167a:	74 14                	je     801690 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80167c:	83 ec 08             	sub    $0x8,%esp
  80167f:	ff 75 0c             	pushl  0xc(%ebp)
  801682:	50                   	push   %eax
  801683:	ff d2                	call   *%edx
  801685:	89 c2                	mov    %eax,%edx
  801687:	83 c4 10             	add    $0x10,%esp
  80168a:	eb 09                	jmp    801695 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168c:	89 c2                	mov    %eax,%edx
  80168e:	eb 05                	jmp    801695 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801690:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801695:	89 d0                	mov    %edx,%eax
  801697:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80169a:	c9                   	leave  
  80169b:	c3                   	ret    

0080169c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80169c:	55                   	push   %ebp
  80169d:	89 e5                	mov    %esp,%ebp
  80169f:	53                   	push   %ebx
  8016a0:	83 ec 14             	sub    $0x14,%esp
  8016a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a9:	50                   	push   %eax
  8016aa:	ff 75 08             	pushl  0x8(%ebp)
  8016ad:	e8 6c fb ff ff       	call   80121e <fd_lookup>
  8016b2:	83 c4 08             	add    $0x8,%esp
  8016b5:	89 c2                	mov    %eax,%edx
  8016b7:	85 c0                	test   %eax,%eax
  8016b9:	78 58                	js     801713 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016bb:	83 ec 08             	sub    $0x8,%esp
  8016be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c1:	50                   	push   %eax
  8016c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c5:	ff 30                	pushl  (%eax)
  8016c7:	e8 a8 fb ff ff       	call   801274 <dev_lookup>
  8016cc:	83 c4 10             	add    $0x10,%esp
  8016cf:	85 c0                	test   %eax,%eax
  8016d1:	78 37                	js     80170a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016da:	74 32                	je     80170e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016dc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016df:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016e6:	00 00 00 
	stat->st_isdir = 0;
  8016e9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016f0:	00 00 00 
	stat->st_dev = dev;
  8016f3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016f9:	83 ec 08             	sub    $0x8,%esp
  8016fc:	53                   	push   %ebx
  8016fd:	ff 75 f0             	pushl  -0x10(%ebp)
  801700:	ff 50 14             	call   *0x14(%eax)
  801703:	89 c2                	mov    %eax,%edx
  801705:	83 c4 10             	add    $0x10,%esp
  801708:	eb 09                	jmp    801713 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80170a:	89 c2                	mov    %eax,%edx
  80170c:	eb 05                	jmp    801713 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80170e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801713:	89 d0                	mov    %edx,%eax
  801715:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801718:	c9                   	leave  
  801719:	c3                   	ret    

0080171a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80171a:	55                   	push   %ebp
  80171b:	89 e5                	mov    %esp,%ebp
  80171d:	56                   	push   %esi
  80171e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80171f:	83 ec 08             	sub    $0x8,%esp
  801722:	6a 00                	push   $0x0
  801724:	ff 75 08             	pushl  0x8(%ebp)
  801727:	e8 d6 01 00 00       	call   801902 <open>
  80172c:	89 c3                	mov    %eax,%ebx
  80172e:	83 c4 10             	add    $0x10,%esp
  801731:	85 c0                	test   %eax,%eax
  801733:	78 1b                	js     801750 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801735:	83 ec 08             	sub    $0x8,%esp
  801738:	ff 75 0c             	pushl  0xc(%ebp)
  80173b:	50                   	push   %eax
  80173c:	e8 5b ff ff ff       	call   80169c <fstat>
  801741:	89 c6                	mov    %eax,%esi
	close(fd);
  801743:	89 1c 24             	mov    %ebx,(%esp)
  801746:	e8 fd fb ff ff       	call   801348 <close>
	return r;
  80174b:	83 c4 10             	add    $0x10,%esp
  80174e:	89 f0                	mov    %esi,%eax
}
  801750:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801753:	5b                   	pop    %ebx
  801754:	5e                   	pop    %esi
  801755:	5d                   	pop    %ebp
  801756:	c3                   	ret    

00801757 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801757:	55                   	push   %ebp
  801758:	89 e5                	mov    %esp,%ebp
  80175a:	56                   	push   %esi
  80175b:	53                   	push   %ebx
  80175c:	89 c6                	mov    %eax,%esi
  80175e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801760:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801767:	75 12                	jne    80177b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801769:	83 ec 0c             	sub    $0xc,%esp
  80176c:	6a 01                	push   $0x1
  80176e:	e8 fc f9 ff ff       	call   80116f <ipc_find_env>
  801773:	a3 00 40 80 00       	mov    %eax,0x804000
  801778:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80177b:	6a 07                	push   $0x7
  80177d:	68 00 50 80 00       	push   $0x805000
  801782:	56                   	push   %esi
  801783:	ff 35 00 40 80 00    	pushl  0x804000
  801789:	e8 8d f9 ff ff       	call   80111b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80178e:	83 c4 0c             	add    $0xc,%esp
  801791:	6a 00                	push   $0x0
  801793:	53                   	push   %ebx
  801794:	6a 00                	push   $0x0
  801796:	e8 19 f9 ff ff       	call   8010b4 <ipc_recv>
}
  80179b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80179e:	5b                   	pop    %ebx
  80179f:	5e                   	pop    %esi
  8017a0:	5d                   	pop    %ebp
  8017a1:	c3                   	ret    

008017a2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ae:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c0:	b8 02 00 00 00       	mov    $0x2,%eax
  8017c5:	e8 8d ff ff ff       	call   801757 <fsipc>
}
  8017ca:	c9                   	leave  
  8017cb:	c3                   	ret    

008017cc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e2:	b8 06 00 00 00       	mov    $0x6,%eax
  8017e7:	e8 6b ff ff ff       	call   801757 <fsipc>
}
  8017ec:	c9                   	leave  
  8017ed:	c3                   	ret    

008017ee <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017ee:	55                   	push   %ebp
  8017ef:	89 e5                	mov    %esp,%ebp
  8017f1:	53                   	push   %ebx
  8017f2:	83 ec 04             	sub    $0x4,%esp
  8017f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8017fe:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801803:	ba 00 00 00 00       	mov    $0x0,%edx
  801808:	b8 05 00 00 00       	mov    $0x5,%eax
  80180d:	e8 45 ff ff ff       	call   801757 <fsipc>
  801812:	85 c0                	test   %eax,%eax
  801814:	78 2c                	js     801842 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801816:	83 ec 08             	sub    $0x8,%esp
  801819:	68 00 50 80 00       	push   $0x805000
  80181e:	53                   	push   %ebx
  80181f:	e8 ed ef ff ff       	call   800811 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801824:	a1 80 50 80 00       	mov    0x805080,%eax
  801829:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80182f:	a1 84 50 80 00       	mov    0x805084,%eax
  801834:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80183a:	83 c4 10             	add    $0x10,%esp
  80183d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801842:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801845:	c9                   	leave  
  801846:	c3                   	ret    

00801847 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	83 ec 0c             	sub    $0xc,%esp
  80184d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801850:	8b 55 08             	mov    0x8(%ebp),%edx
  801853:	8b 52 0c             	mov    0xc(%edx),%edx
  801856:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80185c:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801861:	50                   	push   %eax
  801862:	ff 75 0c             	pushl  0xc(%ebp)
  801865:	68 08 50 80 00       	push   $0x805008
  80186a:	e8 34 f1 ff ff       	call   8009a3 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80186f:	ba 00 00 00 00       	mov    $0x0,%edx
  801874:	b8 04 00 00 00       	mov    $0x4,%eax
  801879:	e8 d9 fe ff ff       	call   801757 <fsipc>

}
  80187e:	c9                   	leave  
  80187f:	c3                   	ret    

00801880 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	56                   	push   %esi
  801884:	53                   	push   %ebx
  801885:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801888:	8b 45 08             	mov    0x8(%ebp),%eax
  80188b:	8b 40 0c             	mov    0xc(%eax),%eax
  80188e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801893:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801899:	ba 00 00 00 00       	mov    $0x0,%edx
  80189e:	b8 03 00 00 00       	mov    $0x3,%eax
  8018a3:	e8 af fe ff ff       	call   801757 <fsipc>
  8018a8:	89 c3                	mov    %eax,%ebx
  8018aa:	85 c0                	test   %eax,%eax
  8018ac:	78 4b                	js     8018f9 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018ae:	39 c6                	cmp    %eax,%esi
  8018b0:	73 16                	jae    8018c8 <devfile_read+0x48>
  8018b2:	68 a8 2b 80 00       	push   $0x802ba8
  8018b7:	68 af 2b 80 00       	push   $0x802baf
  8018bc:	6a 7c                	push   $0x7c
  8018be:	68 c4 2b 80 00       	push   $0x802bc4
  8018c3:	e8 24 0a 00 00       	call   8022ec <_panic>
	assert(r <= PGSIZE);
  8018c8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018cd:	7e 16                	jle    8018e5 <devfile_read+0x65>
  8018cf:	68 cf 2b 80 00       	push   $0x802bcf
  8018d4:	68 af 2b 80 00       	push   $0x802baf
  8018d9:	6a 7d                	push   $0x7d
  8018db:	68 c4 2b 80 00       	push   $0x802bc4
  8018e0:	e8 07 0a 00 00       	call   8022ec <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018e5:	83 ec 04             	sub    $0x4,%esp
  8018e8:	50                   	push   %eax
  8018e9:	68 00 50 80 00       	push   $0x805000
  8018ee:	ff 75 0c             	pushl  0xc(%ebp)
  8018f1:	e8 ad f0 ff ff       	call   8009a3 <memmove>
	return r;
  8018f6:	83 c4 10             	add    $0x10,%esp
}
  8018f9:	89 d8                	mov    %ebx,%eax
  8018fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018fe:	5b                   	pop    %ebx
  8018ff:	5e                   	pop    %esi
  801900:	5d                   	pop    %ebp
  801901:	c3                   	ret    

00801902 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	53                   	push   %ebx
  801906:	83 ec 20             	sub    $0x20,%esp
  801909:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80190c:	53                   	push   %ebx
  80190d:	e8 c6 ee ff ff       	call   8007d8 <strlen>
  801912:	83 c4 10             	add    $0x10,%esp
  801915:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80191a:	7f 67                	jg     801983 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80191c:	83 ec 0c             	sub    $0xc,%esp
  80191f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801922:	50                   	push   %eax
  801923:	e8 a7 f8 ff ff       	call   8011cf <fd_alloc>
  801928:	83 c4 10             	add    $0x10,%esp
		return r;
  80192b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80192d:	85 c0                	test   %eax,%eax
  80192f:	78 57                	js     801988 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801931:	83 ec 08             	sub    $0x8,%esp
  801934:	53                   	push   %ebx
  801935:	68 00 50 80 00       	push   $0x805000
  80193a:	e8 d2 ee ff ff       	call   800811 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80193f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801942:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801947:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80194a:	b8 01 00 00 00       	mov    $0x1,%eax
  80194f:	e8 03 fe ff ff       	call   801757 <fsipc>
  801954:	89 c3                	mov    %eax,%ebx
  801956:	83 c4 10             	add    $0x10,%esp
  801959:	85 c0                	test   %eax,%eax
  80195b:	79 14                	jns    801971 <open+0x6f>
		fd_close(fd, 0);
  80195d:	83 ec 08             	sub    $0x8,%esp
  801960:	6a 00                	push   $0x0
  801962:	ff 75 f4             	pushl  -0xc(%ebp)
  801965:	e8 5d f9 ff ff       	call   8012c7 <fd_close>
		return r;
  80196a:	83 c4 10             	add    $0x10,%esp
  80196d:	89 da                	mov    %ebx,%edx
  80196f:	eb 17                	jmp    801988 <open+0x86>
	}

	return fd2num(fd);
  801971:	83 ec 0c             	sub    $0xc,%esp
  801974:	ff 75 f4             	pushl  -0xc(%ebp)
  801977:	e8 2c f8 ff ff       	call   8011a8 <fd2num>
  80197c:	89 c2                	mov    %eax,%edx
  80197e:	83 c4 10             	add    $0x10,%esp
  801981:	eb 05                	jmp    801988 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801983:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801988:	89 d0                	mov    %edx,%eax
  80198a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198d:	c9                   	leave  
  80198e:	c3                   	ret    

0080198f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80198f:	55                   	push   %ebp
  801990:	89 e5                	mov    %esp,%ebp
  801992:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801995:	ba 00 00 00 00       	mov    $0x0,%edx
  80199a:	b8 08 00 00 00       	mov    $0x8,%eax
  80199f:	e8 b3 fd ff ff       	call   801757 <fsipc>
}
  8019a4:	c9                   	leave  
  8019a5:	c3                   	ret    

008019a6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019a6:	55                   	push   %ebp
  8019a7:	89 e5                	mov    %esp,%ebp
  8019a9:	56                   	push   %esi
  8019aa:	53                   	push   %ebx
  8019ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019ae:	83 ec 0c             	sub    $0xc,%esp
  8019b1:	ff 75 08             	pushl  0x8(%ebp)
  8019b4:	e8 ff f7 ff ff       	call   8011b8 <fd2data>
  8019b9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019bb:	83 c4 08             	add    $0x8,%esp
  8019be:	68 db 2b 80 00       	push   $0x802bdb
  8019c3:	53                   	push   %ebx
  8019c4:	e8 48 ee ff ff       	call   800811 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019c9:	8b 46 04             	mov    0x4(%esi),%eax
  8019cc:	2b 06                	sub    (%esi),%eax
  8019ce:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019d4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019db:	00 00 00 
	stat->st_dev = &devpipe;
  8019de:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  8019e5:	30 80 00 
	return 0;
}
  8019e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f0:	5b                   	pop    %ebx
  8019f1:	5e                   	pop    %esi
  8019f2:	5d                   	pop    %ebp
  8019f3:	c3                   	ret    

008019f4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019f4:	55                   	push   %ebp
  8019f5:	89 e5                	mov    %esp,%ebp
  8019f7:	53                   	push   %ebx
  8019f8:	83 ec 0c             	sub    $0xc,%esp
  8019fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019fe:	53                   	push   %ebx
  8019ff:	6a 00                	push   $0x0
  801a01:	e8 93 f2 ff ff       	call   800c99 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a06:	89 1c 24             	mov    %ebx,(%esp)
  801a09:	e8 aa f7 ff ff       	call   8011b8 <fd2data>
  801a0e:	83 c4 08             	add    $0x8,%esp
  801a11:	50                   	push   %eax
  801a12:	6a 00                	push   $0x0
  801a14:	e8 80 f2 ff ff       	call   800c99 <sys_page_unmap>
}
  801a19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1c:	c9                   	leave  
  801a1d:	c3                   	ret    

00801a1e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a1e:	55                   	push   %ebp
  801a1f:	89 e5                	mov    %esp,%ebp
  801a21:	57                   	push   %edi
  801a22:	56                   	push   %esi
  801a23:	53                   	push   %ebx
  801a24:	83 ec 1c             	sub    $0x1c,%esp
  801a27:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a2a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a2c:	a1 08 40 80 00       	mov    0x804008,%eax
  801a31:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a34:	83 ec 0c             	sub    $0xc,%esp
  801a37:	ff 75 e0             	pushl  -0x20(%ebp)
  801a3a:	e8 5e 09 00 00       	call   80239d <pageref>
  801a3f:	89 c3                	mov    %eax,%ebx
  801a41:	89 3c 24             	mov    %edi,(%esp)
  801a44:	e8 54 09 00 00       	call   80239d <pageref>
  801a49:	83 c4 10             	add    $0x10,%esp
  801a4c:	39 c3                	cmp    %eax,%ebx
  801a4e:	0f 94 c1             	sete   %cl
  801a51:	0f b6 c9             	movzbl %cl,%ecx
  801a54:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a57:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a5d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a60:	39 ce                	cmp    %ecx,%esi
  801a62:	74 1b                	je     801a7f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a64:	39 c3                	cmp    %eax,%ebx
  801a66:	75 c4                	jne    801a2c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a68:	8b 42 58             	mov    0x58(%edx),%eax
  801a6b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a6e:	50                   	push   %eax
  801a6f:	56                   	push   %esi
  801a70:	68 e2 2b 80 00       	push   $0x802be2
  801a75:	e8 12 e8 ff ff       	call   80028c <cprintf>
  801a7a:	83 c4 10             	add    $0x10,%esp
  801a7d:	eb ad                	jmp    801a2c <_pipeisclosed+0xe>
	}
}
  801a7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a85:	5b                   	pop    %ebx
  801a86:	5e                   	pop    %esi
  801a87:	5f                   	pop    %edi
  801a88:	5d                   	pop    %ebp
  801a89:	c3                   	ret    

00801a8a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a8a:	55                   	push   %ebp
  801a8b:	89 e5                	mov    %esp,%ebp
  801a8d:	57                   	push   %edi
  801a8e:	56                   	push   %esi
  801a8f:	53                   	push   %ebx
  801a90:	83 ec 28             	sub    $0x28,%esp
  801a93:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a96:	56                   	push   %esi
  801a97:	e8 1c f7 ff ff       	call   8011b8 <fd2data>
  801a9c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a9e:	83 c4 10             	add    $0x10,%esp
  801aa1:	bf 00 00 00 00       	mov    $0x0,%edi
  801aa6:	eb 4b                	jmp    801af3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801aa8:	89 da                	mov    %ebx,%edx
  801aaa:	89 f0                	mov    %esi,%eax
  801aac:	e8 6d ff ff ff       	call   801a1e <_pipeisclosed>
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	75 48                	jne    801afd <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ab5:	e8 3b f1 ff ff       	call   800bf5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801aba:	8b 43 04             	mov    0x4(%ebx),%eax
  801abd:	8b 0b                	mov    (%ebx),%ecx
  801abf:	8d 51 20             	lea    0x20(%ecx),%edx
  801ac2:	39 d0                	cmp    %edx,%eax
  801ac4:	73 e2                	jae    801aa8 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ac6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ac9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801acd:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ad0:	89 c2                	mov    %eax,%edx
  801ad2:	c1 fa 1f             	sar    $0x1f,%edx
  801ad5:	89 d1                	mov    %edx,%ecx
  801ad7:	c1 e9 1b             	shr    $0x1b,%ecx
  801ada:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801add:	83 e2 1f             	and    $0x1f,%edx
  801ae0:	29 ca                	sub    %ecx,%edx
  801ae2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ae6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801aea:	83 c0 01             	add    $0x1,%eax
  801aed:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801af0:	83 c7 01             	add    $0x1,%edi
  801af3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801af6:	75 c2                	jne    801aba <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801af8:	8b 45 10             	mov    0x10(%ebp),%eax
  801afb:	eb 05                	jmp    801b02 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801afd:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b05:	5b                   	pop    %ebx
  801b06:	5e                   	pop    %esi
  801b07:	5f                   	pop    %edi
  801b08:	5d                   	pop    %ebp
  801b09:	c3                   	ret    

00801b0a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b0a:	55                   	push   %ebp
  801b0b:	89 e5                	mov    %esp,%ebp
  801b0d:	57                   	push   %edi
  801b0e:	56                   	push   %esi
  801b0f:	53                   	push   %ebx
  801b10:	83 ec 18             	sub    $0x18,%esp
  801b13:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b16:	57                   	push   %edi
  801b17:	e8 9c f6 ff ff       	call   8011b8 <fd2data>
  801b1c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b1e:	83 c4 10             	add    $0x10,%esp
  801b21:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b26:	eb 3d                	jmp    801b65 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b28:	85 db                	test   %ebx,%ebx
  801b2a:	74 04                	je     801b30 <devpipe_read+0x26>
				return i;
  801b2c:	89 d8                	mov    %ebx,%eax
  801b2e:	eb 44                	jmp    801b74 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b30:	89 f2                	mov    %esi,%edx
  801b32:	89 f8                	mov    %edi,%eax
  801b34:	e8 e5 fe ff ff       	call   801a1e <_pipeisclosed>
  801b39:	85 c0                	test   %eax,%eax
  801b3b:	75 32                	jne    801b6f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b3d:	e8 b3 f0 ff ff       	call   800bf5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b42:	8b 06                	mov    (%esi),%eax
  801b44:	3b 46 04             	cmp    0x4(%esi),%eax
  801b47:	74 df                	je     801b28 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b49:	99                   	cltd   
  801b4a:	c1 ea 1b             	shr    $0x1b,%edx
  801b4d:	01 d0                	add    %edx,%eax
  801b4f:	83 e0 1f             	and    $0x1f,%eax
  801b52:	29 d0                	sub    %edx,%eax
  801b54:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b5c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b5f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b62:	83 c3 01             	add    $0x1,%ebx
  801b65:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b68:	75 d8                	jne    801b42 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b6a:	8b 45 10             	mov    0x10(%ebp),%eax
  801b6d:	eb 05                	jmp    801b74 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b6f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b77:	5b                   	pop    %ebx
  801b78:	5e                   	pop    %esi
  801b79:	5f                   	pop    %edi
  801b7a:	5d                   	pop    %ebp
  801b7b:	c3                   	ret    

00801b7c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b7c:	55                   	push   %ebp
  801b7d:	89 e5                	mov    %esp,%ebp
  801b7f:	56                   	push   %esi
  801b80:	53                   	push   %ebx
  801b81:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b87:	50                   	push   %eax
  801b88:	e8 42 f6 ff ff       	call   8011cf <fd_alloc>
  801b8d:	83 c4 10             	add    $0x10,%esp
  801b90:	89 c2                	mov    %eax,%edx
  801b92:	85 c0                	test   %eax,%eax
  801b94:	0f 88 2c 01 00 00    	js     801cc6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b9a:	83 ec 04             	sub    $0x4,%esp
  801b9d:	68 07 04 00 00       	push   $0x407
  801ba2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba5:	6a 00                	push   $0x0
  801ba7:	e8 68 f0 ff ff       	call   800c14 <sys_page_alloc>
  801bac:	83 c4 10             	add    $0x10,%esp
  801baf:	89 c2                	mov    %eax,%edx
  801bb1:	85 c0                	test   %eax,%eax
  801bb3:	0f 88 0d 01 00 00    	js     801cc6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bb9:	83 ec 0c             	sub    $0xc,%esp
  801bbc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bbf:	50                   	push   %eax
  801bc0:	e8 0a f6 ff ff       	call   8011cf <fd_alloc>
  801bc5:	89 c3                	mov    %eax,%ebx
  801bc7:	83 c4 10             	add    $0x10,%esp
  801bca:	85 c0                	test   %eax,%eax
  801bcc:	0f 88 e2 00 00 00    	js     801cb4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bd2:	83 ec 04             	sub    $0x4,%esp
  801bd5:	68 07 04 00 00       	push   $0x407
  801bda:	ff 75 f0             	pushl  -0x10(%ebp)
  801bdd:	6a 00                	push   $0x0
  801bdf:	e8 30 f0 ff ff       	call   800c14 <sys_page_alloc>
  801be4:	89 c3                	mov    %eax,%ebx
  801be6:	83 c4 10             	add    $0x10,%esp
  801be9:	85 c0                	test   %eax,%eax
  801beb:	0f 88 c3 00 00 00    	js     801cb4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bf1:	83 ec 0c             	sub    $0xc,%esp
  801bf4:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf7:	e8 bc f5 ff ff       	call   8011b8 <fd2data>
  801bfc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bfe:	83 c4 0c             	add    $0xc,%esp
  801c01:	68 07 04 00 00       	push   $0x407
  801c06:	50                   	push   %eax
  801c07:	6a 00                	push   $0x0
  801c09:	e8 06 f0 ff ff       	call   800c14 <sys_page_alloc>
  801c0e:	89 c3                	mov    %eax,%ebx
  801c10:	83 c4 10             	add    $0x10,%esp
  801c13:	85 c0                	test   %eax,%eax
  801c15:	0f 88 89 00 00 00    	js     801ca4 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c1b:	83 ec 0c             	sub    $0xc,%esp
  801c1e:	ff 75 f0             	pushl  -0x10(%ebp)
  801c21:	e8 92 f5 ff ff       	call   8011b8 <fd2data>
  801c26:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c2d:	50                   	push   %eax
  801c2e:	6a 00                	push   $0x0
  801c30:	56                   	push   %esi
  801c31:	6a 00                	push   $0x0
  801c33:	e8 1f f0 ff ff       	call   800c57 <sys_page_map>
  801c38:	89 c3                	mov    %eax,%ebx
  801c3a:	83 c4 20             	add    $0x20,%esp
  801c3d:	85 c0                	test   %eax,%eax
  801c3f:	78 55                	js     801c96 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c41:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c56:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801c5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c5f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c64:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c6b:	83 ec 0c             	sub    $0xc,%esp
  801c6e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c71:	e8 32 f5 ff ff       	call   8011a8 <fd2num>
  801c76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c79:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c7b:	83 c4 04             	add    $0x4,%esp
  801c7e:	ff 75 f0             	pushl  -0x10(%ebp)
  801c81:	e8 22 f5 ff ff       	call   8011a8 <fd2num>
  801c86:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c89:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c8c:	83 c4 10             	add    $0x10,%esp
  801c8f:	ba 00 00 00 00       	mov    $0x0,%edx
  801c94:	eb 30                	jmp    801cc6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c96:	83 ec 08             	sub    $0x8,%esp
  801c99:	56                   	push   %esi
  801c9a:	6a 00                	push   $0x0
  801c9c:	e8 f8 ef ff ff       	call   800c99 <sys_page_unmap>
  801ca1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ca4:	83 ec 08             	sub    $0x8,%esp
  801ca7:	ff 75 f0             	pushl  -0x10(%ebp)
  801caa:	6a 00                	push   $0x0
  801cac:	e8 e8 ef ff ff       	call   800c99 <sys_page_unmap>
  801cb1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cb4:	83 ec 08             	sub    $0x8,%esp
  801cb7:	ff 75 f4             	pushl  -0xc(%ebp)
  801cba:	6a 00                	push   $0x0
  801cbc:	e8 d8 ef ff ff       	call   800c99 <sys_page_unmap>
  801cc1:	83 c4 10             	add    $0x10,%esp
  801cc4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cc6:	89 d0                	mov    %edx,%eax
  801cc8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ccb:	5b                   	pop    %ebx
  801ccc:	5e                   	pop    %esi
  801ccd:	5d                   	pop    %ebp
  801cce:	c3                   	ret    

00801ccf <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ccf:	55                   	push   %ebp
  801cd0:	89 e5                	mov    %esp,%ebp
  801cd2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cd5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd8:	50                   	push   %eax
  801cd9:	ff 75 08             	pushl  0x8(%ebp)
  801cdc:	e8 3d f5 ff ff       	call   80121e <fd_lookup>
  801ce1:	83 c4 10             	add    $0x10,%esp
  801ce4:	85 c0                	test   %eax,%eax
  801ce6:	78 18                	js     801d00 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ce8:	83 ec 0c             	sub    $0xc,%esp
  801ceb:	ff 75 f4             	pushl  -0xc(%ebp)
  801cee:	e8 c5 f4 ff ff       	call   8011b8 <fd2data>
	return _pipeisclosed(fd, p);
  801cf3:	89 c2                	mov    %eax,%edx
  801cf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf8:	e8 21 fd ff ff       	call   801a1e <_pipeisclosed>
  801cfd:	83 c4 10             	add    $0x10,%esp
}
  801d00:	c9                   	leave  
  801d01:	c3                   	ret    

00801d02 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801d02:	55                   	push   %ebp
  801d03:	89 e5                	mov    %esp,%ebp
  801d05:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801d08:	68 fa 2b 80 00       	push   $0x802bfa
  801d0d:	ff 75 0c             	pushl  0xc(%ebp)
  801d10:	e8 fc ea ff ff       	call   800811 <strcpy>
	return 0;
}
  801d15:	b8 00 00 00 00       	mov    $0x0,%eax
  801d1a:	c9                   	leave  
  801d1b:	c3                   	ret    

00801d1c <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801d1c:	55                   	push   %ebp
  801d1d:	89 e5                	mov    %esp,%ebp
  801d1f:	53                   	push   %ebx
  801d20:	83 ec 10             	sub    $0x10,%esp
  801d23:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801d26:	53                   	push   %ebx
  801d27:	e8 71 06 00 00       	call   80239d <pageref>
  801d2c:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801d2f:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801d34:	83 f8 01             	cmp    $0x1,%eax
  801d37:	75 10                	jne    801d49 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801d39:	83 ec 0c             	sub    $0xc,%esp
  801d3c:	ff 73 0c             	pushl  0xc(%ebx)
  801d3f:	e8 c0 02 00 00       	call   802004 <nsipc_close>
  801d44:	89 c2                	mov    %eax,%edx
  801d46:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801d49:	89 d0                	mov    %edx,%eax
  801d4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d4e:	c9                   	leave  
  801d4f:	c3                   	ret    

00801d50 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
  801d53:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801d56:	6a 00                	push   $0x0
  801d58:	ff 75 10             	pushl  0x10(%ebp)
  801d5b:	ff 75 0c             	pushl  0xc(%ebp)
  801d5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d61:	ff 70 0c             	pushl  0xc(%eax)
  801d64:	e8 78 03 00 00       	call   8020e1 <nsipc_send>
}
  801d69:	c9                   	leave  
  801d6a:	c3                   	ret    

00801d6b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801d6b:	55                   	push   %ebp
  801d6c:	89 e5                	mov    %esp,%ebp
  801d6e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d71:	6a 00                	push   $0x0
  801d73:	ff 75 10             	pushl  0x10(%ebp)
  801d76:	ff 75 0c             	pushl  0xc(%ebp)
  801d79:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7c:	ff 70 0c             	pushl  0xc(%eax)
  801d7f:	e8 f1 02 00 00       	call   802075 <nsipc_recv>
}
  801d84:	c9                   	leave  
  801d85:	c3                   	ret    

00801d86 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801d86:	55                   	push   %ebp
  801d87:	89 e5                	mov    %esp,%ebp
  801d89:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d8c:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d8f:	52                   	push   %edx
  801d90:	50                   	push   %eax
  801d91:	e8 88 f4 ff ff       	call   80121e <fd_lookup>
  801d96:	83 c4 10             	add    $0x10,%esp
  801d99:	85 c0                	test   %eax,%eax
  801d9b:	78 17                	js     801db4 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da0:	8b 0d 44 30 80 00    	mov    0x803044,%ecx
  801da6:	39 08                	cmp    %ecx,(%eax)
  801da8:	75 05                	jne    801daf <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801daa:	8b 40 0c             	mov    0xc(%eax),%eax
  801dad:	eb 05                	jmp    801db4 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801daf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801db4:	c9                   	leave  
  801db5:	c3                   	ret    

00801db6 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801db6:	55                   	push   %ebp
  801db7:	89 e5                	mov    %esp,%ebp
  801db9:	56                   	push   %esi
  801dba:	53                   	push   %ebx
  801dbb:	83 ec 1c             	sub    $0x1c,%esp
  801dbe:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801dc0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dc3:	50                   	push   %eax
  801dc4:	e8 06 f4 ff ff       	call   8011cf <fd_alloc>
  801dc9:	89 c3                	mov    %eax,%ebx
  801dcb:	83 c4 10             	add    $0x10,%esp
  801dce:	85 c0                	test   %eax,%eax
  801dd0:	78 1b                	js     801ded <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801dd2:	83 ec 04             	sub    $0x4,%esp
  801dd5:	68 07 04 00 00       	push   $0x407
  801dda:	ff 75 f4             	pushl  -0xc(%ebp)
  801ddd:	6a 00                	push   $0x0
  801ddf:	e8 30 ee ff ff       	call   800c14 <sys_page_alloc>
  801de4:	89 c3                	mov    %eax,%ebx
  801de6:	83 c4 10             	add    $0x10,%esp
  801de9:	85 c0                	test   %eax,%eax
  801deb:	79 10                	jns    801dfd <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801ded:	83 ec 0c             	sub    $0xc,%esp
  801df0:	56                   	push   %esi
  801df1:	e8 0e 02 00 00       	call   802004 <nsipc_close>
		return r;
  801df6:	83 c4 10             	add    $0x10,%esp
  801df9:	89 d8                	mov    %ebx,%eax
  801dfb:	eb 24                	jmp    801e21 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801dfd:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e06:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801e12:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801e15:	83 ec 0c             	sub    $0xc,%esp
  801e18:	50                   	push   %eax
  801e19:	e8 8a f3 ff ff       	call   8011a8 <fd2num>
  801e1e:	83 c4 10             	add    $0x10,%esp
}
  801e21:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e24:	5b                   	pop    %ebx
  801e25:	5e                   	pop    %esi
  801e26:	5d                   	pop    %ebp
  801e27:	c3                   	ret    

00801e28 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e28:	55                   	push   %ebp
  801e29:	89 e5                	mov    %esp,%ebp
  801e2b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e31:	e8 50 ff ff ff       	call   801d86 <fd2sockid>
		return r;
  801e36:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e38:	85 c0                	test   %eax,%eax
  801e3a:	78 1f                	js     801e5b <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e3c:	83 ec 04             	sub    $0x4,%esp
  801e3f:	ff 75 10             	pushl  0x10(%ebp)
  801e42:	ff 75 0c             	pushl  0xc(%ebp)
  801e45:	50                   	push   %eax
  801e46:	e8 12 01 00 00       	call   801f5d <nsipc_accept>
  801e4b:	83 c4 10             	add    $0x10,%esp
		return r;
  801e4e:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e50:	85 c0                	test   %eax,%eax
  801e52:	78 07                	js     801e5b <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801e54:	e8 5d ff ff ff       	call   801db6 <alloc_sockfd>
  801e59:	89 c1                	mov    %eax,%ecx
}
  801e5b:	89 c8                	mov    %ecx,%eax
  801e5d:	c9                   	leave  
  801e5e:	c3                   	ret    

00801e5f <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e5f:	55                   	push   %ebp
  801e60:	89 e5                	mov    %esp,%ebp
  801e62:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e65:	8b 45 08             	mov    0x8(%ebp),%eax
  801e68:	e8 19 ff ff ff       	call   801d86 <fd2sockid>
  801e6d:	85 c0                	test   %eax,%eax
  801e6f:	78 12                	js     801e83 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801e71:	83 ec 04             	sub    $0x4,%esp
  801e74:	ff 75 10             	pushl  0x10(%ebp)
  801e77:	ff 75 0c             	pushl  0xc(%ebp)
  801e7a:	50                   	push   %eax
  801e7b:	e8 2d 01 00 00       	call   801fad <nsipc_bind>
  801e80:	83 c4 10             	add    $0x10,%esp
}
  801e83:	c9                   	leave  
  801e84:	c3                   	ret    

00801e85 <shutdown>:

int
shutdown(int s, int how)
{
  801e85:	55                   	push   %ebp
  801e86:	89 e5                	mov    %esp,%ebp
  801e88:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8e:	e8 f3 fe ff ff       	call   801d86 <fd2sockid>
  801e93:	85 c0                	test   %eax,%eax
  801e95:	78 0f                	js     801ea6 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801e97:	83 ec 08             	sub    $0x8,%esp
  801e9a:	ff 75 0c             	pushl  0xc(%ebp)
  801e9d:	50                   	push   %eax
  801e9e:	e8 3f 01 00 00       	call   801fe2 <nsipc_shutdown>
  801ea3:	83 c4 10             	add    $0x10,%esp
}
  801ea6:	c9                   	leave  
  801ea7:	c3                   	ret    

00801ea8 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ea8:	55                   	push   %ebp
  801ea9:	89 e5                	mov    %esp,%ebp
  801eab:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801eae:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb1:	e8 d0 fe ff ff       	call   801d86 <fd2sockid>
  801eb6:	85 c0                	test   %eax,%eax
  801eb8:	78 12                	js     801ecc <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801eba:	83 ec 04             	sub    $0x4,%esp
  801ebd:	ff 75 10             	pushl  0x10(%ebp)
  801ec0:	ff 75 0c             	pushl  0xc(%ebp)
  801ec3:	50                   	push   %eax
  801ec4:	e8 55 01 00 00       	call   80201e <nsipc_connect>
  801ec9:	83 c4 10             	add    $0x10,%esp
}
  801ecc:	c9                   	leave  
  801ecd:	c3                   	ret    

00801ece <listen>:

int
listen(int s, int backlog)
{
  801ece:	55                   	push   %ebp
  801ecf:	89 e5                	mov    %esp,%ebp
  801ed1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ed4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed7:	e8 aa fe ff ff       	call   801d86 <fd2sockid>
  801edc:	85 c0                	test   %eax,%eax
  801ede:	78 0f                	js     801eef <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801ee0:	83 ec 08             	sub    $0x8,%esp
  801ee3:	ff 75 0c             	pushl  0xc(%ebp)
  801ee6:	50                   	push   %eax
  801ee7:	e8 67 01 00 00       	call   802053 <nsipc_listen>
  801eec:	83 c4 10             	add    $0x10,%esp
}
  801eef:	c9                   	leave  
  801ef0:	c3                   	ret    

00801ef1 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801ef1:	55                   	push   %ebp
  801ef2:	89 e5                	mov    %esp,%ebp
  801ef4:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801ef7:	ff 75 10             	pushl  0x10(%ebp)
  801efa:	ff 75 0c             	pushl  0xc(%ebp)
  801efd:	ff 75 08             	pushl  0x8(%ebp)
  801f00:	e8 3a 02 00 00       	call   80213f <nsipc_socket>
  801f05:	83 c4 10             	add    $0x10,%esp
  801f08:	85 c0                	test   %eax,%eax
  801f0a:	78 05                	js     801f11 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801f0c:	e8 a5 fe ff ff       	call   801db6 <alloc_sockfd>
}
  801f11:	c9                   	leave  
  801f12:	c3                   	ret    

00801f13 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801f13:	55                   	push   %ebp
  801f14:	89 e5                	mov    %esp,%ebp
  801f16:	53                   	push   %ebx
  801f17:	83 ec 04             	sub    $0x4,%esp
  801f1a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801f1c:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801f23:	75 12                	jne    801f37 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801f25:	83 ec 0c             	sub    $0xc,%esp
  801f28:	6a 02                	push   $0x2
  801f2a:	e8 40 f2 ff ff       	call   80116f <ipc_find_env>
  801f2f:	a3 04 40 80 00       	mov    %eax,0x804004
  801f34:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801f37:	6a 07                	push   $0x7
  801f39:	68 00 60 80 00       	push   $0x806000
  801f3e:	53                   	push   %ebx
  801f3f:	ff 35 04 40 80 00    	pushl  0x804004
  801f45:	e8 d1 f1 ff ff       	call   80111b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801f4a:	83 c4 0c             	add    $0xc,%esp
  801f4d:	6a 00                	push   $0x0
  801f4f:	6a 00                	push   $0x0
  801f51:	6a 00                	push   $0x0
  801f53:	e8 5c f1 ff ff       	call   8010b4 <ipc_recv>
}
  801f58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f5b:	c9                   	leave  
  801f5c:	c3                   	ret    

00801f5d <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f5d:	55                   	push   %ebp
  801f5e:	89 e5                	mov    %esp,%ebp
  801f60:	56                   	push   %esi
  801f61:	53                   	push   %ebx
  801f62:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801f65:	8b 45 08             	mov    0x8(%ebp),%eax
  801f68:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801f6d:	8b 06                	mov    (%esi),%eax
  801f6f:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f74:	b8 01 00 00 00       	mov    $0x1,%eax
  801f79:	e8 95 ff ff ff       	call   801f13 <nsipc>
  801f7e:	89 c3                	mov    %eax,%ebx
  801f80:	85 c0                	test   %eax,%eax
  801f82:	78 20                	js     801fa4 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f84:	83 ec 04             	sub    $0x4,%esp
  801f87:	ff 35 10 60 80 00    	pushl  0x806010
  801f8d:	68 00 60 80 00       	push   $0x806000
  801f92:	ff 75 0c             	pushl  0xc(%ebp)
  801f95:	e8 09 ea ff ff       	call   8009a3 <memmove>
		*addrlen = ret->ret_addrlen;
  801f9a:	a1 10 60 80 00       	mov    0x806010,%eax
  801f9f:	89 06                	mov    %eax,(%esi)
  801fa1:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801fa4:	89 d8                	mov    %ebx,%eax
  801fa6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fa9:	5b                   	pop    %ebx
  801faa:	5e                   	pop    %esi
  801fab:	5d                   	pop    %ebp
  801fac:	c3                   	ret    

00801fad <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801fad:	55                   	push   %ebp
  801fae:	89 e5                	mov    %esp,%ebp
  801fb0:	53                   	push   %ebx
  801fb1:	83 ec 08             	sub    $0x8,%esp
  801fb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801fb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801fba:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801fbf:	53                   	push   %ebx
  801fc0:	ff 75 0c             	pushl  0xc(%ebp)
  801fc3:	68 04 60 80 00       	push   $0x806004
  801fc8:	e8 d6 e9 ff ff       	call   8009a3 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801fcd:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801fd3:	b8 02 00 00 00       	mov    $0x2,%eax
  801fd8:	e8 36 ff ff ff       	call   801f13 <nsipc>
}
  801fdd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fe0:	c9                   	leave  
  801fe1:	c3                   	ret    

00801fe2 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801fe2:	55                   	push   %ebp
  801fe3:	89 e5                	mov    %esp,%ebp
  801fe5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801fe8:	8b 45 08             	mov    0x8(%ebp),%eax
  801feb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801ff0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff3:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801ff8:	b8 03 00 00 00       	mov    $0x3,%eax
  801ffd:	e8 11 ff ff ff       	call   801f13 <nsipc>
}
  802002:	c9                   	leave  
  802003:	c3                   	ret    

00802004 <nsipc_close>:

int
nsipc_close(int s)
{
  802004:	55                   	push   %ebp
  802005:	89 e5                	mov    %esp,%ebp
  802007:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80200a:	8b 45 08             	mov    0x8(%ebp),%eax
  80200d:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  802012:	b8 04 00 00 00       	mov    $0x4,%eax
  802017:	e8 f7 fe ff ff       	call   801f13 <nsipc>
}
  80201c:	c9                   	leave  
  80201d:	c3                   	ret    

0080201e <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80201e:	55                   	push   %ebp
  80201f:	89 e5                	mov    %esp,%ebp
  802021:	53                   	push   %ebx
  802022:	83 ec 08             	sub    $0x8,%esp
  802025:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802028:	8b 45 08             	mov    0x8(%ebp),%eax
  80202b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802030:	53                   	push   %ebx
  802031:	ff 75 0c             	pushl  0xc(%ebp)
  802034:	68 04 60 80 00       	push   $0x806004
  802039:	e8 65 e9 ff ff       	call   8009a3 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80203e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  802044:	b8 05 00 00 00       	mov    $0x5,%eax
  802049:	e8 c5 fe ff ff       	call   801f13 <nsipc>
}
  80204e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802051:	c9                   	leave  
  802052:	c3                   	ret    

00802053 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802053:	55                   	push   %ebp
  802054:	89 e5                	mov    %esp,%ebp
  802056:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802059:	8b 45 08             	mov    0x8(%ebp),%eax
  80205c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  802061:	8b 45 0c             	mov    0xc(%ebp),%eax
  802064:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  802069:	b8 06 00 00 00       	mov    $0x6,%eax
  80206e:	e8 a0 fe ff ff       	call   801f13 <nsipc>
}
  802073:	c9                   	leave  
  802074:	c3                   	ret    

00802075 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802075:	55                   	push   %ebp
  802076:	89 e5                	mov    %esp,%ebp
  802078:	56                   	push   %esi
  802079:	53                   	push   %ebx
  80207a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80207d:	8b 45 08             	mov    0x8(%ebp),%eax
  802080:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  802085:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80208b:	8b 45 14             	mov    0x14(%ebp),%eax
  80208e:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802093:	b8 07 00 00 00       	mov    $0x7,%eax
  802098:	e8 76 fe ff ff       	call   801f13 <nsipc>
  80209d:	89 c3                	mov    %eax,%ebx
  80209f:	85 c0                	test   %eax,%eax
  8020a1:	78 35                	js     8020d8 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8020a3:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8020a8:	7f 04                	jg     8020ae <nsipc_recv+0x39>
  8020aa:	39 c6                	cmp    %eax,%esi
  8020ac:	7d 16                	jge    8020c4 <nsipc_recv+0x4f>
  8020ae:	68 06 2c 80 00       	push   $0x802c06
  8020b3:	68 af 2b 80 00       	push   $0x802baf
  8020b8:	6a 62                	push   $0x62
  8020ba:	68 1b 2c 80 00       	push   $0x802c1b
  8020bf:	e8 28 02 00 00       	call   8022ec <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8020c4:	83 ec 04             	sub    $0x4,%esp
  8020c7:	50                   	push   %eax
  8020c8:	68 00 60 80 00       	push   $0x806000
  8020cd:	ff 75 0c             	pushl  0xc(%ebp)
  8020d0:	e8 ce e8 ff ff       	call   8009a3 <memmove>
  8020d5:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8020d8:	89 d8                	mov    %ebx,%eax
  8020da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020dd:	5b                   	pop    %ebx
  8020de:	5e                   	pop    %esi
  8020df:	5d                   	pop    %ebp
  8020e0:	c3                   	ret    

008020e1 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8020e1:	55                   	push   %ebp
  8020e2:	89 e5                	mov    %esp,%ebp
  8020e4:	53                   	push   %ebx
  8020e5:	83 ec 04             	sub    $0x4,%esp
  8020e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8020eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ee:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8020f3:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8020f9:	7e 16                	jle    802111 <nsipc_send+0x30>
  8020fb:	68 27 2c 80 00       	push   $0x802c27
  802100:	68 af 2b 80 00       	push   $0x802baf
  802105:	6a 6d                	push   $0x6d
  802107:	68 1b 2c 80 00       	push   $0x802c1b
  80210c:	e8 db 01 00 00       	call   8022ec <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802111:	83 ec 04             	sub    $0x4,%esp
  802114:	53                   	push   %ebx
  802115:	ff 75 0c             	pushl  0xc(%ebp)
  802118:	68 0c 60 80 00       	push   $0x80600c
  80211d:	e8 81 e8 ff ff       	call   8009a3 <memmove>
	nsipcbuf.send.req_size = size;
  802122:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  802128:	8b 45 14             	mov    0x14(%ebp),%eax
  80212b:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  802130:	b8 08 00 00 00       	mov    $0x8,%eax
  802135:	e8 d9 fd ff ff       	call   801f13 <nsipc>
}
  80213a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80213d:	c9                   	leave  
  80213e:	c3                   	ret    

0080213f <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80213f:	55                   	push   %ebp
  802140:	89 e5                	mov    %esp,%ebp
  802142:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802145:	8b 45 08             	mov    0x8(%ebp),%eax
  802148:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80214d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802150:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802155:	8b 45 10             	mov    0x10(%ebp),%eax
  802158:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80215d:	b8 09 00 00 00       	mov    $0x9,%eax
  802162:	e8 ac fd ff ff       	call   801f13 <nsipc>
}
  802167:	c9                   	leave  
  802168:	c3                   	ret    

00802169 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802169:	55                   	push   %ebp
  80216a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80216c:	b8 00 00 00 00       	mov    $0x0,%eax
  802171:	5d                   	pop    %ebp
  802172:	c3                   	ret    

00802173 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802173:	55                   	push   %ebp
  802174:	89 e5                	mov    %esp,%ebp
  802176:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802179:	68 33 2c 80 00       	push   $0x802c33
  80217e:	ff 75 0c             	pushl  0xc(%ebp)
  802181:	e8 8b e6 ff ff       	call   800811 <strcpy>
	return 0;
}
  802186:	b8 00 00 00 00       	mov    $0x0,%eax
  80218b:	c9                   	leave  
  80218c:	c3                   	ret    

0080218d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80218d:	55                   	push   %ebp
  80218e:	89 e5                	mov    %esp,%ebp
  802190:	57                   	push   %edi
  802191:	56                   	push   %esi
  802192:	53                   	push   %ebx
  802193:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802199:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80219e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021a4:	eb 2d                	jmp    8021d3 <devcons_write+0x46>
		m = n - tot;
  8021a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021a9:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8021ab:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8021ae:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8021b3:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021b6:	83 ec 04             	sub    $0x4,%esp
  8021b9:	53                   	push   %ebx
  8021ba:	03 45 0c             	add    0xc(%ebp),%eax
  8021bd:	50                   	push   %eax
  8021be:	57                   	push   %edi
  8021bf:	e8 df e7 ff ff       	call   8009a3 <memmove>
		sys_cputs(buf, m);
  8021c4:	83 c4 08             	add    $0x8,%esp
  8021c7:	53                   	push   %ebx
  8021c8:	57                   	push   %edi
  8021c9:	e8 8a e9 ff ff       	call   800b58 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021ce:	01 de                	add    %ebx,%esi
  8021d0:	83 c4 10             	add    $0x10,%esp
  8021d3:	89 f0                	mov    %esi,%eax
  8021d5:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021d8:	72 cc                	jb     8021a6 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021dd:	5b                   	pop    %ebx
  8021de:	5e                   	pop    %esi
  8021df:	5f                   	pop    %edi
  8021e0:	5d                   	pop    %ebp
  8021e1:	c3                   	ret    

008021e2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021e2:	55                   	push   %ebp
  8021e3:	89 e5                	mov    %esp,%ebp
  8021e5:	83 ec 08             	sub    $0x8,%esp
  8021e8:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8021ed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021f1:	74 2a                	je     80221d <devcons_read+0x3b>
  8021f3:	eb 05                	jmp    8021fa <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021f5:	e8 fb e9 ff ff       	call   800bf5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021fa:	e8 77 e9 ff ff       	call   800b76 <sys_cgetc>
  8021ff:	85 c0                	test   %eax,%eax
  802201:	74 f2                	je     8021f5 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802203:	85 c0                	test   %eax,%eax
  802205:	78 16                	js     80221d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802207:	83 f8 04             	cmp    $0x4,%eax
  80220a:	74 0c                	je     802218 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80220c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80220f:	88 02                	mov    %al,(%edx)
	return 1;
  802211:	b8 01 00 00 00       	mov    $0x1,%eax
  802216:	eb 05                	jmp    80221d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802218:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80221d:	c9                   	leave  
  80221e:	c3                   	ret    

0080221f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80221f:	55                   	push   %ebp
  802220:	89 e5                	mov    %esp,%ebp
  802222:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802225:	8b 45 08             	mov    0x8(%ebp),%eax
  802228:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80222b:	6a 01                	push   $0x1
  80222d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802230:	50                   	push   %eax
  802231:	e8 22 e9 ff ff       	call   800b58 <sys_cputs>
}
  802236:	83 c4 10             	add    $0x10,%esp
  802239:	c9                   	leave  
  80223a:	c3                   	ret    

0080223b <getchar>:

int
getchar(void)
{
  80223b:	55                   	push   %ebp
  80223c:	89 e5                	mov    %esp,%ebp
  80223e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802241:	6a 01                	push   $0x1
  802243:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802246:	50                   	push   %eax
  802247:	6a 00                	push   $0x0
  802249:	e8 36 f2 ff ff       	call   801484 <read>
	if (r < 0)
  80224e:	83 c4 10             	add    $0x10,%esp
  802251:	85 c0                	test   %eax,%eax
  802253:	78 0f                	js     802264 <getchar+0x29>
		return r;
	if (r < 1)
  802255:	85 c0                	test   %eax,%eax
  802257:	7e 06                	jle    80225f <getchar+0x24>
		return -E_EOF;
	return c;
  802259:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80225d:	eb 05                	jmp    802264 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80225f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802264:	c9                   	leave  
  802265:	c3                   	ret    

00802266 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802266:	55                   	push   %ebp
  802267:	89 e5                	mov    %esp,%ebp
  802269:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80226c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80226f:	50                   	push   %eax
  802270:	ff 75 08             	pushl  0x8(%ebp)
  802273:	e8 a6 ef ff ff       	call   80121e <fd_lookup>
  802278:	83 c4 10             	add    $0x10,%esp
  80227b:	85 c0                	test   %eax,%eax
  80227d:	78 11                	js     802290 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80227f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802282:	8b 15 60 30 80 00    	mov    0x803060,%edx
  802288:	39 10                	cmp    %edx,(%eax)
  80228a:	0f 94 c0             	sete   %al
  80228d:	0f b6 c0             	movzbl %al,%eax
}
  802290:	c9                   	leave  
  802291:	c3                   	ret    

00802292 <opencons>:

int
opencons(void)
{
  802292:	55                   	push   %ebp
  802293:	89 e5                	mov    %esp,%ebp
  802295:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802298:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80229b:	50                   	push   %eax
  80229c:	e8 2e ef ff ff       	call   8011cf <fd_alloc>
  8022a1:	83 c4 10             	add    $0x10,%esp
		return r;
  8022a4:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022a6:	85 c0                	test   %eax,%eax
  8022a8:	78 3e                	js     8022e8 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022aa:	83 ec 04             	sub    $0x4,%esp
  8022ad:	68 07 04 00 00       	push   $0x407
  8022b2:	ff 75 f4             	pushl  -0xc(%ebp)
  8022b5:	6a 00                	push   $0x0
  8022b7:	e8 58 e9 ff ff       	call   800c14 <sys_page_alloc>
  8022bc:	83 c4 10             	add    $0x10,%esp
		return r;
  8022bf:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022c1:	85 c0                	test   %eax,%eax
  8022c3:	78 23                	js     8022e8 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022c5:	8b 15 60 30 80 00    	mov    0x803060,%edx
  8022cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ce:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022d3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022da:	83 ec 0c             	sub    $0xc,%esp
  8022dd:	50                   	push   %eax
  8022de:	e8 c5 ee ff ff       	call   8011a8 <fd2num>
  8022e3:	89 c2                	mov    %eax,%edx
  8022e5:	83 c4 10             	add    $0x10,%esp
}
  8022e8:	89 d0                	mov    %edx,%eax
  8022ea:	c9                   	leave  
  8022eb:	c3                   	ret    

008022ec <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8022ec:	55                   	push   %ebp
  8022ed:	89 e5                	mov    %esp,%ebp
  8022ef:	56                   	push   %esi
  8022f0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8022f1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8022f4:	8b 35 08 30 80 00    	mov    0x803008,%esi
  8022fa:	e8 d7 e8 ff ff       	call   800bd6 <sys_getenvid>
  8022ff:	83 ec 0c             	sub    $0xc,%esp
  802302:	ff 75 0c             	pushl  0xc(%ebp)
  802305:	ff 75 08             	pushl  0x8(%ebp)
  802308:	56                   	push   %esi
  802309:	50                   	push   %eax
  80230a:	68 40 2c 80 00       	push   $0x802c40
  80230f:	e8 78 df ff ff       	call   80028c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802314:	83 c4 18             	add    $0x18,%esp
  802317:	53                   	push   %ebx
  802318:	ff 75 10             	pushl  0x10(%ebp)
  80231b:	e8 1b df ff ff       	call   80023b <vcprintf>
	cprintf("\n");
  802320:	c7 04 24 f3 2b 80 00 	movl   $0x802bf3,(%esp)
  802327:	e8 60 df ff ff       	call   80028c <cprintf>
  80232c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80232f:	cc                   	int3   
  802330:	eb fd                	jmp    80232f <_panic+0x43>

00802332 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802332:	55                   	push   %ebp
  802333:	89 e5                	mov    %esp,%ebp
  802335:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802338:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80233f:	75 2e                	jne    80236f <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  802341:	e8 90 e8 ff ff       	call   800bd6 <sys_getenvid>
  802346:	83 ec 04             	sub    $0x4,%esp
  802349:	68 07 0e 00 00       	push   $0xe07
  80234e:	68 00 f0 bf ee       	push   $0xeebff000
  802353:	50                   	push   %eax
  802354:	e8 bb e8 ff ff       	call   800c14 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802359:	e8 78 e8 ff ff       	call   800bd6 <sys_getenvid>
  80235e:	83 c4 08             	add    $0x8,%esp
  802361:	68 79 23 80 00       	push   $0x802379
  802366:	50                   	push   %eax
  802367:	e8 f3 e9 ff ff       	call   800d5f <sys_env_set_pgfault_upcall>
  80236c:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80236f:	8b 45 08             	mov    0x8(%ebp),%eax
  802372:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802377:	c9                   	leave  
  802378:	c3                   	ret    

00802379 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802379:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80237a:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80237f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802381:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  802384:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  802388:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  80238c:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  80238f:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  802392:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  802393:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  802396:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  802397:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  802398:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  80239c:	c3                   	ret    

0080239d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80239d:	55                   	push   %ebp
  80239e:	89 e5                	mov    %esp,%ebp
  8023a0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023a3:	89 d0                	mov    %edx,%eax
  8023a5:	c1 e8 16             	shr    $0x16,%eax
  8023a8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023af:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023b4:	f6 c1 01             	test   $0x1,%cl
  8023b7:	74 1d                	je     8023d6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023b9:	c1 ea 0c             	shr    $0xc,%edx
  8023bc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023c3:	f6 c2 01             	test   $0x1,%dl
  8023c6:	74 0e                	je     8023d6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023c8:	c1 ea 0c             	shr    $0xc,%edx
  8023cb:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8023d2:	ef 
  8023d3:	0f b7 c0             	movzwl %ax,%eax
}
  8023d6:	5d                   	pop    %ebp
  8023d7:	c3                   	ret    
  8023d8:	66 90                	xchg   %ax,%ax
  8023da:	66 90                	xchg   %ax,%ax
  8023dc:	66 90                	xchg   %ax,%ax
  8023de:	66 90                	xchg   %ax,%ax

008023e0 <__udivdi3>:
  8023e0:	55                   	push   %ebp
  8023e1:	57                   	push   %edi
  8023e2:	56                   	push   %esi
  8023e3:	53                   	push   %ebx
  8023e4:	83 ec 1c             	sub    $0x1c,%esp
  8023e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8023eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8023ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8023f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023f7:	85 f6                	test   %esi,%esi
  8023f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023fd:	89 ca                	mov    %ecx,%edx
  8023ff:	89 f8                	mov    %edi,%eax
  802401:	75 3d                	jne    802440 <__udivdi3+0x60>
  802403:	39 cf                	cmp    %ecx,%edi
  802405:	0f 87 c5 00 00 00    	ja     8024d0 <__udivdi3+0xf0>
  80240b:	85 ff                	test   %edi,%edi
  80240d:	89 fd                	mov    %edi,%ebp
  80240f:	75 0b                	jne    80241c <__udivdi3+0x3c>
  802411:	b8 01 00 00 00       	mov    $0x1,%eax
  802416:	31 d2                	xor    %edx,%edx
  802418:	f7 f7                	div    %edi
  80241a:	89 c5                	mov    %eax,%ebp
  80241c:	89 c8                	mov    %ecx,%eax
  80241e:	31 d2                	xor    %edx,%edx
  802420:	f7 f5                	div    %ebp
  802422:	89 c1                	mov    %eax,%ecx
  802424:	89 d8                	mov    %ebx,%eax
  802426:	89 cf                	mov    %ecx,%edi
  802428:	f7 f5                	div    %ebp
  80242a:	89 c3                	mov    %eax,%ebx
  80242c:	89 d8                	mov    %ebx,%eax
  80242e:	89 fa                	mov    %edi,%edx
  802430:	83 c4 1c             	add    $0x1c,%esp
  802433:	5b                   	pop    %ebx
  802434:	5e                   	pop    %esi
  802435:	5f                   	pop    %edi
  802436:	5d                   	pop    %ebp
  802437:	c3                   	ret    
  802438:	90                   	nop
  802439:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802440:	39 ce                	cmp    %ecx,%esi
  802442:	77 74                	ja     8024b8 <__udivdi3+0xd8>
  802444:	0f bd fe             	bsr    %esi,%edi
  802447:	83 f7 1f             	xor    $0x1f,%edi
  80244a:	0f 84 98 00 00 00    	je     8024e8 <__udivdi3+0x108>
  802450:	bb 20 00 00 00       	mov    $0x20,%ebx
  802455:	89 f9                	mov    %edi,%ecx
  802457:	89 c5                	mov    %eax,%ebp
  802459:	29 fb                	sub    %edi,%ebx
  80245b:	d3 e6                	shl    %cl,%esi
  80245d:	89 d9                	mov    %ebx,%ecx
  80245f:	d3 ed                	shr    %cl,%ebp
  802461:	89 f9                	mov    %edi,%ecx
  802463:	d3 e0                	shl    %cl,%eax
  802465:	09 ee                	or     %ebp,%esi
  802467:	89 d9                	mov    %ebx,%ecx
  802469:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80246d:	89 d5                	mov    %edx,%ebp
  80246f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802473:	d3 ed                	shr    %cl,%ebp
  802475:	89 f9                	mov    %edi,%ecx
  802477:	d3 e2                	shl    %cl,%edx
  802479:	89 d9                	mov    %ebx,%ecx
  80247b:	d3 e8                	shr    %cl,%eax
  80247d:	09 c2                	or     %eax,%edx
  80247f:	89 d0                	mov    %edx,%eax
  802481:	89 ea                	mov    %ebp,%edx
  802483:	f7 f6                	div    %esi
  802485:	89 d5                	mov    %edx,%ebp
  802487:	89 c3                	mov    %eax,%ebx
  802489:	f7 64 24 0c          	mull   0xc(%esp)
  80248d:	39 d5                	cmp    %edx,%ebp
  80248f:	72 10                	jb     8024a1 <__udivdi3+0xc1>
  802491:	8b 74 24 08          	mov    0x8(%esp),%esi
  802495:	89 f9                	mov    %edi,%ecx
  802497:	d3 e6                	shl    %cl,%esi
  802499:	39 c6                	cmp    %eax,%esi
  80249b:	73 07                	jae    8024a4 <__udivdi3+0xc4>
  80249d:	39 d5                	cmp    %edx,%ebp
  80249f:	75 03                	jne    8024a4 <__udivdi3+0xc4>
  8024a1:	83 eb 01             	sub    $0x1,%ebx
  8024a4:	31 ff                	xor    %edi,%edi
  8024a6:	89 d8                	mov    %ebx,%eax
  8024a8:	89 fa                	mov    %edi,%edx
  8024aa:	83 c4 1c             	add    $0x1c,%esp
  8024ad:	5b                   	pop    %ebx
  8024ae:	5e                   	pop    %esi
  8024af:	5f                   	pop    %edi
  8024b0:	5d                   	pop    %ebp
  8024b1:	c3                   	ret    
  8024b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024b8:	31 ff                	xor    %edi,%edi
  8024ba:	31 db                	xor    %ebx,%ebx
  8024bc:	89 d8                	mov    %ebx,%eax
  8024be:	89 fa                	mov    %edi,%edx
  8024c0:	83 c4 1c             	add    $0x1c,%esp
  8024c3:	5b                   	pop    %ebx
  8024c4:	5e                   	pop    %esi
  8024c5:	5f                   	pop    %edi
  8024c6:	5d                   	pop    %ebp
  8024c7:	c3                   	ret    
  8024c8:	90                   	nop
  8024c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024d0:	89 d8                	mov    %ebx,%eax
  8024d2:	f7 f7                	div    %edi
  8024d4:	31 ff                	xor    %edi,%edi
  8024d6:	89 c3                	mov    %eax,%ebx
  8024d8:	89 d8                	mov    %ebx,%eax
  8024da:	89 fa                	mov    %edi,%edx
  8024dc:	83 c4 1c             	add    $0x1c,%esp
  8024df:	5b                   	pop    %ebx
  8024e0:	5e                   	pop    %esi
  8024e1:	5f                   	pop    %edi
  8024e2:	5d                   	pop    %ebp
  8024e3:	c3                   	ret    
  8024e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024e8:	39 ce                	cmp    %ecx,%esi
  8024ea:	72 0c                	jb     8024f8 <__udivdi3+0x118>
  8024ec:	31 db                	xor    %ebx,%ebx
  8024ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8024f2:	0f 87 34 ff ff ff    	ja     80242c <__udivdi3+0x4c>
  8024f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8024fd:	e9 2a ff ff ff       	jmp    80242c <__udivdi3+0x4c>
  802502:	66 90                	xchg   %ax,%ax
  802504:	66 90                	xchg   %ax,%ax
  802506:	66 90                	xchg   %ax,%ax
  802508:	66 90                	xchg   %ax,%ax
  80250a:	66 90                	xchg   %ax,%ax
  80250c:	66 90                	xchg   %ax,%ax
  80250e:	66 90                	xchg   %ax,%ax

00802510 <__umoddi3>:
  802510:	55                   	push   %ebp
  802511:	57                   	push   %edi
  802512:	56                   	push   %esi
  802513:	53                   	push   %ebx
  802514:	83 ec 1c             	sub    $0x1c,%esp
  802517:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80251b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80251f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802523:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802527:	85 d2                	test   %edx,%edx
  802529:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80252d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802531:	89 f3                	mov    %esi,%ebx
  802533:	89 3c 24             	mov    %edi,(%esp)
  802536:	89 74 24 04          	mov    %esi,0x4(%esp)
  80253a:	75 1c                	jne    802558 <__umoddi3+0x48>
  80253c:	39 f7                	cmp    %esi,%edi
  80253e:	76 50                	jbe    802590 <__umoddi3+0x80>
  802540:	89 c8                	mov    %ecx,%eax
  802542:	89 f2                	mov    %esi,%edx
  802544:	f7 f7                	div    %edi
  802546:	89 d0                	mov    %edx,%eax
  802548:	31 d2                	xor    %edx,%edx
  80254a:	83 c4 1c             	add    $0x1c,%esp
  80254d:	5b                   	pop    %ebx
  80254e:	5e                   	pop    %esi
  80254f:	5f                   	pop    %edi
  802550:	5d                   	pop    %ebp
  802551:	c3                   	ret    
  802552:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802558:	39 f2                	cmp    %esi,%edx
  80255a:	89 d0                	mov    %edx,%eax
  80255c:	77 52                	ja     8025b0 <__umoddi3+0xa0>
  80255e:	0f bd ea             	bsr    %edx,%ebp
  802561:	83 f5 1f             	xor    $0x1f,%ebp
  802564:	75 5a                	jne    8025c0 <__umoddi3+0xb0>
  802566:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80256a:	0f 82 e0 00 00 00    	jb     802650 <__umoddi3+0x140>
  802570:	39 0c 24             	cmp    %ecx,(%esp)
  802573:	0f 86 d7 00 00 00    	jbe    802650 <__umoddi3+0x140>
  802579:	8b 44 24 08          	mov    0x8(%esp),%eax
  80257d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802581:	83 c4 1c             	add    $0x1c,%esp
  802584:	5b                   	pop    %ebx
  802585:	5e                   	pop    %esi
  802586:	5f                   	pop    %edi
  802587:	5d                   	pop    %ebp
  802588:	c3                   	ret    
  802589:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802590:	85 ff                	test   %edi,%edi
  802592:	89 fd                	mov    %edi,%ebp
  802594:	75 0b                	jne    8025a1 <__umoddi3+0x91>
  802596:	b8 01 00 00 00       	mov    $0x1,%eax
  80259b:	31 d2                	xor    %edx,%edx
  80259d:	f7 f7                	div    %edi
  80259f:	89 c5                	mov    %eax,%ebp
  8025a1:	89 f0                	mov    %esi,%eax
  8025a3:	31 d2                	xor    %edx,%edx
  8025a5:	f7 f5                	div    %ebp
  8025a7:	89 c8                	mov    %ecx,%eax
  8025a9:	f7 f5                	div    %ebp
  8025ab:	89 d0                	mov    %edx,%eax
  8025ad:	eb 99                	jmp    802548 <__umoddi3+0x38>
  8025af:	90                   	nop
  8025b0:	89 c8                	mov    %ecx,%eax
  8025b2:	89 f2                	mov    %esi,%edx
  8025b4:	83 c4 1c             	add    $0x1c,%esp
  8025b7:	5b                   	pop    %ebx
  8025b8:	5e                   	pop    %esi
  8025b9:	5f                   	pop    %edi
  8025ba:	5d                   	pop    %ebp
  8025bb:	c3                   	ret    
  8025bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025c0:	8b 34 24             	mov    (%esp),%esi
  8025c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8025c8:	89 e9                	mov    %ebp,%ecx
  8025ca:	29 ef                	sub    %ebp,%edi
  8025cc:	d3 e0                	shl    %cl,%eax
  8025ce:	89 f9                	mov    %edi,%ecx
  8025d0:	89 f2                	mov    %esi,%edx
  8025d2:	d3 ea                	shr    %cl,%edx
  8025d4:	89 e9                	mov    %ebp,%ecx
  8025d6:	09 c2                	or     %eax,%edx
  8025d8:	89 d8                	mov    %ebx,%eax
  8025da:	89 14 24             	mov    %edx,(%esp)
  8025dd:	89 f2                	mov    %esi,%edx
  8025df:	d3 e2                	shl    %cl,%edx
  8025e1:	89 f9                	mov    %edi,%ecx
  8025e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8025eb:	d3 e8                	shr    %cl,%eax
  8025ed:	89 e9                	mov    %ebp,%ecx
  8025ef:	89 c6                	mov    %eax,%esi
  8025f1:	d3 e3                	shl    %cl,%ebx
  8025f3:	89 f9                	mov    %edi,%ecx
  8025f5:	89 d0                	mov    %edx,%eax
  8025f7:	d3 e8                	shr    %cl,%eax
  8025f9:	89 e9                	mov    %ebp,%ecx
  8025fb:	09 d8                	or     %ebx,%eax
  8025fd:	89 d3                	mov    %edx,%ebx
  8025ff:	89 f2                	mov    %esi,%edx
  802601:	f7 34 24             	divl   (%esp)
  802604:	89 d6                	mov    %edx,%esi
  802606:	d3 e3                	shl    %cl,%ebx
  802608:	f7 64 24 04          	mull   0x4(%esp)
  80260c:	39 d6                	cmp    %edx,%esi
  80260e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802612:	89 d1                	mov    %edx,%ecx
  802614:	89 c3                	mov    %eax,%ebx
  802616:	72 08                	jb     802620 <__umoddi3+0x110>
  802618:	75 11                	jne    80262b <__umoddi3+0x11b>
  80261a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80261e:	73 0b                	jae    80262b <__umoddi3+0x11b>
  802620:	2b 44 24 04          	sub    0x4(%esp),%eax
  802624:	1b 14 24             	sbb    (%esp),%edx
  802627:	89 d1                	mov    %edx,%ecx
  802629:	89 c3                	mov    %eax,%ebx
  80262b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80262f:	29 da                	sub    %ebx,%edx
  802631:	19 ce                	sbb    %ecx,%esi
  802633:	89 f9                	mov    %edi,%ecx
  802635:	89 f0                	mov    %esi,%eax
  802637:	d3 e0                	shl    %cl,%eax
  802639:	89 e9                	mov    %ebp,%ecx
  80263b:	d3 ea                	shr    %cl,%edx
  80263d:	89 e9                	mov    %ebp,%ecx
  80263f:	d3 ee                	shr    %cl,%esi
  802641:	09 d0                	or     %edx,%eax
  802643:	89 f2                	mov    %esi,%edx
  802645:	83 c4 1c             	add    $0x1c,%esp
  802648:	5b                   	pop    %ebx
  802649:	5e                   	pop    %esi
  80264a:	5f                   	pop    %edi
  80264b:	5d                   	pop    %ebp
  80264c:	c3                   	ret    
  80264d:	8d 76 00             	lea    0x0(%esi),%esi
  802650:	29 f9                	sub    %edi,%ecx
  802652:	19 d6                	sbb    %edx,%esi
  802654:	89 74 24 04          	mov    %esi,0x4(%esp)
  802658:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80265c:	e9 18 ff ff ff       	jmp    802579 <__umoddi3+0x69>
