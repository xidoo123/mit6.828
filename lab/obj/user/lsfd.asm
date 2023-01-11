
obj/user/lsfd.debug:     file format elf32-i386


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
  80002c:	e8 dc 00 00 00       	call   80010d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <usage>:
#include <inc/lib.h>

void
usage(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: lsfd [-1]\n");
  800039:	68 e0 25 80 00       	push   $0x8025e0
  80003e:	e8 bd 01 00 00       	call   800200 <cprintf>
	exit();
  800043:	e8 0b 01 00 00       	call   800153 <exit>
}
  800048:	83 c4 10             	add    $0x10,%esp
  80004b:	c9                   	leave  
  80004c:	c3                   	ret    

0080004d <umain>:

void
umain(int argc, char **argv)
{
  80004d:	55                   	push   %ebp
  80004e:	89 e5                	mov    %esp,%ebp
  800050:	57                   	push   %edi
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	81 ec b0 00 00 00    	sub    $0xb0,%esp
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800059:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80005f:	50                   	push   %eax
  800060:	ff 75 0c             	pushl  0xc(%ebp)
  800063:	8d 45 08             	lea    0x8(%ebp),%eax
  800066:	50                   	push   %eax
  800067:	e8 b0 0d 00 00       	call   800e1c <argstart>
	while ((i = argnext(&args)) >= 0)
  80006c:	83 c4 10             	add    $0x10,%esp
}

void
umain(int argc, char **argv)
{
	int i, usefprint = 0;
  80006f:	be 00 00 00 00       	mov    $0x0,%esi
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800074:	8d 9d 4c ff ff ff    	lea    -0xb4(%ebp),%ebx
  80007a:	eb 11                	jmp    80008d <umain+0x40>
		if (i == '1')
  80007c:	83 f8 31             	cmp    $0x31,%eax
  80007f:	74 07                	je     800088 <umain+0x3b>
			usefprint = 1;
		else
			usage();
  800081:	e8 ad ff ff ff       	call   800033 <usage>
  800086:	eb 05                	jmp    80008d <umain+0x40>
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
		if (i == '1')
			usefprint = 1;
  800088:	be 01 00 00 00       	mov    $0x1,%esi
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  80008d:	83 ec 0c             	sub    $0xc,%esp
  800090:	53                   	push   %ebx
  800091:	e8 b6 0d 00 00       	call   800e4c <argnext>
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 df                	jns    80007c <umain+0x2f>
  80009d:	bb 00 00 00 00       	mov    $0x0,%ebx
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
  8000a2:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	57                   	push   %edi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 b2 13 00 00       	call   801464 <fstat>
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	78 44                	js     8000fd <umain+0xb0>
			if (usefprint)
  8000b9:	85 f6                	test   %esi,%esi
  8000bb:	74 22                	je     8000df <umain+0x92>
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000c3:	ff 70 04             	pushl  0x4(%eax)
  8000c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8000c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8000cc:	57                   	push   %edi
  8000cd:	53                   	push   %ebx
  8000ce:	68 f4 25 80 00       	push   $0x8025f4
  8000d3:	6a 01                	push   $0x1
  8000d5:	e8 77 17 00 00       	call   801851 <fprintf>
  8000da:	83 c4 20             	add    $0x20,%esp
  8000dd:	eb 1e                	jmp    8000fd <umain+0xb0>
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e5:	ff 70 04             	pushl  0x4(%eax)
  8000e8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8000ee:	57                   	push   %edi
  8000ef:	53                   	push   %ebx
  8000f0:	68 f4 25 80 00       	push   $0x8025f4
  8000f5:	e8 06 01 00 00       	call   800200 <cprintf>
  8000fa:	83 c4 20             	add    $0x20,%esp
		if (i == '1')
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
  8000fd:	83 c3 01             	add    $0x1,%ebx
  800100:	83 fb 20             	cmp    $0x20,%ebx
  800103:	75 a3                	jne    8000a8 <umain+0x5b>
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
		}
}
  800105:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800108:	5b                   	pop    %ebx
  800109:	5e                   	pop    %esi
  80010a:	5f                   	pop    %edi
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    

0080010d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
  800112:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800115:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800118:	e8 2d 0a 00 00       	call   800b4a <sys_getenvid>
  80011d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800122:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800125:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80012a:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012f:	85 db                	test   %ebx,%ebx
  800131:	7e 07                	jle    80013a <libmain+0x2d>
		binaryname = argv[0];
  800133:	8b 06                	mov    (%esi),%eax
  800135:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80013a:	83 ec 08             	sub    $0x8,%esp
  80013d:	56                   	push   %esi
  80013e:	53                   	push   %ebx
  80013f:	e8 09 ff ff ff       	call   80004d <umain>

	// exit gracefully
	exit();
  800144:	e8 0a 00 00 00       	call   800153 <exit>
}
  800149:	83 c4 10             	add    $0x10,%esp
  80014c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80014f:	5b                   	pop    %ebx
  800150:	5e                   	pop    %esi
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    

00800153 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800159:	e8 dd 0f 00 00       	call   80113b <close_all>
	sys_env_destroy(0);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	6a 00                	push   $0x0
  800163:	e8 a1 09 00 00       	call   800b09 <sys_env_destroy>
}
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	c9                   	leave  
  80016c:	c3                   	ret    

0080016d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	53                   	push   %ebx
  800171:	83 ec 04             	sub    $0x4,%esp
  800174:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800177:	8b 13                	mov    (%ebx),%edx
  800179:	8d 42 01             	lea    0x1(%edx),%eax
  80017c:	89 03                	mov    %eax,(%ebx)
  80017e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800181:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800185:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018a:	75 1a                	jne    8001a6 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	68 ff 00 00 00       	push   $0xff
  800194:	8d 43 08             	lea    0x8(%ebx),%eax
  800197:	50                   	push   %eax
  800198:	e8 2f 09 00 00       	call   800acc <sys_cputs>
		b->idx = 0;
  80019d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a3:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ad:	c9                   	leave  
  8001ae:	c3                   	ret    

008001af <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001bf:	00 00 00 
	b.cnt = 0;
  8001c2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cc:	ff 75 0c             	pushl  0xc(%ebp)
  8001cf:	ff 75 08             	pushl  0x8(%ebp)
  8001d2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d8:	50                   	push   %eax
  8001d9:	68 6d 01 80 00       	push   $0x80016d
  8001de:	e8 54 01 00 00       	call   800337 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e3:	83 c4 08             	add    $0x8,%esp
  8001e6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ec:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f2:	50                   	push   %eax
  8001f3:	e8 d4 08 00 00       	call   800acc <sys_cputs>

	return b.cnt;
}
  8001f8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fe:	c9                   	leave  
  8001ff:	c3                   	ret    

00800200 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800206:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800209:	50                   	push   %eax
  80020a:	ff 75 08             	pushl  0x8(%ebp)
  80020d:	e8 9d ff ff ff       	call   8001af <vcprintf>
	va_end(ap);

	return cnt;
}
  800212:	c9                   	leave  
  800213:	c3                   	ret    

00800214 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	57                   	push   %edi
  800218:	56                   	push   %esi
  800219:	53                   	push   %ebx
  80021a:	83 ec 1c             	sub    $0x1c,%esp
  80021d:	89 c7                	mov    %eax,%edi
  80021f:	89 d6                	mov    %edx,%esi
  800221:	8b 45 08             	mov    0x8(%ebp),%eax
  800224:	8b 55 0c             	mov    0xc(%ebp),%edx
  800227:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80022d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800230:	bb 00 00 00 00       	mov    $0x0,%ebx
  800235:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800238:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80023b:	39 d3                	cmp    %edx,%ebx
  80023d:	72 05                	jb     800244 <printnum+0x30>
  80023f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800242:	77 45                	ja     800289 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	ff 75 18             	pushl  0x18(%ebp)
  80024a:	8b 45 14             	mov    0x14(%ebp),%eax
  80024d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800250:	53                   	push   %ebx
  800251:	ff 75 10             	pushl  0x10(%ebp)
  800254:	83 ec 08             	sub    $0x8,%esp
  800257:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025a:	ff 75 e0             	pushl  -0x20(%ebp)
  80025d:	ff 75 dc             	pushl  -0x24(%ebp)
  800260:	ff 75 d8             	pushl  -0x28(%ebp)
  800263:	e8 d8 20 00 00       	call   802340 <__udivdi3>
  800268:	83 c4 18             	add    $0x18,%esp
  80026b:	52                   	push   %edx
  80026c:	50                   	push   %eax
  80026d:	89 f2                	mov    %esi,%edx
  80026f:	89 f8                	mov    %edi,%eax
  800271:	e8 9e ff ff ff       	call   800214 <printnum>
  800276:	83 c4 20             	add    $0x20,%esp
  800279:	eb 18                	jmp    800293 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027b:	83 ec 08             	sub    $0x8,%esp
  80027e:	56                   	push   %esi
  80027f:	ff 75 18             	pushl  0x18(%ebp)
  800282:	ff d7                	call   *%edi
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	eb 03                	jmp    80028c <printnum+0x78>
  800289:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028c:	83 eb 01             	sub    $0x1,%ebx
  80028f:	85 db                	test   %ebx,%ebx
  800291:	7f e8                	jg     80027b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800293:	83 ec 08             	sub    $0x8,%esp
  800296:	56                   	push   %esi
  800297:	83 ec 04             	sub    $0x4,%esp
  80029a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80029d:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a0:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a3:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a6:	e8 c5 21 00 00       	call   802470 <__umoddi3>
  8002ab:	83 c4 14             	add    $0x14,%esp
  8002ae:	0f be 80 26 26 80 00 	movsbl 0x802626(%eax),%eax
  8002b5:	50                   	push   %eax
  8002b6:	ff d7                	call   *%edi
}
  8002b8:	83 c4 10             	add    $0x10,%esp
  8002bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002be:	5b                   	pop    %ebx
  8002bf:	5e                   	pop    %esi
  8002c0:	5f                   	pop    %edi
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c6:	83 fa 01             	cmp    $0x1,%edx
  8002c9:	7e 0e                	jle    8002d9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002cb:	8b 10                	mov    (%eax),%edx
  8002cd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d0:	89 08                	mov    %ecx,(%eax)
  8002d2:	8b 02                	mov    (%edx),%eax
  8002d4:	8b 52 04             	mov    0x4(%edx),%edx
  8002d7:	eb 22                	jmp    8002fb <getuint+0x38>
	else if (lflag)
  8002d9:	85 d2                	test   %edx,%edx
  8002db:	74 10                	je     8002ed <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002dd:	8b 10                	mov    (%eax),%edx
  8002df:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e2:	89 08                	mov    %ecx,(%eax)
  8002e4:	8b 02                	mov    (%edx),%eax
  8002e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002eb:	eb 0e                	jmp    8002fb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002ed:	8b 10                	mov    (%eax),%edx
  8002ef:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f2:	89 08                	mov    %ecx,(%eax)
  8002f4:	8b 02                	mov    (%edx),%eax
  8002f6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800303:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800307:	8b 10                	mov    (%eax),%edx
  800309:	3b 50 04             	cmp    0x4(%eax),%edx
  80030c:	73 0a                	jae    800318 <sprintputch+0x1b>
		*b->buf++ = ch;
  80030e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800311:	89 08                	mov    %ecx,(%eax)
  800313:	8b 45 08             	mov    0x8(%ebp),%eax
  800316:	88 02                	mov    %al,(%edx)
}
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800320:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800323:	50                   	push   %eax
  800324:	ff 75 10             	pushl  0x10(%ebp)
  800327:	ff 75 0c             	pushl  0xc(%ebp)
  80032a:	ff 75 08             	pushl  0x8(%ebp)
  80032d:	e8 05 00 00 00       	call   800337 <vprintfmt>
	va_end(ap);
}
  800332:	83 c4 10             	add    $0x10,%esp
  800335:	c9                   	leave  
  800336:	c3                   	ret    

00800337 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800337:	55                   	push   %ebp
  800338:	89 e5                	mov    %esp,%ebp
  80033a:	57                   	push   %edi
  80033b:	56                   	push   %esi
  80033c:	53                   	push   %ebx
  80033d:	83 ec 2c             	sub    $0x2c,%esp
  800340:	8b 75 08             	mov    0x8(%ebp),%esi
  800343:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800346:	8b 7d 10             	mov    0x10(%ebp),%edi
  800349:	eb 12                	jmp    80035d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80034b:	85 c0                	test   %eax,%eax
  80034d:	0f 84 89 03 00 00    	je     8006dc <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800353:	83 ec 08             	sub    $0x8,%esp
  800356:	53                   	push   %ebx
  800357:	50                   	push   %eax
  800358:	ff d6                	call   *%esi
  80035a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80035d:	83 c7 01             	add    $0x1,%edi
  800360:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800364:	83 f8 25             	cmp    $0x25,%eax
  800367:	75 e2                	jne    80034b <vprintfmt+0x14>
  800369:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80036d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800374:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80037b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800382:	ba 00 00 00 00       	mov    $0x0,%edx
  800387:	eb 07                	jmp    800390 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80038c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800390:	8d 47 01             	lea    0x1(%edi),%eax
  800393:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800396:	0f b6 07             	movzbl (%edi),%eax
  800399:	0f b6 c8             	movzbl %al,%ecx
  80039c:	83 e8 23             	sub    $0x23,%eax
  80039f:	3c 55                	cmp    $0x55,%al
  8003a1:	0f 87 1a 03 00 00    	ja     8006c1 <vprintfmt+0x38a>
  8003a7:	0f b6 c0             	movzbl %al,%eax
  8003aa:	ff 24 85 60 27 80 00 	jmp    *0x802760(,%eax,4)
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b4:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003b8:	eb d6                	jmp    800390 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c8:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003cc:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003cf:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003d2:	83 fa 09             	cmp    $0x9,%edx
  8003d5:	77 39                	ja     800410 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003da:	eb e9                	jmp    8003c5 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003df:	8d 48 04             	lea    0x4(%eax),%ecx
  8003e2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e5:	8b 00                	mov    (%eax),%eax
  8003e7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ed:	eb 27                	jmp    800416 <vprintfmt+0xdf>
  8003ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f2:	85 c0                	test   %eax,%eax
  8003f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f9:	0f 49 c8             	cmovns %eax,%ecx
  8003fc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800402:	eb 8c                	jmp    800390 <vprintfmt+0x59>
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800407:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80040e:	eb 80                	jmp    800390 <vprintfmt+0x59>
  800410:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800413:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800416:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80041a:	0f 89 70 ff ff ff    	jns    800390 <vprintfmt+0x59>
				width = precision, precision = -1;
  800420:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800423:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800426:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80042d:	e9 5e ff ff ff       	jmp    800390 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800432:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800438:	e9 53 ff ff ff       	jmp    800390 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80043d:	8b 45 14             	mov    0x14(%ebp),%eax
  800440:	8d 50 04             	lea    0x4(%eax),%edx
  800443:	89 55 14             	mov    %edx,0x14(%ebp)
  800446:	83 ec 08             	sub    $0x8,%esp
  800449:	53                   	push   %ebx
  80044a:	ff 30                	pushl  (%eax)
  80044c:	ff d6                	call   *%esi
			break;
  80044e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800451:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800454:	e9 04 ff ff ff       	jmp    80035d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800459:	8b 45 14             	mov    0x14(%ebp),%eax
  80045c:	8d 50 04             	lea    0x4(%eax),%edx
  80045f:	89 55 14             	mov    %edx,0x14(%ebp)
  800462:	8b 00                	mov    (%eax),%eax
  800464:	99                   	cltd   
  800465:	31 d0                	xor    %edx,%eax
  800467:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800469:	83 f8 0f             	cmp    $0xf,%eax
  80046c:	7f 0b                	jg     800479 <vprintfmt+0x142>
  80046e:	8b 14 85 c0 28 80 00 	mov    0x8028c0(,%eax,4),%edx
  800475:	85 d2                	test   %edx,%edx
  800477:	75 18                	jne    800491 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800479:	50                   	push   %eax
  80047a:	68 3e 26 80 00       	push   $0x80263e
  80047f:	53                   	push   %ebx
  800480:	56                   	push   %esi
  800481:	e8 94 fe ff ff       	call   80031a <printfmt>
  800486:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800489:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80048c:	e9 cc fe ff ff       	jmp    80035d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800491:	52                   	push   %edx
  800492:	68 f5 29 80 00       	push   $0x8029f5
  800497:	53                   	push   %ebx
  800498:	56                   	push   %esi
  800499:	e8 7c fe ff ff       	call   80031a <printfmt>
  80049e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a4:	e9 b4 fe ff ff       	jmp    80035d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8d 50 04             	lea    0x4(%eax),%edx
  8004af:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004b4:	85 ff                	test   %edi,%edi
  8004b6:	b8 37 26 80 00       	mov    $0x802637,%eax
  8004bb:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004be:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c2:	0f 8e 94 00 00 00    	jle    80055c <vprintfmt+0x225>
  8004c8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004cc:	0f 84 98 00 00 00    	je     80056a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d2:	83 ec 08             	sub    $0x8,%esp
  8004d5:	ff 75 d0             	pushl  -0x30(%ebp)
  8004d8:	57                   	push   %edi
  8004d9:	e8 86 02 00 00       	call   800764 <strnlen>
  8004de:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e1:	29 c1                	sub    %eax,%ecx
  8004e3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004e6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004e9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004f3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f5:	eb 0f                	jmp    800506 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	53                   	push   %ebx
  8004fb:	ff 75 e0             	pushl  -0x20(%ebp)
  8004fe:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800500:	83 ef 01             	sub    $0x1,%edi
  800503:	83 c4 10             	add    $0x10,%esp
  800506:	85 ff                	test   %edi,%edi
  800508:	7f ed                	jg     8004f7 <vprintfmt+0x1c0>
  80050a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80050d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800510:	85 c9                	test   %ecx,%ecx
  800512:	b8 00 00 00 00       	mov    $0x0,%eax
  800517:	0f 49 c1             	cmovns %ecx,%eax
  80051a:	29 c1                	sub    %eax,%ecx
  80051c:	89 75 08             	mov    %esi,0x8(%ebp)
  80051f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800522:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800525:	89 cb                	mov    %ecx,%ebx
  800527:	eb 4d                	jmp    800576 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800529:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80052d:	74 1b                	je     80054a <vprintfmt+0x213>
  80052f:	0f be c0             	movsbl %al,%eax
  800532:	83 e8 20             	sub    $0x20,%eax
  800535:	83 f8 5e             	cmp    $0x5e,%eax
  800538:	76 10                	jbe    80054a <vprintfmt+0x213>
					putch('?', putdat);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	ff 75 0c             	pushl  0xc(%ebp)
  800540:	6a 3f                	push   $0x3f
  800542:	ff 55 08             	call   *0x8(%ebp)
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	eb 0d                	jmp    800557 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80054a:	83 ec 08             	sub    $0x8,%esp
  80054d:	ff 75 0c             	pushl  0xc(%ebp)
  800550:	52                   	push   %edx
  800551:	ff 55 08             	call   *0x8(%ebp)
  800554:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800557:	83 eb 01             	sub    $0x1,%ebx
  80055a:	eb 1a                	jmp    800576 <vprintfmt+0x23f>
  80055c:	89 75 08             	mov    %esi,0x8(%ebp)
  80055f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800562:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800565:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800568:	eb 0c                	jmp    800576 <vprintfmt+0x23f>
  80056a:	89 75 08             	mov    %esi,0x8(%ebp)
  80056d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800570:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800573:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800576:	83 c7 01             	add    $0x1,%edi
  800579:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80057d:	0f be d0             	movsbl %al,%edx
  800580:	85 d2                	test   %edx,%edx
  800582:	74 23                	je     8005a7 <vprintfmt+0x270>
  800584:	85 f6                	test   %esi,%esi
  800586:	78 a1                	js     800529 <vprintfmt+0x1f2>
  800588:	83 ee 01             	sub    $0x1,%esi
  80058b:	79 9c                	jns    800529 <vprintfmt+0x1f2>
  80058d:	89 df                	mov    %ebx,%edi
  80058f:	8b 75 08             	mov    0x8(%ebp),%esi
  800592:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800595:	eb 18                	jmp    8005af <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800597:	83 ec 08             	sub    $0x8,%esp
  80059a:	53                   	push   %ebx
  80059b:	6a 20                	push   $0x20
  80059d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059f:	83 ef 01             	sub    $0x1,%edi
  8005a2:	83 c4 10             	add    $0x10,%esp
  8005a5:	eb 08                	jmp    8005af <vprintfmt+0x278>
  8005a7:	89 df                	mov    %ebx,%edi
  8005a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005af:	85 ff                	test   %edi,%edi
  8005b1:	7f e4                	jg     800597 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b6:	e9 a2 fd ff ff       	jmp    80035d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005bb:	83 fa 01             	cmp    $0x1,%edx
  8005be:	7e 16                	jle    8005d6 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8d 50 08             	lea    0x8(%eax),%edx
  8005c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c9:	8b 50 04             	mov    0x4(%eax),%edx
  8005cc:	8b 00                	mov    (%eax),%eax
  8005ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d4:	eb 32                	jmp    800608 <vprintfmt+0x2d1>
	else if (lflag)
  8005d6:	85 d2                	test   %edx,%edx
  8005d8:	74 18                	je     8005f2 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	8d 50 04             	lea    0x4(%eax),%edx
  8005e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e3:	8b 00                	mov    (%eax),%eax
  8005e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e8:	89 c1                	mov    %eax,%ecx
  8005ea:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ed:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f0:	eb 16                	jmp    800608 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8d 50 04             	lea    0x4(%eax),%edx
  8005f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fb:	8b 00                	mov    (%eax),%eax
  8005fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800600:	89 c1                	mov    %eax,%ecx
  800602:	c1 f9 1f             	sar    $0x1f,%ecx
  800605:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800608:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80060b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80060e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800613:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800617:	79 74                	jns    80068d <vprintfmt+0x356>
				putch('-', putdat);
  800619:	83 ec 08             	sub    $0x8,%esp
  80061c:	53                   	push   %ebx
  80061d:	6a 2d                	push   $0x2d
  80061f:	ff d6                	call   *%esi
				num = -(long long) num;
  800621:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800624:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800627:	f7 d8                	neg    %eax
  800629:	83 d2 00             	adc    $0x0,%edx
  80062c:	f7 da                	neg    %edx
  80062e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800631:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800636:	eb 55                	jmp    80068d <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800638:	8d 45 14             	lea    0x14(%ebp),%eax
  80063b:	e8 83 fc ff ff       	call   8002c3 <getuint>
			base = 10;
  800640:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800645:	eb 46                	jmp    80068d <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800647:	8d 45 14             	lea    0x14(%ebp),%eax
  80064a:	e8 74 fc ff ff       	call   8002c3 <getuint>
			base = 8;
  80064f:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800654:	eb 37                	jmp    80068d <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	53                   	push   %ebx
  80065a:	6a 30                	push   $0x30
  80065c:	ff d6                	call   *%esi
			putch('x', putdat);
  80065e:	83 c4 08             	add    $0x8,%esp
  800661:	53                   	push   %ebx
  800662:	6a 78                	push   $0x78
  800664:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8d 50 04             	lea    0x4(%eax),%edx
  80066c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80066f:	8b 00                	mov    (%eax),%eax
  800671:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800676:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800679:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80067e:	eb 0d                	jmp    80068d <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800680:	8d 45 14             	lea    0x14(%ebp),%eax
  800683:	e8 3b fc ff ff       	call   8002c3 <getuint>
			base = 16;
  800688:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80068d:	83 ec 0c             	sub    $0xc,%esp
  800690:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800694:	57                   	push   %edi
  800695:	ff 75 e0             	pushl  -0x20(%ebp)
  800698:	51                   	push   %ecx
  800699:	52                   	push   %edx
  80069a:	50                   	push   %eax
  80069b:	89 da                	mov    %ebx,%edx
  80069d:	89 f0                	mov    %esi,%eax
  80069f:	e8 70 fb ff ff       	call   800214 <printnum>
			break;
  8006a4:	83 c4 20             	add    $0x20,%esp
  8006a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006aa:	e9 ae fc ff ff       	jmp    80035d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	51                   	push   %ecx
  8006b4:	ff d6                	call   *%esi
			break;
  8006b6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006bc:	e9 9c fc ff ff       	jmp    80035d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006c1:	83 ec 08             	sub    $0x8,%esp
  8006c4:	53                   	push   %ebx
  8006c5:	6a 25                	push   $0x25
  8006c7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c9:	83 c4 10             	add    $0x10,%esp
  8006cc:	eb 03                	jmp    8006d1 <vprintfmt+0x39a>
  8006ce:	83 ef 01             	sub    $0x1,%edi
  8006d1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006d5:	75 f7                	jne    8006ce <vprintfmt+0x397>
  8006d7:	e9 81 fc ff ff       	jmp    80035d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006df:	5b                   	pop    %ebx
  8006e0:	5e                   	pop    %esi
  8006e1:	5f                   	pop    %edi
  8006e2:	5d                   	pop    %ebp
  8006e3:	c3                   	ret    

008006e4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	83 ec 18             	sub    $0x18,%esp
  8006ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ed:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800701:	85 c0                	test   %eax,%eax
  800703:	74 26                	je     80072b <vsnprintf+0x47>
  800705:	85 d2                	test   %edx,%edx
  800707:	7e 22                	jle    80072b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800709:	ff 75 14             	pushl  0x14(%ebp)
  80070c:	ff 75 10             	pushl  0x10(%ebp)
  80070f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800712:	50                   	push   %eax
  800713:	68 fd 02 80 00       	push   $0x8002fd
  800718:	e8 1a fc ff ff       	call   800337 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80071d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800720:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800723:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800726:	83 c4 10             	add    $0x10,%esp
  800729:	eb 05                	jmp    800730 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80072b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800730:	c9                   	leave  
  800731:	c3                   	ret    

00800732 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800738:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80073b:	50                   	push   %eax
  80073c:	ff 75 10             	pushl  0x10(%ebp)
  80073f:	ff 75 0c             	pushl  0xc(%ebp)
  800742:	ff 75 08             	pushl  0x8(%ebp)
  800745:	e8 9a ff ff ff       	call   8006e4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80074a:	c9                   	leave  
  80074b:	c3                   	ret    

0080074c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800752:	b8 00 00 00 00       	mov    $0x0,%eax
  800757:	eb 03                	jmp    80075c <strlen+0x10>
		n++;
  800759:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80075c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800760:	75 f7                	jne    800759 <strlen+0xd>
		n++;
	return n;
}
  800762:	5d                   	pop    %ebp
  800763:	c3                   	ret    

00800764 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80076a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076d:	ba 00 00 00 00       	mov    $0x0,%edx
  800772:	eb 03                	jmp    800777 <strnlen+0x13>
		n++;
  800774:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800777:	39 c2                	cmp    %eax,%edx
  800779:	74 08                	je     800783 <strnlen+0x1f>
  80077b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80077f:	75 f3                	jne    800774 <strnlen+0x10>
  800781:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800783:	5d                   	pop    %ebp
  800784:	c3                   	ret    

00800785 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	53                   	push   %ebx
  800789:	8b 45 08             	mov    0x8(%ebp),%eax
  80078c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80078f:	89 c2                	mov    %eax,%edx
  800791:	83 c2 01             	add    $0x1,%edx
  800794:	83 c1 01             	add    $0x1,%ecx
  800797:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80079b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80079e:	84 db                	test   %bl,%bl
  8007a0:	75 ef                	jne    800791 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007a2:	5b                   	pop    %ebx
  8007a3:	5d                   	pop    %ebp
  8007a4:	c3                   	ret    

008007a5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	53                   	push   %ebx
  8007a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ac:	53                   	push   %ebx
  8007ad:	e8 9a ff ff ff       	call   80074c <strlen>
  8007b2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007b5:	ff 75 0c             	pushl  0xc(%ebp)
  8007b8:	01 d8                	add    %ebx,%eax
  8007ba:	50                   	push   %eax
  8007bb:	e8 c5 ff ff ff       	call   800785 <strcpy>
	return dst;
}
  8007c0:	89 d8                	mov    %ebx,%eax
  8007c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c5:	c9                   	leave  
  8007c6:	c3                   	ret    

008007c7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	56                   	push   %esi
  8007cb:	53                   	push   %ebx
  8007cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d2:	89 f3                	mov    %esi,%ebx
  8007d4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d7:	89 f2                	mov    %esi,%edx
  8007d9:	eb 0f                	jmp    8007ea <strncpy+0x23>
		*dst++ = *src;
  8007db:	83 c2 01             	add    $0x1,%edx
  8007de:	0f b6 01             	movzbl (%ecx),%eax
  8007e1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e4:	80 39 01             	cmpb   $0x1,(%ecx)
  8007e7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ea:	39 da                	cmp    %ebx,%edx
  8007ec:	75 ed                	jne    8007db <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ee:	89 f0                	mov    %esi,%eax
  8007f0:	5b                   	pop    %ebx
  8007f1:	5e                   	pop    %esi
  8007f2:	5d                   	pop    %ebp
  8007f3:	c3                   	ret    

008007f4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	56                   	push   %esi
  8007f8:	53                   	push   %ebx
  8007f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ff:	8b 55 10             	mov    0x10(%ebp),%edx
  800802:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800804:	85 d2                	test   %edx,%edx
  800806:	74 21                	je     800829 <strlcpy+0x35>
  800808:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80080c:	89 f2                	mov    %esi,%edx
  80080e:	eb 09                	jmp    800819 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800810:	83 c2 01             	add    $0x1,%edx
  800813:	83 c1 01             	add    $0x1,%ecx
  800816:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800819:	39 c2                	cmp    %eax,%edx
  80081b:	74 09                	je     800826 <strlcpy+0x32>
  80081d:	0f b6 19             	movzbl (%ecx),%ebx
  800820:	84 db                	test   %bl,%bl
  800822:	75 ec                	jne    800810 <strlcpy+0x1c>
  800824:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800826:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800829:	29 f0                	sub    %esi,%eax
}
  80082b:	5b                   	pop    %ebx
  80082c:	5e                   	pop    %esi
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800835:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800838:	eb 06                	jmp    800840 <strcmp+0x11>
		p++, q++;
  80083a:	83 c1 01             	add    $0x1,%ecx
  80083d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800840:	0f b6 01             	movzbl (%ecx),%eax
  800843:	84 c0                	test   %al,%al
  800845:	74 04                	je     80084b <strcmp+0x1c>
  800847:	3a 02                	cmp    (%edx),%al
  800849:	74 ef                	je     80083a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80084b:	0f b6 c0             	movzbl %al,%eax
  80084e:	0f b6 12             	movzbl (%edx),%edx
  800851:	29 d0                	sub    %edx,%eax
}
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	53                   	push   %ebx
  800859:	8b 45 08             	mov    0x8(%ebp),%eax
  80085c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085f:	89 c3                	mov    %eax,%ebx
  800861:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800864:	eb 06                	jmp    80086c <strncmp+0x17>
		n--, p++, q++;
  800866:	83 c0 01             	add    $0x1,%eax
  800869:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80086c:	39 d8                	cmp    %ebx,%eax
  80086e:	74 15                	je     800885 <strncmp+0x30>
  800870:	0f b6 08             	movzbl (%eax),%ecx
  800873:	84 c9                	test   %cl,%cl
  800875:	74 04                	je     80087b <strncmp+0x26>
  800877:	3a 0a                	cmp    (%edx),%cl
  800879:	74 eb                	je     800866 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80087b:	0f b6 00             	movzbl (%eax),%eax
  80087e:	0f b6 12             	movzbl (%edx),%edx
  800881:	29 d0                	sub    %edx,%eax
  800883:	eb 05                	jmp    80088a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800885:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80088a:	5b                   	pop    %ebx
  80088b:	5d                   	pop    %ebp
  80088c:	c3                   	ret    

0080088d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	8b 45 08             	mov    0x8(%ebp),%eax
  800893:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800897:	eb 07                	jmp    8008a0 <strchr+0x13>
		if (*s == c)
  800899:	38 ca                	cmp    %cl,%dl
  80089b:	74 0f                	je     8008ac <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80089d:	83 c0 01             	add    $0x1,%eax
  8008a0:	0f b6 10             	movzbl (%eax),%edx
  8008a3:	84 d2                	test   %dl,%dl
  8008a5:	75 f2                	jne    800899 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ac:	5d                   	pop    %ebp
  8008ad:	c3                   	ret    

008008ae <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b8:	eb 03                	jmp    8008bd <strfind+0xf>
  8008ba:	83 c0 01             	add    $0x1,%eax
  8008bd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008c0:	38 ca                	cmp    %cl,%dl
  8008c2:	74 04                	je     8008c8 <strfind+0x1a>
  8008c4:	84 d2                	test   %dl,%dl
  8008c6:	75 f2                	jne    8008ba <strfind+0xc>
			break;
	return (char *) s;
}
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	57                   	push   %edi
  8008ce:	56                   	push   %esi
  8008cf:	53                   	push   %ebx
  8008d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d6:	85 c9                	test   %ecx,%ecx
  8008d8:	74 36                	je     800910 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008da:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e0:	75 28                	jne    80090a <memset+0x40>
  8008e2:	f6 c1 03             	test   $0x3,%cl
  8008e5:	75 23                	jne    80090a <memset+0x40>
		c &= 0xFF;
  8008e7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008eb:	89 d3                	mov    %edx,%ebx
  8008ed:	c1 e3 08             	shl    $0x8,%ebx
  8008f0:	89 d6                	mov    %edx,%esi
  8008f2:	c1 e6 18             	shl    $0x18,%esi
  8008f5:	89 d0                	mov    %edx,%eax
  8008f7:	c1 e0 10             	shl    $0x10,%eax
  8008fa:	09 f0                	or     %esi,%eax
  8008fc:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008fe:	89 d8                	mov    %ebx,%eax
  800900:	09 d0                	or     %edx,%eax
  800902:	c1 e9 02             	shr    $0x2,%ecx
  800905:	fc                   	cld    
  800906:	f3 ab                	rep stos %eax,%es:(%edi)
  800908:	eb 06                	jmp    800910 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80090a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090d:	fc                   	cld    
  80090e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800910:	89 f8                	mov    %edi,%eax
  800912:	5b                   	pop    %ebx
  800913:	5e                   	pop    %esi
  800914:	5f                   	pop    %edi
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	57                   	push   %edi
  80091b:	56                   	push   %esi
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800922:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800925:	39 c6                	cmp    %eax,%esi
  800927:	73 35                	jae    80095e <memmove+0x47>
  800929:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80092c:	39 d0                	cmp    %edx,%eax
  80092e:	73 2e                	jae    80095e <memmove+0x47>
		s += n;
		d += n;
  800930:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800933:	89 d6                	mov    %edx,%esi
  800935:	09 fe                	or     %edi,%esi
  800937:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80093d:	75 13                	jne    800952 <memmove+0x3b>
  80093f:	f6 c1 03             	test   $0x3,%cl
  800942:	75 0e                	jne    800952 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800944:	83 ef 04             	sub    $0x4,%edi
  800947:	8d 72 fc             	lea    -0x4(%edx),%esi
  80094a:	c1 e9 02             	shr    $0x2,%ecx
  80094d:	fd                   	std    
  80094e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800950:	eb 09                	jmp    80095b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800952:	83 ef 01             	sub    $0x1,%edi
  800955:	8d 72 ff             	lea    -0x1(%edx),%esi
  800958:	fd                   	std    
  800959:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80095b:	fc                   	cld    
  80095c:	eb 1d                	jmp    80097b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095e:	89 f2                	mov    %esi,%edx
  800960:	09 c2                	or     %eax,%edx
  800962:	f6 c2 03             	test   $0x3,%dl
  800965:	75 0f                	jne    800976 <memmove+0x5f>
  800967:	f6 c1 03             	test   $0x3,%cl
  80096a:	75 0a                	jne    800976 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80096c:	c1 e9 02             	shr    $0x2,%ecx
  80096f:	89 c7                	mov    %eax,%edi
  800971:	fc                   	cld    
  800972:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800974:	eb 05                	jmp    80097b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800976:	89 c7                	mov    %eax,%edi
  800978:	fc                   	cld    
  800979:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80097b:	5e                   	pop    %esi
  80097c:	5f                   	pop    %edi
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800982:	ff 75 10             	pushl  0x10(%ebp)
  800985:	ff 75 0c             	pushl  0xc(%ebp)
  800988:	ff 75 08             	pushl  0x8(%ebp)
  80098b:	e8 87 ff ff ff       	call   800917 <memmove>
}
  800990:	c9                   	leave  
  800991:	c3                   	ret    

00800992 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	56                   	push   %esi
  800996:	53                   	push   %ebx
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099d:	89 c6                	mov    %eax,%esi
  80099f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a2:	eb 1a                	jmp    8009be <memcmp+0x2c>
		if (*s1 != *s2)
  8009a4:	0f b6 08             	movzbl (%eax),%ecx
  8009a7:	0f b6 1a             	movzbl (%edx),%ebx
  8009aa:	38 d9                	cmp    %bl,%cl
  8009ac:	74 0a                	je     8009b8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009ae:	0f b6 c1             	movzbl %cl,%eax
  8009b1:	0f b6 db             	movzbl %bl,%ebx
  8009b4:	29 d8                	sub    %ebx,%eax
  8009b6:	eb 0f                	jmp    8009c7 <memcmp+0x35>
		s1++, s2++;
  8009b8:	83 c0 01             	add    $0x1,%eax
  8009bb:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009be:	39 f0                	cmp    %esi,%eax
  8009c0:	75 e2                	jne    8009a4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c7:	5b                   	pop    %ebx
  8009c8:	5e                   	pop    %esi
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	53                   	push   %ebx
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009d2:	89 c1                	mov    %eax,%ecx
  8009d4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009db:	eb 0a                	jmp    8009e7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009dd:	0f b6 10             	movzbl (%eax),%edx
  8009e0:	39 da                	cmp    %ebx,%edx
  8009e2:	74 07                	je     8009eb <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e4:	83 c0 01             	add    $0x1,%eax
  8009e7:	39 c8                	cmp    %ecx,%eax
  8009e9:	72 f2                	jb     8009dd <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009eb:	5b                   	pop    %ebx
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	57                   	push   %edi
  8009f2:	56                   	push   %esi
  8009f3:	53                   	push   %ebx
  8009f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009fa:	eb 03                	jmp    8009ff <strtol+0x11>
		s++;
  8009fc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ff:	0f b6 01             	movzbl (%ecx),%eax
  800a02:	3c 20                	cmp    $0x20,%al
  800a04:	74 f6                	je     8009fc <strtol+0xe>
  800a06:	3c 09                	cmp    $0x9,%al
  800a08:	74 f2                	je     8009fc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a0a:	3c 2b                	cmp    $0x2b,%al
  800a0c:	75 0a                	jne    800a18 <strtol+0x2a>
		s++;
  800a0e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a11:	bf 00 00 00 00       	mov    $0x0,%edi
  800a16:	eb 11                	jmp    800a29 <strtol+0x3b>
  800a18:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a1d:	3c 2d                	cmp    $0x2d,%al
  800a1f:	75 08                	jne    800a29 <strtol+0x3b>
		s++, neg = 1;
  800a21:	83 c1 01             	add    $0x1,%ecx
  800a24:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a29:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a2f:	75 15                	jne    800a46 <strtol+0x58>
  800a31:	80 39 30             	cmpb   $0x30,(%ecx)
  800a34:	75 10                	jne    800a46 <strtol+0x58>
  800a36:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a3a:	75 7c                	jne    800ab8 <strtol+0xca>
		s += 2, base = 16;
  800a3c:	83 c1 02             	add    $0x2,%ecx
  800a3f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a44:	eb 16                	jmp    800a5c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a46:	85 db                	test   %ebx,%ebx
  800a48:	75 12                	jne    800a5c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a4a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a52:	75 08                	jne    800a5c <strtol+0x6e>
		s++, base = 8;
  800a54:	83 c1 01             	add    $0x1,%ecx
  800a57:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a61:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a64:	0f b6 11             	movzbl (%ecx),%edx
  800a67:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a6a:	89 f3                	mov    %esi,%ebx
  800a6c:	80 fb 09             	cmp    $0x9,%bl
  800a6f:	77 08                	ja     800a79 <strtol+0x8b>
			dig = *s - '0';
  800a71:	0f be d2             	movsbl %dl,%edx
  800a74:	83 ea 30             	sub    $0x30,%edx
  800a77:	eb 22                	jmp    800a9b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a79:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a7c:	89 f3                	mov    %esi,%ebx
  800a7e:	80 fb 19             	cmp    $0x19,%bl
  800a81:	77 08                	ja     800a8b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a83:	0f be d2             	movsbl %dl,%edx
  800a86:	83 ea 57             	sub    $0x57,%edx
  800a89:	eb 10                	jmp    800a9b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a8b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a8e:	89 f3                	mov    %esi,%ebx
  800a90:	80 fb 19             	cmp    $0x19,%bl
  800a93:	77 16                	ja     800aab <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a95:	0f be d2             	movsbl %dl,%edx
  800a98:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a9b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a9e:	7d 0b                	jge    800aab <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aa0:	83 c1 01             	add    $0x1,%ecx
  800aa3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aa7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aa9:	eb b9                	jmp    800a64 <strtol+0x76>

	if (endptr)
  800aab:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aaf:	74 0d                	je     800abe <strtol+0xd0>
		*endptr = (char *) s;
  800ab1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab4:	89 0e                	mov    %ecx,(%esi)
  800ab6:	eb 06                	jmp    800abe <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab8:	85 db                	test   %ebx,%ebx
  800aba:	74 98                	je     800a54 <strtol+0x66>
  800abc:	eb 9e                	jmp    800a5c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800abe:	89 c2                	mov    %eax,%edx
  800ac0:	f7 da                	neg    %edx
  800ac2:	85 ff                	test   %edi,%edi
  800ac4:	0f 45 c2             	cmovne %edx,%eax
}
  800ac7:	5b                   	pop    %ebx
  800ac8:	5e                   	pop    %esi
  800ac9:	5f                   	pop    %edi
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	57                   	push   %edi
  800ad0:	56                   	push   %esi
  800ad1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ada:	8b 55 08             	mov    0x8(%ebp),%edx
  800add:	89 c3                	mov    %eax,%ebx
  800adf:	89 c7                	mov    %eax,%edi
  800ae1:	89 c6                	mov    %eax,%esi
  800ae3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5f                   	pop    %edi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <sys_cgetc>:

int
sys_cgetc(void)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	57                   	push   %edi
  800aee:	56                   	push   %esi
  800aef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af0:	ba 00 00 00 00       	mov    $0x0,%edx
  800af5:	b8 01 00 00 00       	mov    $0x1,%eax
  800afa:	89 d1                	mov    %edx,%ecx
  800afc:	89 d3                	mov    %edx,%ebx
  800afe:	89 d7                	mov    %edx,%edi
  800b00:	89 d6                	mov    %edx,%esi
  800b02:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5f                   	pop    %edi
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    

00800b09 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	57                   	push   %edi
  800b0d:	56                   	push   %esi
  800b0e:	53                   	push   %ebx
  800b0f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b12:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b17:	b8 03 00 00 00       	mov    $0x3,%eax
  800b1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1f:	89 cb                	mov    %ecx,%ebx
  800b21:	89 cf                	mov    %ecx,%edi
  800b23:	89 ce                	mov    %ecx,%esi
  800b25:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b27:	85 c0                	test   %eax,%eax
  800b29:	7e 17                	jle    800b42 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2b:	83 ec 0c             	sub    $0xc,%esp
  800b2e:	50                   	push   %eax
  800b2f:	6a 03                	push   $0x3
  800b31:	68 1f 29 80 00       	push   $0x80291f
  800b36:	6a 23                	push   $0x23
  800b38:	68 3c 29 80 00       	push   $0x80293c
  800b3d:	e8 82 16 00 00       	call   8021c4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b45:	5b                   	pop    %ebx
  800b46:	5e                   	pop    %esi
  800b47:	5f                   	pop    %edi
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	57                   	push   %edi
  800b4e:	56                   	push   %esi
  800b4f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b50:	ba 00 00 00 00       	mov    $0x0,%edx
  800b55:	b8 02 00 00 00       	mov    $0x2,%eax
  800b5a:	89 d1                	mov    %edx,%ecx
  800b5c:	89 d3                	mov    %edx,%ebx
  800b5e:	89 d7                	mov    %edx,%edi
  800b60:	89 d6                	mov    %edx,%esi
  800b62:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <sys_yield>:

void
sys_yield(void)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	57                   	push   %edi
  800b6d:	56                   	push   %esi
  800b6e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b74:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b79:	89 d1                	mov    %edx,%ecx
  800b7b:	89 d3                	mov    %edx,%ebx
  800b7d:	89 d7                	mov    %edx,%edi
  800b7f:	89 d6                	mov    %edx,%esi
  800b81:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b83:	5b                   	pop    %ebx
  800b84:	5e                   	pop    %esi
  800b85:	5f                   	pop    %edi
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    

00800b88 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	57                   	push   %edi
  800b8c:	56                   	push   %esi
  800b8d:	53                   	push   %ebx
  800b8e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b91:	be 00 00 00 00       	mov    $0x0,%esi
  800b96:	b8 04 00 00 00       	mov    $0x4,%eax
  800b9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba4:	89 f7                	mov    %esi,%edi
  800ba6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba8:	85 c0                	test   %eax,%eax
  800baa:	7e 17                	jle    800bc3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bac:	83 ec 0c             	sub    $0xc,%esp
  800baf:	50                   	push   %eax
  800bb0:	6a 04                	push   $0x4
  800bb2:	68 1f 29 80 00       	push   $0x80291f
  800bb7:	6a 23                	push   $0x23
  800bb9:	68 3c 29 80 00       	push   $0x80293c
  800bbe:	e8 01 16 00 00       	call   8021c4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc6:	5b                   	pop    %ebx
  800bc7:	5e                   	pop    %esi
  800bc8:	5f                   	pop    %edi
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	57                   	push   %edi
  800bcf:	56                   	push   %esi
  800bd0:	53                   	push   %ebx
  800bd1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd4:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800be5:	8b 75 18             	mov    0x18(%ebp),%esi
  800be8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bea:	85 c0                	test   %eax,%eax
  800bec:	7e 17                	jle    800c05 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bee:	83 ec 0c             	sub    $0xc,%esp
  800bf1:	50                   	push   %eax
  800bf2:	6a 05                	push   $0x5
  800bf4:	68 1f 29 80 00       	push   $0x80291f
  800bf9:	6a 23                	push   $0x23
  800bfb:	68 3c 29 80 00       	push   $0x80293c
  800c00:	e8 bf 15 00 00       	call   8021c4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c08:	5b                   	pop    %ebx
  800c09:	5e                   	pop    %esi
  800c0a:	5f                   	pop    %edi
  800c0b:	5d                   	pop    %ebp
  800c0c:	c3                   	ret    

00800c0d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	57                   	push   %edi
  800c11:	56                   	push   %esi
  800c12:	53                   	push   %ebx
  800c13:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c1b:	b8 06 00 00 00       	mov    $0x6,%eax
  800c20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c23:	8b 55 08             	mov    0x8(%ebp),%edx
  800c26:	89 df                	mov    %ebx,%edi
  800c28:	89 de                	mov    %ebx,%esi
  800c2a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c2c:	85 c0                	test   %eax,%eax
  800c2e:	7e 17                	jle    800c47 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c30:	83 ec 0c             	sub    $0xc,%esp
  800c33:	50                   	push   %eax
  800c34:	6a 06                	push   $0x6
  800c36:	68 1f 29 80 00       	push   $0x80291f
  800c3b:	6a 23                	push   $0x23
  800c3d:	68 3c 29 80 00       	push   $0x80293c
  800c42:	e8 7d 15 00 00       	call   8021c4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800c58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c65:	8b 55 08             	mov    0x8(%ebp),%edx
  800c68:	89 df                	mov    %ebx,%edi
  800c6a:	89 de                	mov    %ebx,%esi
  800c6c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c6e:	85 c0                	test   %eax,%eax
  800c70:	7e 17                	jle    800c89 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c72:	83 ec 0c             	sub    $0xc,%esp
  800c75:	50                   	push   %eax
  800c76:	6a 08                	push   $0x8
  800c78:	68 1f 29 80 00       	push   $0x80291f
  800c7d:	6a 23                	push   $0x23
  800c7f:	68 3c 29 80 00       	push   $0x80293c
  800c84:	e8 3b 15 00 00       	call   8021c4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8c:	5b                   	pop    %ebx
  800c8d:	5e                   	pop    %esi
  800c8e:	5f                   	pop    %edi
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    

00800c91 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800c9f:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800cb2:	7e 17                	jle    800ccb <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb4:	83 ec 0c             	sub    $0xc,%esp
  800cb7:	50                   	push   %eax
  800cb8:	6a 09                	push   $0x9
  800cba:	68 1f 29 80 00       	push   $0x80291f
  800cbf:	6a 23                	push   $0x23
  800cc1:	68 3c 29 80 00       	push   $0x80293c
  800cc6:	e8 f9 14 00 00       	call   8021c4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ccb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cce:	5b                   	pop    %ebx
  800ccf:	5e                   	pop    %esi
  800cd0:	5f                   	pop    %edi
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    

00800cd3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800ce1:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800cf4:	7e 17                	jle    800d0d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf6:	83 ec 0c             	sub    $0xc,%esp
  800cf9:	50                   	push   %eax
  800cfa:	6a 0a                	push   $0xa
  800cfc:	68 1f 29 80 00       	push   $0x80291f
  800d01:	6a 23                	push   $0x23
  800d03:	68 3c 29 80 00       	push   $0x80293c
  800d08:	e8 b7 14 00 00       	call   8021c4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    

00800d15 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	57                   	push   %edi
  800d19:	56                   	push   %esi
  800d1a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1b:	be 00 00 00 00       	mov    $0x0,%esi
  800d20:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d28:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d31:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5f                   	pop    %edi
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    

00800d38 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	57                   	push   %edi
  800d3c:	56                   	push   %esi
  800d3d:	53                   	push   %ebx
  800d3e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d41:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d46:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4e:	89 cb                	mov    %ecx,%ebx
  800d50:	89 cf                	mov    %ecx,%edi
  800d52:	89 ce                	mov    %ecx,%esi
  800d54:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d56:	85 c0                	test   %eax,%eax
  800d58:	7e 17                	jle    800d71 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5a:	83 ec 0c             	sub    $0xc,%esp
  800d5d:	50                   	push   %eax
  800d5e:	6a 0d                	push   $0xd
  800d60:	68 1f 29 80 00       	push   $0x80291f
  800d65:	6a 23                	push   $0x23
  800d67:	68 3c 29 80 00       	push   $0x80293c
  800d6c:	e8 53 14 00 00       	call   8021c4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d74:	5b                   	pop    %ebx
  800d75:	5e                   	pop    %esi
  800d76:	5f                   	pop    %edi
  800d77:	5d                   	pop    %ebp
  800d78:	c3                   	ret    

00800d79 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	57                   	push   %edi
  800d7d:	56                   	push   %esi
  800d7e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d84:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d89:	89 d1                	mov    %edx,%ecx
  800d8b:	89 d3                	mov    %edx,%ebx
  800d8d:	89 d7                	mov    %edx,%edi
  800d8f:	89 d6                	mov    %edx,%esi
  800d91:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d93:	5b                   	pop    %ebx
  800d94:	5e                   	pop    %esi
  800d95:	5f                   	pop    %edi
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    

00800d98 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	57                   	push   %edi
  800d9c:	56                   	push   %esi
  800d9d:	53                   	push   %ebx
  800d9e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da6:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dae:	8b 55 08             	mov    0x8(%ebp),%edx
  800db1:	89 df                	mov    %ebx,%edi
  800db3:	89 de                	mov    %ebx,%esi
  800db5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800db7:	85 c0                	test   %eax,%eax
  800db9:	7e 17                	jle    800dd2 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbb:	83 ec 0c             	sub    $0xc,%esp
  800dbe:	50                   	push   %eax
  800dbf:	6a 0f                	push   $0xf
  800dc1:	68 1f 29 80 00       	push   $0x80291f
  800dc6:	6a 23                	push   $0x23
  800dc8:	68 3c 29 80 00       	push   $0x80293c
  800dcd:	e8 f2 13 00 00       	call   8021c4 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800dd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd5:	5b                   	pop    %ebx
  800dd6:	5e                   	pop    %esi
  800dd7:	5f                   	pop    %edi
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	57                   	push   %edi
  800dde:	56                   	push   %esi
  800ddf:	53                   	push   %ebx
  800de0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de8:	b8 10 00 00 00       	mov    $0x10,%eax
  800ded:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df0:	8b 55 08             	mov    0x8(%ebp),%edx
  800df3:	89 df                	mov    %ebx,%edi
  800df5:	89 de                	mov    %ebx,%esi
  800df7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800df9:	85 c0                	test   %eax,%eax
  800dfb:	7e 17                	jle    800e14 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfd:	83 ec 0c             	sub    $0xc,%esp
  800e00:	50                   	push   %eax
  800e01:	6a 10                	push   $0x10
  800e03:	68 1f 29 80 00       	push   $0x80291f
  800e08:	6a 23                	push   $0x23
  800e0a:	68 3c 29 80 00       	push   $0x80293c
  800e0f:	e8 b0 13 00 00       	call   8021c4 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  800e14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e17:	5b                   	pop    %ebx
  800e18:	5e                   	pop    %esi
  800e19:	5f                   	pop    %edi
  800e1a:	5d                   	pop    %ebp
  800e1b:	c3                   	ret    

00800e1c <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e25:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800e28:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800e2a:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800e2d:	83 3a 01             	cmpl   $0x1,(%edx)
  800e30:	7e 09                	jle    800e3b <argstart+0x1f>
  800e32:	ba f1 25 80 00       	mov    $0x8025f1,%edx
  800e37:	85 c9                	test   %ecx,%ecx
  800e39:	75 05                	jne    800e40 <argstart+0x24>
  800e3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e40:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800e43:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <argnext>:

int
argnext(struct Argstate *args)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	53                   	push   %ebx
  800e50:	83 ec 04             	sub    $0x4,%esp
  800e53:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800e56:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800e5d:	8b 43 08             	mov    0x8(%ebx),%eax
  800e60:	85 c0                	test   %eax,%eax
  800e62:	74 6f                	je     800ed3 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  800e64:	80 38 00             	cmpb   $0x0,(%eax)
  800e67:	75 4e                	jne    800eb7 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800e69:	8b 0b                	mov    (%ebx),%ecx
  800e6b:	83 39 01             	cmpl   $0x1,(%ecx)
  800e6e:	74 55                	je     800ec5 <argnext+0x79>
		    || args->argv[1][0] != '-'
  800e70:	8b 53 04             	mov    0x4(%ebx),%edx
  800e73:	8b 42 04             	mov    0x4(%edx),%eax
  800e76:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e79:	75 4a                	jne    800ec5 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  800e7b:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e7f:	74 44                	je     800ec5 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800e81:	83 c0 01             	add    $0x1,%eax
  800e84:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800e87:	83 ec 04             	sub    $0x4,%esp
  800e8a:	8b 01                	mov    (%ecx),%eax
  800e8c:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800e93:	50                   	push   %eax
  800e94:	8d 42 08             	lea    0x8(%edx),%eax
  800e97:	50                   	push   %eax
  800e98:	83 c2 04             	add    $0x4,%edx
  800e9b:	52                   	push   %edx
  800e9c:	e8 76 fa ff ff       	call   800917 <memmove>
		(*args->argc)--;
  800ea1:	8b 03                	mov    (%ebx),%eax
  800ea3:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800ea6:	8b 43 08             	mov    0x8(%ebx),%eax
  800ea9:	83 c4 10             	add    $0x10,%esp
  800eac:	80 38 2d             	cmpb   $0x2d,(%eax)
  800eaf:	75 06                	jne    800eb7 <argnext+0x6b>
  800eb1:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800eb5:	74 0e                	je     800ec5 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800eb7:	8b 53 08             	mov    0x8(%ebx),%edx
  800eba:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800ebd:	83 c2 01             	add    $0x1,%edx
  800ec0:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800ec3:	eb 13                	jmp    800ed8 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  800ec5:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800ecc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800ed1:	eb 05                	jmp    800ed8 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  800ed3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800ed8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800edb:	c9                   	leave  
  800edc:	c3                   	ret    

00800edd <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
  800ee0:	53                   	push   %ebx
  800ee1:	83 ec 04             	sub    $0x4,%esp
  800ee4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800ee7:	8b 43 08             	mov    0x8(%ebx),%eax
  800eea:	85 c0                	test   %eax,%eax
  800eec:	74 58                	je     800f46 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  800eee:	80 38 00             	cmpb   $0x0,(%eax)
  800ef1:	74 0c                	je     800eff <argnextvalue+0x22>
		args->argvalue = args->curarg;
  800ef3:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800ef6:	c7 43 08 f1 25 80 00 	movl   $0x8025f1,0x8(%ebx)
  800efd:	eb 42                	jmp    800f41 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  800eff:	8b 13                	mov    (%ebx),%edx
  800f01:	83 3a 01             	cmpl   $0x1,(%edx)
  800f04:	7e 2d                	jle    800f33 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  800f06:	8b 43 04             	mov    0x4(%ebx),%eax
  800f09:	8b 48 04             	mov    0x4(%eax),%ecx
  800f0c:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800f0f:	83 ec 04             	sub    $0x4,%esp
  800f12:	8b 12                	mov    (%edx),%edx
  800f14:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  800f1b:	52                   	push   %edx
  800f1c:	8d 50 08             	lea    0x8(%eax),%edx
  800f1f:	52                   	push   %edx
  800f20:	83 c0 04             	add    $0x4,%eax
  800f23:	50                   	push   %eax
  800f24:	e8 ee f9 ff ff       	call   800917 <memmove>
		(*args->argc)--;
  800f29:	8b 03                	mov    (%ebx),%eax
  800f2b:	83 28 01             	subl   $0x1,(%eax)
  800f2e:	83 c4 10             	add    $0x10,%esp
  800f31:	eb 0e                	jmp    800f41 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  800f33:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800f3a:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800f41:	8b 43 0c             	mov    0xc(%ebx),%eax
  800f44:	eb 05                	jmp    800f4b <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  800f46:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  800f4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f4e:	c9                   	leave  
  800f4f:	c3                   	ret    

00800f50 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800f50:	55                   	push   %ebp
  800f51:	89 e5                	mov    %esp,%ebp
  800f53:	83 ec 08             	sub    $0x8,%esp
  800f56:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800f59:	8b 51 0c             	mov    0xc(%ecx),%edx
  800f5c:	89 d0                	mov    %edx,%eax
  800f5e:	85 d2                	test   %edx,%edx
  800f60:	75 0c                	jne    800f6e <argvalue+0x1e>
  800f62:	83 ec 0c             	sub    $0xc,%esp
  800f65:	51                   	push   %ecx
  800f66:	e8 72 ff ff ff       	call   800edd <argnextvalue>
  800f6b:	83 c4 10             	add    $0x10,%esp
}
  800f6e:	c9                   	leave  
  800f6f:	c3                   	ret    

00800f70 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f73:	8b 45 08             	mov    0x8(%ebp),%eax
  800f76:	05 00 00 00 30       	add    $0x30000000,%eax
  800f7b:	c1 e8 0c             	shr    $0xc,%eax
}
  800f7e:	5d                   	pop    %ebp
  800f7f:	c3                   	ret    

00800f80 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800f83:	8b 45 08             	mov    0x8(%ebp),%eax
  800f86:	05 00 00 00 30       	add    $0x30000000,%eax
  800f8b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f90:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f95:	5d                   	pop    %ebp
  800f96:	c3                   	ret    

00800f97 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f97:	55                   	push   %ebp
  800f98:	89 e5                	mov    %esp,%ebp
  800f9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f9d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800fa2:	89 c2                	mov    %eax,%edx
  800fa4:	c1 ea 16             	shr    $0x16,%edx
  800fa7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fae:	f6 c2 01             	test   $0x1,%dl
  800fb1:	74 11                	je     800fc4 <fd_alloc+0x2d>
  800fb3:	89 c2                	mov    %eax,%edx
  800fb5:	c1 ea 0c             	shr    $0xc,%edx
  800fb8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fbf:	f6 c2 01             	test   $0x1,%dl
  800fc2:	75 09                	jne    800fcd <fd_alloc+0x36>
			*fd_store = fd;
  800fc4:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcb:	eb 17                	jmp    800fe4 <fd_alloc+0x4d>
  800fcd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800fd2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800fd7:	75 c9                	jne    800fa2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800fd9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800fdf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fe4:	5d                   	pop    %ebp
  800fe5:	c3                   	ret    

00800fe6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fe6:	55                   	push   %ebp
  800fe7:	89 e5                	mov    %esp,%ebp
  800fe9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fec:	83 f8 1f             	cmp    $0x1f,%eax
  800fef:	77 36                	ja     801027 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ff1:	c1 e0 0c             	shl    $0xc,%eax
  800ff4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ff9:	89 c2                	mov    %eax,%edx
  800ffb:	c1 ea 16             	shr    $0x16,%edx
  800ffe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801005:	f6 c2 01             	test   $0x1,%dl
  801008:	74 24                	je     80102e <fd_lookup+0x48>
  80100a:	89 c2                	mov    %eax,%edx
  80100c:	c1 ea 0c             	shr    $0xc,%edx
  80100f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801016:	f6 c2 01             	test   $0x1,%dl
  801019:	74 1a                	je     801035 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80101b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80101e:	89 02                	mov    %eax,(%edx)
	return 0;
  801020:	b8 00 00 00 00       	mov    $0x0,%eax
  801025:	eb 13                	jmp    80103a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801027:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80102c:	eb 0c                	jmp    80103a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80102e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801033:	eb 05                	jmp    80103a <fd_lookup+0x54>
  801035:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80103a:	5d                   	pop    %ebp
  80103b:	c3                   	ret    

0080103c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80103c:	55                   	push   %ebp
  80103d:	89 e5                	mov    %esp,%ebp
  80103f:	83 ec 08             	sub    $0x8,%esp
  801042:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801045:	ba c8 29 80 00       	mov    $0x8029c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80104a:	eb 13                	jmp    80105f <dev_lookup+0x23>
  80104c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80104f:	39 08                	cmp    %ecx,(%eax)
  801051:	75 0c                	jne    80105f <dev_lookup+0x23>
			*dev = devtab[i];
  801053:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801056:	89 01                	mov    %eax,(%ecx)
			return 0;
  801058:	b8 00 00 00 00       	mov    $0x0,%eax
  80105d:	eb 2e                	jmp    80108d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80105f:	8b 02                	mov    (%edx),%eax
  801061:	85 c0                	test   %eax,%eax
  801063:	75 e7                	jne    80104c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801065:	a1 08 40 80 00       	mov    0x804008,%eax
  80106a:	8b 40 48             	mov    0x48(%eax),%eax
  80106d:	83 ec 04             	sub    $0x4,%esp
  801070:	51                   	push   %ecx
  801071:	50                   	push   %eax
  801072:	68 4c 29 80 00       	push   $0x80294c
  801077:	e8 84 f1 ff ff       	call   800200 <cprintf>
	*dev = 0;
  80107c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80107f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801085:	83 c4 10             	add    $0x10,%esp
  801088:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80108d:	c9                   	leave  
  80108e:	c3                   	ret    

0080108f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80108f:	55                   	push   %ebp
  801090:	89 e5                	mov    %esp,%ebp
  801092:	56                   	push   %esi
  801093:	53                   	push   %ebx
  801094:	83 ec 10             	sub    $0x10,%esp
  801097:	8b 75 08             	mov    0x8(%ebp),%esi
  80109a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80109d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010a0:	50                   	push   %eax
  8010a1:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8010a7:	c1 e8 0c             	shr    $0xc,%eax
  8010aa:	50                   	push   %eax
  8010ab:	e8 36 ff ff ff       	call   800fe6 <fd_lookup>
  8010b0:	83 c4 08             	add    $0x8,%esp
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	78 05                	js     8010bc <fd_close+0x2d>
	    || fd != fd2)
  8010b7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8010ba:	74 0c                	je     8010c8 <fd_close+0x39>
		return (must_exist ? r : 0);
  8010bc:	84 db                	test   %bl,%bl
  8010be:	ba 00 00 00 00       	mov    $0x0,%edx
  8010c3:	0f 44 c2             	cmove  %edx,%eax
  8010c6:	eb 41                	jmp    801109 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010c8:	83 ec 08             	sub    $0x8,%esp
  8010cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010ce:	50                   	push   %eax
  8010cf:	ff 36                	pushl  (%esi)
  8010d1:	e8 66 ff ff ff       	call   80103c <dev_lookup>
  8010d6:	89 c3                	mov    %eax,%ebx
  8010d8:	83 c4 10             	add    $0x10,%esp
  8010db:	85 c0                	test   %eax,%eax
  8010dd:	78 1a                	js     8010f9 <fd_close+0x6a>
		if (dev->dev_close)
  8010df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010e2:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8010e5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	74 0b                	je     8010f9 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8010ee:	83 ec 0c             	sub    $0xc,%esp
  8010f1:	56                   	push   %esi
  8010f2:	ff d0                	call   *%eax
  8010f4:	89 c3                	mov    %eax,%ebx
  8010f6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010f9:	83 ec 08             	sub    $0x8,%esp
  8010fc:	56                   	push   %esi
  8010fd:	6a 00                	push   $0x0
  8010ff:	e8 09 fb ff ff       	call   800c0d <sys_page_unmap>
	return r;
  801104:	83 c4 10             	add    $0x10,%esp
  801107:	89 d8                	mov    %ebx,%eax
}
  801109:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80110c:	5b                   	pop    %ebx
  80110d:	5e                   	pop    %esi
  80110e:	5d                   	pop    %ebp
  80110f:	c3                   	ret    

00801110 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801116:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801119:	50                   	push   %eax
  80111a:	ff 75 08             	pushl  0x8(%ebp)
  80111d:	e8 c4 fe ff ff       	call   800fe6 <fd_lookup>
  801122:	83 c4 08             	add    $0x8,%esp
  801125:	85 c0                	test   %eax,%eax
  801127:	78 10                	js     801139 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801129:	83 ec 08             	sub    $0x8,%esp
  80112c:	6a 01                	push   $0x1
  80112e:	ff 75 f4             	pushl  -0xc(%ebp)
  801131:	e8 59 ff ff ff       	call   80108f <fd_close>
  801136:	83 c4 10             	add    $0x10,%esp
}
  801139:	c9                   	leave  
  80113a:	c3                   	ret    

0080113b <close_all>:

void
close_all(void)
{
  80113b:	55                   	push   %ebp
  80113c:	89 e5                	mov    %esp,%ebp
  80113e:	53                   	push   %ebx
  80113f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801142:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801147:	83 ec 0c             	sub    $0xc,%esp
  80114a:	53                   	push   %ebx
  80114b:	e8 c0 ff ff ff       	call   801110 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801150:	83 c3 01             	add    $0x1,%ebx
  801153:	83 c4 10             	add    $0x10,%esp
  801156:	83 fb 20             	cmp    $0x20,%ebx
  801159:	75 ec                	jne    801147 <close_all+0xc>
		close(i);
}
  80115b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80115e:	c9                   	leave  
  80115f:	c3                   	ret    

00801160 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	57                   	push   %edi
  801164:	56                   	push   %esi
  801165:	53                   	push   %ebx
  801166:	83 ec 2c             	sub    $0x2c,%esp
  801169:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80116c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80116f:	50                   	push   %eax
  801170:	ff 75 08             	pushl  0x8(%ebp)
  801173:	e8 6e fe ff ff       	call   800fe6 <fd_lookup>
  801178:	83 c4 08             	add    $0x8,%esp
  80117b:	85 c0                	test   %eax,%eax
  80117d:	0f 88 c1 00 00 00    	js     801244 <dup+0xe4>
		return r;
	close(newfdnum);
  801183:	83 ec 0c             	sub    $0xc,%esp
  801186:	56                   	push   %esi
  801187:	e8 84 ff ff ff       	call   801110 <close>

	newfd = INDEX2FD(newfdnum);
  80118c:	89 f3                	mov    %esi,%ebx
  80118e:	c1 e3 0c             	shl    $0xc,%ebx
  801191:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801197:	83 c4 04             	add    $0x4,%esp
  80119a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80119d:	e8 de fd ff ff       	call   800f80 <fd2data>
  8011a2:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8011a4:	89 1c 24             	mov    %ebx,(%esp)
  8011a7:	e8 d4 fd ff ff       	call   800f80 <fd2data>
  8011ac:	83 c4 10             	add    $0x10,%esp
  8011af:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011b2:	89 f8                	mov    %edi,%eax
  8011b4:	c1 e8 16             	shr    $0x16,%eax
  8011b7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011be:	a8 01                	test   $0x1,%al
  8011c0:	74 37                	je     8011f9 <dup+0x99>
  8011c2:	89 f8                	mov    %edi,%eax
  8011c4:	c1 e8 0c             	shr    $0xc,%eax
  8011c7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011ce:	f6 c2 01             	test   $0x1,%dl
  8011d1:	74 26                	je     8011f9 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011d3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011da:	83 ec 0c             	sub    $0xc,%esp
  8011dd:	25 07 0e 00 00       	and    $0xe07,%eax
  8011e2:	50                   	push   %eax
  8011e3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011e6:	6a 00                	push   $0x0
  8011e8:	57                   	push   %edi
  8011e9:	6a 00                	push   $0x0
  8011eb:	e8 db f9 ff ff       	call   800bcb <sys_page_map>
  8011f0:	89 c7                	mov    %eax,%edi
  8011f2:	83 c4 20             	add    $0x20,%esp
  8011f5:	85 c0                	test   %eax,%eax
  8011f7:	78 2e                	js     801227 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011f9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8011fc:	89 d0                	mov    %edx,%eax
  8011fe:	c1 e8 0c             	shr    $0xc,%eax
  801201:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801208:	83 ec 0c             	sub    $0xc,%esp
  80120b:	25 07 0e 00 00       	and    $0xe07,%eax
  801210:	50                   	push   %eax
  801211:	53                   	push   %ebx
  801212:	6a 00                	push   $0x0
  801214:	52                   	push   %edx
  801215:	6a 00                	push   $0x0
  801217:	e8 af f9 ff ff       	call   800bcb <sys_page_map>
  80121c:	89 c7                	mov    %eax,%edi
  80121e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801221:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801223:	85 ff                	test   %edi,%edi
  801225:	79 1d                	jns    801244 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801227:	83 ec 08             	sub    $0x8,%esp
  80122a:	53                   	push   %ebx
  80122b:	6a 00                	push   $0x0
  80122d:	e8 db f9 ff ff       	call   800c0d <sys_page_unmap>
	sys_page_unmap(0, nva);
  801232:	83 c4 08             	add    $0x8,%esp
  801235:	ff 75 d4             	pushl  -0x2c(%ebp)
  801238:	6a 00                	push   $0x0
  80123a:	e8 ce f9 ff ff       	call   800c0d <sys_page_unmap>
	return r;
  80123f:	83 c4 10             	add    $0x10,%esp
  801242:	89 f8                	mov    %edi,%eax
}
  801244:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801247:	5b                   	pop    %ebx
  801248:	5e                   	pop    %esi
  801249:	5f                   	pop    %edi
  80124a:	5d                   	pop    %ebp
  80124b:	c3                   	ret    

0080124c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80124c:	55                   	push   %ebp
  80124d:	89 e5                	mov    %esp,%ebp
  80124f:	53                   	push   %ebx
  801250:	83 ec 14             	sub    $0x14,%esp
  801253:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801256:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801259:	50                   	push   %eax
  80125a:	53                   	push   %ebx
  80125b:	e8 86 fd ff ff       	call   800fe6 <fd_lookup>
  801260:	83 c4 08             	add    $0x8,%esp
  801263:	89 c2                	mov    %eax,%edx
  801265:	85 c0                	test   %eax,%eax
  801267:	78 6d                	js     8012d6 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801269:	83 ec 08             	sub    $0x8,%esp
  80126c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126f:	50                   	push   %eax
  801270:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801273:	ff 30                	pushl  (%eax)
  801275:	e8 c2 fd ff ff       	call   80103c <dev_lookup>
  80127a:	83 c4 10             	add    $0x10,%esp
  80127d:	85 c0                	test   %eax,%eax
  80127f:	78 4c                	js     8012cd <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801281:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801284:	8b 42 08             	mov    0x8(%edx),%eax
  801287:	83 e0 03             	and    $0x3,%eax
  80128a:	83 f8 01             	cmp    $0x1,%eax
  80128d:	75 21                	jne    8012b0 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80128f:	a1 08 40 80 00       	mov    0x804008,%eax
  801294:	8b 40 48             	mov    0x48(%eax),%eax
  801297:	83 ec 04             	sub    $0x4,%esp
  80129a:	53                   	push   %ebx
  80129b:	50                   	push   %eax
  80129c:	68 8d 29 80 00       	push   $0x80298d
  8012a1:	e8 5a ef ff ff       	call   800200 <cprintf>
		return -E_INVAL;
  8012a6:	83 c4 10             	add    $0x10,%esp
  8012a9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012ae:	eb 26                	jmp    8012d6 <read+0x8a>
	}
	if (!dev->dev_read)
  8012b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b3:	8b 40 08             	mov    0x8(%eax),%eax
  8012b6:	85 c0                	test   %eax,%eax
  8012b8:	74 17                	je     8012d1 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012ba:	83 ec 04             	sub    $0x4,%esp
  8012bd:	ff 75 10             	pushl  0x10(%ebp)
  8012c0:	ff 75 0c             	pushl  0xc(%ebp)
  8012c3:	52                   	push   %edx
  8012c4:	ff d0                	call   *%eax
  8012c6:	89 c2                	mov    %eax,%edx
  8012c8:	83 c4 10             	add    $0x10,%esp
  8012cb:	eb 09                	jmp    8012d6 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012cd:	89 c2                	mov    %eax,%edx
  8012cf:	eb 05                	jmp    8012d6 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8012d1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8012d6:	89 d0                	mov    %edx,%eax
  8012d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012db:	c9                   	leave  
  8012dc:	c3                   	ret    

008012dd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012dd:	55                   	push   %ebp
  8012de:	89 e5                	mov    %esp,%ebp
  8012e0:	57                   	push   %edi
  8012e1:	56                   	push   %esi
  8012e2:	53                   	push   %ebx
  8012e3:	83 ec 0c             	sub    $0xc,%esp
  8012e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012e9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012f1:	eb 21                	jmp    801314 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012f3:	83 ec 04             	sub    $0x4,%esp
  8012f6:	89 f0                	mov    %esi,%eax
  8012f8:	29 d8                	sub    %ebx,%eax
  8012fa:	50                   	push   %eax
  8012fb:	89 d8                	mov    %ebx,%eax
  8012fd:	03 45 0c             	add    0xc(%ebp),%eax
  801300:	50                   	push   %eax
  801301:	57                   	push   %edi
  801302:	e8 45 ff ff ff       	call   80124c <read>
		if (m < 0)
  801307:	83 c4 10             	add    $0x10,%esp
  80130a:	85 c0                	test   %eax,%eax
  80130c:	78 10                	js     80131e <readn+0x41>
			return m;
		if (m == 0)
  80130e:	85 c0                	test   %eax,%eax
  801310:	74 0a                	je     80131c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801312:	01 c3                	add    %eax,%ebx
  801314:	39 f3                	cmp    %esi,%ebx
  801316:	72 db                	jb     8012f3 <readn+0x16>
  801318:	89 d8                	mov    %ebx,%eax
  80131a:	eb 02                	jmp    80131e <readn+0x41>
  80131c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80131e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801321:	5b                   	pop    %ebx
  801322:	5e                   	pop    %esi
  801323:	5f                   	pop    %edi
  801324:	5d                   	pop    %ebp
  801325:	c3                   	ret    

00801326 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	53                   	push   %ebx
  80132a:	83 ec 14             	sub    $0x14,%esp
  80132d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801330:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801333:	50                   	push   %eax
  801334:	53                   	push   %ebx
  801335:	e8 ac fc ff ff       	call   800fe6 <fd_lookup>
  80133a:	83 c4 08             	add    $0x8,%esp
  80133d:	89 c2                	mov    %eax,%edx
  80133f:	85 c0                	test   %eax,%eax
  801341:	78 68                	js     8013ab <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801343:	83 ec 08             	sub    $0x8,%esp
  801346:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801349:	50                   	push   %eax
  80134a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134d:	ff 30                	pushl  (%eax)
  80134f:	e8 e8 fc ff ff       	call   80103c <dev_lookup>
  801354:	83 c4 10             	add    $0x10,%esp
  801357:	85 c0                	test   %eax,%eax
  801359:	78 47                	js     8013a2 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80135b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801362:	75 21                	jne    801385 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801364:	a1 08 40 80 00       	mov    0x804008,%eax
  801369:	8b 40 48             	mov    0x48(%eax),%eax
  80136c:	83 ec 04             	sub    $0x4,%esp
  80136f:	53                   	push   %ebx
  801370:	50                   	push   %eax
  801371:	68 a9 29 80 00       	push   $0x8029a9
  801376:	e8 85 ee ff ff       	call   800200 <cprintf>
		return -E_INVAL;
  80137b:	83 c4 10             	add    $0x10,%esp
  80137e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801383:	eb 26                	jmp    8013ab <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801385:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801388:	8b 52 0c             	mov    0xc(%edx),%edx
  80138b:	85 d2                	test   %edx,%edx
  80138d:	74 17                	je     8013a6 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80138f:	83 ec 04             	sub    $0x4,%esp
  801392:	ff 75 10             	pushl  0x10(%ebp)
  801395:	ff 75 0c             	pushl  0xc(%ebp)
  801398:	50                   	push   %eax
  801399:	ff d2                	call   *%edx
  80139b:	89 c2                	mov    %eax,%edx
  80139d:	83 c4 10             	add    $0x10,%esp
  8013a0:	eb 09                	jmp    8013ab <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a2:	89 c2                	mov    %eax,%edx
  8013a4:	eb 05                	jmp    8013ab <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8013a6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8013ab:	89 d0                	mov    %edx,%eax
  8013ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b0:	c9                   	leave  
  8013b1:	c3                   	ret    

008013b2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8013b2:	55                   	push   %ebp
  8013b3:	89 e5                	mov    %esp,%ebp
  8013b5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013b8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013bb:	50                   	push   %eax
  8013bc:	ff 75 08             	pushl  0x8(%ebp)
  8013bf:	e8 22 fc ff ff       	call   800fe6 <fd_lookup>
  8013c4:	83 c4 08             	add    $0x8,%esp
  8013c7:	85 c0                	test   %eax,%eax
  8013c9:	78 0e                	js     8013d9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8013cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013d1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013d9:	c9                   	leave  
  8013da:	c3                   	ret    

008013db <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013db:	55                   	push   %ebp
  8013dc:	89 e5                	mov    %esp,%ebp
  8013de:	53                   	push   %ebx
  8013df:	83 ec 14             	sub    $0x14,%esp
  8013e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e8:	50                   	push   %eax
  8013e9:	53                   	push   %ebx
  8013ea:	e8 f7 fb ff ff       	call   800fe6 <fd_lookup>
  8013ef:	83 c4 08             	add    $0x8,%esp
  8013f2:	89 c2                	mov    %eax,%edx
  8013f4:	85 c0                	test   %eax,%eax
  8013f6:	78 65                	js     80145d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f8:	83 ec 08             	sub    $0x8,%esp
  8013fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fe:	50                   	push   %eax
  8013ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801402:	ff 30                	pushl  (%eax)
  801404:	e8 33 fc ff ff       	call   80103c <dev_lookup>
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	85 c0                	test   %eax,%eax
  80140e:	78 44                	js     801454 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801410:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801413:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801417:	75 21                	jne    80143a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801419:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80141e:	8b 40 48             	mov    0x48(%eax),%eax
  801421:	83 ec 04             	sub    $0x4,%esp
  801424:	53                   	push   %ebx
  801425:	50                   	push   %eax
  801426:	68 6c 29 80 00       	push   $0x80296c
  80142b:	e8 d0 ed ff ff       	call   800200 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801430:	83 c4 10             	add    $0x10,%esp
  801433:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801438:	eb 23                	jmp    80145d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80143a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80143d:	8b 52 18             	mov    0x18(%edx),%edx
  801440:	85 d2                	test   %edx,%edx
  801442:	74 14                	je     801458 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801444:	83 ec 08             	sub    $0x8,%esp
  801447:	ff 75 0c             	pushl  0xc(%ebp)
  80144a:	50                   	push   %eax
  80144b:	ff d2                	call   *%edx
  80144d:	89 c2                	mov    %eax,%edx
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	eb 09                	jmp    80145d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801454:	89 c2                	mov    %eax,%edx
  801456:	eb 05                	jmp    80145d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801458:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80145d:	89 d0                	mov    %edx,%eax
  80145f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801462:	c9                   	leave  
  801463:	c3                   	ret    

00801464 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801464:	55                   	push   %ebp
  801465:	89 e5                	mov    %esp,%ebp
  801467:	53                   	push   %ebx
  801468:	83 ec 14             	sub    $0x14,%esp
  80146b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80146e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801471:	50                   	push   %eax
  801472:	ff 75 08             	pushl  0x8(%ebp)
  801475:	e8 6c fb ff ff       	call   800fe6 <fd_lookup>
  80147a:	83 c4 08             	add    $0x8,%esp
  80147d:	89 c2                	mov    %eax,%edx
  80147f:	85 c0                	test   %eax,%eax
  801481:	78 58                	js     8014db <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801483:	83 ec 08             	sub    $0x8,%esp
  801486:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801489:	50                   	push   %eax
  80148a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80148d:	ff 30                	pushl  (%eax)
  80148f:	e8 a8 fb ff ff       	call   80103c <dev_lookup>
  801494:	83 c4 10             	add    $0x10,%esp
  801497:	85 c0                	test   %eax,%eax
  801499:	78 37                	js     8014d2 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80149b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80149e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014a2:	74 32                	je     8014d6 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014a4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014a7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014ae:	00 00 00 
	stat->st_isdir = 0;
  8014b1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014b8:	00 00 00 
	stat->st_dev = dev;
  8014bb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014c1:	83 ec 08             	sub    $0x8,%esp
  8014c4:	53                   	push   %ebx
  8014c5:	ff 75 f0             	pushl  -0x10(%ebp)
  8014c8:	ff 50 14             	call   *0x14(%eax)
  8014cb:	89 c2                	mov    %eax,%edx
  8014cd:	83 c4 10             	add    $0x10,%esp
  8014d0:	eb 09                	jmp    8014db <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d2:	89 c2                	mov    %eax,%edx
  8014d4:	eb 05                	jmp    8014db <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8014d6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8014db:	89 d0                	mov    %edx,%eax
  8014dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e0:	c9                   	leave  
  8014e1:	c3                   	ret    

008014e2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014e2:	55                   	push   %ebp
  8014e3:	89 e5                	mov    %esp,%ebp
  8014e5:	56                   	push   %esi
  8014e6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014e7:	83 ec 08             	sub    $0x8,%esp
  8014ea:	6a 00                	push   $0x0
  8014ec:	ff 75 08             	pushl  0x8(%ebp)
  8014ef:	e8 d6 01 00 00       	call   8016ca <open>
  8014f4:	89 c3                	mov    %eax,%ebx
  8014f6:	83 c4 10             	add    $0x10,%esp
  8014f9:	85 c0                	test   %eax,%eax
  8014fb:	78 1b                	js     801518 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8014fd:	83 ec 08             	sub    $0x8,%esp
  801500:	ff 75 0c             	pushl  0xc(%ebp)
  801503:	50                   	push   %eax
  801504:	e8 5b ff ff ff       	call   801464 <fstat>
  801509:	89 c6                	mov    %eax,%esi
	close(fd);
  80150b:	89 1c 24             	mov    %ebx,(%esp)
  80150e:	e8 fd fb ff ff       	call   801110 <close>
	return r;
  801513:	83 c4 10             	add    $0x10,%esp
  801516:	89 f0                	mov    %esi,%eax
}
  801518:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80151b:	5b                   	pop    %ebx
  80151c:	5e                   	pop    %esi
  80151d:	5d                   	pop    %ebp
  80151e:	c3                   	ret    

0080151f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80151f:	55                   	push   %ebp
  801520:	89 e5                	mov    %esp,%ebp
  801522:	56                   	push   %esi
  801523:	53                   	push   %ebx
  801524:	89 c6                	mov    %eax,%esi
  801526:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801528:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80152f:	75 12                	jne    801543 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801531:	83 ec 0c             	sub    $0xc,%esp
  801534:	6a 01                	push   $0x1
  801536:	e8 8a 0d 00 00       	call   8022c5 <ipc_find_env>
  80153b:	a3 00 40 80 00       	mov    %eax,0x804000
  801540:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801543:	6a 07                	push   $0x7
  801545:	68 00 50 80 00       	push   $0x805000
  80154a:	56                   	push   %esi
  80154b:	ff 35 00 40 80 00    	pushl  0x804000
  801551:	e8 1b 0d 00 00       	call   802271 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801556:	83 c4 0c             	add    $0xc,%esp
  801559:	6a 00                	push   $0x0
  80155b:	53                   	push   %ebx
  80155c:	6a 00                	push   $0x0
  80155e:	e8 a7 0c 00 00       	call   80220a <ipc_recv>
}
  801563:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801566:	5b                   	pop    %ebx
  801567:	5e                   	pop    %esi
  801568:	5d                   	pop    %ebp
  801569:	c3                   	ret    

0080156a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801570:	8b 45 08             	mov    0x8(%ebp),%eax
  801573:	8b 40 0c             	mov    0xc(%eax),%eax
  801576:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80157b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80157e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801583:	ba 00 00 00 00       	mov    $0x0,%edx
  801588:	b8 02 00 00 00       	mov    $0x2,%eax
  80158d:	e8 8d ff ff ff       	call   80151f <fsipc>
}
  801592:	c9                   	leave  
  801593:	c3                   	ret    

00801594 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801594:	55                   	push   %ebp
  801595:	89 e5                	mov    %esp,%ebp
  801597:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80159a:	8b 45 08             	mov    0x8(%ebp),%eax
  80159d:	8b 40 0c             	mov    0xc(%eax),%eax
  8015a0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8015a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015aa:	b8 06 00 00 00       	mov    $0x6,%eax
  8015af:	e8 6b ff ff ff       	call   80151f <fsipc>
}
  8015b4:	c9                   	leave  
  8015b5:	c3                   	ret    

008015b6 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8015b6:	55                   	push   %ebp
  8015b7:	89 e5                	mov    %esp,%ebp
  8015b9:	53                   	push   %ebx
  8015ba:	83 ec 04             	sub    $0x4,%esp
  8015bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8015c6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d0:	b8 05 00 00 00       	mov    $0x5,%eax
  8015d5:	e8 45 ff ff ff       	call   80151f <fsipc>
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	78 2c                	js     80160a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015de:	83 ec 08             	sub    $0x8,%esp
  8015e1:	68 00 50 80 00       	push   $0x805000
  8015e6:	53                   	push   %ebx
  8015e7:	e8 99 f1 ff ff       	call   800785 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015ec:	a1 80 50 80 00       	mov    0x805080,%eax
  8015f1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015f7:	a1 84 50 80 00       	mov    0x805084,%eax
  8015fc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801602:	83 c4 10             	add    $0x10,%esp
  801605:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80160a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80160d:	c9                   	leave  
  80160e:	c3                   	ret    

0080160f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80160f:	55                   	push   %ebp
  801610:	89 e5                	mov    %esp,%ebp
  801612:	83 ec 0c             	sub    $0xc,%esp
  801615:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801618:	8b 55 08             	mov    0x8(%ebp),%edx
  80161b:	8b 52 0c             	mov    0xc(%edx),%edx
  80161e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801624:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801629:	50                   	push   %eax
  80162a:	ff 75 0c             	pushl  0xc(%ebp)
  80162d:	68 08 50 80 00       	push   $0x805008
  801632:	e8 e0 f2 ff ff       	call   800917 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801637:	ba 00 00 00 00       	mov    $0x0,%edx
  80163c:	b8 04 00 00 00       	mov    $0x4,%eax
  801641:	e8 d9 fe ff ff       	call   80151f <fsipc>

}
  801646:	c9                   	leave  
  801647:	c3                   	ret    

00801648 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	56                   	push   %esi
  80164c:	53                   	push   %ebx
  80164d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801650:	8b 45 08             	mov    0x8(%ebp),%eax
  801653:	8b 40 0c             	mov    0xc(%eax),%eax
  801656:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80165b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801661:	ba 00 00 00 00       	mov    $0x0,%edx
  801666:	b8 03 00 00 00       	mov    $0x3,%eax
  80166b:	e8 af fe ff ff       	call   80151f <fsipc>
  801670:	89 c3                	mov    %eax,%ebx
  801672:	85 c0                	test   %eax,%eax
  801674:	78 4b                	js     8016c1 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801676:	39 c6                	cmp    %eax,%esi
  801678:	73 16                	jae    801690 <devfile_read+0x48>
  80167a:	68 dc 29 80 00       	push   $0x8029dc
  80167f:	68 e3 29 80 00       	push   $0x8029e3
  801684:	6a 7c                	push   $0x7c
  801686:	68 f8 29 80 00       	push   $0x8029f8
  80168b:	e8 34 0b 00 00       	call   8021c4 <_panic>
	assert(r <= PGSIZE);
  801690:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801695:	7e 16                	jle    8016ad <devfile_read+0x65>
  801697:	68 03 2a 80 00       	push   $0x802a03
  80169c:	68 e3 29 80 00       	push   $0x8029e3
  8016a1:	6a 7d                	push   $0x7d
  8016a3:	68 f8 29 80 00       	push   $0x8029f8
  8016a8:	e8 17 0b 00 00       	call   8021c4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8016ad:	83 ec 04             	sub    $0x4,%esp
  8016b0:	50                   	push   %eax
  8016b1:	68 00 50 80 00       	push   $0x805000
  8016b6:	ff 75 0c             	pushl  0xc(%ebp)
  8016b9:	e8 59 f2 ff ff       	call   800917 <memmove>
	return r;
  8016be:	83 c4 10             	add    $0x10,%esp
}
  8016c1:	89 d8                	mov    %ebx,%eax
  8016c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c6:	5b                   	pop    %ebx
  8016c7:	5e                   	pop    %esi
  8016c8:	5d                   	pop    %ebp
  8016c9:	c3                   	ret    

008016ca <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	53                   	push   %ebx
  8016ce:	83 ec 20             	sub    $0x20,%esp
  8016d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016d4:	53                   	push   %ebx
  8016d5:	e8 72 f0 ff ff       	call   80074c <strlen>
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016e2:	7f 67                	jg     80174b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016e4:	83 ec 0c             	sub    $0xc,%esp
  8016e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ea:	50                   	push   %eax
  8016eb:	e8 a7 f8 ff ff       	call   800f97 <fd_alloc>
  8016f0:	83 c4 10             	add    $0x10,%esp
		return r;
  8016f3:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016f5:	85 c0                	test   %eax,%eax
  8016f7:	78 57                	js     801750 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016f9:	83 ec 08             	sub    $0x8,%esp
  8016fc:	53                   	push   %ebx
  8016fd:	68 00 50 80 00       	push   $0x805000
  801702:	e8 7e f0 ff ff       	call   800785 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801707:	8b 45 0c             	mov    0xc(%ebp),%eax
  80170a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80170f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801712:	b8 01 00 00 00       	mov    $0x1,%eax
  801717:	e8 03 fe ff ff       	call   80151f <fsipc>
  80171c:	89 c3                	mov    %eax,%ebx
  80171e:	83 c4 10             	add    $0x10,%esp
  801721:	85 c0                	test   %eax,%eax
  801723:	79 14                	jns    801739 <open+0x6f>
		fd_close(fd, 0);
  801725:	83 ec 08             	sub    $0x8,%esp
  801728:	6a 00                	push   $0x0
  80172a:	ff 75 f4             	pushl  -0xc(%ebp)
  80172d:	e8 5d f9 ff ff       	call   80108f <fd_close>
		return r;
  801732:	83 c4 10             	add    $0x10,%esp
  801735:	89 da                	mov    %ebx,%edx
  801737:	eb 17                	jmp    801750 <open+0x86>
	}

	return fd2num(fd);
  801739:	83 ec 0c             	sub    $0xc,%esp
  80173c:	ff 75 f4             	pushl  -0xc(%ebp)
  80173f:	e8 2c f8 ff ff       	call   800f70 <fd2num>
  801744:	89 c2                	mov    %eax,%edx
  801746:	83 c4 10             	add    $0x10,%esp
  801749:	eb 05                	jmp    801750 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80174b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801750:	89 d0                	mov    %edx,%eax
  801752:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801755:	c9                   	leave  
  801756:	c3                   	ret    

00801757 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801757:	55                   	push   %ebp
  801758:	89 e5                	mov    %esp,%ebp
  80175a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80175d:	ba 00 00 00 00       	mov    $0x0,%edx
  801762:	b8 08 00 00 00       	mov    $0x8,%eax
  801767:	e8 b3 fd ff ff       	call   80151f <fsipc>
}
  80176c:	c9                   	leave  
  80176d:	c3                   	ret    

0080176e <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80176e:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801772:	7e 37                	jle    8017ab <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801774:	55                   	push   %ebp
  801775:	89 e5                	mov    %esp,%ebp
  801777:	53                   	push   %ebx
  801778:	83 ec 08             	sub    $0x8,%esp
  80177b:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80177d:	ff 70 04             	pushl  0x4(%eax)
  801780:	8d 40 10             	lea    0x10(%eax),%eax
  801783:	50                   	push   %eax
  801784:	ff 33                	pushl  (%ebx)
  801786:	e8 9b fb ff ff       	call   801326 <write>
		if (result > 0)
  80178b:	83 c4 10             	add    $0x10,%esp
  80178e:	85 c0                	test   %eax,%eax
  801790:	7e 03                	jle    801795 <writebuf+0x27>
			b->result += result;
  801792:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801795:	3b 43 04             	cmp    0x4(%ebx),%eax
  801798:	74 0d                	je     8017a7 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80179a:	85 c0                	test   %eax,%eax
  80179c:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a1:	0f 4f c2             	cmovg  %edx,%eax
  8017a4:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8017a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017aa:	c9                   	leave  
  8017ab:	f3 c3                	repz ret 

008017ad <putch>:

static void
putch(int ch, void *thunk)
{
  8017ad:	55                   	push   %ebp
  8017ae:	89 e5                	mov    %esp,%ebp
  8017b0:	53                   	push   %ebx
  8017b1:	83 ec 04             	sub    $0x4,%esp
  8017b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8017b7:	8b 53 04             	mov    0x4(%ebx),%edx
  8017ba:	8d 42 01             	lea    0x1(%edx),%eax
  8017bd:	89 43 04             	mov    %eax,0x4(%ebx)
  8017c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c3:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8017c7:	3d 00 01 00 00       	cmp    $0x100,%eax
  8017cc:	75 0e                	jne    8017dc <putch+0x2f>
		writebuf(b);
  8017ce:	89 d8                	mov    %ebx,%eax
  8017d0:	e8 99 ff ff ff       	call   80176e <writebuf>
		b->idx = 0;
  8017d5:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8017dc:	83 c4 04             	add    $0x4,%esp
  8017df:	5b                   	pop    %ebx
  8017e0:	5d                   	pop    %ebp
  8017e1:	c3                   	ret    

008017e2 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8017e2:	55                   	push   %ebp
  8017e3:	89 e5                	mov    %esp,%ebp
  8017e5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8017eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ee:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8017f4:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8017fb:	00 00 00 
	b.result = 0;
  8017fe:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801805:	00 00 00 
	b.error = 1;
  801808:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80180f:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801812:	ff 75 10             	pushl  0x10(%ebp)
  801815:	ff 75 0c             	pushl  0xc(%ebp)
  801818:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80181e:	50                   	push   %eax
  80181f:	68 ad 17 80 00       	push   $0x8017ad
  801824:	e8 0e eb ff ff       	call   800337 <vprintfmt>
	if (b.idx > 0)
  801829:	83 c4 10             	add    $0x10,%esp
  80182c:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801833:	7e 0b                	jle    801840 <vfprintf+0x5e>
		writebuf(&b);
  801835:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80183b:	e8 2e ff ff ff       	call   80176e <writebuf>

	return (b.result ? b.result : b.error);
  801840:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801846:	85 c0                	test   %eax,%eax
  801848:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80184f:	c9                   	leave  
  801850:	c3                   	ret    

00801851 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801851:	55                   	push   %ebp
  801852:	89 e5                	mov    %esp,%ebp
  801854:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801857:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80185a:	50                   	push   %eax
  80185b:	ff 75 0c             	pushl  0xc(%ebp)
  80185e:	ff 75 08             	pushl  0x8(%ebp)
  801861:	e8 7c ff ff ff       	call   8017e2 <vfprintf>
	va_end(ap);

	return cnt;
}
  801866:	c9                   	leave  
  801867:	c3                   	ret    

00801868 <printf>:

int
printf(const char *fmt, ...)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80186e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801871:	50                   	push   %eax
  801872:	ff 75 08             	pushl  0x8(%ebp)
  801875:	6a 01                	push   $0x1
  801877:	e8 66 ff ff ff       	call   8017e2 <vfprintf>
	va_end(ap);

	return cnt;
}
  80187c:	c9                   	leave  
  80187d:	c3                   	ret    

0080187e <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801884:	68 0f 2a 80 00       	push   $0x802a0f
  801889:	ff 75 0c             	pushl  0xc(%ebp)
  80188c:	e8 f4 ee ff ff       	call   800785 <strcpy>
	return 0;
}
  801891:	b8 00 00 00 00       	mov    $0x0,%eax
  801896:	c9                   	leave  
  801897:	c3                   	ret    

00801898 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	53                   	push   %ebx
  80189c:	83 ec 10             	sub    $0x10,%esp
  80189f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8018a2:	53                   	push   %ebx
  8018a3:	e8 56 0a 00 00       	call   8022fe <pageref>
  8018a8:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8018ab:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8018b0:	83 f8 01             	cmp    $0x1,%eax
  8018b3:	75 10                	jne    8018c5 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8018b5:	83 ec 0c             	sub    $0xc,%esp
  8018b8:	ff 73 0c             	pushl  0xc(%ebx)
  8018bb:	e8 c0 02 00 00       	call   801b80 <nsipc_close>
  8018c0:	89 c2                	mov    %eax,%edx
  8018c2:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8018c5:	89 d0                	mov    %edx,%eax
  8018c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ca:	c9                   	leave  
  8018cb:	c3                   	ret    

008018cc <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8018cc:	55                   	push   %ebp
  8018cd:	89 e5                	mov    %esp,%ebp
  8018cf:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8018d2:	6a 00                	push   $0x0
  8018d4:	ff 75 10             	pushl  0x10(%ebp)
  8018d7:	ff 75 0c             	pushl  0xc(%ebp)
  8018da:	8b 45 08             	mov    0x8(%ebp),%eax
  8018dd:	ff 70 0c             	pushl  0xc(%eax)
  8018e0:	e8 78 03 00 00       	call   801c5d <nsipc_send>
}
  8018e5:	c9                   	leave  
  8018e6:	c3                   	ret    

008018e7 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8018e7:	55                   	push   %ebp
  8018e8:	89 e5                	mov    %esp,%ebp
  8018ea:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8018ed:	6a 00                	push   $0x0
  8018ef:	ff 75 10             	pushl  0x10(%ebp)
  8018f2:	ff 75 0c             	pushl  0xc(%ebp)
  8018f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f8:	ff 70 0c             	pushl  0xc(%eax)
  8018fb:	e8 f1 02 00 00       	call   801bf1 <nsipc_recv>
}
  801900:	c9                   	leave  
  801901:	c3                   	ret    

00801902 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801908:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80190b:	52                   	push   %edx
  80190c:	50                   	push   %eax
  80190d:	e8 d4 f6 ff ff       	call   800fe6 <fd_lookup>
  801912:	83 c4 10             	add    $0x10,%esp
  801915:	85 c0                	test   %eax,%eax
  801917:	78 17                	js     801930 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801919:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80191c:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801922:	39 08                	cmp    %ecx,(%eax)
  801924:	75 05                	jne    80192b <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801926:	8b 40 0c             	mov    0xc(%eax),%eax
  801929:	eb 05                	jmp    801930 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80192b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801930:	c9                   	leave  
  801931:	c3                   	ret    

00801932 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801932:	55                   	push   %ebp
  801933:	89 e5                	mov    %esp,%ebp
  801935:	56                   	push   %esi
  801936:	53                   	push   %ebx
  801937:	83 ec 1c             	sub    $0x1c,%esp
  80193a:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80193c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80193f:	50                   	push   %eax
  801940:	e8 52 f6 ff ff       	call   800f97 <fd_alloc>
  801945:	89 c3                	mov    %eax,%ebx
  801947:	83 c4 10             	add    $0x10,%esp
  80194a:	85 c0                	test   %eax,%eax
  80194c:	78 1b                	js     801969 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80194e:	83 ec 04             	sub    $0x4,%esp
  801951:	68 07 04 00 00       	push   $0x407
  801956:	ff 75 f4             	pushl  -0xc(%ebp)
  801959:	6a 00                	push   $0x0
  80195b:	e8 28 f2 ff ff       	call   800b88 <sys_page_alloc>
  801960:	89 c3                	mov    %eax,%ebx
  801962:	83 c4 10             	add    $0x10,%esp
  801965:	85 c0                	test   %eax,%eax
  801967:	79 10                	jns    801979 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801969:	83 ec 0c             	sub    $0xc,%esp
  80196c:	56                   	push   %esi
  80196d:	e8 0e 02 00 00       	call   801b80 <nsipc_close>
		return r;
  801972:	83 c4 10             	add    $0x10,%esp
  801975:	89 d8                	mov    %ebx,%eax
  801977:	eb 24                	jmp    80199d <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801979:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80197f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801982:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801984:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801987:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80198e:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801991:	83 ec 0c             	sub    $0xc,%esp
  801994:	50                   	push   %eax
  801995:	e8 d6 f5 ff ff       	call   800f70 <fd2num>
  80199a:	83 c4 10             	add    $0x10,%esp
}
  80199d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a0:	5b                   	pop    %ebx
  8019a1:	5e                   	pop    %esi
  8019a2:	5d                   	pop    %ebp
  8019a3:	c3                   	ret    

008019a4 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ad:	e8 50 ff ff ff       	call   801902 <fd2sockid>
		return r;
  8019b2:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019b4:	85 c0                	test   %eax,%eax
  8019b6:	78 1f                	js     8019d7 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019b8:	83 ec 04             	sub    $0x4,%esp
  8019bb:	ff 75 10             	pushl  0x10(%ebp)
  8019be:	ff 75 0c             	pushl  0xc(%ebp)
  8019c1:	50                   	push   %eax
  8019c2:	e8 12 01 00 00       	call   801ad9 <nsipc_accept>
  8019c7:	83 c4 10             	add    $0x10,%esp
		return r;
  8019ca:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019cc:	85 c0                	test   %eax,%eax
  8019ce:	78 07                	js     8019d7 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8019d0:	e8 5d ff ff ff       	call   801932 <alloc_sockfd>
  8019d5:	89 c1                	mov    %eax,%ecx
}
  8019d7:	89 c8                	mov    %ecx,%eax
  8019d9:	c9                   	leave  
  8019da:	c3                   	ret    

008019db <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e4:	e8 19 ff ff ff       	call   801902 <fd2sockid>
  8019e9:	85 c0                	test   %eax,%eax
  8019eb:	78 12                	js     8019ff <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8019ed:	83 ec 04             	sub    $0x4,%esp
  8019f0:	ff 75 10             	pushl  0x10(%ebp)
  8019f3:	ff 75 0c             	pushl  0xc(%ebp)
  8019f6:	50                   	push   %eax
  8019f7:	e8 2d 01 00 00       	call   801b29 <nsipc_bind>
  8019fc:	83 c4 10             	add    $0x10,%esp
}
  8019ff:	c9                   	leave  
  801a00:	c3                   	ret    

00801a01 <shutdown>:

int
shutdown(int s, int how)
{
  801a01:	55                   	push   %ebp
  801a02:	89 e5                	mov    %esp,%ebp
  801a04:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a07:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0a:	e8 f3 fe ff ff       	call   801902 <fd2sockid>
  801a0f:	85 c0                	test   %eax,%eax
  801a11:	78 0f                	js     801a22 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801a13:	83 ec 08             	sub    $0x8,%esp
  801a16:	ff 75 0c             	pushl  0xc(%ebp)
  801a19:	50                   	push   %eax
  801a1a:	e8 3f 01 00 00       	call   801b5e <nsipc_shutdown>
  801a1f:	83 c4 10             	add    $0x10,%esp
}
  801a22:	c9                   	leave  
  801a23:	c3                   	ret    

00801a24 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a24:	55                   	push   %ebp
  801a25:	89 e5                	mov    %esp,%ebp
  801a27:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2d:	e8 d0 fe ff ff       	call   801902 <fd2sockid>
  801a32:	85 c0                	test   %eax,%eax
  801a34:	78 12                	js     801a48 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801a36:	83 ec 04             	sub    $0x4,%esp
  801a39:	ff 75 10             	pushl  0x10(%ebp)
  801a3c:	ff 75 0c             	pushl  0xc(%ebp)
  801a3f:	50                   	push   %eax
  801a40:	e8 55 01 00 00       	call   801b9a <nsipc_connect>
  801a45:	83 c4 10             	add    $0x10,%esp
}
  801a48:	c9                   	leave  
  801a49:	c3                   	ret    

00801a4a <listen>:

int
listen(int s, int backlog)
{
  801a4a:	55                   	push   %ebp
  801a4b:	89 e5                	mov    %esp,%ebp
  801a4d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a50:	8b 45 08             	mov    0x8(%ebp),%eax
  801a53:	e8 aa fe ff ff       	call   801902 <fd2sockid>
  801a58:	85 c0                	test   %eax,%eax
  801a5a:	78 0f                	js     801a6b <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801a5c:	83 ec 08             	sub    $0x8,%esp
  801a5f:	ff 75 0c             	pushl  0xc(%ebp)
  801a62:	50                   	push   %eax
  801a63:	e8 67 01 00 00       	call   801bcf <nsipc_listen>
  801a68:	83 c4 10             	add    $0x10,%esp
}
  801a6b:	c9                   	leave  
  801a6c:	c3                   	ret    

00801a6d <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a73:	ff 75 10             	pushl  0x10(%ebp)
  801a76:	ff 75 0c             	pushl  0xc(%ebp)
  801a79:	ff 75 08             	pushl  0x8(%ebp)
  801a7c:	e8 3a 02 00 00       	call   801cbb <nsipc_socket>
  801a81:	83 c4 10             	add    $0x10,%esp
  801a84:	85 c0                	test   %eax,%eax
  801a86:	78 05                	js     801a8d <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801a88:	e8 a5 fe ff ff       	call   801932 <alloc_sockfd>
}
  801a8d:	c9                   	leave  
  801a8e:	c3                   	ret    

00801a8f <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a8f:	55                   	push   %ebp
  801a90:	89 e5                	mov    %esp,%ebp
  801a92:	53                   	push   %ebx
  801a93:	83 ec 04             	sub    $0x4,%esp
  801a96:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a98:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801a9f:	75 12                	jne    801ab3 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801aa1:	83 ec 0c             	sub    $0xc,%esp
  801aa4:	6a 02                	push   $0x2
  801aa6:	e8 1a 08 00 00       	call   8022c5 <ipc_find_env>
  801aab:	a3 04 40 80 00       	mov    %eax,0x804004
  801ab0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ab3:	6a 07                	push   $0x7
  801ab5:	68 00 60 80 00       	push   $0x806000
  801aba:	53                   	push   %ebx
  801abb:	ff 35 04 40 80 00    	pushl  0x804004
  801ac1:	e8 ab 07 00 00       	call   802271 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ac6:	83 c4 0c             	add    $0xc,%esp
  801ac9:	6a 00                	push   $0x0
  801acb:	6a 00                	push   $0x0
  801acd:	6a 00                	push   $0x0
  801acf:	e8 36 07 00 00       	call   80220a <ipc_recv>
}
  801ad4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ad7:	c9                   	leave  
  801ad8:	c3                   	ret    

00801ad9 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ad9:	55                   	push   %ebp
  801ada:	89 e5                	mov    %esp,%ebp
  801adc:	56                   	push   %esi
  801add:	53                   	push   %ebx
  801ade:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801ae1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ae9:	8b 06                	mov    (%esi),%eax
  801aeb:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801af0:	b8 01 00 00 00       	mov    $0x1,%eax
  801af5:	e8 95 ff ff ff       	call   801a8f <nsipc>
  801afa:	89 c3                	mov    %eax,%ebx
  801afc:	85 c0                	test   %eax,%eax
  801afe:	78 20                	js     801b20 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801b00:	83 ec 04             	sub    $0x4,%esp
  801b03:	ff 35 10 60 80 00    	pushl  0x806010
  801b09:	68 00 60 80 00       	push   $0x806000
  801b0e:	ff 75 0c             	pushl  0xc(%ebp)
  801b11:	e8 01 ee ff ff       	call   800917 <memmove>
		*addrlen = ret->ret_addrlen;
  801b16:	a1 10 60 80 00       	mov    0x806010,%eax
  801b1b:	89 06                	mov    %eax,(%esi)
  801b1d:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801b20:	89 d8                	mov    %ebx,%eax
  801b22:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b25:	5b                   	pop    %ebx
  801b26:	5e                   	pop    %esi
  801b27:	5d                   	pop    %ebp
  801b28:	c3                   	ret    

00801b29 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b29:	55                   	push   %ebp
  801b2a:	89 e5                	mov    %esp,%ebp
  801b2c:	53                   	push   %ebx
  801b2d:	83 ec 08             	sub    $0x8,%esp
  801b30:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801b33:	8b 45 08             	mov    0x8(%ebp),%eax
  801b36:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b3b:	53                   	push   %ebx
  801b3c:	ff 75 0c             	pushl  0xc(%ebp)
  801b3f:	68 04 60 80 00       	push   $0x806004
  801b44:	e8 ce ed ff ff       	call   800917 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b49:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801b4f:	b8 02 00 00 00       	mov    $0x2,%eax
  801b54:	e8 36 ff ff ff       	call   801a8f <nsipc>
}
  801b59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b5c:	c9                   	leave  
  801b5d:	c3                   	ret    

00801b5e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b64:	8b 45 08             	mov    0x8(%ebp),%eax
  801b67:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801b6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b6f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801b74:	b8 03 00 00 00       	mov    $0x3,%eax
  801b79:	e8 11 ff ff ff       	call   801a8f <nsipc>
}
  801b7e:	c9                   	leave  
  801b7f:	c3                   	ret    

00801b80 <nsipc_close>:

int
nsipc_close(int s)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b86:	8b 45 08             	mov    0x8(%ebp),%eax
  801b89:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801b8e:	b8 04 00 00 00       	mov    $0x4,%eax
  801b93:	e8 f7 fe ff ff       	call   801a8f <nsipc>
}
  801b98:	c9                   	leave  
  801b99:	c3                   	ret    

00801b9a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	53                   	push   %ebx
  801b9e:	83 ec 08             	sub    $0x8,%esp
  801ba1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801ba4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba7:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801bac:	53                   	push   %ebx
  801bad:	ff 75 0c             	pushl  0xc(%ebp)
  801bb0:	68 04 60 80 00       	push   $0x806004
  801bb5:	e8 5d ed ff ff       	call   800917 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801bba:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801bc0:	b8 05 00 00 00       	mov    $0x5,%eax
  801bc5:	e8 c5 fe ff ff       	call   801a8f <nsipc>
}
  801bca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bcd:	c9                   	leave  
  801bce:	c3                   	ret    

00801bcf <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801bcf:	55                   	push   %ebp
  801bd0:	89 e5                	mov    %esp,%ebp
  801bd2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801bd5:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801bdd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be0:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801be5:	b8 06 00 00 00       	mov    $0x6,%eax
  801bea:	e8 a0 fe ff ff       	call   801a8f <nsipc>
}
  801bef:	c9                   	leave  
  801bf0:	c3                   	ret    

00801bf1 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801bf1:	55                   	push   %ebp
  801bf2:	89 e5                	mov    %esp,%ebp
  801bf4:	56                   	push   %esi
  801bf5:	53                   	push   %ebx
  801bf6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801c01:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801c07:	8b 45 14             	mov    0x14(%ebp),%eax
  801c0a:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801c0f:	b8 07 00 00 00       	mov    $0x7,%eax
  801c14:	e8 76 fe ff ff       	call   801a8f <nsipc>
  801c19:	89 c3                	mov    %eax,%ebx
  801c1b:	85 c0                	test   %eax,%eax
  801c1d:	78 35                	js     801c54 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801c1f:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801c24:	7f 04                	jg     801c2a <nsipc_recv+0x39>
  801c26:	39 c6                	cmp    %eax,%esi
  801c28:	7d 16                	jge    801c40 <nsipc_recv+0x4f>
  801c2a:	68 1b 2a 80 00       	push   $0x802a1b
  801c2f:	68 e3 29 80 00       	push   $0x8029e3
  801c34:	6a 62                	push   $0x62
  801c36:	68 30 2a 80 00       	push   $0x802a30
  801c3b:	e8 84 05 00 00       	call   8021c4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c40:	83 ec 04             	sub    $0x4,%esp
  801c43:	50                   	push   %eax
  801c44:	68 00 60 80 00       	push   $0x806000
  801c49:	ff 75 0c             	pushl  0xc(%ebp)
  801c4c:	e8 c6 ec ff ff       	call   800917 <memmove>
  801c51:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c54:	89 d8                	mov    %ebx,%eax
  801c56:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c59:	5b                   	pop    %ebx
  801c5a:	5e                   	pop    %esi
  801c5b:	5d                   	pop    %ebp
  801c5c:	c3                   	ret    

00801c5d <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c5d:	55                   	push   %ebp
  801c5e:	89 e5                	mov    %esp,%ebp
  801c60:	53                   	push   %ebx
  801c61:	83 ec 04             	sub    $0x4,%esp
  801c64:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c67:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6a:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801c6f:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c75:	7e 16                	jle    801c8d <nsipc_send+0x30>
  801c77:	68 3c 2a 80 00       	push   $0x802a3c
  801c7c:	68 e3 29 80 00       	push   $0x8029e3
  801c81:	6a 6d                	push   $0x6d
  801c83:	68 30 2a 80 00       	push   $0x802a30
  801c88:	e8 37 05 00 00       	call   8021c4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c8d:	83 ec 04             	sub    $0x4,%esp
  801c90:	53                   	push   %ebx
  801c91:	ff 75 0c             	pushl  0xc(%ebp)
  801c94:	68 0c 60 80 00       	push   $0x80600c
  801c99:	e8 79 ec ff ff       	call   800917 <memmove>
	nsipcbuf.send.req_size = size;
  801c9e:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801ca4:	8b 45 14             	mov    0x14(%ebp),%eax
  801ca7:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801cac:	b8 08 00 00 00       	mov    $0x8,%eax
  801cb1:	e8 d9 fd ff ff       	call   801a8f <nsipc>
}
  801cb6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cb9:	c9                   	leave  
  801cba:	c3                   	ret    

00801cbb <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801cbb:	55                   	push   %ebp
  801cbc:	89 e5                	mov    %esp,%ebp
  801cbe:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801cc1:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801cc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ccc:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801cd1:	8b 45 10             	mov    0x10(%ebp),%eax
  801cd4:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801cd9:	b8 09 00 00 00       	mov    $0x9,%eax
  801cde:	e8 ac fd ff ff       	call   801a8f <nsipc>
}
  801ce3:	c9                   	leave  
  801ce4:	c3                   	ret    

00801ce5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ce5:	55                   	push   %ebp
  801ce6:	89 e5                	mov    %esp,%ebp
  801ce8:	56                   	push   %esi
  801ce9:	53                   	push   %ebx
  801cea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ced:	83 ec 0c             	sub    $0xc,%esp
  801cf0:	ff 75 08             	pushl  0x8(%ebp)
  801cf3:	e8 88 f2 ff ff       	call   800f80 <fd2data>
  801cf8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801cfa:	83 c4 08             	add    $0x8,%esp
  801cfd:	68 48 2a 80 00       	push   $0x802a48
  801d02:	53                   	push   %ebx
  801d03:	e8 7d ea ff ff       	call   800785 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d08:	8b 46 04             	mov    0x4(%esi),%eax
  801d0b:	2b 06                	sub    (%esi),%eax
  801d0d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d13:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d1a:	00 00 00 
	stat->st_dev = &devpipe;
  801d1d:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801d24:	30 80 00 
	return 0;
}
  801d27:	b8 00 00 00 00       	mov    $0x0,%eax
  801d2c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d2f:	5b                   	pop    %ebx
  801d30:	5e                   	pop    %esi
  801d31:	5d                   	pop    %ebp
  801d32:	c3                   	ret    

00801d33 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d33:	55                   	push   %ebp
  801d34:	89 e5                	mov    %esp,%ebp
  801d36:	53                   	push   %ebx
  801d37:	83 ec 0c             	sub    $0xc,%esp
  801d3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d3d:	53                   	push   %ebx
  801d3e:	6a 00                	push   $0x0
  801d40:	e8 c8 ee ff ff       	call   800c0d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d45:	89 1c 24             	mov    %ebx,(%esp)
  801d48:	e8 33 f2 ff ff       	call   800f80 <fd2data>
  801d4d:	83 c4 08             	add    $0x8,%esp
  801d50:	50                   	push   %eax
  801d51:	6a 00                	push   $0x0
  801d53:	e8 b5 ee ff ff       	call   800c0d <sys_page_unmap>
}
  801d58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d5b:	c9                   	leave  
  801d5c:	c3                   	ret    

00801d5d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d5d:	55                   	push   %ebp
  801d5e:	89 e5                	mov    %esp,%ebp
  801d60:	57                   	push   %edi
  801d61:	56                   	push   %esi
  801d62:	53                   	push   %ebx
  801d63:	83 ec 1c             	sub    $0x1c,%esp
  801d66:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d69:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d6b:	a1 08 40 80 00       	mov    0x804008,%eax
  801d70:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d73:	83 ec 0c             	sub    $0xc,%esp
  801d76:	ff 75 e0             	pushl  -0x20(%ebp)
  801d79:	e8 80 05 00 00       	call   8022fe <pageref>
  801d7e:	89 c3                	mov    %eax,%ebx
  801d80:	89 3c 24             	mov    %edi,(%esp)
  801d83:	e8 76 05 00 00       	call   8022fe <pageref>
  801d88:	83 c4 10             	add    $0x10,%esp
  801d8b:	39 c3                	cmp    %eax,%ebx
  801d8d:	0f 94 c1             	sete   %cl
  801d90:	0f b6 c9             	movzbl %cl,%ecx
  801d93:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d96:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801d9c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d9f:	39 ce                	cmp    %ecx,%esi
  801da1:	74 1b                	je     801dbe <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801da3:	39 c3                	cmp    %eax,%ebx
  801da5:	75 c4                	jne    801d6b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801da7:	8b 42 58             	mov    0x58(%edx),%eax
  801daa:	ff 75 e4             	pushl  -0x1c(%ebp)
  801dad:	50                   	push   %eax
  801dae:	56                   	push   %esi
  801daf:	68 4f 2a 80 00       	push   $0x802a4f
  801db4:	e8 47 e4 ff ff       	call   800200 <cprintf>
  801db9:	83 c4 10             	add    $0x10,%esp
  801dbc:	eb ad                	jmp    801d6b <_pipeisclosed+0xe>
	}
}
  801dbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dc4:	5b                   	pop    %ebx
  801dc5:	5e                   	pop    %esi
  801dc6:	5f                   	pop    %edi
  801dc7:	5d                   	pop    %ebp
  801dc8:	c3                   	ret    

00801dc9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dc9:	55                   	push   %ebp
  801dca:	89 e5                	mov    %esp,%ebp
  801dcc:	57                   	push   %edi
  801dcd:	56                   	push   %esi
  801dce:	53                   	push   %ebx
  801dcf:	83 ec 28             	sub    $0x28,%esp
  801dd2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801dd5:	56                   	push   %esi
  801dd6:	e8 a5 f1 ff ff       	call   800f80 <fd2data>
  801ddb:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ddd:	83 c4 10             	add    $0x10,%esp
  801de0:	bf 00 00 00 00       	mov    $0x0,%edi
  801de5:	eb 4b                	jmp    801e32 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801de7:	89 da                	mov    %ebx,%edx
  801de9:	89 f0                	mov    %esi,%eax
  801deb:	e8 6d ff ff ff       	call   801d5d <_pipeisclosed>
  801df0:	85 c0                	test   %eax,%eax
  801df2:	75 48                	jne    801e3c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801df4:	e8 70 ed ff ff       	call   800b69 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801df9:	8b 43 04             	mov    0x4(%ebx),%eax
  801dfc:	8b 0b                	mov    (%ebx),%ecx
  801dfe:	8d 51 20             	lea    0x20(%ecx),%edx
  801e01:	39 d0                	cmp    %edx,%eax
  801e03:	73 e2                	jae    801de7 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e08:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e0c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e0f:	89 c2                	mov    %eax,%edx
  801e11:	c1 fa 1f             	sar    $0x1f,%edx
  801e14:	89 d1                	mov    %edx,%ecx
  801e16:	c1 e9 1b             	shr    $0x1b,%ecx
  801e19:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e1c:	83 e2 1f             	and    $0x1f,%edx
  801e1f:	29 ca                	sub    %ecx,%edx
  801e21:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e25:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e29:	83 c0 01             	add    $0x1,%eax
  801e2c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e2f:	83 c7 01             	add    $0x1,%edi
  801e32:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e35:	75 c2                	jne    801df9 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e37:	8b 45 10             	mov    0x10(%ebp),%eax
  801e3a:	eb 05                	jmp    801e41 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e3c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e44:	5b                   	pop    %ebx
  801e45:	5e                   	pop    %esi
  801e46:	5f                   	pop    %edi
  801e47:	5d                   	pop    %ebp
  801e48:	c3                   	ret    

00801e49 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e49:	55                   	push   %ebp
  801e4a:	89 e5                	mov    %esp,%ebp
  801e4c:	57                   	push   %edi
  801e4d:	56                   	push   %esi
  801e4e:	53                   	push   %ebx
  801e4f:	83 ec 18             	sub    $0x18,%esp
  801e52:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e55:	57                   	push   %edi
  801e56:	e8 25 f1 ff ff       	call   800f80 <fd2data>
  801e5b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e5d:	83 c4 10             	add    $0x10,%esp
  801e60:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e65:	eb 3d                	jmp    801ea4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e67:	85 db                	test   %ebx,%ebx
  801e69:	74 04                	je     801e6f <devpipe_read+0x26>
				return i;
  801e6b:	89 d8                	mov    %ebx,%eax
  801e6d:	eb 44                	jmp    801eb3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e6f:	89 f2                	mov    %esi,%edx
  801e71:	89 f8                	mov    %edi,%eax
  801e73:	e8 e5 fe ff ff       	call   801d5d <_pipeisclosed>
  801e78:	85 c0                	test   %eax,%eax
  801e7a:	75 32                	jne    801eae <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e7c:	e8 e8 ec ff ff       	call   800b69 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e81:	8b 06                	mov    (%esi),%eax
  801e83:	3b 46 04             	cmp    0x4(%esi),%eax
  801e86:	74 df                	je     801e67 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e88:	99                   	cltd   
  801e89:	c1 ea 1b             	shr    $0x1b,%edx
  801e8c:	01 d0                	add    %edx,%eax
  801e8e:	83 e0 1f             	and    $0x1f,%eax
  801e91:	29 d0                	sub    %edx,%eax
  801e93:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e9b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e9e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ea1:	83 c3 01             	add    $0x1,%ebx
  801ea4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ea7:	75 d8                	jne    801e81 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ea9:	8b 45 10             	mov    0x10(%ebp),%eax
  801eac:	eb 05                	jmp    801eb3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801eae:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801eb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eb6:	5b                   	pop    %ebx
  801eb7:	5e                   	pop    %esi
  801eb8:	5f                   	pop    %edi
  801eb9:	5d                   	pop    %ebp
  801eba:	c3                   	ret    

00801ebb <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ebb:	55                   	push   %ebp
  801ebc:	89 e5                	mov    %esp,%ebp
  801ebe:	56                   	push   %esi
  801ebf:	53                   	push   %ebx
  801ec0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ec3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec6:	50                   	push   %eax
  801ec7:	e8 cb f0 ff ff       	call   800f97 <fd_alloc>
  801ecc:	83 c4 10             	add    $0x10,%esp
  801ecf:	89 c2                	mov    %eax,%edx
  801ed1:	85 c0                	test   %eax,%eax
  801ed3:	0f 88 2c 01 00 00    	js     802005 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ed9:	83 ec 04             	sub    $0x4,%esp
  801edc:	68 07 04 00 00       	push   $0x407
  801ee1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ee4:	6a 00                	push   $0x0
  801ee6:	e8 9d ec ff ff       	call   800b88 <sys_page_alloc>
  801eeb:	83 c4 10             	add    $0x10,%esp
  801eee:	89 c2                	mov    %eax,%edx
  801ef0:	85 c0                	test   %eax,%eax
  801ef2:	0f 88 0d 01 00 00    	js     802005 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ef8:	83 ec 0c             	sub    $0xc,%esp
  801efb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801efe:	50                   	push   %eax
  801eff:	e8 93 f0 ff ff       	call   800f97 <fd_alloc>
  801f04:	89 c3                	mov    %eax,%ebx
  801f06:	83 c4 10             	add    $0x10,%esp
  801f09:	85 c0                	test   %eax,%eax
  801f0b:	0f 88 e2 00 00 00    	js     801ff3 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f11:	83 ec 04             	sub    $0x4,%esp
  801f14:	68 07 04 00 00       	push   $0x407
  801f19:	ff 75 f0             	pushl  -0x10(%ebp)
  801f1c:	6a 00                	push   $0x0
  801f1e:	e8 65 ec ff ff       	call   800b88 <sys_page_alloc>
  801f23:	89 c3                	mov    %eax,%ebx
  801f25:	83 c4 10             	add    $0x10,%esp
  801f28:	85 c0                	test   %eax,%eax
  801f2a:	0f 88 c3 00 00 00    	js     801ff3 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f30:	83 ec 0c             	sub    $0xc,%esp
  801f33:	ff 75 f4             	pushl  -0xc(%ebp)
  801f36:	e8 45 f0 ff ff       	call   800f80 <fd2data>
  801f3b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f3d:	83 c4 0c             	add    $0xc,%esp
  801f40:	68 07 04 00 00       	push   $0x407
  801f45:	50                   	push   %eax
  801f46:	6a 00                	push   $0x0
  801f48:	e8 3b ec ff ff       	call   800b88 <sys_page_alloc>
  801f4d:	89 c3                	mov    %eax,%ebx
  801f4f:	83 c4 10             	add    $0x10,%esp
  801f52:	85 c0                	test   %eax,%eax
  801f54:	0f 88 89 00 00 00    	js     801fe3 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f5a:	83 ec 0c             	sub    $0xc,%esp
  801f5d:	ff 75 f0             	pushl  -0x10(%ebp)
  801f60:	e8 1b f0 ff ff       	call   800f80 <fd2data>
  801f65:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f6c:	50                   	push   %eax
  801f6d:	6a 00                	push   $0x0
  801f6f:	56                   	push   %esi
  801f70:	6a 00                	push   $0x0
  801f72:	e8 54 ec ff ff       	call   800bcb <sys_page_map>
  801f77:	89 c3                	mov    %eax,%ebx
  801f79:	83 c4 20             	add    $0x20,%esp
  801f7c:	85 c0                	test   %eax,%eax
  801f7e:	78 55                	js     801fd5 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f80:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f89:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f95:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f9e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801fa0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fa3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801faa:	83 ec 0c             	sub    $0xc,%esp
  801fad:	ff 75 f4             	pushl  -0xc(%ebp)
  801fb0:	e8 bb ef ff ff       	call   800f70 <fd2num>
  801fb5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fb8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801fba:	83 c4 04             	add    $0x4,%esp
  801fbd:	ff 75 f0             	pushl  -0x10(%ebp)
  801fc0:	e8 ab ef ff ff       	call   800f70 <fd2num>
  801fc5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fc8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801fcb:	83 c4 10             	add    $0x10,%esp
  801fce:	ba 00 00 00 00       	mov    $0x0,%edx
  801fd3:	eb 30                	jmp    802005 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801fd5:	83 ec 08             	sub    $0x8,%esp
  801fd8:	56                   	push   %esi
  801fd9:	6a 00                	push   $0x0
  801fdb:	e8 2d ec ff ff       	call   800c0d <sys_page_unmap>
  801fe0:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801fe3:	83 ec 08             	sub    $0x8,%esp
  801fe6:	ff 75 f0             	pushl  -0x10(%ebp)
  801fe9:	6a 00                	push   $0x0
  801feb:	e8 1d ec ff ff       	call   800c0d <sys_page_unmap>
  801ff0:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ff3:	83 ec 08             	sub    $0x8,%esp
  801ff6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ff9:	6a 00                	push   $0x0
  801ffb:	e8 0d ec ff ff       	call   800c0d <sys_page_unmap>
  802000:	83 c4 10             	add    $0x10,%esp
  802003:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802005:	89 d0                	mov    %edx,%eax
  802007:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80200a:	5b                   	pop    %ebx
  80200b:	5e                   	pop    %esi
  80200c:	5d                   	pop    %ebp
  80200d:	c3                   	ret    

0080200e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80200e:	55                   	push   %ebp
  80200f:	89 e5                	mov    %esp,%ebp
  802011:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802014:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802017:	50                   	push   %eax
  802018:	ff 75 08             	pushl  0x8(%ebp)
  80201b:	e8 c6 ef ff ff       	call   800fe6 <fd_lookup>
  802020:	83 c4 10             	add    $0x10,%esp
  802023:	85 c0                	test   %eax,%eax
  802025:	78 18                	js     80203f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802027:	83 ec 0c             	sub    $0xc,%esp
  80202a:	ff 75 f4             	pushl  -0xc(%ebp)
  80202d:	e8 4e ef ff ff       	call   800f80 <fd2data>
	return _pipeisclosed(fd, p);
  802032:	89 c2                	mov    %eax,%edx
  802034:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802037:	e8 21 fd ff ff       	call   801d5d <_pipeisclosed>
  80203c:	83 c4 10             	add    $0x10,%esp
}
  80203f:	c9                   	leave  
  802040:	c3                   	ret    

00802041 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802041:	55                   	push   %ebp
  802042:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802044:	b8 00 00 00 00       	mov    $0x0,%eax
  802049:	5d                   	pop    %ebp
  80204a:	c3                   	ret    

0080204b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80204b:	55                   	push   %ebp
  80204c:	89 e5                	mov    %esp,%ebp
  80204e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802051:	68 67 2a 80 00       	push   $0x802a67
  802056:	ff 75 0c             	pushl  0xc(%ebp)
  802059:	e8 27 e7 ff ff       	call   800785 <strcpy>
	return 0;
}
  80205e:	b8 00 00 00 00       	mov    $0x0,%eax
  802063:	c9                   	leave  
  802064:	c3                   	ret    

00802065 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802065:	55                   	push   %ebp
  802066:	89 e5                	mov    %esp,%ebp
  802068:	57                   	push   %edi
  802069:	56                   	push   %esi
  80206a:	53                   	push   %ebx
  80206b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802071:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802076:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80207c:	eb 2d                	jmp    8020ab <devcons_write+0x46>
		m = n - tot;
  80207e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802081:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802083:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802086:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80208b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80208e:	83 ec 04             	sub    $0x4,%esp
  802091:	53                   	push   %ebx
  802092:	03 45 0c             	add    0xc(%ebp),%eax
  802095:	50                   	push   %eax
  802096:	57                   	push   %edi
  802097:	e8 7b e8 ff ff       	call   800917 <memmove>
		sys_cputs(buf, m);
  80209c:	83 c4 08             	add    $0x8,%esp
  80209f:	53                   	push   %ebx
  8020a0:	57                   	push   %edi
  8020a1:	e8 26 ea ff ff       	call   800acc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020a6:	01 de                	add    %ebx,%esi
  8020a8:	83 c4 10             	add    $0x10,%esp
  8020ab:	89 f0                	mov    %esi,%eax
  8020ad:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020b0:	72 cc                	jb     80207e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020b5:	5b                   	pop    %ebx
  8020b6:	5e                   	pop    %esi
  8020b7:	5f                   	pop    %edi
  8020b8:	5d                   	pop    %ebp
  8020b9:	c3                   	ret    

008020ba <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020ba:	55                   	push   %ebp
  8020bb:	89 e5                	mov    %esp,%ebp
  8020bd:	83 ec 08             	sub    $0x8,%esp
  8020c0:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8020c5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020c9:	74 2a                	je     8020f5 <devcons_read+0x3b>
  8020cb:	eb 05                	jmp    8020d2 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8020cd:	e8 97 ea ff ff       	call   800b69 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8020d2:	e8 13 ea ff ff       	call   800aea <sys_cgetc>
  8020d7:	85 c0                	test   %eax,%eax
  8020d9:	74 f2                	je     8020cd <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8020db:	85 c0                	test   %eax,%eax
  8020dd:	78 16                	js     8020f5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8020df:	83 f8 04             	cmp    $0x4,%eax
  8020e2:	74 0c                	je     8020f0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8020e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020e7:	88 02                	mov    %al,(%edx)
	return 1;
  8020e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8020ee:	eb 05                	jmp    8020f5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020f0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020f5:	c9                   	leave  
  8020f6:	c3                   	ret    

008020f7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020f7:	55                   	push   %ebp
  8020f8:	89 e5                	mov    %esp,%ebp
  8020fa:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020fd:	8b 45 08             	mov    0x8(%ebp),%eax
  802100:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802103:	6a 01                	push   $0x1
  802105:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802108:	50                   	push   %eax
  802109:	e8 be e9 ff ff       	call   800acc <sys_cputs>
}
  80210e:	83 c4 10             	add    $0x10,%esp
  802111:	c9                   	leave  
  802112:	c3                   	ret    

00802113 <getchar>:

int
getchar(void)
{
  802113:	55                   	push   %ebp
  802114:	89 e5                	mov    %esp,%ebp
  802116:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802119:	6a 01                	push   $0x1
  80211b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80211e:	50                   	push   %eax
  80211f:	6a 00                	push   $0x0
  802121:	e8 26 f1 ff ff       	call   80124c <read>
	if (r < 0)
  802126:	83 c4 10             	add    $0x10,%esp
  802129:	85 c0                	test   %eax,%eax
  80212b:	78 0f                	js     80213c <getchar+0x29>
		return r;
	if (r < 1)
  80212d:	85 c0                	test   %eax,%eax
  80212f:	7e 06                	jle    802137 <getchar+0x24>
		return -E_EOF;
	return c;
  802131:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802135:	eb 05                	jmp    80213c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802137:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80213c:	c9                   	leave  
  80213d:	c3                   	ret    

0080213e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80213e:	55                   	push   %ebp
  80213f:	89 e5                	mov    %esp,%ebp
  802141:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802144:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802147:	50                   	push   %eax
  802148:	ff 75 08             	pushl  0x8(%ebp)
  80214b:	e8 96 ee ff ff       	call   800fe6 <fd_lookup>
  802150:	83 c4 10             	add    $0x10,%esp
  802153:	85 c0                	test   %eax,%eax
  802155:	78 11                	js     802168 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802157:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80215a:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802160:	39 10                	cmp    %edx,(%eax)
  802162:	0f 94 c0             	sete   %al
  802165:	0f b6 c0             	movzbl %al,%eax
}
  802168:	c9                   	leave  
  802169:	c3                   	ret    

0080216a <opencons>:

int
opencons(void)
{
  80216a:	55                   	push   %ebp
  80216b:	89 e5                	mov    %esp,%ebp
  80216d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802170:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802173:	50                   	push   %eax
  802174:	e8 1e ee ff ff       	call   800f97 <fd_alloc>
  802179:	83 c4 10             	add    $0x10,%esp
		return r;
  80217c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80217e:	85 c0                	test   %eax,%eax
  802180:	78 3e                	js     8021c0 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802182:	83 ec 04             	sub    $0x4,%esp
  802185:	68 07 04 00 00       	push   $0x407
  80218a:	ff 75 f4             	pushl  -0xc(%ebp)
  80218d:	6a 00                	push   $0x0
  80218f:	e8 f4 e9 ff ff       	call   800b88 <sys_page_alloc>
  802194:	83 c4 10             	add    $0x10,%esp
		return r;
  802197:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802199:	85 c0                	test   %eax,%eax
  80219b:	78 23                	js     8021c0 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80219d:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8021a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021a6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ab:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021b2:	83 ec 0c             	sub    $0xc,%esp
  8021b5:	50                   	push   %eax
  8021b6:	e8 b5 ed ff ff       	call   800f70 <fd2num>
  8021bb:	89 c2                	mov    %eax,%edx
  8021bd:	83 c4 10             	add    $0x10,%esp
}
  8021c0:	89 d0                	mov    %edx,%eax
  8021c2:	c9                   	leave  
  8021c3:	c3                   	ret    

008021c4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8021c4:	55                   	push   %ebp
  8021c5:	89 e5                	mov    %esp,%ebp
  8021c7:	56                   	push   %esi
  8021c8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8021c9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8021cc:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8021d2:	e8 73 e9 ff ff       	call   800b4a <sys_getenvid>
  8021d7:	83 ec 0c             	sub    $0xc,%esp
  8021da:	ff 75 0c             	pushl  0xc(%ebp)
  8021dd:	ff 75 08             	pushl  0x8(%ebp)
  8021e0:	56                   	push   %esi
  8021e1:	50                   	push   %eax
  8021e2:	68 74 2a 80 00       	push   $0x802a74
  8021e7:	e8 14 e0 ff ff       	call   800200 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8021ec:	83 c4 18             	add    $0x18,%esp
  8021ef:	53                   	push   %ebx
  8021f0:	ff 75 10             	pushl  0x10(%ebp)
  8021f3:	e8 b7 df ff ff       	call   8001af <vcprintf>
	cprintf("\n");
  8021f8:	c7 04 24 f0 25 80 00 	movl   $0x8025f0,(%esp)
  8021ff:	e8 fc df ff ff       	call   800200 <cprintf>
  802204:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802207:	cc                   	int3   
  802208:	eb fd                	jmp    802207 <_panic+0x43>

0080220a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80220a:	55                   	push   %ebp
  80220b:	89 e5                	mov    %esp,%ebp
  80220d:	56                   	push   %esi
  80220e:	53                   	push   %ebx
  80220f:	8b 75 08             	mov    0x8(%ebp),%esi
  802212:	8b 45 0c             	mov    0xc(%ebp),%eax
  802215:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802218:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  80221a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80221f:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802222:	83 ec 0c             	sub    $0xc,%esp
  802225:	50                   	push   %eax
  802226:	e8 0d eb ff ff       	call   800d38 <sys_ipc_recv>

	if (from_env_store != NULL)
  80222b:	83 c4 10             	add    $0x10,%esp
  80222e:	85 f6                	test   %esi,%esi
  802230:	74 14                	je     802246 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802232:	ba 00 00 00 00       	mov    $0x0,%edx
  802237:	85 c0                	test   %eax,%eax
  802239:	78 09                	js     802244 <ipc_recv+0x3a>
  80223b:	8b 15 08 40 80 00    	mov    0x804008,%edx
  802241:	8b 52 74             	mov    0x74(%edx),%edx
  802244:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802246:	85 db                	test   %ebx,%ebx
  802248:	74 14                	je     80225e <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  80224a:	ba 00 00 00 00       	mov    $0x0,%edx
  80224f:	85 c0                	test   %eax,%eax
  802251:	78 09                	js     80225c <ipc_recv+0x52>
  802253:	8b 15 08 40 80 00    	mov    0x804008,%edx
  802259:	8b 52 78             	mov    0x78(%edx),%edx
  80225c:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80225e:	85 c0                	test   %eax,%eax
  802260:	78 08                	js     80226a <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802262:	a1 08 40 80 00       	mov    0x804008,%eax
  802267:	8b 40 70             	mov    0x70(%eax),%eax
}
  80226a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80226d:	5b                   	pop    %ebx
  80226e:	5e                   	pop    %esi
  80226f:	5d                   	pop    %ebp
  802270:	c3                   	ret    

00802271 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802271:	55                   	push   %ebp
  802272:	89 e5                	mov    %esp,%ebp
  802274:	57                   	push   %edi
  802275:	56                   	push   %esi
  802276:	53                   	push   %ebx
  802277:	83 ec 0c             	sub    $0xc,%esp
  80227a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80227d:	8b 75 0c             	mov    0xc(%ebp),%esi
  802280:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  802283:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802285:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80228a:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80228d:	ff 75 14             	pushl  0x14(%ebp)
  802290:	53                   	push   %ebx
  802291:	56                   	push   %esi
  802292:	57                   	push   %edi
  802293:	e8 7d ea ff ff       	call   800d15 <sys_ipc_try_send>

		if (err < 0) {
  802298:	83 c4 10             	add    $0x10,%esp
  80229b:	85 c0                	test   %eax,%eax
  80229d:	79 1e                	jns    8022bd <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  80229f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022a2:	75 07                	jne    8022ab <ipc_send+0x3a>
				sys_yield();
  8022a4:	e8 c0 e8 ff ff       	call   800b69 <sys_yield>
  8022a9:	eb e2                	jmp    80228d <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8022ab:	50                   	push   %eax
  8022ac:	68 98 2a 80 00       	push   $0x802a98
  8022b1:	6a 49                	push   $0x49
  8022b3:	68 a5 2a 80 00       	push   $0x802aa5
  8022b8:	e8 07 ff ff ff       	call   8021c4 <_panic>
		}

	} while (err < 0);

}
  8022bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022c0:	5b                   	pop    %ebx
  8022c1:	5e                   	pop    %esi
  8022c2:	5f                   	pop    %edi
  8022c3:	5d                   	pop    %ebp
  8022c4:	c3                   	ret    

008022c5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022c5:	55                   	push   %ebp
  8022c6:	89 e5                	mov    %esp,%ebp
  8022c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8022cb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022d0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8022d3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022d9:	8b 52 50             	mov    0x50(%edx),%edx
  8022dc:	39 ca                	cmp    %ecx,%edx
  8022de:	75 0d                	jne    8022ed <ipc_find_env+0x28>
			return envs[i].env_id;
  8022e0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8022e3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8022e8:	8b 40 48             	mov    0x48(%eax),%eax
  8022eb:	eb 0f                	jmp    8022fc <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022ed:	83 c0 01             	add    $0x1,%eax
  8022f0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022f5:	75 d9                	jne    8022d0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022fc:	5d                   	pop    %ebp
  8022fd:	c3                   	ret    

008022fe <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022fe:	55                   	push   %ebp
  8022ff:	89 e5                	mov    %esp,%ebp
  802301:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802304:	89 d0                	mov    %edx,%eax
  802306:	c1 e8 16             	shr    $0x16,%eax
  802309:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802310:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802315:	f6 c1 01             	test   $0x1,%cl
  802318:	74 1d                	je     802337 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80231a:	c1 ea 0c             	shr    $0xc,%edx
  80231d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802324:	f6 c2 01             	test   $0x1,%dl
  802327:	74 0e                	je     802337 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802329:	c1 ea 0c             	shr    $0xc,%edx
  80232c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802333:	ef 
  802334:	0f b7 c0             	movzwl %ax,%eax
}
  802337:	5d                   	pop    %ebp
  802338:	c3                   	ret    
  802339:	66 90                	xchg   %ax,%ax
  80233b:	66 90                	xchg   %ax,%ax
  80233d:	66 90                	xchg   %ax,%ax
  80233f:	90                   	nop

00802340 <__udivdi3>:
  802340:	55                   	push   %ebp
  802341:	57                   	push   %edi
  802342:	56                   	push   %esi
  802343:	53                   	push   %ebx
  802344:	83 ec 1c             	sub    $0x1c,%esp
  802347:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80234b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80234f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802353:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802357:	85 f6                	test   %esi,%esi
  802359:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80235d:	89 ca                	mov    %ecx,%edx
  80235f:	89 f8                	mov    %edi,%eax
  802361:	75 3d                	jne    8023a0 <__udivdi3+0x60>
  802363:	39 cf                	cmp    %ecx,%edi
  802365:	0f 87 c5 00 00 00    	ja     802430 <__udivdi3+0xf0>
  80236b:	85 ff                	test   %edi,%edi
  80236d:	89 fd                	mov    %edi,%ebp
  80236f:	75 0b                	jne    80237c <__udivdi3+0x3c>
  802371:	b8 01 00 00 00       	mov    $0x1,%eax
  802376:	31 d2                	xor    %edx,%edx
  802378:	f7 f7                	div    %edi
  80237a:	89 c5                	mov    %eax,%ebp
  80237c:	89 c8                	mov    %ecx,%eax
  80237e:	31 d2                	xor    %edx,%edx
  802380:	f7 f5                	div    %ebp
  802382:	89 c1                	mov    %eax,%ecx
  802384:	89 d8                	mov    %ebx,%eax
  802386:	89 cf                	mov    %ecx,%edi
  802388:	f7 f5                	div    %ebp
  80238a:	89 c3                	mov    %eax,%ebx
  80238c:	89 d8                	mov    %ebx,%eax
  80238e:	89 fa                	mov    %edi,%edx
  802390:	83 c4 1c             	add    $0x1c,%esp
  802393:	5b                   	pop    %ebx
  802394:	5e                   	pop    %esi
  802395:	5f                   	pop    %edi
  802396:	5d                   	pop    %ebp
  802397:	c3                   	ret    
  802398:	90                   	nop
  802399:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023a0:	39 ce                	cmp    %ecx,%esi
  8023a2:	77 74                	ja     802418 <__udivdi3+0xd8>
  8023a4:	0f bd fe             	bsr    %esi,%edi
  8023a7:	83 f7 1f             	xor    $0x1f,%edi
  8023aa:	0f 84 98 00 00 00    	je     802448 <__udivdi3+0x108>
  8023b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8023b5:	89 f9                	mov    %edi,%ecx
  8023b7:	89 c5                	mov    %eax,%ebp
  8023b9:	29 fb                	sub    %edi,%ebx
  8023bb:	d3 e6                	shl    %cl,%esi
  8023bd:	89 d9                	mov    %ebx,%ecx
  8023bf:	d3 ed                	shr    %cl,%ebp
  8023c1:	89 f9                	mov    %edi,%ecx
  8023c3:	d3 e0                	shl    %cl,%eax
  8023c5:	09 ee                	or     %ebp,%esi
  8023c7:	89 d9                	mov    %ebx,%ecx
  8023c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023cd:	89 d5                	mov    %edx,%ebp
  8023cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023d3:	d3 ed                	shr    %cl,%ebp
  8023d5:	89 f9                	mov    %edi,%ecx
  8023d7:	d3 e2                	shl    %cl,%edx
  8023d9:	89 d9                	mov    %ebx,%ecx
  8023db:	d3 e8                	shr    %cl,%eax
  8023dd:	09 c2                	or     %eax,%edx
  8023df:	89 d0                	mov    %edx,%eax
  8023e1:	89 ea                	mov    %ebp,%edx
  8023e3:	f7 f6                	div    %esi
  8023e5:	89 d5                	mov    %edx,%ebp
  8023e7:	89 c3                	mov    %eax,%ebx
  8023e9:	f7 64 24 0c          	mull   0xc(%esp)
  8023ed:	39 d5                	cmp    %edx,%ebp
  8023ef:	72 10                	jb     802401 <__udivdi3+0xc1>
  8023f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8023f5:	89 f9                	mov    %edi,%ecx
  8023f7:	d3 e6                	shl    %cl,%esi
  8023f9:	39 c6                	cmp    %eax,%esi
  8023fb:	73 07                	jae    802404 <__udivdi3+0xc4>
  8023fd:	39 d5                	cmp    %edx,%ebp
  8023ff:	75 03                	jne    802404 <__udivdi3+0xc4>
  802401:	83 eb 01             	sub    $0x1,%ebx
  802404:	31 ff                	xor    %edi,%edi
  802406:	89 d8                	mov    %ebx,%eax
  802408:	89 fa                	mov    %edi,%edx
  80240a:	83 c4 1c             	add    $0x1c,%esp
  80240d:	5b                   	pop    %ebx
  80240e:	5e                   	pop    %esi
  80240f:	5f                   	pop    %edi
  802410:	5d                   	pop    %ebp
  802411:	c3                   	ret    
  802412:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802418:	31 ff                	xor    %edi,%edi
  80241a:	31 db                	xor    %ebx,%ebx
  80241c:	89 d8                	mov    %ebx,%eax
  80241e:	89 fa                	mov    %edi,%edx
  802420:	83 c4 1c             	add    $0x1c,%esp
  802423:	5b                   	pop    %ebx
  802424:	5e                   	pop    %esi
  802425:	5f                   	pop    %edi
  802426:	5d                   	pop    %ebp
  802427:	c3                   	ret    
  802428:	90                   	nop
  802429:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802430:	89 d8                	mov    %ebx,%eax
  802432:	f7 f7                	div    %edi
  802434:	31 ff                	xor    %edi,%edi
  802436:	89 c3                	mov    %eax,%ebx
  802438:	89 d8                	mov    %ebx,%eax
  80243a:	89 fa                	mov    %edi,%edx
  80243c:	83 c4 1c             	add    $0x1c,%esp
  80243f:	5b                   	pop    %ebx
  802440:	5e                   	pop    %esi
  802441:	5f                   	pop    %edi
  802442:	5d                   	pop    %ebp
  802443:	c3                   	ret    
  802444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802448:	39 ce                	cmp    %ecx,%esi
  80244a:	72 0c                	jb     802458 <__udivdi3+0x118>
  80244c:	31 db                	xor    %ebx,%ebx
  80244e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802452:	0f 87 34 ff ff ff    	ja     80238c <__udivdi3+0x4c>
  802458:	bb 01 00 00 00       	mov    $0x1,%ebx
  80245d:	e9 2a ff ff ff       	jmp    80238c <__udivdi3+0x4c>
  802462:	66 90                	xchg   %ax,%ax
  802464:	66 90                	xchg   %ax,%ax
  802466:	66 90                	xchg   %ax,%ax
  802468:	66 90                	xchg   %ax,%ax
  80246a:	66 90                	xchg   %ax,%ax
  80246c:	66 90                	xchg   %ax,%ax
  80246e:	66 90                	xchg   %ax,%ax

00802470 <__umoddi3>:
  802470:	55                   	push   %ebp
  802471:	57                   	push   %edi
  802472:	56                   	push   %esi
  802473:	53                   	push   %ebx
  802474:	83 ec 1c             	sub    $0x1c,%esp
  802477:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80247b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80247f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802483:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802487:	85 d2                	test   %edx,%edx
  802489:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80248d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802491:	89 f3                	mov    %esi,%ebx
  802493:	89 3c 24             	mov    %edi,(%esp)
  802496:	89 74 24 04          	mov    %esi,0x4(%esp)
  80249a:	75 1c                	jne    8024b8 <__umoddi3+0x48>
  80249c:	39 f7                	cmp    %esi,%edi
  80249e:	76 50                	jbe    8024f0 <__umoddi3+0x80>
  8024a0:	89 c8                	mov    %ecx,%eax
  8024a2:	89 f2                	mov    %esi,%edx
  8024a4:	f7 f7                	div    %edi
  8024a6:	89 d0                	mov    %edx,%eax
  8024a8:	31 d2                	xor    %edx,%edx
  8024aa:	83 c4 1c             	add    $0x1c,%esp
  8024ad:	5b                   	pop    %ebx
  8024ae:	5e                   	pop    %esi
  8024af:	5f                   	pop    %edi
  8024b0:	5d                   	pop    %ebp
  8024b1:	c3                   	ret    
  8024b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024b8:	39 f2                	cmp    %esi,%edx
  8024ba:	89 d0                	mov    %edx,%eax
  8024bc:	77 52                	ja     802510 <__umoddi3+0xa0>
  8024be:	0f bd ea             	bsr    %edx,%ebp
  8024c1:	83 f5 1f             	xor    $0x1f,%ebp
  8024c4:	75 5a                	jne    802520 <__umoddi3+0xb0>
  8024c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8024ca:	0f 82 e0 00 00 00    	jb     8025b0 <__umoddi3+0x140>
  8024d0:	39 0c 24             	cmp    %ecx,(%esp)
  8024d3:	0f 86 d7 00 00 00    	jbe    8025b0 <__umoddi3+0x140>
  8024d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024e1:	83 c4 1c             	add    $0x1c,%esp
  8024e4:	5b                   	pop    %ebx
  8024e5:	5e                   	pop    %esi
  8024e6:	5f                   	pop    %edi
  8024e7:	5d                   	pop    %ebp
  8024e8:	c3                   	ret    
  8024e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024f0:	85 ff                	test   %edi,%edi
  8024f2:	89 fd                	mov    %edi,%ebp
  8024f4:	75 0b                	jne    802501 <__umoddi3+0x91>
  8024f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024fb:	31 d2                	xor    %edx,%edx
  8024fd:	f7 f7                	div    %edi
  8024ff:	89 c5                	mov    %eax,%ebp
  802501:	89 f0                	mov    %esi,%eax
  802503:	31 d2                	xor    %edx,%edx
  802505:	f7 f5                	div    %ebp
  802507:	89 c8                	mov    %ecx,%eax
  802509:	f7 f5                	div    %ebp
  80250b:	89 d0                	mov    %edx,%eax
  80250d:	eb 99                	jmp    8024a8 <__umoddi3+0x38>
  80250f:	90                   	nop
  802510:	89 c8                	mov    %ecx,%eax
  802512:	89 f2                	mov    %esi,%edx
  802514:	83 c4 1c             	add    $0x1c,%esp
  802517:	5b                   	pop    %ebx
  802518:	5e                   	pop    %esi
  802519:	5f                   	pop    %edi
  80251a:	5d                   	pop    %ebp
  80251b:	c3                   	ret    
  80251c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802520:	8b 34 24             	mov    (%esp),%esi
  802523:	bf 20 00 00 00       	mov    $0x20,%edi
  802528:	89 e9                	mov    %ebp,%ecx
  80252a:	29 ef                	sub    %ebp,%edi
  80252c:	d3 e0                	shl    %cl,%eax
  80252e:	89 f9                	mov    %edi,%ecx
  802530:	89 f2                	mov    %esi,%edx
  802532:	d3 ea                	shr    %cl,%edx
  802534:	89 e9                	mov    %ebp,%ecx
  802536:	09 c2                	or     %eax,%edx
  802538:	89 d8                	mov    %ebx,%eax
  80253a:	89 14 24             	mov    %edx,(%esp)
  80253d:	89 f2                	mov    %esi,%edx
  80253f:	d3 e2                	shl    %cl,%edx
  802541:	89 f9                	mov    %edi,%ecx
  802543:	89 54 24 04          	mov    %edx,0x4(%esp)
  802547:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80254b:	d3 e8                	shr    %cl,%eax
  80254d:	89 e9                	mov    %ebp,%ecx
  80254f:	89 c6                	mov    %eax,%esi
  802551:	d3 e3                	shl    %cl,%ebx
  802553:	89 f9                	mov    %edi,%ecx
  802555:	89 d0                	mov    %edx,%eax
  802557:	d3 e8                	shr    %cl,%eax
  802559:	89 e9                	mov    %ebp,%ecx
  80255b:	09 d8                	or     %ebx,%eax
  80255d:	89 d3                	mov    %edx,%ebx
  80255f:	89 f2                	mov    %esi,%edx
  802561:	f7 34 24             	divl   (%esp)
  802564:	89 d6                	mov    %edx,%esi
  802566:	d3 e3                	shl    %cl,%ebx
  802568:	f7 64 24 04          	mull   0x4(%esp)
  80256c:	39 d6                	cmp    %edx,%esi
  80256e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802572:	89 d1                	mov    %edx,%ecx
  802574:	89 c3                	mov    %eax,%ebx
  802576:	72 08                	jb     802580 <__umoddi3+0x110>
  802578:	75 11                	jne    80258b <__umoddi3+0x11b>
  80257a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80257e:	73 0b                	jae    80258b <__umoddi3+0x11b>
  802580:	2b 44 24 04          	sub    0x4(%esp),%eax
  802584:	1b 14 24             	sbb    (%esp),%edx
  802587:	89 d1                	mov    %edx,%ecx
  802589:	89 c3                	mov    %eax,%ebx
  80258b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80258f:	29 da                	sub    %ebx,%edx
  802591:	19 ce                	sbb    %ecx,%esi
  802593:	89 f9                	mov    %edi,%ecx
  802595:	89 f0                	mov    %esi,%eax
  802597:	d3 e0                	shl    %cl,%eax
  802599:	89 e9                	mov    %ebp,%ecx
  80259b:	d3 ea                	shr    %cl,%edx
  80259d:	89 e9                	mov    %ebp,%ecx
  80259f:	d3 ee                	shr    %cl,%esi
  8025a1:	09 d0                	or     %edx,%eax
  8025a3:	89 f2                	mov    %esi,%edx
  8025a5:	83 c4 1c             	add    $0x1c,%esp
  8025a8:	5b                   	pop    %ebx
  8025a9:	5e                   	pop    %esi
  8025aa:	5f                   	pop    %edi
  8025ab:	5d                   	pop    %ebp
  8025ac:	c3                   	ret    
  8025ad:	8d 76 00             	lea    0x0(%esi),%esi
  8025b0:	29 f9                	sub    %edi,%ecx
  8025b2:	19 d6                	sbb    %edx,%esi
  8025b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025bc:	e9 18 ff ff ff       	jmp    8024d9 <__umoddi3+0x69>
