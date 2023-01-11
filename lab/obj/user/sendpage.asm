
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
  800039:	e8 43 0f 00 00       	call   800f81 <fork>
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
  800057:	e8 dc 10 00 00       	call   801138 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 00 27 80 00       	push   $0x802700
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
  80009d:	68 14 27 80 00       	push   $0x802714
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
  8000db:	e8 bf 10 00 00       	call   80119f <ipc_send>
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
  800131:	e8 69 10 00 00       	call   80119f <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 ef 0f 00 00       	call   801138 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 00 27 80 00       	push   $0x802700
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
  80018a:	68 34 27 80 00       	push   $0x802734
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
  8001e5:	e8 0d 12 00 00       	call   8013f7 <close_all>
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
  8002ef:	e8 6c 21 00 00       	call   802460 <__udivdi3>
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
  800332:	e8 59 22 00 00       	call   802590 <__umoddi3>
  800337:	83 c4 14             	add    $0x14,%esp
  80033a:	0f be 80 ac 27 80 00 	movsbl 0x8027ac(%eax),%eax
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
  800436:	ff 24 85 e0 28 80 00 	jmp    *0x8028e0(,%eax,4)
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
  8004fa:	8b 14 85 40 2a 80 00 	mov    0x802a40(,%eax,4),%edx
  800501:	85 d2                	test   %edx,%edx
  800503:	75 18                	jne    80051d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800505:	50                   	push   %eax
  800506:	68 c4 27 80 00       	push   $0x8027c4
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
  80051e:	68 41 2c 80 00       	push   $0x802c41
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
  800542:	b8 bd 27 80 00       	mov    $0x8027bd,%eax
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
  800bbd:	68 9f 2a 80 00       	push   $0x802a9f
  800bc2:	6a 23                	push   $0x23
  800bc4:	68 bc 2a 80 00       	push   $0x802abc
  800bc9:	e8 a2 17 00 00       	call   802370 <_panic>

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
  800c3e:	68 9f 2a 80 00       	push   $0x802a9f
  800c43:	6a 23                	push   $0x23
  800c45:	68 bc 2a 80 00       	push   $0x802abc
  800c4a:	e8 21 17 00 00       	call   802370 <_panic>

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
  800c80:	68 9f 2a 80 00       	push   $0x802a9f
  800c85:	6a 23                	push   $0x23
  800c87:	68 bc 2a 80 00       	push   $0x802abc
  800c8c:	e8 df 16 00 00       	call   802370 <_panic>

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
  800cc2:	68 9f 2a 80 00       	push   $0x802a9f
  800cc7:	6a 23                	push   $0x23
  800cc9:	68 bc 2a 80 00       	push   $0x802abc
  800cce:	e8 9d 16 00 00       	call   802370 <_panic>

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
  800d04:	68 9f 2a 80 00       	push   $0x802a9f
  800d09:	6a 23                	push   $0x23
  800d0b:	68 bc 2a 80 00       	push   $0x802abc
  800d10:	e8 5b 16 00 00       	call   802370 <_panic>

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
  800d46:	68 9f 2a 80 00       	push   $0x802a9f
  800d4b:	6a 23                	push   $0x23
  800d4d:	68 bc 2a 80 00       	push   $0x802abc
  800d52:	e8 19 16 00 00       	call   802370 <_panic>

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
  800d88:	68 9f 2a 80 00       	push   $0x802a9f
  800d8d:	6a 23                	push   $0x23
  800d8f:	68 bc 2a 80 00       	push   $0x802abc
  800d94:	e8 d7 15 00 00       	call   802370 <_panic>

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
  800dec:	68 9f 2a 80 00       	push   $0x802a9f
  800df1:	6a 23                	push   $0x23
  800df3:	68 bc 2a 80 00       	push   $0x802abc
  800df8:	e8 73 15 00 00       	call   802370 <_panic>

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
  800e4d:	68 9f 2a 80 00       	push   $0x802a9f
  800e52:	6a 23                	push   $0x23
  800e54:	68 bc 2a 80 00       	push   $0x802abc
  800e59:	e8 12 15 00 00       	call   802370 <_panic>

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

00800e66 <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	57                   	push   %edi
  800e6a:	56                   	push   %esi
  800e6b:	53                   	push   %ebx
  800e6c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e74:	b8 10 00 00 00       	mov    $0x10,%eax
  800e79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7f:	89 df                	mov    %ebx,%edi
  800e81:	89 de                	mov    %ebx,%esi
  800e83:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e85:	85 c0                	test   %eax,%eax
  800e87:	7e 17                	jle    800ea0 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e89:	83 ec 0c             	sub    $0xc,%esp
  800e8c:	50                   	push   %eax
  800e8d:	6a 10                	push   $0x10
  800e8f:	68 9f 2a 80 00       	push   $0x802a9f
  800e94:	6a 23                	push   $0x23
  800e96:	68 bc 2a 80 00       	push   $0x802abc
  800e9b:	e8 d0 14 00 00       	call   802370 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  800ea0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea3:	5b                   	pop    %ebx
  800ea4:	5e                   	pop    %esi
  800ea5:	5f                   	pop    %edi
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    

00800ea8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	56                   	push   %esi
  800eac:	53                   	push   %ebx
  800ead:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800eb0:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800eb2:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800eb6:	75 25                	jne    800edd <pgfault+0x35>
  800eb8:	89 d8                	mov    %ebx,%eax
  800eba:	c1 e8 0c             	shr    $0xc,%eax
  800ebd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ec4:	f6 c4 08             	test   $0x8,%ah
  800ec7:	75 14                	jne    800edd <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800ec9:	83 ec 04             	sub    $0x4,%esp
  800ecc:	68 cc 2a 80 00       	push   $0x802acc
  800ed1:	6a 1e                	push   $0x1e
  800ed3:	68 60 2b 80 00       	push   $0x802b60
  800ed8:	e8 93 14 00 00       	call   802370 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800edd:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800ee3:	e8 ee fc ff ff       	call   800bd6 <sys_getenvid>
  800ee8:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800eea:	83 ec 04             	sub    $0x4,%esp
  800eed:	6a 07                	push   $0x7
  800eef:	68 00 f0 7f 00       	push   $0x7ff000
  800ef4:	50                   	push   %eax
  800ef5:	e8 1a fd ff ff       	call   800c14 <sys_page_alloc>
	if (r < 0)
  800efa:	83 c4 10             	add    $0x10,%esp
  800efd:	85 c0                	test   %eax,%eax
  800eff:	79 12                	jns    800f13 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800f01:	50                   	push   %eax
  800f02:	68 f8 2a 80 00       	push   $0x802af8
  800f07:	6a 33                	push   $0x33
  800f09:	68 60 2b 80 00       	push   $0x802b60
  800f0e:	e8 5d 14 00 00       	call   802370 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800f13:	83 ec 04             	sub    $0x4,%esp
  800f16:	68 00 10 00 00       	push   $0x1000
  800f1b:	53                   	push   %ebx
  800f1c:	68 00 f0 7f 00       	push   $0x7ff000
  800f21:	e8 e5 fa ff ff       	call   800a0b <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800f26:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f2d:	53                   	push   %ebx
  800f2e:	56                   	push   %esi
  800f2f:	68 00 f0 7f 00       	push   $0x7ff000
  800f34:	56                   	push   %esi
  800f35:	e8 1d fd ff ff       	call   800c57 <sys_page_map>
	if (r < 0)
  800f3a:	83 c4 20             	add    $0x20,%esp
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	79 12                	jns    800f53 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800f41:	50                   	push   %eax
  800f42:	68 1c 2b 80 00       	push   $0x802b1c
  800f47:	6a 3b                	push   $0x3b
  800f49:	68 60 2b 80 00       	push   $0x802b60
  800f4e:	e8 1d 14 00 00       	call   802370 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800f53:	83 ec 08             	sub    $0x8,%esp
  800f56:	68 00 f0 7f 00       	push   $0x7ff000
  800f5b:	56                   	push   %esi
  800f5c:	e8 38 fd ff ff       	call   800c99 <sys_page_unmap>
	if (r < 0)
  800f61:	83 c4 10             	add    $0x10,%esp
  800f64:	85 c0                	test   %eax,%eax
  800f66:	79 12                	jns    800f7a <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800f68:	50                   	push   %eax
  800f69:	68 40 2b 80 00       	push   $0x802b40
  800f6e:	6a 40                	push   $0x40
  800f70:	68 60 2b 80 00       	push   $0x802b60
  800f75:	e8 f6 13 00 00       	call   802370 <_panic>
}
  800f7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f7d:	5b                   	pop    %ebx
  800f7e:	5e                   	pop    %esi
  800f7f:	5d                   	pop    %ebp
  800f80:	c3                   	ret    

00800f81 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f81:	55                   	push   %ebp
  800f82:	89 e5                	mov    %esp,%ebp
  800f84:	57                   	push   %edi
  800f85:	56                   	push   %esi
  800f86:	53                   	push   %ebx
  800f87:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800f8a:	68 a8 0e 80 00       	push   $0x800ea8
  800f8f:	e8 22 14 00 00       	call   8023b6 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f94:	b8 07 00 00 00       	mov    $0x7,%eax
  800f99:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800f9b:	83 c4 10             	add    $0x10,%esp
  800f9e:	85 c0                	test   %eax,%eax
  800fa0:	0f 88 64 01 00 00    	js     80110a <fork+0x189>
  800fa6:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800fab:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800fb0:	85 c0                	test   %eax,%eax
  800fb2:	75 21                	jne    800fd5 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fb4:	e8 1d fc ff ff       	call   800bd6 <sys_getenvid>
  800fb9:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fbe:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fc1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fc6:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  800fcb:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd0:	e9 3f 01 00 00       	jmp    801114 <fork+0x193>
  800fd5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fd8:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800fda:	89 d8                	mov    %ebx,%eax
  800fdc:	c1 e8 16             	shr    $0x16,%eax
  800fdf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fe6:	a8 01                	test   $0x1,%al
  800fe8:	0f 84 bd 00 00 00    	je     8010ab <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800fee:	89 d8                	mov    %ebx,%eax
  800ff0:	c1 e8 0c             	shr    $0xc,%eax
  800ff3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ffa:	f6 c2 01             	test   $0x1,%dl
  800ffd:	0f 84 a8 00 00 00    	je     8010ab <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  801003:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80100a:	a8 04                	test   $0x4,%al
  80100c:	0f 84 99 00 00 00    	je     8010ab <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  801012:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801019:	f6 c4 04             	test   $0x4,%ah
  80101c:	74 17                	je     801035 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  80101e:	83 ec 0c             	sub    $0xc,%esp
  801021:	68 07 0e 00 00       	push   $0xe07
  801026:	53                   	push   %ebx
  801027:	57                   	push   %edi
  801028:	53                   	push   %ebx
  801029:	6a 00                	push   $0x0
  80102b:	e8 27 fc ff ff       	call   800c57 <sys_page_map>
  801030:	83 c4 20             	add    $0x20,%esp
  801033:	eb 76                	jmp    8010ab <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801035:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80103c:	a8 02                	test   $0x2,%al
  80103e:	75 0c                	jne    80104c <fork+0xcb>
  801040:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801047:	f6 c4 08             	test   $0x8,%ah
  80104a:	74 3f                	je     80108b <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  80104c:	83 ec 0c             	sub    $0xc,%esp
  80104f:	68 05 08 00 00       	push   $0x805
  801054:	53                   	push   %ebx
  801055:	57                   	push   %edi
  801056:	53                   	push   %ebx
  801057:	6a 00                	push   $0x0
  801059:	e8 f9 fb ff ff       	call   800c57 <sys_page_map>
		if (r < 0)
  80105e:	83 c4 20             	add    $0x20,%esp
  801061:	85 c0                	test   %eax,%eax
  801063:	0f 88 a5 00 00 00    	js     80110e <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  801069:	83 ec 0c             	sub    $0xc,%esp
  80106c:	68 05 08 00 00       	push   $0x805
  801071:	53                   	push   %ebx
  801072:	6a 00                	push   $0x0
  801074:	53                   	push   %ebx
  801075:	6a 00                	push   $0x0
  801077:	e8 db fb ff ff       	call   800c57 <sys_page_map>
  80107c:	83 c4 20             	add    $0x20,%esp
  80107f:	85 c0                	test   %eax,%eax
  801081:	b9 00 00 00 00       	mov    $0x0,%ecx
  801086:	0f 4f c1             	cmovg  %ecx,%eax
  801089:	eb 1c                	jmp    8010a7 <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  80108b:	83 ec 0c             	sub    $0xc,%esp
  80108e:	6a 05                	push   $0x5
  801090:	53                   	push   %ebx
  801091:	57                   	push   %edi
  801092:	53                   	push   %ebx
  801093:	6a 00                	push   $0x0
  801095:	e8 bd fb ff ff       	call   800c57 <sys_page_map>
  80109a:	83 c4 20             	add    $0x20,%esp
  80109d:	85 c0                	test   %eax,%eax
  80109f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010a4:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	78 67                	js     801112 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  8010ab:	83 c6 01             	add    $0x1,%esi
  8010ae:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010b4:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  8010ba:	0f 85 1a ff ff ff    	jne    800fda <fork+0x59>
  8010c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  8010c3:	83 ec 04             	sub    $0x4,%esp
  8010c6:	6a 07                	push   $0x7
  8010c8:	68 00 f0 bf ee       	push   $0xeebff000
  8010cd:	57                   	push   %edi
  8010ce:	e8 41 fb ff ff       	call   800c14 <sys_page_alloc>
	if (r < 0)
  8010d3:	83 c4 10             	add    $0x10,%esp
		return r;
  8010d6:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  8010d8:	85 c0                	test   %eax,%eax
  8010da:	78 38                	js     801114 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010dc:	83 ec 08             	sub    $0x8,%esp
  8010df:	68 fd 23 80 00       	push   $0x8023fd
  8010e4:	57                   	push   %edi
  8010e5:	e8 75 fc ff ff       	call   800d5f <sys_env_set_pgfault_upcall>
	if (r < 0)
  8010ea:	83 c4 10             	add    $0x10,%esp
		return r;
  8010ed:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  8010ef:	85 c0                	test   %eax,%eax
  8010f1:	78 21                	js     801114 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  8010f3:	83 ec 08             	sub    $0x8,%esp
  8010f6:	6a 02                	push   $0x2
  8010f8:	57                   	push   %edi
  8010f9:	e8 dd fb ff ff       	call   800cdb <sys_env_set_status>
	if (r < 0)
  8010fe:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801101:	85 c0                	test   %eax,%eax
  801103:	0f 48 f8             	cmovs  %eax,%edi
  801106:	89 fa                	mov    %edi,%edx
  801108:	eb 0a                	jmp    801114 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  80110a:	89 c2                	mov    %eax,%edx
  80110c:	eb 06                	jmp    801114 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  80110e:	89 c2                	mov    %eax,%edx
  801110:	eb 02                	jmp    801114 <fork+0x193>
  801112:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  801114:	89 d0                	mov    %edx,%eax
  801116:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801119:	5b                   	pop    %ebx
  80111a:	5e                   	pop    %esi
  80111b:	5f                   	pop    %edi
  80111c:	5d                   	pop    %ebp
  80111d:	c3                   	ret    

0080111e <sfork>:

// Challenge!
int
sfork(void)
{
  80111e:	55                   	push   %ebp
  80111f:	89 e5                	mov    %esp,%ebp
  801121:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801124:	68 6b 2b 80 00       	push   $0x802b6b
  801129:	68 c9 00 00 00       	push   $0xc9
  80112e:	68 60 2b 80 00       	push   $0x802b60
  801133:	e8 38 12 00 00       	call   802370 <_panic>

00801138 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801138:	55                   	push   %ebp
  801139:	89 e5                	mov    %esp,%ebp
  80113b:	56                   	push   %esi
  80113c:	53                   	push   %ebx
  80113d:	8b 75 08             	mov    0x8(%ebp),%esi
  801140:	8b 45 0c             	mov    0xc(%ebp),%eax
  801143:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801146:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801148:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80114d:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801150:	83 ec 0c             	sub    $0xc,%esp
  801153:	50                   	push   %eax
  801154:	e8 6b fc ff ff       	call   800dc4 <sys_ipc_recv>

	if (from_env_store != NULL)
  801159:	83 c4 10             	add    $0x10,%esp
  80115c:	85 f6                	test   %esi,%esi
  80115e:	74 14                	je     801174 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801160:	ba 00 00 00 00       	mov    $0x0,%edx
  801165:	85 c0                	test   %eax,%eax
  801167:	78 09                	js     801172 <ipc_recv+0x3a>
  801169:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80116f:	8b 52 74             	mov    0x74(%edx),%edx
  801172:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801174:	85 db                	test   %ebx,%ebx
  801176:	74 14                	je     80118c <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801178:	ba 00 00 00 00       	mov    $0x0,%edx
  80117d:	85 c0                	test   %eax,%eax
  80117f:	78 09                	js     80118a <ipc_recv+0x52>
  801181:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801187:	8b 52 78             	mov    0x78(%edx),%edx
  80118a:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80118c:	85 c0                	test   %eax,%eax
  80118e:	78 08                	js     801198 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801190:	a1 08 40 80 00       	mov    0x804008,%eax
  801195:	8b 40 70             	mov    0x70(%eax),%eax
}
  801198:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80119b:	5b                   	pop    %ebx
  80119c:	5e                   	pop    %esi
  80119d:	5d                   	pop    %ebp
  80119e:	c3                   	ret    

0080119f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80119f:	55                   	push   %ebp
  8011a0:	89 e5                	mov    %esp,%ebp
  8011a2:	57                   	push   %edi
  8011a3:	56                   	push   %esi
  8011a4:	53                   	push   %ebx
  8011a5:	83 ec 0c             	sub    $0xc,%esp
  8011a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011ab:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8011b1:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8011b3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8011b8:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8011bb:	ff 75 14             	pushl  0x14(%ebp)
  8011be:	53                   	push   %ebx
  8011bf:	56                   	push   %esi
  8011c0:	57                   	push   %edi
  8011c1:	e8 db fb ff ff       	call   800da1 <sys_ipc_try_send>

		if (err < 0) {
  8011c6:	83 c4 10             	add    $0x10,%esp
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	79 1e                	jns    8011eb <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8011cd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011d0:	75 07                	jne    8011d9 <ipc_send+0x3a>
				sys_yield();
  8011d2:	e8 1e fa ff ff       	call   800bf5 <sys_yield>
  8011d7:	eb e2                	jmp    8011bb <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8011d9:	50                   	push   %eax
  8011da:	68 81 2b 80 00       	push   $0x802b81
  8011df:	6a 49                	push   $0x49
  8011e1:	68 8e 2b 80 00       	push   $0x802b8e
  8011e6:	e8 85 11 00 00       	call   802370 <_panic>
		}

	} while (err < 0);

}
  8011eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ee:	5b                   	pop    %ebx
  8011ef:	5e                   	pop    %esi
  8011f0:	5f                   	pop    %edi
  8011f1:	5d                   	pop    %ebp
  8011f2:	c3                   	ret    

008011f3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011f9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011fe:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801201:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801207:	8b 52 50             	mov    0x50(%edx),%edx
  80120a:	39 ca                	cmp    %ecx,%edx
  80120c:	75 0d                	jne    80121b <ipc_find_env+0x28>
			return envs[i].env_id;
  80120e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801211:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801216:	8b 40 48             	mov    0x48(%eax),%eax
  801219:	eb 0f                	jmp    80122a <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80121b:	83 c0 01             	add    $0x1,%eax
  80121e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801223:	75 d9                	jne    8011fe <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801225:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80122a:	5d                   	pop    %ebp
  80122b:	c3                   	ret    

0080122c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80122f:	8b 45 08             	mov    0x8(%ebp),%eax
  801232:	05 00 00 00 30       	add    $0x30000000,%eax
  801237:	c1 e8 0c             	shr    $0xc,%eax
}
  80123a:	5d                   	pop    %ebp
  80123b:	c3                   	ret    

0080123c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80123f:	8b 45 08             	mov    0x8(%ebp),%eax
  801242:	05 00 00 00 30       	add    $0x30000000,%eax
  801247:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80124c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801251:	5d                   	pop    %ebp
  801252:	c3                   	ret    

00801253 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801259:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80125e:	89 c2                	mov    %eax,%edx
  801260:	c1 ea 16             	shr    $0x16,%edx
  801263:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80126a:	f6 c2 01             	test   $0x1,%dl
  80126d:	74 11                	je     801280 <fd_alloc+0x2d>
  80126f:	89 c2                	mov    %eax,%edx
  801271:	c1 ea 0c             	shr    $0xc,%edx
  801274:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80127b:	f6 c2 01             	test   $0x1,%dl
  80127e:	75 09                	jne    801289 <fd_alloc+0x36>
			*fd_store = fd;
  801280:	89 01                	mov    %eax,(%ecx)
			return 0;
  801282:	b8 00 00 00 00       	mov    $0x0,%eax
  801287:	eb 17                	jmp    8012a0 <fd_alloc+0x4d>
  801289:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80128e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801293:	75 c9                	jne    80125e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801295:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80129b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012a0:	5d                   	pop    %ebp
  8012a1:	c3                   	ret    

008012a2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
  8012a5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012a8:	83 f8 1f             	cmp    $0x1f,%eax
  8012ab:	77 36                	ja     8012e3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012ad:	c1 e0 0c             	shl    $0xc,%eax
  8012b0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012b5:	89 c2                	mov    %eax,%edx
  8012b7:	c1 ea 16             	shr    $0x16,%edx
  8012ba:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012c1:	f6 c2 01             	test   $0x1,%dl
  8012c4:	74 24                	je     8012ea <fd_lookup+0x48>
  8012c6:	89 c2                	mov    %eax,%edx
  8012c8:	c1 ea 0c             	shr    $0xc,%edx
  8012cb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012d2:	f6 c2 01             	test   $0x1,%dl
  8012d5:	74 1a                	je     8012f1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012da:	89 02                	mov    %eax,(%edx)
	return 0;
  8012dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e1:	eb 13                	jmp    8012f6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e8:	eb 0c                	jmp    8012f6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ef:	eb 05                	jmp    8012f6 <fd_lookup+0x54>
  8012f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012f6:	5d                   	pop    %ebp
  8012f7:	c3                   	ret    

008012f8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	83 ec 08             	sub    $0x8,%esp
  8012fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801301:	ba 14 2c 80 00       	mov    $0x802c14,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801306:	eb 13                	jmp    80131b <dev_lookup+0x23>
  801308:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80130b:	39 08                	cmp    %ecx,(%eax)
  80130d:	75 0c                	jne    80131b <dev_lookup+0x23>
			*dev = devtab[i];
  80130f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801312:	89 01                	mov    %eax,(%ecx)
			return 0;
  801314:	b8 00 00 00 00       	mov    $0x0,%eax
  801319:	eb 2e                	jmp    801349 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80131b:	8b 02                	mov    (%edx),%eax
  80131d:	85 c0                	test   %eax,%eax
  80131f:	75 e7                	jne    801308 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801321:	a1 08 40 80 00       	mov    0x804008,%eax
  801326:	8b 40 48             	mov    0x48(%eax),%eax
  801329:	83 ec 04             	sub    $0x4,%esp
  80132c:	51                   	push   %ecx
  80132d:	50                   	push   %eax
  80132e:	68 98 2b 80 00       	push   $0x802b98
  801333:	e8 54 ef ff ff       	call   80028c <cprintf>
	*dev = 0;
  801338:	8b 45 0c             	mov    0xc(%ebp),%eax
  80133b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801341:	83 c4 10             	add    $0x10,%esp
  801344:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801349:	c9                   	leave  
  80134a:	c3                   	ret    

0080134b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80134b:	55                   	push   %ebp
  80134c:	89 e5                	mov    %esp,%ebp
  80134e:	56                   	push   %esi
  80134f:	53                   	push   %ebx
  801350:	83 ec 10             	sub    $0x10,%esp
  801353:	8b 75 08             	mov    0x8(%ebp),%esi
  801356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801359:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135c:	50                   	push   %eax
  80135d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801363:	c1 e8 0c             	shr    $0xc,%eax
  801366:	50                   	push   %eax
  801367:	e8 36 ff ff ff       	call   8012a2 <fd_lookup>
  80136c:	83 c4 08             	add    $0x8,%esp
  80136f:	85 c0                	test   %eax,%eax
  801371:	78 05                	js     801378 <fd_close+0x2d>
	    || fd != fd2)
  801373:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801376:	74 0c                	je     801384 <fd_close+0x39>
		return (must_exist ? r : 0);
  801378:	84 db                	test   %bl,%bl
  80137a:	ba 00 00 00 00       	mov    $0x0,%edx
  80137f:	0f 44 c2             	cmove  %edx,%eax
  801382:	eb 41                	jmp    8013c5 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801384:	83 ec 08             	sub    $0x8,%esp
  801387:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138a:	50                   	push   %eax
  80138b:	ff 36                	pushl  (%esi)
  80138d:	e8 66 ff ff ff       	call   8012f8 <dev_lookup>
  801392:	89 c3                	mov    %eax,%ebx
  801394:	83 c4 10             	add    $0x10,%esp
  801397:	85 c0                	test   %eax,%eax
  801399:	78 1a                	js     8013b5 <fd_close+0x6a>
		if (dev->dev_close)
  80139b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013a1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013a6:	85 c0                	test   %eax,%eax
  8013a8:	74 0b                	je     8013b5 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013aa:	83 ec 0c             	sub    $0xc,%esp
  8013ad:	56                   	push   %esi
  8013ae:	ff d0                	call   *%eax
  8013b0:	89 c3                	mov    %eax,%ebx
  8013b2:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013b5:	83 ec 08             	sub    $0x8,%esp
  8013b8:	56                   	push   %esi
  8013b9:	6a 00                	push   $0x0
  8013bb:	e8 d9 f8 ff ff       	call   800c99 <sys_page_unmap>
	return r;
  8013c0:	83 c4 10             	add    $0x10,%esp
  8013c3:	89 d8                	mov    %ebx,%eax
}
  8013c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c8:	5b                   	pop    %ebx
  8013c9:	5e                   	pop    %esi
  8013ca:	5d                   	pop    %ebp
  8013cb:	c3                   	ret    

008013cc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013cc:	55                   	push   %ebp
  8013cd:	89 e5                	mov    %esp,%ebp
  8013cf:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d5:	50                   	push   %eax
  8013d6:	ff 75 08             	pushl  0x8(%ebp)
  8013d9:	e8 c4 fe ff ff       	call   8012a2 <fd_lookup>
  8013de:	83 c4 08             	add    $0x8,%esp
  8013e1:	85 c0                	test   %eax,%eax
  8013e3:	78 10                	js     8013f5 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013e5:	83 ec 08             	sub    $0x8,%esp
  8013e8:	6a 01                	push   $0x1
  8013ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8013ed:	e8 59 ff ff ff       	call   80134b <fd_close>
  8013f2:	83 c4 10             	add    $0x10,%esp
}
  8013f5:	c9                   	leave  
  8013f6:	c3                   	ret    

008013f7 <close_all>:

void
close_all(void)
{
  8013f7:	55                   	push   %ebp
  8013f8:	89 e5                	mov    %esp,%ebp
  8013fa:	53                   	push   %ebx
  8013fb:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013fe:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801403:	83 ec 0c             	sub    $0xc,%esp
  801406:	53                   	push   %ebx
  801407:	e8 c0 ff ff ff       	call   8013cc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80140c:	83 c3 01             	add    $0x1,%ebx
  80140f:	83 c4 10             	add    $0x10,%esp
  801412:	83 fb 20             	cmp    $0x20,%ebx
  801415:	75 ec                	jne    801403 <close_all+0xc>
		close(i);
}
  801417:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80141a:	c9                   	leave  
  80141b:	c3                   	ret    

0080141c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	57                   	push   %edi
  801420:	56                   	push   %esi
  801421:	53                   	push   %ebx
  801422:	83 ec 2c             	sub    $0x2c,%esp
  801425:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801428:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80142b:	50                   	push   %eax
  80142c:	ff 75 08             	pushl  0x8(%ebp)
  80142f:	e8 6e fe ff ff       	call   8012a2 <fd_lookup>
  801434:	83 c4 08             	add    $0x8,%esp
  801437:	85 c0                	test   %eax,%eax
  801439:	0f 88 c1 00 00 00    	js     801500 <dup+0xe4>
		return r;
	close(newfdnum);
  80143f:	83 ec 0c             	sub    $0xc,%esp
  801442:	56                   	push   %esi
  801443:	e8 84 ff ff ff       	call   8013cc <close>

	newfd = INDEX2FD(newfdnum);
  801448:	89 f3                	mov    %esi,%ebx
  80144a:	c1 e3 0c             	shl    $0xc,%ebx
  80144d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801453:	83 c4 04             	add    $0x4,%esp
  801456:	ff 75 e4             	pushl  -0x1c(%ebp)
  801459:	e8 de fd ff ff       	call   80123c <fd2data>
  80145e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801460:	89 1c 24             	mov    %ebx,(%esp)
  801463:	e8 d4 fd ff ff       	call   80123c <fd2data>
  801468:	83 c4 10             	add    $0x10,%esp
  80146b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80146e:	89 f8                	mov    %edi,%eax
  801470:	c1 e8 16             	shr    $0x16,%eax
  801473:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80147a:	a8 01                	test   $0x1,%al
  80147c:	74 37                	je     8014b5 <dup+0x99>
  80147e:	89 f8                	mov    %edi,%eax
  801480:	c1 e8 0c             	shr    $0xc,%eax
  801483:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80148a:	f6 c2 01             	test   $0x1,%dl
  80148d:	74 26                	je     8014b5 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80148f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801496:	83 ec 0c             	sub    $0xc,%esp
  801499:	25 07 0e 00 00       	and    $0xe07,%eax
  80149e:	50                   	push   %eax
  80149f:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014a2:	6a 00                	push   $0x0
  8014a4:	57                   	push   %edi
  8014a5:	6a 00                	push   $0x0
  8014a7:	e8 ab f7 ff ff       	call   800c57 <sys_page_map>
  8014ac:	89 c7                	mov    %eax,%edi
  8014ae:	83 c4 20             	add    $0x20,%esp
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	78 2e                	js     8014e3 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014b8:	89 d0                	mov    %edx,%eax
  8014ba:	c1 e8 0c             	shr    $0xc,%eax
  8014bd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014c4:	83 ec 0c             	sub    $0xc,%esp
  8014c7:	25 07 0e 00 00       	and    $0xe07,%eax
  8014cc:	50                   	push   %eax
  8014cd:	53                   	push   %ebx
  8014ce:	6a 00                	push   $0x0
  8014d0:	52                   	push   %edx
  8014d1:	6a 00                	push   $0x0
  8014d3:	e8 7f f7 ff ff       	call   800c57 <sys_page_map>
  8014d8:	89 c7                	mov    %eax,%edi
  8014da:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014dd:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014df:	85 ff                	test   %edi,%edi
  8014e1:	79 1d                	jns    801500 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014e3:	83 ec 08             	sub    $0x8,%esp
  8014e6:	53                   	push   %ebx
  8014e7:	6a 00                	push   $0x0
  8014e9:	e8 ab f7 ff ff       	call   800c99 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014ee:	83 c4 08             	add    $0x8,%esp
  8014f1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014f4:	6a 00                	push   $0x0
  8014f6:	e8 9e f7 ff ff       	call   800c99 <sys_page_unmap>
	return r;
  8014fb:	83 c4 10             	add    $0x10,%esp
  8014fe:	89 f8                	mov    %edi,%eax
}
  801500:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801503:	5b                   	pop    %ebx
  801504:	5e                   	pop    %esi
  801505:	5f                   	pop    %edi
  801506:	5d                   	pop    %ebp
  801507:	c3                   	ret    

00801508 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801508:	55                   	push   %ebp
  801509:	89 e5                	mov    %esp,%ebp
  80150b:	53                   	push   %ebx
  80150c:	83 ec 14             	sub    $0x14,%esp
  80150f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801512:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801515:	50                   	push   %eax
  801516:	53                   	push   %ebx
  801517:	e8 86 fd ff ff       	call   8012a2 <fd_lookup>
  80151c:	83 c4 08             	add    $0x8,%esp
  80151f:	89 c2                	mov    %eax,%edx
  801521:	85 c0                	test   %eax,%eax
  801523:	78 6d                	js     801592 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801525:	83 ec 08             	sub    $0x8,%esp
  801528:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152b:	50                   	push   %eax
  80152c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152f:	ff 30                	pushl  (%eax)
  801531:	e8 c2 fd ff ff       	call   8012f8 <dev_lookup>
  801536:	83 c4 10             	add    $0x10,%esp
  801539:	85 c0                	test   %eax,%eax
  80153b:	78 4c                	js     801589 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80153d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801540:	8b 42 08             	mov    0x8(%edx),%eax
  801543:	83 e0 03             	and    $0x3,%eax
  801546:	83 f8 01             	cmp    $0x1,%eax
  801549:	75 21                	jne    80156c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80154b:	a1 08 40 80 00       	mov    0x804008,%eax
  801550:	8b 40 48             	mov    0x48(%eax),%eax
  801553:	83 ec 04             	sub    $0x4,%esp
  801556:	53                   	push   %ebx
  801557:	50                   	push   %eax
  801558:	68 d9 2b 80 00       	push   $0x802bd9
  80155d:	e8 2a ed ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  801562:	83 c4 10             	add    $0x10,%esp
  801565:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80156a:	eb 26                	jmp    801592 <read+0x8a>
	}
	if (!dev->dev_read)
  80156c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80156f:	8b 40 08             	mov    0x8(%eax),%eax
  801572:	85 c0                	test   %eax,%eax
  801574:	74 17                	je     80158d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801576:	83 ec 04             	sub    $0x4,%esp
  801579:	ff 75 10             	pushl  0x10(%ebp)
  80157c:	ff 75 0c             	pushl  0xc(%ebp)
  80157f:	52                   	push   %edx
  801580:	ff d0                	call   *%eax
  801582:	89 c2                	mov    %eax,%edx
  801584:	83 c4 10             	add    $0x10,%esp
  801587:	eb 09                	jmp    801592 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801589:	89 c2                	mov    %eax,%edx
  80158b:	eb 05                	jmp    801592 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80158d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801592:	89 d0                	mov    %edx,%eax
  801594:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801597:	c9                   	leave  
  801598:	c3                   	ret    

00801599 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801599:	55                   	push   %ebp
  80159a:	89 e5                	mov    %esp,%ebp
  80159c:	57                   	push   %edi
  80159d:	56                   	push   %esi
  80159e:	53                   	push   %ebx
  80159f:	83 ec 0c             	sub    $0xc,%esp
  8015a2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015a5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015ad:	eb 21                	jmp    8015d0 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015af:	83 ec 04             	sub    $0x4,%esp
  8015b2:	89 f0                	mov    %esi,%eax
  8015b4:	29 d8                	sub    %ebx,%eax
  8015b6:	50                   	push   %eax
  8015b7:	89 d8                	mov    %ebx,%eax
  8015b9:	03 45 0c             	add    0xc(%ebp),%eax
  8015bc:	50                   	push   %eax
  8015bd:	57                   	push   %edi
  8015be:	e8 45 ff ff ff       	call   801508 <read>
		if (m < 0)
  8015c3:	83 c4 10             	add    $0x10,%esp
  8015c6:	85 c0                	test   %eax,%eax
  8015c8:	78 10                	js     8015da <readn+0x41>
			return m;
		if (m == 0)
  8015ca:	85 c0                	test   %eax,%eax
  8015cc:	74 0a                	je     8015d8 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015ce:	01 c3                	add    %eax,%ebx
  8015d0:	39 f3                	cmp    %esi,%ebx
  8015d2:	72 db                	jb     8015af <readn+0x16>
  8015d4:	89 d8                	mov    %ebx,%eax
  8015d6:	eb 02                	jmp    8015da <readn+0x41>
  8015d8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015dd:	5b                   	pop    %ebx
  8015de:	5e                   	pop    %esi
  8015df:	5f                   	pop    %edi
  8015e0:	5d                   	pop    %ebp
  8015e1:	c3                   	ret    

008015e2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	53                   	push   %ebx
  8015e6:	83 ec 14             	sub    $0x14,%esp
  8015e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ef:	50                   	push   %eax
  8015f0:	53                   	push   %ebx
  8015f1:	e8 ac fc ff ff       	call   8012a2 <fd_lookup>
  8015f6:	83 c4 08             	add    $0x8,%esp
  8015f9:	89 c2                	mov    %eax,%edx
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	78 68                	js     801667 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ff:	83 ec 08             	sub    $0x8,%esp
  801602:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801605:	50                   	push   %eax
  801606:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801609:	ff 30                	pushl  (%eax)
  80160b:	e8 e8 fc ff ff       	call   8012f8 <dev_lookup>
  801610:	83 c4 10             	add    $0x10,%esp
  801613:	85 c0                	test   %eax,%eax
  801615:	78 47                	js     80165e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801617:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80161e:	75 21                	jne    801641 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801620:	a1 08 40 80 00       	mov    0x804008,%eax
  801625:	8b 40 48             	mov    0x48(%eax),%eax
  801628:	83 ec 04             	sub    $0x4,%esp
  80162b:	53                   	push   %ebx
  80162c:	50                   	push   %eax
  80162d:	68 f5 2b 80 00       	push   $0x802bf5
  801632:	e8 55 ec ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80163f:	eb 26                	jmp    801667 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801641:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801644:	8b 52 0c             	mov    0xc(%edx),%edx
  801647:	85 d2                	test   %edx,%edx
  801649:	74 17                	je     801662 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80164b:	83 ec 04             	sub    $0x4,%esp
  80164e:	ff 75 10             	pushl  0x10(%ebp)
  801651:	ff 75 0c             	pushl  0xc(%ebp)
  801654:	50                   	push   %eax
  801655:	ff d2                	call   *%edx
  801657:	89 c2                	mov    %eax,%edx
  801659:	83 c4 10             	add    $0x10,%esp
  80165c:	eb 09                	jmp    801667 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165e:	89 c2                	mov    %eax,%edx
  801660:	eb 05                	jmp    801667 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801662:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801667:	89 d0                	mov    %edx,%eax
  801669:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166c:	c9                   	leave  
  80166d:	c3                   	ret    

0080166e <seek>:

int
seek(int fdnum, off_t offset)
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801674:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801677:	50                   	push   %eax
  801678:	ff 75 08             	pushl  0x8(%ebp)
  80167b:	e8 22 fc ff ff       	call   8012a2 <fd_lookup>
  801680:	83 c4 08             	add    $0x8,%esp
  801683:	85 c0                	test   %eax,%eax
  801685:	78 0e                	js     801695 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801687:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80168a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80168d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801690:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801695:	c9                   	leave  
  801696:	c3                   	ret    

00801697 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	53                   	push   %ebx
  80169b:	83 ec 14             	sub    $0x14,%esp
  80169e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a4:	50                   	push   %eax
  8016a5:	53                   	push   %ebx
  8016a6:	e8 f7 fb ff ff       	call   8012a2 <fd_lookup>
  8016ab:	83 c4 08             	add    $0x8,%esp
  8016ae:	89 c2                	mov    %eax,%edx
  8016b0:	85 c0                	test   %eax,%eax
  8016b2:	78 65                	js     801719 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b4:	83 ec 08             	sub    $0x8,%esp
  8016b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ba:	50                   	push   %eax
  8016bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016be:	ff 30                	pushl  (%eax)
  8016c0:	e8 33 fc ff ff       	call   8012f8 <dev_lookup>
  8016c5:	83 c4 10             	add    $0x10,%esp
  8016c8:	85 c0                	test   %eax,%eax
  8016ca:	78 44                	js     801710 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016cf:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016d3:	75 21                	jne    8016f6 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016d5:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016da:	8b 40 48             	mov    0x48(%eax),%eax
  8016dd:	83 ec 04             	sub    $0x4,%esp
  8016e0:	53                   	push   %ebx
  8016e1:	50                   	push   %eax
  8016e2:	68 b8 2b 80 00       	push   $0x802bb8
  8016e7:	e8 a0 eb ff ff       	call   80028c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016ec:	83 c4 10             	add    $0x10,%esp
  8016ef:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016f4:	eb 23                	jmp    801719 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f9:	8b 52 18             	mov    0x18(%edx),%edx
  8016fc:	85 d2                	test   %edx,%edx
  8016fe:	74 14                	je     801714 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801700:	83 ec 08             	sub    $0x8,%esp
  801703:	ff 75 0c             	pushl  0xc(%ebp)
  801706:	50                   	push   %eax
  801707:	ff d2                	call   *%edx
  801709:	89 c2                	mov    %eax,%edx
  80170b:	83 c4 10             	add    $0x10,%esp
  80170e:	eb 09                	jmp    801719 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801710:	89 c2                	mov    %eax,%edx
  801712:	eb 05                	jmp    801719 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801714:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801719:	89 d0                	mov    %edx,%eax
  80171b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171e:	c9                   	leave  
  80171f:	c3                   	ret    

00801720 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	53                   	push   %ebx
  801724:	83 ec 14             	sub    $0x14,%esp
  801727:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80172a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80172d:	50                   	push   %eax
  80172e:	ff 75 08             	pushl  0x8(%ebp)
  801731:	e8 6c fb ff ff       	call   8012a2 <fd_lookup>
  801736:	83 c4 08             	add    $0x8,%esp
  801739:	89 c2                	mov    %eax,%edx
  80173b:	85 c0                	test   %eax,%eax
  80173d:	78 58                	js     801797 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173f:	83 ec 08             	sub    $0x8,%esp
  801742:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801745:	50                   	push   %eax
  801746:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801749:	ff 30                	pushl  (%eax)
  80174b:	e8 a8 fb ff ff       	call   8012f8 <dev_lookup>
  801750:	83 c4 10             	add    $0x10,%esp
  801753:	85 c0                	test   %eax,%eax
  801755:	78 37                	js     80178e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801757:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80175a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80175e:	74 32                	je     801792 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801760:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801763:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80176a:	00 00 00 
	stat->st_isdir = 0;
  80176d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801774:	00 00 00 
	stat->st_dev = dev;
  801777:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80177d:	83 ec 08             	sub    $0x8,%esp
  801780:	53                   	push   %ebx
  801781:	ff 75 f0             	pushl  -0x10(%ebp)
  801784:	ff 50 14             	call   *0x14(%eax)
  801787:	89 c2                	mov    %eax,%edx
  801789:	83 c4 10             	add    $0x10,%esp
  80178c:	eb 09                	jmp    801797 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80178e:	89 c2                	mov    %eax,%edx
  801790:	eb 05                	jmp    801797 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801792:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801797:	89 d0                	mov    %edx,%eax
  801799:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179c:	c9                   	leave  
  80179d:	c3                   	ret    

0080179e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80179e:	55                   	push   %ebp
  80179f:	89 e5                	mov    %esp,%ebp
  8017a1:	56                   	push   %esi
  8017a2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017a3:	83 ec 08             	sub    $0x8,%esp
  8017a6:	6a 00                	push   $0x0
  8017a8:	ff 75 08             	pushl  0x8(%ebp)
  8017ab:	e8 d6 01 00 00       	call   801986 <open>
  8017b0:	89 c3                	mov    %eax,%ebx
  8017b2:	83 c4 10             	add    $0x10,%esp
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	78 1b                	js     8017d4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017b9:	83 ec 08             	sub    $0x8,%esp
  8017bc:	ff 75 0c             	pushl  0xc(%ebp)
  8017bf:	50                   	push   %eax
  8017c0:	e8 5b ff ff ff       	call   801720 <fstat>
  8017c5:	89 c6                	mov    %eax,%esi
	close(fd);
  8017c7:	89 1c 24             	mov    %ebx,(%esp)
  8017ca:	e8 fd fb ff ff       	call   8013cc <close>
	return r;
  8017cf:	83 c4 10             	add    $0x10,%esp
  8017d2:	89 f0                	mov    %esi,%eax
}
  8017d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d7:	5b                   	pop    %ebx
  8017d8:	5e                   	pop    %esi
  8017d9:	5d                   	pop    %ebp
  8017da:	c3                   	ret    

008017db <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017db:	55                   	push   %ebp
  8017dc:	89 e5                	mov    %esp,%ebp
  8017de:	56                   	push   %esi
  8017df:	53                   	push   %ebx
  8017e0:	89 c6                	mov    %eax,%esi
  8017e2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017e4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017eb:	75 12                	jne    8017ff <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017ed:	83 ec 0c             	sub    $0xc,%esp
  8017f0:	6a 01                	push   $0x1
  8017f2:	e8 fc f9 ff ff       	call   8011f3 <ipc_find_env>
  8017f7:	a3 00 40 80 00       	mov    %eax,0x804000
  8017fc:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017ff:	6a 07                	push   $0x7
  801801:	68 00 50 80 00       	push   $0x805000
  801806:	56                   	push   %esi
  801807:	ff 35 00 40 80 00    	pushl  0x804000
  80180d:	e8 8d f9 ff ff       	call   80119f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801812:	83 c4 0c             	add    $0xc,%esp
  801815:	6a 00                	push   $0x0
  801817:	53                   	push   %ebx
  801818:	6a 00                	push   $0x0
  80181a:	e8 19 f9 ff ff       	call   801138 <ipc_recv>
}
  80181f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801822:	5b                   	pop    %ebx
  801823:	5e                   	pop    %esi
  801824:	5d                   	pop    %ebp
  801825:	c3                   	ret    

00801826 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801826:	55                   	push   %ebp
  801827:	89 e5                	mov    %esp,%ebp
  801829:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80182c:	8b 45 08             	mov    0x8(%ebp),%eax
  80182f:	8b 40 0c             	mov    0xc(%eax),%eax
  801832:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801837:	8b 45 0c             	mov    0xc(%ebp),%eax
  80183a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80183f:	ba 00 00 00 00       	mov    $0x0,%edx
  801844:	b8 02 00 00 00       	mov    $0x2,%eax
  801849:	e8 8d ff ff ff       	call   8017db <fsipc>
}
  80184e:	c9                   	leave  
  80184f:	c3                   	ret    

00801850 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801856:	8b 45 08             	mov    0x8(%ebp),%eax
  801859:	8b 40 0c             	mov    0xc(%eax),%eax
  80185c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801861:	ba 00 00 00 00       	mov    $0x0,%edx
  801866:	b8 06 00 00 00       	mov    $0x6,%eax
  80186b:	e8 6b ff ff ff       	call   8017db <fsipc>
}
  801870:	c9                   	leave  
  801871:	c3                   	ret    

00801872 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	53                   	push   %ebx
  801876:	83 ec 04             	sub    $0x4,%esp
  801879:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80187c:	8b 45 08             	mov    0x8(%ebp),%eax
  80187f:	8b 40 0c             	mov    0xc(%eax),%eax
  801882:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801887:	ba 00 00 00 00       	mov    $0x0,%edx
  80188c:	b8 05 00 00 00       	mov    $0x5,%eax
  801891:	e8 45 ff ff ff       	call   8017db <fsipc>
  801896:	85 c0                	test   %eax,%eax
  801898:	78 2c                	js     8018c6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80189a:	83 ec 08             	sub    $0x8,%esp
  80189d:	68 00 50 80 00       	push   $0x805000
  8018a2:	53                   	push   %ebx
  8018a3:	e8 69 ef ff ff       	call   800811 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018a8:	a1 80 50 80 00       	mov    0x805080,%eax
  8018ad:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018b3:	a1 84 50 80 00       	mov    0x805084,%eax
  8018b8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018be:	83 c4 10             	add    $0x10,%esp
  8018c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c9:	c9                   	leave  
  8018ca:	c3                   	ret    

008018cb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018cb:	55                   	push   %ebp
  8018cc:	89 e5                	mov    %esp,%ebp
  8018ce:	83 ec 0c             	sub    $0xc,%esp
  8018d1:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8018d7:	8b 52 0c             	mov    0xc(%edx),%edx
  8018da:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018e0:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018e5:	50                   	push   %eax
  8018e6:	ff 75 0c             	pushl  0xc(%ebp)
  8018e9:	68 08 50 80 00       	push   $0x805008
  8018ee:	e8 b0 f0 ff ff       	call   8009a3 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8018f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f8:	b8 04 00 00 00       	mov    $0x4,%eax
  8018fd:	e8 d9 fe ff ff       	call   8017db <fsipc>

}
  801902:	c9                   	leave  
  801903:	c3                   	ret    

00801904 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801904:	55                   	push   %ebp
  801905:	89 e5                	mov    %esp,%ebp
  801907:	56                   	push   %esi
  801908:	53                   	push   %ebx
  801909:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80190c:	8b 45 08             	mov    0x8(%ebp),%eax
  80190f:	8b 40 0c             	mov    0xc(%eax),%eax
  801912:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801917:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80191d:	ba 00 00 00 00       	mov    $0x0,%edx
  801922:	b8 03 00 00 00       	mov    $0x3,%eax
  801927:	e8 af fe ff ff       	call   8017db <fsipc>
  80192c:	89 c3                	mov    %eax,%ebx
  80192e:	85 c0                	test   %eax,%eax
  801930:	78 4b                	js     80197d <devfile_read+0x79>
		return r;
	assert(r <= n);
  801932:	39 c6                	cmp    %eax,%esi
  801934:	73 16                	jae    80194c <devfile_read+0x48>
  801936:	68 28 2c 80 00       	push   $0x802c28
  80193b:	68 2f 2c 80 00       	push   $0x802c2f
  801940:	6a 7c                	push   $0x7c
  801942:	68 44 2c 80 00       	push   $0x802c44
  801947:	e8 24 0a 00 00       	call   802370 <_panic>
	assert(r <= PGSIZE);
  80194c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801951:	7e 16                	jle    801969 <devfile_read+0x65>
  801953:	68 4f 2c 80 00       	push   $0x802c4f
  801958:	68 2f 2c 80 00       	push   $0x802c2f
  80195d:	6a 7d                	push   $0x7d
  80195f:	68 44 2c 80 00       	push   $0x802c44
  801964:	e8 07 0a 00 00       	call   802370 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801969:	83 ec 04             	sub    $0x4,%esp
  80196c:	50                   	push   %eax
  80196d:	68 00 50 80 00       	push   $0x805000
  801972:	ff 75 0c             	pushl  0xc(%ebp)
  801975:	e8 29 f0 ff ff       	call   8009a3 <memmove>
	return r;
  80197a:	83 c4 10             	add    $0x10,%esp
}
  80197d:	89 d8                	mov    %ebx,%eax
  80197f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801982:	5b                   	pop    %ebx
  801983:	5e                   	pop    %esi
  801984:	5d                   	pop    %ebp
  801985:	c3                   	ret    

00801986 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801986:	55                   	push   %ebp
  801987:	89 e5                	mov    %esp,%ebp
  801989:	53                   	push   %ebx
  80198a:	83 ec 20             	sub    $0x20,%esp
  80198d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801990:	53                   	push   %ebx
  801991:	e8 42 ee ff ff       	call   8007d8 <strlen>
  801996:	83 c4 10             	add    $0x10,%esp
  801999:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80199e:	7f 67                	jg     801a07 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019a0:	83 ec 0c             	sub    $0xc,%esp
  8019a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a6:	50                   	push   %eax
  8019a7:	e8 a7 f8 ff ff       	call   801253 <fd_alloc>
  8019ac:	83 c4 10             	add    $0x10,%esp
		return r;
  8019af:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019b1:	85 c0                	test   %eax,%eax
  8019b3:	78 57                	js     801a0c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019b5:	83 ec 08             	sub    $0x8,%esp
  8019b8:	53                   	push   %ebx
  8019b9:	68 00 50 80 00       	push   $0x805000
  8019be:	e8 4e ee ff ff       	call   800811 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c6:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8019d3:	e8 03 fe ff ff       	call   8017db <fsipc>
  8019d8:	89 c3                	mov    %eax,%ebx
  8019da:	83 c4 10             	add    $0x10,%esp
  8019dd:	85 c0                	test   %eax,%eax
  8019df:	79 14                	jns    8019f5 <open+0x6f>
		fd_close(fd, 0);
  8019e1:	83 ec 08             	sub    $0x8,%esp
  8019e4:	6a 00                	push   $0x0
  8019e6:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e9:	e8 5d f9 ff ff       	call   80134b <fd_close>
		return r;
  8019ee:	83 c4 10             	add    $0x10,%esp
  8019f1:	89 da                	mov    %ebx,%edx
  8019f3:	eb 17                	jmp    801a0c <open+0x86>
	}

	return fd2num(fd);
  8019f5:	83 ec 0c             	sub    $0xc,%esp
  8019f8:	ff 75 f4             	pushl  -0xc(%ebp)
  8019fb:	e8 2c f8 ff ff       	call   80122c <fd2num>
  801a00:	89 c2                	mov    %eax,%edx
  801a02:	83 c4 10             	add    $0x10,%esp
  801a05:	eb 05                	jmp    801a0c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a07:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a0c:	89 d0                	mov    %edx,%eax
  801a0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a11:	c9                   	leave  
  801a12:	c3                   	ret    

00801a13 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a19:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1e:	b8 08 00 00 00       	mov    $0x8,%eax
  801a23:	e8 b3 fd ff ff       	call   8017db <fsipc>
}
  801a28:	c9                   	leave  
  801a29:	c3                   	ret    

00801a2a <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a2a:	55                   	push   %ebp
  801a2b:	89 e5                	mov    %esp,%ebp
  801a2d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a30:	68 5b 2c 80 00       	push   $0x802c5b
  801a35:	ff 75 0c             	pushl  0xc(%ebp)
  801a38:	e8 d4 ed ff ff       	call   800811 <strcpy>
	return 0;
}
  801a3d:	b8 00 00 00 00       	mov    $0x0,%eax
  801a42:	c9                   	leave  
  801a43:	c3                   	ret    

00801a44 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a44:	55                   	push   %ebp
  801a45:	89 e5                	mov    %esp,%ebp
  801a47:	53                   	push   %ebx
  801a48:	83 ec 10             	sub    $0x10,%esp
  801a4b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a4e:	53                   	push   %ebx
  801a4f:	e8 cd 09 00 00       	call   802421 <pageref>
  801a54:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a57:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a5c:	83 f8 01             	cmp    $0x1,%eax
  801a5f:	75 10                	jne    801a71 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a61:	83 ec 0c             	sub    $0xc,%esp
  801a64:	ff 73 0c             	pushl  0xc(%ebx)
  801a67:	e8 c0 02 00 00       	call   801d2c <nsipc_close>
  801a6c:	89 c2                	mov    %eax,%edx
  801a6e:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a71:	89 d0                	mov    %edx,%eax
  801a73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a76:	c9                   	leave  
  801a77:	c3                   	ret    

00801a78 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a78:	55                   	push   %ebp
  801a79:	89 e5                	mov    %esp,%ebp
  801a7b:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a7e:	6a 00                	push   $0x0
  801a80:	ff 75 10             	pushl  0x10(%ebp)
  801a83:	ff 75 0c             	pushl  0xc(%ebp)
  801a86:	8b 45 08             	mov    0x8(%ebp),%eax
  801a89:	ff 70 0c             	pushl  0xc(%eax)
  801a8c:	e8 78 03 00 00       	call   801e09 <nsipc_send>
}
  801a91:	c9                   	leave  
  801a92:	c3                   	ret    

00801a93 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a93:	55                   	push   %ebp
  801a94:	89 e5                	mov    %esp,%ebp
  801a96:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a99:	6a 00                	push   $0x0
  801a9b:	ff 75 10             	pushl  0x10(%ebp)
  801a9e:	ff 75 0c             	pushl  0xc(%ebp)
  801aa1:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa4:	ff 70 0c             	pushl  0xc(%eax)
  801aa7:	e8 f1 02 00 00       	call   801d9d <nsipc_recv>
}
  801aac:	c9                   	leave  
  801aad:	c3                   	ret    

00801aae <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801ab4:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ab7:	52                   	push   %edx
  801ab8:	50                   	push   %eax
  801ab9:	e8 e4 f7 ff ff       	call   8012a2 <fd_lookup>
  801abe:	83 c4 10             	add    $0x10,%esp
  801ac1:	85 c0                	test   %eax,%eax
  801ac3:	78 17                	js     801adc <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac8:	8b 0d 28 30 80 00    	mov    0x803028,%ecx
  801ace:	39 08                	cmp    %ecx,(%eax)
  801ad0:	75 05                	jne    801ad7 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801ad2:	8b 40 0c             	mov    0xc(%eax),%eax
  801ad5:	eb 05                	jmp    801adc <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801ad7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801adc:	c9                   	leave  
  801add:	c3                   	ret    

00801ade <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	56                   	push   %esi
  801ae2:	53                   	push   %ebx
  801ae3:	83 ec 1c             	sub    $0x1c,%esp
  801ae6:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801ae8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aeb:	50                   	push   %eax
  801aec:	e8 62 f7 ff ff       	call   801253 <fd_alloc>
  801af1:	89 c3                	mov    %eax,%ebx
  801af3:	83 c4 10             	add    $0x10,%esp
  801af6:	85 c0                	test   %eax,%eax
  801af8:	78 1b                	js     801b15 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801afa:	83 ec 04             	sub    $0x4,%esp
  801afd:	68 07 04 00 00       	push   $0x407
  801b02:	ff 75 f4             	pushl  -0xc(%ebp)
  801b05:	6a 00                	push   $0x0
  801b07:	e8 08 f1 ff ff       	call   800c14 <sys_page_alloc>
  801b0c:	89 c3                	mov    %eax,%ebx
  801b0e:	83 c4 10             	add    $0x10,%esp
  801b11:	85 c0                	test   %eax,%eax
  801b13:	79 10                	jns    801b25 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801b15:	83 ec 0c             	sub    $0xc,%esp
  801b18:	56                   	push   %esi
  801b19:	e8 0e 02 00 00       	call   801d2c <nsipc_close>
		return r;
  801b1e:	83 c4 10             	add    $0x10,%esp
  801b21:	89 d8                	mov    %ebx,%eax
  801b23:	eb 24                	jmp    801b49 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b25:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b2e:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b33:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b3a:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b3d:	83 ec 0c             	sub    $0xc,%esp
  801b40:	50                   	push   %eax
  801b41:	e8 e6 f6 ff ff       	call   80122c <fd2num>
  801b46:	83 c4 10             	add    $0x10,%esp
}
  801b49:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b4c:	5b                   	pop    %ebx
  801b4d:	5e                   	pop    %esi
  801b4e:	5d                   	pop    %ebp
  801b4f:	c3                   	ret    

00801b50 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b56:	8b 45 08             	mov    0x8(%ebp),%eax
  801b59:	e8 50 ff ff ff       	call   801aae <fd2sockid>
		return r;
  801b5e:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b60:	85 c0                	test   %eax,%eax
  801b62:	78 1f                	js     801b83 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b64:	83 ec 04             	sub    $0x4,%esp
  801b67:	ff 75 10             	pushl  0x10(%ebp)
  801b6a:	ff 75 0c             	pushl  0xc(%ebp)
  801b6d:	50                   	push   %eax
  801b6e:	e8 12 01 00 00       	call   801c85 <nsipc_accept>
  801b73:	83 c4 10             	add    $0x10,%esp
		return r;
  801b76:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b78:	85 c0                	test   %eax,%eax
  801b7a:	78 07                	js     801b83 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b7c:	e8 5d ff ff ff       	call   801ade <alloc_sockfd>
  801b81:	89 c1                	mov    %eax,%ecx
}
  801b83:	89 c8                	mov    %ecx,%eax
  801b85:	c9                   	leave  
  801b86:	c3                   	ret    

00801b87 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
  801b8a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b90:	e8 19 ff ff ff       	call   801aae <fd2sockid>
  801b95:	85 c0                	test   %eax,%eax
  801b97:	78 12                	js     801bab <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801b99:	83 ec 04             	sub    $0x4,%esp
  801b9c:	ff 75 10             	pushl  0x10(%ebp)
  801b9f:	ff 75 0c             	pushl  0xc(%ebp)
  801ba2:	50                   	push   %eax
  801ba3:	e8 2d 01 00 00       	call   801cd5 <nsipc_bind>
  801ba8:	83 c4 10             	add    $0x10,%esp
}
  801bab:	c9                   	leave  
  801bac:	c3                   	ret    

00801bad <shutdown>:

int
shutdown(int s, int how)
{
  801bad:	55                   	push   %ebp
  801bae:	89 e5                	mov    %esp,%ebp
  801bb0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb6:	e8 f3 fe ff ff       	call   801aae <fd2sockid>
  801bbb:	85 c0                	test   %eax,%eax
  801bbd:	78 0f                	js     801bce <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801bbf:	83 ec 08             	sub    $0x8,%esp
  801bc2:	ff 75 0c             	pushl  0xc(%ebp)
  801bc5:	50                   	push   %eax
  801bc6:	e8 3f 01 00 00       	call   801d0a <nsipc_shutdown>
  801bcb:	83 c4 10             	add    $0x10,%esp
}
  801bce:	c9                   	leave  
  801bcf:	c3                   	ret    

00801bd0 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
  801bd3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bd6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd9:	e8 d0 fe ff ff       	call   801aae <fd2sockid>
  801bde:	85 c0                	test   %eax,%eax
  801be0:	78 12                	js     801bf4 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801be2:	83 ec 04             	sub    $0x4,%esp
  801be5:	ff 75 10             	pushl  0x10(%ebp)
  801be8:	ff 75 0c             	pushl  0xc(%ebp)
  801beb:	50                   	push   %eax
  801bec:	e8 55 01 00 00       	call   801d46 <nsipc_connect>
  801bf1:	83 c4 10             	add    $0x10,%esp
}
  801bf4:	c9                   	leave  
  801bf5:	c3                   	ret    

00801bf6 <listen>:

int
listen(int s, int backlog)
{
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
  801bf9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bfc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bff:	e8 aa fe ff ff       	call   801aae <fd2sockid>
  801c04:	85 c0                	test   %eax,%eax
  801c06:	78 0f                	js     801c17 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c08:	83 ec 08             	sub    $0x8,%esp
  801c0b:	ff 75 0c             	pushl  0xc(%ebp)
  801c0e:	50                   	push   %eax
  801c0f:	e8 67 01 00 00       	call   801d7b <nsipc_listen>
  801c14:	83 c4 10             	add    $0x10,%esp
}
  801c17:	c9                   	leave  
  801c18:	c3                   	ret    

00801c19 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c19:	55                   	push   %ebp
  801c1a:	89 e5                	mov    %esp,%ebp
  801c1c:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c1f:	ff 75 10             	pushl  0x10(%ebp)
  801c22:	ff 75 0c             	pushl  0xc(%ebp)
  801c25:	ff 75 08             	pushl  0x8(%ebp)
  801c28:	e8 3a 02 00 00       	call   801e67 <nsipc_socket>
  801c2d:	83 c4 10             	add    $0x10,%esp
  801c30:	85 c0                	test   %eax,%eax
  801c32:	78 05                	js     801c39 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801c34:	e8 a5 fe ff ff       	call   801ade <alloc_sockfd>
}
  801c39:	c9                   	leave  
  801c3a:	c3                   	ret    

00801c3b <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c3b:	55                   	push   %ebp
  801c3c:	89 e5                	mov    %esp,%ebp
  801c3e:	53                   	push   %ebx
  801c3f:	83 ec 04             	sub    $0x4,%esp
  801c42:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c44:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c4b:	75 12                	jne    801c5f <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c4d:	83 ec 0c             	sub    $0xc,%esp
  801c50:	6a 02                	push   $0x2
  801c52:	e8 9c f5 ff ff       	call   8011f3 <ipc_find_env>
  801c57:	a3 04 40 80 00       	mov    %eax,0x804004
  801c5c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c5f:	6a 07                	push   $0x7
  801c61:	68 00 60 80 00       	push   $0x806000
  801c66:	53                   	push   %ebx
  801c67:	ff 35 04 40 80 00    	pushl  0x804004
  801c6d:	e8 2d f5 ff ff       	call   80119f <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c72:	83 c4 0c             	add    $0xc,%esp
  801c75:	6a 00                	push   $0x0
  801c77:	6a 00                	push   $0x0
  801c79:	6a 00                	push   $0x0
  801c7b:	e8 b8 f4 ff ff       	call   801138 <ipc_recv>
}
  801c80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c83:	c9                   	leave  
  801c84:	c3                   	ret    

00801c85 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c85:	55                   	push   %ebp
  801c86:	89 e5                	mov    %esp,%ebp
  801c88:	56                   	push   %esi
  801c89:	53                   	push   %ebx
  801c8a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c90:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c95:	8b 06                	mov    (%esi),%eax
  801c97:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c9c:	b8 01 00 00 00       	mov    $0x1,%eax
  801ca1:	e8 95 ff ff ff       	call   801c3b <nsipc>
  801ca6:	89 c3                	mov    %eax,%ebx
  801ca8:	85 c0                	test   %eax,%eax
  801caa:	78 20                	js     801ccc <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801cac:	83 ec 04             	sub    $0x4,%esp
  801caf:	ff 35 10 60 80 00    	pushl  0x806010
  801cb5:	68 00 60 80 00       	push   $0x806000
  801cba:	ff 75 0c             	pushl  0xc(%ebp)
  801cbd:	e8 e1 ec ff ff       	call   8009a3 <memmove>
		*addrlen = ret->ret_addrlen;
  801cc2:	a1 10 60 80 00       	mov    0x806010,%eax
  801cc7:	89 06                	mov    %eax,(%esi)
  801cc9:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801ccc:	89 d8                	mov    %ebx,%eax
  801cce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cd1:	5b                   	pop    %ebx
  801cd2:	5e                   	pop    %esi
  801cd3:	5d                   	pop    %ebp
  801cd4:	c3                   	ret    

00801cd5 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cd5:	55                   	push   %ebp
  801cd6:	89 e5                	mov    %esp,%ebp
  801cd8:	53                   	push   %ebx
  801cd9:	83 ec 08             	sub    $0x8,%esp
  801cdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce2:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801ce7:	53                   	push   %ebx
  801ce8:	ff 75 0c             	pushl  0xc(%ebp)
  801ceb:	68 04 60 80 00       	push   $0x806004
  801cf0:	e8 ae ec ff ff       	call   8009a3 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801cf5:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801cfb:	b8 02 00 00 00       	mov    $0x2,%eax
  801d00:	e8 36 ff ff ff       	call   801c3b <nsipc>
}
  801d05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d08:	c9                   	leave  
  801d09:	c3                   	ret    

00801d0a <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d0a:	55                   	push   %ebp
  801d0b:	89 e5                	mov    %esp,%ebp
  801d0d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d10:	8b 45 08             	mov    0x8(%ebp),%eax
  801d13:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d18:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d1b:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d20:	b8 03 00 00 00       	mov    $0x3,%eax
  801d25:	e8 11 ff ff ff       	call   801c3b <nsipc>
}
  801d2a:	c9                   	leave  
  801d2b:	c3                   	ret    

00801d2c <nsipc_close>:

int
nsipc_close(int s)
{
  801d2c:	55                   	push   %ebp
  801d2d:	89 e5                	mov    %esp,%ebp
  801d2f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d32:	8b 45 08             	mov    0x8(%ebp),%eax
  801d35:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d3a:	b8 04 00 00 00       	mov    $0x4,%eax
  801d3f:	e8 f7 fe ff ff       	call   801c3b <nsipc>
}
  801d44:	c9                   	leave  
  801d45:	c3                   	ret    

00801d46 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d46:	55                   	push   %ebp
  801d47:	89 e5                	mov    %esp,%ebp
  801d49:	53                   	push   %ebx
  801d4a:	83 ec 08             	sub    $0x8,%esp
  801d4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d50:	8b 45 08             	mov    0x8(%ebp),%eax
  801d53:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d58:	53                   	push   %ebx
  801d59:	ff 75 0c             	pushl  0xc(%ebp)
  801d5c:	68 04 60 80 00       	push   $0x806004
  801d61:	e8 3d ec ff ff       	call   8009a3 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d66:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d6c:	b8 05 00 00 00       	mov    $0x5,%eax
  801d71:	e8 c5 fe ff ff       	call   801c3b <nsipc>
}
  801d76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d79:	c9                   	leave  
  801d7a:	c3                   	ret    

00801d7b <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d7b:	55                   	push   %ebp
  801d7c:	89 e5                	mov    %esp,%ebp
  801d7e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d81:	8b 45 08             	mov    0x8(%ebp),%eax
  801d84:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d89:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d8c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d91:	b8 06 00 00 00       	mov    $0x6,%eax
  801d96:	e8 a0 fe ff ff       	call   801c3b <nsipc>
}
  801d9b:	c9                   	leave  
  801d9c:	c3                   	ret    

00801d9d <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d9d:	55                   	push   %ebp
  801d9e:	89 e5                	mov    %esp,%ebp
  801da0:	56                   	push   %esi
  801da1:	53                   	push   %ebx
  801da2:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801da5:	8b 45 08             	mov    0x8(%ebp),%eax
  801da8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801dad:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801db3:	8b 45 14             	mov    0x14(%ebp),%eax
  801db6:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801dbb:	b8 07 00 00 00       	mov    $0x7,%eax
  801dc0:	e8 76 fe ff ff       	call   801c3b <nsipc>
  801dc5:	89 c3                	mov    %eax,%ebx
  801dc7:	85 c0                	test   %eax,%eax
  801dc9:	78 35                	js     801e00 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801dcb:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801dd0:	7f 04                	jg     801dd6 <nsipc_recv+0x39>
  801dd2:	39 c6                	cmp    %eax,%esi
  801dd4:	7d 16                	jge    801dec <nsipc_recv+0x4f>
  801dd6:	68 67 2c 80 00       	push   $0x802c67
  801ddb:	68 2f 2c 80 00       	push   $0x802c2f
  801de0:	6a 62                	push   $0x62
  801de2:	68 7c 2c 80 00       	push   $0x802c7c
  801de7:	e8 84 05 00 00       	call   802370 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801dec:	83 ec 04             	sub    $0x4,%esp
  801def:	50                   	push   %eax
  801df0:	68 00 60 80 00       	push   $0x806000
  801df5:	ff 75 0c             	pushl  0xc(%ebp)
  801df8:	e8 a6 eb ff ff       	call   8009a3 <memmove>
  801dfd:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e00:	89 d8                	mov    %ebx,%eax
  801e02:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e05:	5b                   	pop    %ebx
  801e06:	5e                   	pop    %esi
  801e07:	5d                   	pop    %ebp
  801e08:	c3                   	ret    

00801e09 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e09:	55                   	push   %ebp
  801e0a:	89 e5                	mov    %esp,%ebp
  801e0c:	53                   	push   %ebx
  801e0d:	83 ec 04             	sub    $0x4,%esp
  801e10:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e13:	8b 45 08             	mov    0x8(%ebp),%eax
  801e16:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e1b:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e21:	7e 16                	jle    801e39 <nsipc_send+0x30>
  801e23:	68 88 2c 80 00       	push   $0x802c88
  801e28:	68 2f 2c 80 00       	push   $0x802c2f
  801e2d:	6a 6d                	push   $0x6d
  801e2f:	68 7c 2c 80 00       	push   $0x802c7c
  801e34:	e8 37 05 00 00       	call   802370 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e39:	83 ec 04             	sub    $0x4,%esp
  801e3c:	53                   	push   %ebx
  801e3d:	ff 75 0c             	pushl  0xc(%ebp)
  801e40:	68 0c 60 80 00       	push   $0x80600c
  801e45:	e8 59 eb ff ff       	call   8009a3 <memmove>
	nsipcbuf.send.req_size = size;
  801e4a:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e50:	8b 45 14             	mov    0x14(%ebp),%eax
  801e53:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e58:	b8 08 00 00 00       	mov    $0x8,%eax
  801e5d:	e8 d9 fd ff ff       	call   801c3b <nsipc>
}
  801e62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e65:	c9                   	leave  
  801e66:	c3                   	ret    

00801e67 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e67:	55                   	push   %ebp
  801e68:	89 e5                	mov    %esp,%ebp
  801e6a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e70:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e75:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e78:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e7d:	8b 45 10             	mov    0x10(%ebp),%eax
  801e80:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e85:	b8 09 00 00 00       	mov    $0x9,%eax
  801e8a:	e8 ac fd ff ff       	call   801c3b <nsipc>
}
  801e8f:	c9                   	leave  
  801e90:	c3                   	ret    

00801e91 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e91:	55                   	push   %ebp
  801e92:	89 e5                	mov    %esp,%ebp
  801e94:	56                   	push   %esi
  801e95:	53                   	push   %ebx
  801e96:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e99:	83 ec 0c             	sub    $0xc,%esp
  801e9c:	ff 75 08             	pushl  0x8(%ebp)
  801e9f:	e8 98 f3 ff ff       	call   80123c <fd2data>
  801ea4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ea6:	83 c4 08             	add    $0x8,%esp
  801ea9:	68 94 2c 80 00       	push   $0x802c94
  801eae:	53                   	push   %ebx
  801eaf:	e8 5d e9 ff ff       	call   800811 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801eb4:	8b 46 04             	mov    0x4(%esi),%eax
  801eb7:	2b 06                	sub    (%esi),%eax
  801eb9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ebf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ec6:	00 00 00 
	stat->st_dev = &devpipe;
  801ec9:	c7 83 88 00 00 00 44 	movl   $0x803044,0x88(%ebx)
  801ed0:	30 80 00 
	return 0;
}
  801ed3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ed8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801edb:	5b                   	pop    %ebx
  801edc:	5e                   	pop    %esi
  801edd:	5d                   	pop    %ebp
  801ede:	c3                   	ret    

00801edf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801edf:	55                   	push   %ebp
  801ee0:	89 e5                	mov    %esp,%ebp
  801ee2:	53                   	push   %ebx
  801ee3:	83 ec 0c             	sub    $0xc,%esp
  801ee6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ee9:	53                   	push   %ebx
  801eea:	6a 00                	push   $0x0
  801eec:	e8 a8 ed ff ff       	call   800c99 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ef1:	89 1c 24             	mov    %ebx,(%esp)
  801ef4:	e8 43 f3 ff ff       	call   80123c <fd2data>
  801ef9:	83 c4 08             	add    $0x8,%esp
  801efc:	50                   	push   %eax
  801efd:	6a 00                	push   $0x0
  801eff:	e8 95 ed ff ff       	call   800c99 <sys_page_unmap>
}
  801f04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f07:	c9                   	leave  
  801f08:	c3                   	ret    

00801f09 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f09:	55                   	push   %ebp
  801f0a:	89 e5                	mov    %esp,%ebp
  801f0c:	57                   	push   %edi
  801f0d:	56                   	push   %esi
  801f0e:	53                   	push   %ebx
  801f0f:	83 ec 1c             	sub    $0x1c,%esp
  801f12:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f15:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f17:	a1 08 40 80 00       	mov    0x804008,%eax
  801f1c:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f1f:	83 ec 0c             	sub    $0xc,%esp
  801f22:	ff 75 e0             	pushl  -0x20(%ebp)
  801f25:	e8 f7 04 00 00       	call   802421 <pageref>
  801f2a:	89 c3                	mov    %eax,%ebx
  801f2c:	89 3c 24             	mov    %edi,(%esp)
  801f2f:	e8 ed 04 00 00       	call   802421 <pageref>
  801f34:	83 c4 10             	add    $0x10,%esp
  801f37:	39 c3                	cmp    %eax,%ebx
  801f39:	0f 94 c1             	sete   %cl
  801f3c:	0f b6 c9             	movzbl %cl,%ecx
  801f3f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f42:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f48:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f4b:	39 ce                	cmp    %ecx,%esi
  801f4d:	74 1b                	je     801f6a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f4f:	39 c3                	cmp    %eax,%ebx
  801f51:	75 c4                	jne    801f17 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f53:	8b 42 58             	mov    0x58(%edx),%eax
  801f56:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f59:	50                   	push   %eax
  801f5a:	56                   	push   %esi
  801f5b:	68 9b 2c 80 00       	push   $0x802c9b
  801f60:	e8 27 e3 ff ff       	call   80028c <cprintf>
  801f65:	83 c4 10             	add    $0x10,%esp
  801f68:	eb ad                	jmp    801f17 <_pipeisclosed+0xe>
	}
}
  801f6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f70:	5b                   	pop    %ebx
  801f71:	5e                   	pop    %esi
  801f72:	5f                   	pop    %edi
  801f73:	5d                   	pop    %ebp
  801f74:	c3                   	ret    

00801f75 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f75:	55                   	push   %ebp
  801f76:	89 e5                	mov    %esp,%ebp
  801f78:	57                   	push   %edi
  801f79:	56                   	push   %esi
  801f7a:	53                   	push   %ebx
  801f7b:	83 ec 28             	sub    $0x28,%esp
  801f7e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f81:	56                   	push   %esi
  801f82:	e8 b5 f2 ff ff       	call   80123c <fd2data>
  801f87:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f89:	83 c4 10             	add    $0x10,%esp
  801f8c:	bf 00 00 00 00       	mov    $0x0,%edi
  801f91:	eb 4b                	jmp    801fde <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f93:	89 da                	mov    %ebx,%edx
  801f95:	89 f0                	mov    %esi,%eax
  801f97:	e8 6d ff ff ff       	call   801f09 <_pipeisclosed>
  801f9c:	85 c0                	test   %eax,%eax
  801f9e:	75 48                	jne    801fe8 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801fa0:	e8 50 ec ff ff       	call   800bf5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fa5:	8b 43 04             	mov    0x4(%ebx),%eax
  801fa8:	8b 0b                	mov    (%ebx),%ecx
  801faa:	8d 51 20             	lea    0x20(%ecx),%edx
  801fad:	39 d0                	cmp    %edx,%eax
  801faf:	73 e2                	jae    801f93 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fb4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801fb8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801fbb:	89 c2                	mov    %eax,%edx
  801fbd:	c1 fa 1f             	sar    $0x1f,%edx
  801fc0:	89 d1                	mov    %edx,%ecx
  801fc2:	c1 e9 1b             	shr    $0x1b,%ecx
  801fc5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801fc8:	83 e2 1f             	and    $0x1f,%edx
  801fcb:	29 ca                	sub    %ecx,%edx
  801fcd:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801fd1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fd5:	83 c0 01             	add    $0x1,%eax
  801fd8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fdb:	83 c7 01             	add    $0x1,%edi
  801fde:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fe1:	75 c2                	jne    801fa5 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fe3:	8b 45 10             	mov    0x10(%ebp),%eax
  801fe6:	eb 05                	jmp    801fed <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fe8:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ff0:	5b                   	pop    %ebx
  801ff1:	5e                   	pop    %esi
  801ff2:	5f                   	pop    %edi
  801ff3:	5d                   	pop    %ebp
  801ff4:	c3                   	ret    

00801ff5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ff5:	55                   	push   %ebp
  801ff6:	89 e5                	mov    %esp,%ebp
  801ff8:	57                   	push   %edi
  801ff9:	56                   	push   %esi
  801ffa:	53                   	push   %ebx
  801ffb:	83 ec 18             	sub    $0x18,%esp
  801ffe:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802001:	57                   	push   %edi
  802002:	e8 35 f2 ff ff       	call   80123c <fd2data>
  802007:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802009:	83 c4 10             	add    $0x10,%esp
  80200c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802011:	eb 3d                	jmp    802050 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802013:	85 db                	test   %ebx,%ebx
  802015:	74 04                	je     80201b <devpipe_read+0x26>
				return i;
  802017:	89 d8                	mov    %ebx,%eax
  802019:	eb 44                	jmp    80205f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80201b:	89 f2                	mov    %esi,%edx
  80201d:	89 f8                	mov    %edi,%eax
  80201f:	e8 e5 fe ff ff       	call   801f09 <_pipeisclosed>
  802024:	85 c0                	test   %eax,%eax
  802026:	75 32                	jne    80205a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802028:	e8 c8 eb ff ff       	call   800bf5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80202d:	8b 06                	mov    (%esi),%eax
  80202f:	3b 46 04             	cmp    0x4(%esi),%eax
  802032:	74 df                	je     802013 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802034:	99                   	cltd   
  802035:	c1 ea 1b             	shr    $0x1b,%edx
  802038:	01 d0                	add    %edx,%eax
  80203a:	83 e0 1f             	and    $0x1f,%eax
  80203d:	29 d0                	sub    %edx,%eax
  80203f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802044:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802047:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80204a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80204d:	83 c3 01             	add    $0x1,%ebx
  802050:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802053:	75 d8                	jne    80202d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802055:	8b 45 10             	mov    0x10(%ebp),%eax
  802058:	eb 05                	jmp    80205f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80205a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80205f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802062:	5b                   	pop    %ebx
  802063:	5e                   	pop    %esi
  802064:	5f                   	pop    %edi
  802065:	5d                   	pop    %ebp
  802066:	c3                   	ret    

00802067 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802067:	55                   	push   %ebp
  802068:	89 e5                	mov    %esp,%ebp
  80206a:	56                   	push   %esi
  80206b:	53                   	push   %ebx
  80206c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80206f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802072:	50                   	push   %eax
  802073:	e8 db f1 ff ff       	call   801253 <fd_alloc>
  802078:	83 c4 10             	add    $0x10,%esp
  80207b:	89 c2                	mov    %eax,%edx
  80207d:	85 c0                	test   %eax,%eax
  80207f:	0f 88 2c 01 00 00    	js     8021b1 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802085:	83 ec 04             	sub    $0x4,%esp
  802088:	68 07 04 00 00       	push   $0x407
  80208d:	ff 75 f4             	pushl  -0xc(%ebp)
  802090:	6a 00                	push   $0x0
  802092:	e8 7d eb ff ff       	call   800c14 <sys_page_alloc>
  802097:	83 c4 10             	add    $0x10,%esp
  80209a:	89 c2                	mov    %eax,%edx
  80209c:	85 c0                	test   %eax,%eax
  80209e:	0f 88 0d 01 00 00    	js     8021b1 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020a4:	83 ec 0c             	sub    $0xc,%esp
  8020a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020aa:	50                   	push   %eax
  8020ab:	e8 a3 f1 ff ff       	call   801253 <fd_alloc>
  8020b0:	89 c3                	mov    %eax,%ebx
  8020b2:	83 c4 10             	add    $0x10,%esp
  8020b5:	85 c0                	test   %eax,%eax
  8020b7:	0f 88 e2 00 00 00    	js     80219f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020bd:	83 ec 04             	sub    $0x4,%esp
  8020c0:	68 07 04 00 00       	push   $0x407
  8020c5:	ff 75 f0             	pushl  -0x10(%ebp)
  8020c8:	6a 00                	push   $0x0
  8020ca:	e8 45 eb ff ff       	call   800c14 <sys_page_alloc>
  8020cf:	89 c3                	mov    %eax,%ebx
  8020d1:	83 c4 10             	add    $0x10,%esp
  8020d4:	85 c0                	test   %eax,%eax
  8020d6:	0f 88 c3 00 00 00    	js     80219f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020dc:	83 ec 0c             	sub    $0xc,%esp
  8020df:	ff 75 f4             	pushl  -0xc(%ebp)
  8020e2:	e8 55 f1 ff ff       	call   80123c <fd2data>
  8020e7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020e9:	83 c4 0c             	add    $0xc,%esp
  8020ec:	68 07 04 00 00       	push   $0x407
  8020f1:	50                   	push   %eax
  8020f2:	6a 00                	push   $0x0
  8020f4:	e8 1b eb ff ff       	call   800c14 <sys_page_alloc>
  8020f9:	89 c3                	mov    %eax,%ebx
  8020fb:	83 c4 10             	add    $0x10,%esp
  8020fe:	85 c0                	test   %eax,%eax
  802100:	0f 88 89 00 00 00    	js     80218f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802106:	83 ec 0c             	sub    $0xc,%esp
  802109:	ff 75 f0             	pushl  -0x10(%ebp)
  80210c:	e8 2b f1 ff ff       	call   80123c <fd2data>
  802111:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802118:	50                   	push   %eax
  802119:	6a 00                	push   $0x0
  80211b:	56                   	push   %esi
  80211c:	6a 00                	push   $0x0
  80211e:	e8 34 eb ff ff       	call   800c57 <sys_page_map>
  802123:	89 c3                	mov    %eax,%ebx
  802125:	83 c4 20             	add    $0x20,%esp
  802128:	85 c0                	test   %eax,%eax
  80212a:	78 55                	js     802181 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80212c:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802132:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802135:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802137:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802141:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802147:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80214a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80214c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80214f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802156:	83 ec 0c             	sub    $0xc,%esp
  802159:	ff 75 f4             	pushl  -0xc(%ebp)
  80215c:	e8 cb f0 ff ff       	call   80122c <fd2num>
  802161:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802164:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802166:	83 c4 04             	add    $0x4,%esp
  802169:	ff 75 f0             	pushl  -0x10(%ebp)
  80216c:	e8 bb f0 ff ff       	call   80122c <fd2num>
  802171:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802174:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802177:	83 c4 10             	add    $0x10,%esp
  80217a:	ba 00 00 00 00       	mov    $0x0,%edx
  80217f:	eb 30                	jmp    8021b1 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802181:	83 ec 08             	sub    $0x8,%esp
  802184:	56                   	push   %esi
  802185:	6a 00                	push   $0x0
  802187:	e8 0d eb ff ff       	call   800c99 <sys_page_unmap>
  80218c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80218f:	83 ec 08             	sub    $0x8,%esp
  802192:	ff 75 f0             	pushl  -0x10(%ebp)
  802195:	6a 00                	push   $0x0
  802197:	e8 fd ea ff ff       	call   800c99 <sys_page_unmap>
  80219c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80219f:	83 ec 08             	sub    $0x8,%esp
  8021a2:	ff 75 f4             	pushl  -0xc(%ebp)
  8021a5:	6a 00                	push   $0x0
  8021a7:	e8 ed ea ff ff       	call   800c99 <sys_page_unmap>
  8021ac:	83 c4 10             	add    $0x10,%esp
  8021af:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8021b1:	89 d0                	mov    %edx,%eax
  8021b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021b6:	5b                   	pop    %ebx
  8021b7:	5e                   	pop    %esi
  8021b8:	5d                   	pop    %ebp
  8021b9:	c3                   	ret    

008021ba <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021ba:	55                   	push   %ebp
  8021bb:	89 e5                	mov    %esp,%ebp
  8021bd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021c3:	50                   	push   %eax
  8021c4:	ff 75 08             	pushl  0x8(%ebp)
  8021c7:	e8 d6 f0 ff ff       	call   8012a2 <fd_lookup>
  8021cc:	83 c4 10             	add    $0x10,%esp
  8021cf:	85 c0                	test   %eax,%eax
  8021d1:	78 18                	js     8021eb <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021d3:	83 ec 0c             	sub    $0xc,%esp
  8021d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8021d9:	e8 5e f0 ff ff       	call   80123c <fd2data>
	return _pipeisclosed(fd, p);
  8021de:	89 c2                	mov    %eax,%edx
  8021e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021e3:	e8 21 fd ff ff       	call   801f09 <_pipeisclosed>
  8021e8:	83 c4 10             	add    $0x10,%esp
}
  8021eb:	c9                   	leave  
  8021ec:	c3                   	ret    

008021ed <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021ed:	55                   	push   %ebp
  8021ee:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8021f5:	5d                   	pop    %ebp
  8021f6:	c3                   	ret    

008021f7 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021f7:	55                   	push   %ebp
  8021f8:	89 e5                	mov    %esp,%ebp
  8021fa:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021fd:	68 b3 2c 80 00       	push   $0x802cb3
  802202:	ff 75 0c             	pushl  0xc(%ebp)
  802205:	e8 07 e6 ff ff       	call   800811 <strcpy>
	return 0;
}
  80220a:	b8 00 00 00 00       	mov    $0x0,%eax
  80220f:	c9                   	leave  
  802210:	c3                   	ret    

00802211 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802211:	55                   	push   %ebp
  802212:	89 e5                	mov    %esp,%ebp
  802214:	57                   	push   %edi
  802215:	56                   	push   %esi
  802216:	53                   	push   %ebx
  802217:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80221d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802222:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802228:	eb 2d                	jmp    802257 <devcons_write+0x46>
		m = n - tot;
  80222a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80222d:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80222f:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802232:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802237:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80223a:	83 ec 04             	sub    $0x4,%esp
  80223d:	53                   	push   %ebx
  80223e:	03 45 0c             	add    0xc(%ebp),%eax
  802241:	50                   	push   %eax
  802242:	57                   	push   %edi
  802243:	e8 5b e7 ff ff       	call   8009a3 <memmove>
		sys_cputs(buf, m);
  802248:	83 c4 08             	add    $0x8,%esp
  80224b:	53                   	push   %ebx
  80224c:	57                   	push   %edi
  80224d:	e8 06 e9 ff ff       	call   800b58 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802252:	01 de                	add    %ebx,%esi
  802254:	83 c4 10             	add    $0x10,%esp
  802257:	89 f0                	mov    %esi,%eax
  802259:	3b 75 10             	cmp    0x10(%ebp),%esi
  80225c:	72 cc                	jb     80222a <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80225e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802261:	5b                   	pop    %ebx
  802262:	5e                   	pop    %esi
  802263:	5f                   	pop    %edi
  802264:	5d                   	pop    %ebp
  802265:	c3                   	ret    

00802266 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802266:	55                   	push   %ebp
  802267:	89 e5                	mov    %esp,%ebp
  802269:	83 ec 08             	sub    $0x8,%esp
  80226c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802271:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802275:	74 2a                	je     8022a1 <devcons_read+0x3b>
  802277:	eb 05                	jmp    80227e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802279:	e8 77 e9 ff ff       	call   800bf5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80227e:	e8 f3 e8 ff ff       	call   800b76 <sys_cgetc>
  802283:	85 c0                	test   %eax,%eax
  802285:	74 f2                	je     802279 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802287:	85 c0                	test   %eax,%eax
  802289:	78 16                	js     8022a1 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80228b:	83 f8 04             	cmp    $0x4,%eax
  80228e:	74 0c                	je     80229c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802290:	8b 55 0c             	mov    0xc(%ebp),%edx
  802293:	88 02                	mov    %al,(%edx)
	return 1;
  802295:	b8 01 00 00 00       	mov    $0x1,%eax
  80229a:	eb 05                	jmp    8022a1 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80229c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8022a1:	c9                   	leave  
  8022a2:	c3                   	ret    

008022a3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8022a3:	55                   	push   %ebp
  8022a4:	89 e5                	mov    %esp,%ebp
  8022a6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8022a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ac:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8022af:	6a 01                	push   $0x1
  8022b1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022b4:	50                   	push   %eax
  8022b5:	e8 9e e8 ff ff       	call   800b58 <sys_cputs>
}
  8022ba:	83 c4 10             	add    $0x10,%esp
  8022bd:	c9                   	leave  
  8022be:	c3                   	ret    

008022bf <getchar>:

int
getchar(void)
{
  8022bf:	55                   	push   %ebp
  8022c0:	89 e5                	mov    %esp,%ebp
  8022c2:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022c5:	6a 01                	push   $0x1
  8022c7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022ca:	50                   	push   %eax
  8022cb:	6a 00                	push   $0x0
  8022cd:	e8 36 f2 ff ff       	call   801508 <read>
	if (r < 0)
  8022d2:	83 c4 10             	add    $0x10,%esp
  8022d5:	85 c0                	test   %eax,%eax
  8022d7:	78 0f                	js     8022e8 <getchar+0x29>
		return r;
	if (r < 1)
  8022d9:	85 c0                	test   %eax,%eax
  8022db:	7e 06                	jle    8022e3 <getchar+0x24>
		return -E_EOF;
	return c;
  8022dd:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022e1:	eb 05                	jmp    8022e8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022e3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022e8:	c9                   	leave  
  8022e9:	c3                   	ret    

008022ea <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022ea:	55                   	push   %ebp
  8022eb:	89 e5                	mov    %esp,%ebp
  8022ed:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022f3:	50                   	push   %eax
  8022f4:	ff 75 08             	pushl  0x8(%ebp)
  8022f7:	e8 a6 ef ff ff       	call   8012a2 <fd_lookup>
  8022fc:	83 c4 10             	add    $0x10,%esp
  8022ff:	85 c0                	test   %eax,%eax
  802301:	78 11                	js     802314 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802303:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802306:	8b 15 60 30 80 00    	mov    0x803060,%edx
  80230c:	39 10                	cmp    %edx,(%eax)
  80230e:	0f 94 c0             	sete   %al
  802311:	0f b6 c0             	movzbl %al,%eax
}
  802314:	c9                   	leave  
  802315:	c3                   	ret    

00802316 <opencons>:

int
opencons(void)
{
  802316:	55                   	push   %ebp
  802317:	89 e5                	mov    %esp,%ebp
  802319:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80231c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80231f:	50                   	push   %eax
  802320:	e8 2e ef ff ff       	call   801253 <fd_alloc>
  802325:	83 c4 10             	add    $0x10,%esp
		return r;
  802328:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80232a:	85 c0                	test   %eax,%eax
  80232c:	78 3e                	js     80236c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80232e:	83 ec 04             	sub    $0x4,%esp
  802331:	68 07 04 00 00       	push   $0x407
  802336:	ff 75 f4             	pushl  -0xc(%ebp)
  802339:	6a 00                	push   $0x0
  80233b:	e8 d4 e8 ff ff       	call   800c14 <sys_page_alloc>
  802340:	83 c4 10             	add    $0x10,%esp
		return r;
  802343:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802345:	85 c0                	test   %eax,%eax
  802347:	78 23                	js     80236c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802349:	8b 15 60 30 80 00    	mov    0x803060,%edx
  80234f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802352:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802354:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802357:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80235e:	83 ec 0c             	sub    $0xc,%esp
  802361:	50                   	push   %eax
  802362:	e8 c5 ee ff ff       	call   80122c <fd2num>
  802367:	89 c2                	mov    %eax,%edx
  802369:	83 c4 10             	add    $0x10,%esp
}
  80236c:	89 d0                	mov    %edx,%eax
  80236e:	c9                   	leave  
  80236f:	c3                   	ret    

00802370 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802370:	55                   	push   %ebp
  802371:	89 e5                	mov    %esp,%ebp
  802373:	56                   	push   %esi
  802374:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802375:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802378:	8b 35 08 30 80 00    	mov    0x803008,%esi
  80237e:	e8 53 e8 ff ff       	call   800bd6 <sys_getenvid>
  802383:	83 ec 0c             	sub    $0xc,%esp
  802386:	ff 75 0c             	pushl  0xc(%ebp)
  802389:	ff 75 08             	pushl  0x8(%ebp)
  80238c:	56                   	push   %esi
  80238d:	50                   	push   %eax
  80238e:	68 c0 2c 80 00       	push   $0x802cc0
  802393:	e8 f4 de ff ff       	call   80028c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802398:	83 c4 18             	add    $0x18,%esp
  80239b:	53                   	push   %ebx
  80239c:	ff 75 10             	pushl  0x10(%ebp)
  80239f:	e8 97 de ff ff       	call   80023b <vcprintf>
	cprintf("\n");
  8023a4:	c7 04 24 ac 2c 80 00 	movl   $0x802cac,(%esp)
  8023ab:	e8 dc de ff ff       	call   80028c <cprintf>
  8023b0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8023b3:	cc                   	int3   
  8023b4:	eb fd                	jmp    8023b3 <_panic+0x43>

008023b6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023b6:	55                   	push   %ebp
  8023b7:	89 e5                	mov    %esp,%ebp
  8023b9:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8023bc:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8023c3:	75 2e                	jne    8023f3 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8023c5:	e8 0c e8 ff ff       	call   800bd6 <sys_getenvid>
  8023ca:	83 ec 04             	sub    $0x4,%esp
  8023cd:	68 07 0e 00 00       	push   $0xe07
  8023d2:	68 00 f0 bf ee       	push   $0xeebff000
  8023d7:	50                   	push   %eax
  8023d8:	e8 37 e8 ff ff       	call   800c14 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8023dd:	e8 f4 e7 ff ff       	call   800bd6 <sys_getenvid>
  8023e2:	83 c4 08             	add    $0x8,%esp
  8023e5:	68 fd 23 80 00       	push   $0x8023fd
  8023ea:	50                   	push   %eax
  8023eb:	e8 6f e9 ff ff       	call   800d5f <sys_env_set_pgfault_upcall>
  8023f0:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8023f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f6:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8023fb:	c9                   	leave  
  8023fc:	c3                   	ret    

008023fd <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023fd:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023fe:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802403:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802405:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  802408:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  80240c:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802410:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  802413:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  802416:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  802417:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  80241a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  80241b:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  80241c:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802420:	c3                   	ret    

00802421 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802421:	55                   	push   %ebp
  802422:	89 e5                	mov    %esp,%ebp
  802424:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802427:	89 d0                	mov    %edx,%eax
  802429:	c1 e8 16             	shr    $0x16,%eax
  80242c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802433:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802438:	f6 c1 01             	test   $0x1,%cl
  80243b:	74 1d                	je     80245a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80243d:	c1 ea 0c             	shr    $0xc,%edx
  802440:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802447:	f6 c2 01             	test   $0x1,%dl
  80244a:	74 0e                	je     80245a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80244c:	c1 ea 0c             	shr    $0xc,%edx
  80244f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802456:	ef 
  802457:	0f b7 c0             	movzwl %ax,%eax
}
  80245a:	5d                   	pop    %ebp
  80245b:	c3                   	ret    
  80245c:	66 90                	xchg   %ax,%ax
  80245e:	66 90                	xchg   %ax,%ax

00802460 <__udivdi3>:
  802460:	55                   	push   %ebp
  802461:	57                   	push   %edi
  802462:	56                   	push   %esi
  802463:	53                   	push   %ebx
  802464:	83 ec 1c             	sub    $0x1c,%esp
  802467:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80246b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80246f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802473:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802477:	85 f6                	test   %esi,%esi
  802479:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80247d:	89 ca                	mov    %ecx,%edx
  80247f:	89 f8                	mov    %edi,%eax
  802481:	75 3d                	jne    8024c0 <__udivdi3+0x60>
  802483:	39 cf                	cmp    %ecx,%edi
  802485:	0f 87 c5 00 00 00    	ja     802550 <__udivdi3+0xf0>
  80248b:	85 ff                	test   %edi,%edi
  80248d:	89 fd                	mov    %edi,%ebp
  80248f:	75 0b                	jne    80249c <__udivdi3+0x3c>
  802491:	b8 01 00 00 00       	mov    $0x1,%eax
  802496:	31 d2                	xor    %edx,%edx
  802498:	f7 f7                	div    %edi
  80249a:	89 c5                	mov    %eax,%ebp
  80249c:	89 c8                	mov    %ecx,%eax
  80249e:	31 d2                	xor    %edx,%edx
  8024a0:	f7 f5                	div    %ebp
  8024a2:	89 c1                	mov    %eax,%ecx
  8024a4:	89 d8                	mov    %ebx,%eax
  8024a6:	89 cf                	mov    %ecx,%edi
  8024a8:	f7 f5                	div    %ebp
  8024aa:	89 c3                	mov    %eax,%ebx
  8024ac:	89 d8                	mov    %ebx,%eax
  8024ae:	89 fa                	mov    %edi,%edx
  8024b0:	83 c4 1c             	add    $0x1c,%esp
  8024b3:	5b                   	pop    %ebx
  8024b4:	5e                   	pop    %esi
  8024b5:	5f                   	pop    %edi
  8024b6:	5d                   	pop    %ebp
  8024b7:	c3                   	ret    
  8024b8:	90                   	nop
  8024b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024c0:	39 ce                	cmp    %ecx,%esi
  8024c2:	77 74                	ja     802538 <__udivdi3+0xd8>
  8024c4:	0f bd fe             	bsr    %esi,%edi
  8024c7:	83 f7 1f             	xor    $0x1f,%edi
  8024ca:	0f 84 98 00 00 00    	je     802568 <__udivdi3+0x108>
  8024d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8024d5:	89 f9                	mov    %edi,%ecx
  8024d7:	89 c5                	mov    %eax,%ebp
  8024d9:	29 fb                	sub    %edi,%ebx
  8024db:	d3 e6                	shl    %cl,%esi
  8024dd:	89 d9                	mov    %ebx,%ecx
  8024df:	d3 ed                	shr    %cl,%ebp
  8024e1:	89 f9                	mov    %edi,%ecx
  8024e3:	d3 e0                	shl    %cl,%eax
  8024e5:	09 ee                	or     %ebp,%esi
  8024e7:	89 d9                	mov    %ebx,%ecx
  8024e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024ed:	89 d5                	mov    %edx,%ebp
  8024ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024f3:	d3 ed                	shr    %cl,%ebp
  8024f5:	89 f9                	mov    %edi,%ecx
  8024f7:	d3 e2                	shl    %cl,%edx
  8024f9:	89 d9                	mov    %ebx,%ecx
  8024fb:	d3 e8                	shr    %cl,%eax
  8024fd:	09 c2                	or     %eax,%edx
  8024ff:	89 d0                	mov    %edx,%eax
  802501:	89 ea                	mov    %ebp,%edx
  802503:	f7 f6                	div    %esi
  802505:	89 d5                	mov    %edx,%ebp
  802507:	89 c3                	mov    %eax,%ebx
  802509:	f7 64 24 0c          	mull   0xc(%esp)
  80250d:	39 d5                	cmp    %edx,%ebp
  80250f:	72 10                	jb     802521 <__udivdi3+0xc1>
  802511:	8b 74 24 08          	mov    0x8(%esp),%esi
  802515:	89 f9                	mov    %edi,%ecx
  802517:	d3 e6                	shl    %cl,%esi
  802519:	39 c6                	cmp    %eax,%esi
  80251b:	73 07                	jae    802524 <__udivdi3+0xc4>
  80251d:	39 d5                	cmp    %edx,%ebp
  80251f:	75 03                	jne    802524 <__udivdi3+0xc4>
  802521:	83 eb 01             	sub    $0x1,%ebx
  802524:	31 ff                	xor    %edi,%edi
  802526:	89 d8                	mov    %ebx,%eax
  802528:	89 fa                	mov    %edi,%edx
  80252a:	83 c4 1c             	add    $0x1c,%esp
  80252d:	5b                   	pop    %ebx
  80252e:	5e                   	pop    %esi
  80252f:	5f                   	pop    %edi
  802530:	5d                   	pop    %ebp
  802531:	c3                   	ret    
  802532:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802538:	31 ff                	xor    %edi,%edi
  80253a:	31 db                	xor    %ebx,%ebx
  80253c:	89 d8                	mov    %ebx,%eax
  80253e:	89 fa                	mov    %edi,%edx
  802540:	83 c4 1c             	add    $0x1c,%esp
  802543:	5b                   	pop    %ebx
  802544:	5e                   	pop    %esi
  802545:	5f                   	pop    %edi
  802546:	5d                   	pop    %ebp
  802547:	c3                   	ret    
  802548:	90                   	nop
  802549:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802550:	89 d8                	mov    %ebx,%eax
  802552:	f7 f7                	div    %edi
  802554:	31 ff                	xor    %edi,%edi
  802556:	89 c3                	mov    %eax,%ebx
  802558:	89 d8                	mov    %ebx,%eax
  80255a:	89 fa                	mov    %edi,%edx
  80255c:	83 c4 1c             	add    $0x1c,%esp
  80255f:	5b                   	pop    %ebx
  802560:	5e                   	pop    %esi
  802561:	5f                   	pop    %edi
  802562:	5d                   	pop    %ebp
  802563:	c3                   	ret    
  802564:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802568:	39 ce                	cmp    %ecx,%esi
  80256a:	72 0c                	jb     802578 <__udivdi3+0x118>
  80256c:	31 db                	xor    %ebx,%ebx
  80256e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802572:	0f 87 34 ff ff ff    	ja     8024ac <__udivdi3+0x4c>
  802578:	bb 01 00 00 00       	mov    $0x1,%ebx
  80257d:	e9 2a ff ff ff       	jmp    8024ac <__udivdi3+0x4c>
  802582:	66 90                	xchg   %ax,%ax
  802584:	66 90                	xchg   %ax,%ax
  802586:	66 90                	xchg   %ax,%ax
  802588:	66 90                	xchg   %ax,%ax
  80258a:	66 90                	xchg   %ax,%ax
  80258c:	66 90                	xchg   %ax,%ax
  80258e:	66 90                	xchg   %ax,%ax

00802590 <__umoddi3>:
  802590:	55                   	push   %ebp
  802591:	57                   	push   %edi
  802592:	56                   	push   %esi
  802593:	53                   	push   %ebx
  802594:	83 ec 1c             	sub    $0x1c,%esp
  802597:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80259b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80259f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025a7:	85 d2                	test   %edx,%edx
  8025a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025b1:	89 f3                	mov    %esi,%ebx
  8025b3:	89 3c 24             	mov    %edi,(%esp)
  8025b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025ba:	75 1c                	jne    8025d8 <__umoddi3+0x48>
  8025bc:	39 f7                	cmp    %esi,%edi
  8025be:	76 50                	jbe    802610 <__umoddi3+0x80>
  8025c0:	89 c8                	mov    %ecx,%eax
  8025c2:	89 f2                	mov    %esi,%edx
  8025c4:	f7 f7                	div    %edi
  8025c6:	89 d0                	mov    %edx,%eax
  8025c8:	31 d2                	xor    %edx,%edx
  8025ca:	83 c4 1c             	add    $0x1c,%esp
  8025cd:	5b                   	pop    %ebx
  8025ce:	5e                   	pop    %esi
  8025cf:	5f                   	pop    %edi
  8025d0:	5d                   	pop    %ebp
  8025d1:	c3                   	ret    
  8025d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025d8:	39 f2                	cmp    %esi,%edx
  8025da:	89 d0                	mov    %edx,%eax
  8025dc:	77 52                	ja     802630 <__umoddi3+0xa0>
  8025de:	0f bd ea             	bsr    %edx,%ebp
  8025e1:	83 f5 1f             	xor    $0x1f,%ebp
  8025e4:	75 5a                	jne    802640 <__umoddi3+0xb0>
  8025e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8025ea:	0f 82 e0 00 00 00    	jb     8026d0 <__umoddi3+0x140>
  8025f0:	39 0c 24             	cmp    %ecx,(%esp)
  8025f3:	0f 86 d7 00 00 00    	jbe    8026d0 <__umoddi3+0x140>
  8025f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802601:	83 c4 1c             	add    $0x1c,%esp
  802604:	5b                   	pop    %ebx
  802605:	5e                   	pop    %esi
  802606:	5f                   	pop    %edi
  802607:	5d                   	pop    %ebp
  802608:	c3                   	ret    
  802609:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802610:	85 ff                	test   %edi,%edi
  802612:	89 fd                	mov    %edi,%ebp
  802614:	75 0b                	jne    802621 <__umoddi3+0x91>
  802616:	b8 01 00 00 00       	mov    $0x1,%eax
  80261b:	31 d2                	xor    %edx,%edx
  80261d:	f7 f7                	div    %edi
  80261f:	89 c5                	mov    %eax,%ebp
  802621:	89 f0                	mov    %esi,%eax
  802623:	31 d2                	xor    %edx,%edx
  802625:	f7 f5                	div    %ebp
  802627:	89 c8                	mov    %ecx,%eax
  802629:	f7 f5                	div    %ebp
  80262b:	89 d0                	mov    %edx,%eax
  80262d:	eb 99                	jmp    8025c8 <__umoddi3+0x38>
  80262f:	90                   	nop
  802630:	89 c8                	mov    %ecx,%eax
  802632:	89 f2                	mov    %esi,%edx
  802634:	83 c4 1c             	add    $0x1c,%esp
  802637:	5b                   	pop    %ebx
  802638:	5e                   	pop    %esi
  802639:	5f                   	pop    %edi
  80263a:	5d                   	pop    %ebp
  80263b:	c3                   	ret    
  80263c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802640:	8b 34 24             	mov    (%esp),%esi
  802643:	bf 20 00 00 00       	mov    $0x20,%edi
  802648:	89 e9                	mov    %ebp,%ecx
  80264a:	29 ef                	sub    %ebp,%edi
  80264c:	d3 e0                	shl    %cl,%eax
  80264e:	89 f9                	mov    %edi,%ecx
  802650:	89 f2                	mov    %esi,%edx
  802652:	d3 ea                	shr    %cl,%edx
  802654:	89 e9                	mov    %ebp,%ecx
  802656:	09 c2                	or     %eax,%edx
  802658:	89 d8                	mov    %ebx,%eax
  80265a:	89 14 24             	mov    %edx,(%esp)
  80265d:	89 f2                	mov    %esi,%edx
  80265f:	d3 e2                	shl    %cl,%edx
  802661:	89 f9                	mov    %edi,%ecx
  802663:	89 54 24 04          	mov    %edx,0x4(%esp)
  802667:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80266b:	d3 e8                	shr    %cl,%eax
  80266d:	89 e9                	mov    %ebp,%ecx
  80266f:	89 c6                	mov    %eax,%esi
  802671:	d3 e3                	shl    %cl,%ebx
  802673:	89 f9                	mov    %edi,%ecx
  802675:	89 d0                	mov    %edx,%eax
  802677:	d3 e8                	shr    %cl,%eax
  802679:	89 e9                	mov    %ebp,%ecx
  80267b:	09 d8                	or     %ebx,%eax
  80267d:	89 d3                	mov    %edx,%ebx
  80267f:	89 f2                	mov    %esi,%edx
  802681:	f7 34 24             	divl   (%esp)
  802684:	89 d6                	mov    %edx,%esi
  802686:	d3 e3                	shl    %cl,%ebx
  802688:	f7 64 24 04          	mull   0x4(%esp)
  80268c:	39 d6                	cmp    %edx,%esi
  80268e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802692:	89 d1                	mov    %edx,%ecx
  802694:	89 c3                	mov    %eax,%ebx
  802696:	72 08                	jb     8026a0 <__umoddi3+0x110>
  802698:	75 11                	jne    8026ab <__umoddi3+0x11b>
  80269a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80269e:	73 0b                	jae    8026ab <__umoddi3+0x11b>
  8026a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8026a4:	1b 14 24             	sbb    (%esp),%edx
  8026a7:	89 d1                	mov    %edx,%ecx
  8026a9:	89 c3                	mov    %eax,%ebx
  8026ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8026af:	29 da                	sub    %ebx,%edx
  8026b1:	19 ce                	sbb    %ecx,%esi
  8026b3:	89 f9                	mov    %edi,%ecx
  8026b5:	89 f0                	mov    %esi,%eax
  8026b7:	d3 e0                	shl    %cl,%eax
  8026b9:	89 e9                	mov    %ebp,%ecx
  8026bb:	d3 ea                	shr    %cl,%edx
  8026bd:	89 e9                	mov    %ebp,%ecx
  8026bf:	d3 ee                	shr    %cl,%esi
  8026c1:	09 d0                	or     %edx,%eax
  8026c3:	89 f2                	mov    %esi,%edx
  8026c5:	83 c4 1c             	add    $0x1c,%esp
  8026c8:	5b                   	pop    %ebx
  8026c9:	5e                   	pop    %esi
  8026ca:	5f                   	pop    %edi
  8026cb:	5d                   	pop    %ebp
  8026cc:	c3                   	ret    
  8026cd:	8d 76 00             	lea    0x0(%esi),%esi
  8026d0:	29 f9                	sub    %edi,%ecx
  8026d2:	19 d6                	sbb    %edx,%esi
  8026d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026dc:	e9 18 ff ff ff       	jmp    8025f9 <__umoddi3+0x69>
