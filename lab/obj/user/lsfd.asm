
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
  800039:	68 a0 25 80 00       	push   $0x8025a0
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
  800067:	e8 6e 0d 00 00       	call   800dda <argstart>
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
  800091:	e8 74 0d 00 00       	call   800e0a <argnext>
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
  8000ad:	e8 70 13 00 00       	call   801422 <fstat>
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
  8000ce:	68 b4 25 80 00       	push   $0x8025b4
  8000d3:	6a 01                	push   $0x1
  8000d5:	e8 35 17 00 00       	call   80180f <fprintf>
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
  8000f0:	68 b4 25 80 00       	push   $0x8025b4
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
  800159:	e8 9b 0f 00 00       	call   8010f9 <close_all>
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
  800263:	e8 98 20 00 00       	call   802300 <__udivdi3>
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
  8002a6:	e8 85 21 00 00       	call   802430 <__umoddi3>
  8002ab:	83 c4 14             	add    $0x14,%esp
  8002ae:	0f be 80 e6 25 80 00 	movsbl 0x8025e6(%eax),%eax
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
  8003aa:	ff 24 85 20 27 80 00 	jmp    *0x802720(,%eax,4)
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
  80046e:	8b 14 85 80 28 80 00 	mov    0x802880(,%eax,4),%edx
  800475:	85 d2                	test   %edx,%edx
  800477:	75 18                	jne    800491 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800479:	50                   	push   %eax
  80047a:	68 fe 25 80 00       	push   $0x8025fe
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
  800492:	68 b5 29 80 00       	push   $0x8029b5
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
  8004b6:	b8 f7 25 80 00       	mov    $0x8025f7,%eax
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
  800b31:	68 df 28 80 00       	push   $0x8028df
  800b36:	6a 23                	push   $0x23
  800b38:	68 fc 28 80 00       	push   $0x8028fc
  800b3d:	e8 40 16 00 00       	call   802182 <_panic>

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
  800bb2:	68 df 28 80 00       	push   $0x8028df
  800bb7:	6a 23                	push   $0x23
  800bb9:	68 fc 28 80 00       	push   $0x8028fc
  800bbe:	e8 bf 15 00 00       	call   802182 <_panic>

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
  800bf4:	68 df 28 80 00       	push   $0x8028df
  800bf9:	6a 23                	push   $0x23
  800bfb:	68 fc 28 80 00       	push   $0x8028fc
  800c00:	e8 7d 15 00 00       	call   802182 <_panic>

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
  800c36:	68 df 28 80 00       	push   $0x8028df
  800c3b:	6a 23                	push   $0x23
  800c3d:	68 fc 28 80 00       	push   $0x8028fc
  800c42:	e8 3b 15 00 00       	call   802182 <_panic>

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
  800c78:	68 df 28 80 00       	push   $0x8028df
  800c7d:	6a 23                	push   $0x23
  800c7f:	68 fc 28 80 00       	push   $0x8028fc
  800c84:	e8 f9 14 00 00       	call   802182 <_panic>

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
  800cba:	68 df 28 80 00       	push   $0x8028df
  800cbf:	6a 23                	push   $0x23
  800cc1:	68 fc 28 80 00       	push   $0x8028fc
  800cc6:	e8 b7 14 00 00       	call   802182 <_panic>

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
  800cfc:	68 df 28 80 00       	push   $0x8028df
  800d01:	6a 23                	push   $0x23
  800d03:	68 fc 28 80 00       	push   $0x8028fc
  800d08:	e8 75 14 00 00       	call   802182 <_panic>

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
  800d60:	68 df 28 80 00       	push   $0x8028df
  800d65:	6a 23                	push   $0x23
  800d67:	68 fc 28 80 00       	push   $0x8028fc
  800d6c:	e8 11 14 00 00       	call   802182 <_panic>

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
  800dc1:	68 df 28 80 00       	push   $0x8028df
  800dc6:	6a 23                	push   $0x23
  800dc8:	68 fc 28 80 00       	push   $0x8028fc
  800dcd:	e8 b0 13 00 00       	call   802182 <_panic>

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

00800dda <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	8b 55 08             	mov    0x8(%ebp),%edx
  800de0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de3:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800de6:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800de8:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800deb:	83 3a 01             	cmpl   $0x1,(%edx)
  800dee:	7e 09                	jle    800df9 <argstart+0x1f>
  800df0:	ba b1 25 80 00       	mov    $0x8025b1,%edx
  800df5:	85 c9                	test   %ecx,%ecx
  800df7:	75 05                	jne    800dfe <argstart+0x24>
  800df9:	ba 00 00 00 00       	mov    $0x0,%edx
  800dfe:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800e01:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <argnext>:

int
argnext(struct Argstate *args)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	53                   	push   %ebx
  800e0e:	83 ec 04             	sub    $0x4,%esp
  800e11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800e14:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800e1b:	8b 43 08             	mov    0x8(%ebx),%eax
  800e1e:	85 c0                	test   %eax,%eax
  800e20:	74 6f                	je     800e91 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  800e22:	80 38 00             	cmpb   $0x0,(%eax)
  800e25:	75 4e                	jne    800e75 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800e27:	8b 0b                	mov    (%ebx),%ecx
  800e29:	83 39 01             	cmpl   $0x1,(%ecx)
  800e2c:	74 55                	je     800e83 <argnext+0x79>
		    || args->argv[1][0] != '-'
  800e2e:	8b 53 04             	mov    0x4(%ebx),%edx
  800e31:	8b 42 04             	mov    0x4(%edx),%eax
  800e34:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e37:	75 4a                	jne    800e83 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  800e39:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e3d:	74 44                	je     800e83 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800e3f:	83 c0 01             	add    $0x1,%eax
  800e42:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800e45:	83 ec 04             	sub    $0x4,%esp
  800e48:	8b 01                	mov    (%ecx),%eax
  800e4a:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800e51:	50                   	push   %eax
  800e52:	8d 42 08             	lea    0x8(%edx),%eax
  800e55:	50                   	push   %eax
  800e56:	83 c2 04             	add    $0x4,%edx
  800e59:	52                   	push   %edx
  800e5a:	e8 b8 fa ff ff       	call   800917 <memmove>
		(*args->argc)--;
  800e5f:	8b 03                	mov    (%ebx),%eax
  800e61:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800e64:	8b 43 08             	mov    0x8(%ebx),%eax
  800e67:	83 c4 10             	add    $0x10,%esp
  800e6a:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e6d:	75 06                	jne    800e75 <argnext+0x6b>
  800e6f:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e73:	74 0e                	je     800e83 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800e75:	8b 53 08             	mov    0x8(%ebx),%edx
  800e78:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800e7b:	83 c2 01             	add    $0x1,%edx
  800e7e:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800e81:	eb 13                	jmp    800e96 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  800e83:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800e8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800e8f:	eb 05                	jmp    800e96 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  800e91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800e96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e99:	c9                   	leave  
  800e9a:	c3                   	ret    

00800e9b <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	53                   	push   %ebx
  800e9f:	83 ec 04             	sub    $0x4,%esp
  800ea2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800ea5:	8b 43 08             	mov    0x8(%ebx),%eax
  800ea8:	85 c0                	test   %eax,%eax
  800eaa:	74 58                	je     800f04 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  800eac:	80 38 00             	cmpb   $0x0,(%eax)
  800eaf:	74 0c                	je     800ebd <argnextvalue+0x22>
		args->argvalue = args->curarg;
  800eb1:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800eb4:	c7 43 08 b1 25 80 00 	movl   $0x8025b1,0x8(%ebx)
  800ebb:	eb 42                	jmp    800eff <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  800ebd:	8b 13                	mov    (%ebx),%edx
  800ebf:	83 3a 01             	cmpl   $0x1,(%edx)
  800ec2:	7e 2d                	jle    800ef1 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  800ec4:	8b 43 04             	mov    0x4(%ebx),%eax
  800ec7:	8b 48 04             	mov    0x4(%eax),%ecx
  800eca:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800ecd:	83 ec 04             	sub    $0x4,%esp
  800ed0:	8b 12                	mov    (%edx),%edx
  800ed2:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  800ed9:	52                   	push   %edx
  800eda:	8d 50 08             	lea    0x8(%eax),%edx
  800edd:	52                   	push   %edx
  800ede:	83 c0 04             	add    $0x4,%eax
  800ee1:	50                   	push   %eax
  800ee2:	e8 30 fa ff ff       	call   800917 <memmove>
		(*args->argc)--;
  800ee7:	8b 03                	mov    (%ebx),%eax
  800ee9:	83 28 01             	subl   $0x1,(%eax)
  800eec:	83 c4 10             	add    $0x10,%esp
  800eef:	eb 0e                	jmp    800eff <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  800ef1:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800ef8:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800eff:	8b 43 0c             	mov    0xc(%ebx),%eax
  800f02:	eb 05                	jmp    800f09 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  800f04:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  800f09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f0c:	c9                   	leave  
  800f0d:	c3                   	ret    

00800f0e <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800f0e:	55                   	push   %ebp
  800f0f:	89 e5                	mov    %esp,%ebp
  800f11:	83 ec 08             	sub    $0x8,%esp
  800f14:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800f17:	8b 51 0c             	mov    0xc(%ecx),%edx
  800f1a:	89 d0                	mov    %edx,%eax
  800f1c:	85 d2                	test   %edx,%edx
  800f1e:	75 0c                	jne    800f2c <argvalue+0x1e>
  800f20:	83 ec 0c             	sub    $0xc,%esp
  800f23:	51                   	push   %ecx
  800f24:	e8 72 ff ff ff       	call   800e9b <argnextvalue>
  800f29:	83 c4 10             	add    $0x10,%esp
}
  800f2c:	c9                   	leave  
  800f2d:	c3                   	ret    

00800f2e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f2e:	55                   	push   %ebp
  800f2f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f31:	8b 45 08             	mov    0x8(%ebp),%eax
  800f34:	05 00 00 00 30       	add    $0x30000000,%eax
  800f39:	c1 e8 0c             	shr    $0xc,%eax
}
  800f3c:	5d                   	pop    %ebp
  800f3d:	c3                   	ret    

00800f3e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f3e:	55                   	push   %ebp
  800f3f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800f41:	8b 45 08             	mov    0x8(%ebp),%eax
  800f44:	05 00 00 00 30       	add    $0x30000000,%eax
  800f49:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f4e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f53:	5d                   	pop    %ebp
  800f54:	c3                   	ret    

00800f55 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f55:	55                   	push   %ebp
  800f56:	89 e5                	mov    %esp,%ebp
  800f58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f5b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f60:	89 c2                	mov    %eax,%edx
  800f62:	c1 ea 16             	shr    $0x16,%edx
  800f65:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f6c:	f6 c2 01             	test   $0x1,%dl
  800f6f:	74 11                	je     800f82 <fd_alloc+0x2d>
  800f71:	89 c2                	mov    %eax,%edx
  800f73:	c1 ea 0c             	shr    $0xc,%edx
  800f76:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f7d:	f6 c2 01             	test   $0x1,%dl
  800f80:	75 09                	jne    800f8b <fd_alloc+0x36>
			*fd_store = fd;
  800f82:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f84:	b8 00 00 00 00       	mov    $0x0,%eax
  800f89:	eb 17                	jmp    800fa2 <fd_alloc+0x4d>
  800f8b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f90:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f95:	75 c9                	jne    800f60 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f97:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f9d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fa2:	5d                   	pop    %ebp
  800fa3:	c3                   	ret    

00800fa4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800faa:	83 f8 1f             	cmp    $0x1f,%eax
  800fad:	77 36                	ja     800fe5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800faf:	c1 e0 0c             	shl    $0xc,%eax
  800fb2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fb7:	89 c2                	mov    %eax,%edx
  800fb9:	c1 ea 16             	shr    $0x16,%edx
  800fbc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fc3:	f6 c2 01             	test   $0x1,%dl
  800fc6:	74 24                	je     800fec <fd_lookup+0x48>
  800fc8:	89 c2                	mov    %eax,%edx
  800fca:	c1 ea 0c             	shr    $0xc,%edx
  800fcd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fd4:	f6 c2 01             	test   $0x1,%dl
  800fd7:	74 1a                	je     800ff3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fd9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fdc:	89 02                	mov    %eax,(%edx)
	return 0;
  800fde:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe3:	eb 13                	jmp    800ff8 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fe5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fea:	eb 0c                	jmp    800ff8 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ff1:	eb 05                	jmp    800ff8 <fd_lookup+0x54>
  800ff3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ff8:	5d                   	pop    %ebp
  800ff9:	c3                   	ret    

00800ffa <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ffa:	55                   	push   %ebp
  800ffb:	89 e5                	mov    %esp,%ebp
  800ffd:	83 ec 08             	sub    $0x8,%esp
  801000:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801003:	ba 88 29 80 00       	mov    $0x802988,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801008:	eb 13                	jmp    80101d <dev_lookup+0x23>
  80100a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80100d:	39 08                	cmp    %ecx,(%eax)
  80100f:	75 0c                	jne    80101d <dev_lookup+0x23>
			*dev = devtab[i];
  801011:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801014:	89 01                	mov    %eax,(%ecx)
			return 0;
  801016:	b8 00 00 00 00       	mov    $0x0,%eax
  80101b:	eb 2e                	jmp    80104b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80101d:	8b 02                	mov    (%edx),%eax
  80101f:	85 c0                	test   %eax,%eax
  801021:	75 e7                	jne    80100a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801023:	a1 08 40 80 00       	mov    0x804008,%eax
  801028:	8b 40 48             	mov    0x48(%eax),%eax
  80102b:	83 ec 04             	sub    $0x4,%esp
  80102e:	51                   	push   %ecx
  80102f:	50                   	push   %eax
  801030:	68 0c 29 80 00       	push   $0x80290c
  801035:	e8 c6 f1 ff ff       	call   800200 <cprintf>
	*dev = 0;
  80103a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80103d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801043:	83 c4 10             	add    $0x10,%esp
  801046:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80104b:	c9                   	leave  
  80104c:	c3                   	ret    

0080104d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80104d:	55                   	push   %ebp
  80104e:	89 e5                	mov    %esp,%ebp
  801050:	56                   	push   %esi
  801051:	53                   	push   %ebx
  801052:	83 ec 10             	sub    $0x10,%esp
  801055:	8b 75 08             	mov    0x8(%ebp),%esi
  801058:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80105b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80105e:	50                   	push   %eax
  80105f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801065:	c1 e8 0c             	shr    $0xc,%eax
  801068:	50                   	push   %eax
  801069:	e8 36 ff ff ff       	call   800fa4 <fd_lookup>
  80106e:	83 c4 08             	add    $0x8,%esp
  801071:	85 c0                	test   %eax,%eax
  801073:	78 05                	js     80107a <fd_close+0x2d>
	    || fd != fd2)
  801075:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801078:	74 0c                	je     801086 <fd_close+0x39>
		return (must_exist ? r : 0);
  80107a:	84 db                	test   %bl,%bl
  80107c:	ba 00 00 00 00       	mov    $0x0,%edx
  801081:	0f 44 c2             	cmove  %edx,%eax
  801084:	eb 41                	jmp    8010c7 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801086:	83 ec 08             	sub    $0x8,%esp
  801089:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80108c:	50                   	push   %eax
  80108d:	ff 36                	pushl  (%esi)
  80108f:	e8 66 ff ff ff       	call   800ffa <dev_lookup>
  801094:	89 c3                	mov    %eax,%ebx
  801096:	83 c4 10             	add    $0x10,%esp
  801099:	85 c0                	test   %eax,%eax
  80109b:	78 1a                	js     8010b7 <fd_close+0x6a>
		if (dev->dev_close)
  80109d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010a0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8010a3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8010a8:	85 c0                	test   %eax,%eax
  8010aa:	74 0b                	je     8010b7 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8010ac:	83 ec 0c             	sub    $0xc,%esp
  8010af:	56                   	push   %esi
  8010b0:	ff d0                	call   *%eax
  8010b2:	89 c3                	mov    %eax,%ebx
  8010b4:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010b7:	83 ec 08             	sub    $0x8,%esp
  8010ba:	56                   	push   %esi
  8010bb:	6a 00                	push   $0x0
  8010bd:	e8 4b fb ff ff       	call   800c0d <sys_page_unmap>
	return r;
  8010c2:	83 c4 10             	add    $0x10,%esp
  8010c5:	89 d8                	mov    %ebx,%eax
}
  8010c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010ca:	5b                   	pop    %ebx
  8010cb:	5e                   	pop    %esi
  8010cc:	5d                   	pop    %ebp
  8010cd:	c3                   	ret    

008010ce <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010ce:	55                   	push   %ebp
  8010cf:	89 e5                	mov    %esp,%ebp
  8010d1:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010d7:	50                   	push   %eax
  8010d8:	ff 75 08             	pushl  0x8(%ebp)
  8010db:	e8 c4 fe ff ff       	call   800fa4 <fd_lookup>
  8010e0:	83 c4 08             	add    $0x8,%esp
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	78 10                	js     8010f7 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8010e7:	83 ec 08             	sub    $0x8,%esp
  8010ea:	6a 01                	push   $0x1
  8010ec:	ff 75 f4             	pushl  -0xc(%ebp)
  8010ef:	e8 59 ff ff ff       	call   80104d <fd_close>
  8010f4:	83 c4 10             	add    $0x10,%esp
}
  8010f7:	c9                   	leave  
  8010f8:	c3                   	ret    

008010f9 <close_all>:

void
close_all(void)
{
  8010f9:	55                   	push   %ebp
  8010fa:	89 e5                	mov    %esp,%ebp
  8010fc:	53                   	push   %ebx
  8010fd:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801100:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801105:	83 ec 0c             	sub    $0xc,%esp
  801108:	53                   	push   %ebx
  801109:	e8 c0 ff ff ff       	call   8010ce <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80110e:	83 c3 01             	add    $0x1,%ebx
  801111:	83 c4 10             	add    $0x10,%esp
  801114:	83 fb 20             	cmp    $0x20,%ebx
  801117:	75 ec                	jne    801105 <close_all+0xc>
		close(i);
}
  801119:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80111c:	c9                   	leave  
  80111d:	c3                   	ret    

0080111e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80111e:	55                   	push   %ebp
  80111f:	89 e5                	mov    %esp,%ebp
  801121:	57                   	push   %edi
  801122:	56                   	push   %esi
  801123:	53                   	push   %ebx
  801124:	83 ec 2c             	sub    $0x2c,%esp
  801127:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80112a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80112d:	50                   	push   %eax
  80112e:	ff 75 08             	pushl  0x8(%ebp)
  801131:	e8 6e fe ff ff       	call   800fa4 <fd_lookup>
  801136:	83 c4 08             	add    $0x8,%esp
  801139:	85 c0                	test   %eax,%eax
  80113b:	0f 88 c1 00 00 00    	js     801202 <dup+0xe4>
		return r;
	close(newfdnum);
  801141:	83 ec 0c             	sub    $0xc,%esp
  801144:	56                   	push   %esi
  801145:	e8 84 ff ff ff       	call   8010ce <close>

	newfd = INDEX2FD(newfdnum);
  80114a:	89 f3                	mov    %esi,%ebx
  80114c:	c1 e3 0c             	shl    $0xc,%ebx
  80114f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801155:	83 c4 04             	add    $0x4,%esp
  801158:	ff 75 e4             	pushl  -0x1c(%ebp)
  80115b:	e8 de fd ff ff       	call   800f3e <fd2data>
  801160:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801162:	89 1c 24             	mov    %ebx,(%esp)
  801165:	e8 d4 fd ff ff       	call   800f3e <fd2data>
  80116a:	83 c4 10             	add    $0x10,%esp
  80116d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801170:	89 f8                	mov    %edi,%eax
  801172:	c1 e8 16             	shr    $0x16,%eax
  801175:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80117c:	a8 01                	test   $0x1,%al
  80117e:	74 37                	je     8011b7 <dup+0x99>
  801180:	89 f8                	mov    %edi,%eax
  801182:	c1 e8 0c             	shr    $0xc,%eax
  801185:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80118c:	f6 c2 01             	test   $0x1,%dl
  80118f:	74 26                	je     8011b7 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801191:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801198:	83 ec 0c             	sub    $0xc,%esp
  80119b:	25 07 0e 00 00       	and    $0xe07,%eax
  8011a0:	50                   	push   %eax
  8011a1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011a4:	6a 00                	push   $0x0
  8011a6:	57                   	push   %edi
  8011a7:	6a 00                	push   $0x0
  8011a9:	e8 1d fa ff ff       	call   800bcb <sys_page_map>
  8011ae:	89 c7                	mov    %eax,%edi
  8011b0:	83 c4 20             	add    $0x20,%esp
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	78 2e                	js     8011e5 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011b7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8011ba:	89 d0                	mov    %edx,%eax
  8011bc:	c1 e8 0c             	shr    $0xc,%eax
  8011bf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011c6:	83 ec 0c             	sub    $0xc,%esp
  8011c9:	25 07 0e 00 00       	and    $0xe07,%eax
  8011ce:	50                   	push   %eax
  8011cf:	53                   	push   %ebx
  8011d0:	6a 00                	push   $0x0
  8011d2:	52                   	push   %edx
  8011d3:	6a 00                	push   $0x0
  8011d5:	e8 f1 f9 ff ff       	call   800bcb <sys_page_map>
  8011da:	89 c7                	mov    %eax,%edi
  8011dc:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8011df:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011e1:	85 ff                	test   %edi,%edi
  8011e3:	79 1d                	jns    801202 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011e5:	83 ec 08             	sub    $0x8,%esp
  8011e8:	53                   	push   %ebx
  8011e9:	6a 00                	push   $0x0
  8011eb:	e8 1d fa ff ff       	call   800c0d <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011f0:	83 c4 08             	add    $0x8,%esp
  8011f3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011f6:	6a 00                	push   $0x0
  8011f8:	e8 10 fa ff ff       	call   800c0d <sys_page_unmap>
	return r;
  8011fd:	83 c4 10             	add    $0x10,%esp
  801200:	89 f8                	mov    %edi,%eax
}
  801202:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801205:	5b                   	pop    %ebx
  801206:	5e                   	pop    %esi
  801207:	5f                   	pop    %edi
  801208:	5d                   	pop    %ebp
  801209:	c3                   	ret    

0080120a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80120a:	55                   	push   %ebp
  80120b:	89 e5                	mov    %esp,%ebp
  80120d:	53                   	push   %ebx
  80120e:	83 ec 14             	sub    $0x14,%esp
  801211:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801214:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801217:	50                   	push   %eax
  801218:	53                   	push   %ebx
  801219:	e8 86 fd ff ff       	call   800fa4 <fd_lookup>
  80121e:	83 c4 08             	add    $0x8,%esp
  801221:	89 c2                	mov    %eax,%edx
  801223:	85 c0                	test   %eax,%eax
  801225:	78 6d                	js     801294 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801227:	83 ec 08             	sub    $0x8,%esp
  80122a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122d:	50                   	push   %eax
  80122e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801231:	ff 30                	pushl  (%eax)
  801233:	e8 c2 fd ff ff       	call   800ffa <dev_lookup>
  801238:	83 c4 10             	add    $0x10,%esp
  80123b:	85 c0                	test   %eax,%eax
  80123d:	78 4c                	js     80128b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80123f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801242:	8b 42 08             	mov    0x8(%edx),%eax
  801245:	83 e0 03             	and    $0x3,%eax
  801248:	83 f8 01             	cmp    $0x1,%eax
  80124b:	75 21                	jne    80126e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80124d:	a1 08 40 80 00       	mov    0x804008,%eax
  801252:	8b 40 48             	mov    0x48(%eax),%eax
  801255:	83 ec 04             	sub    $0x4,%esp
  801258:	53                   	push   %ebx
  801259:	50                   	push   %eax
  80125a:	68 4d 29 80 00       	push   $0x80294d
  80125f:	e8 9c ef ff ff       	call   800200 <cprintf>
		return -E_INVAL;
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80126c:	eb 26                	jmp    801294 <read+0x8a>
	}
	if (!dev->dev_read)
  80126e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801271:	8b 40 08             	mov    0x8(%eax),%eax
  801274:	85 c0                	test   %eax,%eax
  801276:	74 17                	je     80128f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801278:	83 ec 04             	sub    $0x4,%esp
  80127b:	ff 75 10             	pushl  0x10(%ebp)
  80127e:	ff 75 0c             	pushl  0xc(%ebp)
  801281:	52                   	push   %edx
  801282:	ff d0                	call   *%eax
  801284:	89 c2                	mov    %eax,%edx
  801286:	83 c4 10             	add    $0x10,%esp
  801289:	eb 09                	jmp    801294 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128b:	89 c2                	mov    %eax,%edx
  80128d:	eb 05                	jmp    801294 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80128f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801294:	89 d0                	mov    %edx,%eax
  801296:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801299:	c9                   	leave  
  80129a:	c3                   	ret    

0080129b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80129b:	55                   	push   %ebp
  80129c:	89 e5                	mov    %esp,%ebp
  80129e:	57                   	push   %edi
  80129f:	56                   	push   %esi
  8012a0:	53                   	push   %ebx
  8012a1:	83 ec 0c             	sub    $0xc,%esp
  8012a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012a7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012af:	eb 21                	jmp    8012d2 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012b1:	83 ec 04             	sub    $0x4,%esp
  8012b4:	89 f0                	mov    %esi,%eax
  8012b6:	29 d8                	sub    %ebx,%eax
  8012b8:	50                   	push   %eax
  8012b9:	89 d8                	mov    %ebx,%eax
  8012bb:	03 45 0c             	add    0xc(%ebp),%eax
  8012be:	50                   	push   %eax
  8012bf:	57                   	push   %edi
  8012c0:	e8 45 ff ff ff       	call   80120a <read>
		if (m < 0)
  8012c5:	83 c4 10             	add    $0x10,%esp
  8012c8:	85 c0                	test   %eax,%eax
  8012ca:	78 10                	js     8012dc <readn+0x41>
			return m;
		if (m == 0)
  8012cc:	85 c0                	test   %eax,%eax
  8012ce:	74 0a                	je     8012da <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012d0:	01 c3                	add    %eax,%ebx
  8012d2:	39 f3                	cmp    %esi,%ebx
  8012d4:	72 db                	jb     8012b1 <readn+0x16>
  8012d6:	89 d8                	mov    %ebx,%eax
  8012d8:	eb 02                	jmp    8012dc <readn+0x41>
  8012da:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8012dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012df:	5b                   	pop    %ebx
  8012e0:	5e                   	pop    %esi
  8012e1:	5f                   	pop    %edi
  8012e2:	5d                   	pop    %ebp
  8012e3:	c3                   	ret    

008012e4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012e4:	55                   	push   %ebp
  8012e5:	89 e5                	mov    %esp,%ebp
  8012e7:	53                   	push   %ebx
  8012e8:	83 ec 14             	sub    $0x14,%esp
  8012eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f1:	50                   	push   %eax
  8012f2:	53                   	push   %ebx
  8012f3:	e8 ac fc ff ff       	call   800fa4 <fd_lookup>
  8012f8:	83 c4 08             	add    $0x8,%esp
  8012fb:	89 c2                	mov    %eax,%edx
  8012fd:	85 c0                	test   %eax,%eax
  8012ff:	78 68                	js     801369 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801301:	83 ec 08             	sub    $0x8,%esp
  801304:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801307:	50                   	push   %eax
  801308:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130b:	ff 30                	pushl  (%eax)
  80130d:	e8 e8 fc ff ff       	call   800ffa <dev_lookup>
  801312:	83 c4 10             	add    $0x10,%esp
  801315:	85 c0                	test   %eax,%eax
  801317:	78 47                	js     801360 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801319:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801320:	75 21                	jne    801343 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801322:	a1 08 40 80 00       	mov    0x804008,%eax
  801327:	8b 40 48             	mov    0x48(%eax),%eax
  80132a:	83 ec 04             	sub    $0x4,%esp
  80132d:	53                   	push   %ebx
  80132e:	50                   	push   %eax
  80132f:	68 69 29 80 00       	push   $0x802969
  801334:	e8 c7 ee ff ff       	call   800200 <cprintf>
		return -E_INVAL;
  801339:	83 c4 10             	add    $0x10,%esp
  80133c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801341:	eb 26                	jmp    801369 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801343:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801346:	8b 52 0c             	mov    0xc(%edx),%edx
  801349:	85 d2                	test   %edx,%edx
  80134b:	74 17                	je     801364 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80134d:	83 ec 04             	sub    $0x4,%esp
  801350:	ff 75 10             	pushl  0x10(%ebp)
  801353:	ff 75 0c             	pushl  0xc(%ebp)
  801356:	50                   	push   %eax
  801357:	ff d2                	call   *%edx
  801359:	89 c2                	mov    %eax,%edx
  80135b:	83 c4 10             	add    $0x10,%esp
  80135e:	eb 09                	jmp    801369 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801360:	89 c2                	mov    %eax,%edx
  801362:	eb 05                	jmp    801369 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801364:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801369:	89 d0                	mov    %edx,%eax
  80136b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80136e:	c9                   	leave  
  80136f:	c3                   	ret    

00801370 <seek>:

int
seek(int fdnum, off_t offset)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
  801373:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801376:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801379:	50                   	push   %eax
  80137a:	ff 75 08             	pushl  0x8(%ebp)
  80137d:	e8 22 fc ff ff       	call   800fa4 <fd_lookup>
  801382:	83 c4 08             	add    $0x8,%esp
  801385:	85 c0                	test   %eax,%eax
  801387:	78 0e                	js     801397 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801389:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80138c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80138f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801392:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801397:	c9                   	leave  
  801398:	c3                   	ret    

00801399 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801399:	55                   	push   %ebp
  80139a:	89 e5                	mov    %esp,%ebp
  80139c:	53                   	push   %ebx
  80139d:	83 ec 14             	sub    $0x14,%esp
  8013a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a6:	50                   	push   %eax
  8013a7:	53                   	push   %ebx
  8013a8:	e8 f7 fb ff ff       	call   800fa4 <fd_lookup>
  8013ad:	83 c4 08             	add    $0x8,%esp
  8013b0:	89 c2                	mov    %eax,%edx
  8013b2:	85 c0                	test   %eax,%eax
  8013b4:	78 65                	js     80141b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b6:	83 ec 08             	sub    $0x8,%esp
  8013b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013bc:	50                   	push   %eax
  8013bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c0:	ff 30                	pushl  (%eax)
  8013c2:	e8 33 fc ff ff       	call   800ffa <dev_lookup>
  8013c7:	83 c4 10             	add    $0x10,%esp
  8013ca:	85 c0                	test   %eax,%eax
  8013cc:	78 44                	js     801412 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013d5:	75 21                	jne    8013f8 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013d7:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013dc:	8b 40 48             	mov    0x48(%eax),%eax
  8013df:	83 ec 04             	sub    $0x4,%esp
  8013e2:	53                   	push   %ebx
  8013e3:	50                   	push   %eax
  8013e4:	68 2c 29 80 00       	push   $0x80292c
  8013e9:	e8 12 ee ff ff       	call   800200 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013ee:	83 c4 10             	add    $0x10,%esp
  8013f1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013f6:	eb 23                	jmp    80141b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8013f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013fb:	8b 52 18             	mov    0x18(%edx),%edx
  8013fe:	85 d2                	test   %edx,%edx
  801400:	74 14                	je     801416 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801402:	83 ec 08             	sub    $0x8,%esp
  801405:	ff 75 0c             	pushl  0xc(%ebp)
  801408:	50                   	push   %eax
  801409:	ff d2                	call   *%edx
  80140b:	89 c2                	mov    %eax,%edx
  80140d:	83 c4 10             	add    $0x10,%esp
  801410:	eb 09                	jmp    80141b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801412:	89 c2                	mov    %eax,%edx
  801414:	eb 05                	jmp    80141b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801416:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80141b:	89 d0                	mov    %edx,%eax
  80141d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801420:	c9                   	leave  
  801421:	c3                   	ret    

00801422 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801422:	55                   	push   %ebp
  801423:	89 e5                	mov    %esp,%ebp
  801425:	53                   	push   %ebx
  801426:	83 ec 14             	sub    $0x14,%esp
  801429:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80142c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80142f:	50                   	push   %eax
  801430:	ff 75 08             	pushl  0x8(%ebp)
  801433:	e8 6c fb ff ff       	call   800fa4 <fd_lookup>
  801438:	83 c4 08             	add    $0x8,%esp
  80143b:	89 c2                	mov    %eax,%edx
  80143d:	85 c0                	test   %eax,%eax
  80143f:	78 58                	js     801499 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801441:	83 ec 08             	sub    $0x8,%esp
  801444:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801447:	50                   	push   %eax
  801448:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144b:	ff 30                	pushl  (%eax)
  80144d:	e8 a8 fb ff ff       	call   800ffa <dev_lookup>
  801452:	83 c4 10             	add    $0x10,%esp
  801455:	85 c0                	test   %eax,%eax
  801457:	78 37                	js     801490 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801459:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80145c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801460:	74 32                	je     801494 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801462:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801465:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80146c:	00 00 00 
	stat->st_isdir = 0;
  80146f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801476:	00 00 00 
	stat->st_dev = dev;
  801479:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80147f:	83 ec 08             	sub    $0x8,%esp
  801482:	53                   	push   %ebx
  801483:	ff 75 f0             	pushl  -0x10(%ebp)
  801486:	ff 50 14             	call   *0x14(%eax)
  801489:	89 c2                	mov    %eax,%edx
  80148b:	83 c4 10             	add    $0x10,%esp
  80148e:	eb 09                	jmp    801499 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801490:	89 c2                	mov    %eax,%edx
  801492:	eb 05                	jmp    801499 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801494:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801499:	89 d0                	mov    %edx,%eax
  80149b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149e:	c9                   	leave  
  80149f:	c3                   	ret    

008014a0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014a0:	55                   	push   %ebp
  8014a1:	89 e5                	mov    %esp,%ebp
  8014a3:	56                   	push   %esi
  8014a4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014a5:	83 ec 08             	sub    $0x8,%esp
  8014a8:	6a 00                	push   $0x0
  8014aa:	ff 75 08             	pushl  0x8(%ebp)
  8014ad:	e8 d6 01 00 00       	call   801688 <open>
  8014b2:	89 c3                	mov    %eax,%ebx
  8014b4:	83 c4 10             	add    $0x10,%esp
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	78 1b                	js     8014d6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8014bb:	83 ec 08             	sub    $0x8,%esp
  8014be:	ff 75 0c             	pushl  0xc(%ebp)
  8014c1:	50                   	push   %eax
  8014c2:	e8 5b ff ff ff       	call   801422 <fstat>
  8014c7:	89 c6                	mov    %eax,%esi
	close(fd);
  8014c9:	89 1c 24             	mov    %ebx,(%esp)
  8014cc:	e8 fd fb ff ff       	call   8010ce <close>
	return r;
  8014d1:	83 c4 10             	add    $0x10,%esp
  8014d4:	89 f0                	mov    %esi,%eax
}
  8014d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014d9:	5b                   	pop    %ebx
  8014da:	5e                   	pop    %esi
  8014db:	5d                   	pop    %ebp
  8014dc:	c3                   	ret    

008014dd <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014dd:	55                   	push   %ebp
  8014de:	89 e5                	mov    %esp,%ebp
  8014e0:	56                   	push   %esi
  8014e1:	53                   	push   %ebx
  8014e2:	89 c6                	mov    %eax,%esi
  8014e4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014e6:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014ed:	75 12                	jne    801501 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014ef:	83 ec 0c             	sub    $0xc,%esp
  8014f2:	6a 01                	push   $0x1
  8014f4:	e8 8a 0d 00 00       	call   802283 <ipc_find_env>
  8014f9:	a3 00 40 80 00       	mov    %eax,0x804000
  8014fe:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801501:	6a 07                	push   $0x7
  801503:	68 00 50 80 00       	push   $0x805000
  801508:	56                   	push   %esi
  801509:	ff 35 00 40 80 00    	pushl  0x804000
  80150f:	e8 1b 0d 00 00       	call   80222f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801514:	83 c4 0c             	add    $0xc,%esp
  801517:	6a 00                	push   $0x0
  801519:	53                   	push   %ebx
  80151a:	6a 00                	push   $0x0
  80151c:	e8 a7 0c 00 00       	call   8021c8 <ipc_recv>
}
  801521:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801524:	5b                   	pop    %ebx
  801525:	5e                   	pop    %esi
  801526:	5d                   	pop    %ebp
  801527:	c3                   	ret    

00801528 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801528:	55                   	push   %ebp
  801529:	89 e5                	mov    %esp,%ebp
  80152b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80152e:	8b 45 08             	mov    0x8(%ebp),%eax
  801531:	8b 40 0c             	mov    0xc(%eax),%eax
  801534:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801539:	8b 45 0c             	mov    0xc(%ebp),%eax
  80153c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801541:	ba 00 00 00 00       	mov    $0x0,%edx
  801546:	b8 02 00 00 00       	mov    $0x2,%eax
  80154b:	e8 8d ff ff ff       	call   8014dd <fsipc>
}
  801550:	c9                   	leave  
  801551:	c3                   	ret    

00801552 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801552:	55                   	push   %ebp
  801553:	89 e5                	mov    %esp,%ebp
  801555:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801558:	8b 45 08             	mov    0x8(%ebp),%eax
  80155b:	8b 40 0c             	mov    0xc(%eax),%eax
  80155e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801563:	ba 00 00 00 00       	mov    $0x0,%edx
  801568:	b8 06 00 00 00       	mov    $0x6,%eax
  80156d:	e8 6b ff ff ff       	call   8014dd <fsipc>
}
  801572:	c9                   	leave  
  801573:	c3                   	ret    

00801574 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801574:	55                   	push   %ebp
  801575:	89 e5                	mov    %esp,%ebp
  801577:	53                   	push   %ebx
  801578:	83 ec 04             	sub    $0x4,%esp
  80157b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80157e:	8b 45 08             	mov    0x8(%ebp),%eax
  801581:	8b 40 0c             	mov    0xc(%eax),%eax
  801584:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801589:	ba 00 00 00 00       	mov    $0x0,%edx
  80158e:	b8 05 00 00 00       	mov    $0x5,%eax
  801593:	e8 45 ff ff ff       	call   8014dd <fsipc>
  801598:	85 c0                	test   %eax,%eax
  80159a:	78 2c                	js     8015c8 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80159c:	83 ec 08             	sub    $0x8,%esp
  80159f:	68 00 50 80 00       	push   $0x805000
  8015a4:	53                   	push   %ebx
  8015a5:	e8 db f1 ff ff       	call   800785 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015aa:	a1 80 50 80 00       	mov    0x805080,%eax
  8015af:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015b5:	a1 84 50 80 00       	mov    0x805084,%eax
  8015ba:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015c0:	83 c4 10             	add    $0x10,%esp
  8015c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cb:	c9                   	leave  
  8015cc:	c3                   	ret    

008015cd <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015cd:	55                   	push   %ebp
  8015ce:	89 e5                	mov    %esp,%ebp
  8015d0:	83 ec 0c             	sub    $0xc,%esp
  8015d3:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8015d9:	8b 52 0c             	mov    0xc(%edx),%edx
  8015dc:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8015e2:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8015e7:	50                   	push   %eax
  8015e8:	ff 75 0c             	pushl  0xc(%ebp)
  8015eb:	68 08 50 80 00       	push   $0x805008
  8015f0:	e8 22 f3 ff ff       	call   800917 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8015f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015fa:	b8 04 00 00 00       	mov    $0x4,%eax
  8015ff:	e8 d9 fe ff ff       	call   8014dd <fsipc>

}
  801604:	c9                   	leave  
  801605:	c3                   	ret    

00801606 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801606:	55                   	push   %ebp
  801607:	89 e5                	mov    %esp,%ebp
  801609:	56                   	push   %esi
  80160a:	53                   	push   %ebx
  80160b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80160e:	8b 45 08             	mov    0x8(%ebp),%eax
  801611:	8b 40 0c             	mov    0xc(%eax),%eax
  801614:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801619:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80161f:	ba 00 00 00 00       	mov    $0x0,%edx
  801624:	b8 03 00 00 00       	mov    $0x3,%eax
  801629:	e8 af fe ff ff       	call   8014dd <fsipc>
  80162e:	89 c3                	mov    %eax,%ebx
  801630:	85 c0                	test   %eax,%eax
  801632:	78 4b                	js     80167f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801634:	39 c6                	cmp    %eax,%esi
  801636:	73 16                	jae    80164e <devfile_read+0x48>
  801638:	68 9c 29 80 00       	push   $0x80299c
  80163d:	68 a3 29 80 00       	push   $0x8029a3
  801642:	6a 7c                	push   $0x7c
  801644:	68 b8 29 80 00       	push   $0x8029b8
  801649:	e8 34 0b 00 00       	call   802182 <_panic>
	assert(r <= PGSIZE);
  80164e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801653:	7e 16                	jle    80166b <devfile_read+0x65>
  801655:	68 c3 29 80 00       	push   $0x8029c3
  80165a:	68 a3 29 80 00       	push   $0x8029a3
  80165f:	6a 7d                	push   $0x7d
  801661:	68 b8 29 80 00       	push   $0x8029b8
  801666:	e8 17 0b 00 00       	call   802182 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80166b:	83 ec 04             	sub    $0x4,%esp
  80166e:	50                   	push   %eax
  80166f:	68 00 50 80 00       	push   $0x805000
  801674:	ff 75 0c             	pushl  0xc(%ebp)
  801677:	e8 9b f2 ff ff       	call   800917 <memmove>
	return r;
  80167c:	83 c4 10             	add    $0x10,%esp
}
  80167f:	89 d8                	mov    %ebx,%eax
  801681:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801684:	5b                   	pop    %ebx
  801685:	5e                   	pop    %esi
  801686:	5d                   	pop    %ebp
  801687:	c3                   	ret    

00801688 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	53                   	push   %ebx
  80168c:	83 ec 20             	sub    $0x20,%esp
  80168f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801692:	53                   	push   %ebx
  801693:	e8 b4 f0 ff ff       	call   80074c <strlen>
  801698:	83 c4 10             	add    $0x10,%esp
  80169b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016a0:	7f 67                	jg     801709 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016a2:	83 ec 0c             	sub    $0xc,%esp
  8016a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a8:	50                   	push   %eax
  8016a9:	e8 a7 f8 ff ff       	call   800f55 <fd_alloc>
  8016ae:	83 c4 10             	add    $0x10,%esp
		return r;
  8016b1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016b3:	85 c0                	test   %eax,%eax
  8016b5:	78 57                	js     80170e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016b7:	83 ec 08             	sub    $0x8,%esp
  8016ba:	53                   	push   %ebx
  8016bb:	68 00 50 80 00       	push   $0x805000
  8016c0:	e8 c0 f0 ff ff       	call   800785 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8016d5:	e8 03 fe ff ff       	call   8014dd <fsipc>
  8016da:	89 c3                	mov    %eax,%ebx
  8016dc:	83 c4 10             	add    $0x10,%esp
  8016df:	85 c0                	test   %eax,%eax
  8016e1:	79 14                	jns    8016f7 <open+0x6f>
		fd_close(fd, 0);
  8016e3:	83 ec 08             	sub    $0x8,%esp
  8016e6:	6a 00                	push   $0x0
  8016e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8016eb:	e8 5d f9 ff ff       	call   80104d <fd_close>
		return r;
  8016f0:	83 c4 10             	add    $0x10,%esp
  8016f3:	89 da                	mov    %ebx,%edx
  8016f5:	eb 17                	jmp    80170e <open+0x86>
	}

	return fd2num(fd);
  8016f7:	83 ec 0c             	sub    $0xc,%esp
  8016fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8016fd:	e8 2c f8 ff ff       	call   800f2e <fd2num>
  801702:	89 c2                	mov    %eax,%edx
  801704:	83 c4 10             	add    $0x10,%esp
  801707:	eb 05                	jmp    80170e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801709:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80170e:	89 d0                	mov    %edx,%eax
  801710:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801713:	c9                   	leave  
  801714:	c3                   	ret    

00801715 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80171b:	ba 00 00 00 00       	mov    $0x0,%edx
  801720:	b8 08 00 00 00       	mov    $0x8,%eax
  801725:	e8 b3 fd ff ff       	call   8014dd <fsipc>
}
  80172a:	c9                   	leave  
  80172b:	c3                   	ret    

0080172c <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80172c:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801730:	7e 37                	jle    801769 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801732:	55                   	push   %ebp
  801733:	89 e5                	mov    %esp,%ebp
  801735:	53                   	push   %ebx
  801736:	83 ec 08             	sub    $0x8,%esp
  801739:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80173b:	ff 70 04             	pushl  0x4(%eax)
  80173e:	8d 40 10             	lea    0x10(%eax),%eax
  801741:	50                   	push   %eax
  801742:	ff 33                	pushl  (%ebx)
  801744:	e8 9b fb ff ff       	call   8012e4 <write>
		if (result > 0)
  801749:	83 c4 10             	add    $0x10,%esp
  80174c:	85 c0                	test   %eax,%eax
  80174e:	7e 03                	jle    801753 <writebuf+0x27>
			b->result += result;
  801750:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801753:	3b 43 04             	cmp    0x4(%ebx),%eax
  801756:	74 0d                	je     801765 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801758:	85 c0                	test   %eax,%eax
  80175a:	ba 00 00 00 00       	mov    $0x0,%edx
  80175f:	0f 4f c2             	cmovg  %edx,%eax
  801762:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801765:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801768:	c9                   	leave  
  801769:	f3 c3                	repz ret 

0080176b <putch>:

static void
putch(int ch, void *thunk)
{
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
  80176e:	53                   	push   %ebx
  80176f:	83 ec 04             	sub    $0x4,%esp
  801772:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801775:	8b 53 04             	mov    0x4(%ebx),%edx
  801778:	8d 42 01             	lea    0x1(%edx),%eax
  80177b:	89 43 04             	mov    %eax,0x4(%ebx)
  80177e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801781:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801785:	3d 00 01 00 00       	cmp    $0x100,%eax
  80178a:	75 0e                	jne    80179a <putch+0x2f>
		writebuf(b);
  80178c:	89 d8                	mov    %ebx,%eax
  80178e:	e8 99 ff ff ff       	call   80172c <writebuf>
		b->idx = 0;
  801793:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80179a:	83 c4 04             	add    $0x4,%esp
  80179d:	5b                   	pop    %ebx
  80179e:	5d                   	pop    %ebp
  80179f:	c3                   	ret    

008017a0 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8017a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ac:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8017b2:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8017b9:	00 00 00 
	b.result = 0;
  8017bc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8017c3:	00 00 00 
	b.error = 1;
  8017c6:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8017cd:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8017d0:	ff 75 10             	pushl  0x10(%ebp)
  8017d3:	ff 75 0c             	pushl  0xc(%ebp)
  8017d6:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017dc:	50                   	push   %eax
  8017dd:	68 6b 17 80 00       	push   $0x80176b
  8017e2:	e8 50 eb ff ff       	call   800337 <vprintfmt>
	if (b.idx > 0)
  8017e7:	83 c4 10             	add    $0x10,%esp
  8017ea:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8017f1:	7e 0b                	jle    8017fe <vfprintf+0x5e>
		writebuf(&b);
  8017f3:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017f9:	e8 2e ff ff ff       	call   80172c <writebuf>

	return (b.result ? b.result : b.error);
  8017fe:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801804:	85 c0                	test   %eax,%eax
  801806:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80180d:	c9                   	leave  
  80180e:	c3                   	ret    

0080180f <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80180f:	55                   	push   %ebp
  801810:	89 e5                	mov    %esp,%ebp
  801812:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801815:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801818:	50                   	push   %eax
  801819:	ff 75 0c             	pushl  0xc(%ebp)
  80181c:	ff 75 08             	pushl  0x8(%ebp)
  80181f:	e8 7c ff ff ff       	call   8017a0 <vfprintf>
	va_end(ap);

	return cnt;
}
  801824:	c9                   	leave  
  801825:	c3                   	ret    

00801826 <printf>:

int
printf(const char *fmt, ...)
{
  801826:	55                   	push   %ebp
  801827:	89 e5                	mov    %esp,%ebp
  801829:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80182c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80182f:	50                   	push   %eax
  801830:	ff 75 08             	pushl  0x8(%ebp)
  801833:	6a 01                	push   $0x1
  801835:	e8 66 ff ff ff       	call   8017a0 <vfprintf>
	va_end(ap);

	return cnt;
}
  80183a:	c9                   	leave  
  80183b:	c3                   	ret    

0080183c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80183c:	55                   	push   %ebp
  80183d:	89 e5                	mov    %esp,%ebp
  80183f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801842:	68 cf 29 80 00       	push   $0x8029cf
  801847:	ff 75 0c             	pushl  0xc(%ebp)
  80184a:	e8 36 ef ff ff       	call   800785 <strcpy>
	return 0;
}
  80184f:	b8 00 00 00 00       	mov    $0x0,%eax
  801854:	c9                   	leave  
  801855:	c3                   	ret    

00801856 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801856:	55                   	push   %ebp
  801857:	89 e5                	mov    %esp,%ebp
  801859:	53                   	push   %ebx
  80185a:	83 ec 10             	sub    $0x10,%esp
  80185d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801860:	53                   	push   %ebx
  801861:	e8 56 0a 00 00       	call   8022bc <pageref>
  801866:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801869:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80186e:	83 f8 01             	cmp    $0x1,%eax
  801871:	75 10                	jne    801883 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801873:	83 ec 0c             	sub    $0xc,%esp
  801876:	ff 73 0c             	pushl  0xc(%ebx)
  801879:	e8 c0 02 00 00       	call   801b3e <nsipc_close>
  80187e:	89 c2                	mov    %eax,%edx
  801880:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801883:	89 d0                	mov    %edx,%eax
  801885:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801888:	c9                   	leave  
  801889:	c3                   	ret    

0080188a <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801890:	6a 00                	push   $0x0
  801892:	ff 75 10             	pushl  0x10(%ebp)
  801895:	ff 75 0c             	pushl  0xc(%ebp)
  801898:	8b 45 08             	mov    0x8(%ebp),%eax
  80189b:	ff 70 0c             	pushl  0xc(%eax)
  80189e:	e8 78 03 00 00       	call   801c1b <nsipc_send>
}
  8018a3:	c9                   	leave  
  8018a4:	c3                   	ret    

008018a5 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8018a5:	55                   	push   %ebp
  8018a6:	89 e5                	mov    %esp,%ebp
  8018a8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8018ab:	6a 00                	push   $0x0
  8018ad:	ff 75 10             	pushl  0x10(%ebp)
  8018b0:	ff 75 0c             	pushl  0xc(%ebp)
  8018b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b6:	ff 70 0c             	pushl  0xc(%eax)
  8018b9:	e8 f1 02 00 00       	call   801baf <nsipc_recv>
}
  8018be:	c9                   	leave  
  8018bf:	c3                   	ret    

008018c0 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8018c6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8018c9:	52                   	push   %edx
  8018ca:	50                   	push   %eax
  8018cb:	e8 d4 f6 ff ff       	call   800fa4 <fd_lookup>
  8018d0:	83 c4 10             	add    $0x10,%esp
  8018d3:	85 c0                	test   %eax,%eax
  8018d5:	78 17                	js     8018ee <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8018d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018da:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8018e0:	39 08                	cmp    %ecx,(%eax)
  8018e2:	75 05                	jne    8018e9 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8018e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e7:	eb 05                	jmp    8018ee <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8018e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8018ee:	c9                   	leave  
  8018ef:	c3                   	ret    

008018f0 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8018f0:	55                   	push   %ebp
  8018f1:	89 e5                	mov    %esp,%ebp
  8018f3:	56                   	push   %esi
  8018f4:	53                   	push   %ebx
  8018f5:	83 ec 1c             	sub    $0x1c,%esp
  8018f8:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8018fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018fd:	50                   	push   %eax
  8018fe:	e8 52 f6 ff ff       	call   800f55 <fd_alloc>
  801903:	89 c3                	mov    %eax,%ebx
  801905:	83 c4 10             	add    $0x10,%esp
  801908:	85 c0                	test   %eax,%eax
  80190a:	78 1b                	js     801927 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80190c:	83 ec 04             	sub    $0x4,%esp
  80190f:	68 07 04 00 00       	push   $0x407
  801914:	ff 75 f4             	pushl  -0xc(%ebp)
  801917:	6a 00                	push   $0x0
  801919:	e8 6a f2 ff ff       	call   800b88 <sys_page_alloc>
  80191e:	89 c3                	mov    %eax,%ebx
  801920:	83 c4 10             	add    $0x10,%esp
  801923:	85 c0                	test   %eax,%eax
  801925:	79 10                	jns    801937 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801927:	83 ec 0c             	sub    $0xc,%esp
  80192a:	56                   	push   %esi
  80192b:	e8 0e 02 00 00       	call   801b3e <nsipc_close>
		return r;
  801930:	83 c4 10             	add    $0x10,%esp
  801933:	89 d8                	mov    %ebx,%eax
  801935:	eb 24                	jmp    80195b <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801937:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80193d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801940:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801942:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801945:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80194c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80194f:	83 ec 0c             	sub    $0xc,%esp
  801952:	50                   	push   %eax
  801953:	e8 d6 f5 ff ff       	call   800f2e <fd2num>
  801958:	83 c4 10             	add    $0x10,%esp
}
  80195b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80195e:	5b                   	pop    %ebx
  80195f:	5e                   	pop    %esi
  801960:	5d                   	pop    %ebp
  801961:	c3                   	ret    

00801962 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801968:	8b 45 08             	mov    0x8(%ebp),%eax
  80196b:	e8 50 ff ff ff       	call   8018c0 <fd2sockid>
		return r;
  801970:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801972:	85 c0                	test   %eax,%eax
  801974:	78 1f                	js     801995 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801976:	83 ec 04             	sub    $0x4,%esp
  801979:	ff 75 10             	pushl  0x10(%ebp)
  80197c:	ff 75 0c             	pushl  0xc(%ebp)
  80197f:	50                   	push   %eax
  801980:	e8 12 01 00 00       	call   801a97 <nsipc_accept>
  801985:	83 c4 10             	add    $0x10,%esp
		return r;
  801988:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80198a:	85 c0                	test   %eax,%eax
  80198c:	78 07                	js     801995 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80198e:	e8 5d ff ff ff       	call   8018f0 <alloc_sockfd>
  801993:	89 c1                	mov    %eax,%ecx
}
  801995:	89 c8                	mov    %ecx,%eax
  801997:	c9                   	leave  
  801998:	c3                   	ret    

00801999 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801999:	55                   	push   %ebp
  80199a:	89 e5                	mov    %esp,%ebp
  80199c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80199f:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a2:	e8 19 ff ff ff       	call   8018c0 <fd2sockid>
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	78 12                	js     8019bd <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8019ab:	83 ec 04             	sub    $0x4,%esp
  8019ae:	ff 75 10             	pushl  0x10(%ebp)
  8019b1:	ff 75 0c             	pushl  0xc(%ebp)
  8019b4:	50                   	push   %eax
  8019b5:	e8 2d 01 00 00       	call   801ae7 <nsipc_bind>
  8019ba:	83 c4 10             	add    $0x10,%esp
}
  8019bd:	c9                   	leave  
  8019be:	c3                   	ret    

008019bf <shutdown>:

int
shutdown(int s, int how)
{
  8019bf:	55                   	push   %ebp
  8019c0:	89 e5                	mov    %esp,%ebp
  8019c2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c8:	e8 f3 fe ff ff       	call   8018c0 <fd2sockid>
  8019cd:	85 c0                	test   %eax,%eax
  8019cf:	78 0f                	js     8019e0 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8019d1:	83 ec 08             	sub    $0x8,%esp
  8019d4:	ff 75 0c             	pushl  0xc(%ebp)
  8019d7:	50                   	push   %eax
  8019d8:	e8 3f 01 00 00       	call   801b1c <nsipc_shutdown>
  8019dd:	83 c4 10             	add    $0x10,%esp
}
  8019e0:	c9                   	leave  
  8019e1:	c3                   	ret    

008019e2 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019e2:	55                   	push   %ebp
  8019e3:	89 e5                	mov    %esp,%ebp
  8019e5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019eb:	e8 d0 fe ff ff       	call   8018c0 <fd2sockid>
  8019f0:	85 c0                	test   %eax,%eax
  8019f2:	78 12                	js     801a06 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8019f4:	83 ec 04             	sub    $0x4,%esp
  8019f7:	ff 75 10             	pushl  0x10(%ebp)
  8019fa:	ff 75 0c             	pushl  0xc(%ebp)
  8019fd:	50                   	push   %eax
  8019fe:	e8 55 01 00 00       	call   801b58 <nsipc_connect>
  801a03:	83 c4 10             	add    $0x10,%esp
}
  801a06:	c9                   	leave  
  801a07:	c3                   	ret    

00801a08 <listen>:

int
listen(int s, int backlog)
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a11:	e8 aa fe ff ff       	call   8018c0 <fd2sockid>
  801a16:	85 c0                	test   %eax,%eax
  801a18:	78 0f                	js     801a29 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801a1a:	83 ec 08             	sub    $0x8,%esp
  801a1d:	ff 75 0c             	pushl  0xc(%ebp)
  801a20:	50                   	push   %eax
  801a21:	e8 67 01 00 00       	call   801b8d <nsipc_listen>
  801a26:	83 c4 10             	add    $0x10,%esp
}
  801a29:	c9                   	leave  
  801a2a:	c3                   	ret    

00801a2b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a31:	ff 75 10             	pushl  0x10(%ebp)
  801a34:	ff 75 0c             	pushl  0xc(%ebp)
  801a37:	ff 75 08             	pushl  0x8(%ebp)
  801a3a:	e8 3a 02 00 00       	call   801c79 <nsipc_socket>
  801a3f:	83 c4 10             	add    $0x10,%esp
  801a42:	85 c0                	test   %eax,%eax
  801a44:	78 05                	js     801a4b <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801a46:	e8 a5 fe ff ff       	call   8018f0 <alloc_sockfd>
}
  801a4b:	c9                   	leave  
  801a4c:	c3                   	ret    

00801a4d <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a4d:	55                   	push   %ebp
  801a4e:	89 e5                	mov    %esp,%ebp
  801a50:	53                   	push   %ebx
  801a51:	83 ec 04             	sub    $0x4,%esp
  801a54:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a56:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801a5d:	75 12                	jne    801a71 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801a5f:	83 ec 0c             	sub    $0xc,%esp
  801a62:	6a 02                	push   $0x2
  801a64:	e8 1a 08 00 00       	call   802283 <ipc_find_env>
  801a69:	a3 04 40 80 00       	mov    %eax,0x804004
  801a6e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801a71:	6a 07                	push   $0x7
  801a73:	68 00 60 80 00       	push   $0x806000
  801a78:	53                   	push   %ebx
  801a79:	ff 35 04 40 80 00    	pushl  0x804004
  801a7f:	e8 ab 07 00 00       	call   80222f <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801a84:	83 c4 0c             	add    $0xc,%esp
  801a87:	6a 00                	push   $0x0
  801a89:	6a 00                	push   $0x0
  801a8b:	6a 00                	push   $0x0
  801a8d:	e8 36 07 00 00       	call   8021c8 <ipc_recv>
}
  801a92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a95:	c9                   	leave  
  801a96:	c3                   	ret    

00801a97 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	56                   	push   %esi
  801a9b:	53                   	push   %ebx
  801a9c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801aa7:	8b 06                	mov    (%esi),%eax
  801aa9:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801aae:	b8 01 00 00 00       	mov    $0x1,%eax
  801ab3:	e8 95 ff ff ff       	call   801a4d <nsipc>
  801ab8:	89 c3                	mov    %eax,%ebx
  801aba:	85 c0                	test   %eax,%eax
  801abc:	78 20                	js     801ade <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801abe:	83 ec 04             	sub    $0x4,%esp
  801ac1:	ff 35 10 60 80 00    	pushl  0x806010
  801ac7:	68 00 60 80 00       	push   $0x806000
  801acc:	ff 75 0c             	pushl  0xc(%ebp)
  801acf:	e8 43 ee ff ff       	call   800917 <memmove>
		*addrlen = ret->ret_addrlen;
  801ad4:	a1 10 60 80 00       	mov    0x806010,%eax
  801ad9:	89 06                	mov    %eax,(%esi)
  801adb:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801ade:	89 d8                	mov    %ebx,%eax
  801ae0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ae3:	5b                   	pop    %ebx
  801ae4:	5e                   	pop    %esi
  801ae5:	5d                   	pop    %ebp
  801ae6:	c3                   	ret    

00801ae7 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ae7:	55                   	push   %ebp
  801ae8:	89 e5                	mov    %esp,%ebp
  801aea:	53                   	push   %ebx
  801aeb:	83 ec 08             	sub    $0x8,%esp
  801aee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801af1:	8b 45 08             	mov    0x8(%ebp),%eax
  801af4:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801af9:	53                   	push   %ebx
  801afa:	ff 75 0c             	pushl  0xc(%ebp)
  801afd:	68 04 60 80 00       	push   $0x806004
  801b02:	e8 10 ee ff ff       	call   800917 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b07:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801b0d:	b8 02 00 00 00       	mov    $0x2,%eax
  801b12:	e8 36 ff ff ff       	call   801a4d <nsipc>
}
  801b17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b1a:	c9                   	leave  
  801b1b:	c3                   	ret    

00801b1c <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b1c:	55                   	push   %ebp
  801b1d:	89 e5                	mov    %esp,%ebp
  801b1f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b22:	8b 45 08             	mov    0x8(%ebp),%eax
  801b25:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801b2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b2d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801b32:	b8 03 00 00 00       	mov    $0x3,%eax
  801b37:	e8 11 ff ff ff       	call   801a4d <nsipc>
}
  801b3c:	c9                   	leave  
  801b3d:	c3                   	ret    

00801b3e <nsipc_close>:

int
nsipc_close(int s)
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b44:	8b 45 08             	mov    0x8(%ebp),%eax
  801b47:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801b4c:	b8 04 00 00 00       	mov    $0x4,%eax
  801b51:	e8 f7 fe ff ff       	call   801a4d <nsipc>
}
  801b56:	c9                   	leave  
  801b57:	c3                   	ret    

00801b58 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	53                   	push   %ebx
  801b5c:	83 ec 08             	sub    $0x8,%esp
  801b5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b62:	8b 45 08             	mov    0x8(%ebp),%eax
  801b65:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801b6a:	53                   	push   %ebx
  801b6b:	ff 75 0c             	pushl  0xc(%ebp)
  801b6e:	68 04 60 80 00       	push   $0x806004
  801b73:	e8 9f ed ff ff       	call   800917 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801b78:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801b7e:	b8 05 00 00 00       	mov    $0x5,%eax
  801b83:	e8 c5 fe ff ff       	call   801a4d <nsipc>
}
  801b88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b8b:	c9                   	leave  
  801b8c:	c3                   	ret    

00801b8d <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801b8d:	55                   	push   %ebp
  801b8e:	89 e5                	mov    %esp,%ebp
  801b90:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801b93:	8b 45 08             	mov    0x8(%ebp),%eax
  801b96:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801b9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b9e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801ba3:	b8 06 00 00 00       	mov    $0x6,%eax
  801ba8:	e8 a0 fe ff ff       	call   801a4d <nsipc>
}
  801bad:	c9                   	leave  
  801bae:	c3                   	ret    

00801baf <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801baf:	55                   	push   %ebp
  801bb0:	89 e5                	mov    %esp,%ebp
  801bb2:	56                   	push   %esi
  801bb3:	53                   	push   %ebx
  801bb4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801bb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bba:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801bbf:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801bc5:	8b 45 14             	mov    0x14(%ebp),%eax
  801bc8:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801bcd:	b8 07 00 00 00       	mov    $0x7,%eax
  801bd2:	e8 76 fe ff ff       	call   801a4d <nsipc>
  801bd7:	89 c3                	mov    %eax,%ebx
  801bd9:	85 c0                	test   %eax,%eax
  801bdb:	78 35                	js     801c12 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801bdd:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801be2:	7f 04                	jg     801be8 <nsipc_recv+0x39>
  801be4:	39 c6                	cmp    %eax,%esi
  801be6:	7d 16                	jge    801bfe <nsipc_recv+0x4f>
  801be8:	68 db 29 80 00       	push   $0x8029db
  801bed:	68 a3 29 80 00       	push   $0x8029a3
  801bf2:	6a 62                	push   $0x62
  801bf4:	68 f0 29 80 00       	push   $0x8029f0
  801bf9:	e8 84 05 00 00       	call   802182 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801bfe:	83 ec 04             	sub    $0x4,%esp
  801c01:	50                   	push   %eax
  801c02:	68 00 60 80 00       	push   $0x806000
  801c07:	ff 75 0c             	pushl  0xc(%ebp)
  801c0a:	e8 08 ed ff ff       	call   800917 <memmove>
  801c0f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c12:	89 d8                	mov    %ebx,%eax
  801c14:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c17:	5b                   	pop    %ebx
  801c18:	5e                   	pop    %esi
  801c19:	5d                   	pop    %ebp
  801c1a:	c3                   	ret    

00801c1b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c1b:	55                   	push   %ebp
  801c1c:	89 e5                	mov    %esp,%ebp
  801c1e:	53                   	push   %ebx
  801c1f:	83 ec 04             	sub    $0x4,%esp
  801c22:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c25:	8b 45 08             	mov    0x8(%ebp),%eax
  801c28:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801c2d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c33:	7e 16                	jle    801c4b <nsipc_send+0x30>
  801c35:	68 fc 29 80 00       	push   $0x8029fc
  801c3a:	68 a3 29 80 00       	push   $0x8029a3
  801c3f:	6a 6d                	push   $0x6d
  801c41:	68 f0 29 80 00       	push   $0x8029f0
  801c46:	e8 37 05 00 00       	call   802182 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c4b:	83 ec 04             	sub    $0x4,%esp
  801c4e:	53                   	push   %ebx
  801c4f:	ff 75 0c             	pushl  0xc(%ebp)
  801c52:	68 0c 60 80 00       	push   $0x80600c
  801c57:	e8 bb ec ff ff       	call   800917 <memmove>
	nsipcbuf.send.req_size = size;
  801c5c:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801c62:	8b 45 14             	mov    0x14(%ebp),%eax
  801c65:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801c6a:	b8 08 00 00 00       	mov    $0x8,%eax
  801c6f:	e8 d9 fd ff ff       	call   801a4d <nsipc>
}
  801c74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c77:	c9                   	leave  
  801c78:	c3                   	ret    

00801c79 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
  801c7c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c82:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801c87:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c8a:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801c8f:	8b 45 10             	mov    0x10(%ebp),%eax
  801c92:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801c97:	b8 09 00 00 00       	mov    $0x9,%eax
  801c9c:	e8 ac fd ff ff       	call   801a4d <nsipc>
}
  801ca1:	c9                   	leave  
  801ca2:	c3                   	ret    

00801ca3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ca3:	55                   	push   %ebp
  801ca4:	89 e5                	mov    %esp,%ebp
  801ca6:	56                   	push   %esi
  801ca7:	53                   	push   %ebx
  801ca8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801cab:	83 ec 0c             	sub    $0xc,%esp
  801cae:	ff 75 08             	pushl  0x8(%ebp)
  801cb1:	e8 88 f2 ff ff       	call   800f3e <fd2data>
  801cb6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801cb8:	83 c4 08             	add    $0x8,%esp
  801cbb:	68 08 2a 80 00       	push   $0x802a08
  801cc0:	53                   	push   %ebx
  801cc1:	e8 bf ea ff ff       	call   800785 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cc6:	8b 46 04             	mov    0x4(%esi),%eax
  801cc9:	2b 06                	sub    (%esi),%eax
  801ccb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801cd1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cd8:	00 00 00 
	stat->st_dev = &devpipe;
  801cdb:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801ce2:	30 80 00 
	return 0;
}
  801ce5:	b8 00 00 00 00       	mov    $0x0,%eax
  801cea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ced:	5b                   	pop    %ebx
  801cee:	5e                   	pop    %esi
  801cef:	5d                   	pop    %ebp
  801cf0:	c3                   	ret    

00801cf1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cf1:	55                   	push   %ebp
  801cf2:	89 e5                	mov    %esp,%ebp
  801cf4:	53                   	push   %ebx
  801cf5:	83 ec 0c             	sub    $0xc,%esp
  801cf8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cfb:	53                   	push   %ebx
  801cfc:	6a 00                	push   $0x0
  801cfe:	e8 0a ef ff ff       	call   800c0d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d03:	89 1c 24             	mov    %ebx,(%esp)
  801d06:	e8 33 f2 ff ff       	call   800f3e <fd2data>
  801d0b:	83 c4 08             	add    $0x8,%esp
  801d0e:	50                   	push   %eax
  801d0f:	6a 00                	push   $0x0
  801d11:	e8 f7 ee ff ff       	call   800c0d <sys_page_unmap>
}
  801d16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d19:	c9                   	leave  
  801d1a:	c3                   	ret    

00801d1b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	57                   	push   %edi
  801d1f:	56                   	push   %esi
  801d20:	53                   	push   %ebx
  801d21:	83 ec 1c             	sub    $0x1c,%esp
  801d24:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d27:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d29:	a1 08 40 80 00       	mov    0x804008,%eax
  801d2e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d31:	83 ec 0c             	sub    $0xc,%esp
  801d34:	ff 75 e0             	pushl  -0x20(%ebp)
  801d37:	e8 80 05 00 00       	call   8022bc <pageref>
  801d3c:	89 c3                	mov    %eax,%ebx
  801d3e:	89 3c 24             	mov    %edi,(%esp)
  801d41:	e8 76 05 00 00       	call   8022bc <pageref>
  801d46:	83 c4 10             	add    $0x10,%esp
  801d49:	39 c3                	cmp    %eax,%ebx
  801d4b:	0f 94 c1             	sete   %cl
  801d4e:	0f b6 c9             	movzbl %cl,%ecx
  801d51:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d54:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801d5a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d5d:	39 ce                	cmp    %ecx,%esi
  801d5f:	74 1b                	je     801d7c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801d61:	39 c3                	cmp    %eax,%ebx
  801d63:	75 c4                	jne    801d29 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d65:	8b 42 58             	mov    0x58(%edx),%eax
  801d68:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d6b:	50                   	push   %eax
  801d6c:	56                   	push   %esi
  801d6d:	68 0f 2a 80 00       	push   $0x802a0f
  801d72:	e8 89 e4 ff ff       	call   800200 <cprintf>
  801d77:	83 c4 10             	add    $0x10,%esp
  801d7a:	eb ad                	jmp    801d29 <_pipeisclosed+0xe>
	}
}
  801d7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d82:	5b                   	pop    %ebx
  801d83:	5e                   	pop    %esi
  801d84:	5f                   	pop    %edi
  801d85:	5d                   	pop    %ebp
  801d86:	c3                   	ret    

00801d87 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d87:	55                   	push   %ebp
  801d88:	89 e5                	mov    %esp,%ebp
  801d8a:	57                   	push   %edi
  801d8b:	56                   	push   %esi
  801d8c:	53                   	push   %ebx
  801d8d:	83 ec 28             	sub    $0x28,%esp
  801d90:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d93:	56                   	push   %esi
  801d94:	e8 a5 f1 ff ff       	call   800f3e <fd2data>
  801d99:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d9b:	83 c4 10             	add    $0x10,%esp
  801d9e:	bf 00 00 00 00       	mov    $0x0,%edi
  801da3:	eb 4b                	jmp    801df0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801da5:	89 da                	mov    %ebx,%edx
  801da7:	89 f0                	mov    %esi,%eax
  801da9:	e8 6d ff ff ff       	call   801d1b <_pipeisclosed>
  801dae:	85 c0                	test   %eax,%eax
  801db0:	75 48                	jne    801dfa <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801db2:	e8 b2 ed ff ff       	call   800b69 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801db7:	8b 43 04             	mov    0x4(%ebx),%eax
  801dba:	8b 0b                	mov    (%ebx),%ecx
  801dbc:	8d 51 20             	lea    0x20(%ecx),%edx
  801dbf:	39 d0                	cmp    %edx,%eax
  801dc1:	73 e2                	jae    801da5 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801dc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dc6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801dca:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801dcd:	89 c2                	mov    %eax,%edx
  801dcf:	c1 fa 1f             	sar    $0x1f,%edx
  801dd2:	89 d1                	mov    %edx,%ecx
  801dd4:	c1 e9 1b             	shr    $0x1b,%ecx
  801dd7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801dda:	83 e2 1f             	and    $0x1f,%edx
  801ddd:	29 ca                	sub    %ecx,%edx
  801ddf:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801de3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801de7:	83 c0 01             	add    $0x1,%eax
  801dea:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ded:	83 c7 01             	add    $0x1,%edi
  801df0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801df3:	75 c2                	jne    801db7 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801df5:	8b 45 10             	mov    0x10(%ebp),%eax
  801df8:	eb 05                	jmp    801dff <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dfa:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801dff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e02:	5b                   	pop    %ebx
  801e03:	5e                   	pop    %esi
  801e04:	5f                   	pop    %edi
  801e05:	5d                   	pop    %ebp
  801e06:	c3                   	ret    

00801e07 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e07:	55                   	push   %ebp
  801e08:	89 e5                	mov    %esp,%ebp
  801e0a:	57                   	push   %edi
  801e0b:	56                   	push   %esi
  801e0c:	53                   	push   %ebx
  801e0d:	83 ec 18             	sub    $0x18,%esp
  801e10:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e13:	57                   	push   %edi
  801e14:	e8 25 f1 ff ff       	call   800f3e <fd2data>
  801e19:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e1b:	83 c4 10             	add    $0x10,%esp
  801e1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e23:	eb 3d                	jmp    801e62 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e25:	85 db                	test   %ebx,%ebx
  801e27:	74 04                	je     801e2d <devpipe_read+0x26>
				return i;
  801e29:	89 d8                	mov    %ebx,%eax
  801e2b:	eb 44                	jmp    801e71 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e2d:	89 f2                	mov    %esi,%edx
  801e2f:	89 f8                	mov    %edi,%eax
  801e31:	e8 e5 fe ff ff       	call   801d1b <_pipeisclosed>
  801e36:	85 c0                	test   %eax,%eax
  801e38:	75 32                	jne    801e6c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e3a:	e8 2a ed ff ff       	call   800b69 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e3f:	8b 06                	mov    (%esi),%eax
  801e41:	3b 46 04             	cmp    0x4(%esi),%eax
  801e44:	74 df                	je     801e25 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e46:	99                   	cltd   
  801e47:	c1 ea 1b             	shr    $0x1b,%edx
  801e4a:	01 d0                	add    %edx,%eax
  801e4c:	83 e0 1f             	and    $0x1f,%eax
  801e4f:	29 d0                	sub    %edx,%eax
  801e51:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e59:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e5c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e5f:	83 c3 01             	add    $0x1,%ebx
  801e62:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e65:	75 d8                	jne    801e3f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e67:	8b 45 10             	mov    0x10(%ebp),%eax
  801e6a:	eb 05                	jmp    801e71 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e6c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e74:	5b                   	pop    %ebx
  801e75:	5e                   	pop    %esi
  801e76:	5f                   	pop    %edi
  801e77:	5d                   	pop    %ebp
  801e78:	c3                   	ret    

00801e79 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e79:	55                   	push   %ebp
  801e7a:	89 e5                	mov    %esp,%ebp
  801e7c:	56                   	push   %esi
  801e7d:	53                   	push   %ebx
  801e7e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e84:	50                   	push   %eax
  801e85:	e8 cb f0 ff ff       	call   800f55 <fd_alloc>
  801e8a:	83 c4 10             	add    $0x10,%esp
  801e8d:	89 c2                	mov    %eax,%edx
  801e8f:	85 c0                	test   %eax,%eax
  801e91:	0f 88 2c 01 00 00    	js     801fc3 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e97:	83 ec 04             	sub    $0x4,%esp
  801e9a:	68 07 04 00 00       	push   $0x407
  801e9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801ea2:	6a 00                	push   $0x0
  801ea4:	e8 df ec ff ff       	call   800b88 <sys_page_alloc>
  801ea9:	83 c4 10             	add    $0x10,%esp
  801eac:	89 c2                	mov    %eax,%edx
  801eae:	85 c0                	test   %eax,%eax
  801eb0:	0f 88 0d 01 00 00    	js     801fc3 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801eb6:	83 ec 0c             	sub    $0xc,%esp
  801eb9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ebc:	50                   	push   %eax
  801ebd:	e8 93 f0 ff ff       	call   800f55 <fd_alloc>
  801ec2:	89 c3                	mov    %eax,%ebx
  801ec4:	83 c4 10             	add    $0x10,%esp
  801ec7:	85 c0                	test   %eax,%eax
  801ec9:	0f 88 e2 00 00 00    	js     801fb1 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ecf:	83 ec 04             	sub    $0x4,%esp
  801ed2:	68 07 04 00 00       	push   $0x407
  801ed7:	ff 75 f0             	pushl  -0x10(%ebp)
  801eda:	6a 00                	push   $0x0
  801edc:	e8 a7 ec ff ff       	call   800b88 <sys_page_alloc>
  801ee1:	89 c3                	mov    %eax,%ebx
  801ee3:	83 c4 10             	add    $0x10,%esp
  801ee6:	85 c0                	test   %eax,%eax
  801ee8:	0f 88 c3 00 00 00    	js     801fb1 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801eee:	83 ec 0c             	sub    $0xc,%esp
  801ef1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ef4:	e8 45 f0 ff ff       	call   800f3e <fd2data>
  801ef9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801efb:	83 c4 0c             	add    $0xc,%esp
  801efe:	68 07 04 00 00       	push   $0x407
  801f03:	50                   	push   %eax
  801f04:	6a 00                	push   $0x0
  801f06:	e8 7d ec ff ff       	call   800b88 <sys_page_alloc>
  801f0b:	89 c3                	mov    %eax,%ebx
  801f0d:	83 c4 10             	add    $0x10,%esp
  801f10:	85 c0                	test   %eax,%eax
  801f12:	0f 88 89 00 00 00    	js     801fa1 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f18:	83 ec 0c             	sub    $0xc,%esp
  801f1b:	ff 75 f0             	pushl  -0x10(%ebp)
  801f1e:	e8 1b f0 ff ff       	call   800f3e <fd2data>
  801f23:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f2a:	50                   	push   %eax
  801f2b:	6a 00                	push   $0x0
  801f2d:	56                   	push   %esi
  801f2e:	6a 00                	push   $0x0
  801f30:	e8 96 ec ff ff       	call   800bcb <sys_page_map>
  801f35:	89 c3                	mov    %eax,%ebx
  801f37:	83 c4 20             	add    $0x20,%esp
  801f3a:	85 c0                	test   %eax,%eax
  801f3c:	78 55                	js     801f93 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f3e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f47:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f4c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f53:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f5c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f61:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f68:	83 ec 0c             	sub    $0xc,%esp
  801f6b:	ff 75 f4             	pushl  -0xc(%ebp)
  801f6e:	e8 bb ef ff ff       	call   800f2e <fd2num>
  801f73:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f76:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f78:	83 c4 04             	add    $0x4,%esp
  801f7b:	ff 75 f0             	pushl  -0x10(%ebp)
  801f7e:	e8 ab ef ff ff       	call   800f2e <fd2num>
  801f83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f86:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f89:	83 c4 10             	add    $0x10,%esp
  801f8c:	ba 00 00 00 00       	mov    $0x0,%edx
  801f91:	eb 30                	jmp    801fc3 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f93:	83 ec 08             	sub    $0x8,%esp
  801f96:	56                   	push   %esi
  801f97:	6a 00                	push   $0x0
  801f99:	e8 6f ec ff ff       	call   800c0d <sys_page_unmap>
  801f9e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801fa1:	83 ec 08             	sub    $0x8,%esp
  801fa4:	ff 75 f0             	pushl  -0x10(%ebp)
  801fa7:	6a 00                	push   $0x0
  801fa9:	e8 5f ec ff ff       	call   800c0d <sys_page_unmap>
  801fae:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801fb1:	83 ec 08             	sub    $0x8,%esp
  801fb4:	ff 75 f4             	pushl  -0xc(%ebp)
  801fb7:	6a 00                	push   $0x0
  801fb9:	e8 4f ec ff ff       	call   800c0d <sys_page_unmap>
  801fbe:	83 c4 10             	add    $0x10,%esp
  801fc1:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801fc3:	89 d0                	mov    %edx,%eax
  801fc5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fc8:	5b                   	pop    %ebx
  801fc9:	5e                   	pop    %esi
  801fca:	5d                   	pop    %ebp
  801fcb:	c3                   	ret    

00801fcc <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801fcc:	55                   	push   %ebp
  801fcd:	89 e5                	mov    %esp,%ebp
  801fcf:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fd2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fd5:	50                   	push   %eax
  801fd6:	ff 75 08             	pushl  0x8(%ebp)
  801fd9:	e8 c6 ef ff ff       	call   800fa4 <fd_lookup>
  801fde:	83 c4 10             	add    $0x10,%esp
  801fe1:	85 c0                	test   %eax,%eax
  801fe3:	78 18                	js     801ffd <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fe5:	83 ec 0c             	sub    $0xc,%esp
  801fe8:	ff 75 f4             	pushl  -0xc(%ebp)
  801feb:	e8 4e ef ff ff       	call   800f3e <fd2data>
	return _pipeisclosed(fd, p);
  801ff0:	89 c2                	mov    %eax,%edx
  801ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff5:	e8 21 fd ff ff       	call   801d1b <_pipeisclosed>
  801ffa:	83 c4 10             	add    $0x10,%esp
}
  801ffd:	c9                   	leave  
  801ffe:	c3                   	ret    

00801fff <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fff:	55                   	push   %ebp
  802000:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802002:	b8 00 00 00 00       	mov    $0x0,%eax
  802007:	5d                   	pop    %ebp
  802008:	c3                   	ret    

00802009 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802009:	55                   	push   %ebp
  80200a:	89 e5                	mov    %esp,%ebp
  80200c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80200f:	68 27 2a 80 00       	push   $0x802a27
  802014:	ff 75 0c             	pushl  0xc(%ebp)
  802017:	e8 69 e7 ff ff       	call   800785 <strcpy>
	return 0;
}
  80201c:	b8 00 00 00 00       	mov    $0x0,%eax
  802021:	c9                   	leave  
  802022:	c3                   	ret    

00802023 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802023:	55                   	push   %ebp
  802024:	89 e5                	mov    %esp,%ebp
  802026:	57                   	push   %edi
  802027:	56                   	push   %esi
  802028:	53                   	push   %ebx
  802029:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80202f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802034:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80203a:	eb 2d                	jmp    802069 <devcons_write+0x46>
		m = n - tot;
  80203c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80203f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802041:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802044:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802049:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80204c:	83 ec 04             	sub    $0x4,%esp
  80204f:	53                   	push   %ebx
  802050:	03 45 0c             	add    0xc(%ebp),%eax
  802053:	50                   	push   %eax
  802054:	57                   	push   %edi
  802055:	e8 bd e8 ff ff       	call   800917 <memmove>
		sys_cputs(buf, m);
  80205a:	83 c4 08             	add    $0x8,%esp
  80205d:	53                   	push   %ebx
  80205e:	57                   	push   %edi
  80205f:	e8 68 ea ff ff       	call   800acc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802064:	01 de                	add    %ebx,%esi
  802066:	83 c4 10             	add    $0x10,%esp
  802069:	89 f0                	mov    %esi,%eax
  80206b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80206e:	72 cc                	jb     80203c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802070:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802073:	5b                   	pop    %ebx
  802074:	5e                   	pop    %esi
  802075:	5f                   	pop    %edi
  802076:	5d                   	pop    %ebp
  802077:	c3                   	ret    

00802078 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802078:	55                   	push   %ebp
  802079:	89 e5                	mov    %esp,%ebp
  80207b:	83 ec 08             	sub    $0x8,%esp
  80207e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802083:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802087:	74 2a                	je     8020b3 <devcons_read+0x3b>
  802089:	eb 05                	jmp    802090 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80208b:	e8 d9 ea ff ff       	call   800b69 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802090:	e8 55 ea ff ff       	call   800aea <sys_cgetc>
  802095:	85 c0                	test   %eax,%eax
  802097:	74 f2                	je     80208b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802099:	85 c0                	test   %eax,%eax
  80209b:	78 16                	js     8020b3 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80209d:	83 f8 04             	cmp    $0x4,%eax
  8020a0:	74 0c                	je     8020ae <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8020a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020a5:	88 02                	mov    %al,(%edx)
	return 1;
  8020a7:	b8 01 00 00 00       	mov    $0x1,%eax
  8020ac:	eb 05                	jmp    8020b3 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020ae:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020b3:	c9                   	leave  
  8020b4:	c3                   	ret    

008020b5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020b5:	55                   	push   %ebp
  8020b6:	89 e5                	mov    %esp,%ebp
  8020b8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8020be:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020c1:	6a 01                	push   $0x1
  8020c3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020c6:	50                   	push   %eax
  8020c7:	e8 00 ea ff ff       	call   800acc <sys_cputs>
}
  8020cc:	83 c4 10             	add    $0x10,%esp
  8020cf:	c9                   	leave  
  8020d0:	c3                   	ret    

008020d1 <getchar>:

int
getchar(void)
{
  8020d1:	55                   	push   %ebp
  8020d2:	89 e5                	mov    %esp,%ebp
  8020d4:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020d7:	6a 01                	push   $0x1
  8020d9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020dc:	50                   	push   %eax
  8020dd:	6a 00                	push   $0x0
  8020df:	e8 26 f1 ff ff       	call   80120a <read>
	if (r < 0)
  8020e4:	83 c4 10             	add    $0x10,%esp
  8020e7:	85 c0                	test   %eax,%eax
  8020e9:	78 0f                	js     8020fa <getchar+0x29>
		return r;
	if (r < 1)
  8020eb:	85 c0                	test   %eax,%eax
  8020ed:	7e 06                	jle    8020f5 <getchar+0x24>
		return -E_EOF;
	return c;
  8020ef:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020f3:	eb 05                	jmp    8020fa <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020f5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020fa:	c9                   	leave  
  8020fb:	c3                   	ret    

008020fc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020fc:	55                   	push   %ebp
  8020fd:	89 e5                	mov    %esp,%ebp
  8020ff:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802102:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802105:	50                   	push   %eax
  802106:	ff 75 08             	pushl  0x8(%ebp)
  802109:	e8 96 ee ff ff       	call   800fa4 <fd_lookup>
  80210e:	83 c4 10             	add    $0x10,%esp
  802111:	85 c0                	test   %eax,%eax
  802113:	78 11                	js     802126 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802115:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802118:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80211e:	39 10                	cmp    %edx,(%eax)
  802120:	0f 94 c0             	sete   %al
  802123:	0f b6 c0             	movzbl %al,%eax
}
  802126:	c9                   	leave  
  802127:	c3                   	ret    

00802128 <opencons>:

int
opencons(void)
{
  802128:	55                   	push   %ebp
  802129:	89 e5                	mov    %esp,%ebp
  80212b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80212e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802131:	50                   	push   %eax
  802132:	e8 1e ee ff ff       	call   800f55 <fd_alloc>
  802137:	83 c4 10             	add    $0x10,%esp
		return r;
  80213a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80213c:	85 c0                	test   %eax,%eax
  80213e:	78 3e                	js     80217e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802140:	83 ec 04             	sub    $0x4,%esp
  802143:	68 07 04 00 00       	push   $0x407
  802148:	ff 75 f4             	pushl  -0xc(%ebp)
  80214b:	6a 00                	push   $0x0
  80214d:	e8 36 ea ff ff       	call   800b88 <sys_page_alloc>
  802152:	83 c4 10             	add    $0x10,%esp
		return r;
  802155:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802157:	85 c0                	test   %eax,%eax
  802159:	78 23                	js     80217e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80215b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802161:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802164:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802166:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802169:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802170:	83 ec 0c             	sub    $0xc,%esp
  802173:	50                   	push   %eax
  802174:	e8 b5 ed ff ff       	call   800f2e <fd2num>
  802179:	89 c2                	mov    %eax,%edx
  80217b:	83 c4 10             	add    $0x10,%esp
}
  80217e:	89 d0                	mov    %edx,%eax
  802180:	c9                   	leave  
  802181:	c3                   	ret    

00802182 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802182:	55                   	push   %ebp
  802183:	89 e5                	mov    %esp,%ebp
  802185:	56                   	push   %esi
  802186:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802187:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80218a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802190:	e8 b5 e9 ff ff       	call   800b4a <sys_getenvid>
  802195:	83 ec 0c             	sub    $0xc,%esp
  802198:	ff 75 0c             	pushl  0xc(%ebp)
  80219b:	ff 75 08             	pushl  0x8(%ebp)
  80219e:	56                   	push   %esi
  80219f:	50                   	push   %eax
  8021a0:	68 34 2a 80 00       	push   $0x802a34
  8021a5:	e8 56 e0 ff ff       	call   800200 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8021aa:	83 c4 18             	add    $0x18,%esp
  8021ad:	53                   	push   %ebx
  8021ae:	ff 75 10             	pushl  0x10(%ebp)
  8021b1:	e8 f9 df ff ff       	call   8001af <vcprintf>
	cprintf("\n");
  8021b6:	c7 04 24 b0 25 80 00 	movl   $0x8025b0,(%esp)
  8021bd:	e8 3e e0 ff ff       	call   800200 <cprintf>
  8021c2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8021c5:	cc                   	int3   
  8021c6:	eb fd                	jmp    8021c5 <_panic+0x43>

008021c8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021c8:	55                   	push   %ebp
  8021c9:	89 e5                	mov    %esp,%ebp
  8021cb:	56                   	push   %esi
  8021cc:	53                   	push   %ebx
  8021cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8021d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8021d6:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8021d8:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8021dd:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8021e0:	83 ec 0c             	sub    $0xc,%esp
  8021e3:	50                   	push   %eax
  8021e4:	e8 4f eb ff ff       	call   800d38 <sys_ipc_recv>

	if (from_env_store != NULL)
  8021e9:	83 c4 10             	add    $0x10,%esp
  8021ec:	85 f6                	test   %esi,%esi
  8021ee:	74 14                	je     802204 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8021f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8021f5:	85 c0                	test   %eax,%eax
  8021f7:	78 09                	js     802202 <ipc_recv+0x3a>
  8021f9:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8021ff:	8b 52 74             	mov    0x74(%edx),%edx
  802202:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802204:	85 db                	test   %ebx,%ebx
  802206:	74 14                	je     80221c <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802208:	ba 00 00 00 00       	mov    $0x0,%edx
  80220d:	85 c0                	test   %eax,%eax
  80220f:	78 09                	js     80221a <ipc_recv+0x52>
  802211:	8b 15 08 40 80 00    	mov    0x804008,%edx
  802217:	8b 52 78             	mov    0x78(%edx),%edx
  80221a:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80221c:	85 c0                	test   %eax,%eax
  80221e:	78 08                	js     802228 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802220:	a1 08 40 80 00       	mov    0x804008,%eax
  802225:	8b 40 70             	mov    0x70(%eax),%eax
}
  802228:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80222b:	5b                   	pop    %ebx
  80222c:	5e                   	pop    %esi
  80222d:	5d                   	pop    %ebp
  80222e:	c3                   	ret    

0080222f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80222f:	55                   	push   %ebp
  802230:	89 e5                	mov    %esp,%ebp
  802232:	57                   	push   %edi
  802233:	56                   	push   %esi
  802234:	53                   	push   %ebx
  802235:	83 ec 0c             	sub    $0xc,%esp
  802238:	8b 7d 08             	mov    0x8(%ebp),%edi
  80223b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80223e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  802241:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802243:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802248:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80224b:	ff 75 14             	pushl  0x14(%ebp)
  80224e:	53                   	push   %ebx
  80224f:	56                   	push   %esi
  802250:	57                   	push   %edi
  802251:	e8 bf ea ff ff       	call   800d15 <sys_ipc_try_send>

		if (err < 0) {
  802256:	83 c4 10             	add    $0x10,%esp
  802259:	85 c0                	test   %eax,%eax
  80225b:	79 1e                	jns    80227b <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  80225d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802260:	75 07                	jne    802269 <ipc_send+0x3a>
				sys_yield();
  802262:	e8 02 e9 ff ff       	call   800b69 <sys_yield>
  802267:	eb e2                	jmp    80224b <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802269:	50                   	push   %eax
  80226a:	68 58 2a 80 00       	push   $0x802a58
  80226f:	6a 49                	push   $0x49
  802271:	68 65 2a 80 00       	push   $0x802a65
  802276:	e8 07 ff ff ff       	call   802182 <_panic>
		}

	} while (err < 0);

}
  80227b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80227e:	5b                   	pop    %ebx
  80227f:	5e                   	pop    %esi
  802280:	5f                   	pop    %edi
  802281:	5d                   	pop    %ebp
  802282:	c3                   	ret    

00802283 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802283:	55                   	push   %ebp
  802284:	89 e5                	mov    %esp,%ebp
  802286:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802289:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80228e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802291:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802297:	8b 52 50             	mov    0x50(%edx),%edx
  80229a:	39 ca                	cmp    %ecx,%edx
  80229c:	75 0d                	jne    8022ab <ipc_find_env+0x28>
			return envs[i].env_id;
  80229e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8022a1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8022a6:	8b 40 48             	mov    0x48(%eax),%eax
  8022a9:	eb 0f                	jmp    8022ba <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022ab:	83 c0 01             	add    $0x1,%eax
  8022ae:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022b3:	75 d9                	jne    80228e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022ba:	5d                   	pop    %ebp
  8022bb:	c3                   	ret    

008022bc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022bc:	55                   	push   %ebp
  8022bd:	89 e5                	mov    %esp,%ebp
  8022bf:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022c2:	89 d0                	mov    %edx,%eax
  8022c4:	c1 e8 16             	shr    $0x16,%eax
  8022c7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8022ce:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022d3:	f6 c1 01             	test   $0x1,%cl
  8022d6:	74 1d                	je     8022f5 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8022d8:	c1 ea 0c             	shr    $0xc,%edx
  8022db:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8022e2:	f6 c2 01             	test   $0x1,%dl
  8022e5:	74 0e                	je     8022f5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022e7:	c1 ea 0c             	shr    $0xc,%edx
  8022ea:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8022f1:	ef 
  8022f2:	0f b7 c0             	movzwl %ax,%eax
}
  8022f5:	5d                   	pop    %ebp
  8022f6:	c3                   	ret    
  8022f7:	66 90                	xchg   %ax,%ax
  8022f9:	66 90                	xchg   %ax,%ax
  8022fb:	66 90                	xchg   %ax,%ax
  8022fd:	66 90                	xchg   %ax,%ax
  8022ff:	90                   	nop

00802300 <__udivdi3>:
  802300:	55                   	push   %ebp
  802301:	57                   	push   %edi
  802302:	56                   	push   %esi
  802303:	53                   	push   %ebx
  802304:	83 ec 1c             	sub    $0x1c,%esp
  802307:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80230b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80230f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802313:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802317:	85 f6                	test   %esi,%esi
  802319:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80231d:	89 ca                	mov    %ecx,%edx
  80231f:	89 f8                	mov    %edi,%eax
  802321:	75 3d                	jne    802360 <__udivdi3+0x60>
  802323:	39 cf                	cmp    %ecx,%edi
  802325:	0f 87 c5 00 00 00    	ja     8023f0 <__udivdi3+0xf0>
  80232b:	85 ff                	test   %edi,%edi
  80232d:	89 fd                	mov    %edi,%ebp
  80232f:	75 0b                	jne    80233c <__udivdi3+0x3c>
  802331:	b8 01 00 00 00       	mov    $0x1,%eax
  802336:	31 d2                	xor    %edx,%edx
  802338:	f7 f7                	div    %edi
  80233a:	89 c5                	mov    %eax,%ebp
  80233c:	89 c8                	mov    %ecx,%eax
  80233e:	31 d2                	xor    %edx,%edx
  802340:	f7 f5                	div    %ebp
  802342:	89 c1                	mov    %eax,%ecx
  802344:	89 d8                	mov    %ebx,%eax
  802346:	89 cf                	mov    %ecx,%edi
  802348:	f7 f5                	div    %ebp
  80234a:	89 c3                	mov    %eax,%ebx
  80234c:	89 d8                	mov    %ebx,%eax
  80234e:	89 fa                	mov    %edi,%edx
  802350:	83 c4 1c             	add    $0x1c,%esp
  802353:	5b                   	pop    %ebx
  802354:	5e                   	pop    %esi
  802355:	5f                   	pop    %edi
  802356:	5d                   	pop    %ebp
  802357:	c3                   	ret    
  802358:	90                   	nop
  802359:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802360:	39 ce                	cmp    %ecx,%esi
  802362:	77 74                	ja     8023d8 <__udivdi3+0xd8>
  802364:	0f bd fe             	bsr    %esi,%edi
  802367:	83 f7 1f             	xor    $0x1f,%edi
  80236a:	0f 84 98 00 00 00    	je     802408 <__udivdi3+0x108>
  802370:	bb 20 00 00 00       	mov    $0x20,%ebx
  802375:	89 f9                	mov    %edi,%ecx
  802377:	89 c5                	mov    %eax,%ebp
  802379:	29 fb                	sub    %edi,%ebx
  80237b:	d3 e6                	shl    %cl,%esi
  80237d:	89 d9                	mov    %ebx,%ecx
  80237f:	d3 ed                	shr    %cl,%ebp
  802381:	89 f9                	mov    %edi,%ecx
  802383:	d3 e0                	shl    %cl,%eax
  802385:	09 ee                	or     %ebp,%esi
  802387:	89 d9                	mov    %ebx,%ecx
  802389:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80238d:	89 d5                	mov    %edx,%ebp
  80238f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802393:	d3 ed                	shr    %cl,%ebp
  802395:	89 f9                	mov    %edi,%ecx
  802397:	d3 e2                	shl    %cl,%edx
  802399:	89 d9                	mov    %ebx,%ecx
  80239b:	d3 e8                	shr    %cl,%eax
  80239d:	09 c2                	or     %eax,%edx
  80239f:	89 d0                	mov    %edx,%eax
  8023a1:	89 ea                	mov    %ebp,%edx
  8023a3:	f7 f6                	div    %esi
  8023a5:	89 d5                	mov    %edx,%ebp
  8023a7:	89 c3                	mov    %eax,%ebx
  8023a9:	f7 64 24 0c          	mull   0xc(%esp)
  8023ad:	39 d5                	cmp    %edx,%ebp
  8023af:	72 10                	jb     8023c1 <__udivdi3+0xc1>
  8023b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8023b5:	89 f9                	mov    %edi,%ecx
  8023b7:	d3 e6                	shl    %cl,%esi
  8023b9:	39 c6                	cmp    %eax,%esi
  8023bb:	73 07                	jae    8023c4 <__udivdi3+0xc4>
  8023bd:	39 d5                	cmp    %edx,%ebp
  8023bf:	75 03                	jne    8023c4 <__udivdi3+0xc4>
  8023c1:	83 eb 01             	sub    $0x1,%ebx
  8023c4:	31 ff                	xor    %edi,%edi
  8023c6:	89 d8                	mov    %ebx,%eax
  8023c8:	89 fa                	mov    %edi,%edx
  8023ca:	83 c4 1c             	add    $0x1c,%esp
  8023cd:	5b                   	pop    %ebx
  8023ce:	5e                   	pop    %esi
  8023cf:	5f                   	pop    %edi
  8023d0:	5d                   	pop    %ebp
  8023d1:	c3                   	ret    
  8023d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023d8:	31 ff                	xor    %edi,%edi
  8023da:	31 db                	xor    %ebx,%ebx
  8023dc:	89 d8                	mov    %ebx,%eax
  8023de:	89 fa                	mov    %edi,%edx
  8023e0:	83 c4 1c             	add    $0x1c,%esp
  8023e3:	5b                   	pop    %ebx
  8023e4:	5e                   	pop    %esi
  8023e5:	5f                   	pop    %edi
  8023e6:	5d                   	pop    %ebp
  8023e7:	c3                   	ret    
  8023e8:	90                   	nop
  8023e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023f0:	89 d8                	mov    %ebx,%eax
  8023f2:	f7 f7                	div    %edi
  8023f4:	31 ff                	xor    %edi,%edi
  8023f6:	89 c3                	mov    %eax,%ebx
  8023f8:	89 d8                	mov    %ebx,%eax
  8023fa:	89 fa                	mov    %edi,%edx
  8023fc:	83 c4 1c             	add    $0x1c,%esp
  8023ff:	5b                   	pop    %ebx
  802400:	5e                   	pop    %esi
  802401:	5f                   	pop    %edi
  802402:	5d                   	pop    %ebp
  802403:	c3                   	ret    
  802404:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802408:	39 ce                	cmp    %ecx,%esi
  80240a:	72 0c                	jb     802418 <__udivdi3+0x118>
  80240c:	31 db                	xor    %ebx,%ebx
  80240e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802412:	0f 87 34 ff ff ff    	ja     80234c <__udivdi3+0x4c>
  802418:	bb 01 00 00 00       	mov    $0x1,%ebx
  80241d:	e9 2a ff ff ff       	jmp    80234c <__udivdi3+0x4c>
  802422:	66 90                	xchg   %ax,%ax
  802424:	66 90                	xchg   %ax,%ax
  802426:	66 90                	xchg   %ax,%ax
  802428:	66 90                	xchg   %ax,%ax
  80242a:	66 90                	xchg   %ax,%ax
  80242c:	66 90                	xchg   %ax,%ax
  80242e:	66 90                	xchg   %ax,%ax

00802430 <__umoddi3>:
  802430:	55                   	push   %ebp
  802431:	57                   	push   %edi
  802432:	56                   	push   %esi
  802433:	53                   	push   %ebx
  802434:	83 ec 1c             	sub    $0x1c,%esp
  802437:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80243b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80243f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802443:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802447:	85 d2                	test   %edx,%edx
  802449:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80244d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802451:	89 f3                	mov    %esi,%ebx
  802453:	89 3c 24             	mov    %edi,(%esp)
  802456:	89 74 24 04          	mov    %esi,0x4(%esp)
  80245a:	75 1c                	jne    802478 <__umoddi3+0x48>
  80245c:	39 f7                	cmp    %esi,%edi
  80245e:	76 50                	jbe    8024b0 <__umoddi3+0x80>
  802460:	89 c8                	mov    %ecx,%eax
  802462:	89 f2                	mov    %esi,%edx
  802464:	f7 f7                	div    %edi
  802466:	89 d0                	mov    %edx,%eax
  802468:	31 d2                	xor    %edx,%edx
  80246a:	83 c4 1c             	add    $0x1c,%esp
  80246d:	5b                   	pop    %ebx
  80246e:	5e                   	pop    %esi
  80246f:	5f                   	pop    %edi
  802470:	5d                   	pop    %ebp
  802471:	c3                   	ret    
  802472:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802478:	39 f2                	cmp    %esi,%edx
  80247a:	89 d0                	mov    %edx,%eax
  80247c:	77 52                	ja     8024d0 <__umoddi3+0xa0>
  80247e:	0f bd ea             	bsr    %edx,%ebp
  802481:	83 f5 1f             	xor    $0x1f,%ebp
  802484:	75 5a                	jne    8024e0 <__umoddi3+0xb0>
  802486:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80248a:	0f 82 e0 00 00 00    	jb     802570 <__umoddi3+0x140>
  802490:	39 0c 24             	cmp    %ecx,(%esp)
  802493:	0f 86 d7 00 00 00    	jbe    802570 <__umoddi3+0x140>
  802499:	8b 44 24 08          	mov    0x8(%esp),%eax
  80249d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024a1:	83 c4 1c             	add    $0x1c,%esp
  8024a4:	5b                   	pop    %ebx
  8024a5:	5e                   	pop    %esi
  8024a6:	5f                   	pop    %edi
  8024a7:	5d                   	pop    %ebp
  8024a8:	c3                   	ret    
  8024a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024b0:	85 ff                	test   %edi,%edi
  8024b2:	89 fd                	mov    %edi,%ebp
  8024b4:	75 0b                	jne    8024c1 <__umoddi3+0x91>
  8024b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024bb:	31 d2                	xor    %edx,%edx
  8024bd:	f7 f7                	div    %edi
  8024bf:	89 c5                	mov    %eax,%ebp
  8024c1:	89 f0                	mov    %esi,%eax
  8024c3:	31 d2                	xor    %edx,%edx
  8024c5:	f7 f5                	div    %ebp
  8024c7:	89 c8                	mov    %ecx,%eax
  8024c9:	f7 f5                	div    %ebp
  8024cb:	89 d0                	mov    %edx,%eax
  8024cd:	eb 99                	jmp    802468 <__umoddi3+0x38>
  8024cf:	90                   	nop
  8024d0:	89 c8                	mov    %ecx,%eax
  8024d2:	89 f2                	mov    %esi,%edx
  8024d4:	83 c4 1c             	add    $0x1c,%esp
  8024d7:	5b                   	pop    %ebx
  8024d8:	5e                   	pop    %esi
  8024d9:	5f                   	pop    %edi
  8024da:	5d                   	pop    %ebp
  8024db:	c3                   	ret    
  8024dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024e0:	8b 34 24             	mov    (%esp),%esi
  8024e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8024e8:	89 e9                	mov    %ebp,%ecx
  8024ea:	29 ef                	sub    %ebp,%edi
  8024ec:	d3 e0                	shl    %cl,%eax
  8024ee:	89 f9                	mov    %edi,%ecx
  8024f0:	89 f2                	mov    %esi,%edx
  8024f2:	d3 ea                	shr    %cl,%edx
  8024f4:	89 e9                	mov    %ebp,%ecx
  8024f6:	09 c2                	or     %eax,%edx
  8024f8:	89 d8                	mov    %ebx,%eax
  8024fa:	89 14 24             	mov    %edx,(%esp)
  8024fd:	89 f2                	mov    %esi,%edx
  8024ff:	d3 e2                	shl    %cl,%edx
  802501:	89 f9                	mov    %edi,%ecx
  802503:	89 54 24 04          	mov    %edx,0x4(%esp)
  802507:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80250b:	d3 e8                	shr    %cl,%eax
  80250d:	89 e9                	mov    %ebp,%ecx
  80250f:	89 c6                	mov    %eax,%esi
  802511:	d3 e3                	shl    %cl,%ebx
  802513:	89 f9                	mov    %edi,%ecx
  802515:	89 d0                	mov    %edx,%eax
  802517:	d3 e8                	shr    %cl,%eax
  802519:	89 e9                	mov    %ebp,%ecx
  80251b:	09 d8                	or     %ebx,%eax
  80251d:	89 d3                	mov    %edx,%ebx
  80251f:	89 f2                	mov    %esi,%edx
  802521:	f7 34 24             	divl   (%esp)
  802524:	89 d6                	mov    %edx,%esi
  802526:	d3 e3                	shl    %cl,%ebx
  802528:	f7 64 24 04          	mull   0x4(%esp)
  80252c:	39 d6                	cmp    %edx,%esi
  80252e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802532:	89 d1                	mov    %edx,%ecx
  802534:	89 c3                	mov    %eax,%ebx
  802536:	72 08                	jb     802540 <__umoddi3+0x110>
  802538:	75 11                	jne    80254b <__umoddi3+0x11b>
  80253a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80253e:	73 0b                	jae    80254b <__umoddi3+0x11b>
  802540:	2b 44 24 04          	sub    0x4(%esp),%eax
  802544:	1b 14 24             	sbb    (%esp),%edx
  802547:	89 d1                	mov    %edx,%ecx
  802549:	89 c3                	mov    %eax,%ebx
  80254b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80254f:	29 da                	sub    %ebx,%edx
  802551:	19 ce                	sbb    %ecx,%esi
  802553:	89 f9                	mov    %edi,%ecx
  802555:	89 f0                	mov    %esi,%eax
  802557:	d3 e0                	shl    %cl,%eax
  802559:	89 e9                	mov    %ebp,%ecx
  80255b:	d3 ea                	shr    %cl,%edx
  80255d:	89 e9                	mov    %ebp,%ecx
  80255f:	d3 ee                	shr    %cl,%esi
  802561:	09 d0                	or     %edx,%eax
  802563:	89 f2                	mov    %esi,%edx
  802565:	83 c4 1c             	add    $0x1c,%esp
  802568:	5b                   	pop    %ebx
  802569:	5e                   	pop    %esi
  80256a:	5f                   	pop    %edi
  80256b:	5d                   	pop    %ebp
  80256c:	c3                   	ret    
  80256d:	8d 76 00             	lea    0x0(%esi),%esi
  802570:	29 f9                	sub    %edi,%ecx
  802572:	19 d6                	sbb    %edx,%esi
  802574:	89 74 24 04          	mov    %esi,0x4(%esp)
  802578:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80257c:	e9 18 ff ff ff       	jmp    802499 <__umoddi3+0x69>
