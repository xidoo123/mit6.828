
obj/user/forktree.debug:     file format elf32-i386


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
  80003d:	e8 eb 0a 00 00       	call   800b2d <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 00 21 80 00       	push   $0x802100
  80004c:	e8 92 01 00 00       	call   8001e3 <cprintf>

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
  800085:	e8 23 08 00 00       	call   8008ad <memset>

	if (strlen(cur) >= DEPTH)
  80008a:	89 1c 24             	mov    %ebx,(%esp)
  80008d:	e8 9d 06 00 00       	call   80072f <strlen>
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
  8000a4:	68 11 21 80 00       	push   $0x802111
  8000a9:	6a 04                	push   $0x4
  8000ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000ae:	50                   	push   %eax
  8000af:	e8 61 06 00 00       	call   800715 <snprintf>
	// cprintf("%s, %s\n", cur, nxt);
	if (fork() == 0) {
  8000b4:	83 c4 20             	add    $0x20,%esp
  8000b7:	e8 79 0d 00 00       	call   800e35 <fork>
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
  8000e1:	68 10 21 80 00       	push   $0x802110
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
  8000fb:	e8 2d 0a 00 00       	call   800b2d <sys_getenvid>
  800100:	25 ff 03 00 00       	and    $0x3ff,%eax
  800105:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800108:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800112:	85 db                	test   %ebx,%ebx
  800114:	7e 07                	jle    80011d <libmain+0x2d>
		binaryname = argv[0];
  800116:	8b 06                	mov    (%esi),%eax
  800118:	a3 00 30 80 00       	mov    %eax,0x803000

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
  800139:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80013c:	e8 40 10 00 00       	call   801181 <close_all>
	sys_env_destroy(0);
  800141:	83 ec 0c             	sub    $0xc,%esp
  800144:	6a 00                	push   $0x0
  800146:	e8 a1 09 00 00       	call   800aec <sys_env_destroy>
}
  80014b:	83 c4 10             	add    $0x10,%esp
  80014e:	c9                   	leave  
  80014f:	c3                   	ret    

00800150 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	53                   	push   %ebx
  800154:	83 ec 04             	sub    $0x4,%esp
  800157:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80015a:	8b 13                	mov    (%ebx),%edx
  80015c:	8d 42 01             	lea    0x1(%edx),%eax
  80015f:	89 03                	mov    %eax,(%ebx)
  800161:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800164:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800168:	3d ff 00 00 00       	cmp    $0xff,%eax
  80016d:	75 1a                	jne    800189 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80016f:	83 ec 08             	sub    $0x8,%esp
  800172:	68 ff 00 00 00       	push   $0xff
  800177:	8d 43 08             	lea    0x8(%ebx),%eax
  80017a:	50                   	push   %eax
  80017b:	e8 2f 09 00 00       	call   800aaf <sys_cputs>
		b->idx = 0;
  800180:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800186:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800189:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80018d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800190:	c9                   	leave  
  800191:	c3                   	ret    

00800192 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800192:	55                   	push   %ebp
  800193:	89 e5                	mov    %esp,%ebp
  800195:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80019b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001a2:	00 00 00 
	b.cnt = 0;
  8001a5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ac:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001af:	ff 75 0c             	pushl  0xc(%ebp)
  8001b2:	ff 75 08             	pushl  0x8(%ebp)
  8001b5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001bb:	50                   	push   %eax
  8001bc:	68 50 01 80 00       	push   $0x800150
  8001c1:	e8 54 01 00 00       	call   80031a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001c6:	83 c4 08             	add    $0x8,%esp
  8001c9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001cf:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001d5:	50                   	push   %eax
  8001d6:	e8 d4 08 00 00       	call   800aaf <sys_cputs>

	return b.cnt;
}
  8001db:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001e1:	c9                   	leave  
  8001e2:	c3                   	ret    

008001e3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001e9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ec:	50                   	push   %eax
  8001ed:	ff 75 08             	pushl  0x8(%ebp)
  8001f0:	e8 9d ff ff ff       	call   800192 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001f5:	c9                   	leave  
  8001f6:	c3                   	ret    

008001f7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	57                   	push   %edi
  8001fb:	56                   	push   %esi
  8001fc:	53                   	push   %ebx
  8001fd:	83 ec 1c             	sub    $0x1c,%esp
  800200:	89 c7                	mov    %eax,%edi
  800202:	89 d6                	mov    %edx,%esi
  800204:	8b 45 08             	mov    0x8(%ebp),%eax
  800207:	8b 55 0c             	mov    0xc(%ebp),%edx
  80020a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80020d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800210:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800213:	bb 00 00 00 00       	mov    $0x0,%ebx
  800218:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80021b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80021e:	39 d3                	cmp    %edx,%ebx
  800220:	72 05                	jb     800227 <printnum+0x30>
  800222:	39 45 10             	cmp    %eax,0x10(%ebp)
  800225:	77 45                	ja     80026c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800227:	83 ec 0c             	sub    $0xc,%esp
  80022a:	ff 75 18             	pushl  0x18(%ebp)
  80022d:	8b 45 14             	mov    0x14(%ebp),%eax
  800230:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800233:	53                   	push   %ebx
  800234:	ff 75 10             	pushl  0x10(%ebp)
  800237:	83 ec 08             	sub    $0x8,%esp
  80023a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80023d:	ff 75 e0             	pushl  -0x20(%ebp)
  800240:	ff 75 dc             	pushl  -0x24(%ebp)
  800243:	ff 75 d8             	pushl  -0x28(%ebp)
  800246:	e8 15 1c 00 00       	call   801e60 <__udivdi3>
  80024b:	83 c4 18             	add    $0x18,%esp
  80024e:	52                   	push   %edx
  80024f:	50                   	push   %eax
  800250:	89 f2                	mov    %esi,%edx
  800252:	89 f8                	mov    %edi,%eax
  800254:	e8 9e ff ff ff       	call   8001f7 <printnum>
  800259:	83 c4 20             	add    $0x20,%esp
  80025c:	eb 18                	jmp    800276 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80025e:	83 ec 08             	sub    $0x8,%esp
  800261:	56                   	push   %esi
  800262:	ff 75 18             	pushl  0x18(%ebp)
  800265:	ff d7                	call   *%edi
  800267:	83 c4 10             	add    $0x10,%esp
  80026a:	eb 03                	jmp    80026f <printnum+0x78>
  80026c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80026f:	83 eb 01             	sub    $0x1,%ebx
  800272:	85 db                	test   %ebx,%ebx
  800274:	7f e8                	jg     80025e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800276:	83 ec 08             	sub    $0x8,%esp
  800279:	56                   	push   %esi
  80027a:	83 ec 04             	sub    $0x4,%esp
  80027d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800280:	ff 75 e0             	pushl  -0x20(%ebp)
  800283:	ff 75 dc             	pushl  -0x24(%ebp)
  800286:	ff 75 d8             	pushl  -0x28(%ebp)
  800289:	e8 02 1d 00 00       	call   801f90 <__umoddi3>
  80028e:	83 c4 14             	add    $0x14,%esp
  800291:	0f be 80 20 21 80 00 	movsbl 0x802120(%eax),%eax
  800298:	50                   	push   %eax
  800299:	ff d7                	call   *%edi
}
  80029b:	83 c4 10             	add    $0x10,%esp
  80029e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a1:	5b                   	pop    %ebx
  8002a2:	5e                   	pop    %esi
  8002a3:	5f                   	pop    %edi
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a9:	83 fa 01             	cmp    $0x1,%edx
  8002ac:	7e 0e                	jle    8002bc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ae:	8b 10                	mov    (%eax),%edx
  8002b0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b3:	89 08                	mov    %ecx,(%eax)
  8002b5:	8b 02                	mov    (%edx),%eax
  8002b7:	8b 52 04             	mov    0x4(%edx),%edx
  8002ba:	eb 22                	jmp    8002de <getuint+0x38>
	else if (lflag)
  8002bc:	85 d2                	test   %edx,%edx
  8002be:	74 10                	je     8002d0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c0:	8b 10                	mov    (%eax),%edx
  8002c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 02                	mov    (%edx),%eax
  8002c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ce:	eb 0e                	jmp    8002de <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d0:	8b 10                	mov    (%eax),%edx
  8002d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d5:	89 08                	mov    %ecx,(%eax)
  8002d7:	8b 02                	mov    (%edx),%eax
  8002d9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002de:	5d                   	pop    %ebp
  8002df:	c3                   	ret    

008002e0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ea:	8b 10                	mov    (%eax),%edx
  8002ec:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ef:	73 0a                	jae    8002fb <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002f4:	89 08                	mov    %ecx,(%eax)
  8002f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f9:	88 02                	mov    %al,(%edx)
}
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800303:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800306:	50                   	push   %eax
  800307:	ff 75 10             	pushl  0x10(%ebp)
  80030a:	ff 75 0c             	pushl  0xc(%ebp)
  80030d:	ff 75 08             	pushl  0x8(%ebp)
  800310:	e8 05 00 00 00       	call   80031a <vprintfmt>
	va_end(ap);
}
  800315:	83 c4 10             	add    $0x10,%esp
  800318:	c9                   	leave  
  800319:	c3                   	ret    

0080031a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 2c             	sub    $0x2c,%esp
  800323:	8b 75 08             	mov    0x8(%ebp),%esi
  800326:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800329:	8b 7d 10             	mov    0x10(%ebp),%edi
  80032c:	eb 12                	jmp    800340 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80032e:	85 c0                	test   %eax,%eax
  800330:	0f 84 89 03 00 00    	je     8006bf <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800336:	83 ec 08             	sub    $0x8,%esp
  800339:	53                   	push   %ebx
  80033a:	50                   	push   %eax
  80033b:	ff d6                	call   *%esi
  80033d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800340:	83 c7 01             	add    $0x1,%edi
  800343:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800347:	83 f8 25             	cmp    $0x25,%eax
  80034a:	75 e2                	jne    80032e <vprintfmt+0x14>
  80034c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800350:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800357:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80035e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800365:	ba 00 00 00 00       	mov    $0x0,%edx
  80036a:	eb 07                	jmp    800373 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80036f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800373:	8d 47 01             	lea    0x1(%edi),%eax
  800376:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800379:	0f b6 07             	movzbl (%edi),%eax
  80037c:	0f b6 c8             	movzbl %al,%ecx
  80037f:	83 e8 23             	sub    $0x23,%eax
  800382:	3c 55                	cmp    $0x55,%al
  800384:	0f 87 1a 03 00 00    	ja     8006a4 <vprintfmt+0x38a>
  80038a:	0f b6 c0             	movzbl %al,%eax
  80038d:	ff 24 85 60 22 80 00 	jmp    *0x802260(,%eax,4)
  800394:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800397:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80039b:	eb d6                	jmp    800373 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ab:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003af:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003b2:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003b5:	83 fa 09             	cmp    $0x9,%edx
  8003b8:	77 39                	ja     8003f3 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ba:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003bd:	eb e9                	jmp    8003a8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c2:	8d 48 04             	lea    0x4(%eax),%ecx
  8003c5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003c8:	8b 00                	mov    (%eax),%eax
  8003ca:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003d0:	eb 27                	jmp    8003f9 <vprintfmt+0xdf>
  8003d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003d5:	85 c0                	test   %eax,%eax
  8003d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003dc:	0f 49 c8             	cmovns %eax,%ecx
  8003df:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e5:	eb 8c                	jmp    800373 <vprintfmt+0x59>
  8003e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ea:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003f1:	eb 80                	jmp    800373 <vprintfmt+0x59>
  8003f3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003f6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003f9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003fd:	0f 89 70 ff ff ff    	jns    800373 <vprintfmt+0x59>
				width = precision, precision = -1;
  800403:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800406:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800409:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800410:	e9 5e ff ff ff       	jmp    800373 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800415:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800418:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80041b:	e9 53 ff ff ff       	jmp    800373 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800420:	8b 45 14             	mov    0x14(%ebp),%eax
  800423:	8d 50 04             	lea    0x4(%eax),%edx
  800426:	89 55 14             	mov    %edx,0x14(%ebp)
  800429:	83 ec 08             	sub    $0x8,%esp
  80042c:	53                   	push   %ebx
  80042d:	ff 30                	pushl  (%eax)
  80042f:	ff d6                	call   *%esi
			break;
  800431:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800434:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800437:	e9 04 ff ff ff       	jmp    800340 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80043c:	8b 45 14             	mov    0x14(%ebp),%eax
  80043f:	8d 50 04             	lea    0x4(%eax),%edx
  800442:	89 55 14             	mov    %edx,0x14(%ebp)
  800445:	8b 00                	mov    (%eax),%eax
  800447:	99                   	cltd   
  800448:	31 d0                	xor    %edx,%eax
  80044a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044c:	83 f8 0f             	cmp    $0xf,%eax
  80044f:	7f 0b                	jg     80045c <vprintfmt+0x142>
  800451:	8b 14 85 c0 23 80 00 	mov    0x8023c0(,%eax,4),%edx
  800458:	85 d2                	test   %edx,%edx
  80045a:	75 18                	jne    800474 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80045c:	50                   	push   %eax
  80045d:	68 38 21 80 00       	push   $0x802138
  800462:	53                   	push   %ebx
  800463:	56                   	push   %esi
  800464:	e8 94 fe ff ff       	call   8002fd <printfmt>
  800469:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80046f:	e9 cc fe ff ff       	jmp    800340 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800474:	52                   	push   %edx
  800475:	68 d2 25 80 00       	push   $0x8025d2
  80047a:	53                   	push   %ebx
  80047b:	56                   	push   %esi
  80047c:	e8 7c fe ff ff       	call   8002fd <printfmt>
  800481:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800487:	e9 b4 fe ff ff       	jmp    800340 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80048c:	8b 45 14             	mov    0x14(%ebp),%eax
  80048f:	8d 50 04             	lea    0x4(%eax),%edx
  800492:	89 55 14             	mov    %edx,0x14(%ebp)
  800495:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800497:	85 ff                	test   %edi,%edi
  800499:	b8 31 21 80 00       	mov    $0x802131,%eax
  80049e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004a1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a5:	0f 8e 94 00 00 00    	jle    80053f <vprintfmt+0x225>
  8004ab:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004af:	0f 84 98 00 00 00    	je     80054d <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b5:	83 ec 08             	sub    $0x8,%esp
  8004b8:	ff 75 d0             	pushl  -0x30(%ebp)
  8004bb:	57                   	push   %edi
  8004bc:	e8 86 02 00 00       	call   800747 <strnlen>
  8004c1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004c4:	29 c1                	sub    %eax,%ecx
  8004c6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004c9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004cc:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004d6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d8:	eb 0f                	jmp    8004e9 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004da:	83 ec 08             	sub    $0x8,%esp
  8004dd:	53                   	push   %ebx
  8004de:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e3:	83 ef 01             	sub    $0x1,%edi
  8004e6:	83 c4 10             	add    $0x10,%esp
  8004e9:	85 ff                	test   %edi,%edi
  8004eb:	7f ed                	jg     8004da <vprintfmt+0x1c0>
  8004ed:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004f0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004f3:	85 c9                	test   %ecx,%ecx
  8004f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fa:	0f 49 c1             	cmovns %ecx,%eax
  8004fd:	29 c1                	sub    %eax,%ecx
  8004ff:	89 75 08             	mov    %esi,0x8(%ebp)
  800502:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800505:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800508:	89 cb                	mov    %ecx,%ebx
  80050a:	eb 4d                	jmp    800559 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80050c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800510:	74 1b                	je     80052d <vprintfmt+0x213>
  800512:	0f be c0             	movsbl %al,%eax
  800515:	83 e8 20             	sub    $0x20,%eax
  800518:	83 f8 5e             	cmp    $0x5e,%eax
  80051b:	76 10                	jbe    80052d <vprintfmt+0x213>
					putch('?', putdat);
  80051d:	83 ec 08             	sub    $0x8,%esp
  800520:	ff 75 0c             	pushl  0xc(%ebp)
  800523:	6a 3f                	push   $0x3f
  800525:	ff 55 08             	call   *0x8(%ebp)
  800528:	83 c4 10             	add    $0x10,%esp
  80052b:	eb 0d                	jmp    80053a <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	ff 75 0c             	pushl  0xc(%ebp)
  800533:	52                   	push   %edx
  800534:	ff 55 08             	call   *0x8(%ebp)
  800537:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053a:	83 eb 01             	sub    $0x1,%ebx
  80053d:	eb 1a                	jmp    800559 <vprintfmt+0x23f>
  80053f:	89 75 08             	mov    %esi,0x8(%ebp)
  800542:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800545:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800548:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80054b:	eb 0c                	jmp    800559 <vprintfmt+0x23f>
  80054d:	89 75 08             	mov    %esi,0x8(%ebp)
  800550:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800553:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800556:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800559:	83 c7 01             	add    $0x1,%edi
  80055c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800560:	0f be d0             	movsbl %al,%edx
  800563:	85 d2                	test   %edx,%edx
  800565:	74 23                	je     80058a <vprintfmt+0x270>
  800567:	85 f6                	test   %esi,%esi
  800569:	78 a1                	js     80050c <vprintfmt+0x1f2>
  80056b:	83 ee 01             	sub    $0x1,%esi
  80056e:	79 9c                	jns    80050c <vprintfmt+0x1f2>
  800570:	89 df                	mov    %ebx,%edi
  800572:	8b 75 08             	mov    0x8(%ebp),%esi
  800575:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800578:	eb 18                	jmp    800592 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80057a:	83 ec 08             	sub    $0x8,%esp
  80057d:	53                   	push   %ebx
  80057e:	6a 20                	push   $0x20
  800580:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800582:	83 ef 01             	sub    $0x1,%edi
  800585:	83 c4 10             	add    $0x10,%esp
  800588:	eb 08                	jmp    800592 <vprintfmt+0x278>
  80058a:	89 df                	mov    %ebx,%edi
  80058c:	8b 75 08             	mov    0x8(%ebp),%esi
  80058f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800592:	85 ff                	test   %edi,%edi
  800594:	7f e4                	jg     80057a <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800596:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800599:	e9 a2 fd ff ff       	jmp    800340 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80059e:	83 fa 01             	cmp    $0x1,%edx
  8005a1:	7e 16                	jle    8005b9 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8d 50 08             	lea    0x8(%eax),%edx
  8005a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ac:	8b 50 04             	mov    0x4(%eax),%edx
  8005af:	8b 00                	mov    (%eax),%eax
  8005b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b7:	eb 32                	jmp    8005eb <vprintfmt+0x2d1>
	else if (lflag)
  8005b9:	85 d2                	test   %edx,%edx
  8005bb:	74 18                	je     8005d5 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8d 50 04             	lea    0x4(%eax),%edx
  8005c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c6:	8b 00                	mov    (%eax),%eax
  8005c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cb:	89 c1                	mov    %eax,%ecx
  8005cd:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d3:	eb 16                	jmp    8005eb <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	8d 50 04             	lea    0x4(%eax),%edx
  8005db:	89 55 14             	mov    %edx,0x14(%ebp)
  8005de:	8b 00                	mov    (%eax),%eax
  8005e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e3:	89 c1                	mov    %eax,%ecx
  8005e5:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005eb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ee:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005f6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005fa:	79 74                	jns    800670 <vprintfmt+0x356>
				putch('-', putdat);
  8005fc:	83 ec 08             	sub    $0x8,%esp
  8005ff:	53                   	push   %ebx
  800600:	6a 2d                	push   $0x2d
  800602:	ff d6                	call   *%esi
				num = -(long long) num;
  800604:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800607:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80060a:	f7 d8                	neg    %eax
  80060c:	83 d2 00             	adc    $0x0,%edx
  80060f:	f7 da                	neg    %edx
  800611:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800614:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800619:	eb 55                	jmp    800670 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80061b:	8d 45 14             	lea    0x14(%ebp),%eax
  80061e:	e8 83 fc ff ff       	call   8002a6 <getuint>
			base = 10;
  800623:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800628:	eb 46                	jmp    800670 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  80062a:	8d 45 14             	lea    0x14(%ebp),%eax
  80062d:	e8 74 fc ff ff       	call   8002a6 <getuint>
			base = 8;
  800632:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800637:	eb 37                	jmp    800670 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800639:	83 ec 08             	sub    $0x8,%esp
  80063c:	53                   	push   %ebx
  80063d:	6a 30                	push   $0x30
  80063f:	ff d6                	call   *%esi
			putch('x', putdat);
  800641:	83 c4 08             	add    $0x8,%esp
  800644:	53                   	push   %ebx
  800645:	6a 78                	push   $0x78
  800647:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8d 50 04             	lea    0x4(%eax),%edx
  80064f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800652:	8b 00                	mov    (%eax),%eax
  800654:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800659:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80065c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800661:	eb 0d                	jmp    800670 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800663:	8d 45 14             	lea    0x14(%ebp),%eax
  800666:	e8 3b fc ff ff       	call   8002a6 <getuint>
			base = 16;
  80066b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800670:	83 ec 0c             	sub    $0xc,%esp
  800673:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800677:	57                   	push   %edi
  800678:	ff 75 e0             	pushl  -0x20(%ebp)
  80067b:	51                   	push   %ecx
  80067c:	52                   	push   %edx
  80067d:	50                   	push   %eax
  80067e:	89 da                	mov    %ebx,%edx
  800680:	89 f0                	mov    %esi,%eax
  800682:	e8 70 fb ff ff       	call   8001f7 <printnum>
			break;
  800687:	83 c4 20             	add    $0x20,%esp
  80068a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80068d:	e9 ae fc ff ff       	jmp    800340 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800692:	83 ec 08             	sub    $0x8,%esp
  800695:	53                   	push   %ebx
  800696:	51                   	push   %ecx
  800697:	ff d6                	call   *%esi
			break;
  800699:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80069f:	e9 9c fc ff ff       	jmp    800340 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006a4:	83 ec 08             	sub    $0x8,%esp
  8006a7:	53                   	push   %ebx
  8006a8:	6a 25                	push   $0x25
  8006aa:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	eb 03                	jmp    8006b4 <vprintfmt+0x39a>
  8006b1:	83 ef 01             	sub    $0x1,%edi
  8006b4:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006b8:	75 f7                	jne    8006b1 <vprintfmt+0x397>
  8006ba:	e9 81 fc ff ff       	jmp    800340 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c2:	5b                   	pop    %ebx
  8006c3:	5e                   	pop    %esi
  8006c4:	5f                   	pop    %edi
  8006c5:	5d                   	pop    %ebp
  8006c6:	c3                   	ret    

008006c7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c7:	55                   	push   %ebp
  8006c8:	89 e5                	mov    %esp,%ebp
  8006ca:	83 ec 18             	sub    $0x18,%esp
  8006cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006d6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006da:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e4:	85 c0                	test   %eax,%eax
  8006e6:	74 26                	je     80070e <vsnprintf+0x47>
  8006e8:	85 d2                	test   %edx,%edx
  8006ea:	7e 22                	jle    80070e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ec:	ff 75 14             	pushl  0x14(%ebp)
  8006ef:	ff 75 10             	pushl  0x10(%ebp)
  8006f2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f5:	50                   	push   %eax
  8006f6:	68 e0 02 80 00       	push   $0x8002e0
  8006fb:	e8 1a fc ff ff       	call   80031a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800700:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800703:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800706:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800709:	83 c4 10             	add    $0x10,%esp
  80070c:	eb 05                	jmp    800713 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80070e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800713:	c9                   	leave  
  800714:	c3                   	ret    

00800715 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800715:	55                   	push   %ebp
  800716:	89 e5                	mov    %esp,%ebp
  800718:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80071b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80071e:	50                   	push   %eax
  80071f:	ff 75 10             	pushl  0x10(%ebp)
  800722:	ff 75 0c             	pushl  0xc(%ebp)
  800725:	ff 75 08             	pushl  0x8(%ebp)
  800728:	e8 9a ff ff ff       	call   8006c7 <vsnprintf>
	va_end(ap);

	return rc;
}
  80072d:	c9                   	leave  
  80072e:	c3                   	ret    

0080072f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
  800732:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800735:	b8 00 00 00 00       	mov    $0x0,%eax
  80073a:	eb 03                	jmp    80073f <strlen+0x10>
		n++;
  80073c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80073f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800743:	75 f7                	jne    80073c <strlen+0xd>
		n++;
	return n;
}
  800745:	5d                   	pop    %ebp
  800746:	c3                   	ret    

00800747 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80074d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800750:	ba 00 00 00 00       	mov    $0x0,%edx
  800755:	eb 03                	jmp    80075a <strnlen+0x13>
		n++;
  800757:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075a:	39 c2                	cmp    %eax,%edx
  80075c:	74 08                	je     800766 <strnlen+0x1f>
  80075e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800762:	75 f3                	jne    800757 <strnlen+0x10>
  800764:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800766:	5d                   	pop    %ebp
  800767:	c3                   	ret    

00800768 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	53                   	push   %ebx
  80076c:	8b 45 08             	mov    0x8(%ebp),%eax
  80076f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800772:	89 c2                	mov    %eax,%edx
  800774:	83 c2 01             	add    $0x1,%edx
  800777:	83 c1 01             	add    $0x1,%ecx
  80077a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80077e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800781:	84 db                	test   %bl,%bl
  800783:	75 ef                	jne    800774 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800785:	5b                   	pop    %ebx
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	53                   	push   %ebx
  80078c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80078f:	53                   	push   %ebx
  800790:	e8 9a ff ff ff       	call   80072f <strlen>
  800795:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800798:	ff 75 0c             	pushl  0xc(%ebp)
  80079b:	01 d8                	add    %ebx,%eax
  80079d:	50                   	push   %eax
  80079e:	e8 c5 ff ff ff       	call   800768 <strcpy>
	return dst;
}
  8007a3:	89 d8                	mov    %ebx,%eax
  8007a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a8:	c9                   	leave  
  8007a9:	c3                   	ret    

008007aa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	56                   	push   %esi
  8007ae:	53                   	push   %ebx
  8007af:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b5:	89 f3                	mov    %esi,%ebx
  8007b7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ba:	89 f2                	mov    %esi,%edx
  8007bc:	eb 0f                	jmp    8007cd <strncpy+0x23>
		*dst++ = *src;
  8007be:	83 c2 01             	add    $0x1,%edx
  8007c1:	0f b6 01             	movzbl (%ecx),%eax
  8007c4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007c7:	80 39 01             	cmpb   $0x1,(%ecx)
  8007ca:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007cd:	39 da                	cmp    %ebx,%edx
  8007cf:	75 ed                	jne    8007be <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007d1:	89 f0                	mov    %esi,%eax
  8007d3:	5b                   	pop    %ebx
  8007d4:	5e                   	pop    %esi
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	56                   	push   %esi
  8007db:	53                   	push   %ebx
  8007dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e2:	8b 55 10             	mov    0x10(%ebp),%edx
  8007e5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007e7:	85 d2                	test   %edx,%edx
  8007e9:	74 21                	je     80080c <strlcpy+0x35>
  8007eb:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007ef:	89 f2                	mov    %esi,%edx
  8007f1:	eb 09                	jmp    8007fc <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007f3:	83 c2 01             	add    $0x1,%edx
  8007f6:	83 c1 01             	add    $0x1,%ecx
  8007f9:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007fc:	39 c2                	cmp    %eax,%edx
  8007fe:	74 09                	je     800809 <strlcpy+0x32>
  800800:	0f b6 19             	movzbl (%ecx),%ebx
  800803:	84 db                	test   %bl,%bl
  800805:	75 ec                	jne    8007f3 <strlcpy+0x1c>
  800807:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800809:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80080c:	29 f0                	sub    %esi,%eax
}
  80080e:	5b                   	pop    %ebx
  80080f:	5e                   	pop    %esi
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800818:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80081b:	eb 06                	jmp    800823 <strcmp+0x11>
		p++, q++;
  80081d:	83 c1 01             	add    $0x1,%ecx
  800820:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800823:	0f b6 01             	movzbl (%ecx),%eax
  800826:	84 c0                	test   %al,%al
  800828:	74 04                	je     80082e <strcmp+0x1c>
  80082a:	3a 02                	cmp    (%edx),%al
  80082c:	74 ef                	je     80081d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80082e:	0f b6 c0             	movzbl %al,%eax
  800831:	0f b6 12             	movzbl (%edx),%edx
  800834:	29 d0                	sub    %edx,%eax
}
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	53                   	push   %ebx
  80083c:	8b 45 08             	mov    0x8(%ebp),%eax
  80083f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800842:	89 c3                	mov    %eax,%ebx
  800844:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800847:	eb 06                	jmp    80084f <strncmp+0x17>
		n--, p++, q++;
  800849:	83 c0 01             	add    $0x1,%eax
  80084c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80084f:	39 d8                	cmp    %ebx,%eax
  800851:	74 15                	je     800868 <strncmp+0x30>
  800853:	0f b6 08             	movzbl (%eax),%ecx
  800856:	84 c9                	test   %cl,%cl
  800858:	74 04                	je     80085e <strncmp+0x26>
  80085a:	3a 0a                	cmp    (%edx),%cl
  80085c:	74 eb                	je     800849 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80085e:	0f b6 00             	movzbl (%eax),%eax
  800861:	0f b6 12             	movzbl (%edx),%edx
  800864:	29 d0                	sub    %edx,%eax
  800866:	eb 05                	jmp    80086d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800868:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80086d:	5b                   	pop    %ebx
  80086e:	5d                   	pop    %ebp
  80086f:	c3                   	ret    

00800870 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	8b 45 08             	mov    0x8(%ebp),%eax
  800876:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80087a:	eb 07                	jmp    800883 <strchr+0x13>
		if (*s == c)
  80087c:	38 ca                	cmp    %cl,%dl
  80087e:	74 0f                	je     80088f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800880:	83 c0 01             	add    $0x1,%eax
  800883:	0f b6 10             	movzbl (%eax),%edx
  800886:	84 d2                	test   %dl,%dl
  800888:	75 f2                	jne    80087c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80088a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    

00800891 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	8b 45 08             	mov    0x8(%ebp),%eax
  800897:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80089b:	eb 03                	jmp    8008a0 <strfind+0xf>
  80089d:	83 c0 01             	add    $0x1,%eax
  8008a0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008a3:	38 ca                	cmp    %cl,%dl
  8008a5:	74 04                	je     8008ab <strfind+0x1a>
  8008a7:	84 d2                	test   %dl,%dl
  8008a9:	75 f2                	jne    80089d <strfind+0xc>
			break;
	return (char *) s;
}
  8008ab:	5d                   	pop    %ebp
  8008ac:	c3                   	ret    

008008ad <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	57                   	push   %edi
  8008b1:	56                   	push   %esi
  8008b2:	53                   	push   %ebx
  8008b3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008b9:	85 c9                	test   %ecx,%ecx
  8008bb:	74 36                	je     8008f3 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008bd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008c3:	75 28                	jne    8008ed <memset+0x40>
  8008c5:	f6 c1 03             	test   $0x3,%cl
  8008c8:	75 23                	jne    8008ed <memset+0x40>
		c &= 0xFF;
  8008ca:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ce:	89 d3                	mov    %edx,%ebx
  8008d0:	c1 e3 08             	shl    $0x8,%ebx
  8008d3:	89 d6                	mov    %edx,%esi
  8008d5:	c1 e6 18             	shl    $0x18,%esi
  8008d8:	89 d0                	mov    %edx,%eax
  8008da:	c1 e0 10             	shl    $0x10,%eax
  8008dd:	09 f0                	or     %esi,%eax
  8008df:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008e1:	89 d8                	mov    %ebx,%eax
  8008e3:	09 d0                	or     %edx,%eax
  8008e5:	c1 e9 02             	shr    $0x2,%ecx
  8008e8:	fc                   	cld    
  8008e9:	f3 ab                	rep stos %eax,%es:(%edi)
  8008eb:	eb 06                	jmp    8008f3 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f0:	fc                   	cld    
  8008f1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008f3:	89 f8                	mov    %edi,%eax
  8008f5:	5b                   	pop    %ebx
  8008f6:	5e                   	pop    %esi
  8008f7:	5f                   	pop    %edi
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	57                   	push   %edi
  8008fe:	56                   	push   %esi
  8008ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800902:	8b 75 0c             	mov    0xc(%ebp),%esi
  800905:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800908:	39 c6                	cmp    %eax,%esi
  80090a:	73 35                	jae    800941 <memmove+0x47>
  80090c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80090f:	39 d0                	cmp    %edx,%eax
  800911:	73 2e                	jae    800941 <memmove+0x47>
		s += n;
		d += n;
  800913:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800916:	89 d6                	mov    %edx,%esi
  800918:	09 fe                	or     %edi,%esi
  80091a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800920:	75 13                	jne    800935 <memmove+0x3b>
  800922:	f6 c1 03             	test   $0x3,%cl
  800925:	75 0e                	jne    800935 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800927:	83 ef 04             	sub    $0x4,%edi
  80092a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80092d:	c1 e9 02             	shr    $0x2,%ecx
  800930:	fd                   	std    
  800931:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800933:	eb 09                	jmp    80093e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800935:	83 ef 01             	sub    $0x1,%edi
  800938:	8d 72 ff             	lea    -0x1(%edx),%esi
  80093b:	fd                   	std    
  80093c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80093e:	fc                   	cld    
  80093f:	eb 1d                	jmp    80095e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800941:	89 f2                	mov    %esi,%edx
  800943:	09 c2                	or     %eax,%edx
  800945:	f6 c2 03             	test   $0x3,%dl
  800948:	75 0f                	jne    800959 <memmove+0x5f>
  80094a:	f6 c1 03             	test   $0x3,%cl
  80094d:	75 0a                	jne    800959 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80094f:	c1 e9 02             	shr    $0x2,%ecx
  800952:	89 c7                	mov    %eax,%edi
  800954:	fc                   	cld    
  800955:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800957:	eb 05                	jmp    80095e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800959:	89 c7                	mov    %eax,%edi
  80095b:	fc                   	cld    
  80095c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80095e:	5e                   	pop    %esi
  80095f:	5f                   	pop    %edi
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800965:	ff 75 10             	pushl  0x10(%ebp)
  800968:	ff 75 0c             	pushl  0xc(%ebp)
  80096b:	ff 75 08             	pushl  0x8(%ebp)
  80096e:	e8 87 ff ff ff       	call   8008fa <memmove>
}
  800973:	c9                   	leave  
  800974:	c3                   	ret    

00800975 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	56                   	push   %esi
  800979:	53                   	push   %ebx
  80097a:	8b 45 08             	mov    0x8(%ebp),%eax
  80097d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800980:	89 c6                	mov    %eax,%esi
  800982:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800985:	eb 1a                	jmp    8009a1 <memcmp+0x2c>
		if (*s1 != *s2)
  800987:	0f b6 08             	movzbl (%eax),%ecx
  80098a:	0f b6 1a             	movzbl (%edx),%ebx
  80098d:	38 d9                	cmp    %bl,%cl
  80098f:	74 0a                	je     80099b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800991:	0f b6 c1             	movzbl %cl,%eax
  800994:	0f b6 db             	movzbl %bl,%ebx
  800997:	29 d8                	sub    %ebx,%eax
  800999:	eb 0f                	jmp    8009aa <memcmp+0x35>
		s1++, s2++;
  80099b:	83 c0 01             	add    $0x1,%eax
  80099e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a1:	39 f0                	cmp    %esi,%eax
  8009a3:	75 e2                	jne    800987 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009aa:	5b                   	pop    %ebx
  8009ab:	5e                   	pop    %esi
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	53                   	push   %ebx
  8009b2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009b5:	89 c1                	mov    %eax,%ecx
  8009b7:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ba:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009be:	eb 0a                	jmp    8009ca <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c0:	0f b6 10             	movzbl (%eax),%edx
  8009c3:	39 da                	cmp    %ebx,%edx
  8009c5:	74 07                	je     8009ce <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009c7:	83 c0 01             	add    $0x1,%eax
  8009ca:	39 c8                	cmp    %ecx,%eax
  8009cc:	72 f2                	jb     8009c0 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ce:	5b                   	pop    %ebx
  8009cf:	5d                   	pop    %ebp
  8009d0:	c3                   	ret    

008009d1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	57                   	push   %edi
  8009d5:	56                   	push   %esi
  8009d6:	53                   	push   %ebx
  8009d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009da:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009dd:	eb 03                	jmp    8009e2 <strtol+0x11>
		s++;
  8009df:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e2:	0f b6 01             	movzbl (%ecx),%eax
  8009e5:	3c 20                	cmp    $0x20,%al
  8009e7:	74 f6                	je     8009df <strtol+0xe>
  8009e9:	3c 09                	cmp    $0x9,%al
  8009eb:	74 f2                	je     8009df <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009ed:	3c 2b                	cmp    $0x2b,%al
  8009ef:	75 0a                	jne    8009fb <strtol+0x2a>
		s++;
  8009f1:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009f4:	bf 00 00 00 00       	mov    $0x0,%edi
  8009f9:	eb 11                	jmp    800a0c <strtol+0x3b>
  8009fb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a00:	3c 2d                	cmp    $0x2d,%al
  800a02:	75 08                	jne    800a0c <strtol+0x3b>
		s++, neg = 1;
  800a04:	83 c1 01             	add    $0x1,%ecx
  800a07:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a0c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a12:	75 15                	jne    800a29 <strtol+0x58>
  800a14:	80 39 30             	cmpb   $0x30,(%ecx)
  800a17:	75 10                	jne    800a29 <strtol+0x58>
  800a19:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a1d:	75 7c                	jne    800a9b <strtol+0xca>
		s += 2, base = 16;
  800a1f:	83 c1 02             	add    $0x2,%ecx
  800a22:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a27:	eb 16                	jmp    800a3f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a29:	85 db                	test   %ebx,%ebx
  800a2b:	75 12                	jne    800a3f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a2d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a32:	80 39 30             	cmpb   $0x30,(%ecx)
  800a35:	75 08                	jne    800a3f <strtol+0x6e>
		s++, base = 8;
  800a37:	83 c1 01             	add    $0x1,%ecx
  800a3a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a44:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a47:	0f b6 11             	movzbl (%ecx),%edx
  800a4a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a4d:	89 f3                	mov    %esi,%ebx
  800a4f:	80 fb 09             	cmp    $0x9,%bl
  800a52:	77 08                	ja     800a5c <strtol+0x8b>
			dig = *s - '0';
  800a54:	0f be d2             	movsbl %dl,%edx
  800a57:	83 ea 30             	sub    $0x30,%edx
  800a5a:	eb 22                	jmp    800a7e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a5c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a5f:	89 f3                	mov    %esi,%ebx
  800a61:	80 fb 19             	cmp    $0x19,%bl
  800a64:	77 08                	ja     800a6e <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a66:	0f be d2             	movsbl %dl,%edx
  800a69:	83 ea 57             	sub    $0x57,%edx
  800a6c:	eb 10                	jmp    800a7e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a6e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a71:	89 f3                	mov    %esi,%ebx
  800a73:	80 fb 19             	cmp    $0x19,%bl
  800a76:	77 16                	ja     800a8e <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a78:	0f be d2             	movsbl %dl,%edx
  800a7b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a7e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a81:	7d 0b                	jge    800a8e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a83:	83 c1 01             	add    $0x1,%ecx
  800a86:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a8a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a8c:	eb b9                	jmp    800a47 <strtol+0x76>

	if (endptr)
  800a8e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a92:	74 0d                	je     800aa1 <strtol+0xd0>
		*endptr = (char *) s;
  800a94:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a97:	89 0e                	mov    %ecx,(%esi)
  800a99:	eb 06                	jmp    800aa1 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a9b:	85 db                	test   %ebx,%ebx
  800a9d:	74 98                	je     800a37 <strtol+0x66>
  800a9f:	eb 9e                	jmp    800a3f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aa1:	89 c2                	mov    %eax,%edx
  800aa3:	f7 da                	neg    %edx
  800aa5:	85 ff                	test   %edi,%edi
  800aa7:	0f 45 c2             	cmovne %edx,%eax
}
  800aaa:	5b                   	pop    %ebx
  800aab:	5e                   	pop    %esi
  800aac:	5f                   	pop    %edi
  800aad:	5d                   	pop    %ebp
  800aae:	c3                   	ret    

00800aaf <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	57                   	push   %edi
  800ab3:	56                   	push   %esi
  800ab4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800abd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac0:	89 c3                	mov    %eax,%ebx
  800ac2:	89 c7                	mov    %eax,%edi
  800ac4:	89 c6                	mov    %eax,%esi
  800ac6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5f                   	pop    %edi
  800acb:	5d                   	pop    %ebp
  800acc:	c3                   	ret    

00800acd <sys_cgetc>:

int
sys_cgetc(void)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	57                   	push   %edi
  800ad1:	56                   	push   %esi
  800ad2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad8:	b8 01 00 00 00       	mov    $0x1,%eax
  800add:	89 d1                	mov    %edx,%ecx
  800adf:	89 d3                	mov    %edx,%ebx
  800ae1:	89 d7                	mov    %edx,%edi
  800ae3:	89 d6                	mov    %edx,%esi
  800ae5:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ae7:	5b                   	pop    %ebx
  800ae8:	5e                   	pop    %esi
  800ae9:	5f                   	pop    %edi
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	57                   	push   %edi
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
  800af2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800afa:	b8 03 00 00 00       	mov    $0x3,%eax
  800aff:	8b 55 08             	mov    0x8(%ebp),%edx
  800b02:	89 cb                	mov    %ecx,%ebx
  800b04:	89 cf                	mov    %ecx,%edi
  800b06:	89 ce                	mov    %ecx,%esi
  800b08:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b0a:	85 c0                	test   %eax,%eax
  800b0c:	7e 17                	jle    800b25 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b0e:	83 ec 0c             	sub    $0xc,%esp
  800b11:	50                   	push   %eax
  800b12:	6a 03                	push   $0x3
  800b14:	68 1f 24 80 00       	push   $0x80241f
  800b19:	6a 23                	push   $0x23
  800b1b:	68 3c 24 80 00       	push   $0x80243c
  800b20:	e8 4f 11 00 00       	call   801c74 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b28:	5b                   	pop    %ebx
  800b29:	5e                   	pop    %esi
  800b2a:	5f                   	pop    %edi
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	57                   	push   %edi
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b33:	ba 00 00 00 00       	mov    $0x0,%edx
  800b38:	b8 02 00 00 00       	mov    $0x2,%eax
  800b3d:	89 d1                	mov    %edx,%ecx
  800b3f:	89 d3                	mov    %edx,%ebx
  800b41:	89 d7                	mov    %edx,%edi
  800b43:	89 d6                	mov    %edx,%esi
  800b45:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b47:	5b                   	pop    %ebx
  800b48:	5e                   	pop    %esi
  800b49:	5f                   	pop    %edi
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <sys_yield>:

void
sys_yield(void)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	57                   	push   %edi
  800b50:	56                   	push   %esi
  800b51:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b52:	ba 00 00 00 00       	mov    $0x0,%edx
  800b57:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b5c:	89 d1                	mov    %edx,%ecx
  800b5e:	89 d3                	mov    %edx,%ebx
  800b60:	89 d7                	mov    %edx,%edi
  800b62:	89 d6                	mov    %edx,%esi
  800b64:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b66:	5b                   	pop    %ebx
  800b67:	5e                   	pop    %esi
  800b68:	5f                   	pop    %edi
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	57                   	push   %edi
  800b6f:	56                   	push   %esi
  800b70:	53                   	push   %ebx
  800b71:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b74:	be 00 00 00 00       	mov    $0x0,%esi
  800b79:	b8 04 00 00 00       	mov    $0x4,%eax
  800b7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b81:	8b 55 08             	mov    0x8(%ebp),%edx
  800b84:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b87:	89 f7                	mov    %esi,%edi
  800b89:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b8b:	85 c0                	test   %eax,%eax
  800b8d:	7e 17                	jle    800ba6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8f:	83 ec 0c             	sub    $0xc,%esp
  800b92:	50                   	push   %eax
  800b93:	6a 04                	push   $0x4
  800b95:	68 1f 24 80 00       	push   $0x80241f
  800b9a:	6a 23                	push   $0x23
  800b9c:	68 3c 24 80 00       	push   $0x80243c
  800ba1:	e8 ce 10 00 00       	call   801c74 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ba6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb7:	b8 05 00 00 00       	mov    $0x5,%eax
  800bbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bc8:	8b 75 18             	mov    0x18(%ebp),%esi
  800bcb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bcd:	85 c0                	test   %eax,%eax
  800bcf:	7e 17                	jle    800be8 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd1:	83 ec 0c             	sub    $0xc,%esp
  800bd4:	50                   	push   %eax
  800bd5:	6a 05                	push   $0x5
  800bd7:	68 1f 24 80 00       	push   $0x80241f
  800bdc:	6a 23                	push   $0x23
  800bde:	68 3c 24 80 00       	push   $0x80243c
  800be3:	e8 8c 10 00 00       	call   801c74 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800be8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800beb:	5b                   	pop    %ebx
  800bec:	5e                   	pop    %esi
  800bed:	5f                   	pop    %edi
  800bee:	5d                   	pop    %ebp
  800bef:	c3                   	ret    

00800bf0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	57                   	push   %edi
  800bf4:	56                   	push   %esi
  800bf5:	53                   	push   %ebx
  800bf6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bfe:	b8 06 00 00 00       	mov    $0x6,%eax
  800c03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c06:	8b 55 08             	mov    0x8(%ebp),%edx
  800c09:	89 df                	mov    %ebx,%edi
  800c0b:	89 de                	mov    %ebx,%esi
  800c0d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c0f:	85 c0                	test   %eax,%eax
  800c11:	7e 17                	jle    800c2a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c13:	83 ec 0c             	sub    $0xc,%esp
  800c16:	50                   	push   %eax
  800c17:	6a 06                	push   $0x6
  800c19:	68 1f 24 80 00       	push   $0x80241f
  800c1e:	6a 23                	push   $0x23
  800c20:	68 3c 24 80 00       	push   $0x80243c
  800c25:	e8 4a 10 00 00       	call   801c74 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5f                   	pop    %edi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    

00800c32 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	57                   	push   %edi
  800c36:	56                   	push   %esi
  800c37:	53                   	push   %ebx
  800c38:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c40:	b8 08 00 00 00       	mov    $0x8,%eax
  800c45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c48:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4b:	89 df                	mov    %ebx,%edi
  800c4d:	89 de                	mov    %ebx,%esi
  800c4f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c51:	85 c0                	test   %eax,%eax
  800c53:	7e 17                	jle    800c6c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c55:	83 ec 0c             	sub    $0xc,%esp
  800c58:	50                   	push   %eax
  800c59:	6a 08                	push   $0x8
  800c5b:	68 1f 24 80 00       	push   $0x80241f
  800c60:	6a 23                	push   $0x23
  800c62:	68 3c 24 80 00       	push   $0x80243c
  800c67:	e8 08 10 00 00       	call   801c74 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
  800c7a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c82:	b8 09 00 00 00       	mov    $0x9,%eax
  800c87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8d:	89 df                	mov    %ebx,%edi
  800c8f:	89 de                	mov    %ebx,%esi
  800c91:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c93:	85 c0                	test   %eax,%eax
  800c95:	7e 17                	jle    800cae <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c97:	83 ec 0c             	sub    $0xc,%esp
  800c9a:	50                   	push   %eax
  800c9b:	6a 09                	push   $0x9
  800c9d:	68 1f 24 80 00       	push   $0x80241f
  800ca2:	6a 23                	push   $0x23
  800ca4:	68 3c 24 80 00       	push   $0x80243c
  800ca9:	e8 c6 0f 00 00       	call   801c74 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    

00800cb6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
  800cbc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccf:	89 df                	mov    %ebx,%edi
  800cd1:	89 de                	mov    %ebx,%esi
  800cd3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd5:	85 c0                	test   %eax,%eax
  800cd7:	7e 17                	jle    800cf0 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd9:	83 ec 0c             	sub    $0xc,%esp
  800cdc:	50                   	push   %eax
  800cdd:	6a 0a                	push   $0xa
  800cdf:	68 1f 24 80 00       	push   $0x80241f
  800ce4:	6a 23                	push   $0x23
  800ce6:	68 3c 24 80 00       	push   $0x80243c
  800ceb:	e8 84 0f 00 00       	call   801c74 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cf0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5f                   	pop    %edi
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    

00800cf8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	57                   	push   %edi
  800cfc:	56                   	push   %esi
  800cfd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfe:	be 00 00 00 00       	mov    $0x0,%esi
  800d03:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d11:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d14:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	57                   	push   %edi
  800d1f:	56                   	push   %esi
  800d20:	53                   	push   %ebx
  800d21:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d24:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d29:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d31:	89 cb                	mov    %ecx,%ebx
  800d33:	89 cf                	mov    %ecx,%edi
  800d35:	89 ce                	mov    %ecx,%esi
  800d37:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	7e 17                	jle    800d54 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3d:	83 ec 0c             	sub    $0xc,%esp
  800d40:	50                   	push   %eax
  800d41:	6a 0d                	push   $0xd
  800d43:	68 1f 24 80 00       	push   $0x80241f
  800d48:	6a 23                	push   $0x23
  800d4a:	68 3c 24 80 00       	push   $0x80243c
  800d4f:	e8 20 0f 00 00       	call   801c74 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d57:	5b                   	pop    %ebx
  800d58:	5e                   	pop    %esi
  800d59:	5f                   	pop    %edi
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    

00800d5c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
  800d61:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d64:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800d66:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d6a:	75 25                	jne    800d91 <pgfault+0x35>
  800d6c:	89 d8                	mov    %ebx,%eax
  800d6e:	c1 e8 0c             	shr    $0xc,%eax
  800d71:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d78:	f6 c4 08             	test   $0x8,%ah
  800d7b:	75 14                	jne    800d91 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800d7d:	83 ec 04             	sub    $0x4,%esp
  800d80:	68 4c 24 80 00       	push   $0x80244c
  800d85:	6a 1e                	push   $0x1e
  800d87:	68 e0 24 80 00       	push   $0x8024e0
  800d8c:	e8 e3 0e 00 00       	call   801c74 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800d91:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800d97:	e8 91 fd ff ff       	call   800b2d <sys_getenvid>
  800d9c:	89 c6                	mov    %eax,%esi

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800d9e:	83 ec 04             	sub    $0x4,%esp
  800da1:	6a 07                	push   $0x7
  800da3:	68 00 f0 7f 00       	push   $0x7ff000
  800da8:	50                   	push   %eax
  800da9:	e8 bd fd ff ff       	call   800b6b <sys_page_alloc>
	if (r < 0)
  800dae:	83 c4 10             	add    $0x10,%esp
  800db1:	85 c0                	test   %eax,%eax
  800db3:	79 12                	jns    800dc7 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800db5:	50                   	push   %eax
  800db6:	68 78 24 80 00       	push   $0x802478
  800dbb:	6a 31                	push   $0x31
  800dbd:	68 e0 24 80 00       	push   $0x8024e0
  800dc2:	e8 ad 0e 00 00       	call   801c74 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800dc7:	83 ec 04             	sub    $0x4,%esp
  800dca:	68 00 10 00 00       	push   $0x1000
  800dcf:	53                   	push   %ebx
  800dd0:	68 00 f0 7f 00       	push   $0x7ff000
  800dd5:	e8 88 fb ff ff       	call   800962 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800dda:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800de1:	53                   	push   %ebx
  800de2:	56                   	push   %esi
  800de3:	68 00 f0 7f 00       	push   $0x7ff000
  800de8:	56                   	push   %esi
  800de9:	e8 c0 fd ff ff       	call   800bae <sys_page_map>
	if (r < 0)
  800dee:	83 c4 20             	add    $0x20,%esp
  800df1:	85 c0                	test   %eax,%eax
  800df3:	79 12                	jns    800e07 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800df5:	50                   	push   %eax
  800df6:	68 9c 24 80 00       	push   $0x80249c
  800dfb:	6a 39                	push   $0x39
  800dfd:	68 e0 24 80 00       	push   $0x8024e0
  800e02:	e8 6d 0e 00 00       	call   801c74 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800e07:	83 ec 08             	sub    $0x8,%esp
  800e0a:	68 00 f0 7f 00       	push   $0x7ff000
  800e0f:	56                   	push   %esi
  800e10:	e8 db fd ff ff       	call   800bf0 <sys_page_unmap>
	if (r < 0)
  800e15:	83 c4 10             	add    $0x10,%esp
  800e18:	85 c0                	test   %eax,%eax
  800e1a:	79 12                	jns    800e2e <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800e1c:	50                   	push   %eax
  800e1d:	68 c0 24 80 00       	push   $0x8024c0
  800e22:	6a 3e                	push   $0x3e
  800e24:	68 e0 24 80 00       	push   $0x8024e0
  800e29:	e8 46 0e 00 00       	call   801c74 <_panic>
}
  800e2e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e31:	5b                   	pop    %ebx
  800e32:	5e                   	pop    %esi
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    

00800e35 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	57                   	push   %edi
  800e39:	56                   	push   %esi
  800e3a:	53                   	push   %ebx
  800e3b:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800e3e:	68 5c 0d 80 00       	push   $0x800d5c
  800e43:	e8 72 0e 00 00       	call   801cba <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e48:	b8 07 00 00 00       	mov    $0x7,%eax
  800e4d:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800e4f:	83 c4 10             	add    $0x10,%esp
  800e52:	85 c0                	test   %eax,%eax
  800e54:	0f 88 3a 01 00 00    	js     800f94 <fork+0x15f>
  800e5a:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800e5f:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800e64:	85 c0                	test   %eax,%eax
  800e66:	75 21                	jne    800e89 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e68:	e8 c0 fc ff ff       	call   800b2d <sys_getenvid>
  800e6d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e72:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e75:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e7a:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  800e7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e84:	e9 0b 01 00 00       	jmp    800f94 <fork+0x15f>
  800e89:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e8c:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800e8e:	89 d8                	mov    %ebx,%eax
  800e90:	c1 e8 16             	shr    $0x16,%eax
  800e93:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e9a:	a8 01                	test   $0x1,%al
  800e9c:	0f 84 99 00 00 00    	je     800f3b <fork+0x106>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800ea2:	89 d8                	mov    %ebx,%eax
  800ea4:	c1 e8 0c             	shr    $0xc,%eax
  800ea7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800eae:	f6 c2 01             	test   $0x1,%dl
  800eb1:	0f 84 84 00 00 00    	je     800f3b <fork+0x106>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
  800eb7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ebe:	a9 02 08 00 00       	test   $0x802,%eax
  800ec3:	74 76                	je     800f3b <fork+0x106>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;
	
	if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800ec5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ecc:	a8 02                	test   $0x2,%al
  800ece:	75 0c                	jne    800edc <fork+0xa7>
  800ed0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ed7:	f6 c4 08             	test   $0x8,%ah
  800eda:	74 3f                	je     800f1b <fork+0xe6>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800edc:	83 ec 0c             	sub    $0xc,%esp
  800edf:	68 05 08 00 00       	push   $0x805
  800ee4:	53                   	push   %ebx
  800ee5:	57                   	push   %edi
  800ee6:	53                   	push   %ebx
  800ee7:	6a 00                	push   $0x0
  800ee9:	e8 c0 fc ff ff       	call   800bae <sys_page_map>
		if (r < 0)
  800eee:	83 c4 20             	add    $0x20,%esp
  800ef1:	85 c0                	test   %eax,%eax
  800ef3:	0f 88 9b 00 00 00    	js     800f94 <fork+0x15f>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800ef9:	83 ec 0c             	sub    $0xc,%esp
  800efc:	68 05 08 00 00       	push   $0x805
  800f01:	53                   	push   %ebx
  800f02:	6a 00                	push   $0x0
  800f04:	53                   	push   %ebx
  800f05:	6a 00                	push   $0x0
  800f07:	e8 a2 fc ff ff       	call   800bae <sys_page_map>
  800f0c:	83 c4 20             	add    $0x20,%esp
  800f0f:	85 c0                	test   %eax,%eax
  800f11:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f16:	0f 4f c1             	cmovg  %ecx,%eax
  800f19:	eb 1c                	jmp    800f37 <fork+0x102>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800f1b:	83 ec 0c             	sub    $0xc,%esp
  800f1e:	6a 05                	push   $0x5
  800f20:	53                   	push   %ebx
  800f21:	57                   	push   %edi
  800f22:	53                   	push   %ebx
  800f23:	6a 00                	push   $0x0
  800f25:	e8 84 fc ff ff       	call   800bae <sys_page_map>
  800f2a:	83 c4 20             	add    $0x20,%esp
  800f2d:	85 c0                	test   %eax,%eax
  800f2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f34:	0f 4f c1             	cmovg  %ecx,%eax
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  800f37:	85 c0                	test   %eax,%eax
  800f39:	78 59                	js     800f94 <fork+0x15f>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  800f3b:	83 c6 01             	add    $0x1,%esi
  800f3e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f44:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  800f4a:	0f 85 3e ff ff ff    	jne    800e8e <fork+0x59>
  800f50:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  800f53:	83 ec 04             	sub    $0x4,%esp
  800f56:	6a 07                	push   $0x7
  800f58:	68 00 f0 bf ee       	push   $0xeebff000
  800f5d:	57                   	push   %edi
  800f5e:	e8 08 fc ff ff       	call   800b6b <sys_page_alloc>
	if (r < 0)
  800f63:	83 c4 10             	add    $0x10,%esp
  800f66:	85 c0                	test   %eax,%eax
  800f68:	78 2a                	js     800f94 <fork+0x15f>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800f6a:	83 ec 08             	sub    $0x8,%esp
  800f6d:	68 01 1d 80 00       	push   $0x801d01
  800f72:	57                   	push   %edi
  800f73:	e8 3e fd ff ff       	call   800cb6 <sys_env_set_pgfault_upcall>
	if (r < 0)
  800f78:	83 c4 10             	add    $0x10,%esp
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	78 15                	js     800f94 <fork+0x15f>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  800f7f:	83 ec 08             	sub    $0x8,%esp
  800f82:	6a 02                	push   $0x2
  800f84:	57                   	push   %edi
  800f85:	e8 a8 fc ff ff       	call   800c32 <sys_env_set_status>
	if (r < 0)
  800f8a:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	0f 49 c7             	cmovns %edi,%eax
  800f92:	eb 00                	jmp    800f94 <fork+0x15f>
	// panic("fork not implemented");
}
  800f94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f97:	5b                   	pop    %ebx
  800f98:	5e                   	pop    %esi
  800f99:	5f                   	pop    %edi
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    

00800f9c <sfork>:

// Challenge!
int
sfork(void)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fa2:	68 eb 24 80 00       	push   $0x8024eb
  800fa7:	68 c3 00 00 00       	push   $0xc3
  800fac:	68 e0 24 80 00       	push   $0x8024e0
  800fb1:	e8 be 0c 00 00       	call   801c74 <_panic>

00800fb6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800fb6:	55                   	push   %ebp
  800fb7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbc:	05 00 00 00 30       	add    $0x30000000,%eax
  800fc1:	c1 e8 0c             	shr    $0xc,%eax
}
  800fc4:	5d                   	pop    %ebp
  800fc5:	c3                   	ret    

00800fc6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800fc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fcc:	05 00 00 00 30       	add    $0x30000000,%eax
  800fd1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800fd6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800fdb:	5d                   	pop    %ebp
  800fdc:	c3                   	ret    

00800fdd <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800fdd:	55                   	push   %ebp
  800fde:	89 e5                	mov    %esp,%ebp
  800fe0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fe3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800fe8:	89 c2                	mov    %eax,%edx
  800fea:	c1 ea 16             	shr    $0x16,%edx
  800fed:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ff4:	f6 c2 01             	test   $0x1,%dl
  800ff7:	74 11                	je     80100a <fd_alloc+0x2d>
  800ff9:	89 c2                	mov    %eax,%edx
  800ffb:	c1 ea 0c             	shr    $0xc,%edx
  800ffe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801005:	f6 c2 01             	test   $0x1,%dl
  801008:	75 09                	jne    801013 <fd_alloc+0x36>
			*fd_store = fd;
  80100a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80100c:	b8 00 00 00 00       	mov    $0x0,%eax
  801011:	eb 17                	jmp    80102a <fd_alloc+0x4d>
  801013:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801018:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80101d:	75 c9                	jne    800fe8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80101f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801025:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80102a:	5d                   	pop    %ebp
  80102b:	c3                   	ret    

0080102c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801032:	83 f8 1f             	cmp    $0x1f,%eax
  801035:	77 36                	ja     80106d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801037:	c1 e0 0c             	shl    $0xc,%eax
  80103a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80103f:	89 c2                	mov    %eax,%edx
  801041:	c1 ea 16             	shr    $0x16,%edx
  801044:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80104b:	f6 c2 01             	test   $0x1,%dl
  80104e:	74 24                	je     801074 <fd_lookup+0x48>
  801050:	89 c2                	mov    %eax,%edx
  801052:	c1 ea 0c             	shr    $0xc,%edx
  801055:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80105c:	f6 c2 01             	test   $0x1,%dl
  80105f:	74 1a                	je     80107b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801061:	8b 55 0c             	mov    0xc(%ebp),%edx
  801064:	89 02                	mov    %eax,(%edx)
	return 0;
  801066:	b8 00 00 00 00       	mov    $0x0,%eax
  80106b:	eb 13                	jmp    801080 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80106d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801072:	eb 0c                	jmp    801080 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801074:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801079:	eb 05                	jmp    801080 <fd_lookup+0x54>
  80107b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801080:	5d                   	pop    %ebp
  801081:	c3                   	ret    

00801082 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	83 ec 08             	sub    $0x8,%esp
  801088:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80108b:	ba 80 25 80 00       	mov    $0x802580,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801090:	eb 13                	jmp    8010a5 <dev_lookup+0x23>
  801092:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801095:	39 08                	cmp    %ecx,(%eax)
  801097:	75 0c                	jne    8010a5 <dev_lookup+0x23>
			*dev = devtab[i];
  801099:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80109c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80109e:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a3:	eb 2e                	jmp    8010d3 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8010a5:	8b 02                	mov    (%edx),%eax
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	75 e7                	jne    801092 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8010ab:	a1 04 40 80 00       	mov    0x804004,%eax
  8010b0:	8b 40 48             	mov    0x48(%eax),%eax
  8010b3:	83 ec 04             	sub    $0x4,%esp
  8010b6:	51                   	push   %ecx
  8010b7:	50                   	push   %eax
  8010b8:	68 04 25 80 00       	push   $0x802504
  8010bd:	e8 21 f1 ff ff       	call   8001e3 <cprintf>
	*dev = 0;
  8010c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010c5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8010cb:	83 c4 10             	add    $0x10,%esp
  8010ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010d3:	c9                   	leave  
  8010d4:	c3                   	ret    

008010d5 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8010d5:	55                   	push   %ebp
  8010d6:	89 e5                	mov    %esp,%ebp
  8010d8:	56                   	push   %esi
  8010d9:	53                   	push   %ebx
  8010da:	83 ec 10             	sub    $0x10,%esp
  8010dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8010e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e6:	50                   	push   %eax
  8010e7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8010ed:	c1 e8 0c             	shr    $0xc,%eax
  8010f0:	50                   	push   %eax
  8010f1:	e8 36 ff ff ff       	call   80102c <fd_lookup>
  8010f6:	83 c4 08             	add    $0x8,%esp
  8010f9:	85 c0                	test   %eax,%eax
  8010fb:	78 05                	js     801102 <fd_close+0x2d>
	    || fd != fd2)
  8010fd:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801100:	74 0c                	je     80110e <fd_close+0x39>
		return (must_exist ? r : 0);
  801102:	84 db                	test   %bl,%bl
  801104:	ba 00 00 00 00       	mov    $0x0,%edx
  801109:	0f 44 c2             	cmove  %edx,%eax
  80110c:	eb 41                	jmp    80114f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80110e:	83 ec 08             	sub    $0x8,%esp
  801111:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801114:	50                   	push   %eax
  801115:	ff 36                	pushl  (%esi)
  801117:	e8 66 ff ff ff       	call   801082 <dev_lookup>
  80111c:	89 c3                	mov    %eax,%ebx
  80111e:	83 c4 10             	add    $0x10,%esp
  801121:	85 c0                	test   %eax,%eax
  801123:	78 1a                	js     80113f <fd_close+0x6a>
		if (dev->dev_close)
  801125:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801128:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80112b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801130:	85 c0                	test   %eax,%eax
  801132:	74 0b                	je     80113f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801134:	83 ec 0c             	sub    $0xc,%esp
  801137:	56                   	push   %esi
  801138:	ff d0                	call   *%eax
  80113a:	89 c3                	mov    %eax,%ebx
  80113c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80113f:	83 ec 08             	sub    $0x8,%esp
  801142:	56                   	push   %esi
  801143:	6a 00                	push   $0x0
  801145:	e8 a6 fa ff ff       	call   800bf0 <sys_page_unmap>
	return r;
  80114a:	83 c4 10             	add    $0x10,%esp
  80114d:	89 d8                	mov    %ebx,%eax
}
  80114f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801152:	5b                   	pop    %ebx
  801153:	5e                   	pop    %esi
  801154:	5d                   	pop    %ebp
  801155:	c3                   	ret    

00801156 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80115c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80115f:	50                   	push   %eax
  801160:	ff 75 08             	pushl  0x8(%ebp)
  801163:	e8 c4 fe ff ff       	call   80102c <fd_lookup>
  801168:	83 c4 08             	add    $0x8,%esp
  80116b:	85 c0                	test   %eax,%eax
  80116d:	78 10                	js     80117f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80116f:	83 ec 08             	sub    $0x8,%esp
  801172:	6a 01                	push   $0x1
  801174:	ff 75 f4             	pushl  -0xc(%ebp)
  801177:	e8 59 ff ff ff       	call   8010d5 <fd_close>
  80117c:	83 c4 10             	add    $0x10,%esp
}
  80117f:	c9                   	leave  
  801180:	c3                   	ret    

00801181 <close_all>:

void
close_all(void)
{
  801181:	55                   	push   %ebp
  801182:	89 e5                	mov    %esp,%ebp
  801184:	53                   	push   %ebx
  801185:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801188:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80118d:	83 ec 0c             	sub    $0xc,%esp
  801190:	53                   	push   %ebx
  801191:	e8 c0 ff ff ff       	call   801156 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801196:	83 c3 01             	add    $0x1,%ebx
  801199:	83 c4 10             	add    $0x10,%esp
  80119c:	83 fb 20             	cmp    $0x20,%ebx
  80119f:	75 ec                	jne    80118d <close_all+0xc>
		close(i);
}
  8011a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a4:	c9                   	leave  
  8011a5:	c3                   	ret    

008011a6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011a6:	55                   	push   %ebp
  8011a7:	89 e5                	mov    %esp,%ebp
  8011a9:	57                   	push   %edi
  8011aa:	56                   	push   %esi
  8011ab:	53                   	push   %ebx
  8011ac:	83 ec 2c             	sub    $0x2c,%esp
  8011af:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011b2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011b5:	50                   	push   %eax
  8011b6:	ff 75 08             	pushl  0x8(%ebp)
  8011b9:	e8 6e fe ff ff       	call   80102c <fd_lookup>
  8011be:	83 c4 08             	add    $0x8,%esp
  8011c1:	85 c0                	test   %eax,%eax
  8011c3:	0f 88 c1 00 00 00    	js     80128a <dup+0xe4>
		return r;
	close(newfdnum);
  8011c9:	83 ec 0c             	sub    $0xc,%esp
  8011cc:	56                   	push   %esi
  8011cd:	e8 84 ff ff ff       	call   801156 <close>

	newfd = INDEX2FD(newfdnum);
  8011d2:	89 f3                	mov    %esi,%ebx
  8011d4:	c1 e3 0c             	shl    $0xc,%ebx
  8011d7:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8011dd:	83 c4 04             	add    $0x4,%esp
  8011e0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011e3:	e8 de fd ff ff       	call   800fc6 <fd2data>
  8011e8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8011ea:	89 1c 24             	mov    %ebx,(%esp)
  8011ed:	e8 d4 fd ff ff       	call   800fc6 <fd2data>
  8011f2:	83 c4 10             	add    $0x10,%esp
  8011f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011f8:	89 f8                	mov    %edi,%eax
  8011fa:	c1 e8 16             	shr    $0x16,%eax
  8011fd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801204:	a8 01                	test   $0x1,%al
  801206:	74 37                	je     80123f <dup+0x99>
  801208:	89 f8                	mov    %edi,%eax
  80120a:	c1 e8 0c             	shr    $0xc,%eax
  80120d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801214:	f6 c2 01             	test   $0x1,%dl
  801217:	74 26                	je     80123f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801219:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801220:	83 ec 0c             	sub    $0xc,%esp
  801223:	25 07 0e 00 00       	and    $0xe07,%eax
  801228:	50                   	push   %eax
  801229:	ff 75 d4             	pushl  -0x2c(%ebp)
  80122c:	6a 00                	push   $0x0
  80122e:	57                   	push   %edi
  80122f:	6a 00                	push   $0x0
  801231:	e8 78 f9 ff ff       	call   800bae <sys_page_map>
  801236:	89 c7                	mov    %eax,%edi
  801238:	83 c4 20             	add    $0x20,%esp
  80123b:	85 c0                	test   %eax,%eax
  80123d:	78 2e                	js     80126d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80123f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801242:	89 d0                	mov    %edx,%eax
  801244:	c1 e8 0c             	shr    $0xc,%eax
  801247:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80124e:	83 ec 0c             	sub    $0xc,%esp
  801251:	25 07 0e 00 00       	and    $0xe07,%eax
  801256:	50                   	push   %eax
  801257:	53                   	push   %ebx
  801258:	6a 00                	push   $0x0
  80125a:	52                   	push   %edx
  80125b:	6a 00                	push   $0x0
  80125d:	e8 4c f9 ff ff       	call   800bae <sys_page_map>
  801262:	89 c7                	mov    %eax,%edi
  801264:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801267:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801269:	85 ff                	test   %edi,%edi
  80126b:	79 1d                	jns    80128a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80126d:	83 ec 08             	sub    $0x8,%esp
  801270:	53                   	push   %ebx
  801271:	6a 00                	push   $0x0
  801273:	e8 78 f9 ff ff       	call   800bf0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801278:	83 c4 08             	add    $0x8,%esp
  80127b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80127e:	6a 00                	push   $0x0
  801280:	e8 6b f9 ff ff       	call   800bf0 <sys_page_unmap>
	return r;
  801285:	83 c4 10             	add    $0x10,%esp
  801288:	89 f8                	mov    %edi,%eax
}
  80128a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80128d:	5b                   	pop    %ebx
  80128e:	5e                   	pop    %esi
  80128f:	5f                   	pop    %edi
  801290:	5d                   	pop    %ebp
  801291:	c3                   	ret    

00801292 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
  801295:	53                   	push   %ebx
  801296:	83 ec 14             	sub    $0x14,%esp
  801299:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80129c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80129f:	50                   	push   %eax
  8012a0:	53                   	push   %ebx
  8012a1:	e8 86 fd ff ff       	call   80102c <fd_lookup>
  8012a6:	83 c4 08             	add    $0x8,%esp
  8012a9:	89 c2                	mov    %eax,%edx
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	78 6d                	js     80131c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012af:	83 ec 08             	sub    $0x8,%esp
  8012b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b5:	50                   	push   %eax
  8012b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b9:	ff 30                	pushl  (%eax)
  8012bb:	e8 c2 fd ff ff       	call   801082 <dev_lookup>
  8012c0:	83 c4 10             	add    $0x10,%esp
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	78 4c                	js     801313 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8012c7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012ca:	8b 42 08             	mov    0x8(%edx),%eax
  8012cd:	83 e0 03             	and    $0x3,%eax
  8012d0:	83 f8 01             	cmp    $0x1,%eax
  8012d3:	75 21                	jne    8012f6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012d5:	a1 04 40 80 00       	mov    0x804004,%eax
  8012da:	8b 40 48             	mov    0x48(%eax),%eax
  8012dd:	83 ec 04             	sub    $0x4,%esp
  8012e0:	53                   	push   %ebx
  8012e1:	50                   	push   %eax
  8012e2:	68 45 25 80 00       	push   $0x802545
  8012e7:	e8 f7 ee ff ff       	call   8001e3 <cprintf>
		return -E_INVAL;
  8012ec:	83 c4 10             	add    $0x10,%esp
  8012ef:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012f4:	eb 26                	jmp    80131c <read+0x8a>
	}
	if (!dev->dev_read)
  8012f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f9:	8b 40 08             	mov    0x8(%eax),%eax
  8012fc:	85 c0                	test   %eax,%eax
  8012fe:	74 17                	je     801317 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801300:	83 ec 04             	sub    $0x4,%esp
  801303:	ff 75 10             	pushl  0x10(%ebp)
  801306:	ff 75 0c             	pushl  0xc(%ebp)
  801309:	52                   	push   %edx
  80130a:	ff d0                	call   *%eax
  80130c:	89 c2                	mov    %eax,%edx
  80130e:	83 c4 10             	add    $0x10,%esp
  801311:	eb 09                	jmp    80131c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801313:	89 c2                	mov    %eax,%edx
  801315:	eb 05                	jmp    80131c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801317:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80131c:	89 d0                	mov    %edx,%eax
  80131e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801321:	c9                   	leave  
  801322:	c3                   	ret    

00801323 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	57                   	push   %edi
  801327:	56                   	push   %esi
  801328:	53                   	push   %ebx
  801329:	83 ec 0c             	sub    $0xc,%esp
  80132c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80132f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801332:	bb 00 00 00 00       	mov    $0x0,%ebx
  801337:	eb 21                	jmp    80135a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801339:	83 ec 04             	sub    $0x4,%esp
  80133c:	89 f0                	mov    %esi,%eax
  80133e:	29 d8                	sub    %ebx,%eax
  801340:	50                   	push   %eax
  801341:	89 d8                	mov    %ebx,%eax
  801343:	03 45 0c             	add    0xc(%ebp),%eax
  801346:	50                   	push   %eax
  801347:	57                   	push   %edi
  801348:	e8 45 ff ff ff       	call   801292 <read>
		if (m < 0)
  80134d:	83 c4 10             	add    $0x10,%esp
  801350:	85 c0                	test   %eax,%eax
  801352:	78 10                	js     801364 <readn+0x41>
			return m;
		if (m == 0)
  801354:	85 c0                	test   %eax,%eax
  801356:	74 0a                	je     801362 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801358:	01 c3                	add    %eax,%ebx
  80135a:	39 f3                	cmp    %esi,%ebx
  80135c:	72 db                	jb     801339 <readn+0x16>
  80135e:	89 d8                	mov    %ebx,%eax
  801360:	eb 02                	jmp    801364 <readn+0x41>
  801362:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801364:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801367:	5b                   	pop    %ebx
  801368:	5e                   	pop    %esi
  801369:	5f                   	pop    %edi
  80136a:	5d                   	pop    %ebp
  80136b:	c3                   	ret    

0080136c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80136c:	55                   	push   %ebp
  80136d:	89 e5                	mov    %esp,%ebp
  80136f:	53                   	push   %ebx
  801370:	83 ec 14             	sub    $0x14,%esp
  801373:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801376:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801379:	50                   	push   %eax
  80137a:	53                   	push   %ebx
  80137b:	e8 ac fc ff ff       	call   80102c <fd_lookup>
  801380:	83 c4 08             	add    $0x8,%esp
  801383:	89 c2                	mov    %eax,%edx
  801385:	85 c0                	test   %eax,%eax
  801387:	78 68                	js     8013f1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801389:	83 ec 08             	sub    $0x8,%esp
  80138c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80138f:	50                   	push   %eax
  801390:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801393:	ff 30                	pushl  (%eax)
  801395:	e8 e8 fc ff ff       	call   801082 <dev_lookup>
  80139a:	83 c4 10             	add    $0x10,%esp
  80139d:	85 c0                	test   %eax,%eax
  80139f:	78 47                	js     8013e8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013a8:	75 21                	jne    8013cb <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013aa:	a1 04 40 80 00       	mov    0x804004,%eax
  8013af:	8b 40 48             	mov    0x48(%eax),%eax
  8013b2:	83 ec 04             	sub    $0x4,%esp
  8013b5:	53                   	push   %ebx
  8013b6:	50                   	push   %eax
  8013b7:	68 61 25 80 00       	push   $0x802561
  8013bc:	e8 22 ee ff ff       	call   8001e3 <cprintf>
		return -E_INVAL;
  8013c1:	83 c4 10             	add    $0x10,%esp
  8013c4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013c9:	eb 26                	jmp    8013f1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013ce:	8b 52 0c             	mov    0xc(%edx),%edx
  8013d1:	85 d2                	test   %edx,%edx
  8013d3:	74 17                	je     8013ec <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013d5:	83 ec 04             	sub    $0x4,%esp
  8013d8:	ff 75 10             	pushl  0x10(%ebp)
  8013db:	ff 75 0c             	pushl  0xc(%ebp)
  8013de:	50                   	push   %eax
  8013df:	ff d2                	call   *%edx
  8013e1:	89 c2                	mov    %eax,%edx
  8013e3:	83 c4 10             	add    $0x10,%esp
  8013e6:	eb 09                	jmp    8013f1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e8:	89 c2                	mov    %eax,%edx
  8013ea:	eb 05                	jmp    8013f1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8013ec:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8013f1:	89 d0                	mov    %edx,%eax
  8013f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f6:	c9                   	leave  
  8013f7:	c3                   	ret    

008013f8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8013f8:	55                   	push   %ebp
  8013f9:	89 e5                	mov    %esp,%ebp
  8013fb:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013fe:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801401:	50                   	push   %eax
  801402:	ff 75 08             	pushl  0x8(%ebp)
  801405:	e8 22 fc ff ff       	call   80102c <fd_lookup>
  80140a:	83 c4 08             	add    $0x8,%esp
  80140d:	85 c0                	test   %eax,%eax
  80140f:	78 0e                	js     80141f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801411:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801414:	8b 55 0c             	mov    0xc(%ebp),%edx
  801417:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80141a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80141f:	c9                   	leave  
  801420:	c3                   	ret    

00801421 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801421:	55                   	push   %ebp
  801422:	89 e5                	mov    %esp,%ebp
  801424:	53                   	push   %ebx
  801425:	83 ec 14             	sub    $0x14,%esp
  801428:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80142b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80142e:	50                   	push   %eax
  80142f:	53                   	push   %ebx
  801430:	e8 f7 fb ff ff       	call   80102c <fd_lookup>
  801435:	83 c4 08             	add    $0x8,%esp
  801438:	89 c2                	mov    %eax,%edx
  80143a:	85 c0                	test   %eax,%eax
  80143c:	78 65                	js     8014a3 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80143e:	83 ec 08             	sub    $0x8,%esp
  801441:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801444:	50                   	push   %eax
  801445:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801448:	ff 30                	pushl  (%eax)
  80144a:	e8 33 fc ff ff       	call   801082 <dev_lookup>
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	85 c0                	test   %eax,%eax
  801454:	78 44                	js     80149a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801456:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801459:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80145d:	75 21                	jne    801480 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80145f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801464:	8b 40 48             	mov    0x48(%eax),%eax
  801467:	83 ec 04             	sub    $0x4,%esp
  80146a:	53                   	push   %ebx
  80146b:	50                   	push   %eax
  80146c:	68 24 25 80 00       	push   $0x802524
  801471:	e8 6d ed ff ff       	call   8001e3 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801476:	83 c4 10             	add    $0x10,%esp
  801479:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80147e:	eb 23                	jmp    8014a3 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801480:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801483:	8b 52 18             	mov    0x18(%edx),%edx
  801486:	85 d2                	test   %edx,%edx
  801488:	74 14                	je     80149e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80148a:	83 ec 08             	sub    $0x8,%esp
  80148d:	ff 75 0c             	pushl  0xc(%ebp)
  801490:	50                   	push   %eax
  801491:	ff d2                	call   *%edx
  801493:	89 c2                	mov    %eax,%edx
  801495:	83 c4 10             	add    $0x10,%esp
  801498:	eb 09                	jmp    8014a3 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80149a:	89 c2                	mov    %eax,%edx
  80149c:	eb 05                	jmp    8014a3 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80149e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8014a3:	89 d0                	mov    %edx,%eax
  8014a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a8:	c9                   	leave  
  8014a9:	c3                   	ret    

008014aa <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014aa:	55                   	push   %ebp
  8014ab:	89 e5                	mov    %esp,%ebp
  8014ad:	53                   	push   %ebx
  8014ae:	83 ec 14             	sub    $0x14,%esp
  8014b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b7:	50                   	push   %eax
  8014b8:	ff 75 08             	pushl  0x8(%ebp)
  8014bb:	e8 6c fb ff ff       	call   80102c <fd_lookup>
  8014c0:	83 c4 08             	add    $0x8,%esp
  8014c3:	89 c2                	mov    %eax,%edx
  8014c5:	85 c0                	test   %eax,%eax
  8014c7:	78 58                	js     801521 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c9:	83 ec 08             	sub    $0x8,%esp
  8014cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014cf:	50                   	push   %eax
  8014d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d3:	ff 30                	pushl  (%eax)
  8014d5:	e8 a8 fb ff ff       	call   801082 <dev_lookup>
  8014da:	83 c4 10             	add    $0x10,%esp
  8014dd:	85 c0                	test   %eax,%eax
  8014df:	78 37                	js     801518 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8014e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014e8:	74 32                	je     80151c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014ea:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014ed:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014f4:	00 00 00 
	stat->st_isdir = 0;
  8014f7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014fe:	00 00 00 
	stat->st_dev = dev;
  801501:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801507:	83 ec 08             	sub    $0x8,%esp
  80150a:	53                   	push   %ebx
  80150b:	ff 75 f0             	pushl  -0x10(%ebp)
  80150e:	ff 50 14             	call   *0x14(%eax)
  801511:	89 c2                	mov    %eax,%edx
  801513:	83 c4 10             	add    $0x10,%esp
  801516:	eb 09                	jmp    801521 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801518:	89 c2                	mov    %eax,%edx
  80151a:	eb 05                	jmp    801521 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80151c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801521:	89 d0                	mov    %edx,%eax
  801523:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801526:	c9                   	leave  
  801527:	c3                   	ret    

00801528 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801528:	55                   	push   %ebp
  801529:	89 e5                	mov    %esp,%ebp
  80152b:	56                   	push   %esi
  80152c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80152d:	83 ec 08             	sub    $0x8,%esp
  801530:	6a 00                	push   $0x0
  801532:	ff 75 08             	pushl  0x8(%ebp)
  801535:	e8 b7 01 00 00       	call   8016f1 <open>
  80153a:	89 c3                	mov    %eax,%ebx
  80153c:	83 c4 10             	add    $0x10,%esp
  80153f:	85 c0                	test   %eax,%eax
  801541:	78 1b                	js     80155e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801543:	83 ec 08             	sub    $0x8,%esp
  801546:	ff 75 0c             	pushl  0xc(%ebp)
  801549:	50                   	push   %eax
  80154a:	e8 5b ff ff ff       	call   8014aa <fstat>
  80154f:	89 c6                	mov    %eax,%esi
	close(fd);
  801551:	89 1c 24             	mov    %ebx,(%esp)
  801554:	e8 fd fb ff ff       	call   801156 <close>
	return r;
  801559:	83 c4 10             	add    $0x10,%esp
  80155c:	89 f0                	mov    %esi,%eax
}
  80155e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801561:	5b                   	pop    %ebx
  801562:	5e                   	pop    %esi
  801563:	5d                   	pop    %ebp
  801564:	c3                   	ret    

00801565 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801565:	55                   	push   %ebp
  801566:	89 e5                	mov    %esp,%ebp
  801568:	56                   	push   %esi
  801569:	53                   	push   %ebx
  80156a:	89 c6                	mov    %eax,%esi
  80156c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80156e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801575:	75 12                	jne    801589 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801577:	83 ec 0c             	sub    $0xc,%esp
  80157a:	6a 01                	push   $0x1
  80157c:	e8 5f 08 00 00       	call   801de0 <ipc_find_env>
  801581:	a3 00 40 80 00       	mov    %eax,0x804000
  801586:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801589:	6a 07                	push   $0x7
  80158b:	68 00 50 80 00       	push   $0x805000
  801590:	56                   	push   %esi
  801591:	ff 35 00 40 80 00    	pushl  0x804000
  801597:	e8 f0 07 00 00       	call   801d8c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80159c:	83 c4 0c             	add    $0xc,%esp
  80159f:	6a 00                	push   $0x0
  8015a1:	53                   	push   %ebx
  8015a2:	6a 00                	push   $0x0
  8015a4:	e8 7c 07 00 00       	call   801d25 <ipc_recv>
}
  8015a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ac:	5b                   	pop    %ebx
  8015ad:	5e                   	pop    %esi
  8015ae:	5d                   	pop    %ebp
  8015af:	c3                   	ret    

008015b0 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015b0:	55                   	push   %ebp
  8015b1:	89 e5                	mov    %esp,%ebp
  8015b3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8015bc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8015c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c4:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8015c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ce:	b8 02 00 00 00       	mov    $0x2,%eax
  8015d3:	e8 8d ff ff ff       	call   801565 <fsipc>
}
  8015d8:	c9                   	leave  
  8015d9:	c3                   	ret    

008015da <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8015e6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8015eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f0:	b8 06 00 00 00       	mov    $0x6,%eax
  8015f5:	e8 6b ff ff ff       	call   801565 <fsipc>
}
  8015fa:	c9                   	leave  
  8015fb:	c3                   	ret    

008015fc <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8015fc:	55                   	push   %ebp
  8015fd:	89 e5                	mov    %esp,%ebp
  8015ff:	53                   	push   %ebx
  801600:	83 ec 04             	sub    $0x4,%esp
  801603:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801606:	8b 45 08             	mov    0x8(%ebp),%eax
  801609:	8b 40 0c             	mov    0xc(%eax),%eax
  80160c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801611:	ba 00 00 00 00       	mov    $0x0,%edx
  801616:	b8 05 00 00 00       	mov    $0x5,%eax
  80161b:	e8 45 ff ff ff       	call   801565 <fsipc>
  801620:	85 c0                	test   %eax,%eax
  801622:	78 2c                	js     801650 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801624:	83 ec 08             	sub    $0x8,%esp
  801627:	68 00 50 80 00       	push   $0x805000
  80162c:	53                   	push   %ebx
  80162d:	e8 36 f1 ff ff       	call   800768 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801632:	a1 80 50 80 00       	mov    0x805080,%eax
  801637:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80163d:	a1 84 50 80 00       	mov    0x805084,%eax
  801642:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801650:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801653:	c9                   	leave  
  801654:	c3                   	ret    

00801655 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801655:	55                   	push   %ebp
  801656:	89 e5                	mov    %esp,%ebp
  801658:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  80165b:	68 90 25 80 00       	push   $0x802590
  801660:	68 90 00 00 00       	push   $0x90
  801665:	68 ae 25 80 00       	push   $0x8025ae
  80166a:	e8 05 06 00 00       	call   801c74 <_panic>

0080166f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80166f:	55                   	push   %ebp
  801670:	89 e5                	mov    %esp,%ebp
  801672:	56                   	push   %esi
  801673:	53                   	push   %ebx
  801674:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801677:	8b 45 08             	mov    0x8(%ebp),%eax
  80167a:	8b 40 0c             	mov    0xc(%eax),%eax
  80167d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801682:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801688:	ba 00 00 00 00       	mov    $0x0,%edx
  80168d:	b8 03 00 00 00       	mov    $0x3,%eax
  801692:	e8 ce fe ff ff       	call   801565 <fsipc>
  801697:	89 c3                	mov    %eax,%ebx
  801699:	85 c0                	test   %eax,%eax
  80169b:	78 4b                	js     8016e8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80169d:	39 c6                	cmp    %eax,%esi
  80169f:	73 16                	jae    8016b7 <devfile_read+0x48>
  8016a1:	68 b9 25 80 00       	push   $0x8025b9
  8016a6:	68 c0 25 80 00       	push   $0x8025c0
  8016ab:	6a 7c                	push   $0x7c
  8016ad:	68 ae 25 80 00       	push   $0x8025ae
  8016b2:	e8 bd 05 00 00       	call   801c74 <_panic>
	assert(r <= PGSIZE);
  8016b7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016bc:	7e 16                	jle    8016d4 <devfile_read+0x65>
  8016be:	68 d5 25 80 00       	push   $0x8025d5
  8016c3:	68 c0 25 80 00       	push   $0x8025c0
  8016c8:	6a 7d                	push   $0x7d
  8016ca:	68 ae 25 80 00       	push   $0x8025ae
  8016cf:	e8 a0 05 00 00       	call   801c74 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8016d4:	83 ec 04             	sub    $0x4,%esp
  8016d7:	50                   	push   %eax
  8016d8:	68 00 50 80 00       	push   $0x805000
  8016dd:	ff 75 0c             	pushl  0xc(%ebp)
  8016e0:	e8 15 f2 ff ff       	call   8008fa <memmove>
	return r;
  8016e5:	83 c4 10             	add    $0x10,%esp
}
  8016e8:	89 d8                	mov    %ebx,%eax
  8016ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ed:	5b                   	pop    %ebx
  8016ee:	5e                   	pop    %esi
  8016ef:	5d                   	pop    %ebp
  8016f0:	c3                   	ret    

008016f1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	53                   	push   %ebx
  8016f5:	83 ec 20             	sub    $0x20,%esp
  8016f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016fb:	53                   	push   %ebx
  8016fc:	e8 2e f0 ff ff       	call   80072f <strlen>
  801701:	83 c4 10             	add    $0x10,%esp
  801704:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801709:	7f 67                	jg     801772 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80170b:	83 ec 0c             	sub    $0xc,%esp
  80170e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801711:	50                   	push   %eax
  801712:	e8 c6 f8 ff ff       	call   800fdd <fd_alloc>
  801717:	83 c4 10             	add    $0x10,%esp
		return r;
  80171a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80171c:	85 c0                	test   %eax,%eax
  80171e:	78 57                	js     801777 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801720:	83 ec 08             	sub    $0x8,%esp
  801723:	53                   	push   %ebx
  801724:	68 00 50 80 00       	push   $0x805000
  801729:	e8 3a f0 ff ff       	call   800768 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80172e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801731:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801736:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801739:	b8 01 00 00 00       	mov    $0x1,%eax
  80173e:	e8 22 fe ff ff       	call   801565 <fsipc>
  801743:	89 c3                	mov    %eax,%ebx
  801745:	83 c4 10             	add    $0x10,%esp
  801748:	85 c0                	test   %eax,%eax
  80174a:	79 14                	jns    801760 <open+0x6f>
		fd_close(fd, 0);
  80174c:	83 ec 08             	sub    $0x8,%esp
  80174f:	6a 00                	push   $0x0
  801751:	ff 75 f4             	pushl  -0xc(%ebp)
  801754:	e8 7c f9 ff ff       	call   8010d5 <fd_close>
		return r;
  801759:	83 c4 10             	add    $0x10,%esp
  80175c:	89 da                	mov    %ebx,%edx
  80175e:	eb 17                	jmp    801777 <open+0x86>
	}

	return fd2num(fd);
  801760:	83 ec 0c             	sub    $0xc,%esp
  801763:	ff 75 f4             	pushl  -0xc(%ebp)
  801766:	e8 4b f8 ff ff       	call   800fb6 <fd2num>
  80176b:	89 c2                	mov    %eax,%edx
  80176d:	83 c4 10             	add    $0x10,%esp
  801770:	eb 05                	jmp    801777 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801772:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801777:	89 d0                	mov    %edx,%eax
  801779:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80177c:	c9                   	leave  
  80177d:	c3                   	ret    

0080177e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80177e:	55                   	push   %ebp
  80177f:	89 e5                	mov    %esp,%ebp
  801781:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801784:	ba 00 00 00 00       	mov    $0x0,%edx
  801789:	b8 08 00 00 00       	mov    $0x8,%eax
  80178e:	e8 d2 fd ff ff       	call   801565 <fsipc>
}
  801793:	c9                   	leave  
  801794:	c3                   	ret    

00801795 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	56                   	push   %esi
  801799:	53                   	push   %ebx
  80179a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80179d:	83 ec 0c             	sub    $0xc,%esp
  8017a0:	ff 75 08             	pushl  0x8(%ebp)
  8017a3:	e8 1e f8 ff ff       	call   800fc6 <fd2data>
  8017a8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8017aa:	83 c4 08             	add    $0x8,%esp
  8017ad:	68 e1 25 80 00       	push   $0x8025e1
  8017b2:	53                   	push   %ebx
  8017b3:	e8 b0 ef ff ff       	call   800768 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8017b8:	8b 46 04             	mov    0x4(%esi),%eax
  8017bb:	2b 06                	sub    (%esi),%eax
  8017bd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8017c3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017ca:	00 00 00 
	stat->st_dev = &devpipe;
  8017cd:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8017d4:	30 80 00 
	return 0;
}
  8017d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8017dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017df:	5b                   	pop    %ebx
  8017e0:	5e                   	pop    %esi
  8017e1:	5d                   	pop    %ebp
  8017e2:	c3                   	ret    

008017e3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8017e3:	55                   	push   %ebp
  8017e4:	89 e5                	mov    %esp,%ebp
  8017e6:	53                   	push   %ebx
  8017e7:	83 ec 0c             	sub    $0xc,%esp
  8017ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017ed:	53                   	push   %ebx
  8017ee:	6a 00                	push   $0x0
  8017f0:	e8 fb f3 ff ff       	call   800bf0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017f5:	89 1c 24             	mov    %ebx,(%esp)
  8017f8:	e8 c9 f7 ff ff       	call   800fc6 <fd2data>
  8017fd:	83 c4 08             	add    $0x8,%esp
  801800:	50                   	push   %eax
  801801:	6a 00                	push   $0x0
  801803:	e8 e8 f3 ff ff       	call   800bf0 <sys_page_unmap>
}
  801808:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180b:	c9                   	leave  
  80180c:	c3                   	ret    

0080180d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80180d:	55                   	push   %ebp
  80180e:	89 e5                	mov    %esp,%ebp
  801810:	57                   	push   %edi
  801811:	56                   	push   %esi
  801812:	53                   	push   %ebx
  801813:	83 ec 1c             	sub    $0x1c,%esp
  801816:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801819:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80181b:	a1 04 40 80 00       	mov    0x804004,%eax
  801820:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801823:	83 ec 0c             	sub    $0xc,%esp
  801826:	ff 75 e0             	pushl  -0x20(%ebp)
  801829:	e8 eb 05 00 00       	call   801e19 <pageref>
  80182e:	89 c3                	mov    %eax,%ebx
  801830:	89 3c 24             	mov    %edi,(%esp)
  801833:	e8 e1 05 00 00       	call   801e19 <pageref>
  801838:	83 c4 10             	add    $0x10,%esp
  80183b:	39 c3                	cmp    %eax,%ebx
  80183d:	0f 94 c1             	sete   %cl
  801840:	0f b6 c9             	movzbl %cl,%ecx
  801843:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801846:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80184c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80184f:	39 ce                	cmp    %ecx,%esi
  801851:	74 1b                	je     80186e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801853:	39 c3                	cmp    %eax,%ebx
  801855:	75 c4                	jne    80181b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801857:	8b 42 58             	mov    0x58(%edx),%eax
  80185a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80185d:	50                   	push   %eax
  80185e:	56                   	push   %esi
  80185f:	68 e8 25 80 00       	push   $0x8025e8
  801864:	e8 7a e9 ff ff       	call   8001e3 <cprintf>
  801869:	83 c4 10             	add    $0x10,%esp
  80186c:	eb ad                	jmp    80181b <_pipeisclosed+0xe>
	}
}
  80186e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801871:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801874:	5b                   	pop    %ebx
  801875:	5e                   	pop    %esi
  801876:	5f                   	pop    %edi
  801877:	5d                   	pop    %ebp
  801878:	c3                   	ret    

00801879 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	57                   	push   %edi
  80187d:	56                   	push   %esi
  80187e:	53                   	push   %ebx
  80187f:	83 ec 28             	sub    $0x28,%esp
  801882:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801885:	56                   	push   %esi
  801886:	e8 3b f7 ff ff       	call   800fc6 <fd2data>
  80188b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80188d:	83 c4 10             	add    $0x10,%esp
  801890:	bf 00 00 00 00       	mov    $0x0,%edi
  801895:	eb 4b                	jmp    8018e2 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801897:	89 da                	mov    %ebx,%edx
  801899:	89 f0                	mov    %esi,%eax
  80189b:	e8 6d ff ff ff       	call   80180d <_pipeisclosed>
  8018a0:	85 c0                	test   %eax,%eax
  8018a2:	75 48                	jne    8018ec <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8018a4:	e8 a3 f2 ff ff       	call   800b4c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8018a9:	8b 43 04             	mov    0x4(%ebx),%eax
  8018ac:	8b 0b                	mov    (%ebx),%ecx
  8018ae:	8d 51 20             	lea    0x20(%ecx),%edx
  8018b1:	39 d0                	cmp    %edx,%eax
  8018b3:	73 e2                	jae    801897 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8018b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018b8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8018bc:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8018bf:	89 c2                	mov    %eax,%edx
  8018c1:	c1 fa 1f             	sar    $0x1f,%edx
  8018c4:	89 d1                	mov    %edx,%ecx
  8018c6:	c1 e9 1b             	shr    $0x1b,%ecx
  8018c9:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8018cc:	83 e2 1f             	and    $0x1f,%edx
  8018cf:	29 ca                	sub    %ecx,%edx
  8018d1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8018d5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8018d9:	83 c0 01             	add    $0x1,%eax
  8018dc:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018df:	83 c7 01             	add    $0x1,%edi
  8018e2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8018e5:	75 c2                	jne    8018a9 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8018e7:	8b 45 10             	mov    0x10(%ebp),%eax
  8018ea:	eb 05                	jmp    8018f1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018ec:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8018f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018f4:	5b                   	pop    %ebx
  8018f5:	5e                   	pop    %esi
  8018f6:	5f                   	pop    %edi
  8018f7:	5d                   	pop    %ebp
  8018f8:	c3                   	ret    

008018f9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018f9:	55                   	push   %ebp
  8018fa:	89 e5                	mov    %esp,%ebp
  8018fc:	57                   	push   %edi
  8018fd:	56                   	push   %esi
  8018fe:	53                   	push   %ebx
  8018ff:	83 ec 18             	sub    $0x18,%esp
  801902:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801905:	57                   	push   %edi
  801906:	e8 bb f6 ff ff       	call   800fc6 <fd2data>
  80190b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80190d:	83 c4 10             	add    $0x10,%esp
  801910:	bb 00 00 00 00       	mov    $0x0,%ebx
  801915:	eb 3d                	jmp    801954 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801917:	85 db                	test   %ebx,%ebx
  801919:	74 04                	je     80191f <devpipe_read+0x26>
				return i;
  80191b:	89 d8                	mov    %ebx,%eax
  80191d:	eb 44                	jmp    801963 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80191f:	89 f2                	mov    %esi,%edx
  801921:	89 f8                	mov    %edi,%eax
  801923:	e8 e5 fe ff ff       	call   80180d <_pipeisclosed>
  801928:	85 c0                	test   %eax,%eax
  80192a:	75 32                	jne    80195e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80192c:	e8 1b f2 ff ff       	call   800b4c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801931:	8b 06                	mov    (%esi),%eax
  801933:	3b 46 04             	cmp    0x4(%esi),%eax
  801936:	74 df                	je     801917 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801938:	99                   	cltd   
  801939:	c1 ea 1b             	shr    $0x1b,%edx
  80193c:	01 d0                	add    %edx,%eax
  80193e:	83 e0 1f             	and    $0x1f,%eax
  801941:	29 d0                	sub    %edx,%eax
  801943:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801948:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80194b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80194e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801951:	83 c3 01             	add    $0x1,%ebx
  801954:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801957:	75 d8                	jne    801931 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801959:	8b 45 10             	mov    0x10(%ebp),%eax
  80195c:	eb 05                	jmp    801963 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80195e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801963:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801966:	5b                   	pop    %ebx
  801967:	5e                   	pop    %esi
  801968:	5f                   	pop    %edi
  801969:	5d                   	pop    %ebp
  80196a:	c3                   	ret    

0080196b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80196b:	55                   	push   %ebp
  80196c:	89 e5                	mov    %esp,%ebp
  80196e:	56                   	push   %esi
  80196f:	53                   	push   %ebx
  801970:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801973:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801976:	50                   	push   %eax
  801977:	e8 61 f6 ff ff       	call   800fdd <fd_alloc>
  80197c:	83 c4 10             	add    $0x10,%esp
  80197f:	89 c2                	mov    %eax,%edx
  801981:	85 c0                	test   %eax,%eax
  801983:	0f 88 2c 01 00 00    	js     801ab5 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801989:	83 ec 04             	sub    $0x4,%esp
  80198c:	68 07 04 00 00       	push   $0x407
  801991:	ff 75 f4             	pushl  -0xc(%ebp)
  801994:	6a 00                	push   $0x0
  801996:	e8 d0 f1 ff ff       	call   800b6b <sys_page_alloc>
  80199b:	83 c4 10             	add    $0x10,%esp
  80199e:	89 c2                	mov    %eax,%edx
  8019a0:	85 c0                	test   %eax,%eax
  8019a2:	0f 88 0d 01 00 00    	js     801ab5 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8019a8:	83 ec 0c             	sub    $0xc,%esp
  8019ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019ae:	50                   	push   %eax
  8019af:	e8 29 f6 ff ff       	call   800fdd <fd_alloc>
  8019b4:	89 c3                	mov    %eax,%ebx
  8019b6:	83 c4 10             	add    $0x10,%esp
  8019b9:	85 c0                	test   %eax,%eax
  8019bb:	0f 88 e2 00 00 00    	js     801aa3 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019c1:	83 ec 04             	sub    $0x4,%esp
  8019c4:	68 07 04 00 00       	push   $0x407
  8019c9:	ff 75 f0             	pushl  -0x10(%ebp)
  8019cc:	6a 00                	push   $0x0
  8019ce:	e8 98 f1 ff ff       	call   800b6b <sys_page_alloc>
  8019d3:	89 c3                	mov    %eax,%ebx
  8019d5:	83 c4 10             	add    $0x10,%esp
  8019d8:	85 c0                	test   %eax,%eax
  8019da:	0f 88 c3 00 00 00    	js     801aa3 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8019e0:	83 ec 0c             	sub    $0xc,%esp
  8019e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e6:	e8 db f5 ff ff       	call   800fc6 <fd2data>
  8019eb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019ed:	83 c4 0c             	add    $0xc,%esp
  8019f0:	68 07 04 00 00       	push   $0x407
  8019f5:	50                   	push   %eax
  8019f6:	6a 00                	push   $0x0
  8019f8:	e8 6e f1 ff ff       	call   800b6b <sys_page_alloc>
  8019fd:	89 c3                	mov    %eax,%ebx
  8019ff:	83 c4 10             	add    $0x10,%esp
  801a02:	85 c0                	test   %eax,%eax
  801a04:	0f 88 89 00 00 00    	js     801a93 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a0a:	83 ec 0c             	sub    $0xc,%esp
  801a0d:	ff 75 f0             	pushl  -0x10(%ebp)
  801a10:	e8 b1 f5 ff ff       	call   800fc6 <fd2data>
  801a15:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a1c:	50                   	push   %eax
  801a1d:	6a 00                	push   $0x0
  801a1f:	56                   	push   %esi
  801a20:	6a 00                	push   $0x0
  801a22:	e8 87 f1 ff ff       	call   800bae <sys_page_map>
  801a27:	89 c3                	mov    %eax,%ebx
  801a29:	83 c4 20             	add    $0x20,%esp
  801a2c:	85 c0                	test   %eax,%eax
  801a2e:	78 55                	js     801a85 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a30:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a39:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a3e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a45:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a4e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a50:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a53:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a5a:	83 ec 0c             	sub    $0xc,%esp
  801a5d:	ff 75 f4             	pushl  -0xc(%ebp)
  801a60:	e8 51 f5 ff ff       	call   800fb6 <fd2num>
  801a65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a68:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a6a:	83 c4 04             	add    $0x4,%esp
  801a6d:	ff 75 f0             	pushl  -0x10(%ebp)
  801a70:	e8 41 f5 ff ff       	call   800fb6 <fd2num>
  801a75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a78:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a7b:	83 c4 10             	add    $0x10,%esp
  801a7e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a83:	eb 30                	jmp    801ab5 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801a85:	83 ec 08             	sub    $0x8,%esp
  801a88:	56                   	push   %esi
  801a89:	6a 00                	push   $0x0
  801a8b:	e8 60 f1 ff ff       	call   800bf0 <sys_page_unmap>
  801a90:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a93:	83 ec 08             	sub    $0x8,%esp
  801a96:	ff 75 f0             	pushl  -0x10(%ebp)
  801a99:	6a 00                	push   $0x0
  801a9b:	e8 50 f1 ff ff       	call   800bf0 <sys_page_unmap>
  801aa0:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801aa3:	83 ec 08             	sub    $0x8,%esp
  801aa6:	ff 75 f4             	pushl  -0xc(%ebp)
  801aa9:	6a 00                	push   $0x0
  801aab:	e8 40 f1 ff ff       	call   800bf0 <sys_page_unmap>
  801ab0:	83 c4 10             	add    $0x10,%esp
  801ab3:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ab5:	89 d0                	mov    %edx,%eax
  801ab7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aba:	5b                   	pop    %ebx
  801abb:	5e                   	pop    %esi
  801abc:	5d                   	pop    %ebp
  801abd:	c3                   	ret    

00801abe <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801abe:	55                   	push   %ebp
  801abf:	89 e5                	mov    %esp,%ebp
  801ac1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ac4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ac7:	50                   	push   %eax
  801ac8:	ff 75 08             	pushl  0x8(%ebp)
  801acb:	e8 5c f5 ff ff       	call   80102c <fd_lookup>
  801ad0:	83 c4 10             	add    $0x10,%esp
  801ad3:	85 c0                	test   %eax,%eax
  801ad5:	78 18                	js     801aef <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ad7:	83 ec 0c             	sub    $0xc,%esp
  801ada:	ff 75 f4             	pushl  -0xc(%ebp)
  801add:	e8 e4 f4 ff ff       	call   800fc6 <fd2data>
	return _pipeisclosed(fd, p);
  801ae2:	89 c2                	mov    %eax,%edx
  801ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae7:	e8 21 fd ff ff       	call   80180d <_pipeisclosed>
  801aec:	83 c4 10             	add    $0x10,%esp
}
  801aef:	c9                   	leave  
  801af0:	c3                   	ret    

00801af1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801af1:	55                   	push   %ebp
  801af2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801af4:	b8 00 00 00 00       	mov    $0x0,%eax
  801af9:	5d                   	pop    %ebp
  801afa:	c3                   	ret    

00801afb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b01:	68 00 26 80 00       	push   $0x802600
  801b06:	ff 75 0c             	pushl  0xc(%ebp)
  801b09:	e8 5a ec ff ff       	call   800768 <strcpy>
	return 0;
}
  801b0e:	b8 00 00 00 00       	mov    $0x0,%eax
  801b13:	c9                   	leave  
  801b14:	c3                   	ret    

00801b15 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	57                   	push   %edi
  801b19:	56                   	push   %esi
  801b1a:	53                   	push   %ebx
  801b1b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b21:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b26:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b2c:	eb 2d                	jmp    801b5b <devcons_write+0x46>
		m = n - tot;
  801b2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b31:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801b33:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801b36:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801b3b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b3e:	83 ec 04             	sub    $0x4,%esp
  801b41:	53                   	push   %ebx
  801b42:	03 45 0c             	add    0xc(%ebp),%eax
  801b45:	50                   	push   %eax
  801b46:	57                   	push   %edi
  801b47:	e8 ae ed ff ff       	call   8008fa <memmove>
		sys_cputs(buf, m);
  801b4c:	83 c4 08             	add    $0x8,%esp
  801b4f:	53                   	push   %ebx
  801b50:	57                   	push   %edi
  801b51:	e8 59 ef ff ff       	call   800aaf <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b56:	01 de                	add    %ebx,%esi
  801b58:	83 c4 10             	add    $0x10,%esp
  801b5b:	89 f0                	mov    %esi,%eax
  801b5d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b60:	72 cc                	jb     801b2e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b65:	5b                   	pop    %ebx
  801b66:	5e                   	pop    %esi
  801b67:	5f                   	pop    %edi
  801b68:	5d                   	pop    %ebp
  801b69:	c3                   	ret    

00801b6a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b6a:	55                   	push   %ebp
  801b6b:	89 e5                	mov    %esp,%ebp
  801b6d:	83 ec 08             	sub    $0x8,%esp
  801b70:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801b75:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b79:	74 2a                	je     801ba5 <devcons_read+0x3b>
  801b7b:	eb 05                	jmp    801b82 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b7d:	e8 ca ef ff ff       	call   800b4c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b82:	e8 46 ef ff ff       	call   800acd <sys_cgetc>
  801b87:	85 c0                	test   %eax,%eax
  801b89:	74 f2                	je     801b7d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801b8b:	85 c0                	test   %eax,%eax
  801b8d:	78 16                	js     801ba5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b8f:	83 f8 04             	cmp    $0x4,%eax
  801b92:	74 0c                	je     801ba0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801b94:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b97:	88 02                	mov    %al,(%edx)
	return 1;
  801b99:	b8 01 00 00 00       	mov    $0x1,%eax
  801b9e:	eb 05                	jmp    801ba5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ba0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ba5:	c9                   	leave  
  801ba6:	c3                   	ret    

00801ba7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ba7:	55                   	push   %ebp
  801ba8:	89 e5                	mov    %esp,%ebp
  801baa:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801bad:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801bb3:	6a 01                	push   $0x1
  801bb5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bb8:	50                   	push   %eax
  801bb9:	e8 f1 ee ff ff       	call   800aaf <sys_cputs>
}
  801bbe:	83 c4 10             	add    $0x10,%esp
  801bc1:	c9                   	leave  
  801bc2:	c3                   	ret    

00801bc3 <getchar>:

int
getchar(void)
{
  801bc3:	55                   	push   %ebp
  801bc4:	89 e5                	mov    %esp,%ebp
  801bc6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801bc9:	6a 01                	push   $0x1
  801bcb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bce:	50                   	push   %eax
  801bcf:	6a 00                	push   $0x0
  801bd1:	e8 bc f6 ff ff       	call   801292 <read>
	if (r < 0)
  801bd6:	83 c4 10             	add    $0x10,%esp
  801bd9:	85 c0                	test   %eax,%eax
  801bdb:	78 0f                	js     801bec <getchar+0x29>
		return r;
	if (r < 1)
  801bdd:	85 c0                	test   %eax,%eax
  801bdf:	7e 06                	jle    801be7 <getchar+0x24>
		return -E_EOF;
	return c;
  801be1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801be5:	eb 05                	jmp    801bec <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801be7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801bec:	c9                   	leave  
  801bed:	c3                   	ret    

00801bee <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801bee:	55                   	push   %ebp
  801bef:	89 e5                	mov    %esp,%ebp
  801bf1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bf4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf7:	50                   	push   %eax
  801bf8:	ff 75 08             	pushl  0x8(%ebp)
  801bfb:	e8 2c f4 ff ff       	call   80102c <fd_lookup>
  801c00:	83 c4 10             	add    $0x10,%esp
  801c03:	85 c0                	test   %eax,%eax
  801c05:	78 11                	js     801c18 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c0a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c10:	39 10                	cmp    %edx,(%eax)
  801c12:	0f 94 c0             	sete   %al
  801c15:	0f b6 c0             	movzbl %al,%eax
}
  801c18:	c9                   	leave  
  801c19:	c3                   	ret    

00801c1a <opencons>:

int
opencons(void)
{
  801c1a:	55                   	push   %ebp
  801c1b:	89 e5                	mov    %esp,%ebp
  801c1d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c20:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c23:	50                   	push   %eax
  801c24:	e8 b4 f3 ff ff       	call   800fdd <fd_alloc>
  801c29:	83 c4 10             	add    $0x10,%esp
		return r;
  801c2c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c2e:	85 c0                	test   %eax,%eax
  801c30:	78 3e                	js     801c70 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c32:	83 ec 04             	sub    $0x4,%esp
  801c35:	68 07 04 00 00       	push   $0x407
  801c3a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c3d:	6a 00                	push   $0x0
  801c3f:	e8 27 ef ff ff       	call   800b6b <sys_page_alloc>
  801c44:	83 c4 10             	add    $0x10,%esp
		return r;
  801c47:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c49:	85 c0                	test   %eax,%eax
  801c4b:	78 23                	js     801c70 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c4d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c56:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c5b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c62:	83 ec 0c             	sub    $0xc,%esp
  801c65:	50                   	push   %eax
  801c66:	e8 4b f3 ff ff       	call   800fb6 <fd2num>
  801c6b:	89 c2                	mov    %eax,%edx
  801c6d:	83 c4 10             	add    $0x10,%esp
}
  801c70:	89 d0                	mov    %edx,%eax
  801c72:	c9                   	leave  
  801c73:	c3                   	ret    

00801c74 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801c74:	55                   	push   %ebp
  801c75:	89 e5                	mov    %esp,%ebp
  801c77:	56                   	push   %esi
  801c78:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801c79:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801c7c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801c82:	e8 a6 ee ff ff       	call   800b2d <sys_getenvid>
  801c87:	83 ec 0c             	sub    $0xc,%esp
  801c8a:	ff 75 0c             	pushl  0xc(%ebp)
  801c8d:	ff 75 08             	pushl  0x8(%ebp)
  801c90:	56                   	push   %esi
  801c91:	50                   	push   %eax
  801c92:	68 0c 26 80 00       	push   $0x80260c
  801c97:	e8 47 e5 ff ff       	call   8001e3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801c9c:	83 c4 18             	add    $0x18,%esp
  801c9f:	53                   	push   %ebx
  801ca0:	ff 75 10             	pushl  0x10(%ebp)
  801ca3:	e8 ea e4 ff ff       	call   800192 <vcprintf>
	cprintf("\n");
  801ca8:	c7 04 24 0f 21 80 00 	movl   $0x80210f,(%esp)
  801caf:	e8 2f e5 ff ff       	call   8001e3 <cprintf>
  801cb4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801cb7:	cc                   	int3   
  801cb8:	eb fd                	jmp    801cb7 <_panic+0x43>

00801cba <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801cba:	55                   	push   %ebp
  801cbb:	89 e5                	mov    %esp,%ebp
  801cbd:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801cc0:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801cc7:	75 2e                	jne    801cf7 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801cc9:	e8 5f ee ff ff       	call   800b2d <sys_getenvid>
  801cce:	83 ec 04             	sub    $0x4,%esp
  801cd1:	68 07 0e 00 00       	push   $0xe07
  801cd6:	68 00 f0 bf ee       	push   $0xeebff000
  801cdb:	50                   	push   %eax
  801cdc:	e8 8a ee ff ff       	call   800b6b <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801ce1:	e8 47 ee ff ff       	call   800b2d <sys_getenvid>
  801ce6:	83 c4 08             	add    $0x8,%esp
  801ce9:	68 01 1d 80 00       	push   $0x801d01
  801cee:	50                   	push   %eax
  801cef:	e8 c2 ef ff ff       	call   800cb6 <sys_env_set_pgfault_upcall>
  801cf4:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801cf7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfa:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801cff:	c9                   	leave  
  801d00:	c3                   	ret    

00801d01 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801d01:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801d02:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801d07:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801d09:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  801d0c:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  801d10:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  801d14:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  801d17:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  801d1a:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  801d1b:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  801d1e:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  801d1f:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  801d20:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801d24:	c3                   	ret    

00801d25 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d25:	55                   	push   %ebp
  801d26:	89 e5                	mov    %esp,%ebp
  801d28:	56                   	push   %esi
  801d29:	53                   	push   %ebx
  801d2a:	8b 75 08             	mov    0x8(%ebp),%esi
  801d2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d30:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801d33:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801d35:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801d3a:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801d3d:	83 ec 0c             	sub    $0xc,%esp
  801d40:	50                   	push   %eax
  801d41:	e8 d5 ef ff ff       	call   800d1b <sys_ipc_recv>

	if (from_env_store != NULL)
  801d46:	83 c4 10             	add    $0x10,%esp
  801d49:	85 f6                	test   %esi,%esi
  801d4b:	74 14                	je     801d61 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801d4d:	ba 00 00 00 00       	mov    $0x0,%edx
  801d52:	85 c0                	test   %eax,%eax
  801d54:	78 09                	js     801d5f <ipc_recv+0x3a>
  801d56:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d5c:	8b 52 74             	mov    0x74(%edx),%edx
  801d5f:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801d61:	85 db                	test   %ebx,%ebx
  801d63:	74 14                	je     801d79 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801d65:	ba 00 00 00 00       	mov    $0x0,%edx
  801d6a:	85 c0                	test   %eax,%eax
  801d6c:	78 09                	js     801d77 <ipc_recv+0x52>
  801d6e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d74:	8b 52 78             	mov    0x78(%edx),%edx
  801d77:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801d79:	85 c0                	test   %eax,%eax
  801d7b:	78 08                	js     801d85 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801d7d:	a1 04 40 80 00       	mov    0x804004,%eax
  801d82:	8b 40 70             	mov    0x70(%eax),%eax
}
  801d85:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d88:	5b                   	pop    %ebx
  801d89:	5e                   	pop    %esi
  801d8a:	5d                   	pop    %ebp
  801d8b:	c3                   	ret    

00801d8c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	57                   	push   %edi
  801d90:	56                   	push   %esi
  801d91:	53                   	push   %ebx
  801d92:	83 ec 0c             	sub    $0xc,%esp
  801d95:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d98:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801d9e:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801da0:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801da5:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801da8:	ff 75 14             	pushl  0x14(%ebp)
  801dab:	53                   	push   %ebx
  801dac:	56                   	push   %esi
  801dad:	57                   	push   %edi
  801dae:	e8 45 ef ff ff       	call   800cf8 <sys_ipc_try_send>

		if (err < 0) {
  801db3:	83 c4 10             	add    $0x10,%esp
  801db6:	85 c0                	test   %eax,%eax
  801db8:	79 1e                	jns    801dd8 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801dba:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801dbd:	75 07                	jne    801dc6 <ipc_send+0x3a>
				sys_yield();
  801dbf:	e8 88 ed ff ff       	call   800b4c <sys_yield>
  801dc4:	eb e2                	jmp    801da8 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801dc6:	50                   	push   %eax
  801dc7:	68 30 26 80 00       	push   $0x802630
  801dcc:	6a 49                	push   $0x49
  801dce:	68 3d 26 80 00       	push   $0x80263d
  801dd3:	e8 9c fe ff ff       	call   801c74 <_panic>
		}

	} while (err < 0);

}
  801dd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ddb:	5b                   	pop    %ebx
  801ddc:	5e                   	pop    %esi
  801ddd:	5f                   	pop    %edi
  801dde:	5d                   	pop    %ebp
  801ddf:	c3                   	ret    

00801de0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801de6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801deb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801dee:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801df4:	8b 52 50             	mov    0x50(%edx),%edx
  801df7:	39 ca                	cmp    %ecx,%edx
  801df9:	75 0d                	jne    801e08 <ipc_find_env+0x28>
			return envs[i].env_id;
  801dfb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801dfe:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e03:	8b 40 48             	mov    0x48(%eax),%eax
  801e06:	eb 0f                	jmp    801e17 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e08:	83 c0 01             	add    $0x1,%eax
  801e0b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e10:	75 d9                	jne    801deb <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e12:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e17:	5d                   	pop    %ebp
  801e18:	c3                   	ret    

00801e19 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e19:	55                   	push   %ebp
  801e1a:	89 e5                	mov    %esp,%ebp
  801e1c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e1f:	89 d0                	mov    %edx,%eax
  801e21:	c1 e8 16             	shr    $0x16,%eax
  801e24:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e2b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e30:	f6 c1 01             	test   $0x1,%cl
  801e33:	74 1d                	je     801e52 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e35:	c1 ea 0c             	shr    $0xc,%edx
  801e38:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e3f:	f6 c2 01             	test   $0x1,%dl
  801e42:	74 0e                	je     801e52 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e44:	c1 ea 0c             	shr    $0xc,%edx
  801e47:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e4e:	ef 
  801e4f:	0f b7 c0             	movzwl %ax,%eax
}
  801e52:	5d                   	pop    %ebp
  801e53:	c3                   	ret    
  801e54:	66 90                	xchg   %ax,%ax
  801e56:	66 90                	xchg   %ax,%ax
  801e58:	66 90                	xchg   %ax,%ax
  801e5a:	66 90                	xchg   %ax,%ax
  801e5c:	66 90                	xchg   %ax,%ax
  801e5e:	66 90                	xchg   %ax,%ax

00801e60 <__udivdi3>:
  801e60:	55                   	push   %ebp
  801e61:	57                   	push   %edi
  801e62:	56                   	push   %esi
  801e63:	53                   	push   %ebx
  801e64:	83 ec 1c             	sub    $0x1c,%esp
  801e67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801e6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801e6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801e73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e77:	85 f6                	test   %esi,%esi
  801e79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e7d:	89 ca                	mov    %ecx,%edx
  801e7f:	89 f8                	mov    %edi,%eax
  801e81:	75 3d                	jne    801ec0 <__udivdi3+0x60>
  801e83:	39 cf                	cmp    %ecx,%edi
  801e85:	0f 87 c5 00 00 00    	ja     801f50 <__udivdi3+0xf0>
  801e8b:	85 ff                	test   %edi,%edi
  801e8d:	89 fd                	mov    %edi,%ebp
  801e8f:	75 0b                	jne    801e9c <__udivdi3+0x3c>
  801e91:	b8 01 00 00 00       	mov    $0x1,%eax
  801e96:	31 d2                	xor    %edx,%edx
  801e98:	f7 f7                	div    %edi
  801e9a:	89 c5                	mov    %eax,%ebp
  801e9c:	89 c8                	mov    %ecx,%eax
  801e9e:	31 d2                	xor    %edx,%edx
  801ea0:	f7 f5                	div    %ebp
  801ea2:	89 c1                	mov    %eax,%ecx
  801ea4:	89 d8                	mov    %ebx,%eax
  801ea6:	89 cf                	mov    %ecx,%edi
  801ea8:	f7 f5                	div    %ebp
  801eaa:	89 c3                	mov    %eax,%ebx
  801eac:	89 d8                	mov    %ebx,%eax
  801eae:	89 fa                	mov    %edi,%edx
  801eb0:	83 c4 1c             	add    $0x1c,%esp
  801eb3:	5b                   	pop    %ebx
  801eb4:	5e                   	pop    %esi
  801eb5:	5f                   	pop    %edi
  801eb6:	5d                   	pop    %ebp
  801eb7:	c3                   	ret    
  801eb8:	90                   	nop
  801eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ec0:	39 ce                	cmp    %ecx,%esi
  801ec2:	77 74                	ja     801f38 <__udivdi3+0xd8>
  801ec4:	0f bd fe             	bsr    %esi,%edi
  801ec7:	83 f7 1f             	xor    $0x1f,%edi
  801eca:	0f 84 98 00 00 00    	je     801f68 <__udivdi3+0x108>
  801ed0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ed5:	89 f9                	mov    %edi,%ecx
  801ed7:	89 c5                	mov    %eax,%ebp
  801ed9:	29 fb                	sub    %edi,%ebx
  801edb:	d3 e6                	shl    %cl,%esi
  801edd:	89 d9                	mov    %ebx,%ecx
  801edf:	d3 ed                	shr    %cl,%ebp
  801ee1:	89 f9                	mov    %edi,%ecx
  801ee3:	d3 e0                	shl    %cl,%eax
  801ee5:	09 ee                	or     %ebp,%esi
  801ee7:	89 d9                	mov    %ebx,%ecx
  801ee9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eed:	89 d5                	mov    %edx,%ebp
  801eef:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ef3:	d3 ed                	shr    %cl,%ebp
  801ef5:	89 f9                	mov    %edi,%ecx
  801ef7:	d3 e2                	shl    %cl,%edx
  801ef9:	89 d9                	mov    %ebx,%ecx
  801efb:	d3 e8                	shr    %cl,%eax
  801efd:	09 c2                	or     %eax,%edx
  801eff:	89 d0                	mov    %edx,%eax
  801f01:	89 ea                	mov    %ebp,%edx
  801f03:	f7 f6                	div    %esi
  801f05:	89 d5                	mov    %edx,%ebp
  801f07:	89 c3                	mov    %eax,%ebx
  801f09:	f7 64 24 0c          	mull   0xc(%esp)
  801f0d:	39 d5                	cmp    %edx,%ebp
  801f0f:	72 10                	jb     801f21 <__udivdi3+0xc1>
  801f11:	8b 74 24 08          	mov    0x8(%esp),%esi
  801f15:	89 f9                	mov    %edi,%ecx
  801f17:	d3 e6                	shl    %cl,%esi
  801f19:	39 c6                	cmp    %eax,%esi
  801f1b:	73 07                	jae    801f24 <__udivdi3+0xc4>
  801f1d:	39 d5                	cmp    %edx,%ebp
  801f1f:	75 03                	jne    801f24 <__udivdi3+0xc4>
  801f21:	83 eb 01             	sub    $0x1,%ebx
  801f24:	31 ff                	xor    %edi,%edi
  801f26:	89 d8                	mov    %ebx,%eax
  801f28:	89 fa                	mov    %edi,%edx
  801f2a:	83 c4 1c             	add    $0x1c,%esp
  801f2d:	5b                   	pop    %ebx
  801f2e:	5e                   	pop    %esi
  801f2f:	5f                   	pop    %edi
  801f30:	5d                   	pop    %ebp
  801f31:	c3                   	ret    
  801f32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f38:	31 ff                	xor    %edi,%edi
  801f3a:	31 db                	xor    %ebx,%ebx
  801f3c:	89 d8                	mov    %ebx,%eax
  801f3e:	89 fa                	mov    %edi,%edx
  801f40:	83 c4 1c             	add    $0x1c,%esp
  801f43:	5b                   	pop    %ebx
  801f44:	5e                   	pop    %esi
  801f45:	5f                   	pop    %edi
  801f46:	5d                   	pop    %ebp
  801f47:	c3                   	ret    
  801f48:	90                   	nop
  801f49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f50:	89 d8                	mov    %ebx,%eax
  801f52:	f7 f7                	div    %edi
  801f54:	31 ff                	xor    %edi,%edi
  801f56:	89 c3                	mov    %eax,%ebx
  801f58:	89 d8                	mov    %ebx,%eax
  801f5a:	89 fa                	mov    %edi,%edx
  801f5c:	83 c4 1c             	add    $0x1c,%esp
  801f5f:	5b                   	pop    %ebx
  801f60:	5e                   	pop    %esi
  801f61:	5f                   	pop    %edi
  801f62:	5d                   	pop    %ebp
  801f63:	c3                   	ret    
  801f64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f68:	39 ce                	cmp    %ecx,%esi
  801f6a:	72 0c                	jb     801f78 <__udivdi3+0x118>
  801f6c:	31 db                	xor    %ebx,%ebx
  801f6e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801f72:	0f 87 34 ff ff ff    	ja     801eac <__udivdi3+0x4c>
  801f78:	bb 01 00 00 00       	mov    $0x1,%ebx
  801f7d:	e9 2a ff ff ff       	jmp    801eac <__udivdi3+0x4c>
  801f82:	66 90                	xchg   %ax,%ax
  801f84:	66 90                	xchg   %ax,%ax
  801f86:	66 90                	xchg   %ax,%ax
  801f88:	66 90                	xchg   %ax,%ax
  801f8a:	66 90                	xchg   %ax,%ax
  801f8c:	66 90                	xchg   %ax,%ax
  801f8e:	66 90                	xchg   %ax,%ax

00801f90 <__umoddi3>:
  801f90:	55                   	push   %ebp
  801f91:	57                   	push   %edi
  801f92:	56                   	push   %esi
  801f93:	53                   	push   %ebx
  801f94:	83 ec 1c             	sub    $0x1c,%esp
  801f97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801f9b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801f9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801fa3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fa7:	85 d2                	test   %edx,%edx
  801fa9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801fad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fb1:	89 f3                	mov    %esi,%ebx
  801fb3:	89 3c 24             	mov    %edi,(%esp)
  801fb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fba:	75 1c                	jne    801fd8 <__umoddi3+0x48>
  801fbc:	39 f7                	cmp    %esi,%edi
  801fbe:	76 50                	jbe    802010 <__umoddi3+0x80>
  801fc0:	89 c8                	mov    %ecx,%eax
  801fc2:	89 f2                	mov    %esi,%edx
  801fc4:	f7 f7                	div    %edi
  801fc6:	89 d0                	mov    %edx,%eax
  801fc8:	31 d2                	xor    %edx,%edx
  801fca:	83 c4 1c             	add    $0x1c,%esp
  801fcd:	5b                   	pop    %ebx
  801fce:	5e                   	pop    %esi
  801fcf:	5f                   	pop    %edi
  801fd0:	5d                   	pop    %ebp
  801fd1:	c3                   	ret    
  801fd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fd8:	39 f2                	cmp    %esi,%edx
  801fda:	89 d0                	mov    %edx,%eax
  801fdc:	77 52                	ja     802030 <__umoddi3+0xa0>
  801fde:	0f bd ea             	bsr    %edx,%ebp
  801fe1:	83 f5 1f             	xor    $0x1f,%ebp
  801fe4:	75 5a                	jne    802040 <__umoddi3+0xb0>
  801fe6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801fea:	0f 82 e0 00 00 00    	jb     8020d0 <__umoddi3+0x140>
  801ff0:	39 0c 24             	cmp    %ecx,(%esp)
  801ff3:	0f 86 d7 00 00 00    	jbe    8020d0 <__umoddi3+0x140>
  801ff9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ffd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802001:	83 c4 1c             	add    $0x1c,%esp
  802004:	5b                   	pop    %ebx
  802005:	5e                   	pop    %esi
  802006:	5f                   	pop    %edi
  802007:	5d                   	pop    %ebp
  802008:	c3                   	ret    
  802009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802010:	85 ff                	test   %edi,%edi
  802012:	89 fd                	mov    %edi,%ebp
  802014:	75 0b                	jne    802021 <__umoddi3+0x91>
  802016:	b8 01 00 00 00       	mov    $0x1,%eax
  80201b:	31 d2                	xor    %edx,%edx
  80201d:	f7 f7                	div    %edi
  80201f:	89 c5                	mov    %eax,%ebp
  802021:	89 f0                	mov    %esi,%eax
  802023:	31 d2                	xor    %edx,%edx
  802025:	f7 f5                	div    %ebp
  802027:	89 c8                	mov    %ecx,%eax
  802029:	f7 f5                	div    %ebp
  80202b:	89 d0                	mov    %edx,%eax
  80202d:	eb 99                	jmp    801fc8 <__umoddi3+0x38>
  80202f:	90                   	nop
  802030:	89 c8                	mov    %ecx,%eax
  802032:	89 f2                	mov    %esi,%edx
  802034:	83 c4 1c             	add    $0x1c,%esp
  802037:	5b                   	pop    %ebx
  802038:	5e                   	pop    %esi
  802039:	5f                   	pop    %edi
  80203a:	5d                   	pop    %ebp
  80203b:	c3                   	ret    
  80203c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802040:	8b 34 24             	mov    (%esp),%esi
  802043:	bf 20 00 00 00       	mov    $0x20,%edi
  802048:	89 e9                	mov    %ebp,%ecx
  80204a:	29 ef                	sub    %ebp,%edi
  80204c:	d3 e0                	shl    %cl,%eax
  80204e:	89 f9                	mov    %edi,%ecx
  802050:	89 f2                	mov    %esi,%edx
  802052:	d3 ea                	shr    %cl,%edx
  802054:	89 e9                	mov    %ebp,%ecx
  802056:	09 c2                	or     %eax,%edx
  802058:	89 d8                	mov    %ebx,%eax
  80205a:	89 14 24             	mov    %edx,(%esp)
  80205d:	89 f2                	mov    %esi,%edx
  80205f:	d3 e2                	shl    %cl,%edx
  802061:	89 f9                	mov    %edi,%ecx
  802063:	89 54 24 04          	mov    %edx,0x4(%esp)
  802067:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80206b:	d3 e8                	shr    %cl,%eax
  80206d:	89 e9                	mov    %ebp,%ecx
  80206f:	89 c6                	mov    %eax,%esi
  802071:	d3 e3                	shl    %cl,%ebx
  802073:	89 f9                	mov    %edi,%ecx
  802075:	89 d0                	mov    %edx,%eax
  802077:	d3 e8                	shr    %cl,%eax
  802079:	89 e9                	mov    %ebp,%ecx
  80207b:	09 d8                	or     %ebx,%eax
  80207d:	89 d3                	mov    %edx,%ebx
  80207f:	89 f2                	mov    %esi,%edx
  802081:	f7 34 24             	divl   (%esp)
  802084:	89 d6                	mov    %edx,%esi
  802086:	d3 e3                	shl    %cl,%ebx
  802088:	f7 64 24 04          	mull   0x4(%esp)
  80208c:	39 d6                	cmp    %edx,%esi
  80208e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802092:	89 d1                	mov    %edx,%ecx
  802094:	89 c3                	mov    %eax,%ebx
  802096:	72 08                	jb     8020a0 <__umoddi3+0x110>
  802098:	75 11                	jne    8020ab <__umoddi3+0x11b>
  80209a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80209e:	73 0b                	jae    8020ab <__umoddi3+0x11b>
  8020a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8020a4:	1b 14 24             	sbb    (%esp),%edx
  8020a7:	89 d1                	mov    %edx,%ecx
  8020a9:	89 c3                	mov    %eax,%ebx
  8020ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8020af:	29 da                	sub    %ebx,%edx
  8020b1:	19 ce                	sbb    %ecx,%esi
  8020b3:	89 f9                	mov    %edi,%ecx
  8020b5:	89 f0                	mov    %esi,%eax
  8020b7:	d3 e0                	shl    %cl,%eax
  8020b9:	89 e9                	mov    %ebp,%ecx
  8020bb:	d3 ea                	shr    %cl,%edx
  8020bd:	89 e9                	mov    %ebp,%ecx
  8020bf:	d3 ee                	shr    %cl,%esi
  8020c1:	09 d0                	or     %edx,%eax
  8020c3:	89 f2                	mov    %esi,%edx
  8020c5:	83 c4 1c             	add    $0x1c,%esp
  8020c8:	5b                   	pop    %ebx
  8020c9:	5e                   	pop    %esi
  8020ca:	5f                   	pop    %edi
  8020cb:	5d                   	pop    %ebp
  8020cc:	c3                   	ret    
  8020cd:	8d 76 00             	lea    0x0(%esi),%esi
  8020d0:	29 f9                	sub    %edi,%ecx
  8020d2:	19 d6                	sbb    %edx,%esi
  8020d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020dc:	e9 18 ff ff ff       	jmp    801ff9 <__umoddi3+0x69>
