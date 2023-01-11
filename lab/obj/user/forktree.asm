
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
  800047:	68 60 26 80 00       	push   $0x802660
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
  8000a4:	68 71 26 80 00       	push   $0x802671
  8000a9:	6a 04                	push   $0x4
  8000ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000ae:	50                   	push   %eax
  8000af:	e8 61 06 00 00       	call   800715 <snprintf>
	// cprintf("%s, %s\n", cur, nxt);
	if (fork() == 0) {
  8000b4:	83 c4 20             	add    $0x20,%esp
  8000b7:	e8 1c 0e 00 00       	call   800ed8 <fork>
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
  8000e1:	68 70 26 80 00       	push   $0x802670
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
  80010d:	a3 08 40 80 00       	mov    %eax,0x804008

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
  80013c:	e8 19 11 00 00       	call   80125a <close_all>
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
  800246:	e8 75 21 00 00       	call   8023c0 <__udivdi3>
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
  800289:	e8 62 22 00 00       	call   8024f0 <__umoddi3>
  80028e:	83 c4 14             	add    $0x14,%esp
  800291:	0f be 80 80 26 80 00 	movsbl 0x802680(%eax),%eax
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
  80038d:	ff 24 85 c0 27 80 00 	jmp    *0x8027c0(,%eax,4)
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
  800451:	8b 14 85 20 29 80 00 	mov    0x802920(,%eax,4),%edx
  800458:	85 d2                	test   %edx,%edx
  80045a:	75 18                	jne    800474 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80045c:	50                   	push   %eax
  80045d:	68 98 26 80 00       	push   $0x802698
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
  800475:	68 0d 2b 80 00       	push   $0x802b0d
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
  800499:	b8 91 26 80 00       	mov    $0x802691,%eax
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
  800b14:	68 7f 29 80 00       	push   $0x80297f
  800b19:	6a 23                	push   $0x23
  800b1b:	68 9c 29 80 00       	push   $0x80299c
  800b20:	e8 ae 16 00 00       	call   8021d3 <_panic>

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
  800b95:	68 7f 29 80 00       	push   $0x80297f
  800b9a:	6a 23                	push   $0x23
  800b9c:	68 9c 29 80 00       	push   $0x80299c
  800ba1:	e8 2d 16 00 00       	call   8021d3 <_panic>

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
  800bd7:	68 7f 29 80 00       	push   $0x80297f
  800bdc:	6a 23                	push   $0x23
  800bde:	68 9c 29 80 00       	push   $0x80299c
  800be3:	e8 eb 15 00 00       	call   8021d3 <_panic>

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
  800c19:	68 7f 29 80 00       	push   $0x80297f
  800c1e:	6a 23                	push   $0x23
  800c20:	68 9c 29 80 00       	push   $0x80299c
  800c25:	e8 a9 15 00 00       	call   8021d3 <_panic>

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
  800c5b:	68 7f 29 80 00       	push   $0x80297f
  800c60:	6a 23                	push   $0x23
  800c62:	68 9c 29 80 00       	push   $0x80299c
  800c67:	e8 67 15 00 00       	call   8021d3 <_panic>

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
  800c9d:	68 7f 29 80 00       	push   $0x80297f
  800ca2:	6a 23                	push   $0x23
  800ca4:	68 9c 29 80 00       	push   $0x80299c
  800ca9:	e8 25 15 00 00       	call   8021d3 <_panic>

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
  800cdf:	68 7f 29 80 00       	push   $0x80297f
  800ce4:	6a 23                	push   $0x23
  800ce6:	68 9c 29 80 00       	push   $0x80299c
  800ceb:	e8 e3 14 00 00       	call   8021d3 <_panic>

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
  800d43:	68 7f 29 80 00       	push   $0x80297f
  800d48:	6a 23                	push   $0x23
  800d4a:	68 9c 29 80 00       	push   $0x80299c
  800d4f:	e8 7f 14 00 00       	call   8021d3 <_panic>

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

00800d5c <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	57                   	push   %edi
  800d60:	56                   	push   %esi
  800d61:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d62:	ba 00 00 00 00       	mov    $0x0,%edx
  800d67:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d6c:	89 d1                	mov    %edx,%ecx
  800d6e:	89 d3                	mov    %edx,%ebx
  800d70:	89 d7                	mov    %edx,%edi
  800d72:	89 d6                	mov    %edx,%esi
  800d74:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d76:	5b                   	pop    %ebx
  800d77:	5e                   	pop    %esi
  800d78:	5f                   	pop    %edi
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    

00800d7b <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	57                   	push   %edi
  800d7f:	56                   	push   %esi
  800d80:	53                   	push   %ebx
  800d81:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d84:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d89:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d91:	8b 55 08             	mov    0x8(%ebp),%edx
  800d94:	89 df                	mov    %ebx,%edi
  800d96:	89 de                	mov    %ebx,%esi
  800d98:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d9a:	85 c0                	test   %eax,%eax
  800d9c:	7e 17                	jle    800db5 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9e:	83 ec 0c             	sub    $0xc,%esp
  800da1:	50                   	push   %eax
  800da2:	6a 0f                	push   $0xf
  800da4:	68 7f 29 80 00       	push   $0x80297f
  800da9:	6a 23                	push   $0x23
  800dab:	68 9c 29 80 00       	push   $0x80299c
  800db0:	e8 1e 14 00 00       	call   8021d3 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800db5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db8:	5b                   	pop    %ebx
  800db9:	5e                   	pop    %esi
  800dba:	5f                   	pop    %edi
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    

00800dbd <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	57                   	push   %edi
  800dc1:	56                   	push   %esi
  800dc2:	53                   	push   %ebx
  800dc3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcb:	b8 10 00 00 00       	mov    $0x10,%eax
  800dd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd6:	89 df                	mov    %ebx,%edi
  800dd8:	89 de                	mov    %ebx,%esi
  800dda:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ddc:	85 c0                	test   %eax,%eax
  800dde:	7e 17                	jle    800df7 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de0:	83 ec 0c             	sub    $0xc,%esp
  800de3:	50                   	push   %eax
  800de4:	6a 10                	push   $0x10
  800de6:	68 7f 29 80 00       	push   $0x80297f
  800deb:	6a 23                	push   $0x23
  800ded:	68 9c 29 80 00       	push   $0x80299c
  800df2:	e8 dc 13 00 00       	call   8021d3 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  800df7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfa:	5b                   	pop    %ebx
  800dfb:	5e                   	pop    %esi
  800dfc:	5f                   	pop    %edi
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    

00800dff <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	56                   	push   %esi
  800e03:	53                   	push   %ebx
  800e04:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e07:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800e09:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e0d:	75 25                	jne    800e34 <pgfault+0x35>
  800e0f:	89 d8                	mov    %ebx,%eax
  800e11:	c1 e8 0c             	shr    $0xc,%eax
  800e14:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e1b:	f6 c4 08             	test   $0x8,%ah
  800e1e:	75 14                	jne    800e34 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800e20:	83 ec 04             	sub    $0x4,%esp
  800e23:	68 ac 29 80 00       	push   $0x8029ac
  800e28:	6a 1e                	push   $0x1e
  800e2a:	68 40 2a 80 00       	push   $0x802a40
  800e2f:	e8 9f 13 00 00       	call   8021d3 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800e34:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800e3a:	e8 ee fc ff ff       	call   800b2d <sys_getenvid>
  800e3f:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800e41:	83 ec 04             	sub    $0x4,%esp
  800e44:	6a 07                	push   $0x7
  800e46:	68 00 f0 7f 00       	push   $0x7ff000
  800e4b:	50                   	push   %eax
  800e4c:	e8 1a fd ff ff       	call   800b6b <sys_page_alloc>
	if (r < 0)
  800e51:	83 c4 10             	add    $0x10,%esp
  800e54:	85 c0                	test   %eax,%eax
  800e56:	79 12                	jns    800e6a <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800e58:	50                   	push   %eax
  800e59:	68 d8 29 80 00       	push   $0x8029d8
  800e5e:	6a 33                	push   $0x33
  800e60:	68 40 2a 80 00       	push   $0x802a40
  800e65:	e8 69 13 00 00       	call   8021d3 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800e6a:	83 ec 04             	sub    $0x4,%esp
  800e6d:	68 00 10 00 00       	push   $0x1000
  800e72:	53                   	push   %ebx
  800e73:	68 00 f0 7f 00       	push   $0x7ff000
  800e78:	e8 e5 fa ff ff       	call   800962 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800e7d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e84:	53                   	push   %ebx
  800e85:	56                   	push   %esi
  800e86:	68 00 f0 7f 00       	push   $0x7ff000
  800e8b:	56                   	push   %esi
  800e8c:	e8 1d fd ff ff       	call   800bae <sys_page_map>
	if (r < 0)
  800e91:	83 c4 20             	add    $0x20,%esp
  800e94:	85 c0                	test   %eax,%eax
  800e96:	79 12                	jns    800eaa <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800e98:	50                   	push   %eax
  800e99:	68 fc 29 80 00       	push   $0x8029fc
  800e9e:	6a 3b                	push   $0x3b
  800ea0:	68 40 2a 80 00       	push   $0x802a40
  800ea5:	e8 29 13 00 00       	call   8021d3 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800eaa:	83 ec 08             	sub    $0x8,%esp
  800ead:	68 00 f0 7f 00       	push   $0x7ff000
  800eb2:	56                   	push   %esi
  800eb3:	e8 38 fd ff ff       	call   800bf0 <sys_page_unmap>
	if (r < 0)
  800eb8:	83 c4 10             	add    $0x10,%esp
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	79 12                	jns    800ed1 <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800ebf:	50                   	push   %eax
  800ec0:	68 20 2a 80 00       	push   $0x802a20
  800ec5:	6a 40                	push   $0x40
  800ec7:	68 40 2a 80 00       	push   $0x802a40
  800ecc:	e8 02 13 00 00       	call   8021d3 <_panic>
}
  800ed1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ed4:	5b                   	pop    %ebx
  800ed5:	5e                   	pop    %esi
  800ed6:	5d                   	pop    %ebp
  800ed7:	c3                   	ret    

00800ed8 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	57                   	push   %edi
  800edc:	56                   	push   %esi
  800edd:	53                   	push   %ebx
  800ede:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800ee1:	68 ff 0d 80 00       	push   $0x800dff
  800ee6:	e8 2e 13 00 00       	call   802219 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800eeb:	b8 07 00 00 00       	mov    $0x7,%eax
  800ef0:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800ef2:	83 c4 10             	add    $0x10,%esp
  800ef5:	85 c0                	test   %eax,%eax
  800ef7:	0f 88 64 01 00 00    	js     801061 <fork+0x189>
  800efd:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800f02:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800f07:	85 c0                	test   %eax,%eax
  800f09:	75 21                	jne    800f2c <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f0b:	e8 1d fc ff ff       	call   800b2d <sys_getenvid>
  800f10:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f15:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f18:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f1d:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  800f22:	ba 00 00 00 00       	mov    $0x0,%edx
  800f27:	e9 3f 01 00 00       	jmp    80106b <fork+0x193>
  800f2c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f2f:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800f31:	89 d8                	mov    %ebx,%eax
  800f33:	c1 e8 16             	shr    $0x16,%eax
  800f36:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f3d:	a8 01                	test   $0x1,%al
  800f3f:	0f 84 bd 00 00 00    	je     801002 <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800f45:	89 d8                	mov    %ebx,%eax
  800f47:	c1 e8 0c             	shr    $0xc,%eax
  800f4a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f51:	f6 c2 01             	test   $0x1,%dl
  800f54:	0f 84 a8 00 00 00    	je     801002 <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  800f5a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f61:	a8 04                	test   $0x4,%al
  800f63:	0f 84 99 00 00 00    	je     801002 <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800f69:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f70:	f6 c4 04             	test   $0x4,%ah
  800f73:	74 17                	je     800f8c <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800f75:	83 ec 0c             	sub    $0xc,%esp
  800f78:	68 07 0e 00 00       	push   $0xe07
  800f7d:	53                   	push   %ebx
  800f7e:	57                   	push   %edi
  800f7f:	53                   	push   %ebx
  800f80:	6a 00                	push   $0x0
  800f82:	e8 27 fc ff ff       	call   800bae <sys_page_map>
  800f87:	83 c4 20             	add    $0x20,%esp
  800f8a:	eb 76                	jmp    801002 <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f8c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f93:	a8 02                	test   $0x2,%al
  800f95:	75 0c                	jne    800fa3 <fork+0xcb>
  800f97:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f9e:	f6 c4 08             	test   $0x8,%ah
  800fa1:	74 3f                	je     800fe2 <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800fa3:	83 ec 0c             	sub    $0xc,%esp
  800fa6:	68 05 08 00 00       	push   $0x805
  800fab:	53                   	push   %ebx
  800fac:	57                   	push   %edi
  800fad:	53                   	push   %ebx
  800fae:	6a 00                	push   $0x0
  800fb0:	e8 f9 fb ff ff       	call   800bae <sys_page_map>
		if (r < 0)
  800fb5:	83 c4 20             	add    $0x20,%esp
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	0f 88 a5 00 00 00    	js     801065 <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800fc0:	83 ec 0c             	sub    $0xc,%esp
  800fc3:	68 05 08 00 00       	push   $0x805
  800fc8:	53                   	push   %ebx
  800fc9:	6a 00                	push   $0x0
  800fcb:	53                   	push   %ebx
  800fcc:	6a 00                	push   $0x0
  800fce:	e8 db fb ff ff       	call   800bae <sys_page_map>
  800fd3:	83 c4 20             	add    $0x20,%esp
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fdd:	0f 4f c1             	cmovg  %ecx,%eax
  800fe0:	eb 1c                	jmp    800ffe <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800fe2:	83 ec 0c             	sub    $0xc,%esp
  800fe5:	6a 05                	push   $0x5
  800fe7:	53                   	push   %ebx
  800fe8:	57                   	push   %edi
  800fe9:	53                   	push   %ebx
  800fea:	6a 00                	push   $0x0
  800fec:	e8 bd fb ff ff       	call   800bae <sys_page_map>
  800ff1:	83 c4 20             	add    $0x20,%esp
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ffb:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  800ffe:	85 c0                	test   %eax,%eax
  801000:	78 67                	js     801069 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801002:	83 c6 01             	add    $0x1,%esi
  801005:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80100b:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  801011:	0f 85 1a ff ff ff    	jne    800f31 <fork+0x59>
  801017:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  80101a:	83 ec 04             	sub    $0x4,%esp
  80101d:	6a 07                	push   $0x7
  80101f:	68 00 f0 bf ee       	push   $0xeebff000
  801024:	57                   	push   %edi
  801025:	e8 41 fb ff ff       	call   800b6b <sys_page_alloc>
	if (r < 0)
  80102a:	83 c4 10             	add    $0x10,%esp
		return r;
  80102d:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  80102f:	85 c0                	test   %eax,%eax
  801031:	78 38                	js     80106b <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801033:	83 ec 08             	sub    $0x8,%esp
  801036:	68 60 22 80 00       	push   $0x802260
  80103b:	57                   	push   %edi
  80103c:	e8 75 fc ff ff       	call   800cb6 <sys_env_set_pgfault_upcall>
	if (r < 0)
  801041:	83 c4 10             	add    $0x10,%esp
		return r;
  801044:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  801046:	85 c0                	test   %eax,%eax
  801048:	78 21                	js     80106b <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  80104a:	83 ec 08             	sub    $0x8,%esp
  80104d:	6a 02                	push   $0x2
  80104f:	57                   	push   %edi
  801050:	e8 dd fb ff ff       	call   800c32 <sys_env_set_status>
	if (r < 0)
  801055:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801058:	85 c0                	test   %eax,%eax
  80105a:	0f 48 f8             	cmovs  %eax,%edi
  80105d:	89 fa                	mov    %edi,%edx
  80105f:	eb 0a                	jmp    80106b <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  801061:	89 c2                	mov    %eax,%edx
  801063:	eb 06                	jmp    80106b <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801065:	89 c2                	mov    %eax,%edx
  801067:	eb 02                	jmp    80106b <fork+0x193>
  801069:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  80106b:	89 d0                	mov    %edx,%eax
  80106d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801070:	5b                   	pop    %ebx
  801071:	5e                   	pop    %esi
  801072:	5f                   	pop    %edi
  801073:	5d                   	pop    %ebp
  801074:	c3                   	ret    

00801075 <sfork>:

// Challenge!
int
sfork(void)
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80107b:	68 4b 2a 80 00       	push   $0x802a4b
  801080:	68 c9 00 00 00       	push   $0xc9
  801085:	68 40 2a 80 00       	push   $0x802a40
  80108a:	e8 44 11 00 00       	call   8021d3 <_panic>

0080108f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80108f:	55                   	push   %ebp
  801090:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801092:	8b 45 08             	mov    0x8(%ebp),%eax
  801095:	05 00 00 00 30       	add    $0x30000000,%eax
  80109a:	c1 e8 0c             	shr    $0xc,%eax
}
  80109d:	5d                   	pop    %ebp
  80109e:	c3                   	ret    

0080109f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80109f:	55                   	push   %ebp
  8010a0:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a5:	05 00 00 00 30       	add    $0x30000000,%eax
  8010aa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010af:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010b4:	5d                   	pop    %ebp
  8010b5:	c3                   	ret    

008010b6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010b6:	55                   	push   %ebp
  8010b7:	89 e5                	mov    %esp,%ebp
  8010b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010bc:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010c1:	89 c2                	mov    %eax,%edx
  8010c3:	c1 ea 16             	shr    $0x16,%edx
  8010c6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010cd:	f6 c2 01             	test   $0x1,%dl
  8010d0:	74 11                	je     8010e3 <fd_alloc+0x2d>
  8010d2:	89 c2                	mov    %eax,%edx
  8010d4:	c1 ea 0c             	shr    $0xc,%edx
  8010d7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010de:	f6 c2 01             	test   $0x1,%dl
  8010e1:	75 09                	jne    8010ec <fd_alloc+0x36>
			*fd_store = fd;
  8010e3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ea:	eb 17                	jmp    801103 <fd_alloc+0x4d>
  8010ec:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010f1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010f6:	75 c9                	jne    8010c1 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010f8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010fe:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801103:	5d                   	pop    %ebp
  801104:	c3                   	ret    

00801105 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80110b:	83 f8 1f             	cmp    $0x1f,%eax
  80110e:	77 36                	ja     801146 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801110:	c1 e0 0c             	shl    $0xc,%eax
  801113:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801118:	89 c2                	mov    %eax,%edx
  80111a:	c1 ea 16             	shr    $0x16,%edx
  80111d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801124:	f6 c2 01             	test   $0x1,%dl
  801127:	74 24                	je     80114d <fd_lookup+0x48>
  801129:	89 c2                	mov    %eax,%edx
  80112b:	c1 ea 0c             	shr    $0xc,%edx
  80112e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801135:	f6 c2 01             	test   $0x1,%dl
  801138:	74 1a                	je     801154 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80113a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80113d:	89 02                	mov    %eax,(%edx)
	return 0;
  80113f:	b8 00 00 00 00       	mov    $0x0,%eax
  801144:	eb 13                	jmp    801159 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801146:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80114b:	eb 0c                	jmp    801159 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80114d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801152:	eb 05                	jmp    801159 <fd_lookup+0x54>
  801154:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801159:	5d                   	pop    %ebp
  80115a:	c3                   	ret    

0080115b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80115b:	55                   	push   %ebp
  80115c:	89 e5                	mov    %esp,%ebp
  80115e:	83 ec 08             	sub    $0x8,%esp
  801161:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801164:	ba e0 2a 80 00       	mov    $0x802ae0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801169:	eb 13                	jmp    80117e <dev_lookup+0x23>
  80116b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80116e:	39 08                	cmp    %ecx,(%eax)
  801170:	75 0c                	jne    80117e <dev_lookup+0x23>
			*dev = devtab[i];
  801172:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801175:	89 01                	mov    %eax,(%ecx)
			return 0;
  801177:	b8 00 00 00 00       	mov    $0x0,%eax
  80117c:	eb 2e                	jmp    8011ac <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80117e:	8b 02                	mov    (%edx),%eax
  801180:	85 c0                	test   %eax,%eax
  801182:	75 e7                	jne    80116b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801184:	a1 08 40 80 00       	mov    0x804008,%eax
  801189:	8b 40 48             	mov    0x48(%eax),%eax
  80118c:	83 ec 04             	sub    $0x4,%esp
  80118f:	51                   	push   %ecx
  801190:	50                   	push   %eax
  801191:	68 64 2a 80 00       	push   $0x802a64
  801196:	e8 48 f0 ff ff       	call   8001e3 <cprintf>
	*dev = 0;
  80119b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80119e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011a4:	83 c4 10             	add    $0x10,%esp
  8011a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011ac:	c9                   	leave  
  8011ad:	c3                   	ret    

008011ae <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011ae:	55                   	push   %ebp
  8011af:	89 e5                	mov    %esp,%ebp
  8011b1:	56                   	push   %esi
  8011b2:	53                   	push   %ebx
  8011b3:	83 ec 10             	sub    $0x10,%esp
  8011b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8011b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011bf:	50                   	push   %eax
  8011c0:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011c6:	c1 e8 0c             	shr    $0xc,%eax
  8011c9:	50                   	push   %eax
  8011ca:	e8 36 ff ff ff       	call   801105 <fd_lookup>
  8011cf:	83 c4 08             	add    $0x8,%esp
  8011d2:	85 c0                	test   %eax,%eax
  8011d4:	78 05                	js     8011db <fd_close+0x2d>
	    || fd != fd2)
  8011d6:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011d9:	74 0c                	je     8011e7 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011db:	84 db                	test   %bl,%bl
  8011dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8011e2:	0f 44 c2             	cmove  %edx,%eax
  8011e5:	eb 41                	jmp    801228 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011e7:	83 ec 08             	sub    $0x8,%esp
  8011ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ed:	50                   	push   %eax
  8011ee:	ff 36                	pushl  (%esi)
  8011f0:	e8 66 ff ff ff       	call   80115b <dev_lookup>
  8011f5:	89 c3                	mov    %eax,%ebx
  8011f7:	83 c4 10             	add    $0x10,%esp
  8011fa:	85 c0                	test   %eax,%eax
  8011fc:	78 1a                	js     801218 <fd_close+0x6a>
		if (dev->dev_close)
  8011fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801201:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801204:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801209:	85 c0                	test   %eax,%eax
  80120b:	74 0b                	je     801218 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80120d:	83 ec 0c             	sub    $0xc,%esp
  801210:	56                   	push   %esi
  801211:	ff d0                	call   *%eax
  801213:	89 c3                	mov    %eax,%ebx
  801215:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801218:	83 ec 08             	sub    $0x8,%esp
  80121b:	56                   	push   %esi
  80121c:	6a 00                	push   $0x0
  80121e:	e8 cd f9 ff ff       	call   800bf0 <sys_page_unmap>
	return r;
  801223:	83 c4 10             	add    $0x10,%esp
  801226:	89 d8                	mov    %ebx,%eax
}
  801228:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80122b:	5b                   	pop    %ebx
  80122c:	5e                   	pop    %esi
  80122d:	5d                   	pop    %ebp
  80122e:	c3                   	ret    

0080122f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80122f:	55                   	push   %ebp
  801230:	89 e5                	mov    %esp,%ebp
  801232:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801235:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801238:	50                   	push   %eax
  801239:	ff 75 08             	pushl  0x8(%ebp)
  80123c:	e8 c4 fe ff ff       	call   801105 <fd_lookup>
  801241:	83 c4 08             	add    $0x8,%esp
  801244:	85 c0                	test   %eax,%eax
  801246:	78 10                	js     801258 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801248:	83 ec 08             	sub    $0x8,%esp
  80124b:	6a 01                	push   $0x1
  80124d:	ff 75 f4             	pushl  -0xc(%ebp)
  801250:	e8 59 ff ff ff       	call   8011ae <fd_close>
  801255:	83 c4 10             	add    $0x10,%esp
}
  801258:	c9                   	leave  
  801259:	c3                   	ret    

0080125a <close_all>:

void
close_all(void)
{
  80125a:	55                   	push   %ebp
  80125b:	89 e5                	mov    %esp,%ebp
  80125d:	53                   	push   %ebx
  80125e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801261:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801266:	83 ec 0c             	sub    $0xc,%esp
  801269:	53                   	push   %ebx
  80126a:	e8 c0 ff ff ff       	call   80122f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80126f:	83 c3 01             	add    $0x1,%ebx
  801272:	83 c4 10             	add    $0x10,%esp
  801275:	83 fb 20             	cmp    $0x20,%ebx
  801278:	75 ec                	jne    801266 <close_all+0xc>
		close(i);
}
  80127a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80127d:	c9                   	leave  
  80127e:	c3                   	ret    

0080127f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80127f:	55                   	push   %ebp
  801280:	89 e5                	mov    %esp,%ebp
  801282:	57                   	push   %edi
  801283:	56                   	push   %esi
  801284:	53                   	push   %ebx
  801285:	83 ec 2c             	sub    $0x2c,%esp
  801288:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80128b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80128e:	50                   	push   %eax
  80128f:	ff 75 08             	pushl  0x8(%ebp)
  801292:	e8 6e fe ff ff       	call   801105 <fd_lookup>
  801297:	83 c4 08             	add    $0x8,%esp
  80129a:	85 c0                	test   %eax,%eax
  80129c:	0f 88 c1 00 00 00    	js     801363 <dup+0xe4>
		return r;
	close(newfdnum);
  8012a2:	83 ec 0c             	sub    $0xc,%esp
  8012a5:	56                   	push   %esi
  8012a6:	e8 84 ff ff ff       	call   80122f <close>

	newfd = INDEX2FD(newfdnum);
  8012ab:	89 f3                	mov    %esi,%ebx
  8012ad:	c1 e3 0c             	shl    $0xc,%ebx
  8012b0:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012b6:	83 c4 04             	add    $0x4,%esp
  8012b9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012bc:	e8 de fd ff ff       	call   80109f <fd2data>
  8012c1:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012c3:	89 1c 24             	mov    %ebx,(%esp)
  8012c6:	e8 d4 fd ff ff       	call   80109f <fd2data>
  8012cb:	83 c4 10             	add    $0x10,%esp
  8012ce:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012d1:	89 f8                	mov    %edi,%eax
  8012d3:	c1 e8 16             	shr    $0x16,%eax
  8012d6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012dd:	a8 01                	test   $0x1,%al
  8012df:	74 37                	je     801318 <dup+0x99>
  8012e1:	89 f8                	mov    %edi,%eax
  8012e3:	c1 e8 0c             	shr    $0xc,%eax
  8012e6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012ed:	f6 c2 01             	test   $0x1,%dl
  8012f0:	74 26                	je     801318 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012f2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012f9:	83 ec 0c             	sub    $0xc,%esp
  8012fc:	25 07 0e 00 00       	and    $0xe07,%eax
  801301:	50                   	push   %eax
  801302:	ff 75 d4             	pushl  -0x2c(%ebp)
  801305:	6a 00                	push   $0x0
  801307:	57                   	push   %edi
  801308:	6a 00                	push   $0x0
  80130a:	e8 9f f8 ff ff       	call   800bae <sys_page_map>
  80130f:	89 c7                	mov    %eax,%edi
  801311:	83 c4 20             	add    $0x20,%esp
  801314:	85 c0                	test   %eax,%eax
  801316:	78 2e                	js     801346 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801318:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80131b:	89 d0                	mov    %edx,%eax
  80131d:	c1 e8 0c             	shr    $0xc,%eax
  801320:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801327:	83 ec 0c             	sub    $0xc,%esp
  80132a:	25 07 0e 00 00       	and    $0xe07,%eax
  80132f:	50                   	push   %eax
  801330:	53                   	push   %ebx
  801331:	6a 00                	push   $0x0
  801333:	52                   	push   %edx
  801334:	6a 00                	push   $0x0
  801336:	e8 73 f8 ff ff       	call   800bae <sys_page_map>
  80133b:	89 c7                	mov    %eax,%edi
  80133d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801340:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801342:	85 ff                	test   %edi,%edi
  801344:	79 1d                	jns    801363 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801346:	83 ec 08             	sub    $0x8,%esp
  801349:	53                   	push   %ebx
  80134a:	6a 00                	push   $0x0
  80134c:	e8 9f f8 ff ff       	call   800bf0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801351:	83 c4 08             	add    $0x8,%esp
  801354:	ff 75 d4             	pushl  -0x2c(%ebp)
  801357:	6a 00                	push   $0x0
  801359:	e8 92 f8 ff ff       	call   800bf0 <sys_page_unmap>
	return r;
  80135e:	83 c4 10             	add    $0x10,%esp
  801361:	89 f8                	mov    %edi,%eax
}
  801363:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801366:	5b                   	pop    %ebx
  801367:	5e                   	pop    %esi
  801368:	5f                   	pop    %edi
  801369:	5d                   	pop    %ebp
  80136a:	c3                   	ret    

0080136b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
  80136e:	53                   	push   %ebx
  80136f:	83 ec 14             	sub    $0x14,%esp
  801372:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801375:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801378:	50                   	push   %eax
  801379:	53                   	push   %ebx
  80137a:	e8 86 fd ff ff       	call   801105 <fd_lookup>
  80137f:	83 c4 08             	add    $0x8,%esp
  801382:	89 c2                	mov    %eax,%edx
  801384:	85 c0                	test   %eax,%eax
  801386:	78 6d                	js     8013f5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801388:	83 ec 08             	sub    $0x8,%esp
  80138b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80138e:	50                   	push   %eax
  80138f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801392:	ff 30                	pushl  (%eax)
  801394:	e8 c2 fd ff ff       	call   80115b <dev_lookup>
  801399:	83 c4 10             	add    $0x10,%esp
  80139c:	85 c0                	test   %eax,%eax
  80139e:	78 4c                	js     8013ec <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013a3:	8b 42 08             	mov    0x8(%edx),%eax
  8013a6:	83 e0 03             	and    $0x3,%eax
  8013a9:	83 f8 01             	cmp    $0x1,%eax
  8013ac:	75 21                	jne    8013cf <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013ae:	a1 08 40 80 00       	mov    0x804008,%eax
  8013b3:	8b 40 48             	mov    0x48(%eax),%eax
  8013b6:	83 ec 04             	sub    $0x4,%esp
  8013b9:	53                   	push   %ebx
  8013ba:	50                   	push   %eax
  8013bb:	68 a5 2a 80 00       	push   $0x802aa5
  8013c0:	e8 1e ee ff ff       	call   8001e3 <cprintf>
		return -E_INVAL;
  8013c5:	83 c4 10             	add    $0x10,%esp
  8013c8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013cd:	eb 26                	jmp    8013f5 <read+0x8a>
	}
	if (!dev->dev_read)
  8013cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d2:	8b 40 08             	mov    0x8(%eax),%eax
  8013d5:	85 c0                	test   %eax,%eax
  8013d7:	74 17                	je     8013f0 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013d9:	83 ec 04             	sub    $0x4,%esp
  8013dc:	ff 75 10             	pushl  0x10(%ebp)
  8013df:	ff 75 0c             	pushl  0xc(%ebp)
  8013e2:	52                   	push   %edx
  8013e3:	ff d0                	call   *%eax
  8013e5:	89 c2                	mov    %eax,%edx
  8013e7:	83 c4 10             	add    $0x10,%esp
  8013ea:	eb 09                	jmp    8013f5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ec:	89 c2                	mov    %eax,%edx
  8013ee:	eb 05                	jmp    8013f5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013f0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013f5:	89 d0                	mov    %edx,%eax
  8013f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fa:	c9                   	leave  
  8013fb:	c3                   	ret    

008013fc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013fc:	55                   	push   %ebp
  8013fd:	89 e5                	mov    %esp,%ebp
  8013ff:	57                   	push   %edi
  801400:	56                   	push   %esi
  801401:	53                   	push   %ebx
  801402:	83 ec 0c             	sub    $0xc,%esp
  801405:	8b 7d 08             	mov    0x8(%ebp),%edi
  801408:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80140b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801410:	eb 21                	jmp    801433 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801412:	83 ec 04             	sub    $0x4,%esp
  801415:	89 f0                	mov    %esi,%eax
  801417:	29 d8                	sub    %ebx,%eax
  801419:	50                   	push   %eax
  80141a:	89 d8                	mov    %ebx,%eax
  80141c:	03 45 0c             	add    0xc(%ebp),%eax
  80141f:	50                   	push   %eax
  801420:	57                   	push   %edi
  801421:	e8 45 ff ff ff       	call   80136b <read>
		if (m < 0)
  801426:	83 c4 10             	add    $0x10,%esp
  801429:	85 c0                	test   %eax,%eax
  80142b:	78 10                	js     80143d <readn+0x41>
			return m;
		if (m == 0)
  80142d:	85 c0                	test   %eax,%eax
  80142f:	74 0a                	je     80143b <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801431:	01 c3                	add    %eax,%ebx
  801433:	39 f3                	cmp    %esi,%ebx
  801435:	72 db                	jb     801412 <readn+0x16>
  801437:	89 d8                	mov    %ebx,%eax
  801439:	eb 02                	jmp    80143d <readn+0x41>
  80143b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80143d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801440:	5b                   	pop    %ebx
  801441:	5e                   	pop    %esi
  801442:	5f                   	pop    %edi
  801443:	5d                   	pop    %ebp
  801444:	c3                   	ret    

00801445 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801445:	55                   	push   %ebp
  801446:	89 e5                	mov    %esp,%ebp
  801448:	53                   	push   %ebx
  801449:	83 ec 14             	sub    $0x14,%esp
  80144c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80144f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801452:	50                   	push   %eax
  801453:	53                   	push   %ebx
  801454:	e8 ac fc ff ff       	call   801105 <fd_lookup>
  801459:	83 c4 08             	add    $0x8,%esp
  80145c:	89 c2                	mov    %eax,%edx
  80145e:	85 c0                	test   %eax,%eax
  801460:	78 68                	js     8014ca <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801462:	83 ec 08             	sub    $0x8,%esp
  801465:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801468:	50                   	push   %eax
  801469:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146c:	ff 30                	pushl  (%eax)
  80146e:	e8 e8 fc ff ff       	call   80115b <dev_lookup>
  801473:	83 c4 10             	add    $0x10,%esp
  801476:	85 c0                	test   %eax,%eax
  801478:	78 47                	js     8014c1 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80147a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801481:	75 21                	jne    8014a4 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801483:	a1 08 40 80 00       	mov    0x804008,%eax
  801488:	8b 40 48             	mov    0x48(%eax),%eax
  80148b:	83 ec 04             	sub    $0x4,%esp
  80148e:	53                   	push   %ebx
  80148f:	50                   	push   %eax
  801490:	68 c1 2a 80 00       	push   $0x802ac1
  801495:	e8 49 ed ff ff       	call   8001e3 <cprintf>
		return -E_INVAL;
  80149a:	83 c4 10             	add    $0x10,%esp
  80149d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014a2:	eb 26                	jmp    8014ca <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014a7:	8b 52 0c             	mov    0xc(%edx),%edx
  8014aa:	85 d2                	test   %edx,%edx
  8014ac:	74 17                	je     8014c5 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014ae:	83 ec 04             	sub    $0x4,%esp
  8014b1:	ff 75 10             	pushl  0x10(%ebp)
  8014b4:	ff 75 0c             	pushl  0xc(%ebp)
  8014b7:	50                   	push   %eax
  8014b8:	ff d2                	call   *%edx
  8014ba:	89 c2                	mov    %eax,%edx
  8014bc:	83 c4 10             	add    $0x10,%esp
  8014bf:	eb 09                	jmp    8014ca <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c1:	89 c2                	mov    %eax,%edx
  8014c3:	eb 05                	jmp    8014ca <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014c5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014ca:	89 d0                	mov    %edx,%eax
  8014cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014cf:	c9                   	leave  
  8014d0:	c3                   	ret    

008014d1 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014d1:	55                   	push   %ebp
  8014d2:	89 e5                	mov    %esp,%ebp
  8014d4:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014d7:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014da:	50                   	push   %eax
  8014db:	ff 75 08             	pushl  0x8(%ebp)
  8014de:	e8 22 fc ff ff       	call   801105 <fd_lookup>
  8014e3:	83 c4 08             	add    $0x8,%esp
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	78 0e                	js     8014f8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014f0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014f8:	c9                   	leave  
  8014f9:	c3                   	ret    

008014fa <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	53                   	push   %ebx
  8014fe:	83 ec 14             	sub    $0x14,%esp
  801501:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801504:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801507:	50                   	push   %eax
  801508:	53                   	push   %ebx
  801509:	e8 f7 fb ff ff       	call   801105 <fd_lookup>
  80150e:	83 c4 08             	add    $0x8,%esp
  801511:	89 c2                	mov    %eax,%edx
  801513:	85 c0                	test   %eax,%eax
  801515:	78 65                	js     80157c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801517:	83 ec 08             	sub    $0x8,%esp
  80151a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151d:	50                   	push   %eax
  80151e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801521:	ff 30                	pushl  (%eax)
  801523:	e8 33 fc ff ff       	call   80115b <dev_lookup>
  801528:	83 c4 10             	add    $0x10,%esp
  80152b:	85 c0                	test   %eax,%eax
  80152d:	78 44                	js     801573 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80152f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801532:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801536:	75 21                	jne    801559 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801538:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80153d:	8b 40 48             	mov    0x48(%eax),%eax
  801540:	83 ec 04             	sub    $0x4,%esp
  801543:	53                   	push   %ebx
  801544:	50                   	push   %eax
  801545:	68 84 2a 80 00       	push   $0x802a84
  80154a:	e8 94 ec ff ff       	call   8001e3 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80154f:	83 c4 10             	add    $0x10,%esp
  801552:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801557:	eb 23                	jmp    80157c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801559:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80155c:	8b 52 18             	mov    0x18(%edx),%edx
  80155f:	85 d2                	test   %edx,%edx
  801561:	74 14                	je     801577 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801563:	83 ec 08             	sub    $0x8,%esp
  801566:	ff 75 0c             	pushl  0xc(%ebp)
  801569:	50                   	push   %eax
  80156a:	ff d2                	call   *%edx
  80156c:	89 c2                	mov    %eax,%edx
  80156e:	83 c4 10             	add    $0x10,%esp
  801571:	eb 09                	jmp    80157c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801573:	89 c2                	mov    %eax,%edx
  801575:	eb 05                	jmp    80157c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801577:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80157c:	89 d0                	mov    %edx,%eax
  80157e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801581:	c9                   	leave  
  801582:	c3                   	ret    

00801583 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801583:	55                   	push   %ebp
  801584:	89 e5                	mov    %esp,%ebp
  801586:	53                   	push   %ebx
  801587:	83 ec 14             	sub    $0x14,%esp
  80158a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80158d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801590:	50                   	push   %eax
  801591:	ff 75 08             	pushl  0x8(%ebp)
  801594:	e8 6c fb ff ff       	call   801105 <fd_lookup>
  801599:	83 c4 08             	add    $0x8,%esp
  80159c:	89 c2                	mov    %eax,%edx
  80159e:	85 c0                	test   %eax,%eax
  8015a0:	78 58                	js     8015fa <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a2:	83 ec 08             	sub    $0x8,%esp
  8015a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a8:	50                   	push   %eax
  8015a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ac:	ff 30                	pushl  (%eax)
  8015ae:	e8 a8 fb ff ff       	call   80115b <dev_lookup>
  8015b3:	83 c4 10             	add    $0x10,%esp
  8015b6:	85 c0                	test   %eax,%eax
  8015b8:	78 37                	js     8015f1 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015bd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015c1:	74 32                	je     8015f5 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015c3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015c6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015cd:	00 00 00 
	stat->st_isdir = 0;
  8015d0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015d7:	00 00 00 
	stat->st_dev = dev;
  8015da:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015e0:	83 ec 08             	sub    $0x8,%esp
  8015e3:	53                   	push   %ebx
  8015e4:	ff 75 f0             	pushl  -0x10(%ebp)
  8015e7:	ff 50 14             	call   *0x14(%eax)
  8015ea:	89 c2                	mov    %eax,%edx
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	eb 09                	jmp    8015fa <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f1:	89 c2                	mov    %eax,%edx
  8015f3:	eb 05                	jmp    8015fa <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015f5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015fa:	89 d0                	mov    %edx,%eax
  8015fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ff:	c9                   	leave  
  801600:	c3                   	ret    

00801601 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801601:	55                   	push   %ebp
  801602:	89 e5                	mov    %esp,%ebp
  801604:	56                   	push   %esi
  801605:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801606:	83 ec 08             	sub    $0x8,%esp
  801609:	6a 00                	push   $0x0
  80160b:	ff 75 08             	pushl  0x8(%ebp)
  80160e:	e8 d6 01 00 00       	call   8017e9 <open>
  801613:	89 c3                	mov    %eax,%ebx
  801615:	83 c4 10             	add    $0x10,%esp
  801618:	85 c0                	test   %eax,%eax
  80161a:	78 1b                	js     801637 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80161c:	83 ec 08             	sub    $0x8,%esp
  80161f:	ff 75 0c             	pushl  0xc(%ebp)
  801622:	50                   	push   %eax
  801623:	e8 5b ff ff ff       	call   801583 <fstat>
  801628:	89 c6                	mov    %eax,%esi
	close(fd);
  80162a:	89 1c 24             	mov    %ebx,(%esp)
  80162d:	e8 fd fb ff ff       	call   80122f <close>
	return r;
  801632:	83 c4 10             	add    $0x10,%esp
  801635:	89 f0                	mov    %esi,%eax
}
  801637:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80163a:	5b                   	pop    %ebx
  80163b:	5e                   	pop    %esi
  80163c:	5d                   	pop    %ebp
  80163d:	c3                   	ret    

0080163e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	56                   	push   %esi
  801642:	53                   	push   %ebx
  801643:	89 c6                	mov    %eax,%esi
  801645:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801647:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80164e:	75 12                	jne    801662 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801650:	83 ec 0c             	sub    $0xc,%esp
  801653:	6a 01                	push   $0x1
  801655:	e8 e5 0c 00 00       	call   80233f <ipc_find_env>
  80165a:	a3 00 40 80 00       	mov    %eax,0x804000
  80165f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801662:	6a 07                	push   $0x7
  801664:	68 00 50 80 00       	push   $0x805000
  801669:	56                   	push   %esi
  80166a:	ff 35 00 40 80 00    	pushl  0x804000
  801670:	e8 76 0c 00 00       	call   8022eb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801675:	83 c4 0c             	add    $0xc,%esp
  801678:	6a 00                	push   $0x0
  80167a:	53                   	push   %ebx
  80167b:	6a 00                	push   $0x0
  80167d:	e8 02 0c 00 00       	call   802284 <ipc_recv>
}
  801682:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801685:	5b                   	pop    %ebx
  801686:	5e                   	pop    %esi
  801687:	5d                   	pop    %ebp
  801688:	c3                   	ret    

00801689 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801689:	55                   	push   %ebp
  80168a:	89 e5                	mov    %esp,%ebp
  80168c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80168f:	8b 45 08             	mov    0x8(%ebp),%eax
  801692:	8b 40 0c             	mov    0xc(%eax),%eax
  801695:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80169a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80169d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a7:	b8 02 00 00 00       	mov    $0x2,%eax
  8016ac:	e8 8d ff ff ff       	call   80163e <fsipc>
}
  8016b1:	c9                   	leave  
  8016b2:	c3                   	ret    

008016b3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016b3:	55                   	push   %ebp
  8016b4:	89 e5                	mov    %esp,%ebp
  8016b6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8016bf:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c9:	b8 06 00 00 00       	mov    $0x6,%eax
  8016ce:	e8 6b ff ff ff       	call   80163e <fsipc>
}
  8016d3:	c9                   	leave  
  8016d4:	c3                   	ret    

008016d5 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	53                   	push   %ebx
  8016d9:	83 ec 04             	sub    $0x4,%esp
  8016dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016df:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ef:	b8 05 00 00 00       	mov    $0x5,%eax
  8016f4:	e8 45 ff ff ff       	call   80163e <fsipc>
  8016f9:	85 c0                	test   %eax,%eax
  8016fb:	78 2c                	js     801729 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016fd:	83 ec 08             	sub    $0x8,%esp
  801700:	68 00 50 80 00       	push   $0x805000
  801705:	53                   	push   %ebx
  801706:	e8 5d f0 ff ff       	call   800768 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80170b:	a1 80 50 80 00       	mov    0x805080,%eax
  801710:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801716:	a1 84 50 80 00       	mov    0x805084,%eax
  80171b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801721:	83 c4 10             	add    $0x10,%esp
  801724:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801729:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172c:	c9                   	leave  
  80172d:	c3                   	ret    

0080172e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	83 ec 0c             	sub    $0xc,%esp
  801734:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801737:	8b 55 08             	mov    0x8(%ebp),%edx
  80173a:	8b 52 0c             	mov    0xc(%edx),%edx
  80173d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801743:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801748:	50                   	push   %eax
  801749:	ff 75 0c             	pushl  0xc(%ebp)
  80174c:	68 08 50 80 00       	push   $0x805008
  801751:	e8 a4 f1 ff ff       	call   8008fa <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801756:	ba 00 00 00 00       	mov    $0x0,%edx
  80175b:	b8 04 00 00 00       	mov    $0x4,%eax
  801760:	e8 d9 fe ff ff       	call   80163e <fsipc>

}
  801765:	c9                   	leave  
  801766:	c3                   	ret    

00801767 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801767:	55                   	push   %ebp
  801768:	89 e5                	mov    %esp,%ebp
  80176a:	56                   	push   %esi
  80176b:	53                   	push   %ebx
  80176c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80176f:	8b 45 08             	mov    0x8(%ebp),%eax
  801772:	8b 40 0c             	mov    0xc(%eax),%eax
  801775:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80177a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801780:	ba 00 00 00 00       	mov    $0x0,%edx
  801785:	b8 03 00 00 00       	mov    $0x3,%eax
  80178a:	e8 af fe ff ff       	call   80163e <fsipc>
  80178f:	89 c3                	mov    %eax,%ebx
  801791:	85 c0                	test   %eax,%eax
  801793:	78 4b                	js     8017e0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801795:	39 c6                	cmp    %eax,%esi
  801797:	73 16                	jae    8017af <devfile_read+0x48>
  801799:	68 f4 2a 80 00       	push   $0x802af4
  80179e:	68 fb 2a 80 00       	push   $0x802afb
  8017a3:	6a 7c                	push   $0x7c
  8017a5:	68 10 2b 80 00       	push   $0x802b10
  8017aa:	e8 24 0a 00 00       	call   8021d3 <_panic>
	assert(r <= PGSIZE);
  8017af:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017b4:	7e 16                	jle    8017cc <devfile_read+0x65>
  8017b6:	68 1b 2b 80 00       	push   $0x802b1b
  8017bb:	68 fb 2a 80 00       	push   $0x802afb
  8017c0:	6a 7d                	push   $0x7d
  8017c2:	68 10 2b 80 00       	push   $0x802b10
  8017c7:	e8 07 0a 00 00       	call   8021d3 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017cc:	83 ec 04             	sub    $0x4,%esp
  8017cf:	50                   	push   %eax
  8017d0:	68 00 50 80 00       	push   $0x805000
  8017d5:	ff 75 0c             	pushl  0xc(%ebp)
  8017d8:	e8 1d f1 ff ff       	call   8008fa <memmove>
	return r;
  8017dd:	83 c4 10             	add    $0x10,%esp
}
  8017e0:	89 d8                	mov    %ebx,%eax
  8017e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e5:	5b                   	pop    %ebx
  8017e6:	5e                   	pop    %esi
  8017e7:	5d                   	pop    %ebp
  8017e8:	c3                   	ret    

008017e9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	53                   	push   %ebx
  8017ed:	83 ec 20             	sub    $0x20,%esp
  8017f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017f3:	53                   	push   %ebx
  8017f4:	e8 36 ef ff ff       	call   80072f <strlen>
  8017f9:	83 c4 10             	add    $0x10,%esp
  8017fc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801801:	7f 67                	jg     80186a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801803:	83 ec 0c             	sub    $0xc,%esp
  801806:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801809:	50                   	push   %eax
  80180a:	e8 a7 f8 ff ff       	call   8010b6 <fd_alloc>
  80180f:	83 c4 10             	add    $0x10,%esp
		return r;
  801812:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801814:	85 c0                	test   %eax,%eax
  801816:	78 57                	js     80186f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801818:	83 ec 08             	sub    $0x8,%esp
  80181b:	53                   	push   %ebx
  80181c:	68 00 50 80 00       	push   $0x805000
  801821:	e8 42 ef ff ff       	call   800768 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801826:	8b 45 0c             	mov    0xc(%ebp),%eax
  801829:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80182e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801831:	b8 01 00 00 00       	mov    $0x1,%eax
  801836:	e8 03 fe ff ff       	call   80163e <fsipc>
  80183b:	89 c3                	mov    %eax,%ebx
  80183d:	83 c4 10             	add    $0x10,%esp
  801840:	85 c0                	test   %eax,%eax
  801842:	79 14                	jns    801858 <open+0x6f>
		fd_close(fd, 0);
  801844:	83 ec 08             	sub    $0x8,%esp
  801847:	6a 00                	push   $0x0
  801849:	ff 75 f4             	pushl  -0xc(%ebp)
  80184c:	e8 5d f9 ff ff       	call   8011ae <fd_close>
		return r;
  801851:	83 c4 10             	add    $0x10,%esp
  801854:	89 da                	mov    %ebx,%edx
  801856:	eb 17                	jmp    80186f <open+0x86>
	}

	return fd2num(fd);
  801858:	83 ec 0c             	sub    $0xc,%esp
  80185b:	ff 75 f4             	pushl  -0xc(%ebp)
  80185e:	e8 2c f8 ff ff       	call   80108f <fd2num>
  801863:	89 c2                	mov    %eax,%edx
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	eb 05                	jmp    80186f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80186a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80186f:	89 d0                	mov    %edx,%eax
  801871:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801874:	c9                   	leave  
  801875:	c3                   	ret    

00801876 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801876:	55                   	push   %ebp
  801877:	89 e5                	mov    %esp,%ebp
  801879:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80187c:	ba 00 00 00 00       	mov    $0x0,%edx
  801881:	b8 08 00 00 00       	mov    $0x8,%eax
  801886:	e8 b3 fd ff ff       	call   80163e <fsipc>
}
  80188b:	c9                   	leave  
  80188c:	c3                   	ret    

0080188d <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80188d:	55                   	push   %ebp
  80188e:	89 e5                	mov    %esp,%ebp
  801890:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801893:	68 27 2b 80 00       	push   $0x802b27
  801898:	ff 75 0c             	pushl  0xc(%ebp)
  80189b:	e8 c8 ee ff ff       	call   800768 <strcpy>
	return 0;
}
  8018a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a5:	c9                   	leave  
  8018a6:	c3                   	ret    

008018a7 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	53                   	push   %ebx
  8018ab:	83 ec 10             	sub    $0x10,%esp
  8018ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8018b1:	53                   	push   %ebx
  8018b2:	e8 c1 0a 00 00       	call   802378 <pageref>
  8018b7:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8018ba:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8018bf:	83 f8 01             	cmp    $0x1,%eax
  8018c2:	75 10                	jne    8018d4 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8018c4:	83 ec 0c             	sub    $0xc,%esp
  8018c7:	ff 73 0c             	pushl  0xc(%ebx)
  8018ca:	e8 c0 02 00 00       	call   801b8f <nsipc_close>
  8018cf:	89 c2                	mov    %eax,%edx
  8018d1:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8018d4:	89 d0                	mov    %edx,%eax
  8018d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d9:	c9                   	leave  
  8018da:	c3                   	ret    

008018db <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8018e1:	6a 00                	push   $0x0
  8018e3:	ff 75 10             	pushl  0x10(%ebp)
  8018e6:	ff 75 0c             	pushl  0xc(%ebp)
  8018e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ec:	ff 70 0c             	pushl  0xc(%eax)
  8018ef:	e8 78 03 00 00       	call   801c6c <nsipc_send>
}
  8018f4:	c9                   	leave  
  8018f5:	c3                   	ret    

008018f6 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8018f6:	55                   	push   %ebp
  8018f7:	89 e5                	mov    %esp,%ebp
  8018f9:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8018fc:	6a 00                	push   $0x0
  8018fe:	ff 75 10             	pushl  0x10(%ebp)
  801901:	ff 75 0c             	pushl  0xc(%ebp)
  801904:	8b 45 08             	mov    0x8(%ebp),%eax
  801907:	ff 70 0c             	pushl  0xc(%eax)
  80190a:	e8 f1 02 00 00       	call   801c00 <nsipc_recv>
}
  80190f:	c9                   	leave  
  801910:	c3                   	ret    

00801911 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801917:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80191a:	52                   	push   %edx
  80191b:	50                   	push   %eax
  80191c:	e8 e4 f7 ff ff       	call   801105 <fd_lookup>
  801921:	83 c4 10             	add    $0x10,%esp
  801924:	85 c0                	test   %eax,%eax
  801926:	78 17                	js     80193f <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801928:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80192b:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801931:	39 08                	cmp    %ecx,(%eax)
  801933:	75 05                	jne    80193a <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801935:	8b 40 0c             	mov    0xc(%eax),%eax
  801938:	eb 05                	jmp    80193f <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80193a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80193f:	c9                   	leave  
  801940:	c3                   	ret    

00801941 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	56                   	push   %esi
  801945:	53                   	push   %ebx
  801946:	83 ec 1c             	sub    $0x1c,%esp
  801949:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80194b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80194e:	50                   	push   %eax
  80194f:	e8 62 f7 ff ff       	call   8010b6 <fd_alloc>
  801954:	89 c3                	mov    %eax,%ebx
  801956:	83 c4 10             	add    $0x10,%esp
  801959:	85 c0                	test   %eax,%eax
  80195b:	78 1b                	js     801978 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80195d:	83 ec 04             	sub    $0x4,%esp
  801960:	68 07 04 00 00       	push   $0x407
  801965:	ff 75 f4             	pushl  -0xc(%ebp)
  801968:	6a 00                	push   $0x0
  80196a:	e8 fc f1 ff ff       	call   800b6b <sys_page_alloc>
  80196f:	89 c3                	mov    %eax,%ebx
  801971:	83 c4 10             	add    $0x10,%esp
  801974:	85 c0                	test   %eax,%eax
  801976:	79 10                	jns    801988 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801978:	83 ec 0c             	sub    $0xc,%esp
  80197b:	56                   	push   %esi
  80197c:	e8 0e 02 00 00       	call   801b8f <nsipc_close>
		return r;
  801981:	83 c4 10             	add    $0x10,%esp
  801984:	89 d8                	mov    %ebx,%eax
  801986:	eb 24                	jmp    8019ac <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801988:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80198e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801991:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801993:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801996:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80199d:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8019a0:	83 ec 0c             	sub    $0xc,%esp
  8019a3:	50                   	push   %eax
  8019a4:	e8 e6 f6 ff ff       	call   80108f <fd2num>
  8019a9:	83 c4 10             	add    $0x10,%esp
}
  8019ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019af:	5b                   	pop    %ebx
  8019b0:	5e                   	pop    %esi
  8019b1:	5d                   	pop    %ebp
  8019b2:	c3                   	ret    

008019b3 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8019b3:	55                   	push   %ebp
  8019b4:	89 e5                	mov    %esp,%ebp
  8019b6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bc:	e8 50 ff ff ff       	call   801911 <fd2sockid>
		return r;
  8019c1:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019c3:	85 c0                	test   %eax,%eax
  8019c5:	78 1f                	js     8019e6 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019c7:	83 ec 04             	sub    $0x4,%esp
  8019ca:	ff 75 10             	pushl  0x10(%ebp)
  8019cd:	ff 75 0c             	pushl  0xc(%ebp)
  8019d0:	50                   	push   %eax
  8019d1:	e8 12 01 00 00       	call   801ae8 <nsipc_accept>
  8019d6:	83 c4 10             	add    $0x10,%esp
		return r;
  8019d9:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019db:	85 c0                	test   %eax,%eax
  8019dd:	78 07                	js     8019e6 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8019df:	e8 5d ff ff ff       	call   801941 <alloc_sockfd>
  8019e4:	89 c1                	mov    %eax,%ecx
}
  8019e6:	89 c8                	mov    %ecx,%eax
  8019e8:	c9                   	leave  
  8019e9:	c3                   	ret    

008019ea <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8019ea:	55                   	push   %ebp
  8019eb:	89 e5                	mov    %esp,%ebp
  8019ed:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f3:	e8 19 ff ff ff       	call   801911 <fd2sockid>
  8019f8:	85 c0                	test   %eax,%eax
  8019fa:	78 12                	js     801a0e <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8019fc:	83 ec 04             	sub    $0x4,%esp
  8019ff:	ff 75 10             	pushl  0x10(%ebp)
  801a02:	ff 75 0c             	pushl  0xc(%ebp)
  801a05:	50                   	push   %eax
  801a06:	e8 2d 01 00 00       	call   801b38 <nsipc_bind>
  801a0b:	83 c4 10             	add    $0x10,%esp
}
  801a0e:	c9                   	leave  
  801a0f:	c3                   	ret    

00801a10 <shutdown>:

int
shutdown(int s, int how)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a16:	8b 45 08             	mov    0x8(%ebp),%eax
  801a19:	e8 f3 fe ff ff       	call   801911 <fd2sockid>
  801a1e:	85 c0                	test   %eax,%eax
  801a20:	78 0f                	js     801a31 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801a22:	83 ec 08             	sub    $0x8,%esp
  801a25:	ff 75 0c             	pushl  0xc(%ebp)
  801a28:	50                   	push   %eax
  801a29:	e8 3f 01 00 00       	call   801b6d <nsipc_shutdown>
  801a2e:	83 c4 10             	add    $0x10,%esp
}
  801a31:	c9                   	leave  
  801a32:	c3                   	ret    

00801a33 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a39:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3c:	e8 d0 fe ff ff       	call   801911 <fd2sockid>
  801a41:	85 c0                	test   %eax,%eax
  801a43:	78 12                	js     801a57 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801a45:	83 ec 04             	sub    $0x4,%esp
  801a48:	ff 75 10             	pushl  0x10(%ebp)
  801a4b:	ff 75 0c             	pushl  0xc(%ebp)
  801a4e:	50                   	push   %eax
  801a4f:	e8 55 01 00 00       	call   801ba9 <nsipc_connect>
  801a54:	83 c4 10             	add    $0x10,%esp
}
  801a57:	c9                   	leave  
  801a58:	c3                   	ret    

00801a59 <listen>:

int
listen(int s, int backlog)
{
  801a59:	55                   	push   %ebp
  801a5a:	89 e5                	mov    %esp,%ebp
  801a5c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a62:	e8 aa fe ff ff       	call   801911 <fd2sockid>
  801a67:	85 c0                	test   %eax,%eax
  801a69:	78 0f                	js     801a7a <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801a6b:	83 ec 08             	sub    $0x8,%esp
  801a6e:	ff 75 0c             	pushl  0xc(%ebp)
  801a71:	50                   	push   %eax
  801a72:	e8 67 01 00 00       	call   801bde <nsipc_listen>
  801a77:	83 c4 10             	add    $0x10,%esp
}
  801a7a:	c9                   	leave  
  801a7b:	c3                   	ret    

00801a7c <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801a7c:	55                   	push   %ebp
  801a7d:	89 e5                	mov    %esp,%ebp
  801a7f:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a82:	ff 75 10             	pushl  0x10(%ebp)
  801a85:	ff 75 0c             	pushl  0xc(%ebp)
  801a88:	ff 75 08             	pushl  0x8(%ebp)
  801a8b:	e8 3a 02 00 00       	call   801cca <nsipc_socket>
  801a90:	83 c4 10             	add    $0x10,%esp
  801a93:	85 c0                	test   %eax,%eax
  801a95:	78 05                	js     801a9c <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801a97:	e8 a5 fe ff ff       	call   801941 <alloc_sockfd>
}
  801a9c:	c9                   	leave  
  801a9d:	c3                   	ret    

00801a9e <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a9e:	55                   	push   %ebp
  801a9f:	89 e5                	mov    %esp,%ebp
  801aa1:	53                   	push   %ebx
  801aa2:	83 ec 04             	sub    $0x4,%esp
  801aa5:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801aa7:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801aae:	75 12                	jne    801ac2 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801ab0:	83 ec 0c             	sub    $0xc,%esp
  801ab3:	6a 02                	push   $0x2
  801ab5:	e8 85 08 00 00       	call   80233f <ipc_find_env>
  801aba:	a3 04 40 80 00       	mov    %eax,0x804004
  801abf:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ac2:	6a 07                	push   $0x7
  801ac4:	68 00 60 80 00       	push   $0x806000
  801ac9:	53                   	push   %ebx
  801aca:	ff 35 04 40 80 00    	pushl  0x804004
  801ad0:	e8 16 08 00 00       	call   8022eb <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ad5:	83 c4 0c             	add    $0xc,%esp
  801ad8:	6a 00                	push   $0x0
  801ada:	6a 00                	push   $0x0
  801adc:	6a 00                	push   $0x0
  801ade:	e8 a1 07 00 00       	call   802284 <ipc_recv>
}
  801ae3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ae6:	c9                   	leave  
  801ae7:	c3                   	ret    

00801ae8 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ae8:	55                   	push   %ebp
  801ae9:	89 e5                	mov    %esp,%ebp
  801aeb:	56                   	push   %esi
  801aec:	53                   	push   %ebx
  801aed:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801af0:	8b 45 08             	mov    0x8(%ebp),%eax
  801af3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801af8:	8b 06                	mov    (%esi),%eax
  801afa:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801aff:	b8 01 00 00 00       	mov    $0x1,%eax
  801b04:	e8 95 ff ff ff       	call   801a9e <nsipc>
  801b09:	89 c3                	mov    %eax,%ebx
  801b0b:	85 c0                	test   %eax,%eax
  801b0d:	78 20                	js     801b2f <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801b0f:	83 ec 04             	sub    $0x4,%esp
  801b12:	ff 35 10 60 80 00    	pushl  0x806010
  801b18:	68 00 60 80 00       	push   $0x806000
  801b1d:	ff 75 0c             	pushl  0xc(%ebp)
  801b20:	e8 d5 ed ff ff       	call   8008fa <memmove>
		*addrlen = ret->ret_addrlen;
  801b25:	a1 10 60 80 00       	mov    0x806010,%eax
  801b2a:	89 06                	mov    %eax,(%esi)
  801b2c:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801b2f:	89 d8                	mov    %ebx,%eax
  801b31:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b34:	5b                   	pop    %ebx
  801b35:	5e                   	pop    %esi
  801b36:	5d                   	pop    %ebp
  801b37:	c3                   	ret    

00801b38 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	53                   	push   %ebx
  801b3c:	83 ec 08             	sub    $0x8,%esp
  801b3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801b42:	8b 45 08             	mov    0x8(%ebp),%eax
  801b45:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b4a:	53                   	push   %ebx
  801b4b:	ff 75 0c             	pushl  0xc(%ebp)
  801b4e:	68 04 60 80 00       	push   $0x806004
  801b53:	e8 a2 ed ff ff       	call   8008fa <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b58:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801b5e:	b8 02 00 00 00       	mov    $0x2,%eax
  801b63:	e8 36 ff ff ff       	call   801a9e <nsipc>
}
  801b68:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b6b:	c9                   	leave  
  801b6c:	c3                   	ret    

00801b6d <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b6d:	55                   	push   %ebp
  801b6e:	89 e5                	mov    %esp,%ebp
  801b70:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b73:	8b 45 08             	mov    0x8(%ebp),%eax
  801b76:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801b7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b7e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801b83:	b8 03 00 00 00       	mov    $0x3,%eax
  801b88:	e8 11 ff ff ff       	call   801a9e <nsipc>
}
  801b8d:	c9                   	leave  
  801b8e:	c3                   	ret    

00801b8f <nsipc_close>:

int
nsipc_close(int s)
{
  801b8f:	55                   	push   %ebp
  801b90:	89 e5                	mov    %esp,%ebp
  801b92:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b95:	8b 45 08             	mov    0x8(%ebp),%eax
  801b98:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801b9d:	b8 04 00 00 00       	mov    $0x4,%eax
  801ba2:	e8 f7 fe ff ff       	call   801a9e <nsipc>
}
  801ba7:	c9                   	leave  
  801ba8:	c3                   	ret    

00801ba9 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ba9:	55                   	push   %ebp
  801baa:	89 e5                	mov    %esp,%ebp
  801bac:	53                   	push   %ebx
  801bad:	83 ec 08             	sub    $0x8,%esp
  801bb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801bb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb6:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801bbb:	53                   	push   %ebx
  801bbc:	ff 75 0c             	pushl  0xc(%ebp)
  801bbf:	68 04 60 80 00       	push   $0x806004
  801bc4:	e8 31 ed ff ff       	call   8008fa <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801bc9:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801bcf:	b8 05 00 00 00       	mov    $0x5,%eax
  801bd4:	e8 c5 fe ff ff       	call   801a9e <nsipc>
}
  801bd9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bdc:	c9                   	leave  
  801bdd:	c3                   	ret    

00801bde <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801bde:	55                   	push   %ebp
  801bdf:	89 e5                	mov    %esp,%ebp
  801be1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801be4:	8b 45 08             	mov    0x8(%ebp),%eax
  801be7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801bec:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bef:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801bf4:	b8 06 00 00 00       	mov    $0x6,%eax
  801bf9:	e8 a0 fe ff ff       	call   801a9e <nsipc>
}
  801bfe:	c9                   	leave  
  801bff:	c3                   	ret    

00801c00 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	56                   	push   %esi
  801c04:	53                   	push   %ebx
  801c05:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801c08:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801c10:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801c16:	8b 45 14             	mov    0x14(%ebp),%eax
  801c19:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801c1e:	b8 07 00 00 00       	mov    $0x7,%eax
  801c23:	e8 76 fe ff ff       	call   801a9e <nsipc>
  801c28:	89 c3                	mov    %eax,%ebx
  801c2a:	85 c0                	test   %eax,%eax
  801c2c:	78 35                	js     801c63 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801c2e:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801c33:	7f 04                	jg     801c39 <nsipc_recv+0x39>
  801c35:	39 c6                	cmp    %eax,%esi
  801c37:	7d 16                	jge    801c4f <nsipc_recv+0x4f>
  801c39:	68 33 2b 80 00       	push   $0x802b33
  801c3e:	68 fb 2a 80 00       	push   $0x802afb
  801c43:	6a 62                	push   $0x62
  801c45:	68 48 2b 80 00       	push   $0x802b48
  801c4a:	e8 84 05 00 00       	call   8021d3 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c4f:	83 ec 04             	sub    $0x4,%esp
  801c52:	50                   	push   %eax
  801c53:	68 00 60 80 00       	push   $0x806000
  801c58:	ff 75 0c             	pushl  0xc(%ebp)
  801c5b:	e8 9a ec ff ff       	call   8008fa <memmove>
  801c60:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c63:	89 d8                	mov    %ebx,%eax
  801c65:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c68:	5b                   	pop    %ebx
  801c69:	5e                   	pop    %esi
  801c6a:	5d                   	pop    %ebp
  801c6b:	c3                   	ret    

00801c6c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c6c:	55                   	push   %ebp
  801c6d:	89 e5                	mov    %esp,%ebp
  801c6f:	53                   	push   %ebx
  801c70:	83 ec 04             	sub    $0x4,%esp
  801c73:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c76:	8b 45 08             	mov    0x8(%ebp),%eax
  801c79:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801c7e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c84:	7e 16                	jle    801c9c <nsipc_send+0x30>
  801c86:	68 54 2b 80 00       	push   $0x802b54
  801c8b:	68 fb 2a 80 00       	push   $0x802afb
  801c90:	6a 6d                	push   $0x6d
  801c92:	68 48 2b 80 00       	push   $0x802b48
  801c97:	e8 37 05 00 00       	call   8021d3 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c9c:	83 ec 04             	sub    $0x4,%esp
  801c9f:	53                   	push   %ebx
  801ca0:	ff 75 0c             	pushl  0xc(%ebp)
  801ca3:	68 0c 60 80 00       	push   $0x80600c
  801ca8:	e8 4d ec ff ff       	call   8008fa <memmove>
	nsipcbuf.send.req_size = size;
  801cad:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801cb3:	8b 45 14             	mov    0x14(%ebp),%eax
  801cb6:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801cbb:	b8 08 00 00 00       	mov    $0x8,%eax
  801cc0:	e8 d9 fd ff ff       	call   801a9e <nsipc>
}
  801cc5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cc8:	c9                   	leave  
  801cc9:	c3                   	ret    

00801cca <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801cca:	55                   	push   %ebp
  801ccb:	89 e5                	mov    %esp,%ebp
  801ccd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801cd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cdb:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801ce0:	8b 45 10             	mov    0x10(%ebp),%eax
  801ce3:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ce8:	b8 09 00 00 00       	mov    $0x9,%eax
  801ced:	e8 ac fd ff ff       	call   801a9e <nsipc>
}
  801cf2:	c9                   	leave  
  801cf3:	c3                   	ret    

00801cf4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801cf4:	55                   	push   %ebp
  801cf5:	89 e5                	mov    %esp,%ebp
  801cf7:	56                   	push   %esi
  801cf8:	53                   	push   %ebx
  801cf9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801cfc:	83 ec 0c             	sub    $0xc,%esp
  801cff:	ff 75 08             	pushl  0x8(%ebp)
  801d02:	e8 98 f3 ff ff       	call   80109f <fd2data>
  801d07:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d09:	83 c4 08             	add    $0x8,%esp
  801d0c:	68 60 2b 80 00       	push   $0x802b60
  801d11:	53                   	push   %ebx
  801d12:	e8 51 ea ff ff       	call   800768 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d17:	8b 46 04             	mov    0x4(%esi),%eax
  801d1a:	2b 06                	sub    (%esi),%eax
  801d1c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d22:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d29:	00 00 00 
	stat->st_dev = &devpipe;
  801d2c:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801d33:	30 80 00 
	return 0;
}
  801d36:	b8 00 00 00 00       	mov    $0x0,%eax
  801d3b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d3e:	5b                   	pop    %ebx
  801d3f:	5e                   	pop    %esi
  801d40:	5d                   	pop    %ebp
  801d41:	c3                   	ret    

00801d42 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d42:	55                   	push   %ebp
  801d43:	89 e5                	mov    %esp,%ebp
  801d45:	53                   	push   %ebx
  801d46:	83 ec 0c             	sub    $0xc,%esp
  801d49:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d4c:	53                   	push   %ebx
  801d4d:	6a 00                	push   $0x0
  801d4f:	e8 9c ee ff ff       	call   800bf0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d54:	89 1c 24             	mov    %ebx,(%esp)
  801d57:	e8 43 f3 ff ff       	call   80109f <fd2data>
  801d5c:	83 c4 08             	add    $0x8,%esp
  801d5f:	50                   	push   %eax
  801d60:	6a 00                	push   $0x0
  801d62:	e8 89 ee ff ff       	call   800bf0 <sys_page_unmap>
}
  801d67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d6a:	c9                   	leave  
  801d6b:	c3                   	ret    

00801d6c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
  801d6f:	57                   	push   %edi
  801d70:	56                   	push   %esi
  801d71:	53                   	push   %ebx
  801d72:	83 ec 1c             	sub    $0x1c,%esp
  801d75:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d78:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d7a:	a1 08 40 80 00       	mov    0x804008,%eax
  801d7f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d82:	83 ec 0c             	sub    $0xc,%esp
  801d85:	ff 75 e0             	pushl  -0x20(%ebp)
  801d88:	e8 eb 05 00 00       	call   802378 <pageref>
  801d8d:	89 c3                	mov    %eax,%ebx
  801d8f:	89 3c 24             	mov    %edi,(%esp)
  801d92:	e8 e1 05 00 00       	call   802378 <pageref>
  801d97:	83 c4 10             	add    $0x10,%esp
  801d9a:	39 c3                	cmp    %eax,%ebx
  801d9c:	0f 94 c1             	sete   %cl
  801d9f:	0f b6 c9             	movzbl %cl,%ecx
  801da2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801da5:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801dab:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801dae:	39 ce                	cmp    %ecx,%esi
  801db0:	74 1b                	je     801dcd <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801db2:	39 c3                	cmp    %eax,%ebx
  801db4:	75 c4                	jne    801d7a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801db6:	8b 42 58             	mov    0x58(%edx),%eax
  801db9:	ff 75 e4             	pushl  -0x1c(%ebp)
  801dbc:	50                   	push   %eax
  801dbd:	56                   	push   %esi
  801dbe:	68 67 2b 80 00       	push   $0x802b67
  801dc3:	e8 1b e4 ff ff       	call   8001e3 <cprintf>
  801dc8:	83 c4 10             	add    $0x10,%esp
  801dcb:	eb ad                	jmp    801d7a <_pipeisclosed+0xe>
	}
}
  801dcd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dd3:	5b                   	pop    %ebx
  801dd4:	5e                   	pop    %esi
  801dd5:	5f                   	pop    %edi
  801dd6:	5d                   	pop    %ebp
  801dd7:	c3                   	ret    

00801dd8 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dd8:	55                   	push   %ebp
  801dd9:	89 e5                	mov    %esp,%ebp
  801ddb:	57                   	push   %edi
  801ddc:	56                   	push   %esi
  801ddd:	53                   	push   %ebx
  801dde:	83 ec 28             	sub    $0x28,%esp
  801de1:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801de4:	56                   	push   %esi
  801de5:	e8 b5 f2 ff ff       	call   80109f <fd2data>
  801dea:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dec:	83 c4 10             	add    $0x10,%esp
  801def:	bf 00 00 00 00       	mov    $0x0,%edi
  801df4:	eb 4b                	jmp    801e41 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801df6:	89 da                	mov    %ebx,%edx
  801df8:	89 f0                	mov    %esi,%eax
  801dfa:	e8 6d ff ff ff       	call   801d6c <_pipeisclosed>
  801dff:	85 c0                	test   %eax,%eax
  801e01:	75 48                	jne    801e4b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e03:	e8 44 ed ff ff       	call   800b4c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e08:	8b 43 04             	mov    0x4(%ebx),%eax
  801e0b:	8b 0b                	mov    (%ebx),%ecx
  801e0d:	8d 51 20             	lea    0x20(%ecx),%edx
  801e10:	39 d0                	cmp    %edx,%eax
  801e12:	73 e2                	jae    801df6 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e17:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e1b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e1e:	89 c2                	mov    %eax,%edx
  801e20:	c1 fa 1f             	sar    $0x1f,%edx
  801e23:	89 d1                	mov    %edx,%ecx
  801e25:	c1 e9 1b             	shr    $0x1b,%ecx
  801e28:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e2b:	83 e2 1f             	and    $0x1f,%edx
  801e2e:	29 ca                	sub    %ecx,%edx
  801e30:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e34:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e38:	83 c0 01             	add    $0x1,%eax
  801e3b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e3e:	83 c7 01             	add    $0x1,%edi
  801e41:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e44:	75 c2                	jne    801e08 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e46:	8b 45 10             	mov    0x10(%ebp),%eax
  801e49:	eb 05                	jmp    801e50 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e4b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e53:	5b                   	pop    %ebx
  801e54:	5e                   	pop    %esi
  801e55:	5f                   	pop    %edi
  801e56:	5d                   	pop    %ebp
  801e57:	c3                   	ret    

00801e58 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e58:	55                   	push   %ebp
  801e59:	89 e5                	mov    %esp,%ebp
  801e5b:	57                   	push   %edi
  801e5c:	56                   	push   %esi
  801e5d:	53                   	push   %ebx
  801e5e:	83 ec 18             	sub    $0x18,%esp
  801e61:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e64:	57                   	push   %edi
  801e65:	e8 35 f2 ff ff       	call   80109f <fd2data>
  801e6a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e6c:	83 c4 10             	add    $0x10,%esp
  801e6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e74:	eb 3d                	jmp    801eb3 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e76:	85 db                	test   %ebx,%ebx
  801e78:	74 04                	je     801e7e <devpipe_read+0x26>
				return i;
  801e7a:	89 d8                	mov    %ebx,%eax
  801e7c:	eb 44                	jmp    801ec2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e7e:	89 f2                	mov    %esi,%edx
  801e80:	89 f8                	mov    %edi,%eax
  801e82:	e8 e5 fe ff ff       	call   801d6c <_pipeisclosed>
  801e87:	85 c0                	test   %eax,%eax
  801e89:	75 32                	jne    801ebd <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e8b:	e8 bc ec ff ff       	call   800b4c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e90:	8b 06                	mov    (%esi),%eax
  801e92:	3b 46 04             	cmp    0x4(%esi),%eax
  801e95:	74 df                	je     801e76 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e97:	99                   	cltd   
  801e98:	c1 ea 1b             	shr    $0x1b,%edx
  801e9b:	01 d0                	add    %edx,%eax
  801e9d:	83 e0 1f             	and    $0x1f,%eax
  801ea0:	29 d0                	sub    %edx,%eax
  801ea2:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ea7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801eaa:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ead:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eb0:	83 c3 01             	add    $0x1,%ebx
  801eb3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801eb6:	75 d8                	jne    801e90 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801eb8:	8b 45 10             	mov    0x10(%ebp),%eax
  801ebb:	eb 05                	jmp    801ec2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ebd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ec2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ec5:	5b                   	pop    %ebx
  801ec6:	5e                   	pop    %esi
  801ec7:	5f                   	pop    %edi
  801ec8:	5d                   	pop    %ebp
  801ec9:	c3                   	ret    

00801eca <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801eca:	55                   	push   %ebp
  801ecb:	89 e5                	mov    %esp,%ebp
  801ecd:	56                   	push   %esi
  801ece:	53                   	push   %ebx
  801ecf:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ed2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed5:	50                   	push   %eax
  801ed6:	e8 db f1 ff ff       	call   8010b6 <fd_alloc>
  801edb:	83 c4 10             	add    $0x10,%esp
  801ede:	89 c2                	mov    %eax,%edx
  801ee0:	85 c0                	test   %eax,%eax
  801ee2:	0f 88 2c 01 00 00    	js     802014 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ee8:	83 ec 04             	sub    $0x4,%esp
  801eeb:	68 07 04 00 00       	push   $0x407
  801ef0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ef3:	6a 00                	push   $0x0
  801ef5:	e8 71 ec ff ff       	call   800b6b <sys_page_alloc>
  801efa:	83 c4 10             	add    $0x10,%esp
  801efd:	89 c2                	mov    %eax,%edx
  801eff:	85 c0                	test   %eax,%eax
  801f01:	0f 88 0d 01 00 00    	js     802014 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f07:	83 ec 0c             	sub    $0xc,%esp
  801f0a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f0d:	50                   	push   %eax
  801f0e:	e8 a3 f1 ff ff       	call   8010b6 <fd_alloc>
  801f13:	89 c3                	mov    %eax,%ebx
  801f15:	83 c4 10             	add    $0x10,%esp
  801f18:	85 c0                	test   %eax,%eax
  801f1a:	0f 88 e2 00 00 00    	js     802002 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f20:	83 ec 04             	sub    $0x4,%esp
  801f23:	68 07 04 00 00       	push   $0x407
  801f28:	ff 75 f0             	pushl  -0x10(%ebp)
  801f2b:	6a 00                	push   $0x0
  801f2d:	e8 39 ec ff ff       	call   800b6b <sys_page_alloc>
  801f32:	89 c3                	mov    %eax,%ebx
  801f34:	83 c4 10             	add    $0x10,%esp
  801f37:	85 c0                	test   %eax,%eax
  801f39:	0f 88 c3 00 00 00    	js     802002 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f3f:	83 ec 0c             	sub    $0xc,%esp
  801f42:	ff 75 f4             	pushl  -0xc(%ebp)
  801f45:	e8 55 f1 ff ff       	call   80109f <fd2data>
  801f4a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f4c:	83 c4 0c             	add    $0xc,%esp
  801f4f:	68 07 04 00 00       	push   $0x407
  801f54:	50                   	push   %eax
  801f55:	6a 00                	push   $0x0
  801f57:	e8 0f ec ff ff       	call   800b6b <sys_page_alloc>
  801f5c:	89 c3                	mov    %eax,%ebx
  801f5e:	83 c4 10             	add    $0x10,%esp
  801f61:	85 c0                	test   %eax,%eax
  801f63:	0f 88 89 00 00 00    	js     801ff2 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f69:	83 ec 0c             	sub    $0xc,%esp
  801f6c:	ff 75 f0             	pushl  -0x10(%ebp)
  801f6f:	e8 2b f1 ff ff       	call   80109f <fd2data>
  801f74:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f7b:	50                   	push   %eax
  801f7c:	6a 00                	push   $0x0
  801f7e:	56                   	push   %esi
  801f7f:	6a 00                	push   $0x0
  801f81:	e8 28 ec ff ff       	call   800bae <sys_page_map>
  801f86:	89 c3                	mov    %eax,%ebx
  801f88:	83 c4 20             	add    $0x20,%esp
  801f8b:	85 c0                	test   %eax,%eax
  801f8d:	78 55                	js     801fe4 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f8f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f98:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f9d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801fa4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801faa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fad:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801faf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fb2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801fb9:	83 ec 0c             	sub    $0xc,%esp
  801fbc:	ff 75 f4             	pushl  -0xc(%ebp)
  801fbf:	e8 cb f0 ff ff       	call   80108f <fd2num>
  801fc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fc7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801fc9:	83 c4 04             	add    $0x4,%esp
  801fcc:	ff 75 f0             	pushl  -0x10(%ebp)
  801fcf:	e8 bb f0 ff ff       	call   80108f <fd2num>
  801fd4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fd7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801fda:	83 c4 10             	add    $0x10,%esp
  801fdd:	ba 00 00 00 00       	mov    $0x0,%edx
  801fe2:	eb 30                	jmp    802014 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801fe4:	83 ec 08             	sub    $0x8,%esp
  801fe7:	56                   	push   %esi
  801fe8:	6a 00                	push   $0x0
  801fea:	e8 01 ec ff ff       	call   800bf0 <sys_page_unmap>
  801fef:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ff2:	83 ec 08             	sub    $0x8,%esp
  801ff5:	ff 75 f0             	pushl  -0x10(%ebp)
  801ff8:	6a 00                	push   $0x0
  801ffa:	e8 f1 eb ff ff       	call   800bf0 <sys_page_unmap>
  801fff:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802002:	83 ec 08             	sub    $0x8,%esp
  802005:	ff 75 f4             	pushl  -0xc(%ebp)
  802008:	6a 00                	push   $0x0
  80200a:	e8 e1 eb ff ff       	call   800bf0 <sys_page_unmap>
  80200f:	83 c4 10             	add    $0x10,%esp
  802012:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802014:	89 d0                	mov    %edx,%eax
  802016:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802019:	5b                   	pop    %ebx
  80201a:	5e                   	pop    %esi
  80201b:	5d                   	pop    %ebp
  80201c:	c3                   	ret    

0080201d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80201d:	55                   	push   %ebp
  80201e:	89 e5                	mov    %esp,%ebp
  802020:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802023:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802026:	50                   	push   %eax
  802027:	ff 75 08             	pushl  0x8(%ebp)
  80202a:	e8 d6 f0 ff ff       	call   801105 <fd_lookup>
  80202f:	83 c4 10             	add    $0x10,%esp
  802032:	85 c0                	test   %eax,%eax
  802034:	78 18                	js     80204e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802036:	83 ec 0c             	sub    $0xc,%esp
  802039:	ff 75 f4             	pushl  -0xc(%ebp)
  80203c:	e8 5e f0 ff ff       	call   80109f <fd2data>
	return _pipeisclosed(fd, p);
  802041:	89 c2                	mov    %eax,%edx
  802043:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802046:	e8 21 fd ff ff       	call   801d6c <_pipeisclosed>
  80204b:	83 c4 10             	add    $0x10,%esp
}
  80204e:	c9                   	leave  
  80204f:	c3                   	ret    

00802050 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802050:	55                   	push   %ebp
  802051:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802053:	b8 00 00 00 00       	mov    $0x0,%eax
  802058:	5d                   	pop    %ebp
  802059:	c3                   	ret    

0080205a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80205a:	55                   	push   %ebp
  80205b:	89 e5                	mov    %esp,%ebp
  80205d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802060:	68 7f 2b 80 00       	push   $0x802b7f
  802065:	ff 75 0c             	pushl  0xc(%ebp)
  802068:	e8 fb e6 ff ff       	call   800768 <strcpy>
	return 0;
}
  80206d:	b8 00 00 00 00       	mov    $0x0,%eax
  802072:	c9                   	leave  
  802073:	c3                   	ret    

00802074 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802074:	55                   	push   %ebp
  802075:	89 e5                	mov    %esp,%ebp
  802077:	57                   	push   %edi
  802078:	56                   	push   %esi
  802079:	53                   	push   %ebx
  80207a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802080:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802085:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80208b:	eb 2d                	jmp    8020ba <devcons_write+0x46>
		m = n - tot;
  80208d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802090:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802092:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802095:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80209a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80209d:	83 ec 04             	sub    $0x4,%esp
  8020a0:	53                   	push   %ebx
  8020a1:	03 45 0c             	add    0xc(%ebp),%eax
  8020a4:	50                   	push   %eax
  8020a5:	57                   	push   %edi
  8020a6:	e8 4f e8 ff ff       	call   8008fa <memmove>
		sys_cputs(buf, m);
  8020ab:	83 c4 08             	add    $0x8,%esp
  8020ae:	53                   	push   %ebx
  8020af:	57                   	push   %edi
  8020b0:	e8 fa e9 ff ff       	call   800aaf <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020b5:	01 de                	add    %ebx,%esi
  8020b7:	83 c4 10             	add    $0x10,%esp
  8020ba:	89 f0                	mov    %esi,%eax
  8020bc:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020bf:	72 cc                	jb     80208d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020c4:	5b                   	pop    %ebx
  8020c5:	5e                   	pop    %esi
  8020c6:	5f                   	pop    %edi
  8020c7:	5d                   	pop    %ebp
  8020c8:	c3                   	ret    

008020c9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020c9:	55                   	push   %ebp
  8020ca:	89 e5                	mov    %esp,%ebp
  8020cc:	83 ec 08             	sub    $0x8,%esp
  8020cf:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8020d4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020d8:	74 2a                	je     802104 <devcons_read+0x3b>
  8020da:	eb 05                	jmp    8020e1 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8020dc:	e8 6b ea ff ff       	call   800b4c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8020e1:	e8 e7 e9 ff ff       	call   800acd <sys_cgetc>
  8020e6:	85 c0                	test   %eax,%eax
  8020e8:	74 f2                	je     8020dc <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8020ea:	85 c0                	test   %eax,%eax
  8020ec:	78 16                	js     802104 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8020ee:	83 f8 04             	cmp    $0x4,%eax
  8020f1:	74 0c                	je     8020ff <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8020f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020f6:	88 02                	mov    %al,(%edx)
	return 1;
  8020f8:	b8 01 00 00 00       	mov    $0x1,%eax
  8020fd:	eb 05                	jmp    802104 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020ff:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802104:	c9                   	leave  
  802105:	c3                   	ret    

00802106 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802106:	55                   	push   %ebp
  802107:	89 e5                	mov    %esp,%ebp
  802109:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80210c:	8b 45 08             	mov    0x8(%ebp),%eax
  80210f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802112:	6a 01                	push   $0x1
  802114:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802117:	50                   	push   %eax
  802118:	e8 92 e9 ff ff       	call   800aaf <sys_cputs>
}
  80211d:	83 c4 10             	add    $0x10,%esp
  802120:	c9                   	leave  
  802121:	c3                   	ret    

00802122 <getchar>:

int
getchar(void)
{
  802122:	55                   	push   %ebp
  802123:	89 e5                	mov    %esp,%ebp
  802125:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802128:	6a 01                	push   $0x1
  80212a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80212d:	50                   	push   %eax
  80212e:	6a 00                	push   $0x0
  802130:	e8 36 f2 ff ff       	call   80136b <read>
	if (r < 0)
  802135:	83 c4 10             	add    $0x10,%esp
  802138:	85 c0                	test   %eax,%eax
  80213a:	78 0f                	js     80214b <getchar+0x29>
		return r;
	if (r < 1)
  80213c:	85 c0                	test   %eax,%eax
  80213e:	7e 06                	jle    802146 <getchar+0x24>
		return -E_EOF;
	return c;
  802140:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802144:	eb 05                	jmp    80214b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802146:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80214b:	c9                   	leave  
  80214c:	c3                   	ret    

0080214d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80214d:	55                   	push   %ebp
  80214e:	89 e5                	mov    %esp,%ebp
  802150:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802153:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802156:	50                   	push   %eax
  802157:	ff 75 08             	pushl  0x8(%ebp)
  80215a:	e8 a6 ef ff ff       	call   801105 <fd_lookup>
  80215f:	83 c4 10             	add    $0x10,%esp
  802162:	85 c0                	test   %eax,%eax
  802164:	78 11                	js     802177 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802166:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802169:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80216f:	39 10                	cmp    %edx,(%eax)
  802171:	0f 94 c0             	sete   %al
  802174:	0f b6 c0             	movzbl %al,%eax
}
  802177:	c9                   	leave  
  802178:	c3                   	ret    

00802179 <opencons>:

int
opencons(void)
{
  802179:	55                   	push   %ebp
  80217a:	89 e5                	mov    %esp,%ebp
  80217c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80217f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802182:	50                   	push   %eax
  802183:	e8 2e ef ff ff       	call   8010b6 <fd_alloc>
  802188:	83 c4 10             	add    $0x10,%esp
		return r;
  80218b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80218d:	85 c0                	test   %eax,%eax
  80218f:	78 3e                	js     8021cf <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802191:	83 ec 04             	sub    $0x4,%esp
  802194:	68 07 04 00 00       	push   $0x407
  802199:	ff 75 f4             	pushl  -0xc(%ebp)
  80219c:	6a 00                	push   $0x0
  80219e:	e8 c8 e9 ff ff       	call   800b6b <sys_page_alloc>
  8021a3:	83 c4 10             	add    $0x10,%esp
		return r;
  8021a6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021a8:	85 c0                	test   %eax,%eax
  8021aa:	78 23                	js     8021cf <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021ac:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8021b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ba:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021c1:	83 ec 0c             	sub    $0xc,%esp
  8021c4:	50                   	push   %eax
  8021c5:	e8 c5 ee ff ff       	call   80108f <fd2num>
  8021ca:	89 c2                	mov    %eax,%edx
  8021cc:	83 c4 10             	add    $0x10,%esp
}
  8021cf:	89 d0                	mov    %edx,%eax
  8021d1:	c9                   	leave  
  8021d2:	c3                   	ret    

008021d3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8021d3:	55                   	push   %ebp
  8021d4:	89 e5                	mov    %esp,%ebp
  8021d6:	56                   	push   %esi
  8021d7:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8021d8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8021db:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8021e1:	e8 47 e9 ff ff       	call   800b2d <sys_getenvid>
  8021e6:	83 ec 0c             	sub    $0xc,%esp
  8021e9:	ff 75 0c             	pushl  0xc(%ebp)
  8021ec:	ff 75 08             	pushl  0x8(%ebp)
  8021ef:	56                   	push   %esi
  8021f0:	50                   	push   %eax
  8021f1:	68 8c 2b 80 00       	push   $0x802b8c
  8021f6:	e8 e8 df ff ff       	call   8001e3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8021fb:	83 c4 18             	add    $0x18,%esp
  8021fe:	53                   	push   %ebx
  8021ff:	ff 75 10             	pushl  0x10(%ebp)
  802202:	e8 8b df ff ff       	call   800192 <vcprintf>
	cprintf("\n");
  802207:	c7 04 24 6f 26 80 00 	movl   $0x80266f,(%esp)
  80220e:	e8 d0 df ff ff       	call   8001e3 <cprintf>
  802213:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802216:	cc                   	int3   
  802217:	eb fd                	jmp    802216 <_panic+0x43>

00802219 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802219:	55                   	push   %ebp
  80221a:	89 e5                	mov    %esp,%ebp
  80221c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80221f:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802226:	75 2e                	jne    802256 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  802228:	e8 00 e9 ff ff       	call   800b2d <sys_getenvid>
  80222d:	83 ec 04             	sub    $0x4,%esp
  802230:	68 07 0e 00 00       	push   $0xe07
  802235:	68 00 f0 bf ee       	push   $0xeebff000
  80223a:	50                   	push   %eax
  80223b:	e8 2b e9 ff ff       	call   800b6b <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802240:	e8 e8 e8 ff ff       	call   800b2d <sys_getenvid>
  802245:	83 c4 08             	add    $0x8,%esp
  802248:	68 60 22 80 00       	push   $0x802260
  80224d:	50                   	push   %eax
  80224e:	e8 63 ea ff ff       	call   800cb6 <sys_env_set_pgfault_upcall>
  802253:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802256:	8b 45 08             	mov    0x8(%ebp),%eax
  802259:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80225e:	c9                   	leave  
  80225f:	c3                   	ret    

00802260 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802260:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802261:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802266:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802268:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  80226b:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  80226f:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802273:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  802276:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  802279:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  80227a:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  80227d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  80227e:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  80227f:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802283:	c3                   	ret    

00802284 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802284:	55                   	push   %ebp
  802285:	89 e5                	mov    %esp,%ebp
  802287:	56                   	push   %esi
  802288:	53                   	push   %ebx
  802289:	8b 75 08             	mov    0x8(%ebp),%esi
  80228c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80228f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802292:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802294:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802299:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  80229c:	83 ec 0c             	sub    $0xc,%esp
  80229f:	50                   	push   %eax
  8022a0:	e8 76 ea ff ff       	call   800d1b <sys_ipc_recv>

	if (from_env_store != NULL)
  8022a5:	83 c4 10             	add    $0x10,%esp
  8022a8:	85 f6                	test   %esi,%esi
  8022aa:	74 14                	je     8022c0 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8022ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8022b1:	85 c0                	test   %eax,%eax
  8022b3:	78 09                	js     8022be <ipc_recv+0x3a>
  8022b5:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8022bb:	8b 52 74             	mov    0x74(%edx),%edx
  8022be:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8022c0:	85 db                	test   %ebx,%ebx
  8022c2:	74 14                	je     8022d8 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8022c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8022c9:	85 c0                	test   %eax,%eax
  8022cb:	78 09                	js     8022d6 <ipc_recv+0x52>
  8022cd:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8022d3:	8b 52 78             	mov    0x78(%edx),%edx
  8022d6:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8022d8:	85 c0                	test   %eax,%eax
  8022da:	78 08                	js     8022e4 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8022dc:	a1 08 40 80 00       	mov    0x804008,%eax
  8022e1:	8b 40 70             	mov    0x70(%eax),%eax
}
  8022e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022e7:	5b                   	pop    %ebx
  8022e8:	5e                   	pop    %esi
  8022e9:	5d                   	pop    %ebp
  8022ea:	c3                   	ret    

008022eb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022eb:	55                   	push   %ebp
  8022ec:	89 e5                	mov    %esp,%ebp
  8022ee:	57                   	push   %edi
  8022ef:	56                   	push   %esi
  8022f0:	53                   	push   %ebx
  8022f1:	83 ec 0c             	sub    $0xc,%esp
  8022f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022f7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8022fd:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8022ff:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802304:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  802307:	ff 75 14             	pushl  0x14(%ebp)
  80230a:	53                   	push   %ebx
  80230b:	56                   	push   %esi
  80230c:	57                   	push   %edi
  80230d:	e8 e6 e9 ff ff       	call   800cf8 <sys_ipc_try_send>

		if (err < 0) {
  802312:	83 c4 10             	add    $0x10,%esp
  802315:	85 c0                	test   %eax,%eax
  802317:	79 1e                	jns    802337 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802319:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80231c:	75 07                	jne    802325 <ipc_send+0x3a>
				sys_yield();
  80231e:	e8 29 e8 ff ff       	call   800b4c <sys_yield>
  802323:	eb e2                	jmp    802307 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802325:	50                   	push   %eax
  802326:	68 b0 2b 80 00       	push   $0x802bb0
  80232b:	6a 49                	push   $0x49
  80232d:	68 bd 2b 80 00       	push   $0x802bbd
  802332:	e8 9c fe ff ff       	call   8021d3 <_panic>
		}

	} while (err < 0);

}
  802337:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80233a:	5b                   	pop    %ebx
  80233b:	5e                   	pop    %esi
  80233c:	5f                   	pop    %edi
  80233d:	5d                   	pop    %ebp
  80233e:	c3                   	ret    

0080233f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80233f:	55                   	push   %ebp
  802340:	89 e5                	mov    %esp,%ebp
  802342:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802345:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80234a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80234d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802353:	8b 52 50             	mov    0x50(%edx),%edx
  802356:	39 ca                	cmp    %ecx,%edx
  802358:	75 0d                	jne    802367 <ipc_find_env+0x28>
			return envs[i].env_id;
  80235a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80235d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802362:	8b 40 48             	mov    0x48(%eax),%eax
  802365:	eb 0f                	jmp    802376 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802367:	83 c0 01             	add    $0x1,%eax
  80236a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80236f:	75 d9                	jne    80234a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802371:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802376:	5d                   	pop    %ebp
  802377:	c3                   	ret    

00802378 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802378:	55                   	push   %ebp
  802379:	89 e5                	mov    %esp,%ebp
  80237b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80237e:	89 d0                	mov    %edx,%eax
  802380:	c1 e8 16             	shr    $0x16,%eax
  802383:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80238a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80238f:	f6 c1 01             	test   $0x1,%cl
  802392:	74 1d                	je     8023b1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802394:	c1 ea 0c             	shr    $0xc,%edx
  802397:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80239e:	f6 c2 01             	test   $0x1,%dl
  8023a1:	74 0e                	je     8023b1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023a3:	c1 ea 0c             	shr    $0xc,%edx
  8023a6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8023ad:	ef 
  8023ae:	0f b7 c0             	movzwl %ax,%eax
}
  8023b1:	5d                   	pop    %ebp
  8023b2:	c3                   	ret    
  8023b3:	66 90                	xchg   %ax,%ax
  8023b5:	66 90                	xchg   %ax,%ax
  8023b7:	66 90                	xchg   %ax,%ax
  8023b9:	66 90                	xchg   %ax,%ax
  8023bb:	66 90                	xchg   %ax,%ax
  8023bd:	66 90                	xchg   %ax,%ax
  8023bf:	90                   	nop

008023c0 <__udivdi3>:
  8023c0:	55                   	push   %ebp
  8023c1:	57                   	push   %edi
  8023c2:	56                   	push   %esi
  8023c3:	53                   	push   %ebx
  8023c4:	83 ec 1c             	sub    $0x1c,%esp
  8023c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8023cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8023cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8023d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023d7:	85 f6                	test   %esi,%esi
  8023d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023dd:	89 ca                	mov    %ecx,%edx
  8023df:	89 f8                	mov    %edi,%eax
  8023e1:	75 3d                	jne    802420 <__udivdi3+0x60>
  8023e3:	39 cf                	cmp    %ecx,%edi
  8023e5:	0f 87 c5 00 00 00    	ja     8024b0 <__udivdi3+0xf0>
  8023eb:	85 ff                	test   %edi,%edi
  8023ed:	89 fd                	mov    %edi,%ebp
  8023ef:	75 0b                	jne    8023fc <__udivdi3+0x3c>
  8023f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8023f6:	31 d2                	xor    %edx,%edx
  8023f8:	f7 f7                	div    %edi
  8023fa:	89 c5                	mov    %eax,%ebp
  8023fc:	89 c8                	mov    %ecx,%eax
  8023fe:	31 d2                	xor    %edx,%edx
  802400:	f7 f5                	div    %ebp
  802402:	89 c1                	mov    %eax,%ecx
  802404:	89 d8                	mov    %ebx,%eax
  802406:	89 cf                	mov    %ecx,%edi
  802408:	f7 f5                	div    %ebp
  80240a:	89 c3                	mov    %eax,%ebx
  80240c:	89 d8                	mov    %ebx,%eax
  80240e:	89 fa                	mov    %edi,%edx
  802410:	83 c4 1c             	add    $0x1c,%esp
  802413:	5b                   	pop    %ebx
  802414:	5e                   	pop    %esi
  802415:	5f                   	pop    %edi
  802416:	5d                   	pop    %ebp
  802417:	c3                   	ret    
  802418:	90                   	nop
  802419:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802420:	39 ce                	cmp    %ecx,%esi
  802422:	77 74                	ja     802498 <__udivdi3+0xd8>
  802424:	0f bd fe             	bsr    %esi,%edi
  802427:	83 f7 1f             	xor    $0x1f,%edi
  80242a:	0f 84 98 00 00 00    	je     8024c8 <__udivdi3+0x108>
  802430:	bb 20 00 00 00       	mov    $0x20,%ebx
  802435:	89 f9                	mov    %edi,%ecx
  802437:	89 c5                	mov    %eax,%ebp
  802439:	29 fb                	sub    %edi,%ebx
  80243b:	d3 e6                	shl    %cl,%esi
  80243d:	89 d9                	mov    %ebx,%ecx
  80243f:	d3 ed                	shr    %cl,%ebp
  802441:	89 f9                	mov    %edi,%ecx
  802443:	d3 e0                	shl    %cl,%eax
  802445:	09 ee                	or     %ebp,%esi
  802447:	89 d9                	mov    %ebx,%ecx
  802449:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80244d:	89 d5                	mov    %edx,%ebp
  80244f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802453:	d3 ed                	shr    %cl,%ebp
  802455:	89 f9                	mov    %edi,%ecx
  802457:	d3 e2                	shl    %cl,%edx
  802459:	89 d9                	mov    %ebx,%ecx
  80245b:	d3 e8                	shr    %cl,%eax
  80245d:	09 c2                	or     %eax,%edx
  80245f:	89 d0                	mov    %edx,%eax
  802461:	89 ea                	mov    %ebp,%edx
  802463:	f7 f6                	div    %esi
  802465:	89 d5                	mov    %edx,%ebp
  802467:	89 c3                	mov    %eax,%ebx
  802469:	f7 64 24 0c          	mull   0xc(%esp)
  80246d:	39 d5                	cmp    %edx,%ebp
  80246f:	72 10                	jb     802481 <__udivdi3+0xc1>
  802471:	8b 74 24 08          	mov    0x8(%esp),%esi
  802475:	89 f9                	mov    %edi,%ecx
  802477:	d3 e6                	shl    %cl,%esi
  802479:	39 c6                	cmp    %eax,%esi
  80247b:	73 07                	jae    802484 <__udivdi3+0xc4>
  80247d:	39 d5                	cmp    %edx,%ebp
  80247f:	75 03                	jne    802484 <__udivdi3+0xc4>
  802481:	83 eb 01             	sub    $0x1,%ebx
  802484:	31 ff                	xor    %edi,%edi
  802486:	89 d8                	mov    %ebx,%eax
  802488:	89 fa                	mov    %edi,%edx
  80248a:	83 c4 1c             	add    $0x1c,%esp
  80248d:	5b                   	pop    %ebx
  80248e:	5e                   	pop    %esi
  80248f:	5f                   	pop    %edi
  802490:	5d                   	pop    %ebp
  802491:	c3                   	ret    
  802492:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802498:	31 ff                	xor    %edi,%edi
  80249a:	31 db                	xor    %ebx,%ebx
  80249c:	89 d8                	mov    %ebx,%eax
  80249e:	89 fa                	mov    %edi,%edx
  8024a0:	83 c4 1c             	add    $0x1c,%esp
  8024a3:	5b                   	pop    %ebx
  8024a4:	5e                   	pop    %esi
  8024a5:	5f                   	pop    %edi
  8024a6:	5d                   	pop    %ebp
  8024a7:	c3                   	ret    
  8024a8:	90                   	nop
  8024a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024b0:	89 d8                	mov    %ebx,%eax
  8024b2:	f7 f7                	div    %edi
  8024b4:	31 ff                	xor    %edi,%edi
  8024b6:	89 c3                	mov    %eax,%ebx
  8024b8:	89 d8                	mov    %ebx,%eax
  8024ba:	89 fa                	mov    %edi,%edx
  8024bc:	83 c4 1c             	add    $0x1c,%esp
  8024bf:	5b                   	pop    %ebx
  8024c0:	5e                   	pop    %esi
  8024c1:	5f                   	pop    %edi
  8024c2:	5d                   	pop    %ebp
  8024c3:	c3                   	ret    
  8024c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024c8:	39 ce                	cmp    %ecx,%esi
  8024ca:	72 0c                	jb     8024d8 <__udivdi3+0x118>
  8024cc:	31 db                	xor    %ebx,%ebx
  8024ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8024d2:	0f 87 34 ff ff ff    	ja     80240c <__udivdi3+0x4c>
  8024d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8024dd:	e9 2a ff ff ff       	jmp    80240c <__udivdi3+0x4c>
  8024e2:	66 90                	xchg   %ax,%ax
  8024e4:	66 90                	xchg   %ax,%ax
  8024e6:	66 90                	xchg   %ax,%ax
  8024e8:	66 90                	xchg   %ax,%ax
  8024ea:	66 90                	xchg   %ax,%ax
  8024ec:	66 90                	xchg   %ax,%ax
  8024ee:	66 90                	xchg   %ax,%ax

008024f0 <__umoddi3>:
  8024f0:	55                   	push   %ebp
  8024f1:	57                   	push   %edi
  8024f2:	56                   	push   %esi
  8024f3:	53                   	push   %ebx
  8024f4:	83 ec 1c             	sub    $0x1c,%esp
  8024f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8024fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8024ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802503:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802507:	85 d2                	test   %edx,%edx
  802509:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80250d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802511:	89 f3                	mov    %esi,%ebx
  802513:	89 3c 24             	mov    %edi,(%esp)
  802516:	89 74 24 04          	mov    %esi,0x4(%esp)
  80251a:	75 1c                	jne    802538 <__umoddi3+0x48>
  80251c:	39 f7                	cmp    %esi,%edi
  80251e:	76 50                	jbe    802570 <__umoddi3+0x80>
  802520:	89 c8                	mov    %ecx,%eax
  802522:	89 f2                	mov    %esi,%edx
  802524:	f7 f7                	div    %edi
  802526:	89 d0                	mov    %edx,%eax
  802528:	31 d2                	xor    %edx,%edx
  80252a:	83 c4 1c             	add    $0x1c,%esp
  80252d:	5b                   	pop    %ebx
  80252e:	5e                   	pop    %esi
  80252f:	5f                   	pop    %edi
  802530:	5d                   	pop    %ebp
  802531:	c3                   	ret    
  802532:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802538:	39 f2                	cmp    %esi,%edx
  80253a:	89 d0                	mov    %edx,%eax
  80253c:	77 52                	ja     802590 <__umoddi3+0xa0>
  80253e:	0f bd ea             	bsr    %edx,%ebp
  802541:	83 f5 1f             	xor    $0x1f,%ebp
  802544:	75 5a                	jne    8025a0 <__umoddi3+0xb0>
  802546:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80254a:	0f 82 e0 00 00 00    	jb     802630 <__umoddi3+0x140>
  802550:	39 0c 24             	cmp    %ecx,(%esp)
  802553:	0f 86 d7 00 00 00    	jbe    802630 <__umoddi3+0x140>
  802559:	8b 44 24 08          	mov    0x8(%esp),%eax
  80255d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802561:	83 c4 1c             	add    $0x1c,%esp
  802564:	5b                   	pop    %ebx
  802565:	5e                   	pop    %esi
  802566:	5f                   	pop    %edi
  802567:	5d                   	pop    %ebp
  802568:	c3                   	ret    
  802569:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802570:	85 ff                	test   %edi,%edi
  802572:	89 fd                	mov    %edi,%ebp
  802574:	75 0b                	jne    802581 <__umoddi3+0x91>
  802576:	b8 01 00 00 00       	mov    $0x1,%eax
  80257b:	31 d2                	xor    %edx,%edx
  80257d:	f7 f7                	div    %edi
  80257f:	89 c5                	mov    %eax,%ebp
  802581:	89 f0                	mov    %esi,%eax
  802583:	31 d2                	xor    %edx,%edx
  802585:	f7 f5                	div    %ebp
  802587:	89 c8                	mov    %ecx,%eax
  802589:	f7 f5                	div    %ebp
  80258b:	89 d0                	mov    %edx,%eax
  80258d:	eb 99                	jmp    802528 <__umoddi3+0x38>
  80258f:	90                   	nop
  802590:	89 c8                	mov    %ecx,%eax
  802592:	89 f2                	mov    %esi,%edx
  802594:	83 c4 1c             	add    $0x1c,%esp
  802597:	5b                   	pop    %ebx
  802598:	5e                   	pop    %esi
  802599:	5f                   	pop    %edi
  80259a:	5d                   	pop    %ebp
  80259b:	c3                   	ret    
  80259c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025a0:	8b 34 24             	mov    (%esp),%esi
  8025a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8025a8:	89 e9                	mov    %ebp,%ecx
  8025aa:	29 ef                	sub    %ebp,%edi
  8025ac:	d3 e0                	shl    %cl,%eax
  8025ae:	89 f9                	mov    %edi,%ecx
  8025b0:	89 f2                	mov    %esi,%edx
  8025b2:	d3 ea                	shr    %cl,%edx
  8025b4:	89 e9                	mov    %ebp,%ecx
  8025b6:	09 c2                	or     %eax,%edx
  8025b8:	89 d8                	mov    %ebx,%eax
  8025ba:	89 14 24             	mov    %edx,(%esp)
  8025bd:	89 f2                	mov    %esi,%edx
  8025bf:	d3 e2                	shl    %cl,%edx
  8025c1:	89 f9                	mov    %edi,%ecx
  8025c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8025cb:	d3 e8                	shr    %cl,%eax
  8025cd:	89 e9                	mov    %ebp,%ecx
  8025cf:	89 c6                	mov    %eax,%esi
  8025d1:	d3 e3                	shl    %cl,%ebx
  8025d3:	89 f9                	mov    %edi,%ecx
  8025d5:	89 d0                	mov    %edx,%eax
  8025d7:	d3 e8                	shr    %cl,%eax
  8025d9:	89 e9                	mov    %ebp,%ecx
  8025db:	09 d8                	or     %ebx,%eax
  8025dd:	89 d3                	mov    %edx,%ebx
  8025df:	89 f2                	mov    %esi,%edx
  8025e1:	f7 34 24             	divl   (%esp)
  8025e4:	89 d6                	mov    %edx,%esi
  8025e6:	d3 e3                	shl    %cl,%ebx
  8025e8:	f7 64 24 04          	mull   0x4(%esp)
  8025ec:	39 d6                	cmp    %edx,%esi
  8025ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025f2:	89 d1                	mov    %edx,%ecx
  8025f4:	89 c3                	mov    %eax,%ebx
  8025f6:	72 08                	jb     802600 <__umoddi3+0x110>
  8025f8:	75 11                	jne    80260b <__umoddi3+0x11b>
  8025fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8025fe:	73 0b                	jae    80260b <__umoddi3+0x11b>
  802600:	2b 44 24 04          	sub    0x4(%esp),%eax
  802604:	1b 14 24             	sbb    (%esp),%edx
  802607:	89 d1                	mov    %edx,%ecx
  802609:	89 c3                	mov    %eax,%ebx
  80260b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80260f:	29 da                	sub    %ebx,%edx
  802611:	19 ce                	sbb    %ecx,%esi
  802613:	89 f9                	mov    %edi,%ecx
  802615:	89 f0                	mov    %esi,%eax
  802617:	d3 e0                	shl    %cl,%eax
  802619:	89 e9                	mov    %ebp,%ecx
  80261b:	d3 ea                	shr    %cl,%edx
  80261d:	89 e9                	mov    %ebp,%ecx
  80261f:	d3 ee                	shr    %cl,%esi
  802621:	09 d0                	or     %edx,%eax
  802623:	89 f2                	mov    %esi,%edx
  802625:	83 c4 1c             	add    $0x1c,%esp
  802628:	5b                   	pop    %ebx
  802629:	5e                   	pop    %esi
  80262a:	5f                   	pop    %edi
  80262b:	5d                   	pop    %ebp
  80262c:	c3                   	ret    
  80262d:	8d 76 00             	lea    0x0(%esi),%esi
  802630:	29 f9                	sub    %edi,%ecx
  802632:	19 d6                	sbb    %edx,%esi
  802634:	89 74 24 04          	mov    %esi,0x4(%esp)
  802638:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80263c:	e9 18 ff ff ff       	jmp    802559 <__umoddi3+0x69>
