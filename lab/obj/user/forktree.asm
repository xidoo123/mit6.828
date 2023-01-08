
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
  800047:	68 c0 25 80 00       	push   $0x8025c0
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
  8000a4:	68 d1 25 80 00       	push   $0x8025d1
  8000a9:	6a 04                	push   $0x4
  8000ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000ae:	50                   	push   %eax
  8000af:	e8 61 06 00 00       	call   800715 <snprintf>
	// cprintf("%s, %s\n", cur, nxt);
	if (fork() == 0) {
  8000b4:	83 c4 20             	add    $0x20,%esp
  8000b7:	e8 98 0d 00 00       	call   800e54 <fork>
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
  8000e1:	68 d0 25 80 00       	push   $0x8025d0
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
  80013c:	e8 95 10 00 00       	call   8011d6 <close_all>
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
  800246:	e8 e5 20 00 00       	call   802330 <__udivdi3>
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
  800289:	e8 d2 21 00 00       	call   802460 <__umoddi3>
  80028e:	83 c4 14             	add    $0x14,%esp
  800291:	0f be 80 e0 25 80 00 	movsbl 0x8025e0(%eax),%eax
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
  80038d:	ff 24 85 20 27 80 00 	jmp    *0x802720(,%eax,4)
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
  800451:	8b 14 85 80 28 80 00 	mov    0x802880(,%eax,4),%edx
  800458:	85 d2                	test   %edx,%edx
  80045a:	75 18                	jne    800474 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80045c:	50                   	push   %eax
  80045d:	68 f8 25 80 00       	push   $0x8025f8
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
  800475:	68 6d 2a 80 00       	push   $0x802a6d
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
  800499:	b8 f1 25 80 00       	mov    $0x8025f1,%eax
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
  800b14:	68 df 28 80 00       	push   $0x8028df
  800b19:	6a 23                	push   $0x23
  800b1b:	68 fc 28 80 00       	push   $0x8028fc
  800b20:	e8 2a 16 00 00       	call   80214f <_panic>

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
  800b95:	68 df 28 80 00       	push   $0x8028df
  800b9a:	6a 23                	push   $0x23
  800b9c:	68 fc 28 80 00       	push   $0x8028fc
  800ba1:	e8 a9 15 00 00       	call   80214f <_panic>

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
  800bd7:	68 df 28 80 00       	push   $0x8028df
  800bdc:	6a 23                	push   $0x23
  800bde:	68 fc 28 80 00       	push   $0x8028fc
  800be3:	e8 67 15 00 00       	call   80214f <_panic>

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
  800c19:	68 df 28 80 00       	push   $0x8028df
  800c1e:	6a 23                	push   $0x23
  800c20:	68 fc 28 80 00       	push   $0x8028fc
  800c25:	e8 25 15 00 00       	call   80214f <_panic>

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
  800c5b:	68 df 28 80 00       	push   $0x8028df
  800c60:	6a 23                	push   $0x23
  800c62:	68 fc 28 80 00       	push   $0x8028fc
  800c67:	e8 e3 14 00 00       	call   80214f <_panic>

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
  800c9d:	68 df 28 80 00       	push   $0x8028df
  800ca2:	6a 23                	push   $0x23
  800ca4:	68 fc 28 80 00       	push   $0x8028fc
  800ca9:	e8 a1 14 00 00       	call   80214f <_panic>

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
  800cdf:	68 df 28 80 00       	push   $0x8028df
  800ce4:	6a 23                	push   $0x23
  800ce6:	68 fc 28 80 00       	push   $0x8028fc
  800ceb:	e8 5f 14 00 00       	call   80214f <_panic>

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
  800d43:	68 df 28 80 00       	push   $0x8028df
  800d48:	6a 23                	push   $0x23
  800d4a:	68 fc 28 80 00       	push   $0x8028fc
  800d4f:	e8 fb 13 00 00       	call   80214f <_panic>

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

00800d7b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	56                   	push   %esi
  800d7f:	53                   	push   %ebx
  800d80:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d83:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800d85:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d89:	75 25                	jne    800db0 <pgfault+0x35>
  800d8b:	89 d8                	mov    %ebx,%eax
  800d8d:	c1 e8 0c             	shr    $0xc,%eax
  800d90:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d97:	f6 c4 08             	test   $0x8,%ah
  800d9a:	75 14                	jne    800db0 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800d9c:	83 ec 04             	sub    $0x4,%esp
  800d9f:	68 0c 29 80 00       	push   $0x80290c
  800da4:	6a 1e                	push   $0x1e
  800da6:	68 a0 29 80 00       	push   $0x8029a0
  800dab:	e8 9f 13 00 00       	call   80214f <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800db0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800db6:	e8 72 fd ff ff       	call   800b2d <sys_getenvid>
  800dbb:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800dbd:	83 ec 04             	sub    $0x4,%esp
  800dc0:	6a 07                	push   $0x7
  800dc2:	68 00 f0 7f 00       	push   $0x7ff000
  800dc7:	50                   	push   %eax
  800dc8:	e8 9e fd ff ff       	call   800b6b <sys_page_alloc>
	if (r < 0)
  800dcd:	83 c4 10             	add    $0x10,%esp
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	79 12                	jns    800de6 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800dd4:	50                   	push   %eax
  800dd5:	68 38 29 80 00       	push   $0x802938
  800dda:	6a 33                	push   $0x33
  800ddc:	68 a0 29 80 00       	push   $0x8029a0
  800de1:	e8 69 13 00 00       	call   80214f <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800de6:	83 ec 04             	sub    $0x4,%esp
  800de9:	68 00 10 00 00       	push   $0x1000
  800dee:	53                   	push   %ebx
  800def:	68 00 f0 7f 00       	push   $0x7ff000
  800df4:	e8 69 fb ff ff       	call   800962 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800df9:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e00:	53                   	push   %ebx
  800e01:	56                   	push   %esi
  800e02:	68 00 f0 7f 00       	push   $0x7ff000
  800e07:	56                   	push   %esi
  800e08:	e8 a1 fd ff ff       	call   800bae <sys_page_map>
	if (r < 0)
  800e0d:	83 c4 20             	add    $0x20,%esp
  800e10:	85 c0                	test   %eax,%eax
  800e12:	79 12                	jns    800e26 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800e14:	50                   	push   %eax
  800e15:	68 5c 29 80 00       	push   $0x80295c
  800e1a:	6a 3b                	push   $0x3b
  800e1c:	68 a0 29 80 00       	push   $0x8029a0
  800e21:	e8 29 13 00 00       	call   80214f <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800e26:	83 ec 08             	sub    $0x8,%esp
  800e29:	68 00 f0 7f 00       	push   $0x7ff000
  800e2e:	56                   	push   %esi
  800e2f:	e8 bc fd ff ff       	call   800bf0 <sys_page_unmap>
	if (r < 0)
  800e34:	83 c4 10             	add    $0x10,%esp
  800e37:	85 c0                	test   %eax,%eax
  800e39:	79 12                	jns    800e4d <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800e3b:	50                   	push   %eax
  800e3c:	68 80 29 80 00       	push   $0x802980
  800e41:	6a 40                	push   $0x40
  800e43:	68 a0 29 80 00       	push   $0x8029a0
  800e48:	e8 02 13 00 00       	call   80214f <_panic>
}
  800e4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    

00800e54 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	57                   	push   %edi
  800e58:	56                   	push   %esi
  800e59:	53                   	push   %ebx
  800e5a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800e5d:	68 7b 0d 80 00       	push   $0x800d7b
  800e62:	e8 2e 13 00 00       	call   802195 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e67:	b8 07 00 00 00       	mov    $0x7,%eax
  800e6c:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800e6e:	83 c4 10             	add    $0x10,%esp
  800e71:	85 c0                	test   %eax,%eax
  800e73:	0f 88 64 01 00 00    	js     800fdd <fork+0x189>
  800e79:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800e7e:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800e83:	85 c0                	test   %eax,%eax
  800e85:	75 21                	jne    800ea8 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e87:	e8 a1 fc ff ff       	call   800b2d <sys_getenvid>
  800e8c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e91:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e94:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e99:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  800e9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea3:	e9 3f 01 00 00       	jmp    800fe7 <fork+0x193>
  800ea8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800eab:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800ead:	89 d8                	mov    %ebx,%eax
  800eaf:	c1 e8 16             	shr    $0x16,%eax
  800eb2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800eb9:	a8 01                	test   $0x1,%al
  800ebb:	0f 84 bd 00 00 00    	je     800f7e <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800ec1:	89 d8                	mov    %ebx,%eax
  800ec3:	c1 e8 0c             	shr    $0xc,%eax
  800ec6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ecd:	f6 c2 01             	test   $0x1,%dl
  800ed0:	0f 84 a8 00 00 00    	je     800f7e <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  800ed6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800edd:	a8 04                	test   $0x4,%al
  800edf:	0f 84 99 00 00 00    	je     800f7e <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800ee5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800eec:	f6 c4 04             	test   $0x4,%ah
  800eef:	74 17                	je     800f08 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800ef1:	83 ec 0c             	sub    $0xc,%esp
  800ef4:	68 07 0e 00 00       	push   $0xe07
  800ef9:	53                   	push   %ebx
  800efa:	57                   	push   %edi
  800efb:	53                   	push   %ebx
  800efc:	6a 00                	push   $0x0
  800efe:	e8 ab fc ff ff       	call   800bae <sys_page_map>
  800f03:	83 c4 20             	add    $0x20,%esp
  800f06:	eb 76                	jmp    800f7e <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f08:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f0f:	a8 02                	test   $0x2,%al
  800f11:	75 0c                	jne    800f1f <fork+0xcb>
  800f13:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f1a:	f6 c4 08             	test   $0x8,%ah
  800f1d:	74 3f                	je     800f5e <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f1f:	83 ec 0c             	sub    $0xc,%esp
  800f22:	68 05 08 00 00       	push   $0x805
  800f27:	53                   	push   %ebx
  800f28:	57                   	push   %edi
  800f29:	53                   	push   %ebx
  800f2a:	6a 00                	push   $0x0
  800f2c:	e8 7d fc ff ff       	call   800bae <sys_page_map>
		if (r < 0)
  800f31:	83 c4 20             	add    $0x20,%esp
  800f34:	85 c0                	test   %eax,%eax
  800f36:	0f 88 a5 00 00 00    	js     800fe1 <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f3c:	83 ec 0c             	sub    $0xc,%esp
  800f3f:	68 05 08 00 00       	push   $0x805
  800f44:	53                   	push   %ebx
  800f45:	6a 00                	push   $0x0
  800f47:	53                   	push   %ebx
  800f48:	6a 00                	push   $0x0
  800f4a:	e8 5f fc ff ff       	call   800bae <sys_page_map>
  800f4f:	83 c4 20             	add    $0x20,%esp
  800f52:	85 c0                	test   %eax,%eax
  800f54:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f59:	0f 4f c1             	cmovg  %ecx,%eax
  800f5c:	eb 1c                	jmp    800f7a <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800f5e:	83 ec 0c             	sub    $0xc,%esp
  800f61:	6a 05                	push   $0x5
  800f63:	53                   	push   %ebx
  800f64:	57                   	push   %edi
  800f65:	53                   	push   %ebx
  800f66:	6a 00                	push   $0x0
  800f68:	e8 41 fc ff ff       	call   800bae <sys_page_map>
  800f6d:	83 c4 20             	add    $0x20,%esp
  800f70:	85 c0                	test   %eax,%eax
  800f72:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f77:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  800f7a:	85 c0                	test   %eax,%eax
  800f7c:	78 67                	js     800fe5 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  800f7e:	83 c6 01             	add    $0x1,%esi
  800f81:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f87:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  800f8d:	0f 85 1a ff ff ff    	jne    800ead <fork+0x59>
  800f93:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  800f96:	83 ec 04             	sub    $0x4,%esp
  800f99:	6a 07                	push   $0x7
  800f9b:	68 00 f0 bf ee       	push   $0xeebff000
  800fa0:	57                   	push   %edi
  800fa1:	e8 c5 fb ff ff       	call   800b6b <sys_page_alloc>
	if (r < 0)
  800fa6:	83 c4 10             	add    $0x10,%esp
		return r;
  800fa9:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  800fab:	85 c0                	test   %eax,%eax
  800fad:	78 38                	js     800fe7 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800faf:	83 ec 08             	sub    $0x8,%esp
  800fb2:	68 dc 21 80 00       	push   $0x8021dc
  800fb7:	57                   	push   %edi
  800fb8:	e8 f9 fc ff ff       	call   800cb6 <sys_env_set_pgfault_upcall>
	if (r < 0)
  800fbd:	83 c4 10             	add    $0x10,%esp
		return r;
  800fc0:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  800fc2:	85 c0                	test   %eax,%eax
  800fc4:	78 21                	js     800fe7 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  800fc6:	83 ec 08             	sub    $0x8,%esp
  800fc9:	6a 02                	push   $0x2
  800fcb:	57                   	push   %edi
  800fcc:	e8 61 fc ff ff       	call   800c32 <sys_env_set_status>
	if (r < 0)
  800fd1:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	0f 48 f8             	cmovs  %eax,%edi
  800fd9:	89 fa                	mov    %edi,%edx
  800fdb:	eb 0a                	jmp    800fe7 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  800fdd:	89 c2                	mov    %eax,%edx
  800fdf:	eb 06                	jmp    800fe7 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800fe1:	89 c2                	mov    %eax,%edx
  800fe3:	eb 02                	jmp    800fe7 <fork+0x193>
  800fe5:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  800fe7:	89 d0                	mov    %edx,%eax
  800fe9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fec:	5b                   	pop    %ebx
  800fed:	5e                   	pop    %esi
  800fee:	5f                   	pop    %edi
  800fef:	5d                   	pop    %ebp
  800ff0:	c3                   	ret    

00800ff1 <sfork>:

// Challenge!
int
sfork(void)
{
  800ff1:	55                   	push   %ebp
  800ff2:	89 e5                	mov    %esp,%ebp
  800ff4:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800ff7:	68 ab 29 80 00       	push   $0x8029ab
  800ffc:	68 c9 00 00 00       	push   $0xc9
  801001:	68 a0 29 80 00       	push   $0x8029a0
  801006:	e8 44 11 00 00       	call   80214f <_panic>

0080100b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80100e:	8b 45 08             	mov    0x8(%ebp),%eax
  801011:	05 00 00 00 30       	add    $0x30000000,%eax
  801016:	c1 e8 0c             	shr    $0xc,%eax
}
  801019:	5d                   	pop    %ebp
  80101a:	c3                   	ret    

0080101b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80101e:	8b 45 08             	mov    0x8(%ebp),%eax
  801021:	05 00 00 00 30       	add    $0x30000000,%eax
  801026:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80102b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801030:	5d                   	pop    %ebp
  801031:	c3                   	ret    

00801032 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801032:	55                   	push   %ebp
  801033:	89 e5                	mov    %esp,%ebp
  801035:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801038:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80103d:	89 c2                	mov    %eax,%edx
  80103f:	c1 ea 16             	shr    $0x16,%edx
  801042:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801049:	f6 c2 01             	test   $0x1,%dl
  80104c:	74 11                	je     80105f <fd_alloc+0x2d>
  80104e:	89 c2                	mov    %eax,%edx
  801050:	c1 ea 0c             	shr    $0xc,%edx
  801053:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80105a:	f6 c2 01             	test   $0x1,%dl
  80105d:	75 09                	jne    801068 <fd_alloc+0x36>
			*fd_store = fd;
  80105f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801061:	b8 00 00 00 00       	mov    $0x0,%eax
  801066:	eb 17                	jmp    80107f <fd_alloc+0x4d>
  801068:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80106d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801072:	75 c9                	jne    80103d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801074:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80107a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80107f:	5d                   	pop    %ebp
  801080:	c3                   	ret    

00801081 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801087:	83 f8 1f             	cmp    $0x1f,%eax
  80108a:	77 36                	ja     8010c2 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80108c:	c1 e0 0c             	shl    $0xc,%eax
  80108f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801094:	89 c2                	mov    %eax,%edx
  801096:	c1 ea 16             	shr    $0x16,%edx
  801099:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010a0:	f6 c2 01             	test   $0x1,%dl
  8010a3:	74 24                	je     8010c9 <fd_lookup+0x48>
  8010a5:	89 c2                	mov    %eax,%edx
  8010a7:	c1 ea 0c             	shr    $0xc,%edx
  8010aa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010b1:	f6 c2 01             	test   $0x1,%dl
  8010b4:	74 1a                	je     8010d0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010b9:	89 02                	mov    %eax,(%edx)
	return 0;
  8010bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c0:	eb 13                	jmp    8010d5 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010c7:	eb 0c                	jmp    8010d5 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010ce:	eb 05                	jmp    8010d5 <fd_lookup+0x54>
  8010d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010d5:	5d                   	pop    %ebp
  8010d6:	c3                   	ret    

008010d7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	83 ec 08             	sub    $0x8,%esp
  8010dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010e0:	ba 40 2a 80 00       	mov    $0x802a40,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8010e5:	eb 13                	jmp    8010fa <dev_lookup+0x23>
  8010e7:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8010ea:	39 08                	cmp    %ecx,(%eax)
  8010ec:	75 0c                	jne    8010fa <dev_lookup+0x23>
			*dev = devtab[i];
  8010ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f8:	eb 2e                	jmp    801128 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8010fa:	8b 02                	mov    (%edx),%eax
  8010fc:	85 c0                	test   %eax,%eax
  8010fe:	75 e7                	jne    8010e7 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801100:	a1 08 40 80 00       	mov    0x804008,%eax
  801105:	8b 40 48             	mov    0x48(%eax),%eax
  801108:	83 ec 04             	sub    $0x4,%esp
  80110b:	51                   	push   %ecx
  80110c:	50                   	push   %eax
  80110d:	68 c4 29 80 00       	push   $0x8029c4
  801112:	e8 cc f0 ff ff       	call   8001e3 <cprintf>
	*dev = 0;
  801117:	8b 45 0c             	mov    0xc(%ebp),%eax
  80111a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801120:	83 c4 10             	add    $0x10,%esp
  801123:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801128:	c9                   	leave  
  801129:	c3                   	ret    

0080112a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80112a:	55                   	push   %ebp
  80112b:	89 e5                	mov    %esp,%ebp
  80112d:	56                   	push   %esi
  80112e:	53                   	push   %ebx
  80112f:	83 ec 10             	sub    $0x10,%esp
  801132:	8b 75 08             	mov    0x8(%ebp),%esi
  801135:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801138:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80113b:	50                   	push   %eax
  80113c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801142:	c1 e8 0c             	shr    $0xc,%eax
  801145:	50                   	push   %eax
  801146:	e8 36 ff ff ff       	call   801081 <fd_lookup>
  80114b:	83 c4 08             	add    $0x8,%esp
  80114e:	85 c0                	test   %eax,%eax
  801150:	78 05                	js     801157 <fd_close+0x2d>
	    || fd != fd2)
  801152:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801155:	74 0c                	je     801163 <fd_close+0x39>
		return (must_exist ? r : 0);
  801157:	84 db                	test   %bl,%bl
  801159:	ba 00 00 00 00       	mov    $0x0,%edx
  80115e:	0f 44 c2             	cmove  %edx,%eax
  801161:	eb 41                	jmp    8011a4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801163:	83 ec 08             	sub    $0x8,%esp
  801166:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801169:	50                   	push   %eax
  80116a:	ff 36                	pushl  (%esi)
  80116c:	e8 66 ff ff ff       	call   8010d7 <dev_lookup>
  801171:	89 c3                	mov    %eax,%ebx
  801173:	83 c4 10             	add    $0x10,%esp
  801176:	85 c0                	test   %eax,%eax
  801178:	78 1a                	js     801194 <fd_close+0x6a>
		if (dev->dev_close)
  80117a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80117d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801180:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801185:	85 c0                	test   %eax,%eax
  801187:	74 0b                	je     801194 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801189:	83 ec 0c             	sub    $0xc,%esp
  80118c:	56                   	push   %esi
  80118d:	ff d0                	call   *%eax
  80118f:	89 c3                	mov    %eax,%ebx
  801191:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801194:	83 ec 08             	sub    $0x8,%esp
  801197:	56                   	push   %esi
  801198:	6a 00                	push   $0x0
  80119a:	e8 51 fa ff ff       	call   800bf0 <sys_page_unmap>
	return r;
  80119f:	83 c4 10             	add    $0x10,%esp
  8011a2:	89 d8                	mov    %ebx,%eax
}
  8011a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011a7:	5b                   	pop    %ebx
  8011a8:	5e                   	pop    %esi
  8011a9:	5d                   	pop    %ebp
  8011aa:	c3                   	ret    

008011ab <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011ab:	55                   	push   %ebp
  8011ac:	89 e5                	mov    %esp,%ebp
  8011ae:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b4:	50                   	push   %eax
  8011b5:	ff 75 08             	pushl  0x8(%ebp)
  8011b8:	e8 c4 fe ff ff       	call   801081 <fd_lookup>
  8011bd:	83 c4 08             	add    $0x8,%esp
  8011c0:	85 c0                	test   %eax,%eax
  8011c2:	78 10                	js     8011d4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8011c4:	83 ec 08             	sub    $0x8,%esp
  8011c7:	6a 01                	push   $0x1
  8011c9:	ff 75 f4             	pushl  -0xc(%ebp)
  8011cc:	e8 59 ff ff ff       	call   80112a <fd_close>
  8011d1:	83 c4 10             	add    $0x10,%esp
}
  8011d4:	c9                   	leave  
  8011d5:	c3                   	ret    

008011d6 <close_all>:

void
close_all(void)
{
  8011d6:	55                   	push   %ebp
  8011d7:	89 e5                	mov    %esp,%ebp
  8011d9:	53                   	push   %ebx
  8011da:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011dd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011e2:	83 ec 0c             	sub    $0xc,%esp
  8011e5:	53                   	push   %ebx
  8011e6:	e8 c0 ff ff ff       	call   8011ab <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8011eb:	83 c3 01             	add    $0x1,%ebx
  8011ee:	83 c4 10             	add    $0x10,%esp
  8011f1:	83 fb 20             	cmp    $0x20,%ebx
  8011f4:	75 ec                	jne    8011e2 <close_all+0xc>
		close(i);
}
  8011f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f9:	c9                   	leave  
  8011fa:	c3                   	ret    

008011fb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	57                   	push   %edi
  8011ff:	56                   	push   %esi
  801200:	53                   	push   %ebx
  801201:	83 ec 2c             	sub    $0x2c,%esp
  801204:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801207:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80120a:	50                   	push   %eax
  80120b:	ff 75 08             	pushl  0x8(%ebp)
  80120e:	e8 6e fe ff ff       	call   801081 <fd_lookup>
  801213:	83 c4 08             	add    $0x8,%esp
  801216:	85 c0                	test   %eax,%eax
  801218:	0f 88 c1 00 00 00    	js     8012df <dup+0xe4>
		return r;
	close(newfdnum);
  80121e:	83 ec 0c             	sub    $0xc,%esp
  801221:	56                   	push   %esi
  801222:	e8 84 ff ff ff       	call   8011ab <close>

	newfd = INDEX2FD(newfdnum);
  801227:	89 f3                	mov    %esi,%ebx
  801229:	c1 e3 0c             	shl    $0xc,%ebx
  80122c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801232:	83 c4 04             	add    $0x4,%esp
  801235:	ff 75 e4             	pushl  -0x1c(%ebp)
  801238:	e8 de fd ff ff       	call   80101b <fd2data>
  80123d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80123f:	89 1c 24             	mov    %ebx,(%esp)
  801242:	e8 d4 fd ff ff       	call   80101b <fd2data>
  801247:	83 c4 10             	add    $0x10,%esp
  80124a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80124d:	89 f8                	mov    %edi,%eax
  80124f:	c1 e8 16             	shr    $0x16,%eax
  801252:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801259:	a8 01                	test   $0x1,%al
  80125b:	74 37                	je     801294 <dup+0x99>
  80125d:	89 f8                	mov    %edi,%eax
  80125f:	c1 e8 0c             	shr    $0xc,%eax
  801262:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801269:	f6 c2 01             	test   $0x1,%dl
  80126c:	74 26                	je     801294 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80126e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801275:	83 ec 0c             	sub    $0xc,%esp
  801278:	25 07 0e 00 00       	and    $0xe07,%eax
  80127d:	50                   	push   %eax
  80127e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801281:	6a 00                	push   $0x0
  801283:	57                   	push   %edi
  801284:	6a 00                	push   $0x0
  801286:	e8 23 f9 ff ff       	call   800bae <sys_page_map>
  80128b:	89 c7                	mov    %eax,%edi
  80128d:	83 c4 20             	add    $0x20,%esp
  801290:	85 c0                	test   %eax,%eax
  801292:	78 2e                	js     8012c2 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801294:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801297:	89 d0                	mov    %edx,%eax
  801299:	c1 e8 0c             	shr    $0xc,%eax
  80129c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012a3:	83 ec 0c             	sub    $0xc,%esp
  8012a6:	25 07 0e 00 00       	and    $0xe07,%eax
  8012ab:	50                   	push   %eax
  8012ac:	53                   	push   %ebx
  8012ad:	6a 00                	push   $0x0
  8012af:	52                   	push   %edx
  8012b0:	6a 00                	push   $0x0
  8012b2:	e8 f7 f8 ff ff       	call   800bae <sys_page_map>
  8012b7:	89 c7                	mov    %eax,%edi
  8012b9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012bc:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012be:	85 ff                	test   %edi,%edi
  8012c0:	79 1d                	jns    8012df <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012c2:	83 ec 08             	sub    $0x8,%esp
  8012c5:	53                   	push   %ebx
  8012c6:	6a 00                	push   $0x0
  8012c8:	e8 23 f9 ff ff       	call   800bf0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012cd:	83 c4 08             	add    $0x8,%esp
  8012d0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012d3:	6a 00                	push   $0x0
  8012d5:	e8 16 f9 ff ff       	call   800bf0 <sys_page_unmap>
	return r;
  8012da:	83 c4 10             	add    $0x10,%esp
  8012dd:	89 f8                	mov    %edi,%eax
}
  8012df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012e2:	5b                   	pop    %ebx
  8012e3:	5e                   	pop    %esi
  8012e4:	5f                   	pop    %edi
  8012e5:	5d                   	pop    %ebp
  8012e6:	c3                   	ret    

008012e7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012e7:	55                   	push   %ebp
  8012e8:	89 e5                	mov    %esp,%ebp
  8012ea:	53                   	push   %ebx
  8012eb:	83 ec 14             	sub    $0x14,%esp
  8012ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f4:	50                   	push   %eax
  8012f5:	53                   	push   %ebx
  8012f6:	e8 86 fd ff ff       	call   801081 <fd_lookup>
  8012fb:	83 c4 08             	add    $0x8,%esp
  8012fe:	89 c2                	mov    %eax,%edx
  801300:	85 c0                	test   %eax,%eax
  801302:	78 6d                	js     801371 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801304:	83 ec 08             	sub    $0x8,%esp
  801307:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130a:	50                   	push   %eax
  80130b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130e:	ff 30                	pushl  (%eax)
  801310:	e8 c2 fd ff ff       	call   8010d7 <dev_lookup>
  801315:	83 c4 10             	add    $0x10,%esp
  801318:	85 c0                	test   %eax,%eax
  80131a:	78 4c                	js     801368 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80131c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80131f:	8b 42 08             	mov    0x8(%edx),%eax
  801322:	83 e0 03             	and    $0x3,%eax
  801325:	83 f8 01             	cmp    $0x1,%eax
  801328:	75 21                	jne    80134b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80132a:	a1 08 40 80 00       	mov    0x804008,%eax
  80132f:	8b 40 48             	mov    0x48(%eax),%eax
  801332:	83 ec 04             	sub    $0x4,%esp
  801335:	53                   	push   %ebx
  801336:	50                   	push   %eax
  801337:	68 05 2a 80 00       	push   $0x802a05
  80133c:	e8 a2 ee ff ff       	call   8001e3 <cprintf>
		return -E_INVAL;
  801341:	83 c4 10             	add    $0x10,%esp
  801344:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801349:	eb 26                	jmp    801371 <read+0x8a>
	}
	if (!dev->dev_read)
  80134b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80134e:	8b 40 08             	mov    0x8(%eax),%eax
  801351:	85 c0                	test   %eax,%eax
  801353:	74 17                	je     80136c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801355:	83 ec 04             	sub    $0x4,%esp
  801358:	ff 75 10             	pushl  0x10(%ebp)
  80135b:	ff 75 0c             	pushl  0xc(%ebp)
  80135e:	52                   	push   %edx
  80135f:	ff d0                	call   *%eax
  801361:	89 c2                	mov    %eax,%edx
  801363:	83 c4 10             	add    $0x10,%esp
  801366:	eb 09                	jmp    801371 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801368:	89 c2                	mov    %eax,%edx
  80136a:	eb 05                	jmp    801371 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80136c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801371:	89 d0                	mov    %edx,%eax
  801373:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801376:	c9                   	leave  
  801377:	c3                   	ret    

00801378 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
  80137b:	57                   	push   %edi
  80137c:	56                   	push   %esi
  80137d:	53                   	push   %ebx
  80137e:	83 ec 0c             	sub    $0xc,%esp
  801381:	8b 7d 08             	mov    0x8(%ebp),%edi
  801384:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801387:	bb 00 00 00 00       	mov    $0x0,%ebx
  80138c:	eb 21                	jmp    8013af <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80138e:	83 ec 04             	sub    $0x4,%esp
  801391:	89 f0                	mov    %esi,%eax
  801393:	29 d8                	sub    %ebx,%eax
  801395:	50                   	push   %eax
  801396:	89 d8                	mov    %ebx,%eax
  801398:	03 45 0c             	add    0xc(%ebp),%eax
  80139b:	50                   	push   %eax
  80139c:	57                   	push   %edi
  80139d:	e8 45 ff ff ff       	call   8012e7 <read>
		if (m < 0)
  8013a2:	83 c4 10             	add    $0x10,%esp
  8013a5:	85 c0                	test   %eax,%eax
  8013a7:	78 10                	js     8013b9 <readn+0x41>
			return m;
		if (m == 0)
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	74 0a                	je     8013b7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013ad:	01 c3                	add    %eax,%ebx
  8013af:	39 f3                	cmp    %esi,%ebx
  8013b1:	72 db                	jb     80138e <readn+0x16>
  8013b3:	89 d8                	mov    %ebx,%eax
  8013b5:	eb 02                	jmp    8013b9 <readn+0x41>
  8013b7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013bc:	5b                   	pop    %ebx
  8013bd:	5e                   	pop    %esi
  8013be:	5f                   	pop    %edi
  8013bf:	5d                   	pop    %ebp
  8013c0:	c3                   	ret    

008013c1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013c1:	55                   	push   %ebp
  8013c2:	89 e5                	mov    %esp,%ebp
  8013c4:	53                   	push   %ebx
  8013c5:	83 ec 14             	sub    $0x14,%esp
  8013c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ce:	50                   	push   %eax
  8013cf:	53                   	push   %ebx
  8013d0:	e8 ac fc ff ff       	call   801081 <fd_lookup>
  8013d5:	83 c4 08             	add    $0x8,%esp
  8013d8:	89 c2                	mov    %eax,%edx
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	78 68                	js     801446 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013de:	83 ec 08             	sub    $0x8,%esp
  8013e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e4:	50                   	push   %eax
  8013e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e8:	ff 30                	pushl  (%eax)
  8013ea:	e8 e8 fc ff ff       	call   8010d7 <dev_lookup>
  8013ef:	83 c4 10             	add    $0x10,%esp
  8013f2:	85 c0                	test   %eax,%eax
  8013f4:	78 47                	js     80143d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013fd:	75 21                	jne    801420 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013ff:	a1 08 40 80 00       	mov    0x804008,%eax
  801404:	8b 40 48             	mov    0x48(%eax),%eax
  801407:	83 ec 04             	sub    $0x4,%esp
  80140a:	53                   	push   %ebx
  80140b:	50                   	push   %eax
  80140c:	68 21 2a 80 00       	push   $0x802a21
  801411:	e8 cd ed ff ff       	call   8001e3 <cprintf>
		return -E_INVAL;
  801416:	83 c4 10             	add    $0x10,%esp
  801419:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80141e:	eb 26                	jmp    801446 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801420:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801423:	8b 52 0c             	mov    0xc(%edx),%edx
  801426:	85 d2                	test   %edx,%edx
  801428:	74 17                	je     801441 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80142a:	83 ec 04             	sub    $0x4,%esp
  80142d:	ff 75 10             	pushl  0x10(%ebp)
  801430:	ff 75 0c             	pushl  0xc(%ebp)
  801433:	50                   	push   %eax
  801434:	ff d2                	call   *%edx
  801436:	89 c2                	mov    %eax,%edx
  801438:	83 c4 10             	add    $0x10,%esp
  80143b:	eb 09                	jmp    801446 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80143d:	89 c2                	mov    %eax,%edx
  80143f:	eb 05                	jmp    801446 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801441:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801446:	89 d0                	mov    %edx,%eax
  801448:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80144b:	c9                   	leave  
  80144c:	c3                   	ret    

0080144d <seek>:

int
seek(int fdnum, off_t offset)
{
  80144d:	55                   	push   %ebp
  80144e:	89 e5                	mov    %esp,%ebp
  801450:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801453:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801456:	50                   	push   %eax
  801457:	ff 75 08             	pushl  0x8(%ebp)
  80145a:	e8 22 fc ff ff       	call   801081 <fd_lookup>
  80145f:	83 c4 08             	add    $0x8,%esp
  801462:	85 c0                	test   %eax,%eax
  801464:	78 0e                	js     801474 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801466:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801469:	8b 55 0c             	mov    0xc(%ebp),%edx
  80146c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80146f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801474:	c9                   	leave  
  801475:	c3                   	ret    

00801476 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
  801479:	53                   	push   %ebx
  80147a:	83 ec 14             	sub    $0x14,%esp
  80147d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801480:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801483:	50                   	push   %eax
  801484:	53                   	push   %ebx
  801485:	e8 f7 fb ff ff       	call   801081 <fd_lookup>
  80148a:	83 c4 08             	add    $0x8,%esp
  80148d:	89 c2                	mov    %eax,%edx
  80148f:	85 c0                	test   %eax,%eax
  801491:	78 65                	js     8014f8 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801493:	83 ec 08             	sub    $0x8,%esp
  801496:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801499:	50                   	push   %eax
  80149a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149d:	ff 30                	pushl  (%eax)
  80149f:	e8 33 fc ff ff       	call   8010d7 <dev_lookup>
  8014a4:	83 c4 10             	add    $0x10,%esp
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	78 44                	js     8014ef <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ae:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014b2:	75 21                	jne    8014d5 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014b4:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014b9:	8b 40 48             	mov    0x48(%eax),%eax
  8014bc:	83 ec 04             	sub    $0x4,%esp
  8014bf:	53                   	push   %ebx
  8014c0:	50                   	push   %eax
  8014c1:	68 e4 29 80 00       	push   $0x8029e4
  8014c6:	e8 18 ed ff ff       	call   8001e3 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014cb:	83 c4 10             	add    $0x10,%esp
  8014ce:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014d3:	eb 23                	jmp    8014f8 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8014d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014d8:	8b 52 18             	mov    0x18(%edx),%edx
  8014db:	85 d2                	test   %edx,%edx
  8014dd:	74 14                	je     8014f3 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014df:	83 ec 08             	sub    $0x8,%esp
  8014e2:	ff 75 0c             	pushl  0xc(%ebp)
  8014e5:	50                   	push   %eax
  8014e6:	ff d2                	call   *%edx
  8014e8:	89 c2                	mov    %eax,%edx
  8014ea:	83 c4 10             	add    $0x10,%esp
  8014ed:	eb 09                	jmp    8014f8 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ef:	89 c2                	mov    %eax,%edx
  8014f1:	eb 05                	jmp    8014f8 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8014f3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8014f8:	89 d0                	mov    %edx,%eax
  8014fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014fd:	c9                   	leave  
  8014fe:	c3                   	ret    

008014ff <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014ff:	55                   	push   %ebp
  801500:	89 e5                	mov    %esp,%ebp
  801502:	53                   	push   %ebx
  801503:	83 ec 14             	sub    $0x14,%esp
  801506:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801509:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80150c:	50                   	push   %eax
  80150d:	ff 75 08             	pushl  0x8(%ebp)
  801510:	e8 6c fb ff ff       	call   801081 <fd_lookup>
  801515:	83 c4 08             	add    $0x8,%esp
  801518:	89 c2                	mov    %eax,%edx
  80151a:	85 c0                	test   %eax,%eax
  80151c:	78 58                	js     801576 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151e:	83 ec 08             	sub    $0x8,%esp
  801521:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801524:	50                   	push   %eax
  801525:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801528:	ff 30                	pushl  (%eax)
  80152a:	e8 a8 fb ff ff       	call   8010d7 <dev_lookup>
  80152f:	83 c4 10             	add    $0x10,%esp
  801532:	85 c0                	test   %eax,%eax
  801534:	78 37                	js     80156d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801536:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801539:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80153d:	74 32                	je     801571 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80153f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801542:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801549:	00 00 00 
	stat->st_isdir = 0;
  80154c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801553:	00 00 00 
	stat->st_dev = dev;
  801556:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80155c:	83 ec 08             	sub    $0x8,%esp
  80155f:	53                   	push   %ebx
  801560:	ff 75 f0             	pushl  -0x10(%ebp)
  801563:	ff 50 14             	call   *0x14(%eax)
  801566:	89 c2                	mov    %eax,%edx
  801568:	83 c4 10             	add    $0x10,%esp
  80156b:	eb 09                	jmp    801576 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156d:	89 c2                	mov    %eax,%edx
  80156f:	eb 05                	jmp    801576 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801571:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801576:	89 d0                	mov    %edx,%eax
  801578:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157b:	c9                   	leave  
  80157c:	c3                   	ret    

0080157d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80157d:	55                   	push   %ebp
  80157e:	89 e5                	mov    %esp,%ebp
  801580:	56                   	push   %esi
  801581:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801582:	83 ec 08             	sub    $0x8,%esp
  801585:	6a 00                	push   $0x0
  801587:	ff 75 08             	pushl  0x8(%ebp)
  80158a:	e8 d6 01 00 00       	call   801765 <open>
  80158f:	89 c3                	mov    %eax,%ebx
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	85 c0                	test   %eax,%eax
  801596:	78 1b                	js     8015b3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801598:	83 ec 08             	sub    $0x8,%esp
  80159b:	ff 75 0c             	pushl  0xc(%ebp)
  80159e:	50                   	push   %eax
  80159f:	e8 5b ff ff ff       	call   8014ff <fstat>
  8015a4:	89 c6                	mov    %eax,%esi
	close(fd);
  8015a6:	89 1c 24             	mov    %ebx,(%esp)
  8015a9:	e8 fd fb ff ff       	call   8011ab <close>
	return r;
  8015ae:	83 c4 10             	add    $0x10,%esp
  8015b1:	89 f0                	mov    %esi,%eax
}
  8015b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015b6:	5b                   	pop    %ebx
  8015b7:	5e                   	pop    %esi
  8015b8:	5d                   	pop    %ebp
  8015b9:	c3                   	ret    

008015ba <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015ba:	55                   	push   %ebp
  8015bb:	89 e5                	mov    %esp,%ebp
  8015bd:	56                   	push   %esi
  8015be:	53                   	push   %ebx
  8015bf:	89 c6                	mov    %eax,%esi
  8015c1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015c3:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015ca:	75 12                	jne    8015de <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015cc:	83 ec 0c             	sub    $0xc,%esp
  8015cf:	6a 01                	push   $0x1
  8015d1:	e8 e5 0c 00 00       	call   8022bb <ipc_find_env>
  8015d6:	a3 00 40 80 00       	mov    %eax,0x804000
  8015db:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015de:	6a 07                	push   $0x7
  8015e0:	68 00 50 80 00       	push   $0x805000
  8015e5:	56                   	push   %esi
  8015e6:	ff 35 00 40 80 00    	pushl  0x804000
  8015ec:	e8 76 0c 00 00       	call   802267 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015f1:	83 c4 0c             	add    $0xc,%esp
  8015f4:	6a 00                	push   $0x0
  8015f6:	53                   	push   %ebx
  8015f7:	6a 00                	push   $0x0
  8015f9:	e8 02 0c 00 00       	call   802200 <ipc_recv>
}
  8015fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801601:	5b                   	pop    %ebx
  801602:	5e                   	pop    %esi
  801603:	5d                   	pop    %ebp
  801604:	c3                   	ret    

00801605 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801605:	55                   	push   %ebp
  801606:	89 e5                	mov    %esp,%ebp
  801608:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80160b:	8b 45 08             	mov    0x8(%ebp),%eax
  80160e:	8b 40 0c             	mov    0xc(%eax),%eax
  801611:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801616:	8b 45 0c             	mov    0xc(%ebp),%eax
  801619:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80161e:	ba 00 00 00 00       	mov    $0x0,%edx
  801623:	b8 02 00 00 00       	mov    $0x2,%eax
  801628:	e8 8d ff ff ff       	call   8015ba <fsipc>
}
  80162d:	c9                   	leave  
  80162e:	c3                   	ret    

0080162f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
  801632:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801635:	8b 45 08             	mov    0x8(%ebp),%eax
  801638:	8b 40 0c             	mov    0xc(%eax),%eax
  80163b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801640:	ba 00 00 00 00       	mov    $0x0,%edx
  801645:	b8 06 00 00 00       	mov    $0x6,%eax
  80164a:	e8 6b ff ff ff       	call   8015ba <fsipc>
}
  80164f:	c9                   	leave  
  801650:	c3                   	ret    

00801651 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801651:	55                   	push   %ebp
  801652:	89 e5                	mov    %esp,%ebp
  801654:	53                   	push   %ebx
  801655:	83 ec 04             	sub    $0x4,%esp
  801658:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80165b:	8b 45 08             	mov    0x8(%ebp),%eax
  80165e:	8b 40 0c             	mov    0xc(%eax),%eax
  801661:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801666:	ba 00 00 00 00       	mov    $0x0,%edx
  80166b:	b8 05 00 00 00       	mov    $0x5,%eax
  801670:	e8 45 ff ff ff       	call   8015ba <fsipc>
  801675:	85 c0                	test   %eax,%eax
  801677:	78 2c                	js     8016a5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801679:	83 ec 08             	sub    $0x8,%esp
  80167c:	68 00 50 80 00       	push   $0x805000
  801681:	53                   	push   %ebx
  801682:	e8 e1 f0 ff ff       	call   800768 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801687:	a1 80 50 80 00       	mov    0x805080,%eax
  80168c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801692:	a1 84 50 80 00       	mov    0x805084,%eax
  801697:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80169d:	83 c4 10             	add    $0x10,%esp
  8016a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a8:	c9                   	leave  
  8016a9:	c3                   	ret    

008016aa <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016aa:	55                   	push   %ebp
  8016ab:	89 e5                	mov    %esp,%ebp
  8016ad:	83 ec 0c             	sub    $0xc,%esp
  8016b0:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8016b6:	8b 52 0c             	mov    0xc(%edx),%edx
  8016b9:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8016bf:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8016c4:	50                   	push   %eax
  8016c5:	ff 75 0c             	pushl  0xc(%ebp)
  8016c8:	68 08 50 80 00       	push   $0x805008
  8016cd:	e8 28 f2 ff ff       	call   8008fa <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8016d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d7:	b8 04 00 00 00       	mov    $0x4,%eax
  8016dc:	e8 d9 fe ff ff       	call   8015ba <fsipc>

}
  8016e1:	c9                   	leave  
  8016e2:	c3                   	ret    

008016e3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	56                   	push   %esi
  8016e7:	53                   	push   %ebx
  8016e8:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ee:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016f6:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801701:	b8 03 00 00 00       	mov    $0x3,%eax
  801706:	e8 af fe ff ff       	call   8015ba <fsipc>
  80170b:	89 c3                	mov    %eax,%ebx
  80170d:	85 c0                	test   %eax,%eax
  80170f:	78 4b                	js     80175c <devfile_read+0x79>
		return r;
	assert(r <= n);
  801711:	39 c6                	cmp    %eax,%esi
  801713:	73 16                	jae    80172b <devfile_read+0x48>
  801715:	68 54 2a 80 00       	push   $0x802a54
  80171a:	68 5b 2a 80 00       	push   $0x802a5b
  80171f:	6a 7c                	push   $0x7c
  801721:	68 70 2a 80 00       	push   $0x802a70
  801726:	e8 24 0a 00 00       	call   80214f <_panic>
	assert(r <= PGSIZE);
  80172b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801730:	7e 16                	jle    801748 <devfile_read+0x65>
  801732:	68 7b 2a 80 00       	push   $0x802a7b
  801737:	68 5b 2a 80 00       	push   $0x802a5b
  80173c:	6a 7d                	push   $0x7d
  80173e:	68 70 2a 80 00       	push   $0x802a70
  801743:	e8 07 0a 00 00       	call   80214f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801748:	83 ec 04             	sub    $0x4,%esp
  80174b:	50                   	push   %eax
  80174c:	68 00 50 80 00       	push   $0x805000
  801751:	ff 75 0c             	pushl  0xc(%ebp)
  801754:	e8 a1 f1 ff ff       	call   8008fa <memmove>
	return r;
  801759:	83 c4 10             	add    $0x10,%esp
}
  80175c:	89 d8                	mov    %ebx,%eax
  80175e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801761:	5b                   	pop    %ebx
  801762:	5e                   	pop    %esi
  801763:	5d                   	pop    %ebp
  801764:	c3                   	ret    

00801765 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801765:	55                   	push   %ebp
  801766:	89 e5                	mov    %esp,%ebp
  801768:	53                   	push   %ebx
  801769:	83 ec 20             	sub    $0x20,%esp
  80176c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80176f:	53                   	push   %ebx
  801770:	e8 ba ef ff ff       	call   80072f <strlen>
  801775:	83 c4 10             	add    $0x10,%esp
  801778:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80177d:	7f 67                	jg     8017e6 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80177f:	83 ec 0c             	sub    $0xc,%esp
  801782:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801785:	50                   	push   %eax
  801786:	e8 a7 f8 ff ff       	call   801032 <fd_alloc>
  80178b:	83 c4 10             	add    $0x10,%esp
		return r;
  80178e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801790:	85 c0                	test   %eax,%eax
  801792:	78 57                	js     8017eb <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801794:	83 ec 08             	sub    $0x8,%esp
  801797:	53                   	push   %ebx
  801798:	68 00 50 80 00       	push   $0x805000
  80179d:	e8 c6 ef ff ff       	call   800768 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a5:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ad:	b8 01 00 00 00       	mov    $0x1,%eax
  8017b2:	e8 03 fe ff ff       	call   8015ba <fsipc>
  8017b7:	89 c3                	mov    %eax,%ebx
  8017b9:	83 c4 10             	add    $0x10,%esp
  8017bc:	85 c0                	test   %eax,%eax
  8017be:	79 14                	jns    8017d4 <open+0x6f>
		fd_close(fd, 0);
  8017c0:	83 ec 08             	sub    $0x8,%esp
  8017c3:	6a 00                	push   $0x0
  8017c5:	ff 75 f4             	pushl  -0xc(%ebp)
  8017c8:	e8 5d f9 ff ff       	call   80112a <fd_close>
		return r;
  8017cd:	83 c4 10             	add    $0x10,%esp
  8017d0:	89 da                	mov    %ebx,%edx
  8017d2:	eb 17                	jmp    8017eb <open+0x86>
	}

	return fd2num(fd);
  8017d4:	83 ec 0c             	sub    $0xc,%esp
  8017d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8017da:	e8 2c f8 ff ff       	call   80100b <fd2num>
  8017df:	89 c2                	mov    %eax,%edx
  8017e1:	83 c4 10             	add    $0x10,%esp
  8017e4:	eb 05                	jmp    8017eb <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017e6:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017eb:	89 d0                	mov    %edx,%eax
  8017ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f0:	c9                   	leave  
  8017f1:	c3                   	ret    

008017f2 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fd:	b8 08 00 00 00       	mov    $0x8,%eax
  801802:	e8 b3 fd ff ff       	call   8015ba <fsipc>
}
  801807:	c9                   	leave  
  801808:	c3                   	ret    

00801809 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801809:	55                   	push   %ebp
  80180a:	89 e5                	mov    %esp,%ebp
  80180c:	56                   	push   %esi
  80180d:	53                   	push   %ebx
  80180e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801811:	83 ec 0c             	sub    $0xc,%esp
  801814:	ff 75 08             	pushl  0x8(%ebp)
  801817:	e8 ff f7 ff ff       	call   80101b <fd2data>
  80181c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80181e:	83 c4 08             	add    $0x8,%esp
  801821:	68 87 2a 80 00       	push   $0x802a87
  801826:	53                   	push   %ebx
  801827:	e8 3c ef ff ff       	call   800768 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80182c:	8b 46 04             	mov    0x4(%esi),%eax
  80182f:	2b 06                	sub    (%esi),%eax
  801831:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801837:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80183e:	00 00 00 
	stat->st_dev = &devpipe;
  801841:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801848:	30 80 00 
	return 0;
}
  80184b:	b8 00 00 00 00       	mov    $0x0,%eax
  801850:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801853:	5b                   	pop    %ebx
  801854:	5e                   	pop    %esi
  801855:	5d                   	pop    %ebp
  801856:	c3                   	ret    

00801857 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	53                   	push   %ebx
  80185b:	83 ec 0c             	sub    $0xc,%esp
  80185e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801861:	53                   	push   %ebx
  801862:	6a 00                	push   $0x0
  801864:	e8 87 f3 ff ff       	call   800bf0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801869:	89 1c 24             	mov    %ebx,(%esp)
  80186c:	e8 aa f7 ff ff       	call   80101b <fd2data>
  801871:	83 c4 08             	add    $0x8,%esp
  801874:	50                   	push   %eax
  801875:	6a 00                	push   $0x0
  801877:	e8 74 f3 ff ff       	call   800bf0 <sys_page_unmap>
}
  80187c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187f:	c9                   	leave  
  801880:	c3                   	ret    

00801881 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801881:	55                   	push   %ebp
  801882:	89 e5                	mov    %esp,%ebp
  801884:	57                   	push   %edi
  801885:	56                   	push   %esi
  801886:	53                   	push   %ebx
  801887:	83 ec 1c             	sub    $0x1c,%esp
  80188a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80188d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80188f:	a1 08 40 80 00       	mov    0x804008,%eax
  801894:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801897:	83 ec 0c             	sub    $0xc,%esp
  80189a:	ff 75 e0             	pushl  -0x20(%ebp)
  80189d:	e8 52 0a 00 00       	call   8022f4 <pageref>
  8018a2:	89 c3                	mov    %eax,%ebx
  8018a4:	89 3c 24             	mov    %edi,(%esp)
  8018a7:	e8 48 0a 00 00       	call   8022f4 <pageref>
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	39 c3                	cmp    %eax,%ebx
  8018b1:	0f 94 c1             	sete   %cl
  8018b4:	0f b6 c9             	movzbl %cl,%ecx
  8018b7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8018ba:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8018c0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018c3:	39 ce                	cmp    %ecx,%esi
  8018c5:	74 1b                	je     8018e2 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8018c7:	39 c3                	cmp    %eax,%ebx
  8018c9:	75 c4                	jne    80188f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018cb:	8b 42 58             	mov    0x58(%edx),%eax
  8018ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018d1:	50                   	push   %eax
  8018d2:	56                   	push   %esi
  8018d3:	68 8e 2a 80 00       	push   $0x802a8e
  8018d8:	e8 06 e9 ff ff       	call   8001e3 <cprintf>
  8018dd:	83 c4 10             	add    $0x10,%esp
  8018e0:	eb ad                	jmp    80188f <_pipeisclosed+0xe>
	}
}
  8018e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018e8:	5b                   	pop    %ebx
  8018e9:	5e                   	pop    %esi
  8018ea:	5f                   	pop    %edi
  8018eb:	5d                   	pop    %ebp
  8018ec:	c3                   	ret    

008018ed <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018ed:	55                   	push   %ebp
  8018ee:	89 e5                	mov    %esp,%ebp
  8018f0:	57                   	push   %edi
  8018f1:	56                   	push   %esi
  8018f2:	53                   	push   %ebx
  8018f3:	83 ec 28             	sub    $0x28,%esp
  8018f6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8018f9:	56                   	push   %esi
  8018fa:	e8 1c f7 ff ff       	call   80101b <fd2data>
  8018ff:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801901:	83 c4 10             	add    $0x10,%esp
  801904:	bf 00 00 00 00       	mov    $0x0,%edi
  801909:	eb 4b                	jmp    801956 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80190b:	89 da                	mov    %ebx,%edx
  80190d:	89 f0                	mov    %esi,%eax
  80190f:	e8 6d ff ff ff       	call   801881 <_pipeisclosed>
  801914:	85 c0                	test   %eax,%eax
  801916:	75 48                	jne    801960 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801918:	e8 2f f2 ff ff       	call   800b4c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80191d:	8b 43 04             	mov    0x4(%ebx),%eax
  801920:	8b 0b                	mov    (%ebx),%ecx
  801922:	8d 51 20             	lea    0x20(%ecx),%edx
  801925:	39 d0                	cmp    %edx,%eax
  801927:	73 e2                	jae    80190b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801929:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80192c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801930:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801933:	89 c2                	mov    %eax,%edx
  801935:	c1 fa 1f             	sar    $0x1f,%edx
  801938:	89 d1                	mov    %edx,%ecx
  80193a:	c1 e9 1b             	shr    $0x1b,%ecx
  80193d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801940:	83 e2 1f             	and    $0x1f,%edx
  801943:	29 ca                	sub    %ecx,%edx
  801945:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801949:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80194d:	83 c0 01             	add    $0x1,%eax
  801950:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801953:	83 c7 01             	add    $0x1,%edi
  801956:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801959:	75 c2                	jne    80191d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80195b:	8b 45 10             	mov    0x10(%ebp),%eax
  80195e:	eb 05                	jmp    801965 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801960:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801965:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801968:	5b                   	pop    %ebx
  801969:	5e                   	pop    %esi
  80196a:	5f                   	pop    %edi
  80196b:	5d                   	pop    %ebp
  80196c:	c3                   	ret    

0080196d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80196d:	55                   	push   %ebp
  80196e:	89 e5                	mov    %esp,%ebp
  801970:	57                   	push   %edi
  801971:	56                   	push   %esi
  801972:	53                   	push   %ebx
  801973:	83 ec 18             	sub    $0x18,%esp
  801976:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801979:	57                   	push   %edi
  80197a:	e8 9c f6 ff ff       	call   80101b <fd2data>
  80197f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801981:	83 c4 10             	add    $0x10,%esp
  801984:	bb 00 00 00 00       	mov    $0x0,%ebx
  801989:	eb 3d                	jmp    8019c8 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80198b:	85 db                	test   %ebx,%ebx
  80198d:	74 04                	je     801993 <devpipe_read+0x26>
				return i;
  80198f:	89 d8                	mov    %ebx,%eax
  801991:	eb 44                	jmp    8019d7 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801993:	89 f2                	mov    %esi,%edx
  801995:	89 f8                	mov    %edi,%eax
  801997:	e8 e5 fe ff ff       	call   801881 <_pipeisclosed>
  80199c:	85 c0                	test   %eax,%eax
  80199e:	75 32                	jne    8019d2 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019a0:	e8 a7 f1 ff ff       	call   800b4c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019a5:	8b 06                	mov    (%esi),%eax
  8019a7:	3b 46 04             	cmp    0x4(%esi),%eax
  8019aa:	74 df                	je     80198b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019ac:	99                   	cltd   
  8019ad:	c1 ea 1b             	shr    $0x1b,%edx
  8019b0:	01 d0                	add    %edx,%eax
  8019b2:	83 e0 1f             	and    $0x1f,%eax
  8019b5:	29 d0                	sub    %edx,%eax
  8019b7:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8019bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019bf:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8019c2:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019c5:	83 c3 01             	add    $0x1,%ebx
  8019c8:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019cb:	75 d8                	jne    8019a5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8019d0:	eb 05                	jmp    8019d7 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019d2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019da:	5b                   	pop    %ebx
  8019db:	5e                   	pop    %esi
  8019dc:	5f                   	pop    %edi
  8019dd:	5d                   	pop    %ebp
  8019de:	c3                   	ret    

008019df <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8019df:	55                   	push   %ebp
  8019e0:	89 e5                	mov    %esp,%ebp
  8019e2:	56                   	push   %esi
  8019e3:	53                   	push   %ebx
  8019e4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8019e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ea:	50                   	push   %eax
  8019eb:	e8 42 f6 ff ff       	call   801032 <fd_alloc>
  8019f0:	83 c4 10             	add    $0x10,%esp
  8019f3:	89 c2                	mov    %eax,%edx
  8019f5:	85 c0                	test   %eax,%eax
  8019f7:	0f 88 2c 01 00 00    	js     801b29 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019fd:	83 ec 04             	sub    $0x4,%esp
  801a00:	68 07 04 00 00       	push   $0x407
  801a05:	ff 75 f4             	pushl  -0xc(%ebp)
  801a08:	6a 00                	push   $0x0
  801a0a:	e8 5c f1 ff ff       	call   800b6b <sys_page_alloc>
  801a0f:	83 c4 10             	add    $0x10,%esp
  801a12:	89 c2                	mov    %eax,%edx
  801a14:	85 c0                	test   %eax,%eax
  801a16:	0f 88 0d 01 00 00    	js     801b29 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a1c:	83 ec 0c             	sub    $0xc,%esp
  801a1f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a22:	50                   	push   %eax
  801a23:	e8 0a f6 ff ff       	call   801032 <fd_alloc>
  801a28:	89 c3                	mov    %eax,%ebx
  801a2a:	83 c4 10             	add    $0x10,%esp
  801a2d:	85 c0                	test   %eax,%eax
  801a2f:	0f 88 e2 00 00 00    	js     801b17 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a35:	83 ec 04             	sub    $0x4,%esp
  801a38:	68 07 04 00 00       	push   $0x407
  801a3d:	ff 75 f0             	pushl  -0x10(%ebp)
  801a40:	6a 00                	push   $0x0
  801a42:	e8 24 f1 ff ff       	call   800b6b <sys_page_alloc>
  801a47:	89 c3                	mov    %eax,%ebx
  801a49:	83 c4 10             	add    $0x10,%esp
  801a4c:	85 c0                	test   %eax,%eax
  801a4e:	0f 88 c3 00 00 00    	js     801b17 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a54:	83 ec 0c             	sub    $0xc,%esp
  801a57:	ff 75 f4             	pushl  -0xc(%ebp)
  801a5a:	e8 bc f5 ff ff       	call   80101b <fd2data>
  801a5f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a61:	83 c4 0c             	add    $0xc,%esp
  801a64:	68 07 04 00 00       	push   $0x407
  801a69:	50                   	push   %eax
  801a6a:	6a 00                	push   $0x0
  801a6c:	e8 fa f0 ff ff       	call   800b6b <sys_page_alloc>
  801a71:	89 c3                	mov    %eax,%ebx
  801a73:	83 c4 10             	add    $0x10,%esp
  801a76:	85 c0                	test   %eax,%eax
  801a78:	0f 88 89 00 00 00    	js     801b07 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a7e:	83 ec 0c             	sub    $0xc,%esp
  801a81:	ff 75 f0             	pushl  -0x10(%ebp)
  801a84:	e8 92 f5 ff ff       	call   80101b <fd2data>
  801a89:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a90:	50                   	push   %eax
  801a91:	6a 00                	push   $0x0
  801a93:	56                   	push   %esi
  801a94:	6a 00                	push   $0x0
  801a96:	e8 13 f1 ff ff       	call   800bae <sys_page_map>
  801a9b:	89 c3                	mov    %eax,%ebx
  801a9d:	83 c4 20             	add    $0x20,%esp
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	78 55                	js     801af9 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801aa4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aad:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ab9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801abf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ac2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ac4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ac7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ace:	83 ec 0c             	sub    $0xc,%esp
  801ad1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ad4:	e8 32 f5 ff ff       	call   80100b <fd2num>
  801ad9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801adc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ade:	83 c4 04             	add    $0x4,%esp
  801ae1:	ff 75 f0             	pushl  -0x10(%ebp)
  801ae4:	e8 22 f5 ff ff       	call   80100b <fd2num>
  801ae9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801aec:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801aef:	83 c4 10             	add    $0x10,%esp
  801af2:	ba 00 00 00 00       	mov    $0x0,%edx
  801af7:	eb 30                	jmp    801b29 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801af9:	83 ec 08             	sub    $0x8,%esp
  801afc:	56                   	push   %esi
  801afd:	6a 00                	push   $0x0
  801aff:	e8 ec f0 ff ff       	call   800bf0 <sys_page_unmap>
  801b04:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b07:	83 ec 08             	sub    $0x8,%esp
  801b0a:	ff 75 f0             	pushl  -0x10(%ebp)
  801b0d:	6a 00                	push   $0x0
  801b0f:	e8 dc f0 ff ff       	call   800bf0 <sys_page_unmap>
  801b14:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b17:	83 ec 08             	sub    $0x8,%esp
  801b1a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b1d:	6a 00                	push   $0x0
  801b1f:	e8 cc f0 ff ff       	call   800bf0 <sys_page_unmap>
  801b24:	83 c4 10             	add    $0x10,%esp
  801b27:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b29:	89 d0                	mov    %edx,%eax
  801b2b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b2e:	5b                   	pop    %ebx
  801b2f:	5e                   	pop    %esi
  801b30:	5d                   	pop    %ebp
  801b31:	c3                   	ret    

00801b32 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b32:	55                   	push   %ebp
  801b33:	89 e5                	mov    %esp,%ebp
  801b35:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b3b:	50                   	push   %eax
  801b3c:	ff 75 08             	pushl  0x8(%ebp)
  801b3f:	e8 3d f5 ff ff       	call   801081 <fd_lookup>
  801b44:	83 c4 10             	add    $0x10,%esp
  801b47:	85 c0                	test   %eax,%eax
  801b49:	78 18                	js     801b63 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b4b:	83 ec 0c             	sub    $0xc,%esp
  801b4e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b51:	e8 c5 f4 ff ff       	call   80101b <fd2data>
	return _pipeisclosed(fd, p);
  801b56:	89 c2                	mov    %eax,%edx
  801b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5b:	e8 21 fd ff ff       	call   801881 <_pipeisclosed>
  801b60:	83 c4 10             	add    $0x10,%esp
}
  801b63:	c9                   	leave  
  801b64:	c3                   	ret    

00801b65 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b65:	55                   	push   %ebp
  801b66:	89 e5                	mov    %esp,%ebp
  801b68:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801b6b:	68 a6 2a 80 00       	push   $0x802aa6
  801b70:	ff 75 0c             	pushl  0xc(%ebp)
  801b73:	e8 f0 eb ff ff       	call   800768 <strcpy>
	return 0;
}
  801b78:	b8 00 00 00 00       	mov    $0x0,%eax
  801b7d:	c9                   	leave  
  801b7e:	c3                   	ret    

00801b7f <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801b7f:	55                   	push   %ebp
  801b80:	89 e5                	mov    %esp,%ebp
  801b82:	53                   	push   %ebx
  801b83:	83 ec 10             	sub    $0x10,%esp
  801b86:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b89:	53                   	push   %ebx
  801b8a:	e8 65 07 00 00       	call   8022f4 <pageref>
  801b8f:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801b92:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801b97:	83 f8 01             	cmp    $0x1,%eax
  801b9a:	75 10                	jne    801bac <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801b9c:	83 ec 0c             	sub    $0xc,%esp
  801b9f:	ff 73 0c             	pushl  0xc(%ebx)
  801ba2:	e8 c0 02 00 00       	call   801e67 <nsipc_close>
  801ba7:	89 c2                	mov    %eax,%edx
  801ba9:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801bac:	89 d0                	mov    %edx,%eax
  801bae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb1:	c9                   	leave  
  801bb2:	c3                   	ret    

00801bb3 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801bb9:	6a 00                	push   $0x0
  801bbb:	ff 75 10             	pushl  0x10(%ebp)
  801bbe:	ff 75 0c             	pushl  0xc(%ebp)
  801bc1:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc4:	ff 70 0c             	pushl  0xc(%eax)
  801bc7:	e8 78 03 00 00       	call   801f44 <nsipc_send>
}
  801bcc:	c9                   	leave  
  801bcd:	c3                   	ret    

00801bce <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801bce:	55                   	push   %ebp
  801bcf:	89 e5                	mov    %esp,%ebp
  801bd1:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801bd4:	6a 00                	push   $0x0
  801bd6:	ff 75 10             	pushl  0x10(%ebp)
  801bd9:	ff 75 0c             	pushl  0xc(%ebp)
  801bdc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdf:	ff 70 0c             	pushl  0xc(%eax)
  801be2:	e8 f1 02 00 00       	call   801ed8 <nsipc_recv>
}
  801be7:	c9                   	leave  
  801be8:	c3                   	ret    

00801be9 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801be9:	55                   	push   %ebp
  801bea:	89 e5                	mov    %esp,%ebp
  801bec:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801bef:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801bf2:	52                   	push   %edx
  801bf3:	50                   	push   %eax
  801bf4:	e8 88 f4 ff ff       	call   801081 <fd_lookup>
  801bf9:	83 c4 10             	add    $0x10,%esp
  801bfc:	85 c0                	test   %eax,%eax
  801bfe:	78 17                	js     801c17 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c03:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801c09:	39 08                	cmp    %ecx,(%eax)
  801c0b:	75 05                	jne    801c12 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801c0d:	8b 40 0c             	mov    0xc(%eax),%eax
  801c10:	eb 05                	jmp    801c17 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801c12:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801c17:	c9                   	leave  
  801c18:	c3                   	ret    

00801c19 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801c19:	55                   	push   %ebp
  801c1a:	89 e5                	mov    %esp,%ebp
  801c1c:	56                   	push   %esi
  801c1d:	53                   	push   %ebx
  801c1e:	83 ec 1c             	sub    $0x1c,%esp
  801c21:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801c23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c26:	50                   	push   %eax
  801c27:	e8 06 f4 ff ff       	call   801032 <fd_alloc>
  801c2c:	89 c3                	mov    %eax,%ebx
  801c2e:	83 c4 10             	add    $0x10,%esp
  801c31:	85 c0                	test   %eax,%eax
  801c33:	78 1b                	js     801c50 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801c35:	83 ec 04             	sub    $0x4,%esp
  801c38:	68 07 04 00 00       	push   $0x407
  801c3d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c40:	6a 00                	push   $0x0
  801c42:	e8 24 ef ff ff       	call   800b6b <sys_page_alloc>
  801c47:	89 c3                	mov    %eax,%ebx
  801c49:	83 c4 10             	add    $0x10,%esp
  801c4c:	85 c0                	test   %eax,%eax
  801c4e:	79 10                	jns    801c60 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801c50:	83 ec 0c             	sub    $0xc,%esp
  801c53:	56                   	push   %esi
  801c54:	e8 0e 02 00 00       	call   801e67 <nsipc_close>
		return r;
  801c59:	83 c4 10             	add    $0x10,%esp
  801c5c:	89 d8                	mov    %ebx,%eax
  801c5e:	eb 24                	jmp    801c84 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801c60:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c69:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c75:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801c78:	83 ec 0c             	sub    $0xc,%esp
  801c7b:	50                   	push   %eax
  801c7c:	e8 8a f3 ff ff       	call   80100b <fd2num>
  801c81:	83 c4 10             	add    $0x10,%esp
}
  801c84:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c87:	5b                   	pop    %ebx
  801c88:	5e                   	pop    %esi
  801c89:	5d                   	pop    %ebp
  801c8a:	c3                   	ret    

00801c8b <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c8b:	55                   	push   %ebp
  801c8c:	89 e5                	mov    %esp,%ebp
  801c8e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c91:	8b 45 08             	mov    0x8(%ebp),%eax
  801c94:	e8 50 ff ff ff       	call   801be9 <fd2sockid>
		return r;
  801c99:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c9b:	85 c0                	test   %eax,%eax
  801c9d:	78 1f                	js     801cbe <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c9f:	83 ec 04             	sub    $0x4,%esp
  801ca2:	ff 75 10             	pushl  0x10(%ebp)
  801ca5:	ff 75 0c             	pushl  0xc(%ebp)
  801ca8:	50                   	push   %eax
  801ca9:	e8 12 01 00 00       	call   801dc0 <nsipc_accept>
  801cae:	83 c4 10             	add    $0x10,%esp
		return r;
  801cb1:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801cb3:	85 c0                	test   %eax,%eax
  801cb5:	78 07                	js     801cbe <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801cb7:	e8 5d ff ff ff       	call   801c19 <alloc_sockfd>
  801cbc:	89 c1                	mov    %eax,%ecx
}
  801cbe:	89 c8                	mov    %ecx,%eax
  801cc0:	c9                   	leave  
  801cc1:	c3                   	ret    

00801cc2 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cc2:	55                   	push   %ebp
  801cc3:	89 e5                	mov    %esp,%ebp
  801cc5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ccb:	e8 19 ff ff ff       	call   801be9 <fd2sockid>
  801cd0:	85 c0                	test   %eax,%eax
  801cd2:	78 12                	js     801ce6 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801cd4:	83 ec 04             	sub    $0x4,%esp
  801cd7:	ff 75 10             	pushl  0x10(%ebp)
  801cda:	ff 75 0c             	pushl  0xc(%ebp)
  801cdd:	50                   	push   %eax
  801cde:	e8 2d 01 00 00       	call   801e10 <nsipc_bind>
  801ce3:	83 c4 10             	add    $0x10,%esp
}
  801ce6:	c9                   	leave  
  801ce7:	c3                   	ret    

00801ce8 <shutdown>:

int
shutdown(int s, int how)
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cee:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf1:	e8 f3 fe ff ff       	call   801be9 <fd2sockid>
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	78 0f                	js     801d09 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801cfa:	83 ec 08             	sub    $0x8,%esp
  801cfd:	ff 75 0c             	pushl  0xc(%ebp)
  801d00:	50                   	push   %eax
  801d01:	e8 3f 01 00 00       	call   801e45 <nsipc_shutdown>
  801d06:	83 c4 10             	add    $0x10,%esp
}
  801d09:	c9                   	leave  
  801d0a:	c3                   	ret    

00801d0b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d0b:	55                   	push   %ebp
  801d0c:	89 e5                	mov    %esp,%ebp
  801d0e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d11:	8b 45 08             	mov    0x8(%ebp),%eax
  801d14:	e8 d0 fe ff ff       	call   801be9 <fd2sockid>
  801d19:	85 c0                	test   %eax,%eax
  801d1b:	78 12                	js     801d2f <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801d1d:	83 ec 04             	sub    $0x4,%esp
  801d20:	ff 75 10             	pushl  0x10(%ebp)
  801d23:	ff 75 0c             	pushl  0xc(%ebp)
  801d26:	50                   	push   %eax
  801d27:	e8 55 01 00 00       	call   801e81 <nsipc_connect>
  801d2c:	83 c4 10             	add    $0x10,%esp
}
  801d2f:	c9                   	leave  
  801d30:	c3                   	ret    

00801d31 <listen>:

int
listen(int s, int backlog)
{
  801d31:	55                   	push   %ebp
  801d32:	89 e5                	mov    %esp,%ebp
  801d34:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d37:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3a:	e8 aa fe ff ff       	call   801be9 <fd2sockid>
  801d3f:	85 c0                	test   %eax,%eax
  801d41:	78 0f                	js     801d52 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801d43:	83 ec 08             	sub    $0x8,%esp
  801d46:	ff 75 0c             	pushl  0xc(%ebp)
  801d49:	50                   	push   %eax
  801d4a:	e8 67 01 00 00       	call   801eb6 <nsipc_listen>
  801d4f:	83 c4 10             	add    $0x10,%esp
}
  801d52:	c9                   	leave  
  801d53:	c3                   	ret    

00801d54 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801d54:	55                   	push   %ebp
  801d55:	89 e5                	mov    %esp,%ebp
  801d57:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801d5a:	ff 75 10             	pushl  0x10(%ebp)
  801d5d:	ff 75 0c             	pushl  0xc(%ebp)
  801d60:	ff 75 08             	pushl  0x8(%ebp)
  801d63:	e8 3a 02 00 00       	call   801fa2 <nsipc_socket>
  801d68:	83 c4 10             	add    $0x10,%esp
  801d6b:	85 c0                	test   %eax,%eax
  801d6d:	78 05                	js     801d74 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801d6f:	e8 a5 fe ff ff       	call   801c19 <alloc_sockfd>
}
  801d74:	c9                   	leave  
  801d75:	c3                   	ret    

00801d76 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d76:	55                   	push   %ebp
  801d77:	89 e5                	mov    %esp,%ebp
  801d79:	53                   	push   %ebx
  801d7a:	83 ec 04             	sub    $0x4,%esp
  801d7d:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d7f:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801d86:	75 12                	jne    801d9a <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d88:	83 ec 0c             	sub    $0xc,%esp
  801d8b:	6a 02                	push   $0x2
  801d8d:	e8 29 05 00 00       	call   8022bb <ipc_find_env>
  801d92:	a3 04 40 80 00       	mov    %eax,0x804004
  801d97:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d9a:	6a 07                	push   $0x7
  801d9c:	68 00 60 80 00       	push   $0x806000
  801da1:	53                   	push   %ebx
  801da2:	ff 35 04 40 80 00    	pushl  0x804004
  801da8:	e8 ba 04 00 00       	call   802267 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801dad:	83 c4 0c             	add    $0xc,%esp
  801db0:	6a 00                	push   $0x0
  801db2:	6a 00                	push   $0x0
  801db4:	6a 00                	push   $0x0
  801db6:	e8 45 04 00 00       	call   802200 <ipc_recv>
}
  801dbb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dbe:	c9                   	leave  
  801dbf:	c3                   	ret    

00801dc0 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	56                   	push   %esi
  801dc4:	53                   	push   %ebx
  801dc5:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801dc8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801dd0:	8b 06                	mov    (%esi),%eax
  801dd2:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801dd7:	b8 01 00 00 00       	mov    $0x1,%eax
  801ddc:	e8 95 ff ff ff       	call   801d76 <nsipc>
  801de1:	89 c3                	mov    %eax,%ebx
  801de3:	85 c0                	test   %eax,%eax
  801de5:	78 20                	js     801e07 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801de7:	83 ec 04             	sub    $0x4,%esp
  801dea:	ff 35 10 60 80 00    	pushl  0x806010
  801df0:	68 00 60 80 00       	push   $0x806000
  801df5:	ff 75 0c             	pushl  0xc(%ebp)
  801df8:	e8 fd ea ff ff       	call   8008fa <memmove>
		*addrlen = ret->ret_addrlen;
  801dfd:	a1 10 60 80 00       	mov    0x806010,%eax
  801e02:	89 06                	mov    %eax,(%esi)
  801e04:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801e07:	89 d8                	mov    %ebx,%eax
  801e09:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e0c:	5b                   	pop    %ebx
  801e0d:	5e                   	pop    %esi
  801e0e:	5d                   	pop    %ebp
  801e0f:	c3                   	ret    

00801e10 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	53                   	push   %ebx
  801e14:	83 ec 08             	sub    $0x8,%esp
  801e17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801e22:	53                   	push   %ebx
  801e23:	ff 75 0c             	pushl  0xc(%ebp)
  801e26:	68 04 60 80 00       	push   $0x806004
  801e2b:	e8 ca ea ff ff       	call   8008fa <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801e30:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801e36:	b8 02 00 00 00       	mov    $0x2,%eax
  801e3b:	e8 36 ff ff ff       	call   801d76 <nsipc>
}
  801e40:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e43:	c9                   	leave  
  801e44:	c3                   	ret    

00801e45 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801e45:	55                   	push   %ebp
  801e46:	89 e5                	mov    %esp,%ebp
  801e48:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801e53:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e56:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e5b:	b8 03 00 00 00       	mov    $0x3,%eax
  801e60:	e8 11 ff ff ff       	call   801d76 <nsipc>
}
  801e65:	c9                   	leave  
  801e66:	c3                   	ret    

00801e67 <nsipc_close>:

int
nsipc_close(int s)
{
  801e67:	55                   	push   %ebp
  801e68:	89 e5                	mov    %esp,%ebp
  801e6a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801e6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e70:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801e75:	b8 04 00 00 00       	mov    $0x4,%eax
  801e7a:	e8 f7 fe ff ff       	call   801d76 <nsipc>
}
  801e7f:	c9                   	leave  
  801e80:	c3                   	ret    

00801e81 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e81:	55                   	push   %ebp
  801e82:	89 e5                	mov    %esp,%ebp
  801e84:	53                   	push   %ebx
  801e85:	83 ec 08             	sub    $0x8,%esp
  801e88:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801e8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801e93:	53                   	push   %ebx
  801e94:	ff 75 0c             	pushl  0xc(%ebp)
  801e97:	68 04 60 80 00       	push   $0x806004
  801e9c:	e8 59 ea ff ff       	call   8008fa <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ea1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801ea7:	b8 05 00 00 00       	mov    $0x5,%eax
  801eac:	e8 c5 fe ff ff       	call   801d76 <nsipc>
}
  801eb1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eb4:	c9                   	leave  
  801eb5:	c3                   	ret    

00801eb6 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801eb6:	55                   	push   %ebp
  801eb7:	89 e5                	mov    %esp,%ebp
  801eb9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ebc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801ec4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec7:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801ecc:	b8 06 00 00 00       	mov    $0x6,%eax
  801ed1:	e8 a0 fe ff ff       	call   801d76 <nsipc>
}
  801ed6:	c9                   	leave  
  801ed7:	c3                   	ret    

00801ed8 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ed8:	55                   	push   %ebp
  801ed9:	89 e5                	mov    %esp,%ebp
  801edb:	56                   	push   %esi
  801edc:	53                   	push   %ebx
  801edd:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801ee0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801ee8:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801eee:	8b 45 14             	mov    0x14(%ebp),%eax
  801ef1:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ef6:	b8 07 00 00 00       	mov    $0x7,%eax
  801efb:	e8 76 fe ff ff       	call   801d76 <nsipc>
  801f00:	89 c3                	mov    %eax,%ebx
  801f02:	85 c0                	test   %eax,%eax
  801f04:	78 35                	js     801f3b <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801f06:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801f0b:	7f 04                	jg     801f11 <nsipc_recv+0x39>
  801f0d:	39 c6                	cmp    %eax,%esi
  801f0f:	7d 16                	jge    801f27 <nsipc_recv+0x4f>
  801f11:	68 b2 2a 80 00       	push   $0x802ab2
  801f16:	68 5b 2a 80 00       	push   $0x802a5b
  801f1b:	6a 62                	push   $0x62
  801f1d:	68 c7 2a 80 00       	push   $0x802ac7
  801f22:	e8 28 02 00 00       	call   80214f <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f27:	83 ec 04             	sub    $0x4,%esp
  801f2a:	50                   	push   %eax
  801f2b:	68 00 60 80 00       	push   $0x806000
  801f30:	ff 75 0c             	pushl  0xc(%ebp)
  801f33:	e8 c2 e9 ff ff       	call   8008fa <memmove>
  801f38:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801f3b:	89 d8                	mov    %ebx,%eax
  801f3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f40:	5b                   	pop    %ebx
  801f41:	5e                   	pop    %esi
  801f42:	5d                   	pop    %ebp
  801f43:	c3                   	ret    

00801f44 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
  801f47:	53                   	push   %ebx
  801f48:	83 ec 04             	sub    $0x4,%esp
  801f4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801f4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f51:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801f56:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801f5c:	7e 16                	jle    801f74 <nsipc_send+0x30>
  801f5e:	68 d3 2a 80 00       	push   $0x802ad3
  801f63:	68 5b 2a 80 00       	push   $0x802a5b
  801f68:	6a 6d                	push   $0x6d
  801f6a:	68 c7 2a 80 00       	push   $0x802ac7
  801f6f:	e8 db 01 00 00       	call   80214f <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801f74:	83 ec 04             	sub    $0x4,%esp
  801f77:	53                   	push   %ebx
  801f78:	ff 75 0c             	pushl  0xc(%ebp)
  801f7b:	68 0c 60 80 00       	push   $0x80600c
  801f80:	e8 75 e9 ff ff       	call   8008fa <memmove>
	nsipcbuf.send.req_size = size;
  801f85:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801f8b:	8b 45 14             	mov    0x14(%ebp),%eax
  801f8e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801f93:	b8 08 00 00 00       	mov    $0x8,%eax
  801f98:	e8 d9 fd ff ff       	call   801d76 <nsipc>
}
  801f9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fa0:	c9                   	leave  
  801fa1:	c3                   	ret    

00801fa2 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801fa2:	55                   	push   %ebp
  801fa3:	89 e5                	mov    %esp,%ebp
  801fa5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801fa8:	8b 45 08             	mov    0x8(%ebp),%eax
  801fab:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801fb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fb3:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801fb8:	8b 45 10             	mov    0x10(%ebp),%eax
  801fbb:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801fc0:	b8 09 00 00 00       	mov    $0x9,%eax
  801fc5:	e8 ac fd ff ff       	call   801d76 <nsipc>
}
  801fca:	c9                   	leave  
  801fcb:	c3                   	ret    

00801fcc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fcc:	55                   	push   %ebp
  801fcd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fcf:	b8 00 00 00 00       	mov    $0x0,%eax
  801fd4:	5d                   	pop    %ebp
  801fd5:	c3                   	ret    

00801fd6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fd6:	55                   	push   %ebp
  801fd7:	89 e5                	mov    %esp,%ebp
  801fd9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801fdc:	68 df 2a 80 00       	push   $0x802adf
  801fe1:	ff 75 0c             	pushl  0xc(%ebp)
  801fe4:	e8 7f e7 ff ff       	call   800768 <strcpy>
	return 0;
}
  801fe9:	b8 00 00 00 00       	mov    $0x0,%eax
  801fee:	c9                   	leave  
  801fef:	c3                   	ret    

00801ff0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	57                   	push   %edi
  801ff4:	56                   	push   %esi
  801ff5:	53                   	push   %ebx
  801ff6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ffc:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802001:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802007:	eb 2d                	jmp    802036 <devcons_write+0x46>
		m = n - tot;
  802009:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80200c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80200e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802011:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802016:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802019:	83 ec 04             	sub    $0x4,%esp
  80201c:	53                   	push   %ebx
  80201d:	03 45 0c             	add    0xc(%ebp),%eax
  802020:	50                   	push   %eax
  802021:	57                   	push   %edi
  802022:	e8 d3 e8 ff ff       	call   8008fa <memmove>
		sys_cputs(buf, m);
  802027:	83 c4 08             	add    $0x8,%esp
  80202a:	53                   	push   %ebx
  80202b:	57                   	push   %edi
  80202c:	e8 7e ea ff ff       	call   800aaf <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802031:	01 de                	add    %ebx,%esi
  802033:	83 c4 10             	add    $0x10,%esp
  802036:	89 f0                	mov    %esi,%eax
  802038:	3b 75 10             	cmp    0x10(%ebp),%esi
  80203b:	72 cc                	jb     802009 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80203d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802040:	5b                   	pop    %ebx
  802041:	5e                   	pop    %esi
  802042:	5f                   	pop    %edi
  802043:	5d                   	pop    %ebp
  802044:	c3                   	ret    

00802045 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802045:	55                   	push   %ebp
  802046:	89 e5                	mov    %esp,%ebp
  802048:	83 ec 08             	sub    $0x8,%esp
  80204b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802050:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802054:	74 2a                	je     802080 <devcons_read+0x3b>
  802056:	eb 05                	jmp    80205d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802058:	e8 ef ea ff ff       	call   800b4c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80205d:	e8 6b ea ff ff       	call   800acd <sys_cgetc>
  802062:	85 c0                	test   %eax,%eax
  802064:	74 f2                	je     802058 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802066:	85 c0                	test   %eax,%eax
  802068:	78 16                	js     802080 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80206a:	83 f8 04             	cmp    $0x4,%eax
  80206d:	74 0c                	je     80207b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80206f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802072:	88 02                	mov    %al,(%edx)
	return 1;
  802074:	b8 01 00 00 00       	mov    $0x1,%eax
  802079:	eb 05                	jmp    802080 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80207b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802080:	c9                   	leave  
  802081:	c3                   	ret    

00802082 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802082:	55                   	push   %ebp
  802083:	89 e5                	mov    %esp,%ebp
  802085:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802088:	8b 45 08             	mov    0x8(%ebp),%eax
  80208b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80208e:	6a 01                	push   $0x1
  802090:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802093:	50                   	push   %eax
  802094:	e8 16 ea ff ff       	call   800aaf <sys_cputs>
}
  802099:	83 c4 10             	add    $0x10,%esp
  80209c:	c9                   	leave  
  80209d:	c3                   	ret    

0080209e <getchar>:

int
getchar(void)
{
  80209e:	55                   	push   %ebp
  80209f:	89 e5                	mov    %esp,%ebp
  8020a1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020a4:	6a 01                	push   $0x1
  8020a6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020a9:	50                   	push   %eax
  8020aa:	6a 00                	push   $0x0
  8020ac:	e8 36 f2 ff ff       	call   8012e7 <read>
	if (r < 0)
  8020b1:	83 c4 10             	add    $0x10,%esp
  8020b4:	85 c0                	test   %eax,%eax
  8020b6:	78 0f                	js     8020c7 <getchar+0x29>
		return r;
	if (r < 1)
  8020b8:	85 c0                	test   %eax,%eax
  8020ba:	7e 06                	jle    8020c2 <getchar+0x24>
		return -E_EOF;
	return c;
  8020bc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020c0:	eb 05                	jmp    8020c7 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020c2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020c7:	c9                   	leave  
  8020c8:	c3                   	ret    

008020c9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020c9:	55                   	push   %ebp
  8020ca:	89 e5                	mov    %esp,%ebp
  8020cc:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020d2:	50                   	push   %eax
  8020d3:	ff 75 08             	pushl  0x8(%ebp)
  8020d6:	e8 a6 ef ff ff       	call   801081 <fd_lookup>
  8020db:	83 c4 10             	add    $0x10,%esp
  8020de:	85 c0                	test   %eax,%eax
  8020e0:	78 11                	js     8020f3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e5:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8020eb:	39 10                	cmp    %edx,(%eax)
  8020ed:	0f 94 c0             	sete   %al
  8020f0:	0f b6 c0             	movzbl %al,%eax
}
  8020f3:	c9                   	leave  
  8020f4:	c3                   	ret    

008020f5 <opencons>:

int
opencons(void)
{
  8020f5:	55                   	push   %ebp
  8020f6:	89 e5                	mov    %esp,%ebp
  8020f8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020fe:	50                   	push   %eax
  8020ff:	e8 2e ef ff ff       	call   801032 <fd_alloc>
  802104:	83 c4 10             	add    $0x10,%esp
		return r;
  802107:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802109:	85 c0                	test   %eax,%eax
  80210b:	78 3e                	js     80214b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80210d:	83 ec 04             	sub    $0x4,%esp
  802110:	68 07 04 00 00       	push   $0x407
  802115:	ff 75 f4             	pushl  -0xc(%ebp)
  802118:	6a 00                	push   $0x0
  80211a:	e8 4c ea ff ff       	call   800b6b <sys_page_alloc>
  80211f:	83 c4 10             	add    $0x10,%esp
		return r;
  802122:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802124:	85 c0                	test   %eax,%eax
  802126:	78 23                	js     80214b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802128:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80212e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802131:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802133:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802136:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80213d:	83 ec 0c             	sub    $0xc,%esp
  802140:	50                   	push   %eax
  802141:	e8 c5 ee ff ff       	call   80100b <fd2num>
  802146:	89 c2                	mov    %eax,%edx
  802148:	83 c4 10             	add    $0x10,%esp
}
  80214b:	89 d0                	mov    %edx,%eax
  80214d:	c9                   	leave  
  80214e:	c3                   	ret    

0080214f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80214f:	55                   	push   %ebp
  802150:	89 e5                	mov    %esp,%ebp
  802152:	56                   	push   %esi
  802153:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802154:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802157:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80215d:	e8 cb e9 ff ff       	call   800b2d <sys_getenvid>
  802162:	83 ec 0c             	sub    $0xc,%esp
  802165:	ff 75 0c             	pushl  0xc(%ebp)
  802168:	ff 75 08             	pushl  0x8(%ebp)
  80216b:	56                   	push   %esi
  80216c:	50                   	push   %eax
  80216d:	68 ec 2a 80 00       	push   $0x802aec
  802172:	e8 6c e0 ff ff       	call   8001e3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802177:	83 c4 18             	add    $0x18,%esp
  80217a:	53                   	push   %ebx
  80217b:	ff 75 10             	pushl  0x10(%ebp)
  80217e:	e8 0f e0 ff ff       	call   800192 <vcprintf>
	cprintf("\n");
  802183:	c7 04 24 cf 25 80 00 	movl   $0x8025cf,(%esp)
  80218a:	e8 54 e0 ff ff       	call   8001e3 <cprintf>
  80218f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802192:	cc                   	int3   
  802193:	eb fd                	jmp    802192 <_panic+0x43>

00802195 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802195:	55                   	push   %ebp
  802196:	89 e5                	mov    %esp,%ebp
  802198:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80219b:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8021a2:	75 2e                	jne    8021d2 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8021a4:	e8 84 e9 ff ff       	call   800b2d <sys_getenvid>
  8021a9:	83 ec 04             	sub    $0x4,%esp
  8021ac:	68 07 0e 00 00       	push   $0xe07
  8021b1:	68 00 f0 bf ee       	push   $0xeebff000
  8021b6:	50                   	push   %eax
  8021b7:	e8 af e9 ff ff       	call   800b6b <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8021bc:	e8 6c e9 ff ff       	call   800b2d <sys_getenvid>
  8021c1:	83 c4 08             	add    $0x8,%esp
  8021c4:	68 dc 21 80 00       	push   $0x8021dc
  8021c9:	50                   	push   %eax
  8021ca:	e8 e7 ea ff ff       	call   800cb6 <sys_env_set_pgfault_upcall>
  8021cf:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d5:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8021da:	c9                   	leave  
  8021db:	c3                   	ret    

008021dc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8021dc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8021dd:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8021e2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8021e4:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  8021e7:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  8021eb:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  8021ef:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  8021f2:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  8021f5:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  8021f6:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  8021f9:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  8021fa:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  8021fb:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  8021ff:	c3                   	ret    

00802200 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802200:	55                   	push   %ebp
  802201:	89 e5                	mov    %esp,%ebp
  802203:	56                   	push   %esi
  802204:	53                   	push   %ebx
  802205:	8b 75 08             	mov    0x8(%ebp),%esi
  802208:	8b 45 0c             	mov    0xc(%ebp),%eax
  80220b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  80220e:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802210:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802215:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802218:	83 ec 0c             	sub    $0xc,%esp
  80221b:	50                   	push   %eax
  80221c:	e8 fa ea ff ff       	call   800d1b <sys_ipc_recv>

	if (from_env_store != NULL)
  802221:	83 c4 10             	add    $0x10,%esp
  802224:	85 f6                	test   %esi,%esi
  802226:	74 14                	je     80223c <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802228:	ba 00 00 00 00       	mov    $0x0,%edx
  80222d:	85 c0                	test   %eax,%eax
  80222f:	78 09                	js     80223a <ipc_recv+0x3a>
  802231:	8b 15 08 40 80 00    	mov    0x804008,%edx
  802237:	8b 52 74             	mov    0x74(%edx),%edx
  80223a:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  80223c:	85 db                	test   %ebx,%ebx
  80223e:	74 14                	je     802254 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802240:	ba 00 00 00 00       	mov    $0x0,%edx
  802245:	85 c0                	test   %eax,%eax
  802247:	78 09                	js     802252 <ipc_recv+0x52>
  802249:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80224f:	8b 52 78             	mov    0x78(%edx),%edx
  802252:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802254:	85 c0                	test   %eax,%eax
  802256:	78 08                	js     802260 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802258:	a1 08 40 80 00       	mov    0x804008,%eax
  80225d:	8b 40 70             	mov    0x70(%eax),%eax
}
  802260:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802263:	5b                   	pop    %ebx
  802264:	5e                   	pop    %esi
  802265:	5d                   	pop    %ebp
  802266:	c3                   	ret    

00802267 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802267:	55                   	push   %ebp
  802268:	89 e5                	mov    %esp,%ebp
  80226a:	57                   	push   %edi
  80226b:	56                   	push   %esi
  80226c:	53                   	push   %ebx
  80226d:	83 ec 0c             	sub    $0xc,%esp
  802270:	8b 7d 08             	mov    0x8(%ebp),%edi
  802273:	8b 75 0c             	mov    0xc(%ebp),%esi
  802276:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  802279:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  80227b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802280:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  802283:	ff 75 14             	pushl  0x14(%ebp)
  802286:	53                   	push   %ebx
  802287:	56                   	push   %esi
  802288:	57                   	push   %edi
  802289:	e8 6a ea ff ff       	call   800cf8 <sys_ipc_try_send>

		if (err < 0) {
  80228e:	83 c4 10             	add    $0x10,%esp
  802291:	85 c0                	test   %eax,%eax
  802293:	79 1e                	jns    8022b3 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802295:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802298:	75 07                	jne    8022a1 <ipc_send+0x3a>
				sys_yield();
  80229a:	e8 ad e8 ff ff       	call   800b4c <sys_yield>
  80229f:	eb e2                	jmp    802283 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8022a1:	50                   	push   %eax
  8022a2:	68 10 2b 80 00       	push   $0x802b10
  8022a7:	6a 49                	push   $0x49
  8022a9:	68 1d 2b 80 00       	push   $0x802b1d
  8022ae:	e8 9c fe ff ff       	call   80214f <_panic>
		}

	} while (err < 0);

}
  8022b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022b6:	5b                   	pop    %ebx
  8022b7:	5e                   	pop    %esi
  8022b8:	5f                   	pop    %edi
  8022b9:	5d                   	pop    %ebp
  8022ba:	c3                   	ret    

008022bb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022bb:	55                   	push   %ebp
  8022bc:	89 e5                	mov    %esp,%ebp
  8022be:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8022c1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022c6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8022c9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022cf:	8b 52 50             	mov    0x50(%edx),%edx
  8022d2:	39 ca                	cmp    %ecx,%edx
  8022d4:	75 0d                	jne    8022e3 <ipc_find_env+0x28>
			return envs[i].env_id;
  8022d6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8022d9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8022de:	8b 40 48             	mov    0x48(%eax),%eax
  8022e1:	eb 0f                	jmp    8022f2 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022e3:	83 c0 01             	add    $0x1,%eax
  8022e6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022eb:	75 d9                	jne    8022c6 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022f2:	5d                   	pop    %ebp
  8022f3:	c3                   	ret    

008022f4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022f4:	55                   	push   %ebp
  8022f5:	89 e5                	mov    %esp,%ebp
  8022f7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022fa:	89 d0                	mov    %edx,%eax
  8022fc:	c1 e8 16             	shr    $0x16,%eax
  8022ff:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802306:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80230b:	f6 c1 01             	test   $0x1,%cl
  80230e:	74 1d                	je     80232d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802310:	c1 ea 0c             	shr    $0xc,%edx
  802313:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80231a:	f6 c2 01             	test   $0x1,%dl
  80231d:	74 0e                	je     80232d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80231f:	c1 ea 0c             	shr    $0xc,%edx
  802322:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802329:	ef 
  80232a:	0f b7 c0             	movzwl %ax,%eax
}
  80232d:	5d                   	pop    %ebp
  80232e:	c3                   	ret    
  80232f:	90                   	nop

00802330 <__udivdi3>:
  802330:	55                   	push   %ebp
  802331:	57                   	push   %edi
  802332:	56                   	push   %esi
  802333:	53                   	push   %ebx
  802334:	83 ec 1c             	sub    $0x1c,%esp
  802337:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80233b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80233f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802343:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802347:	85 f6                	test   %esi,%esi
  802349:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80234d:	89 ca                	mov    %ecx,%edx
  80234f:	89 f8                	mov    %edi,%eax
  802351:	75 3d                	jne    802390 <__udivdi3+0x60>
  802353:	39 cf                	cmp    %ecx,%edi
  802355:	0f 87 c5 00 00 00    	ja     802420 <__udivdi3+0xf0>
  80235b:	85 ff                	test   %edi,%edi
  80235d:	89 fd                	mov    %edi,%ebp
  80235f:	75 0b                	jne    80236c <__udivdi3+0x3c>
  802361:	b8 01 00 00 00       	mov    $0x1,%eax
  802366:	31 d2                	xor    %edx,%edx
  802368:	f7 f7                	div    %edi
  80236a:	89 c5                	mov    %eax,%ebp
  80236c:	89 c8                	mov    %ecx,%eax
  80236e:	31 d2                	xor    %edx,%edx
  802370:	f7 f5                	div    %ebp
  802372:	89 c1                	mov    %eax,%ecx
  802374:	89 d8                	mov    %ebx,%eax
  802376:	89 cf                	mov    %ecx,%edi
  802378:	f7 f5                	div    %ebp
  80237a:	89 c3                	mov    %eax,%ebx
  80237c:	89 d8                	mov    %ebx,%eax
  80237e:	89 fa                	mov    %edi,%edx
  802380:	83 c4 1c             	add    $0x1c,%esp
  802383:	5b                   	pop    %ebx
  802384:	5e                   	pop    %esi
  802385:	5f                   	pop    %edi
  802386:	5d                   	pop    %ebp
  802387:	c3                   	ret    
  802388:	90                   	nop
  802389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802390:	39 ce                	cmp    %ecx,%esi
  802392:	77 74                	ja     802408 <__udivdi3+0xd8>
  802394:	0f bd fe             	bsr    %esi,%edi
  802397:	83 f7 1f             	xor    $0x1f,%edi
  80239a:	0f 84 98 00 00 00    	je     802438 <__udivdi3+0x108>
  8023a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8023a5:	89 f9                	mov    %edi,%ecx
  8023a7:	89 c5                	mov    %eax,%ebp
  8023a9:	29 fb                	sub    %edi,%ebx
  8023ab:	d3 e6                	shl    %cl,%esi
  8023ad:	89 d9                	mov    %ebx,%ecx
  8023af:	d3 ed                	shr    %cl,%ebp
  8023b1:	89 f9                	mov    %edi,%ecx
  8023b3:	d3 e0                	shl    %cl,%eax
  8023b5:	09 ee                	or     %ebp,%esi
  8023b7:	89 d9                	mov    %ebx,%ecx
  8023b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023bd:	89 d5                	mov    %edx,%ebp
  8023bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023c3:	d3 ed                	shr    %cl,%ebp
  8023c5:	89 f9                	mov    %edi,%ecx
  8023c7:	d3 e2                	shl    %cl,%edx
  8023c9:	89 d9                	mov    %ebx,%ecx
  8023cb:	d3 e8                	shr    %cl,%eax
  8023cd:	09 c2                	or     %eax,%edx
  8023cf:	89 d0                	mov    %edx,%eax
  8023d1:	89 ea                	mov    %ebp,%edx
  8023d3:	f7 f6                	div    %esi
  8023d5:	89 d5                	mov    %edx,%ebp
  8023d7:	89 c3                	mov    %eax,%ebx
  8023d9:	f7 64 24 0c          	mull   0xc(%esp)
  8023dd:	39 d5                	cmp    %edx,%ebp
  8023df:	72 10                	jb     8023f1 <__udivdi3+0xc1>
  8023e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8023e5:	89 f9                	mov    %edi,%ecx
  8023e7:	d3 e6                	shl    %cl,%esi
  8023e9:	39 c6                	cmp    %eax,%esi
  8023eb:	73 07                	jae    8023f4 <__udivdi3+0xc4>
  8023ed:	39 d5                	cmp    %edx,%ebp
  8023ef:	75 03                	jne    8023f4 <__udivdi3+0xc4>
  8023f1:	83 eb 01             	sub    $0x1,%ebx
  8023f4:	31 ff                	xor    %edi,%edi
  8023f6:	89 d8                	mov    %ebx,%eax
  8023f8:	89 fa                	mov    %edi,%edx
  8023fa:	83 c4 1c             	add    $0x1c,%esp
  8023fd:	5b                   	pop    %ebx
  8023fe:	5e                   	pop    %esi
  8023ff:	5f                   	pop    %edi
  802400:	5d                   	pop    %ebp
  802401:	c3                   	ret    
  802402:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802408:	31 ff                	xor    %edi,%edi
  80240a:	31 db                	xor    %ebx,%ebx
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
  802420:	89 d8                	mov    %ebx,%eax
  802422:	f7 f7                	div    %edi
  802424:	31 ff                	xor    %edi,%edi
  802426:	89 c3                	mov    %eax,%ebx
  802428:	89 d8                	mov    %ebx,%eax
  80242a:	89 fa                	mov    %edi,%edx
  80242c:	83 c4 1c             	add    $0x1c,%esp
  80242f:	5b                   	pop    %ebx
  802430:	5e                   	pop    %esi
  802431:	5f                   	pop    %edi
  802432:	5d                   	pop    %ebp
  802433:	c3                   	ret    
  802434:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802438:	39 ce                	cmp    %ecx,%esi
  80243a:	72 0c                	jb     802448 <__udivdi3+0x118>
  80243c:	31 db                	xor    %ebx,%ebx
  80243e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802442:	0f 87 34 ff ff ff    	ja     80237c <__udivdi3+0x4c>
  802448:	bb 01 00 00 00       	mov    $0x1,%ebx
  80244d:	e9 2a ff ff ff       	jmp    80237c <__udivdi3+0x4c>
  802452:	66 90                	xchg   %ax,%ax
  802454:	66 90                	xchg   %ax,%ax
  802456:	66 90                	xchg   %ax,%ax
  802458:	66 90                	xchg   %ax,%ax
  80245a:	66 90                	xchg   %ax,%ax
  80245c:	66 90                	xchg   %ax,%ax
  80245e:	66 90                	xchg   %ax,%ax

00802460 <__umoddi3>:
  802460:	55                   	push   %ebp
  802461:	57                   	push   %edi
  802462:	56                   	push   %esi
  802463:	53                   	push   %ebx
  802464:	83 ec 1c             	sub    $0x1c,%esp
  802467:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80246b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80246f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802473:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802477:	85 d2                	test   %edx,%edx
  802479:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80247d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802481:	89 f3                	mov    %esi,%ebx
  802483:	89 3c 24             	mov    %edi,(%esp)
  802486:	89 74 24 04          	mov    %esi,0x4(%esp)
  80248a:	75 1c                	jne    8024a8 <__umoddi3+0x48>
  80248c:	39 f7                	cmp    %esi,%edi
  80248e:	76 50                	jbe    8024e0 <__umoddi3+0x80>
  802490:	89 c8                	mov    %ecx,%eax
  802492:	89 f2                	mov    %esi,%edx
  802494:	f7 f7                	div    %edi
  802496:	89 d0                	mov    %edx,%eax
  802498:	31 d2                	xor    %edx,%edx
  80249a:	83 c4 1c             	add    $0x1c,%esp
  80249d:	5b                   	pop    %ebx
  80249e:	5e                   	pop    %esi
  80249f:	5f                   	pop    %edi
  8024a0:	5d                   	pop    %ebp
  8024a1:	c3                   	ret    
  8024a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024a8:	39 f2                	cmp    %esi,%edx
  8024aa:	89 d0                	mov    %edx,%eax
  8024ac:	77 52                	ja     802500 <__umoddi3+0xa0>
  8024ae:	0f bd ea             	bsr    %edx,%ebp
  8024b1:	83 f5 1f             	xor    $0x1f,%ebp
  8024b4:	75 5a                	jne    802510 <__umoddi3+0xb0>
  8024b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8024ba:	0f 82 e0 00 00 00    	jb     8025a0 <__umoddi3+0x140>
  8024c0:	39 0c 24             	cmp    %ecx,(%esp)
  8024c3:	0f 86 d7 00 00 00    	jbe    8025a0 <__umoddi3+0x140>
  8024c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024d1:	83 c4 1c             	add    $0x1c,%esp
  8024d4:	5b                   	pop    %ebx
  8024d5:	5e                   	pop    %esi
  8024d6:	5f                   	pop    %edi
  8024d7:	5d                   	pop    %ebp
  8024d8:	c3                   	ret    
  8024d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024e0:	85 ff                	test   %edi,%edi
  8024e2:	89 fd                	mov    %edi,%ebp
  8024e4:	75 0b                	jne    8024f1 <__umoddi3+0x91>
  8024e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024eb:	31 d2                	xor    %edx,%edx
  8024ed:	f7 f7                	div    %edi
  8024ef:	89 c5                	mov    %eax,%ebp
  8024f1:	89 f0                	mov    %esi,%eax
  8024f3:	31 d2                	xor    %edx,%edx
  8024f5:	f7 f5                	div    %ebp
  8024f7:	89 c8                	mov    %ecx,%eax
  8024f9:	f7 f5                	div    %ebp
  8024fb:	89 d0                	mov    %edx,%eax
  8024fd:	eb 99                	jmp    802498 <__umoddi3+0x38>
  8024ff:	90                   	nop
  802500:	89 c8                	mov    %ecx,%eax
  802502:	89 f2                	mov    %esi,%edx
  802504:	83 c4 1c             	add    $0x1c,%esp
  802507:	5b                   	pop    %ebx
  802508:	5e                   	pop    %esi
  802509:	5f                   	pop    %edi
  80250a:	5d                   	pop    %ebp
  80250b:	c3                   	ret    
  80250c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802510:	8b 34 24             	mov    (%esp),%esi
  802513:	bf 20 00 00 00       	mov    $0x20,%edi
  802518:	89 e9                	mov    %ebp,%ecx
  80251a:	29 ef                	sub    %ebp,%edi
  80251c:	d3 e0                	shl    %cl,%eax
  80251e:	89 f9                	mov    %edi,%ecx
  802520:	89 f2                	mov    %esi,%edx
  802522:	d3 ea                	shr    %cl,%edx
  802524:	89 e9                	mov    %ebp,%ecx
  802526:	09 c2                	or     %eax,%edx
  802528:	89 d8                	mov    %ebx,%eax
  80252a:	89 14 24             	mov    %edx,(%esp)
  80252d:	89 f2                	mov    %esi,%edx
  80252f:	d3 e2                	shl    %cl,%edx
  802531:	89 f9                	mov    %edi,%ecx
  802533:	89 54 24 04          	mov    %edx,0x4(%esp)
  802537:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80253b:	d3 e8                	shr    %cl,%eax
  80253d:	89 e9                	mov    %ebp,%ecx
  80253f:	89 c6                	mov    %eax,%esi
  802541:	d3 e3                	shl    %cl,%ebx
  802543:	89 f9                	mov    %edi,%ecx
  802545:	89 d0                	mov    %edx,%eax
  802547:	d3 e8                	shr    %cl,%eax
  802549:	89 e9                	mov    %ebp,%ecx
  80254b:	09 d8                	or     %ebx,%eax
  80254d:	89 d3                	mov    %edx,%ebx
  80254f:	89 f2                	mov    %esi,%edx
  802551:	f7 34 24             	divl   (%esp)
  802554:	89 d6                	mov    %edx,%esi
  802556:	d3 e3                	shl    %cl,%ebx
  802558:	f7 64 24 04          	mull   0x4(%esp)
  80255c:	39 d6                	cmp    %edx,%esi
  80255e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802562:	89 d1                	mov    %edx,%ecx
  802564:	89 c3                	mov    %eax,%ebx
  802566:	72 08                	jb     802570 <__umoddi3+0x110>
  802568:	75 11                	jne    80257b <__umoddi3+0x11b>
  80256a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80256e:	73 0b                	jae    80257b <__umoddi3+0x11b>
  802570:	2b 44 24 04          	sub    0x4(%esp),%eax
  802574:	1b 14 24             	sbb    (%esp),%edx
  802577:	89 d1                	mov    %edx,%ecx
  802579:	89 c3                	mov    %eax,%ebx
  80257b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80257f:	29 da                	sub    %ebx,%edx
  802581:	19 ce                	sbb    %ecx,%esi
  802583:	89 f9                	mov    %edi,%ecx
  802585:	89 f0                	mov    %esi,%eax
  802587:	d3 e0                	shl    %cl,%eax
  802589:	89 e9                	mov    %ebp,%ecx
  80258b:	d3 ea                	shr    %cl,%edx
  80258d:	89 e9                	mov    %ebp,%ecx
  80258f:	d3 ee                	shr    %cl,%esi
  802591:	09 d0                	or     %edx,%eax
  802593:	89 f2                	mov    %esi,%edx
  802595:	83 c4 1c             	add    $0x1c,%esp
  802598:	5b                   	pop    %ebx
  802599:	5e                   	pop    %esi
  80259a:	5f                   	pop    %edi
  80259b:	5d                   	pop    %ebp
  80259c:	c3                   	ret    
  80259d:	8d 76 00             	lea    0x0(%esi),%esi
  8025a0:	29 f9                	sub    %edi,%ecx
  8025a2:	19 d6                	sbb    %edx,%esi
  8025a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025ac:	e9 18 ff ff ff       	jmp    8024c9 <__umoddi3+0x69>
