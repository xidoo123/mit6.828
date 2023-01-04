
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
  800039:	68 c0 20 80 00       	push   $0x8020c0
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
  800067:	e8 0d 0d 00 00       	call   800d79 <argstart>
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
  800091:	e8 13 0d 00 00       	call   800da9 <argnext>
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
  8000ad:	e8 0f 13 00 00       	call   8013c1 <fstat>
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
  8000ce:	68 d4 20 80 00       	push   $0x8020d4
  8000d3:	6a 01                	push   $0x1
  8000d5:	e8 d4 16 00 00       	call   8017ae <fprintf>
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
  8000f0:	68 d4 20 80 00       	push   $0x8020d4
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
  80012a:	a3 04 40 80 00       	mov    %eax,0x804004

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
  800159:	e8 3a 0f 00 00       	call   801098 <close_all>
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
  800263:	e8 c8 1b 00 00       	call   801e30 <__udivdi3>
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
  8002a6:	e8 b5 1c 00 00       	call   801f60 <__umoddi3>
  8002ab:	83 c4 14             	add    $0x14,%esp
  8002ae:	0f be 80 06 21 80 00 	movsbl 0x802106(%eax),%eax
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
  8003aa:	ff 24 85 40 22 80 00 	jmp    *0x802240(,%eax,4)
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
  80046e:	8b 14 85 a0 23 80 00 	mov    0x8023a0(,%eax,4),%edx
  800475:	85 d2                	test   %edx,%edx
  800477:	75 18                	jne    800491 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800479:	50                   	push   %eax
  80047a:	68 1e 21 80 00       	push   $0x80211e
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
  800492:	68 d1 24 80 00       	push   $0x8024d1
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
  8004b6:	b8 17 21 80 00       	mov    $0x802117,%eax
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
  800b31:	68 ff 23 80 00       	push   $0x8023ff
  800b36:	6a 23                	push   $0x23
  800b38:	68 1c 24 80 00       	push   $0x80241c
  800b3d:	e8 78 11 00 00       	call   801cba <_panic>

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
  800bb2:	68 ff 23 80 00       	push   $0x8023ff
  800bb7:	6a 23                	push   $0x23
  800bb9:	68 1c 24 80 00       	push   $0x80241c
  800bbe:	e8 f7 10 00 00       	call   801cba <_panic>

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
  800bf4:	68 ff 23 80 00       	push   $0x8023ff
  800bf9:	6a 23                	push   $0x23
  800bfb:	68 1c 24 80 00       	push   $0x80241c
  800c00:	e8 b5 10 00 00       	call   801cba <_panic>

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
  800c36:	68 ff 23 80 00       	push   $0x8023ff
  800c3b:	6a 23                	push   $0x23
  800c3d:	68 1c 24 80 00       	push   $0x80241c
  800c42:	e8 73 10 00 00       	call   801cba <_panic>

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
  800c78:	68 ff 23 80 00       	push   $0x8023ff
  800c7d:	6a 23                	push   $0x23
  800c7f:	68 1c 24 80 00       	push   $0x80241c
  800c84:	e8 31 10 00 00       	call   801cba <_panic>

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
  800cba:	68 ff 23 80 00       	push   $0x8023ff
  800cbf:	6a 23                	push   $0x23
  800cc1:	68 1c 24 80 00       	push   $0x80241c
  800cc6:	e8 ef 0f 00 00       	call   801cba <_panic>

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
  800cfc:	68 ff 23 80 00       	push   $0x8023ff
  800d01:	6a 23                	push   $0x23
  800d03:	68 1c 24 80 00       	push   $0x80241c
  800d08:	e8 ad 0f 00 00       	call   801cba <_panic>

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
  800d60:	68 ff 23 80 00       	push   $0x8023ff
  800d65:	6a 23                	push   $0x23
  800d67:	68 1c 24 80 00       	push   $0x80241c
  800d6c:	e8 49 0f 00 00       	call   801cba <_panic>

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

00800d79 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d82:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800d85:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800d87:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800d8a:	83 3a 01             	cmpl   $0x1,(%edx)
  800d8d:	7e 09                	jle    800d98 <argstart+0x1f>
  800d8f:	ba d1 20 80 00       	mov    $0x8020d1,%edx
  800d94:	85 c9                	test   %ecx,%ecx
  800d96:	75 05                	jne    800d9d <argstart+0x24>
  800d98:	ba 00 00 00 00       	mov    $0x0,%edx
  800d9d:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800da0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <argnext>:

int
argnext(struct Argstate *args)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	53                   	push   %ebx
  800dad:	83 ec 04             	sub    $0x4,%esp
  800db0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800db3:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800dba:	8b 43 08             	mov    0x8(%ebx),%eax
  800dbd:	85 c0                	test   %eax,%eax
  800dbf:	74 6f                	je     800e30 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  800dc1:	80 38 00             	cmpb   $0x0,(%eax)
  800dc4:	75 4e                	jne    800e14 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800dc6:	8b 0b                	mov    (%ebx),%ecx
  800dc8:	83 39 01             	cmpl   $0x1,(%ecx)
  800dcb:	74 55                	je     800e22 <argnext+0x79>
		    || args->argv[1][0] != '-'
  800dcd:	8b 53 04             	mov    0x4(%ebx),%edx
  800dd0:	8b 42 04             	mov    0x4(%edx),%eax
  800dd3:	80 38 2d             	cmpb   $0x2d,(%eax)
  800dd6:	75 4a                	jne    800e22 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  800dd8:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800ddc:	74 44                	je     800e22 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800dde:	83 c0 01             	add    $0x1,%eax
  800de1:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800de4:	83 ec 04             	sub    $0x4,%esp
  800de7:	8b 01                	mov    (%ecx),%eax
  800de9:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800df0:	50                   	push   %eax
  800df1:	8d 42 08             	lea    0x8(%edx),%eax
  800df4:	50                   	push   %eax
  800df5:	83 c2 04             	add    $0x4,%edx
  800df8:	52                   	push   %edx
  800df9:	e8 19 fb ff ff       	call   800917 <memmove>
		(*args->argc)--;
  800dfe:	8b 03                	mov    (%ebx),%eax
  800e00:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800e03:	8b 43 08             	mov    0x8(%ebx),%eax
  800e06:	83 c4 10             	add    $0x10,%esp
  800e09:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e0c:	75 06                	jne    800e14 <argnext+0x6b>
  800e0e:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e12:	74 0e                	je     800e22 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800e14:	8b 53 08             	mov    0x8(%ebx),%edx
  800e17:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800e1a:	83 c2 01             	add    $0x1,%edx
  800e1d:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800e20:	eb 13                	jmp    800e35 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  800e22:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800e29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800e2e:	eb 05                	jmp    800e35 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  800e30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800e35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e38:	c9                   	leave  
  800e39:	c3                   	ret    

00800e3a <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
  800e3d:	53                   	push   %ebx
  800e3e:	83 ec 04             	sub    $0x4,%esp
  800e41:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800e44:	8b 43 08             	mov    0x8(%ebx),%eax
  800e47:	85 c0                	test   %eax,%eax
  800e49:	74 58                	je     800ea3 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  800e4b:	80 38 00             	cmpb   $0x0,(%eax)
  800e4e:	74 0c                	je     800e5c <argnextvalue+0x22>
		args->argvalue = args->curarg;
  800e50:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800e53:	c7 43 08 d1 20 80 00 	movl   $0x8020d1,0x8(%ebx)
  800e5a:	eb 42                	jmp    800e9e <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  800e5c:	8b 13                	mov    (%ebx),%edx
  800e5e:	83 3a 01             	cmpl   $0x1,(%edx)
  800e61:	7e 2d                	jle    800e90 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  800e63:	8b 43 04             	mov    0x4(%ebx),%eax
  800e66:	8b 48 04             	mov    0x4(%eax),%ecx
  800e69:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800e6c:	83 ec 04             	sub    $0x4,%esp
  800e6f:	8b 12                	mov    (%edx),%edx
  800e71:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  800e78:	52                   	push   %edx
  800e79:	8d 50 08             	lea    0x8(%eax),%edx
  800e7c:	52                   	push   %edx
  800e7d:	83 c0 04             	add    $0x4,%eax
  800e80:	50                   	push   %eax
  800e81:	e8 91 fa ff ff       	call   800917 <memmove>
		(*args->argc)--;
  800e86:	8b 03                	mov    (%ebx),%eax
  800e88:	83 28 01             	subl   $0x1,(%eax)
  800e8b:	83 c4 10             	add    $0x10,%esp
  800e8e:	eb 0e                	jmp    800e9e <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  800e90:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800e97:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800e9e:	8b 43 0c             	mov    0xc(%ebx),%eax
  800ea1:	eb 05                	jmp    800ea8 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  800ea3:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  800ea8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eab:	c9                   	leave  
  800eac:	c3                   	ret    

00800ead <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	83 ec 08             	sub    $0x8,%esp
  800eb3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800eb6:	8b 51 0c             	mov    0xc(%ecx),%edx
  800eb9:	89 d0                	mov    %edx,%eax
  800ebb:	85 d2                	test   %edx,%edx
  800ebd:	75 0c                	jne    800ecb <argvalue+0x1e>
  800ebf:	83 ec 0c             	sub    $0xc,%esp
  800ec2:	51                   	push   %ecx
  800ec3:	e8 72 ff ff ff       	call   800e3a <argnextvalue>
  800ec8:	83 c4 10             	add    $0x10,%esp
}
  800ecb:	c9                   	leave  
  800ecc:	c3                   	ret    

00800ecd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ed0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed3:	05 00 00 00 30       	add    $0x30000000,%eax
  800ed8:	c1 e8 0c             	shr    $0xc,%eax
}
  800edb:	5d                   	pop    %ebp
  800edc:	c3                   	ret    

00800edd <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ee0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee3:	05 00 00 00 30       	add    $0x30000000,%eax
  800ee8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800eed:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800efa:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800eff:	89 c2                	mov    %eax,%edx
  800f01:	c1 ea 16             	shr    $0x16,%edx
  800f04:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f0b:	f6 c2 01             	test   $0x1,%dl
  800f0e:	74 11                	je     800f21 <fd_alloc+0x2d>
  800f10:	89 c2                	mov    %eax,%edx
  800f12:	c1 ea 0c             	shr    $0xc,%edx
  800f15:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f1c:	f6 c2 01             	test   $0x1,%dl
  800f1f:	75 09                	jne    800f2a <fd_alloc+0x36>
			*fd_store = fd;
  800f21:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f23:	b8 00 00 00 00       	mov    $0x0,%eax
  800f28:	eb 17                	jmp    800f41 <fd_alloc+0x4d>
  800f2a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f2f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f34:	75 c9                	jne    800eff <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f36:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f3c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f41:	5d                   	pop    %ebp
  800f42:	c3                   	ret    

00800f43 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f49:	83 f8 1f             	cmp    $0x1f,%eax
  800f4c:	77 36                	ja     800f84 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f4e:	c1 e0 0c             	shl    $0xc,%eax
  800f51:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f56:	89 c2                	mov    %eax,%edx
  800f58:	c1 ea 16             	shr    $0x16,%edx
  800f5b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f62:	f6 c2 01             	test   $0x1,%dl
  800f65:	74 24                	je     800f8b <fd_lookup+0x48>
  800f67:	89 c2                	mov    %eax,%edx
  800f69:	c1 ea 0c             	shr    $0xc,%edx
  800f6c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f73:	f6 c2 01             	test   $0x1,%dl
  800f76:	74 1a                	je     800f92 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f78:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f7b:	89 02                	mov    %eax,(%edx)
	return 0;
  800f7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f82:	eb 13                	jmp    800f97 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f84:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f89:	eb 0c                	jmp    800f97 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f8b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f90:	eb 05                	jmp    800f97 <fd_lookup+0x54>
  800f92:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f97:	5d                   	pop    %ebp
  800f98:	c3                   	ret    

00800f99 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f99:	55                   	push   %ebp
  800f9a:	89 e5                	mov    %esp,%ebp
  800f9c:	83 ec 08             	sub    $0x8,%esp
  800f9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fa2:	ba a8 24 80 00       	mov    $0x8024a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800fa7:	eb 13                	jmp    800fbc <dev_lookup+0x23>
  800fa9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800fac:	39 08                	cmp    %ecx,(%eax)
  800fae:	75 0c                	jne    800fbc <dev_lookup+0x23>
			*dev = devtab[i];
  800fb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb3:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fb5:	b8 00 00 00 00       	mov    $0x0,%eax
  800fba:	eb 2e                	jmp    800fea <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fbc:	8b 02                	mov    (%edx),%eax
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	75 e7                	jne    800fa9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fc2:	a1 04 40 80 00       	mov    0x804004,%eax
  800fc7:	8b 40 48             	mov    0x48(%eax),%eax
  800fca:	83 ec 04             	sub    $0x4,%esp
  800fcd:	51                   	push   %ecx
  800fce:	50                   	push   %eax
  800fcf:	68 2c 24 80 00       	push   $0x80242c
  800fd4:	e8 27 f2 ff ff       	call   800200 <cprintf>
	*dev = 0;
  800fd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fdc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fe2:	83 c4 10             	add    $0x10,%esp
  800fe5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fea:	c9                   	leave  
  800feb:	c3                   	ret    

00800fec <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	56                   	push   %esi
  800ff0:	53                   	push   %ebx
  800ff1:	83 ec 10             	sub    $0x10,%esp
  800ff4:	8b 75 08             	mov    0x8(%ebp),%esi
  800ff7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ffa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffd:	50                   	push   %eax
  800ffe:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801004:	c1 e8 0c             	shr    $0xc,%eax
  801007:	50                   	push   %eax
  801008:	e8 36 ff ff ff       	call   800f43 <fd_lookup>
  80100d:	83 c4 08             	add    $0x8,%esp
  801010:	85 c0                	test   %eax,%eax
  801012:	78 05                	js     801019 <fd_close+0x2d>
	    || fd != fd2)
  801014:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801017:	74 0c                	je     801025 <fd_close+0x39>
		return (must_exist ? r : 0);
  801019:	84 db                	test   %bl,%bl
  80101b:	ba 00 00 00 00       	mov    $0x0,%edx
  801020:	0f 44 c2             	cmove  %edx,%eax
  801023:	eb 41                	jmp    801066 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801025:	83 ec 08             	sub    $0x8,%esp
  801028:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80102b:	50                   	push   %eax
  80102c:	ff 36                	pushl  (%esi)
  80102e:	e8 66 ff ff ff       	call   800f99 <dev_lookup>
  801033:	89 c3                	mov    %eax,%ebx
  801035:	83 c4 10             	add    $0x10,%esp
  801038:	85 c0                	test   %eax,%eax
  80103a:	78 1a                	js     801056 <fd_close+0x6a>
		if (dev->dev_close)
  80103c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80103f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801042:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801047:	85 c0                	test   %eax,%eax
  801049:	74 0b                	je     801056 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80104b:	83 ec 0c             	sub    $0xc,%esp
  80104e:	56                   	push   %esi
  80104f:	ff d0                	call   *%eax
  801051:	89 c3                	mov    %eax,%ebx
  801053:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801056:	83 ec 08             	sub    $0x8,%esp
  801059:	56                   	push   %esi
  80105a:	6a 00                	push   $0x0
  80105c:	e8 ac fb ff ff       	call   800c0d <sys_page_unmap>
	return r;
  801061:	83 c4 10             	add    $0x10,%esp
  801064:	89 d8                	mov    %ebx,%eax
}
  801066:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801069:	5b                   	pop    %ebx
  80106a:	5e                   	pop    %esi
  80106b:	5d                   	pop    %ebp
  80106c:	c3                   	ret    

0080106d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
  801070:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801073:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801076:	50                   	push   %eax
  801077:	ff 75 08             	pushl  0x8(%ebp)
  80107a:	e8 c4 fe ff ff       	call   800f43 <fd_lookup>
  80107f:	83 c4 08             	add    $0x8,%esp
  801082:	85 c0                	test   %eax,%eax
  801084:	78 10                	js     801096 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801086:	83 ec 08             	sub    $0x8,%esp
  801089:	6a 01                	push   $0x1
  80108b:	ff 75 f4             	pushl  -0xc(%ebp)
  80108e:	e8 59 ff ff ff       	call   800fec <fd_close>
  801093:	83 c4 10             	add    $0x10,%esp
}
  801096:	c9                   	leave  
  801097:	c3                   	ret    

00801098 <close_all>:

void
close_all(void)
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	53                   	push   %ebx
  80109c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80109f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010a4:	83 ec 0c             	sub    $0xc,%esp
  8010a7:	53                   	push   %ebx
  8010a8:	e8 c0 ff ff ff       	call   80106d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010ad:	83 c3 01             	add    $0x1,%ebx
  8010b0:	83 c4 10             	add    $0x10,%esp
  8010b3:	83 fb 20             	cmp    $0x20,%ebx
  8010b6:	75 ec                	jne    8010a4 <close_all+0xc>
		close(i);
}
  8010b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010bb:	c9                   	leave  
  8010bc:	c3                   	ret    

008010bd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010bd:	55                   	push   %ebp
  8010be:	89 e5                	mov    %esp,%ebp
  8010c0:	57                   	push   %edi
  8010c1:	56                   	push   %esi
  8010c2:	53                   	push   %ebx
  8010c3:	83 ec 2c             	sub    $0x2c,%esp
  8010c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010c9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010cc:	50                   	push   %eax
  8010cd:	ff 75 08             	pushl  0x8(%ebp)
  8010d0:	e8 6e fe ff ff       	call   800f43 <fd_lookup>
  8010d5:	83 c4 08             	add    $0x8,%esp
  8010d8:	85 c0                	test   %eax,%eax
  8010da:	0f 88 c1 00 00 00    	js     8011a1 <dup+0xe4>
		return r;
	close(newfdnum);
  8010e0:	83 ec 0c             	sub    $0xc,%esp
  8010e3:	56                   	push   %esi
  8010e4:	e8 84 ff ff ff       	call   80106d <close>

	newfd = INDEX2FD(newfdnum);
  8010e9:	89 f3                	mov    %esi,%ebx
  8010eb:	c1 e3 0c             	shl    $0xc,%ebx
  8010ee:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010f4:	83 c4 04             	add    $0x4,%esp
  8010f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010fa:	e8 de fd ff ff       	call   800edd <fd2data>
  8010ff:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801101:	89 1c 24             	mov    %ebx,(%esp)
  801104:	e8 d4 fd ff ff       	call   800edd <fd2data>
  801109:	83 c4 10             	add    $0x10,%esp
  80110c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80110f:	89 f8                	mov    %edi,%eax
  801111:	c1 e8 16             	shr    $0x16,%eax
  801114:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80111b:	a8 01                	test   $0x1,%al
  80111d:	74 37                	je     801156 <dup+0x99>
  80111f:	89 f8                	mov    %edi,%eax
  801121:	c1 e8 0c             	shr    $0xc,%eax
  801124:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80112b:	f6 c2 01             	test   $0x1,%dl
  80112e:	74 26                	je     801156 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801130:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801137:	83 ec 0c             	sub    $0xc,%esp
  80113a:	25 07 0e 00 00       	and    $0xe07,%eax
  80113f:	50                   	push   %eax
  801140:	ff 75 d4             	pushl  -0x2c(%ebp)
  801143:	6a 00                	push   $0x0
  801145:	57                   	push   %edi
  801146:	6a 00                	push   $0x0
  801148:	e8 7e fa ff ff       	call   800bcb <sys_page_map>
  80114d:	89 c7                	mov    %eax,%edi
  80114f:	83 c4 20             	add    $0x20,%esp
  801152:	85 c0                	test   %eax,%eax
  801154:	78 2e                	js     801184 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801156:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801159:	89 d0                	mov    %edx,%eax
  80115b:	c1 e8 0c             	shr    $0xc,%eax
  80115e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801165:	83 ec 0c             	sub    $0xc,%esp
  801168:	25 07 0e 00 00       	and    $0xe07,%eax
  80116d:	50                   	push   %eax
  80116e:	53                   	push   %ebx
  80116f:	6a 00                	push   $0x0
  801171:	52                   	push   %edx
  801172:	6a 00                	push   $0x0
  801174:	e8 52 fa ff ff       	call   800bcb <sys_page_map>
  801179:	89 c7                	mov    %eax,%edi
  80117b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80117e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801180:	85 ff                	test   %edi,%edi
  801182:	79 1d                	jns    8011a1 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801184:	83 ec 08             	sub    $0x8,%esp
  801187:	53                   	push   %ebx
  801188:	6a 00                	push   $0x0
  80118a:	e8 7e fa ff ff       	call   800c0d <sys_page_unmap>
	sys_page_unmap(0, nva);
  80118f:	83 c4 08             	add    $0x8,%esp
  801192:	ff 75 d4             	pushl  -0x2c(%ebp)
  801195:	6a 00                	push   $0x0
  801197:	e8 71 fa ff ff       	call   800c0d <sys_page_unmap>
	return r;
  80119c:	83 c4 10             	add    $0x10,%esp
  80119f:	89 f8                	mov    %edi,%eax
}
  8011a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a4:	5b                   	pop    %ebx
  8011a5:	5e                   	pop    %esi
  8011a6:	5f                   	pop    %edi
  8011a7:	5d                   	pop    %ebp
  8011a8:	c3                   	ret    

008011a9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011a9:	55                   	push   %ebp
  8011aa:	89 e5                	mov    %esp,%ebp
  8011ac:	53                   	push   %ebx
  8011ad:	83 ec 14             	sub    $0x14,%esp
  8011b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b6:	50                   	push   %eax
  8011b7:	53                   	push   %ebx
  8011b8:	e8 86 fd ff ff       	call   800f43 <fd_lookup>
  8011bd:	83 c4 08             	add    $0x8,%esp
  8011c0:	89 c2                	mov    %eax,%edx
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	78 6d                	js     801233 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c6:	83 ec 08             	sub    $0x8,%esp
  8011c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011cc:	50                   	push   %eax
  8011cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d0:	ff 30                	pushl  (%eax)
  8011d2:	e8 c2 fd ff ff       	call   800f99 <dev_lookup>
  8011d7:	83 c4 10             	add    $0x10,%esp
  8011da:	85 c0                	test   %eax,%eax
  8011dc:	78 4c                	js     80122a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011de:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011e1:	8b 42 08             	mov    0x8(%edx),%eax
  8011e4:	83 e0 03             	and    $0x3,%eax
  8011e7:	83 f8 01             	cmp    $0x1,%eax
  8011ea:	75 21                	jne    80120d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011ec:	a1 04 40 80 00       	mov    0x804004,%eax
  8011f1:	8b 40 48             	mov    0x48(%eax),%eax
  8011f4:	83 ec 04             	sub    $0x4,%esp
  8011f7:	53                   	push   %ebx
  8011f8:	50                   	push   %eax
  8011f9:	68 6d 24 80 00       	push   $0x80246d
  8011fe:	e8 fd ef ff ff       	call   800200 <cprintf>
		return -E_INVAL;
  801203:	83 c4 10             	add    $0x10,%esp
  801206:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80120b:	eb 26                	jmp    801233 <read+0x8a>
	}
	if (!dev->dev_read)
  80120d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801210:	8b 40 08             	mov    0x8(%eax),%eax
  801213:	85 c0                	test   %eax,%eax
  801215:	74 17                	je     80122e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801217:	83 ec 04             	sub    $0x4,%esp
  80121a:	ff 75 10             	pushl  0x10(%ebp)
  80121d:	ff 75 0c             	pushl  0xc(%ebp)
  801220:	52                   	push   %edx
  801221:	ff d0                	call   *%eax
  801223:	89 c2                	mov    %eax,%edx
  801225:	83 c4 10             	add    $0x10,%esp
  801228:	eb 09                	jmp    801233 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122a:	89 c2                	mov    %eax,%edx
  80122c:	eb 05                	jmp    801233 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80122e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801233:	89 d0                	mov    %edx,%eax
  801235:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801238:	c9                   	leave  
  801239:	c3                   	ret    

0080123a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80123a:	55                   	push   %ebp
  80123b:	89 e5                	mov    %esp,%ebp
  80123d:	57                   	push   %edi
  80123e:	56                   	push   %esi
  80123f:	53                   	push   %ebx
  801240:	83 ec 0c             	sub    $0xc,%esp
  801243:	8b 7d 08             	mov    0x8(%ebp),%edi
  801246:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801249:	bb 00 00 00 00       	mov    $0x0,%ebx
  80124e:	eb 21                	jmp    801271 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801250:	83 ec 04             	sub    $0x4,%esp
  801253:	89 f0                	mov    %esi,%eax
  801255:	29 d8                	sub    %ebx,%eax
  801257:	50                   	push   %eax
  801258:	89 d8                	mov    %ebx,%eax
  80125a:	03 45 0c             	add    0xc(%ebp),%eax
  80125d:	50                   	push   %eax
  80125e:	57                   	push   %edi
  80125f:	e8 45 ff ff ff       	call   8011a9 <read>
		if (m < 0)
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	85 c0                	test   %eax,%eax
  801269:	78 10                	js     80127b <readn+0x41>
			return m;
		if (m == 0)
  80126b:	85 c0                	test   %eax,%eax
  80126d:	74 0a                	je     801279 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80126f:	01 c3                	add    %eax,%ebx
  801271:	39 f3                	cmp    %esi,%ebx
  801273:	72 db                	jb     801250 <readn+0x16>
  801275:	89 d8                	mov    %ebx,%eax
  801277:	eb 02                	jmp    80127b <readn+0x41>
  801279:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80127b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80127e:	5b                   	pop    %ebx
  80127f:	5e                   	pop    %esi
  801280:	5f                   	pop    %edi
  801281:	5d                   	pop    %ebp
  801282:	c3                   	ret    

00801283 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801283:	55                   	push   %ebp
  801284:	89 e5                	mov    %esp,%ebp
  801286:	53                   	push   %ebx
  801287:	83 ec 14             	sub    $0x14,%esp
  80128a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80128d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801290:	50                   	push   %eax
  801291:	53                   	push   %ebx
  801292:	e8 ac fc ff ff       	call   800f43 <fd_lookup>
  801297:	83 c4 08             	add    $0x8,%esp
  80129a:	89 c2                	mov    %eax,%edx
  80129c:	85 c0                	test   %eax,%eax
  80129e:	78 68                	js     801308 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012a0:	83 ec 08             	sub    $0x8,%esp
  8012a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a6:	50                   	push   %eax
  8012a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012aa:	ff 30                	pushl  (%eax)
  8012ac:	e8 e8 fc ff ff       	call   800f99 <dev_lookup>
  8012b1:	83 c4 10             	add    $0x10,%esp
  8012b4:	85 c0                	test   %eax,%eax
  8012b6:	78 47                	js     8012ff <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012bb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012bf:	75 21                	jne    8012e2 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012c1:	a1 04 40 80 00       	mov    0x804004,%eax
  8012c6:	8b 40 48             	mov    0x48(%eax),%eax
  8012c9:	83 ec 04             	sub    $0x4,%esp
  8012cc:	53                   	push   %ebx
  8012cd:	50                   	push   %eax
  8012ce:	68 89 24 80 00       	push   $0x802489
  8012d3:	e8 28 ef ff ff       	call   800200 <cprintf>
		return -E_INVAL;
  8012d8:	83 c4 10             	add    $0x10,%esp
  8012db:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012e0:	eb 26                	jmp    801308 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012e5:	8b 52 0c             	mov    0xc(%edx),%edx
  8012e8:	85 d2                	test   %edx,%edx
  8012ea:	74 17                	je     801303 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012ec:	83 ec 04             	sub    $0x4,%esp
  8012ef:	ff 75 10             	pushl  0x10(%ebp)
  8012f2:	ff 75 0c             	pushl  0xc(%ebp)
  8012f5:	50                   	push   %eax
  8012f6:	ff d2                	call   *%edx
  8012f8:	89 c2                	mov    %eax,%edx
  8012fa:	83 c4 10             	add    $0x10,%esp
  8012fd:	eb 09                	jmp    801308 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ff:	89 c2                	mov    %eax,%edx
  801301:	eb 05                	jmp    801308 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801303:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801308:	89 d0                	mov    %edx,%eax
  80130a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80130d:	c9                   	leave  
  80130e:	c3                   	ret    

0080130f <seek>:

int
seek(int fdnum, off_t offset)
{
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
  801312:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801315:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801318:	50                   	push   %eax
  801319:	ff 75 08             	pushl  0x8(%ebp)
  80131c:	e8 22 fc ff ff       	call   800f43 <fd_lookup>
  801321:	83 c4 08             	add    $0x8,%esp
  801324:	85 c0                	test   %eax,%eax
  801326:	78 0e                	js     801336 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801328:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80132b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80132e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801331:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801336:	c9                   	leave  
  801337:	c3                   	ret    

00801338 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	53                   	push   %ebx
  80133c:	83 ec 14             	sub    $0x14,%esp
  80133f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801342:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801345:	50                   	push   %eax
  801346:	53                   	push   %ebx
  801347:	e8 f7 fb ff ff       	call   800f43 <fd_lookup>
  80134c:	83 c4 08             	add    $0x8,%esp
  80134f:	89 c2                	mov    %eax,%edx
  801351:	85 c0                	test   %eax,%eax
  801353:	78 65                	js     8013ba <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801355:	83 ec 08             	sub    $0x8,%esp
  801358:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135b:	50                   	push   %eax
  80135c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135f:	ff 30                	pushl  (%eax)
  801361:	e8 33 fc ff ff       	call   800f99 <dev_lookup>
  801366:	83 c4 10             	add    $0x10,%esp
  801369:	85 c0                	test   %eax,%eax
  80136b:	78 44                	js     8013b1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80136d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801370:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801374:	75 21                	jne    801397 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801376:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80137b:	8b 40 48             	mov    0x48(%eax),%eax
  80137e:	83 ec 04             	sub    $0x4,%esp
  801381:	53                   	push   %ebx
  801382:	50                   	push   %eax
  801383:	68 4c 24 80 00       	push   $0x80244c
  801388:	e8 73 ee ff ff       	call   800200 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80138d:	83 c4 10             	add    $0x10,%esp
  801390:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801395:	eb 23                	jmp    8013ba <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801397:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80139a:	8b 52 18             	mov    0x18(%edx),%edx
  80139d:	85 d2                	test   %edx,%edx
  80139f:	74 14                	je     8013b5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013a1:	83 ec 08             	sub    $0x8,%esp
  8013a4:	ff 75 0c             	pushl  0xc(%ebp)
  8013a7:	50                   	push   %eax
  8013a8:	ff d2                	call   *%edx
  8013aa:	89 c2                	mov    %eax,%edx
  8013ac:	83 c4 10             	add    $0x10,%esp
  8013af:	eb 09                	jmp    8013ba <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b1:	89 c2                	mov    %eax,%edx
  8013b3:	eb 05                	jmp    8013ba <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8013ba:	89 d0                	mov    %edx,%eax
  8013bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013bf:	c9                   	leave  
  8013c0:	c3                   	ret    

008013c1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013c1:	55                   	push   %ebp
  8013c2:	89 e5                	mov    %esp,%ebp
  8013c4:	53                   	push   %ebx
  8013c5:	83 ec 14             	sub    $0x14,%esp
  8013c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ce:	50                   	push   %eax
  8013cf:	ff 75 08             	pushl  0x8(%ebp)
  8013d2:	e8 6c fb ff ff       	call   800f43 <fd_lookup>
  8013d7:	83 c4 08             	add    $0x8,%esp
  8013da:	89 c2                	mov    %eax,%edx
  8013dc:	85 c0                	test   %eax,%eax
  8013de:	78 58                	js     801438 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e0:	83 ec 08             	sub    $0x8,%esp
  8013e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e6:	50                   	push   %eax
  8013e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ea:	ff 30                	pushl  (%eax)
  8013ec:	e8 a8 fb ff ff       	call   800f99 <dev_lookup>
  8013f1:	83 c4 10             	add    $0x10,%esp
  8013f4:	85 c0                	test   %eax,%eax
  8013f6:	78 37                	js     80142f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013fb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013ff:	74 32                	je     801433 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801401:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801404:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80140b:	00 00 00 
	stat->st_isdir = 0;
  80140e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801415:	00 00 00 
	stat->st_dev = dev;
  801418:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80141e:	83 ec 08             	sub    $0x8,%esp
  801421:	53                   	push   %ebx
  801422:	ff 75 f0             	pushl  -0x10(%ebp)
  801425:	ff 50 14             	call   *0x14(%eax)
  801428:	89 c2                	mov    %eax,%edx
  80142a:	83 c4 10             	add    $0x10,%esp
  80142d:	eb 09                	jmp    801438 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142f:	89 c2                	mov    %eax,%edx
  801431:	eb 05                	jmp    801438 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801433:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801438:	89 d0                	mov    %edx,%eax
  80143a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80143d:	c9                   	leave  
  80143e:	c3                   	ret    

0080143f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	56                   	push   %esi
  801443:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801444:	83 ec 08             	sub    $0x8,%esp
  801447:	6a 00                	push   $0x0
  801449:	ff 75 08             	pushl  0x8(%ebp)
  80144c:	e8 d6 01 00 00       	call   801627 <open>
  801451:	89 c3                	mov    %eax,%ebx
  801453:	83 c4 10             	add    $0x10,%esp
  801456:	85 c0                	test   %eax,%eax
  801458:	78 1b                	js     801475 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80145a:	83 ec 08             	sub    $0x8,%esp
  80145d:	ff 75 0c             	pushl  0xc(%ebp)
  801460:	50                   	push   %eax
  801461:	e8 5b ff ff ff       	call   8013c1 <fstat>
  801466:	89 c6                	mov    %eax,%esi
	close(fd);
  801468:	89 1c 24             	mov    %ebx,(%esp)
  80146b:	e8 fd fb ff ff       	call   80106d <close>
	return r;
  801470:	83 c4 10             	add    $0x10,%esp
  801473:	89 f0                	mov    %esi,%eax
}
  801475:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801478:	5b                   	pop    %ebx
  801479:	5e                   	pop    %esi
  80147a:	5d                   	pop    %ebp
  80147b:	c3                   	ret    

0080147c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	56                   	push   %esi
  801480:	53                   	push   %ebx
  801481:	89 c6                	mov    %eax,%esi
  801483:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801485:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80148c:	75 12                	jne    8014a0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80148e:	83 ec 0c             	sub    $0xc,%esp
  801491:	6a 01                	push   $0x1
  801493:	e8 23 09 00 00       	call   801dbb <ipc_find_env>
  801498:	a3 00 40 80 00       	mov    %eax,0x804000
  80149d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014a0:	6a 07                	push   $0x7
  8014a2:	68 00 50 80 00       	push   $0x805000
  8014a7:	56                   	push   %esi
  8014a8:	ff 35 00 40 80 00    	pushl  0x804000
  8014ae:	e8 b4 08 00 00       	call   801d67 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014b3:	83 c4 0c             	add    $0xc,%esp
  8014b6:	6a 00                	push   $0x0
  8014b8:	53                   	push   %ebx
  8014b9:	6a 00                	push   $0x0
  8014bb:	e8 40 08 00 00       	call   801d00 <ipc_recv>
}
  8014c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014c3:	5b                   	pop    %ebx
  8014c4:	5e                   	pop    %esi
  8014c5:	5d                   	pop    %ebp
  8014c6:	c3                   	ret    

008014c7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014c7:	55                   	push   %ebp
  8014c8:	89 e5                	mov    %esp,%ebp
  8014ca:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d0:	8b 40 0c             	mov    0xc(%eax),%eax
  8014d3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014db:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e5:	b8 02 00 00 00       	mov    $0x2,%eax
  8014ea:	e8 8d ff ff ff       	call   80147c <fsipc>
}
  8014ef:	c9                   	leave  
  8014f0:	c3                   	ret    

008014f1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014f1:	55                   	push   %ebp
  8014f2:	89 e5                	mov    %esp,%ebp
  8014f4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8014fd:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801502:	ba 00 00 00 00       	mov    $0x0,%edx
  801507:	b8 06 00 00 00       	mov    $0x6,%eax
  80150c:	e8 6b ff ff ff       	call   80147c <fsipc>
}
  801511:	c9                   	leave  
  801512:	c3                   	ret    

00801513 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801513:	55                   	push   %ebp
  801514:	89 e5                	mov    %esp,%ebp
  801516:	53                   	push   %ebx
  801517:	83 ec 04             	sub    $0x4,%esp
  80151a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80151d:	8b 45 08             	mov    0x8(%ebp),%eax
  801520:	8b 40 0c             	mov    0xc(%eax),%eax
  801523:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801528:	ba 00 00 00 00       	mov    $0x0,%edx
  80152d:	b8 05 00 00 00       	mov    $0x5,%eax
  801532:	e8 45 ff ff ff       	call   80147c <fsipc>
  801537:	85 c0                	test   %eax,%eax
  801539:	78 2c                	js     801567 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80153b:	83 ec 08             	sub    $0x8,%esp
  80153e:	68 00 50 80 00       	push   $0x805000
  801543:	53                   	push   %ebx
  801544:	e8 3c f2 ff ff       	call   800785 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801549:	a1 80 50 80 00       	mov    0x805080,%eax
  80154e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801554:	a1 84 50 80 00       	mov    0x805084,%eax
  801559:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80155f:	83 c4 10             	add    $0x10,%esp
  801562:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801567:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156a:	c9                   	leave  
  80156b:	c3                   	ret    

0080156c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	83 ec 0c             	sub    $0xc,%esp
  801572:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801575:	8b 55 08             	mov    0x8(%ebp),%edx
  801578:	8b 52 0c             	mov    0xc(%edx),%edx
  80157b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801581:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801586:	50                   	push   %eax
  801587:	ff 75 0c             	pushl  0xc(%ebp)
  80158a:	68 08 50 80 00       	push   $0x805008
  80158f:	e8 83 f3 ff ff       	call   800917 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801594:	ba 00 00 00 00       	mov    $0x0,%edx
  801599:	b8 04 00 00 00       	mov    $0x4,%eax
  80159e:	e8 d9 fe ff ff       	call   80147c <fsipc>

}
  8015a3:	c9                   	leave  
  8015a4:	c3                   	ret    

008015a5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015a5:	55                   	push   %ebp
  8015a6:	89 e5                	mov    %esp,%ebp
  8015a8:	56                   	push   %esi
  8015a9:	53                   	push   %ebx
  8015aa:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8015b3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015b8:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015be:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c3:	b8 03 00 00 00       	mov    $0x3,%eax
  8015c8:	e8 af fe ff ff       	call   80147c <fsipc>
  8015cd:	89 c3                	mov    %eax,%ebx
  8015cf:	85 c0                	test   %eax,%eax
  8015d1:	78 4b                	js     80161e <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015d3:	39 c6                	cmp    %eax,%esi
  8015d5:	73 16                	jae    8015ed <devfile_read+0x48>
  8015d7:	68 b8 24 80 00       	push   $0x8024b8
  8015dc:	68 bf 24 80 00       	push   $0x8024bf
  8015e1:	6a 7c                	push   $0x7c
  8015e3:	68 d4 24 80 00       	push   $0x8024d4
  8015e8:	e8 cd 06 00 00       	call   801cba <_panic>
	assert(r <= PGSIZE);
  8015ed:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015f2:	7e 16                	jle    80160a <devfile_read+0x65>
  8015f4:	68 df 24 80 00       	push   $0x8024df
  8015f9:	68 bf 24 80 00       	push   $0x8024bf
  8015fe:	6a 7d                	push   $0x7d
  801600:	68 d4 24 80 00       	push   $0x8024d4
  801605:	e8 b0 06 00 00       	call   801cba <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80160a:	83 ec 04             	sub    $0x4,%esp
  80160d:	50                   	push   %eax
  80160e:	68 00 50 80 00       	push   $0x805000
  801613:	ff 75 0c             	pushl  0xc(%ebp)
  801616:	e8 fc f2 ff ff       	call   800917 <memmove>
	return r;
  80161b:	83 c4 10             	add    $0x10,%esp
}
  80161e:	89 d8                	mov    %ebx,%eax
  801620:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801623:	5b                   	pop    %ebx
  801624:	5e                   	pop    %esi
  801625:	5d                   	pop    %ebp
  801626:	c3                   	ret    

00801627 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801627:	55                   	push   %ebp
  801628:	89 e5                	mov    %esp,%ebp
  80162a:	53                   	push   %ebx
  80162b:	83 ec 20             	sub    $0x20,%esp
  80162e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801631:	53                   	push   %ebx
  801632:	e8 15 f1 ff ff       	call   80074c <strlen>
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80163f:	7f 67                	jg     8016a8 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801641:	83 ec 0c             	sub    $0xc,%esp
  801644:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801647:	50                   	push   %eax
  801648:	e8 a7 f8 ff ff       	call   800ef4 <fd_alloc>
  80164d:	83 c4 10             	add    $0x10,%esp
		return r;
  801650:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801652:	85 c0                	test   %eax,%eax
  801654:	78 57                	js     8016ad <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801656:	83 ec 08             	sub    $0x8,%esp
  801659:	53                   	push   %ebx
  80165a:	68 00 50 80 00       	push   $0x805000
  80165f:	e8 21 f1 ff ff       	call   800785 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801664:	8b 45 0c             	mov    0xc(%ebp),%eax
  801667:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80166c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80166f:	b8 01 00 00 00       	mov    $0x1,%eax
  801674:	e8 03 fe ff ff       	call   80147c <fsipc>
  801679:	89 c3                	mov    %eax,%ebx
  80167b:	83 c4 10             	add    $0x10,%esp
  80167e:	85 c0                	test   %eax,%eax
  801680:	79 14                	jns    801696 <open+0x6f>
		fd_close(fd, 0);
  801682:	83 ec 08             	sub    $0x8,%esp
  801685:	6a 00                	push   $0x0
  801687:	ff 75 f4             	pushl  -0xc(%ebp)
  80168a:	e8 5d f9 ff ff       	call   800fec <fd_close>
		return r;
  80168f:	83 c4 10             	add    $0x10,%esp
  801692:	89 da                	mov    %ebx,%edx
  801694:	eb 17                	jmp    8016ad <open+0x86>
	}

	return fd2num(fd);
  801696:	83 ec 0c             	sub    $0xc,%esp
  801699:	ff 75 f4             	pushl  -0xc(%ebp)
  80169c:	e8 2c f8 ff ff       	call   800ecd <fd2num>
  8016a1:	89 c2                	mov    %eax,%edx
  8016a3:	83 c4 10             	add    $0x10,%esp
  8016a6:	eb 05                	jmp    8016ad <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016a8:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016ad:	89 d0                	mov    %edx,%eax
  8016af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b2:	c9                   	leave  
  8016b3:	c3                   	ret    

008016b4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8016bf:	b8 08 00 00 00       	mov    $0x8,%eax
  8016c4:	e8 b3 fd ff ff       	call   80147c <fsipc>
}
  8016c9:	c9                   	leave  
  8016ca:	c3                   	ret    

008016cb <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8016cb:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8016cf:	7e 37                	jle    801708 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	53                   	push   %ebx
  8016d5:	83 ec 08             	sub    $0x8,%esp
  8016d8:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8016da:	ff 70 04             	pushl  0x4(%eax)
  8016dd:	8d 40 10             	lea    0x10(%eax),%eax
  8016e0:	50                   	push   %eax
  8016e1:	ff 33                	pushl  (%ebx)
  8016e3:	e8 9b fb ff ff       	call   801283 <write>
		if (result > 0)
  8016e8:	83 c4 10             	add    $0x10,%esp
  8016eb:	85 c0                	test   %eax,%eax
  8016ed:	7e 03                	jle    8016f2 <writebuf+0x27>
			b->result += result;
  8016ef:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8016f2:	3b 43 04             	cmp    0x4(%ebx),%eax
  8016f5:	74 0d                	je     801704 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8016f7:	85 c0                	test   %eax,%eax
  8016f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fe:	0f 4f c2             	cmovg  %edx,%eax
  801701:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801704:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801707:	c9                   	leave  
  801708:	f3 c3                	repz ret 

0080170a <putch>:

static void
putch(int ch, void *thunk)
{
  80170a:	55                   	push   %ebp
  80170b:	89 e5                	mov    %esp,%ebp
  80170d:	53                   	push   %ebx
  80170e:	83 ec 04             	sub    $0x4,%esp
  801711:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801714:	8b 53 04             	mov    0x4(%ebx),%edx
  801717:	8d 42 01             	lea    0x1(%edx),%eax
  80171a:	89 43 04             	mov    %eax,0x4(%ebx)
  80171d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801720:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801724:	3d 00 01 00 00       	cmp    $0x100,%eax
  801729:	75 0e                	jne    801739 <putch+0x2f>
		writebuf(b);
  80172b:	89 d8                	mov    %ebx,%eax
  80172d:	e8 99 ff ff ff       	call   8016cb <writebuf>
		b->idx = 0;
  801732:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801739:	83 c4 04             	add    $0x4,%esp
  80173c:	5b                   	pop    %ebx
  80173d:	5d                   	pop    %ebp
  80173e:	c3                   	ret    

0080173f <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80173f:	55                   	push   %ebp
  801740:	89 e5                	mov    %esp,%ebp
  801742:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801748:	8b 45 08             	mov    0x8(%ebp),%eax
  80174b:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801751:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801758:	00 00 00 
	b.result = 0;
  80175b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801762:	00 00 00 
	b.error = 1;
  801765:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80176c:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80176f:	ff 75 10             	pushl  0x10(%ebp)
  801772:	ff 75 0c             	pushl  0xc(%ebp)
  801775:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80177b:	50                   	push   %eax
  80177c:	68 0a 17 80 00       	push   $0x80170a
  801781:	e8 b1 eb ff ff       	call   800337 <vprintfmt>
	if (b.idx > 0)
  801786:	83 c4 10             	add    $0x10,%esp
  801789:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801790:	7e 0b                	jle    80179d <vfprintf+0x5e>
		writebuf(&b);
  801792:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801798:	e8 2e ff ff ff       	call   8016cb <writebuf>

	return (b.result ? b.result : b.error);
  80179d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8017a3:	85 c0                	test   %eax,%eax
  8017a5:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8017ac:	c9                   	leave  
  8017ad:	c3                   	ret    

008017ae <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8017ae:	55                   	push   %ebp
  8017af:	89 e5                	mov    %esp,%ebp
  8017b1:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017b4:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8017b7:	50                   	push   %eax
  8017b8:	ff 75 0c             	pushl  0xc(%ebp)
  8017bb:	ff 75 08             	pushl  0x8(%ebp)
  8017be:	e8 7c ff ff ff       	call   80173f <vfprintf>
	va_end(ap);

	return cnt;
}
  8017c3:	c9                   	leave  
  8017c4:	c3                   	ret    

008017c5 <printf>:

int
printf(const char *fmt, ...)
{
  8017c5:	55                   	push   %ebp
  8017c6:	89 e5                	mov    %esp,%ebp
  8017c8:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017cb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8017ce:	50                   	push   %eax
  8017cf:	ff 75 08             	pushl  0x8(%ebp)
  8017d2:	6a 01                	push   $0x1
  8017d4:	e8 66 ff ff ff       	call   80173f <vfprintf>
	va_end(ap);

	return cnt;
}
  8017d9:	c9                   	leave  
  8017da:	c3                   	ret    

008017db <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8017db:	55                   	push   %ebp
  8017dc:	89 e5                	mov    %esp,%ebp
  8017de:	56                   	push   %esi
  8017df:	53                   	push   %ebx
  8017e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8017e3:	83 ec 0c             	sub    $0xc,%esp
  8017e6:	ff 75 08             	pushl  0x8(%ebp)
  8017e9:	e8 ef f6 ff ff       	call   800edd <fd2data>
  8017ee:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8017f0:	83 c4 08             	add    $0x8,%esp
  8017f3:	68 eb 24 80 00       	push   $0x8024eb
  8017f8:	53                   	push   %ebx
  8017f9:	e8 87 ef ff ff       	call   800785 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8017fe:	8b 46 04             	mov    0x4(%esi),%eax
  801801:	2b 06                	sub    (%esi),%eax
  801803:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801809:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801810:	00 00 00 
	stat->st_dev = &devpipe;
  801813:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80181a:	30 80 00 
	return 0;
}
  80181d:	b8 00 00 00 00       	mov    $0x0,%eax
  801822:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801825:	5b                   	pop    %ebx
  801826:	5e                   	pop    %esi
  801827:	5d                   	pop    %ebp
  801828:	c3                   	ret    

00801829 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801829:	55                   	push   %ebp
  80182a:	89 e5                	mov    %esp,%ebp
  80182c:	53                   	push   %ebx
  80182d:	83 ec 0c             	sub    $0xc,%esp
  801830:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801833:	53                   	push   %ebx
  801834:	6a 00                	push   $0x0
  801836:	e8 d2 f3 ff ff       	call   800c0d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80183b:	89 1c 24             	mov    %ebx,(%esp)
  80183e:	e8 9a f6 ff ff       	call   800edd <fd2data>
  801843:	83 c4 08             	add    $0x8,%esp
  801846:	50                   	push   %eax
  801847:	6a 00                	push   $0x0
  801849:	e8 bf f3 ff ff       	call   800c0d <sys_page_unmap>
}
  80184e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801851:	c9                   	leave  
  801852:	c3                   	ret    

00801853 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801853:	55                   	push   %ebp
  801854:	89 e5                	mov    %esp,%ebp
  801856:	57                   	push   %edi
  801857:	56                   	push   %esi
  801858:	53                   	push   %ebx
  801859:	83 ec 1c             	sub    $0x1c,%esp
  80185c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80185f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801861:	a1 04 40 80 00       	mov    0x804004,%eax
  801866:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801869:	83 ec 0c             	sub    $0xc,%esp
  80186c:	ff 75 e0             	pushl  -0x20(%ebp)
  80186f:	e8 80 05 00 00       	call   801df4 <pageref>
  801874:	89 c3                	mov    %eax,%ebx
  801876:	89 3c 24             	mov    %edi,(%esp)
  801879:	e8 76 05 00 00       	call   801df4 <pageref>
  80187e:	83 c4 10             	add    $0x10,%esp
  801881:	39 c3                	cmp    %eax,%ebx
  801883:	0f 94 c1             	sete   %cl
  801886:	0f b6 c9             	movzbl %cl,%ecx
  801889:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80188c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801892:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801895:	39 ce                	cmp    %ecx,%esi
  801897:	74 1b                	je     8018b4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801899:	39 c3                	cmp    %eax,%ebx
  80189b:	75 c4                	jne    801861 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80189d:	8b 42 58             	mov    0x58(%edx),%eax
  8018a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018a3:	50                   	push   %eax
  8018a4:	56                   	push   %esi
  8018a5:	68 f2 24 80 00       	push   $0x8024f2
  8018aa:	e8 51 e9 ff ff       	call   800200 <cprintf>
  8018af:	83 c4 10             	add    $0x10,%esp
  8018b2:	eb ad                	jmp    801861 <_pipeisclosed+0xe>
	}
}
  8018b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018ba:	5b                   	pop    %ebx
  8018bb:	5e                   	pop    %esi
  8018bc:	5f                   	pop    %edi
  8018bd:	5d                   	pop    %ebp
  8018be:	c3                   	ret    

008018bf <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	57                   	push   %edi
  8018c3:	56                   	push   %esi
  8018c4:	53                   	push   %ebx
  8018c5:	83 ec 28             	sub    $0x28,%esp
  8018c8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8018cb:	56                   	push   %esi
  8018cc:	e8 0c f6 ff ff       	call   800edd <fd2data>
  8018d1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018d3:	83 c4 10             	add    $0x10,%esp
  8018d6:	bf 00 00 00 00       	mov    $0x0,%edi
  8018db:	eb 4b                	jmp    801928 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8018dd:	89 da                	mov    %ebx,%edx
  8018df:	89 f0                	mov    %esi,%eax
  8018e1:	e8 6d ff ff ff       	call   801853 <_pipeisclosed>
  8018e6:	85 c0                	test   %eax,%eax
  8018e8:	75 48                	jne    801932 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8018ea:	e8 7a f2 ff ff       	call   800b69 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8018ef:	8b 43 04             	mov    0x4(%ebx),%eax
  8018f2:	8b 0b                	mov    (%ebx),%ecx
  8018f4:	8d 51 20             	lea    0x20(%ecx),%edx
  8018f7:	39 d0                	cmp    %edx,%eax
  8018f9:	73 e2                	jae    8018dd <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8018fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018fe:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801902:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801905:	89 c2                	mov    %eax,%edx
  801907:	c1 fa 1f             	sar    $0x1f,%edx
  80190a:	89 d1                	mov    %edx,%ecx
  80190c:	c1 e9 1b             	shr    $0x1b,%ecx
  80190f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801912:	83 e2 1f             	and    $0x1f,%edx
  801915:	29 ca                	sub    %ecx,%edx
  801917:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80191b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80191f:	83 c0 01             	add    $0x1,%eax
  801922:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801925:	83 c7 01             	add    $0x1,%edi
  801928:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80192b:	75 c2                	jne    8018ef <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80192d:	8b 45 10             	mov    0x10(%ebp),%eax
  801930:	eb 05                	jmp    801937 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801932:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801937:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80193a:	5b                   	pop    %ebx
  80193b:	5e                   	pop    %esi
  80193c:	5f                   	pop    %edi
  80193d:	5d                   	pop    %ebp
  80193e:	c3                   	ret    

0080193f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80193f:	55                   	push   %ebp
  801940:	89 e5                	mov    %esp,%ebp
  801942:	57                   	push   %edi
  801943:	56                   	push   %esi
  801944:	53                   	push   %ebx
  801945:	83 ec 18             	sub    $0x18,%esp
  801948:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80194b:	57                   	push   %edi
  80194c:	e8 8c f5 ff ff       	call   800edd <fd2data>
  801951:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801953:	83 c4 10             	add    $0x10,%esp
  801956:	bb 00 00 00 00       	mov    $0x0,%ebx
  80195b:	eb 3d                	jmp    80199a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80195d:	85 db                	test   %ebx,%ebx
  80195f:	74 04                	je     801965 <devpipe_read+0x26>
				return i;
  801961:	89 d8                	mov    %ebx,%eax
  801963:	eb 44                	jmp    8019a9 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801965:	89 f2                	mov    %esi,%edx
  801967:	89 f8                	mov    %edi,%eax
  801969:	e8 e5 fe ff ff       	call   801853 <_pipeisclosed>
  80196e:	85 c0                	test   %eax,%eax
  801970:	75 32                	jne    8019a4 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801972:	e8 f2 f1 ff ff       	call   800b69 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801977:	8b 06                	mov    (%esi),%eax
  801979:	3b 46 04             	cmp    0x4(%esi),%eax
  80197c:	74 df                	je     80195d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80197e:	99                   	cltd   
  80197f:	c1 ea 1b             	shr    $0x1b,%edx
  801982:	01 d0                	add    %edx,%eax
  801984:	83 e0 1f             	and    $0x1f,%eax
  801987:	29 d0                	sub    %edx,%eax
  801989:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80198e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801991:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801994:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801997:	83 c3 01             	add    $0x1,%ebx
  80199a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80199d:	75 d8                	jne    801977 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80199f:	8b 45 10             	mov    0x10(%ebp),%eax
  8019a2:	eb 05                	jmp    8019a9 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019a4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019ac:	5b                   	pop    %ebx
  8019ad:	5e                   	pop    %esi
  8019ae:	5f                   	pop    %edi
  8019af:	5d                   	pop    %ebp
  8019b0:	c3                   	ret    

008019b1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8019b1:	55                   	push   %ebp
  8019b2:	89 e5                	mov    %esp,%ebp
  8019b4:	56                   	push   %esi
  8019b5:	53                   	push   %ebx
  8019b6:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8019b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019bc:	50                   	push   %eax
  8019bd:	e8 32 f5 ff ff       	call   800ef4 <fd_alloc>
  8019c2:	83 c4 10             	add    $0x10,%esp
  8019c5:	89 c2                	mov    %eax,%edx
  8019c7:	85 c0                	test   %eax,%eax
  8019c9:	0f 88 2c 01 00 00    	js     801afb <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019cf:	83 ec 04             	sub    $0x4,%esp
  8019d2:	68 07 04 00 00       	push   $0x407
  8019d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8019da:	6a 00                	push   $0x0
  8019dc:	e8 a7 f1 ff ff       	call   800b88 <sys_page_alloc>
  8019e1:	83 c4 10             	add    $0x10,%esp
  8019e4:	89 c2                	mov    %eax,%edx
  8019e6:	85 c0                	test   %eax,%eax
  8019e8:	0f 88 0d 01 00 00    	js     801afb <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8019ee:	83 ec 0c             	sub    $0xc,%esp
  8019f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019f4:	50                   	push   %eax
  8019f5:	e8 fa f4 ff ff       	call   800ef4 <fd_alloc>
  8019fa:	89 c3                	mov    %eax,%ebx
  8019fc:	83 c4 10             	add    $0x10,%esp
  8019ff:	85 c0                	test   %eax,%eax
  801a01:	0f 88 e2 00 00 00    	js     801ae9 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a07:	83 ec 04             	sub    $0x4,%esp
  801a0a:	68 07 04 00 00       	push   $0x407
  801a0f:	ff 75 f0             	pushl  -0x10(%ebp)
  801a12:	6a 00                	push   $0x0
  801a14:	e8 6f f1 ff ff       	call   800b88 <sys_page_alloc>
  801a19:	89 c3                	mov    %eax,%ebx
  801a1b:	83 c4 10             	add    $0x10,%esp
  801a1e:	85 c0                	test   %eax,%eax
  801a20:	0f 88 c3 00 00 00    	js     801ae9 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a26:	83 ec 0c             	sub    $0xc,%esp
  801a29:	ff 75 f4             	pushl  -0xc(%ebp)
  801a2c:	e8 ac f4 ff ff       	call   800edd <fd2data>
  801a31:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a33:	83 c4 0c             	add    $0xc,%esp
  801a36:	68 07 04 00 00       	push   $0x407
  801a3b:	50                   	push   %eax
  801a3c:	6a 00                	push   $0x0
  801a3e:	e8 45 f1 ff ff       	call   800b88 <sys_page_alloc>
  801a43:	89 c3                	mov    %eax,%ebx
  801a45:	83 c4 10             	add    $0x10,%esp
  801a48:	85 c0                	test   %eax,%eax
  801a4a:	0f 88 89 00 00 00    	js     801ad9 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a50:	83 ec 0c             	sub    $0xc,%esp
  801a53:	ff 75 f0             	pushl  -0x10(%ebp)
  801a56:	e8 82 f4 ff ff       	call   800edd <fd2data>
  801a5b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a62:	50                   	push   %eax
  801a63:	6a 00                	push   $0x0
  801a65:	56                   	push   %esi
  801a66:	6a 00                	push   $0x0
  801a68:	e8 5e f1 ff ff       	call   800bcb <sys_page_map>
  801a6d:	89 c3                	mov    %eax,%ebx
  801a6f:	83 c4 20             	add    $0x20,%esp
  801a72:	85 c0                	test   %eax,%eax
  801a74:	78 55                	js     801acb <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a76:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a7f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a84:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a8b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a91:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a94:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a96:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a99:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801aa0:	83 ec 0c             	sub    $0xc,%esp
  801aa3:	ff 75 f4             	pushl  -0xc(%ebp)
  801aa6:	e8 22 f4 ff ff       	call   800ecd <fd2num>
  801aab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801aae:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ab0:	83 c4 04             	add    $0x4,%esp
  801ab3:	ff 75 f0             	pushl  -0x10(%ebp)
  801ab6:	e8 12 f4 ff ff       	call   800ecd <fd2num>
  801abb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801abe:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ac1:	83 c4 10             	add    $0x10,%esp
  801ac4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac9:	eb 30                	jmp    801afb <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801acb:	83 ec 08             	sub    $0x8,%esp
  801ace:	56                   	push   %esi
  801acf:	6a 00                	push   $0x0
  801ad1:	e8 37 f1 ff ff       	call   800c0d <sys_page_unmap>
  801ad6:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ad9:	83 ec 08             	sub    $0x8,%esp
  801adc:	ff 75 f0             	pushl  -0x10(%ebp)
  801adf:	6a 00                	push   $0x0
  801ae1:	e8 27 f1 ff ff       	call   800c0d <sys_page_unmap>
  801ae6:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ae9:	83 ec 08             	sub    $0x8,%esp
  801aec:	ff 75 f4             	pushl  -0xc(%ebp)
  801aef:	6a 00                	push   $0x0
  801af1:	e8 17 f1 ff ff       	call   800c0d <sys_page_unmap>
  801af6:	83 c4 10             	add    $0x10,%esp
  801af9:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801afb:	89 d0                	mov    %edx,%eax
  801afd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b00:	5b                   	pop    %ebx
  801b01:	5e                   	pop    %esi
  801b02:	5d                   	pop    %ebp
  801b03:	c3                   	ret    

00801b04 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b04:	55                   	push   %ebp
  801b05:	89 e5                	mov    %esp,%ebp
  801b07:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b0d:	50                   	push   %eax
  801b0e:	ff 75 08             	pushl  0x8(%ebp)
  801b11:	e8 2d f4 ff ff       	call   800f43 <fd_lookup>
  801b16:	83 c4 10             	add    $0x10,%esp
  801b19:	85 c0                	test   %eax,%eax
  801b1b:	78 18                	js     801b35 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b1d:	83 ec 0c             	sub    $0xc,%esp
  801b20:	ff 75 f4             	pushl  -0xc(%ebp)
  801b23:	e8 b5 f3 ff ff       	call   800edd <fd2data>
	return _pipeisclosed(fd, p);
  801b28:	89 c2                	mov    %eax,%edx
  801b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b2d:	e8 21 fd ff ff       	call   801853 <_pipeisclosed>
  801b32:	83 c4 10             	add    $0x10,%esp
}
  801b35:	c9                   	leave  
  801b36:	c3                   	ret    

00801b37 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b37:	55                   	push   %ebp
  801b38:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b3a:	b8 00 00 00 00       	mov    $0x0,%eax
  801b3f:	5d                   	pop    %ebp
  801b40:	c3                   	ret    

00801b41 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b41:	55                   	push   %ebp
  801b42:	89 e5                	mov    %esp,%ebp
  801b44:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b47:	68 0a 25 80 00       	push   $0x80250a
  801b4c:	ff 75 0c             	pushl  0xc(%ebp)
  801b4f:	e8 31 ec ff ff       	call   800785 <strcpy>
	return 0;
}
  801b54:	b8 00 00 00 00       	mov    $0x0,%eax
  801b59:	c9                   	leave  
  801b5a:	c3                   	ret    

00801b5b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
  801b5e:	57                   	push   %edi
  801b5f:	56                   	push   %esi
  801b60:	53                   	push   %ebx
  801b61:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b67:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b6c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b72:	eb 2d                	jmp    801ba1 <devcons_write+0x46>
		m = n - tot;
  801b74:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b77:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801b79:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801b7c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801b81:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b84:	83 ec 04             	sub    $0x4,%esp
  801b87:	53                   	push   %ebx
  801b88:	03 45 0c             	add    0xc(%ebp),%eax
  801b8b:	50                   	push   %eax
  801b8c:	57                   	push   %edi
  801b8d:	e8 85 ed ff ff       	call   800917 <memmove>
		sys_cputs(buf, m);
  801b92:	83 c4 08             	add    $0x8,%esp
  801b95:	53                   	push   %ebx
  801b96:	57                   	push   %edi
  801b97:	e8 30 ef ff ff       	call   800acc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b9c:	01 de                	add    %ebx,%esi
  801b9e:	83 c4 10             	add    $0x10,%esp
  801ba1:	89 f0                	mov    %esi,%eax
  801ba3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ba6:	72 cc                	jb     801b74 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ba8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bab:	5b                   	pop    %ebx
  801bac:	5e                   	pop    %esi
  801bad:	5f                   	pop    %edi
  801bae:	5d                   	pop    %ebp
  801baf:	c3                   	ret    

00801bb0 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	83 ec 08             	sub    $0x8,%esp
  801bb6:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801bbb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bbf:	74 2a                	je     801beb <devcons_read+0x3b>
  801bc1:	eb 05                	jmp    801bc8 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801bc3:	e8 a1 ef ff ff       	call   800b69 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801bc8:	e8 1d ef ff ff       	call   800aea <sys_cgetc>
  801bcd:	85 c0                	test   %eax,%eax
  801bcf:	74 f2                	je     801bc3 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801bd1:	85 c0                	test   %eax,%eax
  801bd3:	78 16                	js     801beb <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801bd5:	83 f8 04             	cmp    $0x4,%eax
  801bd8:	74 0c                	je     801be6 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801bda:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bdd:	88 02                	mov    %al,(%edx)
	return 1;
  801bdf:	b8 01 00 00 00       	mov    $0x1,%eax
  801be4:	eb 05                	jmp    801beb <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801be6:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801beb:	c9                   	leave  
  801bec:	c3                   	ret    

00801bed <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801bed:	55                   	push   %ebp
  801bee:	89 e5                	mov    %esp,%ebp
  801bf0:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801bf3:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf6:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801bf9:	6a 01                	push   $0x1
  801bfb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bfe:	50                   	push   %eax
  801bff:	e8 c8 ee ff ff       	call   800acc <sys_cputs>
}
  801c04:	83 c4 10             	add    $0x10,%esp
  801c07:	c9                   	leave  
  801c08:	c3                   	ret    

00801c09 <getchar>:

int
getchar(void)
{
  801c09:	55                   	push   %ebp
  801c0a:	89 e5                	mov    %esp,%ebp
  801c0c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c0f:	6a 01                	push   $0x1
  801c11:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c14:	50                   	push   %eax
  801c15:	6a 00                	push   $0x0
  801c17:	e8 8d f5 ff ff       	call   8011a9 <read>
	if (r < 0)
  801c1c:	83 c4 10             	add    $0x10,%esp
  801c1f:	85 c0                	test   %eax,%eax
  801c21:	78 0f                	js     801c32 <getchar+0x29>
		return r;
	if (r < 1)
  801c23:	85 c0                	test   %eax,%eax
  801c25:	7e 06                	jle    801c2d <getchar+0x24>
		return -E_EOF;
	return c;
  801c27:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c2b:	eb 05                	jmp    801c32 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c2d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c32:	c9                   	leave  
  801c33:	c3                   	ret    

00801c34 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
  801c37:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c3a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c3d:	50                   	push   %eax
  801c3e:	ff 75 08             	pushl  0x8(%ebp)
  801c41:	e8 fd f2 ff ff       	call   800f43 <fd_lookup>
  801c46:	83 c4 10             	add    $0x10,%esp
  801c49:	85 c0                	test   %eax,%eax
  801c4b:	78 11                	js     801c5e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c50:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c56:	39 10                	cmp    %edx,(%eax)
  801c58:	0f 94 c0             	sete   %al
  801c5b:	0f b6 c0             	movzbl %al,%eax
}
  801c5e:	c9                   	leave  
  801c5f:	c3                   	ret    

00801c60 <opencons>:

int
opencons(void)
{
  801c60:	55                   	push   %ebp
  801c61:	89 e5                	mov    %esp,%ebp
  801c63:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c66:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c69:	50                   	push   %eax
  801c6a:	e8 85 f2 ff ff       	call   800ef4 <fd_alloc>
  801c6f:	83 c4 10             	add    $0x10,%esp
		return r;
  801c72:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c74:	85 c0                	test   %eax,%eax
  801c76:	78 3e                	js     801cb6 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c78:	83 ec 04             	sub    $0x4,%esp
  801c7b:	68 07 04 00 00       	push   $0x407
  801c80:	ff 75 f4             	pushl  -0xc(%ebp)
  801c83:	6a 00                	push   $0x0
  801c85:	e8 fe ee ff ff       	call   800b88 <sys_page_alloc>
  801c8a:	83 c4 10             	add    $0x10,%esp
		return r;
  801c8d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c8f:	85 c0                	test   %eax,%eax
  801c91:	78 23                	js     801cb6 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c93:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ca8:	83 ec 0c             	sub    $0xc,%esp
  801cab:	50                   	push   %eax
  801cac:	e8 1c f2 ff ff       	call   800ecd <fd2num>
  801cb1:	89 c2                	mov    %eax,%edx
  801cb3:	83 c4 10             	add    $0x10,%esp
}
  801cb6:	89 d0                	mov    %edx,%eax
  801cb8:	c9                   	leave  
  801cb9:	c3                   	ret    

00801cba <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801cba:	55                   	push   %ebp
  801cbb:	89 e5                	mov    %esp,%ebp
  801cbd:	56                   	push   %esi
  801cbe:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801cbf:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801cc2:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801cc8:	e8 7d ee ff ff       	call   800b4a <sys_getenvid>
  801ccd:	83 ec 0c             	sub    $0xc,%esp
  801cd0:	ff 75 0c             	pushl  0xc(%ebp)
  801cd3:	ff 75 08             	pushl  0x8(%ebp)
  801cd6:	56                   	push   %esi
  801cd7:	50                   	push   %eax
  801cd8:	68 18 25 80 00       	push   $0x802518
  801cdd:	e8 1e e5 ff ff       	call   800200 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ce2:	83 c4 18             	add    $0x18,%esp
  801ce5:	53                   	push   %ebx
  801ce6:	ff 75 10             	pushl  0x10(%ebp)
  801ce9:	e8 c1 e4 ff ff       	call   8001af <vcprintf>
	cprintf("\n");
  801cee:	c7 04 24 d0 20 80 00 	movl   $0x8020d0,(%esp)
  801cf5:	e8 06 e5 ff ff       	call   800200 <cprintf>
  801cfa:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801cfd:	cc                   	int3   
  801cfe:	eb fd                	jmp    801cfd <_panic+0x43>

00801d00 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
  801d03:	56                   	push   %esi
  801d04:	53                   	push   %ebx
  801d05:	8b 75 08             	mov    0x8(%ebp),%esi
  801d08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801d0e:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801d10:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801d15:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801d18:	83 ec 0c             	sub    $0xc,%esp
  801d1b:	50                   	push   %eax
  801d1c:	e8 17 f0 ff ff       	call   800d38 <sys_ipc_recv>

	if (from_env_store != NULL)
  801d21:	83 c4 10             	add    $0x10,%esp
  801d24:	85 f6                	test   %esi,%esi
  801d26:	74 14                	je     801d3c <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801d28:	ba 00 00 00 00       	mov    $0x0,%edx
  801d2d:	85 c0                	test   %eax,%eax
  801d2f:	78 09                	js     801d3a <ipc_recv+0x3a>
  801d31:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d37:	8b 52 74             	mov    0x74(%edx),%edx
  801d3a:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801d3c:	85 db                	test   %ebx,%ebx
  801d3e:	74 14                	je     801d54 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801d40:	ba 00 00 00 00       	mov    $0x0,%edx
  801d45:	85 c0                	test   %eax,%eax
  801d47:	78 09                	js     801d52 <ipc_recv+0x52>
  801d49:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d4f:	8b 52 78             	mov    0x78(%edx),%edx
  801d52:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801d54:	85 c0                	test   %eax,%eax
  801d56:	78 08                	js     801d60 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801d58:	a1 04 40 80 00       	mov    0x804004,%eax
  801d5d:	8b 40 70             	mov    0x70(%eax),%eax
}
  801d60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d63:	5b                   	pop    %ebx
  801d64:	5e                   	pop    %esi
  801d65:	5d                   	pop    %ebp
  801d66:	c3                   	ret    

00801d67 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d67:	55                   	push   %ebp
  801d68:	89 e5                	mov    %esp,%ebp
  801d6a:	57                   	push   %edi
  801d6b:	56                   	push   %esi
  801d6c:	53                   	push   %ebx
  801d6d:	83 ec 0c             	sub    $0xc,%esp
  801d70:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d73:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801d79:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801d7b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801d80:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801d83:	ff 75 14             	pushl  0x14(%ebp)
  801d86:	53                   	push   %ebx
  801d87:	56                   	push   %esi
  801d88:	57                   	push   %edi
  801d89:	e8 87 ef ff ff       	call   800d15 <sys_ipc_try_send>

		if (err < 0) {
  801d8e:	83 c4 10             	add    $0x10,%esp
  801d91:	85 c0                	test   %eax,%eax
  801d93:	79 1e                	jns    801db3 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801d95:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d98:	75 07                	jne    801da1 <ipc_send+0x3a>
				sys_yield();
  801d9a:	e8 ca ed ff ff       	call   800b69 <sys_yield>
  801d9f:	eb e2                	jmp    801d83 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801da1:	50                   	push   %eax
  801da2:	68 3c 25 80 00       	push   $0x80253c
  801da7:	6a 49                	push   $0x49
  801da9:	68 49 25 80 00       	push   $0x802549
  801dae:	e8 07 ff ff ff       	call   801cba <_panic>
		}

	} while (err < 0);

}
  801db3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801db6:	5b                   	pop    %ebx
  801db7:	5e                   	pop    %esi
  801db8:	5f                   	pop    %edi
  801db9:	5d                   	pop    %ebp
  801dba:	c3                   	ret    

00801dbb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
  801dbe:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801dc1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801dc6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801dc9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801dcf:	8b 52 50             	mov    0x50(%edx),%edx
  801dd2:	39 ca                	cmp    %ecx,%edx
  801dd4:	75 0d                	jne    801de3 <ipc_find_env+0x28>
			return envs[i].env_id;
  801dd6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801dd9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801dde:	8b 40 48             	mov    0x48(%eax),%eax
  801de1:	eb 0f                	jmp    801df2 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801de3:	83 c0 01             	add    $0x1,%eax
  801de6:	3d 00 04 00 00       	cmp    $0x400,%eax
  801deb:	75 d9                	jne    801dc6 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ded:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801df2:	5d                   	pop    %ebp
  801df3:	c3                   	ret    

00801df4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801df4:	55                   	push   %ebp
  801df5:	89 e5                	mov    %esp,%ebp
  801df7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801dfa:	89 d0                	mov    %edx,%eax
  801dfc:	c1 e8 16             	shr    $0x16,%eax
  801dff:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e06:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e0b:	f6 c1 01             	test   $0x1,%cl
  801e0e:	74 1d                	je     801e2d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e10:	c1 ea 0c             	shr    $0xc,%edx
  801e13:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e1a:	f6 c2 01             	test   $0x1,%dl
  801e1d:	74 0e                	je     801e2d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e1f:	c1 ea 0c             	shr    $0xc,%edx
  801e22:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e29:	ef 
  801e2a:	0f b7 c0             	movzwl %ax,%eax
}
  801e2d:	5d                   	pop    %ebp
  801e2e:	c3                   	ret    
  801e2f:	90                   	nop

00801e30 <__udivdi3>:
  801e30:	55                   	push   %ebp
  801e31:	57                   	push   %edi
  801e32:	56                   	push   %esi
  801e33:	53                   	push   %ebx
  801e34:	83 ec 1c             	sub    $0x1c,%esp
  801e37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801e3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801e3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801e43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e47:	85 f6                	test   %esi,%esi
  801e49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e4d:	89 ca                	mov    %ecx,%edx
  801e4f:	89 f8                	mov    %edi,%eax
  801e51:	75 3d                	jne    801e90 <__udivdi3+0x60>
  801e53:	39 cf                	cmp    %ecx,%edi
  801e55:	0f 87 c5 00 00 00    	ja     801f20 <__udivdi3+0xf0>
  801e5b:	85 ff                	test   %edi,%edi
  801e5d:	89 fd                	mov    %edi,%ebp
  801e5f:	75 0b                	jne    801e6c <__udivdi3+0x3c>
  801e61:	b8 01 00 00 00       	mov    $0x1,%eax
  801e66:	31 d2                	xor    %edx,%edx
  801e68:	f7 f7                	div    %edi
  801e6a:	89 c5                	mov    %eax,%ebp
  801e6c:	89 c8                	mov    %ecx,%eax
  801e6e:	31 d2                	xor    %edx,%edx
  801e70:	f7 f5                	div    %ebp
  801e72:	89 c1                	mov    %eax,%ecx
  801e74:	89 d8                	mov    %ebx,%eax
  801e76:	89 cf                	mov    %ecx,%edi
  801e78:	f7 f5                	div    %ebp
  801e7a:	89 c3                	mov    %eax,%ebx
  801e7c:	89 d8                	mov    %ebx,%eax
  801e7e:	89 fa                	mov    %edi,%edx
  801e80:	83 c4 1c             	add    $0x1c,%esp
  801e83:	5b                   	pop    %ebx
  801e84:	5e                   	pop    %esi
  801e85:	5f                   	pop    %edi
  801e86:	5d                   	pop    %ebp
  801e87:	c3                   	ret    
  801e88:	90                   	nop
  801e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e90:	39 ce                	cmp    %ecx,%esi
  801e92:	77 74                	ja     801f08 <__udivdi3+0xd8>
  801e94:	0f bd fe             	bsr    %esi,%edi
  801e97:	83 f7 1f             	xor    $0x1f,%edi
  801e9a:	0f 84 98 00 00 00    	je     801f38 <__udivdi3+0x108>
  801ea0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ea5:	89 f9                	mov    %edi,%ecx
  801ea7:	89 c5                	mov    %eax,%ebp
  801ea9:	29 fb                	sub    %edi,%ebx
  801eab:	d3 e6                	shl    %cl,%esi
  801ead:	89 d9                	mov    %ebx,%ecx
  801eaf:	d3 ed                	shr    %cl,%ebp
  801eb1:	89 f9                	mov    %edi,%ecx
  801eb3:	d3 e0                	shl    %cl,%eax
  801eb5:	09 ee                	or     %ebp,%esi
  801eb7:	89 d9                	mov    %ebx,%ecx
  801eb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ebd:	89 d5                	mov    %edx,%ebp
  801ebf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ec3:	d3 ed                	shr    %cl,%ebp
  801ec5:	89 f9                	mov    %edi,%ecx
  801ec7:	d3 e2                	shl    %cl,%edx
  801ec9:	89 d9                	mov    %ebx,%ecx
  801ecb:	d3 e8                	shr    %cl,%eax
  801ecd:	09 c2                	or     %eax,%edx
  801ecf:	89 d0                	mov    %edx,%eax
  801ed1:	89 ea                	mov    %ebp,%edx
  801ed3:	f7 f6                	div    %esi
  801ed5:	89 d5                	mov    %edx,%ebp
  801ed7:	89 c3                	mov    %eax,%ebx
  801ed9:	f7 64 24 0c          	mull   0xc(%esp)
  801edd:	39 d5                	cmp    %edx,%ebp
  801edf:	72 10                	jb     801ef1 <__udivdi3+0xc1>
  801ee1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ee5:	89 f9                	mov    %edi,%ecx
  801ee7:	d3 e6                	shl    %cl,%esi
  801ee9:	39 c6                	cmp    %eax,%esi
  801eeb:	73 07                	jae    801ef4 <__udivdi3+0xc4>
  801eed:	39 d5                	cmp    %edx,%ebp
  801eef:	75 03                	jne    801ef4 <__udivdi3+0xc4>
  801ef1:	83 eb 01             	sub    $0x1,%ebx
  801ef4:	31 ff                	xor    %edi,%edi
  801ef6:	89 d8                	mov    %ebx,%eax
  801ef8:	89 fa                	mov    %edi,%edx
  801efa:	83 c4 1c             	add    $0x1c,%esp
  801efd:	5b                   	pop    %ebx
  801efe:	5e                   	pop    %esi
  801eff:	5f                   	pop    %edi
  801f00:	5d                   	pop    %ebp
  801f01:	c3                   	ret    
  801f02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f08:	31 ff                	xor    %edi,%edi
  801f0a:	31 db                	xor    %ebx,%ebx
  801f0c:	89 d8                	mov    %ebx,%eax
  801f0e:	89 fa                	mov    %edi,%edx
  801f10:	83 c4 1c             	add    $0x1c,%esp
  801f13:	5b                   	pop    %ebx
  801f14:	5e                   	pop    %esi
  801f15:	5f                   	pop    %edi
  801f16:	5d                   	pop    %ebp
  801f17:	c3                   	ret    
  801f18:	90                   	nop
  801f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f20:	89 d8                	mov    %ebx,%eax
  801f22:	f7 f7                	div    %edi
  801f24:	31 ff                	xor    %edi,%edi
  801f26:	89 c3                	mov    %eax,%ebx
  801f28:	89 d8                	mov    %ebx,%eax
  801f2a:	89 fa                	mov    %edi,%edx
  801f2c:	83 c4 1c             	add    $0x1c,%esp
  801f2f:	5b                   	pop    %ebx
  801f30:	5e                   	pop    %esi
  801f31:	5f                   	pop    %edi
  801f32:	5d                   	pop    %ebp
  801f33:	c3                   	ret    
  801f34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f38:	39 ce                	cmp    %ecx,%esi
  801f3a:	72 0c                	jb     801f48 <__udivdi3+0x118>
  801f3c:	31 db                	xor    %ebx,%ebx
  801f3e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801f42:	0f 87 34 ff ff ff    	ja     801e7c <__udivdi3+0x4c>
  801f48:	bb 01 00 00 00       	mov    $0x1,%ebx
  801f4d:	e9 2a ff ff ff       	jmp    801e7c <__udivdi3+0x4c>
  801f52:	66 90                	xchg   %ax,%ax
  801f54:	66 90                	xchg   %ax,%ax
  801f56:	66 90                	xchg   %ax,%ax
  801f58:	66 90                	xchg   %ax,%ax
  801f5a:	66 90                	xchg   %ax,%ax
  801f5c:	66 90                	xchg   %ax,%ax
  801f5e:	66 90                	xchg   %ax,%ax

00801f60 <__umoddi3>:
  801f60:	55                   	push   %ebp
  801f61:	57                   	push   %edi
  801f62:	56                   	push   %esi
  801f63:	53                   	push   %ebx
  801f64:	83 ec 1c             	sub    $0x1c,%esp
  801f67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801f6b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801f6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801f73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f77:	85 d2                	test   %edx,%edx
  801f79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801f7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f81:	89 f3                	mov    %esi,%ebx
  801f83:	89 3c 24             	mov    %edi,(%esp)
  801f86:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f8a:	75 1c                	jne    801fa8 <__umoddi3+0x48>
  801f8c:	39 f7                	cmp    %esi,%edi
  801f8e:	76 50                	jbe    801fe0 <__umoddi3+0x80>
  801f90:	89 c8                	mov    %ecx,%eax
  801f92:	89 f2                	mov    %esi,%edx
  801f94:	f7 f7                	div    %edi
  801f96:	89 d0                	mov    %edx,%eax
  801f98:	31 d2                	xor    %edx,%edx
  801f9a:	83 c4 1c             	add    $0x1c,%esp
  801f9d:	5b                   	pop    %ebx
  801f9e:	5e                   	pop    %esi
  801f9f:	5f                   	pop    %edi
  801fa0:	5d                   	pop    %ebp
  801fa1:	c3                   	ret    
  801fa2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fa8:	39 f2                	cmp    %esi,%edx
  801faa:	89 d0                	mov    %edx,%eax
  801fac:	77 52                	ja     802000 <__umoddi3+0xa0>
  801fae:	0f bd ea             	bsr    %edx,%ebp
  801fb1:	83 f5 1f             	xor    $0x1f,%ebp
  801fb4:	75 5a                	jne    802010 <__umoddi3+0xb0>
  801fb6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801fba:	0f 82 e0 00 00 00    	jb     8020a0 <__umoddi3+0x140>
  801fc0:	39 0c 24             	cmp    %ecx,(%esp)
  801fc3:	0f 86 d7 00 00 00    	jbe    8020a0 <__umoddi3+0x140>
  801fc9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fcd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801fd1:	83 c4 1c             	add    $0x1c,%esp
  801fd4:	5b                   	pop    %ebx
  801fd5:	5e                   	pop    %esi
  801fd6:	5f                   	pop    %edi
  801fd7:	5d                   	pop    %ebp
  801fd8:	c3                   	ret    
  801fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fe0:	85 ff                	test   %edi,%edi
  801fe2:	89 fd                	mov    %edi,%ebp
  801fe4:	75 0b                	jne    801ff1 <__umoddi3+0x91>
  801fe6:	b8 01 00 00 00       	mov    $0x1,%eax
  801feb:	31 d2                	xor    %edx,%edx
  801fed:	f7 f7                	div    %edi
  801fef:	89 c5                	mov    %eax,%ebp
  801ff1:	89 f0                	mov    %esi,%eax
  801ff3:	31 d2                	xor    %edx,%edx
  801ff5:	f7 f5                	div    %ebp
  801ff7:	89 c8                	mov    %ecx,%eax
  801ff9:	f7 f5                	div    %ebp
  801ffb:	89 d0                	mov    %edx,%eax
  801ffd:	eb 99                	jmp    801f98 <__umoddi3+0x38>
  801fff:	90                   	nop
  802000:	89 c8                	mov    %ecx,%eax
  802002:	89 f2                	mov    %esi,%edx
  802004:	83 c4 1c             	add    $0x1c,%esp
  802007:	5b                   	pop    %ebx
  802008:	5e                   	pop    %esi
  802009:	5f                   	pop    %edi
  80200a:	5d                   	pop    %ebp
  80200b:	c3                   	ret    
  80200c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802010:	8b 34 24             	mov    (%esp),%esi
  802013:	bf 20 00 00 00       	mov    $0x20,%edi
  802018:	89 e9                	mov    %ebp,%ecx
  80201a:	29 ef                	sub    %ebp,%edi
  80201c:	d3 e0                	shl    %cl,%eax
  80201e:	89 f9                	mov    %edi,%ecx
  802020:	89 f2                	mov    %esi,%edx
  802022:	d3 ea                	shr    %cl,%edx
  802024:	89 e9                	mov    %ebp,%ecx
  802026:	09 c2                	or     %eax,%edx
  802028:	89 d8                	mov    %ebx,%eax
  80202a:	89 14 24             	mov    %edx,(%esp)
  80202d:	89 f2                	mov    %esi,%edx
  80202f:	d3 e2                	shl    %cl,%edx
  802031:	89 f9                	mov    %edi,%ecx
  802033:	89 54 24 04          	mov    %edx,0x4(%esp)
  802037:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80203b:	d3 e8                	shr    %cl,%eax
  80203d:	89 e9                	mov    %ebp,%ecx
  80203f:	89 c6                	mov    %eax,%esi
  802041:	d3 e3                	shl    %cl,%ebx
  802043:	89 f9                	mov    %edi,%ecx
  802045:	89 d0                	mov    %edx,%eax
  802047:	d3 e8                	shr    %cl,%eax
  802049:	89 e9                	mov    %ebp,%ecx
  80204b:	09 d8                	or     %ebx,%eax
  80204d:	89 d3                	mov    %edx,%ebx
  80204f:	89 f2                	mov    %esi,%edx
  802051:	f7 34 24             	divl   (%esp)
  802054:	89 d6                	mov    %edx,%esi
  802056:	d3 e3                	shl    %cl,%ebx
  802058:	f7 64 24 04          	mull   0x4(%esp)
  80205c:	39 d6                	cmp    %edx,%esi
  80205e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802062:	89 d1                	mov    %edx,%ecx
  802064:	89 c3                	mov    %eax,%ebx
  802066:	72 08                	jb     802070 <__umoddi3+0x110>
  802068:	75 11                	jne    80207b <__umoddi3+0x11b>
  80206a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80206e:	73 0b                	jae    80207b <__umoddi3+0x11b>
  802070:	2b 44 24 04          	sub    0x4(%esp),%eax
  802074:	1b 14 24             	sbb    (%esp),%edx
  802077:	89 d1                	mov    %edx,%ecx
  802079:	89 c3                	mov    %eax,%ebx
  80207b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80207f:	29 da                	sub    %ebx,%edx
  802081:	19 ce                	sbb    %ecx,%esi
  802083:	89 f9                	mov    %edi,%ecx
  802085:	89 f0                	mov    %esi,%eax
  802087:	d3 e0                	shl    %cl,%eax
  802089:	89 e9                	mov    %ebp,%ecx
  80208b:	d3 ea                	shr    %cl,%edx
  80208d:	89 e9                	mov    %ebp,%ecx
  80208f:	d3 ee                	shr    %cl,%esi
  802091:	09 d0                	or     %edx,%eax
  802093:	89 f2                	mov    %esi,%edx
  802095:	83 c4 1c             	add    $0x1c,%esp
  802098:	5b                   	pop    %ebx
  802099:	5e                   	pop    %esi
  80209a:	5f                   	pop    %edi
  80209b:	5d                   	pop    %ebp
  80209c:	c3                   	ret    
  80209d:	8d 76 00             	lea    0x0(%esi),%esi
  8020a0:	29 f9                	sub    %edi,%ecx
  8020a2:	19 d6                	sbb    %edx,%esi
  8020a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020ac:	e9 18 ff ff ff       	jmp    801fc9 <__umoddi3+0x69>
