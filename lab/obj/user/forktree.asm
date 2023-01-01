
obj/user/forktree:     file format elf32-i386


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
  80002c:	e8 bf 00 00 00       	call   8000f0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 e3 0a 00 00       	call   800b25 <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 c0 12 80 00       	push   $0x8012c0
  80004c:	e8 8a 01 00 00       	call   8001db <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 14             	sub    $0x14,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	char nxt[DEPTH+1];
	memset(nxt, 0, DEPTH+1);
  80007d:	6a 04                	push   $0x4
  80007f:	6a 00                	push   $0x0
  800081:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800084:	50                   	push   %eax
  800085:	e8 1b 08 00 00       	call   8008a5 <memset>

	if (strlen(cur) >= DEPTH)
  80008a:	89 1c 24             	mov    %ebx,(%esp)
  80008d:	e8 95 06 00 00       	call   800727 <strlen>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	83 f8 02             	cmp    $0x2,%eax
  800098:	7f 3a                	jg     8000d4 <forkchild+0x65>
		return;
	// cprintf("%s, %s\n", cur, nxt);
	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	89 f0                	mov    %esi,%eax
  80009f:	0f be f0             	movsbl %al,%esi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
  8000a4:	68 d1 12 80 00       	push   $0x8012d1
  8000a9:	6a 04                	push   $0x4
  8000ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000ae:	50                   	push   %eax
  8000af:	e8 59 06 00 00       	call   80070d <snprintf>
	// cprintf("%s, %s\n", cur, nxt);
	if (fork() == 0) {
  8000b4:	83 c4 20             	add    $0x20,%esp
  8000b7:	e8 2f 0d 00 00       	call   800deb <fork>
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	75 14                	jne    8000d4 <forkchild+0x65>
		forktree(nxt);
  8000c0:	83 ec 0c             	sub    $0xc,%esp
  8000c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000c6:	50                   	push   %eax
  8000c7:	e8 67 ff ff ff       	call   800033 <forktree>
		exit();
  8000cc:	e8 65 00 00 00       	call   800136 <exit>
  8000d1:	83 c4 10             	add    $0x10,%esp
	}
}
  8000d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000d7:	5b                   	pop    %ebx
  8000d8:	5e                   	pop    %esi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000e1:	68 d0 12 80 00       	push   $0x8012d0
  8000e6:	e8 48 ff ff ff       	call   800033 <forktree>
}
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	c9                   	leave  
  8000ef:	c3                   	ret    

008000f0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	56                   	push   %esi
  8000f4:	53                   	push   %ebx
  8000f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000fb:	e8 25 0a 00 00       	call   800b25 <sys_getenvid>
  800100:	25 ff 03 00 00       	and    $0x3ff,%eax
  800105:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800108:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010d:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800112:	85 db                	test   %ebx,%ebx
  800114:	7e 07                	jle    80011d <libmain+0x2d>
		binaryname = argv[0];
  800116:	8b 06                	mov    (%esi),%eax
  800118:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80011d:	83 ec 08             	sub    $0x8,%esp
  800120:	56                   	push   %esi
  800121:	53                   	push   %ebx
  800122:	e8 b4 ff ff ff       	call   8000db <umain>

	// exit gracefully
	exit();
  800127:	e8 0a 00 00 00       	call   800136 <exit>
}
  80012c:	83 c4 10             	add    $0x10,%esp
  80012f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800132:	5b                   	pop    %ebx
  800133:	5e                   	pop    %esi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    

00800136 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80013c:	6a 00                	push   $0x0
  80013e:	e8 a1 09 00 00       	call   800ae4 <sys_env_destroy>
}
  800143:	83 c4 10             	add    $0x10,%esp
  800146:	c9                   	leave  
  800147:	c3                   	ret    

00800148 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	53                   	push   %ebx
  80014c:	83 ec 04             	sub    $0x4,%esp
  80014f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800152:	8b 13                	mov    (%ebx),%edx
  800154:	8d 42 01             	lea    0x1(%edx),%eax
  800157:	89 03                	mov    %eax,(%ebx)
  800159:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80015c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800160:	3d ff 00 00 00       	cmp    $0xff,%eax
  800165:	75 1a                	jne    800181 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800167:	83 ec 08             	sub    $0x8,%esp
  80016a:	68 ff 00 00 00       	push   $0xff
  80016f:	8d 43 08             	lea    0x8(%ebx),%eax
  800172:	50                   	push   %eax
  800173:	e8 2f 09 00 00       	call   800aa7 <sys_cputs>
		b->idx = 0;
  800178:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80017e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800181:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800185:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800188:	c9                   	leave  
  800189:	c3                   	ret    

0080018a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80018a:	55                   	push   %ebp
  80018b:	89 e5                	mov    %esp,%ebp
  80018d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800193:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80019a:	00 00 00 
	b.cnt = 0;
  80019d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001a4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a7:	ff 75 0c             	pushl  0xc(%ebp)
  8001aa:	ff 75 08             	pushl  0x8(%ebp)
  8001ad:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001b3:	50                   	push   %eax
  8001b4:	68 48 01 80 00       	push   $0x800148
  8001b9:	e8 54 01 00 00       	call   800312 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001be:	83 c4 08             	add    $0x8,%esp
  8001c1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001cd:	50                   	push   %eax
  8001ce:	e8 d4 08 00 00       	call   800aa7 <sys_cputs>

	return b.cnt;
}
  8001d3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d9:	c9                   	leave  
  8001da:	c3                   	ret    

008001db <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001e1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001e4:	50                   	push   %eax
  8001e5:	ff 75 08             	pushl  0x8(%ebp)
  8001e8:	e8 9d ff ff ff       	call   80018a <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ed:	c9                   	leave  
  8001ee:	c3                   	ret    

008001ef <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	57                   	push   %edi
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	83 ec 1c             	sub    $0x1c,%esp
  8001f8:	89 c7                	mov    %eax,%edi
  8001fa:	89 d6                	mov    %edx,%esi
  8001fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800202:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800205:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800208:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80020b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800210:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800213:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800216:	39 d3                	cmp    %edx,%ebx
  800218:	72 05                	jb     80021f <printnum+0x30>
  80021a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80021d:	77 45                	ja     800264 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80021f:	83 ec 0c             	sub    $0xc,%esp
  800222:	ff 75 18             	pushl  0x18(%ebp)
  800225:	8b 45 14             	mov    0x14(%ebp),%eax
  800228:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80022b:	53                   	push   %ebx
  80022c:	ff 75 10             	pushl  0x10(%ebp)
  80022f:	83 ec 08             	sub    $0x8,%esp
  800232:	ff 75 e4             	pushl  -0x1c(%ebp)
  800235:	ff 75 e0             	pushl  -0x20(%ebp)
  800238:	ff 75 dc             	pushl  -0x24(%ebp)
  80023b:	ff 75 d8             	pushl  -0x28(%ebp)
  80023e:	e8 dd 0d 00 00       	call   801020 <__udivdi3>
  800243:	83 c4 18             	add    $0x18,%esp
  800246:	52                   	push   %edx
  800247:	50                   	push   %eax
  800248:	89 f2                	mov    %esi,%edx
  80024a:	89 f8                	mov    %edi,%eax
  80024c:	e8 9e ff ff ff       	call   8001ef <printnum>
  800251:	83 c4 20             	add    $0x20,%esp
  800254:	eb 18                	jmp    80026e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800256:	83 ec 08             	sub    $0x8,%esp
  800259:	56                   	push   %esi
  80025a:	ff 75 18             	pushl  0x18(%ebp)
  80025d:	ff d7                	call   *%edi
  80025f:	83 c4 10             	add    $0x10,%esp
  800262:	eb 03                	jmp    800267 <printnum+0x78>
  800264:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800267:	83 eb 01             	sub    $0x1,%ebx
  80026a:	85 db                	test   %ebx,%ebx
  80026c:	7f e8                	jg     800256 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80026e:	83 ec 08             	sub    $0x8,%esp
  800271:	56                   	push   %esi
  800272:	83 ec 04             	sub    $0x4,%esp
  800275:	ff 75 e4             	pushl  -0x1c(%ebp)
  800278:	ff 75 e0             	pushl  -0x20(%ebp)
  80027b:	ff 75 dc             	pushl  -0x24(%ebp)
  80027e:	ff 75 d8             	pushl  -0x28(%ebp)
  800281:	e8 ca 0e 00 00       	call   801150 <__umoddi3>
  800286:	83 c4 14             	add    $0x14,%esp
  800289:	0f be 80 e0 12 80 00 	movsbl 0x8012e0(%eax),%eax
  800290:	50                   	push   %eax
  800291:	ff d7                	call   *%edi
}
  800293:	83 c4 10             	add    $0x10,%esp
  800296:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800299:	5b                   	pop    %ebx
  80029a:	5e                   	pop    %esi
  80029b:	5f                   	pop    %edi
  80029c:	5d                   	pop    %ebp
  80029d:	c3                   	ret    

0080029e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80029e:	55                   	push   %ebp
  80029f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a1:	83 fa 01             	cmp    $0x1,%edx
  8002a4:	7e 0e                	jle    8002b4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002a6:	8b 10                	mov    (%eax),%edx
  8002a8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ab:	89 08                	mov    %ecx,(%eax)
  8002ad:	8b 02                	mov    (%edx),%eax
  8002af:	8b 52 04             	mov    0x4(%edx),%edx
  8002b2:	eb 22                	jmp    8002d6 <getuint+0x38>
	else if (lflag)
  8002b4:	85 d2                	test   %edx,%edx
  8002b6:	74 10                	je     8002c8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b8:	8b 10                	mov    (%eax),%edx
  8002ba:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002bd:	89 08                	mov    %ecx,(%eax)
  8002bf:	8b 02                	mov    (%edx),%eax
  8002c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c6:	eb 0e                	jmp    8002d6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c8:	8b 10                	mov    (%eax),%edx
  8002ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002cd:	89 08                	mov    %ecx,(%eax)
  8002cf:	8b 02                	mov    (%edx),%eax
  8002d1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002d6:	5d                   	pop    %ebp
  8002d7:	c3                   	ret    

008002d8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
  8002db:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002de:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e2:	8b 10                	mov    (%eax),%edx
  8002e4:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e7:	73 0a                	jae    8002f3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ec:	89 08                	mov    %ecx,(%eax)
  8002ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f1:	88 02                	mov    %al,(%edx)
}
  8002f3:	5d                   	pop    %ebp
  8002f4:	c3                   	ret    

008002f5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002fb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002fe:	50                   	push   %eax
  8002ff:	ff 75 10             	pushl  0x10(%ebp)
  800302:	ff 75 0c             	pushl  0xc(%ebp)
  800305:	ff 75 08             	pushl  0x8(%ebp)
  800308:	e8 05 00 00 00       	call   800312 <vprintfmt>
	va_end(ap);
}
  80030d:	83 c4 10             	add    $0x10,%esp
  800310:	c9                   	leave  
  800311:	c3                   	ret    

00800312 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	57                   	push   %edi
  800316:	56                   	push   %esi
  800317:	53                   	push   %ebx
  800318:	83 ec 2c             	sub    $0x2c,%esp
  80031b:	8b 75 08             	mov    0x8(%ebp),%esi
  80031e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800321:	8b 7d 10             	mov    0x10(%ebp),%edi
  800324:	eb 12                	jmp    800338 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800326:	85 c0                	test   %eax,%eax
  800328:	0f 84 89 03 00 00    	je     8006b7 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80032e:	83 ec 08             	sub    $0x8,%esp
  800331:	53                   	push   %ebx
  800332:	50                   	push   %eax
  800333:	ff d6                	call   *%esi
  800335:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800338:	83 c7 01             	add    $0x1,%edi
  80033b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80033f:	83 f8 25             	cmp    $0x25,%eax
  800342:	75 e2                	jne    800326 <vprintfmt+0x14>
  800344:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800348:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80034f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800356:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80035d:	ba 00 00 00 00       	mov    $0x0,%edx
  800362:	eb 07                	jmp    80036b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800364:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800367:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036b:	8d 47 01             	lea    0x1(%edi),%eax
  80036e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800371:	0f b6 07             	movzbl (%edi),%eax
  800374:	0f b6 c8             	movzbl %al,%ecx
  800377:	83 e8 23             	sub    $0x23,%eax
  80037a:	3c 55                	cmp    $0x55,%al
  80037c:	0f 87 1a 03 00 00    	ja     80069c <vprintfmt+0x38a>
  800382:	0f b6 c0             	movzbl %al,%eax
  800385:	ff 24 85 a0 13 80 00 	jmp    *0x8013a0(,%eax,4)
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80038f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800393:	eb d6                	jmp    80036b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800398:	b8 00 00 00 00       	mov    $0x0,%eax
  80039d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003a7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003aa:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003ad:	83 fa 09             	cmp    $0x9,%edx
  8003b0:	77 39                	ja     8003eb <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003b2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003b5:	eb e9                	jmp    8003a0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ba:	8d 48 04             	lea    0x4(%eax),%ecx
  8003bd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003c0:	8b 00                	mov    (%eax),%eax
  8003c2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c8:	eb 27                	jmp    8003f1 <vprintfmt+0xdf>
  8003ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003cd:	85 c0                	test   %eax,%eax
  8003cf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d4:	0f 49 c8             	cmovns %eax,%ecx
  8003d7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003dd:	eb 8c                	jmp    80036b <vprintfmt+0x59>
  8003df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003e2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e9:	eb 80                	jmp    80036b <vprintfmt+0x59>
  8003eb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003ee:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003f1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f5:	0f 89 70 ff ff ff    	jns    80036b <vprintfmt+0x59>
				width = precision, precision = -1;
  8003fb:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800401:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800408:	e9 5e ff ff ff       	jmp    80036b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80040d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800413:	e9 53 ff ff ff       	jmp    80036b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800418:	8b 45 14             	mov    0x14(%ebp),%eax
  80041b:	8d 50 04             	lea    0x4(%eax),%edx
  80041e:	89 55 14             	mov    %edx,0x14(%ebp)
  800421:	83 ec 08             	sub    $0x8,%esp
  800424:	53                   	push   %ebx
  800425:	ff 30                	pushl  (%eax)
  800427:	ff d6                	call   *%esi
			break;
  800429:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80042f:	e9 04 ff ff ff       	jmp    800338 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800434:	8b 45 14             	mov    0x14(%ebp),%eax
  800437:	8d 50 04             	lea    0x4(%eax),%edx
  80043a:	89 55 14             	mov    %edx,0x14(%ebp)
  80043d:	8b 00                	mov    (%eax),%eax
  80043f:	99                   	cltd   
  800440:	31 d0                	xor    %edx,%eax
  800442:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800444:	83 f8 08             	cmp    $0x8,%eax
  800447:	7f 0b                	jg     800454 <vprintfmt+0x142>
  800449:	8b 14 85 00 15 80 00 	mov    0x801500(,%eax,4),%edx
  800450:	85 d2                	test   %edx,%edx
  800452:	75 18                	jne    80046c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800454:	50                   	push   %eax
  800455:	68 f8 12 80 00       	push   $0x8012f8
  80045a:	53                   	push   %ebx
  80045b:	56                   	push   %esi
  80045c:	e8 94 fe ff ff       	call   8002f5 <printfmt>
  800461:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800464:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800467:	e9 cc fe ff ff       	jmp    800338 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80046c:	52                   	push   %edx
  80046d:	68 01 13 80 00       	push   $0x801301
  800472:	53                   	push   %ebx
  800473:	56                   	push   %esi
  800474:	e8 7c fe ff ff       	call   8002f5 <printfmt>
  800479:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80047f:	e9 b4 fe ff ff       	jmp    800338 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800484:	8b 45 14             	mov    0x14(%ebp),%eax
  800487:	8d 50 04             	lea    0x4(%eax),%edx
  80048a:	89 55 14             	mov    %edx,0x14(%ebp)
  80048d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80048f:	85 ff                	test   %edi,%edi
  800491:	b8 f1 12 80 00       	mov    $0x8012f1,%eax
  800496:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800499:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80049d:	0f 8e 94 00 00 00    	jle    800537 <vprintfmt+0x225>
  8004a3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004a7:	0f 84 98 00 00 00    	je     800545 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	ff 75 d0             	pushl  -0x30(%ebp)
  8004b3:	57                   	push   %edi
  8004b4:	e8 86 02 00 00       	call   80073f <strnlen>
  8004b9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004bc:	29 c1                	sub    %eax,%ecx
  8004be:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004c1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004c4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004cb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ce:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d0:	eb 0f                	jmp    8004e1 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004d2:	83 ec 08             	sub    $0x8,%esp
  8004d5:	53                   	push   %ebx
  8004d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004db:	83 ef 01             	sub    $0x1,%edi
  8004de:	83 c4 10             	add    $0x10,%esp
  8004e1:	85 ff                	test   %edi,%edi
  8004e3:	7f ed                	jg     8004d2 <vprintfmt+0x1c0>
  8004e5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004eb:	85 c9                	test   %ecx,%ecx
  8004ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f2:	0f 49 c1             	cmovns %ecx,%eax
  8004f5:	29 c1                	sub    %eax,%ecx
  8004f7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004fa:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004fd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800500:	89 cb                	mov    %ecx,%ebx
  800502:	eb 4d                	jmp    800551 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800504:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800508:	74 1b                	je     800525 <vprintfmt+0x213>
  80050a:	0f be c0             	movsbl %al,%eax
  80050d:	83 e8 20             	sub    $0x20,%eax
  800510:	83 f8 5e             	cmp    $0x5e,%eax
  800513:	76 10                	jbe    800525 <vprintfmt+0x213>
					putch('?', putdat);
  800515:	83 ec 08             	sub    $0x8,%esp
  800518:	ff 75 0c             	pushl  0xc(%ebp)
  80051b:	6a 3f                	push   $0x3f
  80051d:	ff 55 08             	call   *0x8(%ebp)
  800520:	83 c4 10             	add    $0x10,%esp
  800523:	eb 0d                	jmp    800532 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800525:	83 ec 08             	sub    $0x8,%esp
  800528:	ff 75 0c             	pushl  0xc(%ebp)
  80052b:	52                   	push   %edx
  80052c:	ff 55 08             	call   *0x8(%ebp)
  80052f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800532:	83 eb 01             	sub    $0x1,%ebx
  800535:	eb 1a                	jmp    800551 <vprintfmt+0x23f>
  800537:	89 75 08             	mov    %esi,0x8(%ebp)
  80053a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80053d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800540:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800543:	eb 0c                	jmp    800551 <vprintfmt+0x23f>
  800545:	89 75 08             	mov    %esi,0x8(%ebp)
  800548:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80054b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800551:	83 c7 01             	add    $0x1,%edi
  800554:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800558:	0f be d0             	movsbl %al,%edx
  80055b:	85 d2                	test   %edx,%edx
  80055d:	74 23                	je     800582 <vprintfmt+0x270>
  80055f:	85 f6                	test   %esi,%esi
  800561:	78 a1                	js     800504 <vprintfmt+0x1f2>
  800563:	83 ee 01             	sub    $0x1,%esi
  800566:	79 9c                	jns    800504 <vprintfmt+0x1f2>
  800568:	89 df                	mov    %ebx,%edi
  80056a:	8b 75 08             	mov    0x8(%ebp),%esi
  80056d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800570:	eb 18                	jmp    80058a <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800572:	83 ec 08             	sub    $0x8,%esp
  800575:	53                   	push   %ebx
  800576:	6a 20                	push   $0x20
  800578:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80057a:	83 ef 01             	sub    $0x1,%edi
  80057d:	83 c4 10             	add    $0x10,%esp
  800580:	eb 08                	jmp    80058a <vprintfmt+0x278>
  800582:	89 df                	mov    %ebx,%edi
  800584:	8b 75 08             	mov    0x8(%ebp),%esi
  800587:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80058a:	85 ff                	test   %edi,%edi
  80058c:	7f e4                	jg     800572 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800591:	e9 a2 fd ff ff       	jmp    800338 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800596:	83 fa 01             	cmp    $0x1,%edx
  800599:	7e 16                	jle    8005b1 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8d 50 08             	lea    0x8(%eax),%edx
  8005a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a4:	8b 50 04             	mov    0x4(%eax),%edx
  8005a7:	8b 00                	mov    (%eax),%eax
  8005a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ac:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005af:	eb 32                	jmp    8005e3 <vprintfmt+0x2d1>
	else if (lflag)
  8005b1:	85 d2                	test   %edx,%edx
  8005b3:	74 18                	je     8005cd <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8d 50 04             	lea    0x4(%eax),%edx
  8005bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005be:	8b 00                	mov    (%eax),%eax
  8005c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c3:	89 c1                	mov    %eax,%ecx
  8005c5:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005cb:	eb 16                	jmp    8005e3 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8d 50 04             	lea    0x4(%eax),%edx
  8005d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d6:	8b 00                	mov    (%eax),%eax
  8005d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005db:	89 c1                	mov    %eax,%ecx
  8005dd:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005e3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005e6:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ee:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005f2:	79 74                	jns    800668 <vprintfmt+0x356>
				putch('-', putdat);
  8005f4:	83 ec 08             	sub    $0x8,%esp
  8005f7:	53                   	push   %ebx
  8005f8:	6a 2d                	push   $0x2d
  8005fa:	ff d6                	call   *%esi
				num = -(long long) num;
  8005fc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ff:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800602:	f7 d8                	neg    %eax
  800604:	83 d2 00             	adc    $0x0,%edx
  800607:	f7 da                	neg    %edx
  800609:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80060c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800611:	eb 55                	jmp    800668 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800613:	8d 45 14             	lea    0x14(%ebp),%eax
  800616:	e8 83 fc ff ff       	call   80029e <getuint>
			base = 10;
  80061b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800620:	eb 46                	jmp    800668 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800622:	8d 45 14             	lea    0x14(%ebp),%eax
  800625:	e8 74 fc ff ff       	call   80029e <getuint>
			base = 8;
  80062a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80062f:	eb 37                	jmp    800668 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800631:	83 ec 08             	sub    $0x8,%esp
  800634:	53                   	push   %ebx
  800635:	6a 30                	push   $0x30
  800637:	ff d6                	call   *%esi
			putch('x', putdat);
  800639:	83 c4 08             	add    $0x8,%esp
  80063c:	53                   	push   %ebx
  80063d:	6a 78                	push   $0x78
  80063f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8d 50 04             	lea    0x4(%eax),%edx
  800647:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80064a:	8b 00                	mov    (%eax),%eax
  80064c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800651:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800654:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800659:	eb 0d                	jmp    800668 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80065b:	8d 45 14             	lea    0x14(%ebp),%eax
  80065e:	e8 3b fc ff ff       	call   80029e <getuint>
			base = 16;
  800663:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800668:	83 ec 0c             	sub    $0xc,%esp
  80066b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80066f:	57                   	push   %edi
  800670:	ff 75 e0             	pushl  -0x20(%ebp)
  800673:	51                   	push   %ecx
  800674:	52                   	push   %edx
  800675:	50                   	push   %eax
  800676:	89 da                	mov    %ebx,%edx
  800678:	89 f0                	mov    %esi,%eax
  80067a:	e8 70 fb ff ff       	call   8001ef <printnum>
			break;
  80067f:	83 c4 20             	add    $0x20,%esp
  800682:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800685:	e9 ae fc ff ff       	jmp    800338 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80068a:	83 ec 08             	sub    $0x8,%esp
  80068d:	53                   	push   %ebx
  80068e:	51                   	push   %ecx
  80068f:	ff d6                	call   *%esi
			break;
  800691:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800694:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800697:	e9 9c fc ff ff       	jmp    800338 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80069c:	83 ec 08             	sub    $0x8,%esp
  80069f:	53                   	push   %ebx
  8006a0:	6a 25                	push   $0x25
  8006a2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a4:	83 c4 10             	add    $0x10,%esp
  8006a7:	eb 03                	jmp    8006ac <vprintfmt+0x39a>
  8006a9:	83 ef 01             	sub    $0x1,%edi
  8006ac:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006b0:	75 f7                	jne    8006a9 <vprintfmt+0x397>
  8006b2:	e9 81 fc ff ff       	jmp    800338 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ba:	5b                   	pop    %ebx
  8006bb:	5e                   	pop    %esi
  8006bc:	5f                   	pop    %edi
  8006bd:	5d                   	pop    %ebp
  8006be:	c3                   	ret    

008006bf <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006bf:	55                   	push   %ebp
  8006c0:	89 e5                	mov    %esp,%ebp
  8006c2:	83 ec 18             	sub    $0x18,%esp
  8006c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ce:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006dc:	85 c0                	test   %eax,%eax
  8006de:	74 26                	je     800706 <vsnprintf+0x47>
  8006e0:	85 d2                	test   %edx,%edx
  8006e2:	7e 22                	jle    800706 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e4:	ff 75 14             	pushl  0x14(%ebp)
  8006e7:	ff 75 10             	pushl  0x10(%ebp)
  8006ea:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ed:	50                   	push   %eax
  8006ee:	68 d8 02 80 00       	push   $0x8002d8
  8006f3:	e8 1a fc ff ff       	call   800312 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006fb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800701:	83 c4 10             	add    $0x10,%esp
  800704:	eb 05                	jmp    80070b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800706:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80070b:	c9                   	leave  
  80070c:	c3                   	ret    

0080070d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800713:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800716:	50                   	push   %eax
  800717:	ff 75 10             	pushl  0x10(%ebp)
  80071a:	ff 75 0c             	pushl  0xc(%ebp)
  80071d:	ff 75 08             	pushl  0x8(%ebp)
  800720:	e8 9a ff ff ff       	call   8006bf <vsnprintf>
	va_end(ap);

	return rc;
}
  800725:	c9                   	leave  
  800726:	c3                   	ret    

00800727 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80072d:	b8 00 00 00 00       	mov    $0x0,%eax
  800732:	eb 03                	jmp    800737 <strlen+0x10>
		n++;
  800734:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800737:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80073b:	75 f7                	jne    800734 <strlen+0xd>
		n++;
	return n;
}
  80073d:	5d                   	pop    %ebp
  80073e:	c3                   	ret    

0080073f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800745:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800748:	ba 00 00 00 00       	mov    $0x0,%edx
  80074d:	eb 03                	jmp    800752 <strnlen+0x13>
		n++;
  80074f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800752:	39 c2                	cmp    %eax,%edx
  800754:	74 08                	je     80075e <strnlen+0x1f>
  800756:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80075a:	75 f3                	jne    80074f <strnlen+0x10>
  80075c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80075e:	5d                   	pop    %ebp
  80075f:	c3                   	ret    

00800760 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	53                   	push   %ebx
  800764:	8b 45 08             	mov    0x8(%ebp),%eax
  800767:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80076a:	89 c2                	mov    %eax,%edx
  80076c:	83 c2 01             	add    $0x1,%edx
  80076f:	83 c1 01             	add    $0x1,%ecx
  800772:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800776:	88 5a ff             	mov    %bl,-0x1(%edx)
  800779:	84 db                	test   %bl,%bl
  80077b:	75 ef                	jne    80076c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80077d:	5b                   	pop    %ebx
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	53                   	push   %ebx
  800784:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800787:	53                   	push   %ebx
  800788:	e8 9a ff ff ff       	call   800727 <strlen>
  80078d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800790:	ff 75 0c             	pushl  0xc(%ebp)
  800793:	01 d8                	add    %ebx,%eax
  800795:	50                   	push   %eax
  800796:	e8 c5 ff ff ff       	call   800760 <strcpy>
	return dst;
}
  80079b:	89 d8                	mov    %ebx,%eax
  80079d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a0:	c9                   	leave  
  8007a1:	c3                   	ret    

008007a2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	56                   	push   %esi
  8007a6:	53                   	push   %ebx
  8007a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ad:	89 f3                	mov    %esi,%ebx
  8007af:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b2:	89 f2                	mov    %esi,%edx
  8007b4:	eb 0f                	jmp    8007c5 <strncpy+0x23>
		*dst++ = *src;
  8007b6:	83 c2 01             	add    $0x1,%edx
  8007b9:	0f b6 01             	movzbl (%ecx),%eax
  8007bc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007bf:	80 39 01             	cmpb   $0x1,(%ecx)
  8007c2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c5:	39 da                	cmp    %ebx,%edx
  8007c7:	75 ed                	jne    8007b6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c9:	89 f0                	mov    %esi,%eax
  8007cb:	5b                   	pop    %ebx
  8007cc:	5e                   	pop    %esi
  8007cd:	5d                   	pop    %ebp
  8007ce:	c3                   	ret    

008007cf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	56                   	push   %esi
  8007d3:	53                   	push   %ebx
  8007d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007da:	8b 55 10             	mov    0x10(%ebp),%edx
  8007dd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007df:	85 d2                	test   %edx,%edx
  8007e1:	74 21                	je     800804 <strlcpy+0x35>
  8007e3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007e7:	89 f2                	mov    %esi,%edx
  8007e9:	eb 09                	jmp    8007f4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007eb:	83 c2 01             	add    $0x1,%edx
  8007ee:	83 c1 01             	add    $0x1,%ecx
  8007f1:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007f4:	39 c2                	cmp    %eax,%edx
  8007f6:	74 09                	je     800801 <strlcpy+0x32>
  8007f8:	0f b6 19             	movzbl (%ecx),%ebx
  8007fb:	84 db                	test   %bl,%bl
  8007fd:	75 ec                	jne    8007eb <strlcpy+0x1c>
  8007ff:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800801:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800804:	29 f0                	sub    %esi,%eax
}
  800806:	5b                   	pop    %ebx
  800807:	5e                   	pop    %esi
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800810:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800813:	eb 06                	jmp    80081b <strcmp+0x11>
		p++, q++;
  800815:	83 c1 01             	add    $0x1,%ecx
  800818:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80081b:	0f b6 01             	movzbl (%ecx),%eax
  80081e:	84 c0                	test   %al,%al
  800820:	74 04                	je     800826 <strcmp+0x1c>
  800822:	3a 02                	cmp    (%edx),%al
  800824:	74 ef                	je     800815 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800826:	0f b6 c0             	movzbl %al,%eax
  800829:	0f b6 12             	movzbl (%edx),%edx
  80082c:	29 d0                	sub    %edx,%eax
}
  80082e:	5d                   	pop    %ebp
  80082f:	c3                   	ret    

00800830 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	53                   	push   %ebx
  800834:	8b 45 08             	mov    0x8(%ebp),%eax
  800837:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083a:	89 c3                	mov    %eax,%ebx
  80083c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80083f:	eb 06                	jmp    800847 <strncmp+0x17>
		n--, p++, q++;
  800841:	83 c0 01             	add    $0x1,%eax
  800844:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800847:	39 d8                	cmp    %ebx,%eax
  800849:	74 15                	je     800860 <strncmp+0x30>
  80084b:	0f b6 08             	movzbl (%eax),%ecx
  80084e:	84 c9                	test   %cl,%cl
  800850:	74 04                	je     800856 <strncmp+0x26>
  800852:	3a 0a                	cmp    (%edx),%cl
  800854:	74 eb                	je     800841 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800856:	0f b6 00             	movzbl (%eax),%eax
  800859:	0f b6 12             	movzbl (%edx),%edx
  80085c:	29 d0                	sub    %edx,%eax
  80085e:	eb 05                	jmp    800865 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800860:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800865:	5b                   	pop    %ebx
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	8b 45 08             	mov    0x8(%ebp),%eax
  80086e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800872:	eb 07                	jmp    80087b <strchr+0x13>
		if (*s == c)
  800874:	38 ca                	cmp    %cl,%dl
  800876:	74 0f                	je     800887 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800878:	83 c0 01             	add    $0x1,%eax
  80087b:	0f b6 10             	movzbl (%eax),%edx
  80087e:	84 d2                	test   %dl,%dl
  800880:	75 f2                	jne    800874 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800882:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800887:	5d                   	pop    %ebp
  800888:	c3                   	ret    

00800889 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	8b 45 08             	mov    0x8(%ebp),%eax
  80088f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800893:	eb 03                	jmp    800898 <strfind+0xf>
  800895:	83 c0 01             	add    $0x1,%eax
  800898:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80089b:	38 ca                	cmp    %cl,%dl
  80089d:	74 04                	je     8008a3 <strfind+0x1a>
  80089f:	84 d2                	test   %dl,%dl
  8008a1:	75 f2                	jne    800895 <strfind+0xc>
			break;
	return (char *) s;
}
  8008a3:	5d                   	pop    %ebp
  8008a4:	c3                   	ret    

008008a5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	57                   	push   %edi
  8008a9:	56                   	push   %esi
  8008aa:	53                   	push   %ebx
  8008ab:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008b1:	85 c9                	test   %ecx,%ecx
  8008b3:	74 36                	je     8008eb <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008b5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008bb:	75 28                	jne    8008e5 <memset+0x40>
  8008bd:	f6 c1 03             	test   $0x3,%cl
  8008c0:	75 23                	jne    8008e5 <memset+0x40>
		c &= 0xFF;
  8008c2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008c6:	89 d3                	mov    %edx,%ebx
  8008c8:	c1 e3 08             	shl    $0x8,%ebx
  8008cb:	89 d6                	mov    %edx,%esi
  8008cd:	c1 e6 18             	shl    $0x18,%esi
  8008d0:	89 d0                	mov    %edx,%eax
  8008d2:	c1 e0 10             	shl    $0x10,%eax
  8008d5:	09 f0                	or     %esi,%eax
  8008d7:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008d9:	89 d8                	mov    %ebx,%eax
  8008db:	09 d0                	or     %edx,%eax
  8008dd:	c1 e9 02             	shr    $0x2,%ecx
  8008e0:	fc                   	cld    
  8008e1:	f3 ab                	rep stos %eax,%es:(%edi)
  8008e3:	eb 06                	jmp    8008eb <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e8:	fc                   	cld    
  8008e9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008eb:	89 f8                	mov    %edi,%eax
  8008ed:	5b                   	pop    %ebx
  8008ee:	5e                   	pop    %esi
  8008ef:	5f                   	pop    %edi
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	57                   	push   %edi
  8008f6:	56                   	push   %esi
  8008f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fa:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800900:	39 c6                	cmp    %eax,%esi
  800902:	73 35                	jae    800939 <memmove+0x47>
  800904:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800907:	39 d0                	cmp    %edx,%eax
  800909:	73 2e                	jae    800939 <memmove+0x47>
		s += n;
		d += n;
  80090b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090e:	89 d6                	mov    %edx,%esi
  800910:	09 fe                	or     %edi,%esi
  800912:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800918:	75 13                	jne    80092d <memmove+0x3b>
  80091a:	f6 c1 03             	test   $0x3,%cl
  80091d:	75 0e                	jne    80092d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80091f:	83 ef 04             	sub    $0x4,%edi
  800922:	8d 72 fc             	lea    -0x4(%edx),%esi
  800925:	c1 e9 02             	shr    $0x2,%ecx
  800928:	fd                   	std    
  800929:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092b:	eb 09                	jmp    800936 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80092d:	83 ef 01             	sub    $0x1,%edi
  800930:	8d 72 ff             	lea    -0x1(%edx),%esi
  800933:	fd                   	std    
  800934:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800936:	fc                   	cld    
  800937:	eb 1d                	jmp    800956 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800939:	89 f2                	mov    %esi,%edx
  80093b:	09 c2                	or     %eax,%edx
  80093d:	f6 c2 03             	test   $0x3,%dl
  800940:	75 0f                	jne    800951 <memmove+0x5f>
  800942:	f6 c1 03             	test   $0x3,%cl
  800945:	75 0a                	jne    800951 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800947:	c1 e9 02             	shr    $0x2,%ecx
  80094a:	89 c7                	mov    %eax,%edi
  80094c:	fc                   	cld    
  80094d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094f:	eb 05                	jmp    800956 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800951:	89 c7                	mov    %eax,%edi
  800953:	fc                   	cld    
  800954:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800956:	5e                   	pop    %esi
  800957:	5f                   	pop    %edi
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80095d:	ff 75 10             	pushl  0x10(%ebp)
  800960:	ff 75 0c             	pushl  0xc(%ebp)
  800963:	ff 75 08             	pushl  0x8(%ebp)
  800966:	e8 87 ff ff ff       	call   8008f2 <memmove>
}
  80096b:	c9                   	leave  
  80096c:	c3                   	ret    

0080096d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	56                   	push   %esi
  800971:	53                   	push   %ebx
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	8b 55 0c             	mov    0xc(%ebp),%edx
  800978:	89 c6                	mov    %eax,%esi
  80097a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097d:	eb 1a                	jmp    800999 <memcmp+0x2c>
		if (*s1 != *s2)
  80097f:	0f b6 08             	movzbl (%eax),%ecx
  800982:	0f b6 1a             	movzbl (%edx),%ebx
  800985:	38 d9                	cmp    %bl,%cl
  800987:	74 0a                	je     800993 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800989:	0f b6 c1             	movzbl %cl,%eax
  80098c:	0f b6 db             	movzbl %bl,%ebx
  80098f:	29 d8                	sub    %ebx,%eax
  800991:	eb 0f                	jmp    8009a2 <memcmp+0x35>
		s1++, s2++;
  800993:	83 c0 01             	add    $0x1,%eax
  800996:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800999:	39 f0                	cmp    %esi,%eax
  80099b:	75 e2                	jne    80097f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80099d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a2:	5b                   	pop    %ebx
  8009a3:	5e                   	pop    %esi
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	53                   	push   %ebx
  8009aa:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009ad:	89 c1                	mov    %eax,%ecx
  8009af:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b6:	eb 0a                	jmp    8009c2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b8:	0f b6 10             	movzbl (%eax),%edx
  8009bb:	39 da                	cmp    %ebx,%edx
  8009bd:	74 07                	je     8009c6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009bf:	83 c0 01             	add    $0x1,%eax
  8009c2:	39 c8                	cmp    %ecx,%eax
  8009c4:	72 f2                	jb     8009b8 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009c6:	5b                   	pop    %ebx
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	57                   	push   %edi
  8009cd:	56                   	push   %esi
  8009ce:	53                   	push   %ebx
  8009cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d5:	eb 03                	jmp    8009da <strtol+0x11>
		s++;
  8009d7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009da:	0f b6 01             	movzbl (%ecx),%eax
  8009dd:	3c 20                	cmp    $0x20,%al
  8009df:	74 f6                	je     8009d7 <strtol+0xe>
  8009e1:	3c 09                	cmp    $0x9,%al
  8009e3:	74 f2                	je     8009d7 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009e5:	3c 2b                	cmp    $0x2b,%al
  8009e7:	75 0a                	jne    8009f3 <strtol+0x2a>
		s++;
  8009e9:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ec:	bf 00 00 00 00       	mov    $0x0,%edi
  8009f1:	eb 11                	jmp    800a04 <strtol+0x3b>
  8009f3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009f8:	3c 2d                	cmp    $0x2d,%al
  8009fa:	75 08                	jne    800a04 <strtol+0x3b>
		s++, neg = 1;
  8009fc:	83 c1 01             	add    $0x1,%ecx
  8009ff:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a04:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a0a:	75 15                	jne    800a21 <strtol+0x58>
  800a0c:	80 39 30             	cmpb   $0x30,(%ecx)
  800a0f:	75 10                	jne    800a21 <strtol+0x58>
  800a11:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a15:	75 7c                	jne    800a93 <strtol+0xca>
		s += 2, base = 16;
  800a17:	83 c1 02             	add    $0x2,%ecx
  800a1a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a1f:	eb 16                	jmp    800a37 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a21:	85 db                	test   %ebx,%ebx
  800a23:	75 12                	jne    800a37 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a25:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a2a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a2d:	75 08                	jne    800a37 <strtol+0x6e>
		s++, base = 8;
  800a2f:	83 c1 01             	add    $0x1,%ecx
  800a32:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a37:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a3f:	0f b6 11             	movzbl (%ecx),%edx
  800a42:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a45:	89 f3                	mov    %esi,%ebx
  800a47:	80 fb 09             	cmp    $0x9,%bl
  800a4a:	77 08                	ja     800a54 <strtol+0x8b>
			dig = *s - '0';
  800a4c:	0f be d2             	movsbl %dl,%edx
  800a4f:	83 ea 30             	sub    $0x30,%edx
  800a52:	eb 22                	jmp    800a76 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a54:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a57:	89 f3                	mov    %esi,%ebx
  800a59:	80 fb 19             	cmp    $0x19,%bl
  800a5c:	77 08                	ja     800a66 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a5e:	0f be d2             	movsbl %dl,%edx
  800a61:	83 ea 57             	sub    $0x57,%edx
  800a64:	eb 10                	jmp    800a76 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a66:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a69:	89 f3                	mov    %esi,%ebx
  800a6b:	80 fb 19             	cmp    $0x19,%bl
  800a6e:	77 16                	ja     800a86 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a70:	0f be d2             	movsbl %dl,%edx
  800a73:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a76:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a79:	7d 0b                	jge    800a86 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a7b:	83 c1 01             	add    $0x1,%ecx
  800a7e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a82:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a84:	eb b9                	jmp    800a3f <strtol+0x76>

	if (endptr)
  800a86:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a8a:	74 0d                	je     800a99 <strtol+0xd0>
		*endptr = (char *) s;
  800a8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8f:	89 0e                	mov    %ecx,(%esi)
  800a91:	eb 06                	jmp    800a99 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a93:	85 db                	test   %ebx,%ebx
  800a95:	74 98                	je     800a2f <strtol+0x66>
  800a97:	eb 9e                	jmp    800a37 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a99:	89 c2                	mov    %eax,%edx
  800a9b:	f7 da                	neg    %edx
  800a9d:	85 ff                	test   %edi,%edi
  800a9f:	0f 45 c2             	cmovne %edx,%eax
}
  800aa2:	5b                   	pop    %ebx
  800aa3:	5e                   	pop    %esi
  800aa4:	5f                   	pop    %edi
  800aa5:	5d                   	pop    %ebp
  800aa6:	c3                   	ret    

00800aa7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	57                   	push   %edi
  800aab:	56                   	push   %esi
  800aac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aad:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab8:	89 c3                	mov    %eax,%ebx
  800aba:	89 c7                	mov    %eax,%edi
  800abc:	89 c6                	mov    %eax,%esi
  800abe:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ac0:	5b                   	pop    %ebx
  800ac1:	5e                   	pop    %esi
  800ac2:	5f                   	pop    %edi
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	57                   	push   %edi
  800ac9:	56                   	push   %esi
  800aca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad5:	89 d1                	mov    %edx,%ecx
  800ad7:	89 d3                	mov    %edx,%ebx
  800ad9:	89 d7                	mov    %edx,%edi
  800adb:	89 d6                	mov    %edx,%esi
  800add:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800adf:	5b                   	pop    %ebx
  800ae0:	5e                   	pop    %esi
  800ae1:	5f                   	pop    %edi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	57                   	push   %edi
  800ae8:	56                   	push   %esi
  800ae9:	53                   	push   %ebx
  800aea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aed:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af2:	b8 03 00 00 00       	mov    $0x3,%eax
  800af7:	8b 55 08             	mov    0x8(%ebp),%edx
  800afa:	89 cb                	mov    %ecx,%ebx
  800afc:	89 cf                	mov    %ecx,%edi
  800afe:	89 ce                	mov    %ecx,%esi
  800b00:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b02:	85 c0                	test   %eax,%eax
  800b04:	7e 17                	jle    800b1d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b06:	83 ec 0c             	sub    $0xc,%esp
  800b09:	50                   	push   %eax
  800b0a:	6a 03                	push   $0x3
  800b0c:	68 24 15 80 00       	push   $0x801524
  800b11:	6a 23                	push   $0x23
  800b13:	68 41 15 80 00       	push   $0x801541
  800b18:	e8 4f 04 00 00       	call   800f6c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5f                   	pop    %edi
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	57                   	push   %edi
  800b29:	56                   	push   %esi
  800b2a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b30:	b8 02 00 00 00       	mov    $0x2,%eax
  800b35:	89 d1                	mov    %edx,%ecx
  800b37:	89 d3                	mov    %edx,%ebx
  800b39:	89 d7                	mov    %edx,%edi
  800b3b:	89 d6                	mov    %edx,%esi
  800b3d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b3f:	5b                   	pop    %ebx
  800b40:	5e                   	pop    %esi
  800b41:	5f                   	pop    %edi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <sys_yield>:

void
sys_yield(void)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b54:	89 d1                	mov    %edx,%ecx
  800b56:	89 d3                	mov    %edx,%ebx
  800b58:	89 d7                	mov    %edx,%edi
  800b5a:	89 d6                	mov    %edx,%esi
  800b5c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b5e:	5b                   	pop    %ebx
  800b5f:	5e                   	pop    %esi
  800b60:	5f                   	pop    %edi
  800b61:	5d                   	pop    %ebp
  800b62:	c3                   	ret    

00800b63 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	57                   	push   %edi
  800b67:	56                   	push   %esi
  800b68:	53                   	push   %ebx
  800b69:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6c:	be 00 00 00 00       	mov    $0x0,%esi
  800b71:	b8 04 00 00 00       	mov    $0x4,%eax
  800b76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b79:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b7f:	89 f7                	mov    %esi,%edi
  800b81:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b83:	85 c0                	test   %eax,%eax
  800b85:	7e 17                	jle    800b9e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b87:	83 ec 0c             	sub    $0xc,%esp
  800b8a:	50                   	push   %eax
  800b8b:	6a 04                	push   $0x4
  800b8d:	68 24 15 80 00       	push   $0x801524
  800b92:	6a 23                	push   $0x23
  800b94:	68 41 15 80 00       	push   $0x801541
  800b99:	e8 ce 03 00 00       	call   800f6c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba1:	5b                   	pop    %ebx
  800ba2:	5e                   	pop    %esi
  800ba3:	5f                   	pop    %edi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	57                   	push   %edi
  800baa:	56                   	push   %esi
  800bab:	53                   	push   %ebx
  800bac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baf:	b8 05 00 00 00       	mov    $0x5,%eax
  800bb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bbd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bc0:	8b 75 18             	mov    0x18(%ebp),%esi
  800bc3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc5:	85 c0                	test   %eax,%eax
  800bc7:	7e 17                	jle    800be0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc9:	83 ec 0c             	sub    $0xc,%esp
  800bcc:	50                   	push   %eax
  800bcd:	6a 05                	push   $0x5
  800bcf:	68 24 15 80 00       	push   $0x801524
  800bd4:	6a 23                	push   $0x23
  800bd6:	68 41 15 80 00       	push   $0x801541
  800bdb:	e8 8c 03 00 00       	call   800f6c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800be0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be3:	5b                   	pop    %ebx
  800be4:	5e                   	pop    %esi
  800be5:	5f                   	pop    %edi
  800be6:	5d                   	pop    %ebp
  800be7:	c3                   	ret    

00800be8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	57                   	push   %edi
  800bec:	56                   	push   %esi
  800bed:	53                   	push   %ebx
  800bee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf6:	b8 06 00 00 00       	mov    $0x6,%eax
  800bfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800c01:	89 df                	mov    %ebx,%edi
  800c03:	89 de                	mov    %ebx,%esi
  800c05:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c07:	85 c0                	test   %eax,%eax
  800c09:	7e 17                	jle    800c22 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0b:	83 ec 0c             	sub    $0xc,%esp
  800c0e:	50                   	push   %eax
  800c0f:	6a 06                	push   $0x6
  800c11:	68 24 15 80 00       	push   $0x801524
  800c16:	6a 23                	push   $0x23
  800c18:	68 41 15 80 00       	push   $0x801541
  800c1d:	e8 4a 03 00 00       	call   800f6c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c25:	5b                   	pop    %ebx
  800c26:	5e                   	pop    %esi
  800c27:	5f                   	pop    %edi
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    

00800c2a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	57                   	push   %edi
  800c2e:	56                   	push   %esi
  800c2f:	53                   	push   %ebx
  800c30:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c38:	b8 08 00 00 00       	mov    $0x8,%eax
  800c3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c40:	8b 55 08             	mov    0x8(%ebp),%edx
  800c43:	89 df                	mov    %ebx,%edi
  800c45:	89 de                	mov    %ebx,%esi
  800c47:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c49:	85 c0                	test   %eax,%eax
  800c4b:	7e 17                	jle    800c64 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4d:	83 ec 0c             	sub    $0xc,%esp
  800c50:	50                   	push   %eax
  800c51:	6a 08                	push   $0x8
  800c53:	68 24 15 80 00       	push   $0x801524
  800c58:	6a 23                	push   $0x23
  800c5a:	68 41 15 80 00       	push   $0x801541
  800c5f:	e8 08 03 00 00       	call   800f6c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c67:	5b                   	pop    %ebx
  800c68:	5e                   	pop    %esi
  800c69:	5f                   	pop    %edi
  800c6a:	5d                   	pop    %ebp
  800c6b:	c3                   	ret    

00800c6c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	57                   	push   %edi
  800c70:	56                   	push   %esi
  800c71:	53                   	push   %ebx
  800c72:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7a:	b8 09 00 00 00       	mov    $0x9,%eax
  800c7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c82:	8b 55 08             	mov    0x8(%ebp),%edx
  800c85:	89 df                	mov    %ebx,%edi
  800c87:	89 de                	mov    %ebx,%esi
  800c89:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8b:	85 c0                	test   %eax,%eax
  800c8d:	7e 17                	jle    800ca6 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8f:	83 ec 0c             	sub    $0xc,%esp
  800c92:	50                   	push   %eax
  800c93:	6a 09                	push   $0x9
  800c95:	68 24 15 80 00       	push   $0x801524
  800c9a:	6a 23                	push   $0x23
  800c9c:	68 41 15 80 00       	push   $0x801541
  800ca1:	e8 c6 02 00 00       	call   800f6c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca9:	5b                   	pop    %ebx
  800caa:	5e                   	pop    %esi
  800cab:	5f                   	pop    %edi
  800cac:	5d                   	pop    %ebp
  800cad:	c3                   	ret    

00800cae <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	57                   	push   %edi
  800cb2:	56                   	push   %esi
  800cb3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb4:	be 00 00 00 00       	mov    $0x0,%esi
  800cb9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cca:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
  800cd7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cda:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cdf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ce4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce7:	89 cb                	mov    %ecx,%ebx
  800ce9:	89 cf                	mov    %ecx,%edi
  800ceb:	89 ce                	mov    %ecx,%esi
  800ced:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cef:	85 c0                	test   %eax,%eax
  800cf1:	7e 17                	jle    800d0a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf3:	83 ec 0c             	sub    $0xc,%esp
  800cf6:	50                   	push   %eax
  800cf7:	6a 0c                	push   $0xc
  800cf9:	68 24 15 80 00       	push   $0x801524
  800cfe:	6a 23                	push   $0x23
  800d00:	68 41 15 80 00       	push   $0x801541
  800d05:	e8 62 02 00 00       	call   800f6c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0d:	5b                   	pop    %ebx
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	56                   	push   %esi
  800d16:	53                   	push   %ebx
  800d17:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d1a:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800d1c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d20:	75 25                	jne    800d47 <pgfault+0x35>
  800d22:	89 d8                	mov    %ebx,%eax
  800d24:	c1 e8 0c             	shr    $0xc,%eax
  800d27:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d2e:	f6 c4 08             	test   $0x8,%ah
  800d31:	75 14                	jne    800d47 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800d33:	83 ec 04             	sub    $0x4,%esp
  800d36:	68 50 15 80 00       	push   $0x801550
  800d3b:	6a 1e                	push   $0x1e
  800d3d:	68 e4 15 80 00       	push   $0x8015e4
  800d42:	e8 25 02 00 00       	call   800f6c <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800d47:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800d4d:	e8 d3 fd ff ff       	call   800b25 <sys_getenvid>
  800d52:	89 c6                	mov    %eax,%esi

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800d54:	83 ec 04             	sub    $0x4,%esp
  800d57:	6a 07                	push   $0x7
  800d59:	68 00 f0 7f 00       	push   $0x7ff000
  800d5e:	50                   	push   %eax
  800d5f:	e8 ff fd ff ff       	call   800b63 <sys_page_alloc>
	if (r < 0)
  800d64:	83 c4 10             	add    $0x10,%esp
  800d67:	85 c0                	test   %eax,%eax
  800d69:	79 12                	jns    800d7d <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800d6b:	50                   	push   %eax
  800d6c:	68 7c 15 80 00       	push   $0x80157c
  800d71:	6a 31                	push   $0x31
  800d73:	68 e4 15 80 00       	push   $0x8015e4
  800d78:	e8 ef 01 00 00       	call   800f6c <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800d7d:	83 ec 04             	sub    $0x4,%esp
  800d80:	68 00 10 00 00       	push   $0x1000
  800d85:	53                   	push   %ebx
  800d86:	68 00 f0 7f 00       	push   $0x7ff000
  800d8b:	e8 ca fb ff ff       	call   80095a <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800d90:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800d97:	53                   	push   %ebx
  800d98:	56                   	push   %esi
  800d99:	68 00 f0 7f 00       	push   $0x7ff000
  800d9e:	56                   	push   %esi
  800d9f:	e8 02 fe ff ff       	call   800ba6 <sys_page_map>
	if (r < 0)
  800da4:	83 c4 20             	add    $0x20,%esp
  800da7:	85 c0                	test   %eax,%eax
  800da9:	79 12                	jns    800dbd <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800dab:	50                   	push   %eax
  800dac:	68 a0 15 80 00       	push   $0x8015a0
  800db1:	6a 39                	push   $0x39
  800db3:	68 e4 15 80 00       	push   $0x8015e4
  800db8:	e8 af 01 00 00       	call   800f6c <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800dbd:	83 ec 08             	sub    $0x8,%esp
  800dc0:	68 00 f0 7f 00       	push   $0x7ff000
  800dc5:	56                   	push   %esi
  800dc6:	e8 1d fe ff ff       	call   800be8 <sys_page_unmap>
	if (r < 0)
  800dcb:	83 c4 10             	add    $0x10,%esp
  800dce:	85 c0                	test   %eax,%eax
  800dd0:	79 12                	jns    800de4 <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800dd2:	50                   	push   %eax
  800dd3:	68 c4 15 80 00       	push   $0x8015c4
  800dd8:	6a 3e                	push   $0x3e
  800dda:	68 e4 15 80 00       	push   $0x8015e4
  800ddf:	e8 88 01 00 00       	call   800f6c <_panic>
}
  800de4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800de7:	5b                   	pop    %ebx
  800de8:	5e                   	pop    %esi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	57                   	push   %edi
  800def:	56                   	push   %esi
  800df0:	53                   	push   %ebx
  800df1:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800df4:	68 12 0d 80 00       	push   $0x800d12
  800df9:	e8 b4 01 00 00       	call   800fb2 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800dfe:	b8 07 00 00 00       	mov    $0x7,%eax
  800e03:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800e05:	83 c4 10             	add    $0x10,%esp
  800e08:	85 c0                	test   %eax,%eax
  800e0a:	0f 88 3a 01 00 00    	js     800f4a <fork+0x15f>
  800e10:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800e15:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800e1a:	85 c0                	test   %eax,%eax
  800e1c:	75 21                	jne    800e3f <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e1e:	e8 02 fd ff ff       	call   800b25 <sys_getenvid>
  800e23:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e28:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e2b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e30:	a3 04 20 80 00       	mov    %eax,0x802004
        return 0;
  800e35:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3a:	e9 0b 01 00 00       	jmp    800f4a <fork+0x15f>
  800e3f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e42:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800e44:	89 d8                	mov    %ebx,%eax
  800e46:	c1 e8 16             	shr    $0x16,%eax
  800e49:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e50:	a8 01                	test   $0x1,%al
  800e52:	0f 84 99 00 00 00    	je     800ef1 <fork+0x106>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800e58:	89 d8                	mov    %ebx,%eax
  800e5a:	c1 e8 0c             	shr    $0xc,%eax
  800e5d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e64:	f6 c2 01             	test   $0x1,%dl
  800e67:	0f 84 84 00 00 00    	je     800ef1 <fork+0x106>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
  800e6d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e74:	a9 02 08 00 00       	test   $0x802,%eax
  800e79:	74 76                	je     800ef1 <fork+0x106>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;
	
	if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800e7b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800e82:	a8 02                	test   $0x2,%al
  800e84:	75 0c                	jne    800e92 <fork+0xa7>
  800e86:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800e8d:	f6 c4 08             	test   $0x8,%ah
  800e90:	74 3f                	je     800ed1 <fork+0xe6>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800e92:	83 ec 0c             	sub    $0xc,%esp
  800e95:	68 05 08 00 00       	push   $0x805
  800e9a:	53                   	push   %ebx
  800e9b:	57                   	push   %edi
  800e9c:	53                   	push   %ebx
  800e9d:	6a 00                	push   $0x0
  800e9f:	e8 02 fd ff ff       	call   800ba6 <sys_page_map>
		if (r < 0)
  800ea4:	83 c4 20             	add    $0x20,%esp
  800ea7:	85 c0                	test   %eax,%eax
  800ea9:	0f 88 9b 00 00 00    	js     800f4a <fork+0x15f>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800eaf:	83 ec 0c             	sub    $0xc,%esp
  800eb2:	68 05 08 00 00       	push   $0x805
  800eb7:	53                   	push   %ebx
  800eb8:	6a 00                	push   $0x0
  800eba:	53                   	push   %ebx
  800ebb:	6a 00                	push   $0x0
  800ebd:	e8 e4 fc ff ff       	call   800ba6 <sys_page_map>
  800ec2:	83 c4 20             	add    $0x20,%esp
  800ec5:	85 c0                	test   %eax,%eax
  800ec7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ecc:	0f 4f c1             	cmovg  %ecx,%eax
  800ecf:	eb 1c                	jmp    800eed <fork+0x102>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800ed1:	83 ec 0c             	sub    $0xc,%esp
  800ed4:	6a 05                	push   $0x5
  800ed6:	53                   	push   %ebx
  800ed7:	57                   	push   %edi
  800ed8:	53                   	push   %ebx
  800ed9:	6a 00                	push   $0x0
  800edb:	e8 c6 fc ff ff       	call   800ba6 <sys_page_map>
  800ee0:	83 c4 20             	add    $0x20,%esp
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eea:	0f 4f c1             	cmovg  %ecx,%eax
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  800eed:	85 c0                	test   %eax,%eax
  800eef:	78 59                	js     800f4a <fork+0x15f>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  800ef1:	83 c6 01             	add    $0x1,%esi
  800ef4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800efa:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  800f00:	0f 85 3e ff ff ff    	jne    800e44 <fork+0x59>
  800f06:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  800f09:	83 ec 04             	sub    $0x4,%esp
  800f0c:	6a 07                	push   $0x7
  800f0e:	68 00 f0 bf ee       	push   $0xeebff000
  800f13:	57                   	push   %edi
  800f14:	e8 4a fc ff ff       	call   800b63 <sys_page_alloc>
	if (r < 0)
  800f19:	83 c4 10             	add    $0x10,%esp
  800f1c:	85 c0                	test   %eax,%eax
  800f1e:	78 2a                	js     800f4a <fork+0x15f>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800f20:	83 ec 08             	sub    $0x8,%esp
  800f23:	68 f9 0f 80 00       	push   $0x800ff9
  800f28:	57                   	push   %edi
  800f29:	e8 3e fd ff ff       	call   800c6c <sys_env_set_pgfault_upcall>
	if (r < 0)
  800f2e:	83 c4 10             	add    $0x10,%esp
  800f31:	85 c0                	test   %eax,%eax
  800f33:	78 15                	js     800f4a <fork+0x15f>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  800f35:	83 ec 08             	sub    $0x8,%esp
  800f38:	6a 02                	push   $0x2
  800f3a:	57                   	push   %edi
  800f3b:	e8 ea fc ff ff       	call   800c2a <sys_env_set_status>
	if (r < 0)
  800f40:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  800f43:	85 c0                	test   %eax,%eax
  800f45:	0f 49 c7             	cmovns %edi,%eax
  800f48:	eb 00                	jmp    800f4a <fork+0x15f>
	// panic("fork not implemented");
}
  800f4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f4d:	5b                   	pop    %ebx
  800f4e:	5e                   	pop    %esi
  800f4f:	5f                   	pop    %edi
  800f50:	5d                   	pop    %ebp
  800f51:	c3                   	ret    

00800f52 <sfork>:

// Challenge!
int
sfork(void)
{
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800f58:	68 ef 15 80 00       	push   $0x8015ef
  800f5d:	68 c3 00 00 00       	push   $0xc3
  800f62:	68 e4 15 80 00       	push   $0x8015e4
  800f67:	e8 00 00 00 00       	call   800f6c <_panic>

00800f6c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	56                   	push   %esi
  800f70:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800f71:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f74:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800f7a:	e8 a6 fb ff ff       	call   800b25 <sys_getenvid>
  800f7f:	83 ec 0c             	sub    $0xc,%esp
  800f82:	ff 75 0c             	pushl  0xc(%ebp)
  800f85:	ff 75 08             	pushl  0x8(%ebp)
  800f88:	56                   	push   %esi
  800f89:	50                   	push   %eax
  800f8a:	68 08 16 80 00       	push   $0x801608
  800f8f:	e8 47 f2 ff ff       	call   8001db <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f94:	83 c4 18             	add    $0x18,%esp
  800f97:	53                   	push   %ebx
  800f98:	ff 75 10             	pushl  0x10(%ebp)
  800f9b:	e8 ea f1 ff ff       	call   80018a <vcprintf>
	cprintf("\n");
  800fa0:	c7 04 24 cf 12 80 00 	movl   $0x8012cf,(%esp)
  800fa7:	e8 2f f2 ff ff       	call   8001db <cprintf>
  800fac:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800faf:	cc                   	int3   
  800fb0:	eb fd                	jmp    800faf <_panic+0x43>

00800fb2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800fb8:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800fbf:	75 2e                	jne    800fef <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  800fc1:	e8 5f fb ff ff       	call   800b25 <sys_getenvid>
  800fc6:	83 ec 04             	sub    $0x4,%esp
  800fc9:	68 07 0e 00 00       	push   $0xe07
  800fce:	68 00 f0 bf ee       	push   $0xeebff000
  800fd3:	50                   	push   %eax
  800fd4:	e8 8a fb ff ff       	call   800b63 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  800fd9:	e8 47 fb ff ff       	call   800b25 <sys_getenvid>
  800fde:	83 c4 08             	add    $0x8,%esp
  800fe1:	68 f9 0f 80 00       	push   $0x800ff9
  800fe6:	50                   	push   %eax
  800fe7:	e8 80 fc ff ff       	call   800c6c <sys_env_set_pgfault_upcall>
  800fec:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800fef:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff2:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800ff7:	c9                   	leave  
  800ff8:	c3                   	ret    

00800ff9 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800ff9:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800ffa:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800fff:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801001:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  801004:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  801008:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  80100c:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  80100f:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  801012:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  801013:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  801016:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  801017:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  801018:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  80101c:	c3                   	ret    
  80101d:	66 90                	xchg   %ax,%ax
  80101f:	90                   	nop

00801020 <__udivdi3>:
  801020:	55                   	push   %ebp
  801021:	57                   	push   %edi
  801022:	56                   	push   %esi
  801023:	53                   	push   %ebx
  801024:	83 ec 1c             	sub    $0x1c,%esp
  801027:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80102b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80102f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801033:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801037:	85 f6                	test   %esi,%esi
  801039:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80103d:	89 ca                	mov    %ecx,%edx
  80103f:	89 f8                	mov    %edi,%eax
  801041:	75 3d                	jne    801080 <__udivdi3+0x60>
  801043:	39 cf                	cmp    %ecx,%edi
  801045:	0f 87 c5 00 00 00    	ja     801110 <__udivdi3+0xf0>
  80104b:	85 ff                	test   %edi,%edi
  80104d:	89 fd                	mov    %edi,%ebp
  80104f:	75 0b                	jne    80105c <__udivdi3+0x3c>
  801051:	b8 01 00 00 00       	mov    $0x1,%eax
  801056:	31 d2                	xor    %edx,%edx
  801058:	f7 f7                	div    %edi
  80105a:	89 c5                	mov    %eax,%ebp
  80105c:	89 c8                	mov    %ecx,%eax
  80105e:	31 d2                	xor    %edx,%edx
  801060:	f7 f5                	div    %ebp
  801062:	89 c1                	mov    %eax,%ecx
  801064:	89 d8                	mov    %ebx,%eax
  801066:	89 cf                	mov    %ecx,%edi
  801068:	f7 f5                	div    %ebp
  80106a:	89 c3                	mov    %eax,%ebx
  80106c:	89 d8                	mov    %ebx,%eax
  80106e:	89 fa                	mov    %edi,%edx
  801070:	83 c4 1c             	add    $0x1c,%esp
  801073:	5b                   	pop    %ebx
  801074:	5e                   	pop    %esi
  801075:	5f                   	pop    %edi
  801076:	5d                   	pop    %ebp
  801077:	c3                   	ret    
  801078:	90                   	nop
  801079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801080:	39 ce                	cmp    %ecx,%esi
  801082:	77 74                	ja     8010f8 <__udivdi3+0xd8>
  801084:	0f bd fe             	bsr    %esi,%edi
  801087:	83 f7 1f             	xor    $0x1f,%edi
  80108a:	0f 84 98 00 00 00    	je     801128 <__udivdi3+0x108>
  801090:	bb 20 00 00 00       	mov    $0x20,%ebx
  801095:	89 f9                	mov    %edi,%ecx
  801097:	89 c5                	mov    %eax,%ebp
  801099:	29 fb                	sub    %edi,%ebx
  80109b:	d3 e6                	shl    %cl,%esi
  80109d:	89 d9                	mov    %ebx,%ecx
  80109f:	d3 ed                	shr    %cl,%ebp
  8010a1:	89 f9                	mov    %edi,%ecx
  8010a3:	d3 e0                	shl    %cl,%eax
  8010a5:	09 ee                	or     %ebp,%esi
  8010a7:	89 d9                	mov    %ebx,%ecx
  8010a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010ad:	89 d5                	mov    %edx,%ebp
  8010af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8010b3:	d3 ed                	shr    %cl,%ebp
  8010b5:	89 f9                	mov    %edi,%ecx
  8010b7:	d3 e2                	shl    %cl,%edx
  8010b9:	89 d9                	mov    %ebx,%ecx
  8010bb:	d3 e8                	shr    %cl,%eax
  8010bd:	09 c2                	or     %eax,%edx
  8010bf:	89 d0                	mov    %edx,%eax
  8010c1:	89 ea                	mov    %ebp,%edx
  8010c3:	f7 f6                	div    %esi
  8010c5:	89 d5                	mov    %edx,%ebp
  8010c7:	89 c3                	mov    %eax,%ebx
  8010c9:	f7 64 24 0c          	mull   0xc(%esp)
  8010cd:	39 d5                	cmp    %edx,%ebp
  8010cf:	72 10                	jb     8010e1 <__udivdi3+0xc1>
  8010d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8010d5:	89 f9                	mov    %edi,%ecx
  8010d7:	d3 e6                	shl    %cl,%esi
  8010d9:	39 c6                	cmp    %eax,%esi
  8010db:	73 07                	jae    8010e4 <__udivdi3+0xc4>
  8010dd:	39 d5                	cmp    %edx,%ebp
  8010df:	75 03                	jne    8010e4 <__udivdi3+0xc4>
  8010e1:	83 eb 01             	sub    $0x1,%ebx
  8010e4:	31 ff                	xor    %edi,%edi
  8010e6:	89 d8                	mov    %ebx,%eax
  8010e8:	89 fa                	mov    %edi,%edx
  8010ea:	83 c4 1c             	add    $0x1c,%esp
  8010ed:	5b                   	pop    %ebx
  8010ee:	5e                   	pop    %esi
  8010ef:	5f                   	pop    %edi
  8010f0:	5d                   	pop    %ebp
  8010f1:	c3                   	ret    
  8010f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010f8:	31 ff                	xor    %edi,%edi
  8010fa:	31 db                	xor    %ebx,%ebx
  8010fc:	89 d8                	mov    %ebx,%eax
  8010fe:	89 fa                	mov    %edi,%edx
  801100:	83 c4 1c             	add    $0x1c,%esp
  801103:	5b                   	pop    %ebx
  801104:	5e                   	pop    %esi
  801105:	5f                   	pop    %edi
  801106:	5d                   	pop    %ebp
  801107:	c3                   	ret    
  801108:	90                   	nop
  801109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801110:	89 d8                	mov    %ebx,%eax
  801112:	f7 f7                	div    %edi
  801114:	31 ff                	xor    %edi,%edi
  801116:	89 c3                	mov    %eax,%ebx
  801118:	89 d8                	mov    %ebx,%eax
  80111a:	89 fa                	mov    %edi,%edx
  80111c:	83 c4 1c             	add    $0x1c,%esp
  80111f:	5b                   	pop    %ebx
  801120:	5e                   	pop    %esi
  801121:	5f                   	pop    %edi
  801122:	5d                   	pop    %ebp
  801123:	c3                   	ret    
  801124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801128:	39 ce                	cmp    %ecx,%esi
  80112a:	72 0c                	jb     801138 <__udivdi3+0x118>
  80112c:	31 db                	xor    %ebx,%ebx
  80112e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801132:	0f 87 34 ff ff ff    	ja     80106c <__udivdi3+0x4c>
  801138:	bb 01 00 00 00       	mov    $0x1,%ebx
  80113d:	e9 2a ff ff ff       	jmp    80106c <__udivdi3+0x4c>
  801142:	66 90                	xchg   %ax,%ax
  801144:	66 90                	xchg   %ax,%ax
  801146:	66 90                	xchg   %ax,%ax
  801148:	66 90                	xchg   %ax,%ax
  80114a:	66 90                	xchg   %ax,%ax
  80114c:	66 90                	xchg   %ax,%ax
  80114e:	66 90                	xchg   %ax,%ax

00801150 <__umoddi3>:
  801150:	55                   	push   %ebp
  801151:	57                   	push   %edi
  801152:	56                   	push   %esi
  801153:	53                   	push   %ebx
  801154:	83 ec 1c             	sub    $0x1c,%esp
  801157:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80115b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80115f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801163:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801167:	85 d2                	test   %edx,%edx
  801169:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80116d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801171:	89 f3                	mov    %esi,%ebx
  801173:	89 3c 24             	mov    %edi,(%esp)
  801176:	89 74 24 04          	mov    %esi,0x4(%esp)
  80117a:	75 1c                	jne    801198 <__umoddi3+0x48>
  80117c:	39 f7                	cmp    %esi,%edi
  80117e:	76 50                	jbe    8011d0 <__umoddi3+0x80>
  801180:	89 c8                	mov    %ecx,%eax
  801182:	89 f2                	mov    %esi,%edx
  801184:	f7 f7                	div    %edi
  801186:	89 d0                	mov    %edx,%eax
  801188:	31 d2                	xor    %edx,%edx
  80118a:	83 c4 1c             	add    $0x1c,%esp
  80118d:	5b                   	pop    %ebx
  80118e:	5e                   	pop    %esi
  80118f:	5f                   	pop    %edi
  801190:	5d                   	pop    %ebp
  801191:	c3                   	ret    
  801192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801198:	39 f2                	cmp    %esi,%edx
  80119a:	89 d0                	mov    %edx,%eax
  80119c:	77 52                	ja     8011f0 <__umoddi3+0xa0>
  80119e:	0f bd ea             	bsr    %edx,%ebp
  8011a1:	83 f5 1f             	xor    $0x1f,%ebp
  8011a4:	75 5a                	jne    801200 <__umoddi3+0xb0>
  8011a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8011aa:	0f 82 e0 00 00 00    	jb     801290 <__umoddi3+0x140>
  8011b0:	39 0c 24             	cmp    %ecx,(%esp)
  8011b3:	0f 86 d7 00 00 00    	jbe    801290 <__umoddi3+0x140>
  8011b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8011bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8011c1:	83 c4 1c             	add    $0x1c,%esp
  8011c4:	5b                   	pop    %ebx
  8011c5:	5e                   	pop    %esi
  8011c6:	5f                   	pop    %edi
  8011c7:	5d                   	pop    %ebp
  8011c8:	c3                   	ret    
  8011c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011d0:	85 ff                	test   %edi,%edi
  8011d2:	89 fd                	mov    %edi,%ebp
  8011d4:	75 0b                	jne    8011e1 <__umoddi3+0x91>
  8011d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8011db:	31 d2                	xor    %edx,%edx
  8011dd:	f7 f7                	div    %edi
  8011df:	89 c5                	mov    %eax,%ebp
  8011e1:	89 f0                	mov    %esi,%eax
  8011e3:	31 d2                	xor    %edx,%edx
  8011e5:	f7 f5                	div    %ebp
  8011e7:	89 c8                	mov    %ecx,%eax
  8011e9:	f7 f5                	div    %ebp
  8011eb:	89 d0                	mov    %edx,%eax
  8011ed:	eb 99                	jmp    801188 <__umoddi3+0x38>
  8011ef:	90                   	nop
  8011f0:	89 c8                	mov    %ecx,%eax
  8011f2:	89 f2                	mov    %esi,%edx
  8011f4:	83 c4 1c             	add    $0x1c,%esp
  8011f7:	5b                   	pop    %ebx
  8011f8:	5e                   	pop    %esi
  8011f9:	5f                   	pop    %edi
  8011fa:	5d                   	pop    %ebp
  8011fb:	c3                   	ret    
  8011fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801200:	8b 34 24             	mov    (%esp),%esi
  801203:	bf 20 00 00 00       	mov    $0x20,%edi
  801208:	89 e9                	mov    %ebp,%ecx
  80120a:	29 ef                	sub    %ebp,%edi
  80120c:	d3 e0                	shl    %cl,%eax
  80120e:	89 f9                	mov    %edi,%ecx
  801210:	89 f2                	mov    %esi,%edx
  801212:	d3 ea                	shr    %cl,%edx
  801214:	89 e9                	mov    %ebp,%ecx
  801216:	09 c2                	or     %eax,%edx
  801218:	89 d8                	mov    %ebx,%eax
  80121a:	89 14 24             	mov    %edx,(%esp)
  80121d:	89 f2                	mov    %esi,%edx
  80121f:	d3 e2                	shl    %cl,%edx
  801221:	89 f9                	mov    %edi,%ecx
  801223:	89 54 24 04          	mov    %edx,0x4(%esp)
  801227:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80122b:	d3 e8                	shr    %cl,%eax
  80122d:	89 e9                	mov    %ebp,%ecx
  80122f:	89 c6                	mov    %eax,%esi
  801231:	d3 e3                	shl    %cl,%ebx
  801233:	89 f9                	mov    %edi,%ecx
  801235:	89 d0                	mov    %edx,%eax
  801237:	d3 e8                	shr    %cl,%eax
  801239:	89 e9                	mov    %ebp,%ecx
  80123b:	09 d8                	or     %ebx,%eax
  80123d:	89 d3                	mov    %edx,%ebx
  80123f:	89 f2                	mov    %esi,%edx
  801241:	f7 34 24             	divl   (%esp)
  801244:	89 d6                	mov    %edx,%esi
  801246:	d3 e3                	shl    %cl,%ebx
  801248:	f7 64 24 04          	mull   0x4(%esp)
  80124c:	39 d6                	cmp    %edx,%esi
  80124e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801252:	89 d1                	mov    %edx,%ecx
  801254:	89 c3                	mov    %eax,%ebx
  801256:	72 08                	jb     801260 <__umoddi3+0x110>
  801258:	75 11                	jne    80126b <__umoddi3+0x11b>
  80125a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80125e:	73 0b                	jae    80126b <__umoddi3+0x11b>
  801260:	2b 44 24 04          	sub    0x4(%esp),%eax
  801264:	1b 14 24             	sbb    (%esp),%edx
  801267:	89 d1                	mov    %edx,%ecx
  801269:	89 c3                	mov    %eax,%ebx
  80126b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80126f:	29 da                	sub    %ebx,%edx
  801271:	19 ce                	sbb    %ecx,%esi
  801273:	89 f9                	mov    %edi,%ecx
  801275:	89 f0                	mov    %esi,%eax
  801277:	d3 e0                	shl    %cl,%eax
  801279:	89 e9                	mov    %ebp,%ecx
  80127b:	d3 ea                	shr    %cl,%edx
  80127d:	89 e9                	mov    %ebp,%ecx
  80127f:	d3 ee                	shr    %cl,%esi
  801281:	09 d0                	or     %edx,%eax
  801283:	89 f2                	mov    %esi,%edx
  801285:	83 c4 1c             	add    $0x1c,%esp
  801288:	5b                   	pop    %ebx
  801289:	5e                   	pop    %esi
  80128a:	5f                   	pop    %edi
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    
  80128d:	8d 76 00             	lea    0x0(%esi),%esi
  801290:	29 f9                	sub    %edi,%ecx
  801292:	19 d6                	sbb    %edx,%esi
  801294:	89 74 24 04          	mov    %esi,0x4(%esp)
  801298:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80129c:	e9 18 ff ff ff       	jmp    8011b9 <__umoddi3+0x69>
