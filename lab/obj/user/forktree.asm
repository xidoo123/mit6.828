
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
  800047:	68 20 26 80 00       	push   $0x802620
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
  8000a4:	68 31 26 80 00       	push   $0x802631
  8000a9:	6a 04                	push   $0x4
  8000ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000ae:	50                   	push   %eax
  8000af:	e8 61 06 00 00       	call   800715 <snprintf>
	// cprintf("%s, %s\n", cur, nxt);
	if (fork() == 0) {
  8000b4:	83 c4 20             	add    $0x20,%esp
  8000b7:	e8 da 0d 00 00       	call   800e96 <fork>
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
  8000e1:	68 30 26 80 00       	push   $0x802630
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
  80013c:	e8 d7 10 00 00       	call   801218 <close_all>
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
  800246:	e8 35 21 00 00       	call   802380 <__udivdi3>
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
  800289:	e8 22 22 00 00       	call   8024b0 <__umoddi3>
  80028e:	83 c4 14             	add    $0x14,%esp
  800291:	0f be 80 40 26 80 00 	movsbl 0x802640(%eax),%eax
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
  80038d:	ff 24 85 80 27 80 00 	jmp    *0x802780(,%eax,4)
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
  800451:	8b 14 85 e0 28 80 00 	mov    0x8028e0(,%eax,4),%edx
  800458:	85 d2                	test   %edx,%edx
  80045a:	75 18                	jne    800474 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80045c:	50                   	push   %eax
  80045d:	68 58 26 80 00       	push   $0x802658
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
  800475:	68 cd 2a 80 00       	push   $0x802acd
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
  800499:	b8 51 26 80 00       	mov    $0x802651,%eax
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
  800b14:	68 3f 29 80 00       	push   $0x80293f
  800b19:	6a 23                	push   $0x23
  800b1b:	68 5c 29 80 00       	push   $0x80295c
  800b20:	e8 6c 16 00 00       	call   802191 <_panic>

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
  800b95:	68 3f 29 80 00       	push   $0x80293f
  800b9a:	6a 23                	push   $0x23
  800b9c:	68 5c 29 80 00       	push   $0x80295c
  800ba1:	e8 eb 15 00 00       	call   802191 <_panic>

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
  800bd7:	68 3f 29 80 00       	push   $0x80293f
  800bdc:	6a 23                	push   $0x23
  800bde:	68 5c 29 80 00       	push   $0x80295c
  800be3:	e8 a9 15 00 00       	call   802191 <_panic>

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
  800c19:	68 3f 29 80 00       	push   $0x80293f
  800c1e:	6a 23                	push   $0x23
  800c20:	68 5c 29 80 00       	push   $0x80295c
  800c25:	e8 67 15 00 00       	call   802191 <_panic>

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
  800c5b:	68 3f 29 80 00       	push   $0x80293f
  800c60:	6a 23                	push   $0x23
  800c62:	68 5c 29 80 00       	push   $0x80295c
  800c67:	e8 25 15 00 00       	call   802191 <_panic>

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
  800c9d:	68 3f 29 80 00       	push   $0x80293f
  800ca2:	6a 23                	push   $0x23
  800ca4:	68 5c 29 80 00       	push   $0x80295c
  800ca9:	e8 e3 14 00 00       	call   802191 <_panic>

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
  800cdf:	68 3f 29 80 00       	push   $0x80293f
  800ce4:	6a 23                	push   $0x23
  800ce6:	68 5c 29 80 00       	push   $0x80295c
  800ceb:	e8 a1 14 00 00       	call   802191 <_panic>

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
  800d43:	68 3f 29 80 00       	push   $0x80293f
  800d48:	6a 23                	push   $0x23
  800d4a:	68 5c 29 80 00       	push   $0x80295c
  800d4f:	e8 3d 14 00 00       	call   802191 <_panic>

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
  800da4:	68 3f 29 80 00       	push   $0x80293f
  800da9:	6a 23                	push   $0x23
  800dab:	68 5c 29 80 00       	push   $0x80295c
  800db0:	e8 dc 13 00 00       	call   802191 <_panic>

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

00800dbd <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	56                   	push   %esi
  800dc1:	53                   	push   %ebx
  800dc2:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dc5:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800dc7:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dcb:	75 25                	jne    800df2 <pgfault+0x35>
  800dcd:	89 d8                	mov    %ebx,%eax
  800dcf:	c1 e8 0c             	shr    $0xc,%eax
  800dd2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dd9:	f6 c4 08             	test   $0x8,%ah
  800ddc:	75 14                	jne    800df2 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800dde:	83 ec 04             	sub    $0x4,%esp
  800de1:	68 6c 29 80 00       	push   $0x80296c
  800de6:	6a 1e                	push   $0x1e
  800de8:	68 00 2a 80 00       	push   $0x802a00
  800ded:	e8 9f 13 00 00       	call   802191 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800df2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800df8:	e8 30 fd ff ff       	call   800b2d <sys_getenvid>
  800dfd:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800dff:	83 ec 04             	sub    $0x4,%esp
  800e02:	6a 07                	push   $0x7
  800e04:	68 00 f0 7f 00       	push   $0x7ff000
  800e09:	50                   	push   %eax
  800e0a:	e8 5c fd ff ff       	call   800b6b <sys_page_alloc>
	if (r < 0)
  800e0f:	83 c4 10             	add    $0x10,%esp
  800e12:	85 c0                	test   %eax,%eax
  800e14:	79 12                	jns    800e28 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800e16:	50                   	push   %eax
  800e17:	68 98 29 80 00       	push   $0x802998
  800e1c:	6a 33                	push   $0x33
  800e1e:	68 00 2a 80 00       	push   $0x802a00
  800e23:	e8 69 13 00 00       	call   802191 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800e28:	83 ec 04             	sub    $0x4,%esp
  800e2b:	68 00 10 00 00       	push   $0x1000
  800e30:	53                   	push   %ebx
  800e31:	68 00 f0 7f 00       	push   $0x7ff000
  800e36:	e8 27 fb ff ff       	call   800962 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800e3b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e42:	53                   	push   %ebx
  800e43:	56                   	push   %esi
  800e44:	68 00 f0 7f 00       	push   $0x7ff000
  800e49:	56                   	push   %esi
  800e4a:	e8 5f fd ff ff       	call   800bae <sys_page_map>
	if (r < 0)
  800e4f:	83 c4 20             	add    $0x20,%esp
  800e52:	85 c0                	test   %eax,%eax
  800e54:	79 12                	jns    800e68 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800e56:	50                   	push   %eax
  800e57:	68 bc 29 80 00       	push   $0x8029bc
  800e5c:	6a 3b                	push   $0x3b
  800e5e:	68 00 2a 80 00       	push   $0x802a00
  800e63:	e8 29 13 00 00       	call   802191 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800e68:	83 ec 08             	sub    $0x8,%esp
  800e6b:	68 00 f0 7f 00       	push   $0x7ff000
  800e70:	56                   	push   %esi
  800e71:	e8 7a fd ff ff       	call   800bf0 <sys_page_unmap>
	if (r < 0)
  800e76:	83 c4 10             	add    $0x10,%esp
  800e79:	85 c0                	test   %eax,%eax
  800e7b:	79 12                	jns    800e8f <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800e7d:	50                   	push   %eax
  800e7e:	68 e0 29 80 00       	push   $0x8029e0
  800e83:	6a 40                	push   $0x40
  800e85:	68 00 2a 80 00       	push   $0x802a00
  800e8a:	e8 02 13 00 00       	call   802191 <_panic>
}
  800e8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e92:	5b                   	pop    %ebx
  800e93:	5e                   	pop    %esi
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	57                   	push   %edi
  800e9a:	56                   	push   %esi
  800e9b:	53                   	push   %ebx
  800e9c:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800e9f:	68 bd 0d 80 00       	push   $0x800dbd
  800ea4:	e8 2e 13 00 00       	call   8021d7 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ea9:	b8 07 00 00 00       	mov    $0x7,%eax
  800eae:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800eb0:	83 c4 10             	add    $0x10,%esp
  800eb3:	85 c0                	test   %eax,%eax
  800eb5:	0f 88 64 01 00 00    	js     80101f <fork+0x189>
  800ebb:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800ec0:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800ec5:	85 c0                	test   %eax,%eax
  800ec7:	75 21                	jne    800eea <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ec9:	e8 5f fc ff ff       	call   800b2d <sys_getenvid>
  800ece:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ed3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ed6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800edb:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  800ee0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ee5:	e9 3f 01 00 00       	jmp    801029 <fork+0x193>
  800eea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800eed:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800eef:	89 d8                	mov    %ebx,%eax
  800ef1:	c1 e8 16             	shr    $0x16,%eax
  800ef4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800efb:	a8 01                	test   $0x1,%al
  800efd:	0f 84 bd 00 00 00    	je     800fc0 <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800f03:	89 d8                	mov    %ebx,%eax
  800f05:	c1 e8 0c             	shr    $0xc,%eax
  800f08:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f0f:	f6 c2 01             	test   $0x1,%dl
  800f12:	0f 84 a8 00 00 00    	je     800fc0 <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  800f18:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f1f:	a8 04                	test   $0x4,%al
  800f21:	0f 84 99 00 00 00    	je     800fc0 <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800f27:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f2e:	f6 c4 04             	test   $0x4,%ah
  800f31:	74 17                	je     800f4a <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800f33:	83 ec 0c             	sub    $0xc,%esp
  800f36:	68 07 0e 00 00       	push   $0xe07
  800f3b:	53                   	push   %ebx
  800f3c:	57                   	push   %edi
  800f3d:	53                   	push   %ebx
  800f3e:	6a 00                	push   $0x0
  800f40:	e8 69 fc ff ff       	call   800bae <sys_page_map>
  800f45:	83 c4 20             	add    $0x20,%esp
  800f48:	eb 76                	jmp    800fc0 <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f4a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f51:	a8 02                	test   $0x2,%al
  800f53:	75 0c                	jne    800f61 <fork+0xcb>
  800f55:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f5c:	f6 c4 08             	test   $0x8,%ah
  800f5f:	74 3f                	je     800fa0 <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f61:	83 ec 0c             	sub    $0xc,%esp
  800f64:	68 05 08 00 00       	push   $0x805
  800f69:	53                   	push   %ebx
  800f6a:	57                   	push   %edi
  800f6b:	53                   	push   %ebx
  800f6c:	6a 00                	push   $0x0
  800f6e:	e8 3b fc ff ff       	call   800bae <sys_page_map>
		if (r < 0)
  800f73:	83 c4 20             	add    $0x20,%esp
  800f76:	85 c0                	test   %eax,%eax
  800f78:	0f 88 a5 00 00 00    	js     801023 <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f7e:	83 ec 0c             	sub    $0xc,%esp
  800f81:	68 05 08 00 00       	push   $0x805
  800f86:	53                   	push   %ebx
  800f87:	6a 00                	push   $0x0
  800f89:	53                   	push   %ebx
  800f8a:	6a 00                	push   $0x0
  800f8c:	e8 1d fc ff ff       	call   800bae <sys_page_map>
  800f91:	83 c4 20             	add    $0x20,%esp
  800f94:	85 c0                	test   %eax,%eax
  800f96:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f9b:	0f 4f c1             	cmovg  %ecx,%eax
  800f9e:	eb 1c                	jmp    800fbc <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800fa0:	83 ec 0c             	sub    $0xc,%esp
  800fa3:	6a 05                	push   $0x5
  800fa5:	53                   	push   %ebx
  800fa6:	57                   	push   %edi
  800fa7:	53                   	push   %ebx
  800fa8:	6a 00                	push   $0x0
  800faa:	e8 ff fb ff ff       	call   800bae <sys_page_map>
  800faf:	83 c4 20             	add    $0x20,%esp
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fb9:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  800fbc:	85 c0                	test   %eax,%eax
  800fbe:	78 67                	js     801027 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  800fc0:	83 c6 01             	add    $0x1,%esi
  800fc3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fc9:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  800fcf:	0f 85 1a ff ff ff    	jne    800eef <fork+0x59>
  800fd5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  800fd8:	83 ec 04             	sub    $0x4,%esp
  800fdb:	6a 07                	push   $0x7
  800fdd:	68 00 f0 bf ee       	push   $0xeebff000
  800fe2:	57                   	push   %edi
  800fe3:	e8 83 fb ff ff       	call   800b6b <sys_page_alloc>
	if (r < 0)
  800fe8:	83 c4 10             	add    $0x10,%esp
		return r;
  800feb:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  800fed:	85 c0                	test   %eax,%eax
  800fef:	78 38                	js     801029 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800ff1:	83 ec 08             	sub    $0x8,%esp
  800ff4:	68 1e 22 80 00       	push   $0x80221e
  800ff9:	57                   	push   %edi
  800ffa:	e8 b7 fc ff ff       	call   800cb6 <sys_env_set_pgfault_upcall>
	if (r < 0)
  800fff:	83 c4 10             	add    $0x10,%esp
		return r;
  801002:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  801004:	85 c0                	test   %eax,%eax
  801006:	78 21                	js     801029 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801008:	83 ec 08             	sub    $0x8,%esp
  80100b:	6a 02                	push   $0x2
  80100d:	57                   	push   %edi
  80100e:	e8 1f fc ff ff       	call   800c32 <sys_env_set_status>
	if (r < 0)
  801013:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801016:	85 c0                	test   %eax,%eax
  801018:	0f 48 f8             	cmovs  %eax,%edi
  80101b:	89 fa                	mov    %edi,%edx
  80101d:	eb 0a                	jmp    801029 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  80101f:	89 c2                	mov    %eax,%edx
  801021:	eb 06                	jmp    801029 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801023:	89 c2                	mov    %eax,%edx
  801025:	eb 02                	jmp    801029 <fork+0x193>
  801027:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  801029:	89 d0                	mov    %edx,%eax
  80102b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80102e:	5b                   	pop    %ebx
  80102f:	5e                   	pop    %esi
  801030:	5f                   	pop    %edi
  801031:	5d                   	pop    %ebp
  801032:	c3                   	ret    

00801033 <sfork>:

// Challenge!
int
sfork(void)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801039:	68 0b 2a 80 00       	push   $0x802a0b
  80103e:	68 c9 00 00 00       	push   $0xc9
  801043:	68 00 2a 80 00       	push   $0x802a00
  801048:	e8 44 11 00 00       	call   802191 <_panic>

0080104d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80104d:	55                   	push   %ebp
  80104e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801050:	8b 45 08             	mov    0x8(%ebp),%eax
  801053:	05 00 00 00 30       	add    $0x30000000,%eax
  801058:	c1 e8 0c             	shr    $0xc,%eax
}
  80105b:	5d                   	pop    %ebp
  80105c:	c3                   	ret    

0080105d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801060:	8b 45 08             	mov    0x8(%ebp),%eax
  801063:	05 00 00 00 30       	add    $0x30000000,%eax
  801068:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80106d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801072:	5d                   	pop    %ebp
  801073:	c3                   	ret    

00801074 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80107a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80107f:	89 c2                	mov    %eax,%edx
  801081:	c1 ea 16             	shr    $0x16,%edx
  801084:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80108b:	f6 c2 01             	test   $0x1,%dl
  80108e:	74 11                	je     8010a1 <fd_alloc+0x2d>
  801090:	89 c2                	mov    %eax,%edx
  801092:	c1 ea 0c             	shr    $0xc,%edx
  801095:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80109c:	f6 c2 01             	test   $0x1,%dl
  80109f:	75 09                	jne    8010aa <fd_alloc+0x36>
			*fd_store = fd;
  8010a1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a8:	eb 17                	jmp    8010c1 <fd_alloc+0x4d>
  8010aa:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010af:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010b4:	75 c9                	jne    80107f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010b6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010bc:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010c1:	5d                   	pop    %ebp
  8010c2:	c3                   	ret    

008010c3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010c9:	83 f8 1f             	cmp    $0x1f,%eax
  8010cc:	77 36                	ja     801104 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010ce:	c1 e0 0c             	shl    $0xc,%eax
  8010d1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010d6:	89 c2                	mov    %eax,%edx
  8010d8:	c1 ea 16             	shr    $0x16,%edx
  8010db:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010e2:	f6 c2 01             	test   $0x1,%dl
  8010e5:	74 24                	je     80110b <fd_lookup+0x48>
  8010e7:	89 c2                	mov    %eax,%edx
  8010e9:	c1 ea 0c             	shr    $0xc,%edx
  8010ec:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010f3:	f6 c2 01             	test   $0x1,%dl
  8010f6:	74 1a                	je     801112 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010fb:	89 02                	mov    %eax,(%edx)
	return 0;
  8010fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801102:	eb 13                	jmp    801117 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801104:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801109:	eb 0c                	jmp    801117 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80110b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801110:	eb 05                	jmp    801117 <fd_lookup+0x54>
  801112:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801117:	5d                   	pop    %ebp
  801118:	c3                   	ret    

00801119 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
  80111c:	83 ec 08             	sub    $0x8,%esp
  80111f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801122:	ba a0 2a 80 00       	mov    $0x802aa0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801127:	eb 13                	jmp    80113c <dev_lookup+0x23>
  801129:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80112c:	39 08                	cmp    %ecx,(%eax)
  80112e:	75 0c                	jne    80113c <dev_lookup+0x23>
			*dev = devtab[i];
  801130:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801133:	89 01                	mov    %eax,(%ecx)
			return 0;
  801135:	b8 00 00 00 00       	mov    $0x0,%eax
  80113a:	eb 2e                	jmp    80116a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80113c:	8b 02                	mov    (%edx),%eax
  80113e:	85 c0                	test   %eax,%eax
  801140:	75 e7                	jne    801129 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801142:	a1 08 40 80 00       	mov    0x804008,%eax
  801147:	8b 40 48             	mov    0x48(%eax),%eax
  80114a:	83 ec 04             	sub    $0x4,%esp
  80114d:	51                   	push   %ecx
  80114e:	50                   	push   %eax
  80114f:	68 24 2a 80 00       	push   $0x802a24
  801154:	e8 8a f0 ff ff       	call   8001e3 <cprintf>
	*dev = 0;
  801159:	8b 45 0c             	mov    0xc(%ebp),%eax
  80115c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801162:	83 c4 10             	add    $0x10,%esp
  801165:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80116a:	c9                   	leave  
  80116b:	c3                   	ret    

0080116c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80116c:	55                   	push   %ebp
  80116d:	89 e5                	mov    %esp,%ebp
  80116f:	56                   	push   %esi
  801170:	53                   	push   %ebx
  801171:	83 ec 10             	sub    $0x10,%esp
  801174:	8b 75 08             	mov    0x8(%ebp),%esi
  801177:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80117a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80117d:	50                   	push   %eax
  80117e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801184:	c1 e8 0c             	shr    $0xc,%eax
  801187:	50                   	push   %eax
  801188:	e8 36 ff ff ff       	call   8010c3 <fd_lookup>
  80118d:	83 c4 08             	add    $0x8,%esp
  801190:	85 c0                	test   %eax,%eax
  801192:	78 05                	js     801199 <fd_close+0x2d>
	    || fd != fd2)
  801194:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801197:	74 0c                	je     8011a5 <fd_close+0x39>
		return (must_exist ? r : 0);
  801199:	84 db                	test   %bl,%bl
  80119b:	ba 00 00 00 00       	mov    $0x0,%edx
  8011a0:	0f 44 c2             	cmove  %edx,%eax
  8011a3:	eb 41                	jmp    8011e6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011a5:	83 ec 08             	sub    $0x8,%esp
  8011a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ab:	50                   	push   %eax
  8011ac:	ff 36                	pushl  (%esi)
  8011ae:	e8 66 ff ff ff       	call   801119 <dev_lookup>
  8011b3:	89 c3                	mov    %eax,%ebx
  8011b5:	83 c4 10             	add    $0x10,%esp
  8011b8:	85 c0                	test   %eax,%eax
  8011ba:	78 1a                	js     8011d6 <fd_close+0x6a>
		if (dev->dev_close)
  8011bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011bf:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011c2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011c7:	85 c0                	test   %eax,%eax
  8011c9:	74 0b                	je     8011d6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011cb:	83 ec 0c             	sub    $0xc,%esp
  8011ce:	56                   	push   %esi
  8011cf:	ff d0                	call   *%eax
  8011d1:	89 c3                	mov    %eax,%ebx
  8011d3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011d6:	83 ec 08             	sub    $0x8,%esp
  8011d9:	56                   	push   %esi
  8011da:	6a 00                	push   $0x0
  8011dc:	e8 0f fa ff ff       	call   800bf0 <sys_page_unmap>
	return r;
  8011e1:	83 c4 10             	add    $0x10,%esp
  8011e4:	89 d8                	mov    %ebx,%eax
}
  8011e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011e9:	5b                   	pop    %ebx
  8011ea:	5e                   	pop    %esi
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    

008011ed <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f6:	50                   	push   %eax
  8011f7:	ff 75 08             	pushl  0x8(%ebp)
  8011fa:	e8 c4 fe ff ff       	call   8010c3 <fd_lookup>
  8011ff:	83 c4 08             	add    $0x8,%esp
  801202:	85 c0                	test   %eax,%eax
  801204:	78 10                	js     801216 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801206:	83 ec 08             	sub    $0x8,%esp
  801209:	6a 01                	push   $0x1
  80120b:	ff 75 f4             	pushl  -0xc(%ebp)
  80120e:	e8 59 ff ff ff       	call   80116c <fd_close>
  801213:	83 c4 10             	add    $0x10,%esp
}
  801216:	c9                   	leave  
  801217:	c3                   	ret    

00801218 <close_all>:

void
close_all(void)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	53                   	push   %ebx
  80121c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80121f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801224:	83 ec 0c             	sub    $0xc,%esp
  801227:	53                   	push   %ebx
  801228:	e8 c0 ff ff ff       	call   8011ed <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80122d:	83 c3 01             	add    $0x1,%ebx
  801230:	83 c4 10             	add    $0x10,%esp
  801233:	83 fb 20             	cmp    $0x20,%ebx
  801236:	75 ec                	jne    801224 <close_all+0xc>
		close(i);
}
  801238:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80123b:	c9                   	leave  
  80123c:	c3                   	ret    

0080123d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80123d:	55                   	push   %ebp
  80123e:	89 e5                	mov    %esp,%ebp
  801240:	57                   	push   %edi
  801241:	56                   	push   %esi
  801242:	53                   	push   %ebx
  801243:	83 ec 2c             	sub    $0x2c,%esp
  801246:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801249:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80124c:	50                   	push   %eax
  80124d:	ff 75 08             	pushl  0x8(%ebp)
  801250:	e8 6e fe ff ff       	call   8010c3 <fd_lookup>
  801255:	83 c4 08             	add    $0x8,%esp
  801258:	85 c0                	test   %eax,%eax
  80125a:	0f 88 c1 00 00 00    	js     801321 <dup+0xe4>
		return r;
	close(newfdnum);
  801260:	83 ec 0c             	sub    $0xc,%esp
  801263:	56                   	push   %esi
  801264:	e8 84 ff ff ff       	call   8011ed <close>

	newfd = INDEX2FD(newfdnum);
  801269:	89 f3                	mov    %esi,%ebx
  80126b:	c1 e3 0c             	shl    $0xc,%ebx
  80126e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801274:	83 c4 04             	add    $0x4,%esp
  801277:	ff 75 e4             	pushl  -0x1c(%ebp)
  80127a:	e8 de fd ff ff       	call   80105d <fd2data>
  80127f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801281:	89 1c 24             	mov    %ebx,(%esp)
  801284:	e8 d4 fd ff ff       	call   80105d <fd2data>
  801289:	83 c4 10             	add    $0x10,%esp
  80128c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80128f:	89 f8                	mov    %edi,%eax
  801291:	c1 e8 16             	shr    $0x16,%eax
  801294:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80129b:	a8 01                	test   $0x1,%al
  80129d:	74 37                	je     8012d6 <dup+0x99>
  80129f:	89 f8                	mov    %edi,%eax
  8012a1:	c1 e8 0c             	shr    $0xc,%eax
  8012a4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012ab:	f6 c2 01             	test   $0x1,%dl
  8012ae:	74 26                	je     8012d6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012b0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012b7:	83 ec 0c             	sub    $0xc,%esp
  8012ba:	25 07 0e 00 00       	and    $0xe07,%eax
  8012bf:	50                   	push   %eax
  8012c0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012c3:	6a 00                	push   $0x0
  8012c5:	57                   	push   %edi
  8012c6:	6a 00                	push   $0x0
  8012c8:	e8 e1 f8 ff ff       	call   800bae <sys_page_map>
  8012cd:	89 c7                	mov    %eax,%edi
  8012cf:	83 c4 20             	add    $0x20,%esp
  8012d2:	85 c0                	test   %eax,%eax
  8012d4:	78 2e                	js     801304 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012d6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012d9:	89 d0                	mov    %edx,%eax
  8012db:	c1 e8 0c             	shr    $0xc,%eax
  8012de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012e5:	83 ec 0c             	sub    $0xc,%esp
  8012e8:	25 07 0e 00 00       	and    $0xe07,%eax
  8012ed:	50                   	push   %eax
  8012ee:	53                   	push   %ebx
  8012ef:	6a 00                	push   $0x0
  8012f1:	52                   	push   %edx
  8012f2:	6a 00                	push   $0x0
  8012f4:	e8 b5 f8 ff ff       	call   800bae <sys_page_map>
  8012f9:	89 c7                	mov    %eax,%edi
  8012fb:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012fe:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801300:	85 ff                	test   %edi,%edi
  801302:	79 1d                	jns    801321 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801304:	83 ec 08             	sub    $0x8,%esp
  801307:	53                   	push   %ebx
  801308:	6a 00                	push   $0x0
  80130a:	e8 e1 f8 ff ff       	call   800bf0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80130f:	83 c4 08             	add    $0x8,%esp
  801312:	ff 75 d4             	pushl  -0x2c(%ebp)
  801315:	6a 00                	push   $0x0
  801317:	e8 d4 f8 ff ff       	call   800bf0 <sys_page_unmap>
	return r;
  80131c:	83 c4 10             	add    $0x10,%esp
  80131f:	89 f8                	mov    %edi,%eax
}
  801321:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801324:	5b                   	pop    %ebx
  801325:	5e                   	pop    %esi
  801326:	5f                   	pop    %edi
  801327:	5d                   	pop    %ebp
  801328:	c3                   	ret    

00801329 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801329:	55                   	push   %ebp
  80132a:	89 e5                	mov    %esp,%ebp
  80132c:	53                   	push   %ebx
  80132d:	83 ec 14             	sub    $0x14,%esp
  801330:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801333:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801336:	50                   	push   %eax
  801337:	53                   	push   %ebx
  801338:	e8 86 fd ff ff       	call   8010c3 <fd_lookup>
  80133d:	83 c4 08             	add    $0x8,%esp
  801340:	89 c2                	mov    %eax,%edx
  801342:	85 c0                	test   %eax,%eax
  801344:	78 6d                	js     8013b3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801346:	83 ec 08             	sub    $0x8,%esp
  801349:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134c:	50                   	push   %eax
  80134d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801350:	ff 30                	pushl  (%eax)
  801352:	e8 c2 fd ff ff       	call   801119 <dev_lookup>
  801357:	83 c4 10             	add    $0x10,%esp
  80135a:	85 c0                	test   %eax,%eax
  80135c:	78 4c                	js     8013aa <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80135e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801361:	8b 42 08             	mov    0x8(%edx),%eax
  801364:	83 e0 03             	and    $0x3,%eax
  801367:	83 f8 01             	cmp    $0x1,%eax
  80136a:	75 21                	jne    80138d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80136c:	a1 08 40 80 00       	mov    0x804008,%eax
  801371:	8b 40 48             	mov    0x48(%eax),%eax
  801374:	83 ec 04             	sub    $0x4,%esp
  801377:	53                   	push   %ebx
  801378:	50                   	push   %eax
  801379:	68 65 2a 80 00       	push   $0x802a65
  80137e:	e8 60 ee ff ff       	call   8001e3 <cprintf>
		return -E_INVAL;
  801383:	83 c4 10             	add    $0x10,%esp
  801386:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80138b:	eb 26                	jmp    8013b3 <read+0x8a>
	}
	if (!dev->dev_read)
  80138d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801390:	8b 40 08             	mov    0x8(%eax),%eax
  801393:	85 c0                	test   %eax,%eax
  801395:	74 17                	je     8013ae <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801397:	83 ec 04             	sub    $0x4,%esp
  80139a:	ff 75 10             	pushl  0x10(%ebp)
  80139d:	ff 75 0c             	pushl  0xc(%ebp)
  8013a0:	52                   	push   %edx
  8013a1:	ff d0                	call   *%eax
  8013a3:	89 c2                	mov    %eax,%edx
  8013a5:	83 c4 10             	add    $0x10,%esp
  8013a8:	eb 09                	jmp    8013b3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013aa:	89 c2                	mov    %eax,%edx
  8013ac:	eb 05                	jmp    8013b3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013ae:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013b3:	89 d0                	mov    %edx,%eax
  8013b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b8:	c9                   	leave  
  8013b9:	c3                   	ret    

008013ba <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013ba:	55                   	push   %ebp
  8013bb:	89 e5                	mov    %esp,%ebp
  8013bd:	57                   	push   %edi
  8013be:	56                   	push   %esi
  8013bf:	53                   	push   %ebx
  8013c0:	83 ec 0c             	sub    $0xc,%esp
  8013c3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013c6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013c9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013ce:	eb 21                	jmp    8013f1 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013d0:	83 ec 04             	sub    $0x4,%esp
  8013d3:	89 f0                	mov    %esi,%eax
  8013d5:	29 d8                	sub    %ebx,%eax
  8013d7:	50                   	push   %eax
  8013d8:	89 d8                	mov    %ebx,%eax
  8013da:	03 45 0c             	add    0xc(%ebp),%eax
  8013dd:	50                   	push   %eax
  8013de:	57                   	push   %edi
  8013df:	e8 45 ff ff ff       	call   801329 <read>
		if (m < 0)
  8013e4:	83 c4 10             	add    $0x10,%esp
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	78 10                	js     8013fb <readn+0x41>
			return m;
		if (m == 0)
  8013eb:	85 c0                	test   %eax,%eax
  8013ed:	74 0a                	je     8013f9 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013ef:	01 c3                	add    %eax,%ebx
  8013f1:	39 f3                	cmp    %esi,%ebx
  8013f3:	72 db                	jb     8013d0 <readn+0x16>
  8013f5:	89 d8                	mov    %ebx,%eax
  8013f7:	eb 02                	jmp    8013fb <readn+0x41>
  8013f9:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013fe:	5b                   	pop    %ebx
  8013ff:	5e                   	pop    %esi
  801400:	5f                   	pop    %edi
  801401:	5d                   	pop    %ebp
  801402:	c3                   	ret    

00801403 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801403:	55                   	push   %ebp
  801404:	89 e5                	mov    %esp,%ebp
  801406:	53                   	push   %ebx
  801407:	83 ec 14             	sub    $0x14,%esp
  80140a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80140d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801410:	50                   	push   %eax
  801411:	53                   	push   %ebx
  801412:	e8 ac fc ff ff       	call   8010c3 <fd_lookup>
  801417:	83 c4 08             	add    $0x8,%esp
  80141a:	89 c2                	mov    %eax,%edx
  80141c:	85 c0                	test   %eax,%eax
  80141e:	78 68                	js     801488 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801420:	83 ec 08             	sub    $0x8,%esp
  801423:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801426:	50                   	push   %eax
  801427:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142a:	ff 30                	pushl  (%eax)
  80142c:	e8 e8 fc ff ff       	call   801119 <dev_lookup>
  801431:	83 c4 10             	add    $0x10,%esp
  801434:	85 c0                	test   %eax,%eax
  801436:	78 47                	js     80147f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801438:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80143f:	75 21                	jne    801462 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801441:	a1 08 40 80 00       	mov    0x804008,%eax
  801446:	8b 40 48             	mov    0x48(%eax),%eax
  801449:	83 ec 04             	sub    $0x4,%esp
  80144c:	53                   	push   %ebx
  80144d:	50                   	push   %eax
  80144e:	68 81 2a 80 00       	push   $0x802a81
  801453:	e8 8b ed ff ff       	call   8001e3 <cprintf>
		return -E_INVAL;
  801458:	83 c4 10             	add    $0x10,%esp
  80145b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801460:	eb 26                	jmp    801488 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801462:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801465:	8b 52 0c             	mov    0xc(%edx),%edx
  801468:	85 d2                	test   %edx,%edx
  80146a:	74 17                	je     801483 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80146c:	83 ec 04             	sub    $0x4,%esp
  80146f:	ff 75 10             	pushl  0x10(%ebp)
  801472:	ff 75 0c             	pushl  0xc(%ebp)
  801475:	50                   	push   %eax
  801476:	ff d2                	call   *%edx
  801478:	89 c2                	mov    %eax,%edx
  80147a:	83 c4 10             	add    $0x10,%esp
  80147d:	eb 09                	jmp    801488 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80147f:	89 c2                	mov    %eax,%edx
  801481:	eb 05                	jmp    801488 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801483:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801488:	89 d0                	mov    %edx,%eax
  80148a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80148d:	c9                   	leave  
  80148e:	c3                   	ret    

0080148f <seek>:

int
seek(int fdnum, off_t offset)
{
  80148f:	55                   	push   %ebp
  801490:	89 e5                	mov    %esp,%ebp
  801492:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801495:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801498:	50                   	push   %eax
  801499:	ff 75 08             	pushl  0x8(%ebp)
  80149c:	e8 22 fc ff ff       	call   8010c3 <fd_lookup>
  8014a1:	83 c4 08             	add    $0x8,%esp
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	78 0e                	js     8014b6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ae:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014b6:	c9                   	leave  
  8014b7:	c3                   	ret    

008014b8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014b8:	55                   	push   %ebp
  8014b9:	89 e5                	mov    %esp,%ebp
  8014bb:	53                   	push   %ebx
  8014bc:	83 ec 14             	sub    $0x14,%esp
  8014bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c5:	50                   	push   %eax
  8014c6:	53                   	push   %ebx
  8014c7:	e8 f7 fb ff ff       	call   8010c3 <fd_lookup>
  8014cc:	83 c4 08             	add    $0x8,%esp
  8014cf:	89 c2                	mov    %eax,%edx
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	78 65                	js     80153a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d5:	83 ec 08             	sub    $0x8,%esp
  8014d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014db:	50                   	push   %eax
  8014dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014df:	ff 30                	pushl  (%eax)
  8014e1:	e8 33 fc ff ff       	call   801119 <dev_lookup>
  8014e6:	83 c4 10             	add    $0x10,%esp
  8014e9:	85 c0                	test   %eax,%eax
  8014eb:	78 44                	js     801531 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014f4:	75 21                	jne    801517 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014f6:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014fb:	8b 40 48             	mov    0x48(%eax),%eax
  8014fe:	83 ec 04             	sub    $0x4,%esp
  801501:	53                   	push   %ebx
  801502:	50                   	push   %eax
  801503:	68 44 2a 80 00       	push   $0x802a44
  801508:	e8 d6 ec ff ff       	call   8001e3 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80150d:	83 c4 10             	add    $0x10,%esp
  801510:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801515:	eb 23                	jmp    80153a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801517:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80151a:	8b 52 18             	mov    0x18(%edx),%edx
  80151d:	85 d2                	test   %edx,%edx
  80151f:	74 14                	je     801535 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801521:	83 ec 08             	sub    $0x8,%esp
  801524:	ff 75 0c             	pushl  0xc(%ebp)
  801527:	50                   	push   %eax
  801528:	ff d2                	call   *%edx
  80152a:	89 c2                	mov    %eax,%edx
  80152c:	83 c4 10             	add    $0x10,%esp
  80152f:	eb 09                	jmp    80153a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801531:	89 c2                	mov    %eax,%edx
  801533:	eb 05                	jmp    80153a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801535:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80153a:	89 d0                	mov    %edx,%eax
  80153c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153f:	c9                   	leave  
  801540:	c3                   	ret    

00801541 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	53                   	push   %ebx
  801545:	83 ec 14             	sub    $0x14,%esp
  801548:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80154e:	50                   	push   %eax
  80154f:	ff 75 08             	pushl  0x8(%ebp)
  801552:	e8 6c fb ff ff       	call   8010c3 <fd_lookup>
  801557:	83 c4 08             	add    $0x8,%esp
  80155a:	89 c2                	mov    %eax,%edx
  80155c:	85 c0                	test   %eax,%eax
  80155e:	78 58                	js     8015b8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801560:	83 ec 08             	sub    $0x8,%esp
  801563:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801566:	50                   	push   %eax
  801567:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156a:	ff 30                	pushl  (%eax)
  80156c:	e8 a8 fb ff ff       	call   801119 <dev_lookup>
  801571:	83 c4 10             	add    $0x10,%esp
  801574:	85 c0                	test   %eax,%eax
  801576:	78 37                	js     8015af <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801578:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80157b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80157f:	74 32                	je     8015b3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801581:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801584:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80158b:	00 00 00 
	stat->st_isdir = 0;
  80158e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801595:	00 00 00 
	stat->st_dev = dev;
  801598:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80159e:	83 ec 08             	sub    $0x8,%esp
  8015a1:	53                   	push   %ebx
  8015a2:	ff 75 f0             	pushl  -0x10(%ebp)
  8015a5:	ff 50 14             	call   *0x14(%eax)
  8015a8:	89 c2                	mov    %eax,%edx
  8015aa:	83 c4 10             	add    $0x10,%esp
  8015ad:	eb 09                	jmp    8015b8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015af:	89 c2                	mov    %eax,%edx
  8015b1:	eb 05                	jmp    8015b8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015b3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015b8:	89 d0                	mov    %edx,%eax
  8015ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bd:	c9                   	leave  
  8015be:	c3                   	ret    

008015bf <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015bf:	55                   	push   %ebp
  8015c0:	89 e5                	mov    %esp,%ebp
  8015c2:	56                   	push   %esi
  8015c3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015c4:	83 ec 08             	sub    $0x8,%esp
  8015c7:	6a 00                	push   $0x0
  8015c9:	ff 75 08             	pushl  0x8(%ebp)
  8015cc:	e8 d6 01 00 00       	call   8017a7 <open>
  8015d1:	89 c3                	mov    %eax,%ebx
  8015d3:	83 c4 10             	add    $0x10,%esp
  8015d6:	85 c0                	test   %eax,%eax
  8015d8:	78 1b                	js     8015f5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015da:	83 ec 08             	sub    $0x8,%esp
  8015dd:	ff 75 0c             	pushl  0xc(%ebp)
  8015e0:	50                   	push   %eax
  8015e1:	e8 5b ff ff ff       	call   801541 <fstat>
  8015e6:	89 c6                	mov    %eax,%esi
	close(fd);
  8015e8:	89 1c 24             	mov    %ebx,(%esp)
  8015eb:	e8 fd fb ff ff       	call   8011ed <close>
	return r;
  8015f0:	83 c4 10             	add    $0x10,%esp
  8015f3:	89 f0                	mov    %esi,%eax
}
  8015f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015f8:	5b                   	pop    %ebx
  8015f9:	5e                   	pop    %esi
  8015fa:	5d                   	pop    %ebp
  8015fb:	c3                   	ret    

008015fc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015fc:	55                   	push   %ebp
  8015fd:	89 e5                	mov    %esp,%ebp
  8015ff:	56                   	push   %esi
  801600:	53                   	push   %ebx
  801601:	89 c6                	mov    %eax,%esi
  801603:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801605:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80160c:	75 12                	jne    801620 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80160e:	83 ec 0c             	sub    $0xc,%esp
  801611:	6a 01                	push   $0x1
  801613:	e8 e5 0c 00 00       	call   8022fd <ipc_find_env>
  801618:	a3 00 40 80 00       	mov    %eax,0x804000
  80161d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801620:	6a 07                	push   $0x7
  801622:	68 00 50 80 00       	push   $0x805000
  801627:	56                   	push   %esi
  801628:	ff 35 00 40 80 00    	pushl  0x804000
  80162e:	e8 76 0c 00 00       	call   8022a9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801633:	83 c4 0c             	add    $0xc,%esp
  801636:	6a 00                	push   $0x0
  801638:	53                   	push   %ebx
  801639:	6a 00                	push   $0x0
  80163b:	e8 02 0c 00 00       	call   802242 <ipc_recv>
}
  801640:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801643:	5b                   	pop    %ebx
  801644:	5e                   	pop    %esi
  801645:	5d                   	pop    %ebp
  801646:	c3                   	ret    

00801647 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80164d:	8b 45 08             	mov    0x8(%ebp),%eax
  801650:	8b 40 0c             	mov    0xc(%eax),%eax
  801653:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801658:	8b 45 0c             	mov    0xc(%ebp),%eax
  80165b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801660:	ba 00 00 00 00       	mov    $0x0,%edx
  801665:	b8 02 00 00 00       	mov    $0x2,%eax
  80166a:	e8 8d ff ff ff       	call   8015fc <fsipc>
}
  80166f:	c9                   	leave  
  801670:	c3                   	ret    

00801671 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801677:	8b 45 08             	mov    0x8(%ebp),%eax
  80167a:	8b 40 0c             	mov    0xc(%eax),%eax
  80167d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801682:	ba 00 00 00 00       	mov    $0x0,%edx
  801687:	b8 06 00 00 00       	mov    $0x6,%eax
  80168c:	e8 6b ff ff ff       	call   8015fc <fsipc>
}
  801691:	c9                   	leave  
  801692:	c3                   	ret    

00801693 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	53                   	push   %ebx
  801697:	83 ec 04             	sub    $0x4,%esp
  80169a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80169d:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a0:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ad:	b8 05 00 00 00       	mov    $0x5,%eax
  8016b2:	e8 45 ff ff ff       	call   8015fc <fsipc>
  8016b7:	85 c0                	test   %eax,%eax
  8016b9:	78 2c                	js     8016e7 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016bb:	83 ec 08             	sub    $0x8,%esp
  8016be:	68 00 50 80 00       	push   $0x805000
  8016c3:	53                   	push   %ebx
  8016c4:	e8 9f f0 ff ff       	call   800768 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016c9:	a1 80 50 80 00       	mov    0x805080,%eax
  8016ce:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016d4:	a1 84 50 80 00       	mov    0x805084,%eax
  8016d9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016df:	83 c4 10             	add    $0x10,%esp
  8016e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ea:	c9                   	leave  
  8016eb:	c3                   	ret    

008016ec <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016ec:	55                   	push   %ebp
  8016ed:	89 e5                	mov    %esp,%ebp
  8016ef:	83 ec 0c             	sub    $0xc,%esp
  8016f2:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8016f8:	8b 52 0c             	mov    0xc(%edx),%edx
  8016fb:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801701:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801706:	50                   	push   %eax
  801707:	ff 75 0c             	pushl  0xc(%ebp)
  80170a:	68 08 50 80 00       	push   $0x805008
  80170f:	e8 e6 f1 ff ff       	call   8008fa <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801714:	ba 00 00 00 00       	mov    $0x0,%edx
  801719:	b8 04 00 00 00       	mov    $0x4,%eax
  80171e:	e8 d9 fe ff ff       	call   8015fc <fsipc>

}
  801723:	c9                   	leave  
  801724:	c3                   	ret    

00801725 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801725:	55                   	push   %ebp
  801726:	89 e5                	mov    %esp,%ebp
  801728:	56                   	push   %esi
  801729:	53                   	push   %ebx
  80172a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80172d:	8b 45 08             	mov    0x8(%ebp),%eax
  801730:	8b 40 0c             	mov    0xc(%eax),%eax
  801733:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801738:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80173e:	ba 00 00 00 00       	mov    $0x0,%edx
  801743:	b8 03 00 00 00       	mov    $0x3,%eax
  801748:	e8 af fe ff ff       	call   8015fc <fsipc>
  80174d:	89 c3                	mov    %eax,%ebx
  80174f:	85 c0                	test   %eax,%eax
  801751:	78 4b                	js     80179e <devfile_read+0x79>
		return r;
	assert(r <= n);
  801753:	39 c6                	cmp    %eax,%esi
  801755:	73 16                	jae    80176d <devfile_read+0x48>
  801757:	68 b4 2a 80 00       	push   $0x802ab4
  80175c:	68 bb 2a 80 00       	push   $0x802abb
  801761:	6a 7c                	push   $0x7c
  801763:	68 d0 2a 80 00       	push   $0x802ad0
  801768:	e8 24 0a 00 00       	call   802191 <_panic>
	assert(r <= PGSIZE);
  80176d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801772:	7e 16                	jle    80178a <devfile_read+0x65>
  801774:	68 db 2a 80 00       	push   $0x802adb
  801779:	68 bb 2a 80 00       	push   $0x802abb
  80177e:	6a 7d                	push   $0x7d
  801780:	68 d0 2a 80 00       	push   $0x802ad0
  801785:	e8 07 0a 00 00       	call   802191 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80178a:	83 ec 04             	sub    $0x4,%esp
  80178d:	50                   	push   %eax
  80178e:	68 00 50 80 00       	push   $0x805000
  801793:	ff 75 0c             	pushl  0xc(%ebp)
  801796:	e8 5f f1 ff ff       	call   8008fa <memmove>
	return r;
  80179b:	83 c4 10             	add    $0x10,%esp
}
  80179e:	89 d8                	mov    %ebx,%eax
  8017a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a3:	5b                   	pop    %ebx
  8017a4:	5e                   	pop    %esi
  8017a5:	5d                   	pop    %ebp
  8017a6:	c3                   	ret    

008017a7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017a7:	55                   	push   %ebp
  8017a8:	89 e5                	mov    %esp,%ebp
  8017aa:	53                   	push   %ebx
  8017ab:	83 ec 20             	sub    $0x20,%esp
  8017ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017b1:	53                   	push   %ebx
  8017b2:	e8 78 ef ff ff       	call   80072f <strlen>
  8017b7:	83 c4 10             	add    $0x10,%esp
  8017ba:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017bf:	7f 67                	jg     801828 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017c1:	83 ec 0c             	sub    $0xc,%esp
  8017c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c7:	50                   	push   %eax
  8017c8:	e8 a7 f8 ff ff       	call   801074 <fd_alloc>
  8017cd:	83 c4 10             	add    $0x10,%esp
		return r;
  8017d0:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017d2:	85 c0                	test   %eax,%eax
  8017d4:	78 57                	js     80182d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017d6:	83 ec 08             	sub    $0x8,%esp
  8017d9:	53                   	push   %ebx
  8017da:	68 00 50 80 00       	push   $0x805000
  8017df:	e8 84 ef ff ff       	call   800768 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ef:	b8 01 00 00 00       	mov    $0x1,%eax
  8017f4:	e8 03 fe ff ff       	call   8015fc <fsipc>
  8017f9:	89 c3                	mov    %eax,%ebx
  8017fb:	83 c4 10             	add    $0x10,%esp
  8017fe:	85 c0                	test   %eax,%eax
  801800:	79 14                	jns    801816 <open+0x6f>
		fd_close(fd, 0);
  801802:	83 ec 08             	sub    $0x8,%esp
  801805:	6a 00                	push   $0x0
  801807:	ff 75 f4             	pushl  -0xc(%ebp)
  80180a:	e8 5d f9 ff ff       	call   80116c <fd_close>
		return r;
  80180f:	83 c4 10             	add    $0x10,%esp
  801812:	89 da                	mov    %ebx,%edx
  801814:	eb 17                	jmp    80182d <open+0x86>
	}

	return fd2num(fd);
  801816:	83 ec 0c             	sub    $0xc,%esp
  801819:	ff 75 f4             	pushl  -0xc(%ebp)
  80181c:	e8 2c f8 ff ff       	call   80104d <fd2num>
  801821:	89 c2                	mov    %eax,%edx
  801823:	83 c4 10             	add    $0x10,%esp
  801826:	eb 05                	jmp    80182d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801828:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80182d:	89 d0                	mov    %edx,%eax
  80182f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801832:	c9                   	leave  
  801833:	c3                   	ret    

00801834 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80183a:	ba 00 00 00 00       	mov    $0x0,%edx
  80183f:	b8 08 00 00 00       	mov    $0x8,%eax
  801844:	e8 b3 fd ff ff       	call   8015fc <fsipc>
}
  801849:	c9                   	leave  
  80184a:	c3                   	ret    

0080184b <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80184b:	55                   	push   %ebp
  80184c:	89 e5                	mov    %esp,%ebp
  80184e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801851:	68 e7 2a 80 00       	push   $0x802ae7
  801856:	ff 75 0c             	pushl  0xc(%ebp)
  801859:	e8 0a ef ff ff       	call   800768 <strcpy>
	return 0;
}
  80185e:	b8 00 00 00 00       	mov    $0x0,%eax
  801863:	c9                   	leave  
  801864:	c3                   	ret    

00801865 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801865:	55                   	push   %ebp
  801866:	89 e5                	mov    %esp,%ebp
  801868:	53                   	push   %ebx
  801869:	83 ec 10             	sub    $0x10,%esp
  80186c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80186f:	53                   	push   %ebx
  801870:	e8 c1 0a 00 00       	call   802336 <pageref>
  801875:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801878:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80187d:	83 f8 01             	cmp    $0x1,%eax
  801880:	75 10                	jne    801892 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801882:	83 ec 0c             	sub    $0xc,%esp
  801885:	ff 73 0c             	pushl  0xc(%ebx)
  801888:	e8 c0 02 00 00       	call   801b4d <nsipc_close>
  80188d:	89 c2                	mov    %eax,%edx
  80188f:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801892:	89 d0                	mov    %edx,%eax
  801894:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801897:	c9                   	leave  
  801898:	c3                   	ret    

00801899 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801899:	55                   	push   %ebp
  80189a:	89 e5                	mov    %esp,%ebp
  80189c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80189f:	6a 00                	push   $0x0
  8018a1:	ff 75 10             	pushl  0x10(%ebp)
  8018a4:	ff 75 0c             	pushl  0xc(%ebp)
  8018a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018aa:	ff 70 0c             	pushl  0xc(%eax)
  8018ad:	e8 78 03 00 00       	call   801c2a <nsipc_send>
}
  8018b2:	c9                   	leave  
  8018b3:	c3                   	ret    

008018b4 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8018b4:	55                   	push   %ebp
  8018b5:	89 e5                	mov    %esp,%ebp
  8018b7:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8018ba:	6a 00                	push   $0x0
  8018bc:	ff 75 10             	pushl  0x10(%ebp)
  8018bf:	ff 75 0c             	pushl  0xc(%ebp)
  8018c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c5:	ff 70 0c             	pushl  0xc(%eax)
  8018c8:	e8 f1 02 00 00       	call   801bbe <nsipc_recv>
}
  8018cd:	c9                   	leave  
  8018ce:	c3                   	ret    

008018cf <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8018d5:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8018d8:	52                   	push   %edx
  8018d9:	50                   	push   %eax
  8018da:	e8 e4 f7 ff ff       	call   8010c3 <fd_lookup>
  8018df:	83 c4 10             	add    $0x10,%esp
  8018e2:	85 c0                	test   %eax,%eax
  8018e4:	78 17                	js     8018fd <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8018e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e9:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8018ef:	39 08                	cmp    %ecx,(%eax)
  8018f1:	75 05                	jne    8018f8 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8018f3:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f6:	eb 05                	jmp    8018fd <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8018f8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8018fd:	c9                   	leave  
  8018fe:	c3                   	ret    

008018ff <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	56                   	push   %esi
  801903:	53                   	push   %ebx
  801904:	83 ec 1c             	sub    $0x1c,%esp
  801907:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801909:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80190c:	50                   	push   %eax
  80190d:	e8 62 f7 ff ff       	call   801074 <fd_alloc>
  801912:	89 c3                	mov    %eax,%ebx
  801914:	83 c4 10             	add    $0x10,%esp
  801917:	85 c0                	test   %eax,%eax
  801919:	78 1b                	js     801936 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80191b:	83 ec 04             	sub    $0x4,%esp
  80191e:	68 07 04 00 00       	push   $0x407
  801923:	ff 75 f4             	pushl  -0xc(%ebp)
  801926:	6a 00                	push   $0x0
  801928:	e8 3e f2 ff ff       	call   800b6b <sys_page_alloc>
  80192d:	89 c3                	mov    %eax,%ebx
  80192f:	83 c4 10             	add    $0x10,%esp
  801932:	85 c0                	test   %eax,%eax
  801934:	79 10                	jns    801946 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801936:	83 ec 0c             	sub    $0xc,%esp
  801939:	56                   	push   %esi
  80193a:	e8 0e 02 00 00       	call   801b4d <nsipc_close>
		return r;
  80193f:	83 c4 10             	add    $0x10,%esp
  801942:	89 d8                	mov    %ebx,%eax
  801944:	eb 24                	jmp    80196a <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801946:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80194c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80194f:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801951:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801954:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80195b:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80195e:	83 ec 0c             	sub    $0xc,%esp
  801961:	50                   	push   %eax
  801962:	e8 e6 f6 ff ff       	call   80104d <fd2num>
  801967:	83 c4 10             	add    $0x10,%esp
}
  80196a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80196d:	5b                   	pop    %ebx
  80196e:	5e                   	pop    %esi
  80196f:	5d                   	pop    %ebp
  801970:	c3                   	ret    

00801971 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801971:	55                   	push   %ebp
  801972:	89 e5                	mov    %esp,%ebp
  801974:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801977:	8b 45 08             	mov    0x8(%ebp),%eax
  80197a:	e8 50 ff ff ff       	call   8018cf <fd2sockid>
		return r;
  80197f:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801981:	85 c0                	test   %eax,%eax
  801983:	78 1f                	js     8019a4 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801985:	83 ec 04             	sub    $0x4,%esp
  801988:	ff 75 10             	pushl  0x10(%ebp)
  80198b:	ff 75 0c             	pushl  0xc(%ebp)
  80198e:	50                   	push   %eax
  80198f:	e8 12 01 00 00       	call   801aa6 <nsipc_accept>
  801994:	83 c4 10             	add    $0x10,%esp
		return r;
  801997:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801999:	85 c0                	test   %eax,%eax
  80199b:	78 07                	js     8019a4 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80199d:	e8 5d ff ff ff       	call   8018ff <alloc_sockfd>
  8019a2:	89 c1                	mov    %eax,%ecx
}
  8019a4:	89 c8                	mov    %ecx,%eax
  8019a6:	c9                   	leave  
  8019a7:	c3                   	ret    

008019a8 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b1:	e8 19 ff ff ff       	call   8018cf <fd2sockid>
  8019b6:	85 c0                	test   %eax,%eax
  8019b8:	78 12                	js     8019cc <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8019ba:	83 ec 04             	sub    $0x4,%esp
  8019bd:	ff 75 10             	pushl  0x10(%ebp)
  8019c0:	ff 75 0c             	pushl  0xc(%ebp)
  8019c3:	50                   	push   %eax
  8019c4:	e8 2d 01 00 00       	call   801af6 <nsipc_bind>
  8019c9:	83 c4 10             	add    $0x10,%esp
}
  8019cc:	c9                   	leave  
  8019cd:	c3                   	ret    

008019ce <shutdown>:

int
shutdown(int s, int how)
{
  8019ce:	55                   	push   %ebp
  8019cf:	89 e5                	mov    %esp,%ebp
  8019d1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d7:	e8 f3 fe ff ff       	call   8018cf <fd2sockid>
  8019dc:	85 c0                	test   %eax,%eax
  8019de:	78 0f                	js     8019ef <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8019e0:	83 ec 08             	sub    $0x8,%esp
  8019e3:	ff 75 0c             	pushl  0xc(%ebp)
  8019e6:	50                   	push   %eax
  8019e7:	e8 3f 01 00 00       	call   801b2b <nsipc_shutdown>
  8019ec:	83 c4 10             	add    $0x10,%esp
}
  8019ef:	c9                   	leave  
  8019f0:	c3                   	ret    

008019f1 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
  8019f4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fa:	e8 d0 fe ff ff       	call   8018cf <fd2sockid>
  8019ff:	85 c0                	test   %eax,%eax
  801a01:	78 12                	js     801a15 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801a03:	83 ec 04             	sub    $0x4,%esp
  801a06:	ff 75 10             	pushl  0x10(%ebp)
  801a09:	ff 75 0c             	pushl  0xc(%ebp)
  801a0c:	50                   	push   %eax
  801a0d:	e8 55 01 00 00       	call   801b67 <nsipc_connect>
  801a12:	83 c4 10             	add    $0x10,%esp
}
  801a15:	c9                   	leave  
  801a16:	c3                   	ret    

00801a17 <listen>:

int
listen(int s, int backlog)
{
  801a17:	55                   	push   %ebp
  801a18:	89 e5                	mov    %esp,%ebp
  801a1a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a20:	e8 aa fe ff ff       	call   8018cf <fd2sockid>
  801a25:	85 c0                	test   %eax,%eax
  801a27:	78 0f                	js     801a38 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801a29:	83 ec 08             	sub    $0x8,%esp
  801a2c:	ff 75 0c             	pushl  0xc(%ebp)
  801a2f:	50                   	push   %eax
  801a30:	e8 67 01 00 00       	call   801b9c <nsipc_listen>
  801a35:	83 c4 10             	add    $0x10,%esp
}
  801a38:	c9                   	leave  
  801a39:	c3                   	ret    

00801a3a <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801a3a:	55                   	push   %ebp
  801a3b:	89 e5                	mov    %esp,%ebp
  801a3d:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a40:	ff 75 10             	pushl  0x10(%ebp)
  801a43:	ff 75 0c             	pushl  0xc(%ebp)
  801a46:	ff 75 08             	pushl  0x8(%ebp)
  801a49:	e8 3a 02 00 00       	call   801c88 <nsipc_socket>
  801a4e:	83 c4 10             	add    $0x10,%esp
  801a51:	85 c0                	test   %eax,%eax
  801a53:	78 05                	js     801a5a <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801a55:	e8 a5 fe ff ff       	call   8018ff <alloc_sockfd>
}
  801a5a:	c9                   	leave  
  801a5b:	c3                   	ret    

00801a5c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a5c:	55                   	push   %ebp
  801a5d:	89 e5                	mov    %esp,%ebp
  801a5f:	53                   	push   %ebx
  801a60:	83 ec 04             	sub    $0x4,%esp
  801a63:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a65:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801a6c:	75 12                	jne    801a80 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801a6e:	83 ec 0c             	sub    $0xc,%esp
  801a71:	6a 02                	push   $0x2
  801a73:	e8 85 08 00 00       	call   8022fd <ipc_find_env>
  801a78:	a3 04 40 80 00       	mov    %eax,0x804004
  801a7d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801a80:	6a 07                	push   $0x7
  801a82:	68 00 60 80 00       	push   $0x806000
  801a87:	53                   	push   %ebx
  801a88:	ff 35 04 40 80 00    	pushl  0x804004
  801a8e:	e8 16 08 00 00       	call   8022a9 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801a93:	83 c4 0c             	add    $0xc,%esp
  801a96:	6a 00                	push   $0x0
  801a98:	6a 00                	push   $0x0
  801a9a:	6a 00                	push   $0x0
  801a9c:	e8 a1 07 00 00       	call   802242 <ipc_recv>
}
  801aa1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aa4:	c9                   	leave  
  801aa5:	c3                   	ret    

00801aa6 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801aa6:	55                   	push   %ebp
  801aa7:	89 e5                	mov    %esp,%ebp
  801aa9:	56                   	push   %esi
  801aaa:	53                   	push   %ebx
  801aab:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801aae:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ab6:	8b 06                	mov    (%esi),%eax
  801ab8:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801abd:	b8 01 00 00 00       	mov    $0x1,%eax
  801ac2:	e8 95 ff ff ff       	call   801a5c <nsipc>
  801ac7:	89 c3                	mov    %eax,%ebx
  801ac9:	85 c0                	test   %eax,%eax
  801acb:	78 20                	js     801aed <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801acd:	83 ec 04             	sub    $0x4,%esp
  801ad0:	ff 35 10 60 80 00    	pushl  0x806010
  801ad6:	68 00 60 80 00       	push   $0x806000
  801adb:	ff 75 0c             	pushl  0xc(%ebp)
  801ade:	e8 17 ee ff ff       	call   8008fa <memmove>
		*addrlen = ret->ret_addrlen;
  801ae3:	a1 10 60 80 00       	mov    0x806010,%eax
  801ae8:	89 06                	mov    %eax,(%esi)
  801aea:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801aed:	89 d8                	mov    %ebx,%eax
  801aef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af2:	5b                   	pop    %ebx
  801af3:	5e                   	pop    %esi
  801af4:	5d                   	pop    %ebp
  801af5:	c3                   	ret    

00801af6 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	53                   	push   %ebx
  801afa:	83 ec 08             	sub    $0x8,%esp
  801afd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801b00:	8b 45 08             	mov    0x8(%ebp),%eax
  801b03:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b08:	53                   	push   %ebx
  801b09:	ff 75 0c             	pushl  0xc(%ebp)
  801b0c:	68 04 60 80 00       	push   $0x806004
  801b11:	e8 e4 ed ff ff       	call   8008fa <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b16:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801b1c:	b8 02 00 00 00       	mov    $0x2,%eax
  801b21:	e8 36 ff ff ff       	call   801a5c <nsipc>
}
  801b26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b29:	c9                   	leave  
  801b2a:	c3                   	ret    

00801b2b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b31:	8b 45 08             	mov    0x8(%ebp),%eax
  801b34:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801b39:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b3c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801b41:	b8 03 00 00 00       	mov    $0x3,%eax
  801b46:	e8 11 ff ff ff       	call   801a5c <nsipc>
}
  801b4b:	c9                   	leave  
  801b4c:	c3                   	ret    

00801b4d <nsipc_close>:

int
nsipc_close(int s)
{
  801b4d:	55                   	push   %ebp
  801b4e:	89 e5                	mov    %esp,%ebp
  801b50:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b53:	8b 45 08             	mov    0x8(%ebp),%eax
  801b56:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801b5b:	b8 04 00 00 00       	mov    $0x4,%eax
  801b60:	e8 f7 fe ff ff       	call   801a5c <nsipc>
}
  801b65:	c9                   	leave  
  801b66:	c3                   	ret    

00801b67 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b67:	55                   	push   %ebp
  801b68:	89 e5                	mov    %esp,%ebp
  801b6a:	53                   	push   %ebx
  801b6b:	83 ec 08             	sub    $0x8,%esp
  801b6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b71:	8b 45 08             	mov    0x8(%ebp),%eax
  801b74:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801b79:	53                   	push   %ebx
  801b7a:	ff 75 0c             	pushl  0xc(%ebp)
  801b7d:	68 04 60 80 00       	push   $0x806004
  801b82:	e8 73 ed ff ff       	call   8008fa <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801b87:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801b8d:	b8 05 00 00 00       	mov    $0x5,%eax
  801b92:	e8 c5 fe ff ff       	call   801a5c <nsipc>
}
  801b97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b9a:	c9                   	leave  
  801b9b:	c3                   	ret    

00801b9c <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
  801b9f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ba2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801baa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bad:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801bb2:	b8 06 00 00 00       	mov    $0x6,%eax
  801bb7:	e8 a0 fe ff ff       	call   801a5c <nsipc>
}
  801bbc:	c9                   	leave  
  801bbd:	c3                   	ret    

00801bbe <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
  801bc1:	56                   	push   %esi
  801bc2:	53                   	push   %ebx
  801bc3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801bc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801bce:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801bd4:	8b 45 14             	mov    0x14(%ebp),%eax
  801bd7:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801bdc:	b8 07 00 00 00       	mov    $0x7,%eax
  801be1:	e8 76 fe ff ff       	call   801a5c <nsipc>
  801be6:	89 c3                	mov    %eax,%ebx
  801be8:	85 c0                	test   %eax,%eax
  801bea:	78 35                	js     801c21 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801bec:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801bf1:	7f 04                	jg     801bf7 <nsipc_recv+0x39>
  801bf3:	39 c6                	cmp    %eax,%esi
  801bf5:	7d 16                	jge    801c0d <nsipc_recv+0x4f>
  801bf7:	68 f3 2a 80 00       	push   $0x802af3
  801bfc:	68 bb 2a 80 00       	push   $0x802abb
  801c01:	6a 62                	push   $0x62
  801c03:	68 08 2b 80 00       	push   $0x802b08
  801c08:	e8 84 05 00 00       	call   802191 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c0d:	83 ec 04             	sub    $0x4,%esp
  801c10:	50                   	push   %eax
  801c11:	68 00 60 80 00       	push   $0x806000
  801c16:	ff 75 0c             	pushl  0xc(%ebp)
  801c19:	e8 dc ec ff ff       	call   8008fa <memmove>
  801c1e:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c21:	89 d8                	mov    %ebx,%eax
  801c23:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c26:	5b                   	pop    %ebx
  801c27:	5e                   	pop    %esi
  801c28:	5d                   	pop    %ebp
  801c29:	c3                   	ret    

00801c2a <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c2a:	55                   	push   %ebp
  801c2b:	89 e5                	mov    %esp,%ebp
  801c2d:	53                   	push   %ebx
  801c2e:	83 ec 04             	sub    $0x4,%esp
  801c31:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c34:	8b 45 08             	mov    0x8(%ebp),%eax
  801c37:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801c3c:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c42:	7e 16                	jle    801c5a <nsipc_send+0x30>
  801c44:	68 14 2b 80 00       	push   $0x802b14
  801c49:	68 bb 2a 80 00       	push   $0x802abb
  801c4e:	6a 6d                	push   $0x6d
  801c50:	68 08 2b 80 00       	push   $0x802b08
  801c55:	e8 37 05 00 00       	call   802191 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c5a:	83 ec 04             	sub    $0x4,%esp
  801c5d:	53                   	push   %ebx
  801c5e:	ff 75 0c             	pushl  0xc(%ebp)
  801c61:	68 0c 60 80 00       	push   $0x80600c
  801c66:	e8 8f ec ff ff       	call   8008fa <memmove>
	nsipcbuf.send.req_size = size;
  801c6b:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801c71:	8b 45 14             	mov    0x14(%ebp),%eax
  801c74:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801c79:	b8 08 00 00 00       	mov    $0x8,%eax
  801c7e:	e8 d9 fd ff ff       	call   801a5c <nsipc>
}
  801c83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c86:	c9                   	leave  
  801c87:	c3                   	ret    

00801c88 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801c88:	55                   	push   %ebp
  801c89:	89 e5                	mov    %esp,%ebp
  801c8b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c91:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801c96:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c99:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801c9e:	8b 45 10             	mov    0x10(%ebp),%eax
  801ca1:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ca6:	b8 09 00 00 00       	mov    $0x9,%eax
  801cab:	e8 ac fd ff ff       	call   801a5c <nsipc>
}
  801cb0:	c9                   	leave  
  801cb1:	c3                   	ret    

00801cb2 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801cb2:	55                   	push   %ebp
  801cb3:	89 e5                	mov    %esp,%ebp
  801cb5:	56                   	push   %esi
  801cb6:	53                   	push   %ebx
  801cb7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801cba:	83 ec 0c             	sub    $0xc,%esp
  801cbd:	ff 75 08             	pushl  0x8(%ebp)
  801cc0:	e8 98 f3 ff ff       	call   80105d <fd2data>
  801cc5:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801cc7:	83 c4 08             	add    $0x8,%esp
  801cca:	68 20 2b 80 00       	push   $0x802b20
  801ccf:	53                   	push   %ebx
  801cd0:	e8 93 ea ff ff       	call   800768 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cd5:	8b 46 04             	mov    0x4(%esi),%eax
  801cd8:	2b 06                	sub    (%esi),%eax
  801cda:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ce0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ce7:	00 00 00 
	stat->st_dev = &devpipe;
  801cea:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801cf1:	30 80 00 
	return 0;
}
  801cf4:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cfc:	5b                   	pop    %ebx
  801cfd:	5e                   	pop    %esi
  801cfe:	5d                   	pop    %ebp
  801cff:	c3                   	ret    

00801d00 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
  801d03:	53                   	push   %ebx
  801d04:	83 ec 0c             	sub    $0xc,%esp
  801d07:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d0a:	53                   	push   %ebx
  801d0b:	6a 00                	push   $0x0
  801d0d:	e8 de ee ff ff       	call   800bf0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d12:	89 1c 24             	mov    %ebx,(%esp)
  801d15:	e8 43 f3 ff ff       	call   80105d <fd2data>
  801d1a:	83 c4 08             	add    $0x8,%esp
  801d1d:	50                   	push   %eax
  801d1e:	6a 00                	push   $0x0
  801d20:	e8 cb ee ff ff       	call   800bf0 <sys_page_unmap>
}
  801d25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d28:	c9                   	leave  
  801d29:	c3                   	ret    

00801d2a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d2a:	55                   	push   %ebp
  801d2b:	89 e5                	mov    %esp,%ebp
  801d2d:	57                   	push   %edi
  801d2e:	56                   	push   %esi
  801d2f:	53                   	push   %ebx
  801d30:	83 ec 1c             	sub    $0x1c,%esp
  801d33:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d36:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d38:	a1 08 40 80 00       	mov    0x804008,%eax
  801d3d:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d40:	83 ec 0c             	sub    $0xc,%esp
  801d43:	ff 75 e0             	pushl  -0x20(%ebp)
  801d46:	e8 eb 05 00 00       	call   802336 <pageref>
  801d4b:	89 c3                	mov    %eax,%ebx
  801d4d:	89 3c 24             	mov    %edi,(%esp)
  801d50:	e8 e1 05 00 00       	call   802336 <pageref>
  801d55:	83 c4 10             	add    $0x10,%esp
  801d58:	39 c3                	cmp    %eax,%ebx
  801d5a:	0f 94 c1             	sete   %cl
  801d5d:	0f b6 c9             	movzbl %cl,%ecx
  801d60:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d63:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801d69:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d6c:	39 ce                	cmp    %ecx,%esi
  801d6e:	74 1b                	je     801d8b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801d70:	39 c3                	cmp    %eax,%ebx
  801d72:	75 c4                	jne    801d38 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d74:	8b 42 58             	mov    0x58(%edx),%eax
  801d77:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d7a:	50                   	push   %eax
  801d7b:	56                   	push   %esi
  801d7c:	68 27 2b 80 00       	push   $0x802b27
  801d81:	e8 5d e4 ff ff       	call   8001e3 <cprintf>
  801d86:	83 c4 10             	add    $0x10,%esp
  801d89:	eb ad                	jmp    801d38 <_pipeisclosed+0xe>
	}
}
  801d8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d91:	5b                   	pop    %ebx
  801d92:	5e                   	pop    %esi
  801d93:	5f                   	pop    %edi
  801d94:	5d                   	pop    %ebp
  801d95:	c3                   	ret    

00801d96 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d96:	55                   	push   %ebp
  801d97:	89 e5                	mov    %esp,%ebp
  801d99:	57                   	push   %edi
  801d9a:	56                   	push   %esi
  801d9b:	53                   	push   %ebx
  801d9c:	83 ec 28             	sub    $0x28,%esp
  801d9f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801da2:	56                   	push   %esi
  801da3:	e8 b5 f2 ff ff       	call   80105d <fd2data>
  801da8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801daa:	83 c4 10             	add    $0x10,%esp
  801dad:	bf 00 00 00 00       	mov    $0x0,%edi
  801db2:	eb 4b                	jmp    801dff <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801db4:	89 da                	mov    %ebx,%edx
  801db6:	89 f0                	mov    %esi,%eax
  801db8:	e8 6d ff ff ff       	call   801d2a <_pipeisclosed>
  801dbd:	85 c0                	test   %eax,%eax
  801dbf:	75 48                	jne    801e09 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801dc1:	e8 86 ed ff ff       	call   800b4c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801dc6:	8b 43 04             	mov    0x4(%ebx),%eax
  801dc9:	8b 0b                	mov    (%ebx),%ecx
  801dcb:	8d 51 20             	lea    0x20(%ecx),%edx
  801dce:	39 d0                	cmp    %edx,%eax
  801dd0:	73 e2                	jae    801db4 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801dd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dd5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801dd9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ddc:	89 c2                	mov    %eax,%edx
  801dde:	c1 fa 1f             	sar    $0x1f,%edx
  801de1:	89 d1                	mov    %edx,%ecx
  801de3:	c1 e9 1b             	shr    $0x1b,%ecx
  801de6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801de9:	83 e2 1f             	and    $0x1f,%edx
  801dec:	29 ca                	sub    %ecx,%edx
  801dee:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801df2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801df6:	83 c0 01             	add    $0x1,%eax
  801df9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dfc:	83 c7 01             	add    $0x1,%edi
  801dff:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e02:	75 c2                	jne    801dc6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e04:	8b 45 10             	mov    0x10(%ebp),%eax
  801e07:	eb 05                	jmp    801e0e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e09:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e11:	5b                   	pop    %ebx
  801e12:	5e                   	pop    %esi
  801e13:	5f                   	pop    %edi
  801e14:	5d                   	pop    %ebp
  801e15:	c3                   	ret    

00801e16 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e16:	55                   	push   %ebp
  801e17:	89 e5                	mov    %esp,%ebp
  801e19:	57                   	push   %edi
  801e1a:	56                   	push   %esi
  801e1b:	53                   	push   %ebx
  801e1c:	83 ec 18             	sub    $0x18,%esp
  801e1f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e22:	57                   	push   %edi
  801e23:	e8 35 f2 ff ff       	call   80105d <fd2data>
  801e28:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e2a:	83 c4 10             	add    $0x10,%esp
  801e2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e32:	eb 3d                	jmp    801e71 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e34:	85 db                	test   %ebx,%ebx
  801e36:	74 04                	je     801e3c <devpipe_read+0x26>
				return i;
  801e38:	89 d8                	mov    %ebx,%eax
  801e3a:	eb 44                	jmp    801e80 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e3c:	89 f2                	mov    %esi,%edx
  801e3e:	89 f8                	mov    %edi,%eax
  801e40:	e8 e5 fe ff ff       	call   801d2a <_pipeisclosed>
  801e45:	85 c0                	test   %eax,%eax
  801e47:	75 32                	jne    801e7b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e49:	e8 fe ec ff ff       	call   800b4c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e4e:	8b 06                	mov    (%esi),%eax
  801e50:	3b 46 04             	cmp    0x4(%esi),%eax
  801e53:	74 df                	je     801e34 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e55:	99                   	cltd   
  801e56:	c1 ea 1b             	shr    $0x1b,%edx
  801e59:	01 d0                	add    %edx,%eax
  801e5b:	83 e0 1f             	and    $0x1f,%eax
  801e5e:	29 d0                	sub    %edx,%eax
  801e60:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e68:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e6b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e6e:	83 c3 01             	add    $0x1,%ebx
  801e71:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e74:	75 d8                	jne    801e4e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e76:	8b 45 10             	mov    0x10(%ebp),%eax
  801e79:	eb 05                	jmp    801e80 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e7b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e83:	5b                   	pop    %ebx
  801e84:	5e                   	pop    %esi
  801e85:	5f                   	pop    %edi
  801e86:	5d                   	pop    %ebp
  801e87:	c3                   	ret    

00801e88 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e88:	55                   	push   %ebp
  801e89:	89 e5                	mov    %esp,%ebp
  801e8b:	56                   	push   %esi
  801e8c:	53                   	push   %ebx
  801e8d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e90:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e93:	50                   	push   %eax
  801e94:	e8 db f1 ff ff       	call   801074 <fd_alloc>
  801e99:	83 c4 10             	add    $0x10,%esp
  801e9c:	89 c2                	mov    %eax,%edx
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	0f 88 2c 01 00 00    	js     801fd2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ea6:	83 ec 04             	sub    $0x4,%esp
  801ea9:	68 07 04 00 00       	push   $0x407
  801eae:	ff 75 f4             	pushl  -0xc(%ebp)
  801eb1:	6a 00                	push   $0x0
  801eb3:	e8 b3 ec ff ff       	call   800b6b <sys_page_alloc>
  801eb8:	83 c4 10             	add    $0x10,%esp
  801ebb:	89 c2                	mov    %eax,%edx
  801ebd:	85 c0                	test   %eax,%eax
  801ebf:	0f 88 0d 01 00 00    	js     801fd2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ec5:	83 ec 0c             	sub    $0xc,%esp
  801ec8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ecb:	50                   	push   %eax
  801ecc:	e8 a3 f1 ff ff       	call   801074 <fd_alloc>
  801ed1:	89 c3                	mov    %eax,%ebx
  801ed3:	83 c4 10             	add    $0x10,%esp
  801ed6:	85 c0                	test   %eax,%eax
  801ed8:	0f 88 e2 00 00 00    	js     801fc0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ede:	83 ec 04             	sub    $0x4,%esp
  801ee1:	68 07 04 00 00       	push   $0x407
  801ee6:	ff 75 f0             	pushl  -0x10(%ebp)
  801ee9:	6a 00                	push   $0x0
  801eeb:	e8 7b ec ff ff       	call   800b6b <sys_page_alloc>
  801ef0:	89 c3                	mov    %eax,%ebx
  801ef2:	83 c4 10             	add    $0x10,%esp
  801ef5:	85 c0                	test   %eax,%eax
  801ef7:	0f 88 c3 00 00 00    	js     801fc0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801efd:	83 ec 0c             	sub    $0xc,%esp
  801f00:	ff 75 f4             	pushl  -0xc(%ebp)
  801f03:	e8 55 f1 ff ff       	call   80105d <fd2data>
  801f08:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f0a:	83 c4 0c             	add    $0xc,%esp
  801f0d:	68 07 04 00 00       	push   $0x407
  801f12:	50                   	push   %eax
  801f13:	6a 00                	push   $0x0
  801f15:	e8 51 ec ff ff       	call   800b6b <sys_page_alloc>
  801f1a:	89 c3                	mov    %eax,%ebx
  801f1c:	83 c4 10             	add    $0x10,%esp
  801f1f:	85 c0                	test   %eax,%eax
  801f21:	0f 88 89 00 00 00    	js     801fb0 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f27:	83 ec 0c             	sub    $0xc,%esp
  801f2a:	ff 75 f0             	pushl  -0x10(%ebp)
  801f2d:	e8 2b f1 ff ff       	call   80105d <fd2data>
  801f32:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f39:	50                   	push   %eax
  801f3a:	6a 00                	push   $0x0
  801f3c:	56                   	push   %esi
  801f3d:	6a 00                	push   $0x0
  801f3f:	e8 6a ec ff ff       	call   800bae <sys_page_map>
  801f44:	89 c3                	mov    %eax,%ebx
  801f46:	83 c4 20             	add    $0x20,%esp
  801f49:	85 c0                	test   %eax,%eax
  801f4b:	78 55                	js     801fa2 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f4d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f56:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f5b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f62:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f6b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f70:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f77:	83 ec 0c             	sub    $0xc,%esp
  801f7a:	ff 75 f4             	pushl  -0xc(%ebp)
  801f7d:	e8 cb f0 ff ff       	call   80104d <fd2num>
  801f82:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f85:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f87:	83 c4 04             	add    $0x4,%esp
  801f8a:	ff 75 f0             	pushl  -0x10(%ebp)
  801f8d:	e8 bb f0 ff ff       	call   80104d <fd2num>
  801f92:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f95:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f98:	83 c4 10             	add    $0x10,%esp
  801f9b:	ba 00 00 00 00       	mov    $0x0,%edx
  801fa0:	eb 30                	jmp    801fd2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801fa2:	83 ec 08             	sub    $0x8,%esp
  801fa5:	56                   	push   %esi
  801fa6:	6a 00                	push   $0x0
  801fa8:	e8 43 ec ff ff       	call   800bf0 <sys_page_unmap>
  801fad:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801fb0:	83 ec 08             	sub    $0x8,%esp
  801fb3:	ff 75 f0             	pushl  -0x10(%ebp)
  801fb6:	6a 00                	push   $0x0
  801fb8:	e8 33 ec ff ff       	call   800bf0 <sys_page_unmap>
  801fbd:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801fc0:	83 ec 08             	sub    $0x8,%esp
  801fc3:	ff 75 f4             	pushl  -0xc(%ebp)
  801fc6:	6a 00                	push   $0x0
  801fc8:	e8 23 ec ff ff       	call   800bf0 <sys_page_unmap>
  801fcd:	83 c4 10             	add    $0x10,%esp
  801fd0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801fd2:	89 d0                	mov    %edx,%eax
  801fd4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fd7:	5b                   	pop    %ebx
  801fd8:	5e                   	pop    %esi
  801fd9:	5d                   	pop    %ebp
  801fda:	c3                   	ret    

00801fdb <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801fdb:	55                   	push   %ebp
  801fdc:	89 e5                	mov    %esp,%ebp
  801fde:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fe1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fe4:	50                   	push   %eax
  801fe5:	ff 75 08             	pushl  0x8(%ebp)
  801fe8:	e8 d6 f0 ff ff       	call   8010c3 <fd_lookup>
  801fed:	83 c4 10             	add    $0x10,%esp
  801ff0:	85 c0                	test   %eax,%eax
  801ff2:	78 18                	js     80200c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ff4:	83 ec 0c             	sub    $0xc,%esp
  801ff7:	ff 75 f4             	pushl  -0xc(%ebp)
  801ffa:	e8 5e f0 ff ff       	call   80105d <fd2data>
	return _pipeisclosed(fd, p);
  801fff:	89 c2                	mov    %eax,%edx
  802001:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802004:	e8 21 fd ff ff       	call   801d2a <_pipeisclosed>
  802009:	83 c4 10             	add    $0x10,%esp
}
  80200c:	c9                   	leave  
  80200d:	c3                   	ret    

0080200e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80200e:	55                   	push   %ebp
  80200f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802011:	b8 00 00 00 00       	mov    $0x0,%eax
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    

00802018 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802018:	55                   	push   %ebp
  802019:	89 e5                	mov    %esp,%ebp
  80201b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80201e:	68 3f 2b 80 00       	push   $0x802b3f
  802023:	ff 75 0c             	pushl  0xc(%ebp)
  802026:	e8 3d e7 ff ff       	call   800768 <strcpy>
	return 0;
}
  80202b:	b8 00 00 00 00       	mov    $0x0,%eax
  802030:	c9                   	leave  
  802031:	c3                   	ret    

00802032 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802032:	55                   	push   %ebp
  802033:	89 e5                	mov    %esp,%ebp
  802035:	57                   	push   %edi
  802036:	56                   	push   %esi
  802037:	53                   	push   %ebx
  802038:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80203e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802043:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802049:	eb 2d                	jmp    802078 <devcons_write+0x46>
		m = n - tot;
  80204b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80204e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802050:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802053:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802058:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80205b:	83 ec 04             	sub    $0x4,%esp
  80205e:	53                   	push   %ebx
  80205f:	03 45 0c             	add    0xc(%ebp),%eax
  802062:	50                   	push   %eax
  802063:	57                   	push   %edi
  802064:	e8 91 e8 ff ff       	call   8008fa <memmove>
		sys_cputs(buf, m);
  802069:	83 c4 08             	add    $0x8,%esp
  80206c:	53                   	push   %ebx
  80206d:	57                   	push   %edi
  80206e:	e8 3c ea ff ff       	call   800aaf <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802073:	01 de                	add    %ebx,%esi
  802075:	83 c4 10             	add    $0x10,%esp
  802078:	89 f0                	mov    %esi,%eax
  80207a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80207d:	72 cc                	jb     80204b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80207f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802082:	5b                   	pop    %ebx
  802083:	5e                   	pop    %esi
  802084:	5f                   	pop    %edi
  802085:	5d                   	pop    %ebp
  802086:	c3                   	ret    

00802087 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802087:	55                   	push   %ebp
  802088:	89 e5                	mov    %esp,%ebp
  80208a:	83 ec 08             	sub    $0x8,%esp
  80208d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802092:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802096:	74 2a                	je     8020c2 <devcons_read+0x3b>
  802098:	eb 05                	jmp    80209f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80209a:	e8 ad ea ff ff       	call   800b4c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80209f:	e8 29 ea ff ff       	call   800acd <sys_cgetc>
  8020a4:	85 c0                	test   %eax,%eax
  8020a6:	74 f2                	je     80209a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8020a8:	85 c0                	test   %eax,%eax
  8020aa:	78 16                	js     8020c2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8020ac:	83 f8 04             	cmp    $0x4,%eax
  8020af:	74 0c                	je     8020bd <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8020b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020b4:	88 02                	mov    %al,(%edx)
	return 1;
  8020b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020bb:	eb 05                	jmp    8020c2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020bd:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020c2:	c9                   	leave  
  8020c3:	c3                   	ret    

008020c4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020c4:	55                   	push   %ebp
  8020c5:	89 e5                	mov    %esp,%ebp
  8020c7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8020cd:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020d0:	6a 01                	push   $0x1
  8020d2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020d5:	50                   	push   %eax
  8020d6:	e8 d4 e9 ff ff       	call   800aaf <sys_cputs>
}
  8020db:	83 c4 10             	add    $0x10,%esp
  8020de:	c9                   	leave  
  8020df:	c3                   	ret    

008020e0 <getchar>:

int
getchar(void)
{
  8020e0:	55                   	push   %ebp
  8020e1:	89 e5                	mov    %esp,%ebp
  8020e3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020e6:	6a 01                	push   $0x1
  8020e8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020eb:	50                   	push   %eax
  8020ec:	6a 00                	push   $0x0
  8020ee:	e8 36 f2 ff ff       	call   801329 <read>
	if (r < 0)
  8020f3:	83 c4 10             	add    $0x10,%esp
  8020f6:	85 c0                	test   %eax,%eax
  8020f8:	78 0f                	js     802109 <getchar+0x29>
		return r;
	if (r < 1)
  8020fa:	85 c0                	test   %eax,%eax
  8020fc:	7e 06                	jle    802104 <getchar+0x24>
		return -E_EOF;
	return c;
  8020fe:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802102:	eb 05                	jmp    802109 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802104:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802109:	c9                   	leave  
  80210a:	c3                   	ret    

0080210b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80210b:	55                   	push   %ebp
  80210c:	89 e5                	mov    %esp,%ebp
  80210e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802111:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802114:	50                   	push   %eax
  802115:	ff 75 08             	pushl  0x8(%ebp)
  802118:	e8 a6 ef ff ff       	call   8010c3 <fd_lookup>
  80211d:	83 c4 10             	add    $0x10,%esp
  802120:	85 c0                	test   %eax,%eax
  802122:	78 11                	js     802135 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802124:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802127:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80212d:	39 10                	cmp    %edx,(%eax)
  80212f:	0f 94 c0             	sete   %al
  802132:	0f b6 c0             	movzbl %al,%eax
}
  802135:	c9                   	leave  
  802136:	c3                   	ret    

00802137 <opencons>:

int
opencons(void)
{
  802137:	55                   	push   %ebp
  802138:	89 e5                	mov    %esp,%ebp
  80213a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80213d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802140:	50                   	push   %eax
  802141:	e8 2e ef ff ff       	call   801074 <fd_alloc>
  802146:	83 c4 10             	add    $0x10,%esp
		return r;
  802149:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80214b:	85 c0                	test   %eax,%eax
  80214d:	78 3e                	js     80218d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80214f:	83 ec 04             	sub    $0x4,%esp
  802152:	68 07 04 00 00       	push   $0x407
  802157:	ff 75 f4             	pushl  -0xc(%ebp)
  80215a:	6a 00                	push   $0x0
  80215c:	e8 0a ea ff ff       	call   800b6b <sys_page_alloc>
  802161:	83 c4 10             	add    $0x10,%esp
		return r;
  802164:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802166:	85 c0                	test   %eax,%eax
  802168:	78 23                	js     80218d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80216a:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802170:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802173:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802175:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802178:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80217f:	83 ec 0c             	sub    $0xc,%esp
  802182:	50                   	push   %eax
  802183:	e8 c5 ee ff ff       	call   80104d <fd2num>
  802188:	89 c2                	mov    %eax,%edx
  80218a:	83 c4 10             	add    $0x10,%esp
}
  80218d:	89 d0                	mov    %edx,%eax
  80218f:	c9                   	leave  
  802190:	c3                   	ret    

00802191 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802191:	55                   	push   %ebp
  802192:	89 e5                	mov    %esp,%ebp
  802194:	56                   	push   %esi
  802195:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802196:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802199:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80219f:	e8 89 e9 ff ff       	call   800b2d <sys_getenvid>
  8021a4:	83 ec 0c             	sub    $0xc,%esp
  8021a7:	ff 75 0c             	pushl  0xc(%ebp)
  8021aa:	ff 75 08             	pushl  0x8(%ebp)
  8021ad:	56                   	push   %esi
  8021ae:	50                   	push   %eax
  8021af:	68 4c 2b 80 00       	push   $0x802b4c
  8021b4:	e8 2a e0 ff ff       	call   8001e3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8021b9:	83 c4 18             	add    $0x18,%esp
  8021bc:	53                   	push   %ebx
  8021bd:	ff 75 10             	pushl  0x10(%ebp)
  8021c0:	e8 cd df ff ff       	call   800192 <vcprintf>
	cprintf("\n");
  8021c5:	c7 04 24 2f 26 80 00 	movl   $0x80262f,(%esp)
  8021cc:	e8 12 e0 ff ff       	call   8001e3 <cprintf>
  8021d1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8021d4:	cc                   	int3   
  8021d5:	eb fd                	jmp    8021d4 <_panic+0x43>

008021d7 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8021d7:	55                   	push   %ebp
  8021d8:	89 e5                	mov    %esp,%ebp
  8021da:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8021dd:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8021e4:	75 2e                	jne    802214 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8021e6:	e8 42 e9 ff ff       	call   800b2d <sys_getenvid>
  8021eb:	83 ec 04             	sub    $0x4,%esp
  8021ee:	68 07 0e 00 00       	push   $0xe07
  8021f3:	68 00 f0 bf ee       	push   $0xeebff000
  8021f8:	50                   	push   %eax
  8021f9:	e8 6d e9 ff ff       	call   800b6b <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8021fe:	e8 2a e9 ff ff       	call   800b2d <sys_getenvid>
  802203:	83 c4 08             	add    $0x8,%esp
  802206:	68 1e 22 80 00       	push   $0x80221e
  80220b:	50                   	push   %eax
  80220c:	e8 a5 ea ff ff       	call   800cb6 <sys_env_set_pgfault_upcall>
  802211:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802214:	8b 45 08             	mov    0x8(%ebp),%eax
  802217:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80221c:	c9                   	leave  
  80221d:	c3                   	ret    

0080221e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80221e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80221f:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802224:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802226:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  802229:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  80222d:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802231:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  802234:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  802237:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  802238:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  80223b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  80223c:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  80223d:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802241:	c3                   	ret    

00802242 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802242:	55                   	push   %ebp
  802243:	89 e5                	mov    %esp,%ebp
  802245:	56                   	push   %esi
  802246:	53                   	push   %ebx
  802247:	8b 75 08             	mov    0x8(%ebp),%esi
  80224a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80224d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802250:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802252:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802257:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  80225a:	83 ec 0c             	sub    $0xc,%esp
  80225d:	50                   	push   %eax
  80225e:	e8 b8 ea ff ff       	call   800d1b <sys_ipc_recv>

	if (from_env_store != NULL)
  802263:	83 c4 10             	add    $0x10,%esp
  802266:	85 f6                	test   %esi,%esi
  802268:	74 14                	je     80227e <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  80226a:	ba 00 00 00 00       	mov    $0x0,%edx
  80226f:	85 c0                	test   %eax,%eax
  802271:	78 09                	js     80227c <ipc_recv+0x3a>
  802273:	8b 15 08 40 80 00    	mov    0x804008,%edx
  802279:	8b 52 74             	mov    0x74(%edx),%edx
  80227c:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  80227e:	85 db                	test   %ebx,%ebx
  802280:	74 14                	je     802296 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802282:	ba 00 00 00 00       	mov    $0x0,%edx
  802287:	85 c0                	test   %eax,%eax
  802289:	78 09                	js     802294 <ipc_recv+0x52>
  80228b:	8b 15 08 40 80 00    	mov    0x804008,%edx
  802291:	8b 52 78             	mov    0x78(%edx),%edx
  802294:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802296:	85 c0                	test   %eax,%eax
  802298:	78 08                	js     8022a2 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  80229a:	a1 08 40 80 00       	mov    0x804008,%eax
  80229f:	8b 40 70             	mov    0x70(%eax),%eax
}
  8022a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022a5:	5b                   	pop    %ebx
  8022a6:	5e                   	pop    %esi
  8022a7:	5d                   	pop    %ebp
  8022a8:	c3                   	ret    

008022a9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022a9:	55                   	push   %ebp
  8022aa:	89 e5                	mov    %esp,%ebp
  8022ac:	57                   	push   %edi
  8022ad:	56                   	push   %esi
  8022ae:	53                   	push   %ebx
  8022af:	83 ec 0c             	sub    $0xc,%esp
  8022b2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022b5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8022bb:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8022bd:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8022c2:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8022c5:	ff 75 14             	pushl  0x14(%ebp)
  8022c8:	53                   	push   %ebx
  8022c9:	56                   	push   %esi
  8022ca:	57                   	push   %edi
  8022cb:	e8 28 ea ff ff       	call   800cf8 <sys_ipc_try_send>

		if (err < 0) {
  8022d0:	83 c4 10             	add    $0x10,%esp
  8022d3:	85 c0                	test   %eax,%eax
  8022d5:	79 1e                	jns    8022f5 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8022d7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022da:	75 07                	jne    8022e3 <ipc_send+0x3a>
				sys_yield();
  8022dc:	e8 6b e8 ff ff       	call   800b4c <sys_yield>
  8022e1:	eb e2                	jmp    8022c5 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8022e3:	50                   	push   %eax
  8022e4:	68 70 2b 80 00       	push   $0x802b70
  8022e9:	6a 49                	push   $0x49
  8022eb:	68 7d 2b 80 00       	push   $0x802b7d
  8022f0:	e8 9c fe ff ff       	call   802191 <_panic>
		}

	} while (err < 0);

}
  8022f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022f8:	5b                   	pop    %ebx
  8022f9:	5e                   	pop    %esi
  8022fa:	5f                   	pop    %edi
  8022fb:	5d                   	pop    %ebp
  8022fc:	c3                   	ret    

008022fd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022fd:	55                   	push   %ebp
  8022fe:	89 e5                	mov    %esp,%ebp
  802300:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802303:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802308:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80230b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802311:	8b 52 50             	mov    0x50(%edx),%edx
  802314:	39 ca                	cmp    %ecx,%edx
  802316:	75 0d                	jne    802325 <ipc_find_env+0x28>
			return envs[i].env_id;
  802318:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80231b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802320:	8b 40 48             	mov    0x48(%eax),%eax
  802323:	eb 0f                	jmp    802334 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802325:	83 c0 01             	add    $0x1,%eax
  802328:	3d 00 04 00 00       	cmp    $0x400,%eax
  80232d:	75 d9                	jne    802308 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80232f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802334:	5d                   	pop    %ebp
  802335:	c3                   	ret    

00802336 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802336:	55                   	push   %ebp
  802337:	89 e5                	mov    %esp,%ebp
  802339:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80233c:	89 d0                	mov    %edx,%eax
  80233e:	c1 e8 16             	shr    $0x16,%eax
  802341:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802348:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80234d:	f6 c1 01             	test   $0x1,%cl
  802350:	74 1d                	je     80236f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802352:	c1 ea 0c             	shr    $0xc,%edx
  802355:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80235c:	f6 c2 01             	test   $0x1,%dl
  80235f:	74 0e                	je     80236f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802361:	c1 ea 0c             	shr    $0xc,%edx
  802364:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80236b:	ef 
  80236c:	0f b7 c0             	movzwl %ax,%eax
}
  80236f:	5d                   	pop    %ebp
  802370:	c3                   	ret    
  802371:	66 90                	xchg   %ax,%ax
  802373:	66 90                	xchg   %ax,%ax
  802375:	66 90                	xchg   %ax,%ax
  802377:	66 90                	xchg   %ax,%ax
  802379:	66 90                	xchg   %ax,%ax
  80237b:	66 90                	xchg   %ax,%ax
  80237d:	66 90                	xchg   %ax,%ax
  80237f:	90                   	nop

00802380 <__udivdi3>:
  802380:	55                   	push   %ebp
  802381:	57                   	push   %edi
  802382:	56                   	push   %esi
  802383:	53                   	push   %ebx
  802384:	83 ec 1c             	sub    $0x1c,%esp
  802387:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80238b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80238f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802393:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802397:	85 f6                	test   %esi,%esi
  802399:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80239d:	89 ca                	mov    %ecx,%edx
  80239f:	89 f8                	mov    %edi,%eax
  8023a1:	75 3d                	jne    8023e0 <__udivdi3+0x60>
  8023a3:	39 cf                	cmp    %ecx,%edi
  8023a5:	0f 87 c5 00 00 00    	ja     802470 <__udivdi3+0xf0>
  8023ab:	85 ff                	test   %edi,%edi
  8023ad:	89 fd                	mov    %edi,%ebp
  8023af:	75 0b                	jne    8023bc <__udivdi3+0x3c>
  8023b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8023b6:	31 d2                	xor    %edx,%edx
  8023b8:	f7 f7                	div    %edi
  8023ba:	89 c5                	mov    %eax,%ebp
  8023bc:	89 c8                	mov    %ecx,%eax
  8023be:	31 d2                	xor    %edx,%edx
  8023c0:	f7 f5                	div    %ebp
  8023c2:	89 c1                	mov    %eax,%ecx
  8023c4:	89 d8                	mov    %ebx,%eax
  8023c6:	89 cf                	mov    %ecx,%edi
  8023c8:	f7 f5                	div    %ebp
  8023ca:	89 c3                	mov    %eax,%ebx
  8023cc:	89 d8                	mov    %ebx,%eax
  8023ce:	89 fa                	mov    %edi,%edx
  8023d0:	83 c4 1c             	add    $0x1c,%esp
  8023d3:	5b                   	pop    %ebx
  8023d4:	5e                   	pop    %esi
  8023d5:	5f                   	pop    %edi
  8023d6:	5d                   	pop    %ebp
  8023d7:	c3                   	ret    
  8023d8:	90                   	nop
  8023d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023e0:	39 ce                	cmp    %ecx,%esi
  8023e2:	77 74                	ja     802458 <__udivdi3+0xd8>
  8023e4:	0f bd fe             	bsr    %esi,%edi
  8023e7:	83 f7 1f             	xor    $0x1f,%edi
  8023ea:	0f 84 98 00 00 00    	je     802488 <__udivdi3+0x108>
  8023f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8023f5:	89 f9                	mov    %edi,%ecx
  8023f7:	89 c5                	mov    %eax,%ebp
  8023f9:	29 fb                	sub    %edi,%ebx
  8023fb:	d3 e6                	shl    %cl,%esi
  8023fd:	89 d9                	mov    %ebx,%ecx
  8023ff:	d3 ed                	shr    %cl,%ebp
  802401:	89 f9                	mov    %edi,%ecx
  802403:	d3 e0                	shl    %cl,%eax
  802405:	09 ee                	or     %ebp,%esi
  802407:	89 d9                	mov    %ebx,%ecx
  802409:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80240d:	89 d5                	mov    %edx,%ebp
  80240f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802413:	d3 ed                	shr    %cl,%ebp
  802415:	89 f9                	mov    %edi,%ecx
  802417:	d3 e2                	shl    %cl,%edx
  802419:	89 d9                	mov    %ebx,%ecx
  80241b:	d3 e8                	shr    %cl,%eax
  80241d:	09 c2                	or     %eax,%edx
  80241f:	89 d0                	mov    %edx,%eax
  802421:	89 ea                	mov    %ebp,%edx
  802423:	f7 f6                	div    %esi
  802425:	89 d5                	mov    %edx,%ebp
  802427:	89 c3                	mov    %eax,%ebx
  802429:	f7 64 24 0c          	mull   0xc(%esp)
  80242d:	39 d5                	cmp    %edx,%ebp
  80242f:	72 10                	jb     802441 <__udivdi3+0xc1>
  802431:	8b 74 24 08          	mov    0x8(%esp),%esi
  802435:	89 f9                	mov    %edi,%ecx
  802437:	d3 e6                	shl    %cl,%esi
  802439:	39 c6                	cmp    %eax,%esi
  80243b:	73 07                	jae    802444 <__udivdi3+0xc4>
  80243d:	39 d5                	cmp    %edx,%ebp
  80243f:	75 03                	jne    802444 <__udivdi3+0xc4>
  802441:	83 eb 01             	sub    $0x1,%ebx
  802444:	31 ff                	xor    %edi,%edi
  802446:	89 d8                	mov    %ebx,%eax
  802448:	89 fa                	mov    %edi,%edx
  80244a:	83 c4 1c             	add    $0x1c,%esp
  80244d:	5b                   	pop    %ebx
  80244e:	5e                   	pop    %esi
  80244f:	5f                   	pop    %edi
  802450:	5d                   	pop    %ebp
  802451:	c3                   	ret    
  802452:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802458:	31 ff                	xor    %edi,%edi
  80245a:	31 db                	xor    %ebx,%ebx
  80245c:	89 d8                	mov    %ebx,%eax
  80245e:	89 fa                	mov    %edi,%edx
  802460:	83 c4 1c             	add    $0x1c,%esp
  802463:	5b                   	pop    %ebx
  802464:	5e                   	pop    %esi
  802465:	5f                   	pop    %edi
  802466:	5d                   	pop    %ebp
  802467:	c3                   	ret    
  802468:	90                   	nop
  802469:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802470:	89 d8                	mov    %ebx,%eax
  802472:	f7 f7                	div    %edi
  802474:	31 ff                	xor    %edi,%edi
  802476:	89 c3                	mov    %eax,%ebx
  802478:	89 d8                	mov    %ebx,%eax
  80247a:	89 fa                	mov    %edi,%edx
  80247c:	83 c4 1c             	add    $0x1c,%esp
  80247f:	5b                   	pop    %ebx
  802480:	5e                   	pop    %esi
  802481:	5f                   	pop    %edi
  802482:	5d                   	pop    %ebp
  802483:	c3                   	ret    
  802484:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802488:	39 ce                	cmp    %ecx,%esi
  80248a:	72 0c                	jb     802498 <__udivdi3+0x118>
  80248c:	31 db                	xor    %ebx,%ebx
  80248e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802492:	0f 87 34 ff ff ff    	ja     8023cc <__udivdi3+0x4c>
  802498:	bb 01 00 00 00       	mov    $0x1,%ebx
  80249d:	e9 2a ff ff ff       	jmp    8023cc <__udivdi3+0x4c>
  8024a2:	66 90                	xchg   %ax,%ax
  8024a4:	66 90                	xchg   %ax,%ax
  8024a6:	66 90                	xchg   %ax,%ax
  8024a8:	66 90                	xchg   %ax,%ax
  8024aa:	66 90                	xchg   %ax,%ax
  8024ac:	66 90                	xchg   %ax,%ax
  8024ae:	66 90                	xchg   %ax,%ax

008024b0 <__umoddi3>:
  8024b0:	55                   	push   %ebp
  8024b1:	57                   	push   %edi
  8024b2:	56                   	push   %esi
  8024b3:	53                   	push   %ebx
  8024b4:	83 ec 1c             	sub    $0x1c,%esp
  8024b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8024bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8024bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024c7:	85 d2                	test   %edx,%edx
  8024c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8024cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024d1:	89 f3                	mov    %esi,%ebx
  8024d3:	89 3c 24             	mov    %edi,(%esp)
  8024d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024da:	75 1c                	jne    8024f8 <__umoddi3+0x48>
  8024dc:	39 f7                	cmp    %esi,%edi
  8024de:	76 50                	jbe    802530 <__umoddi3+0x80>
  8024e0:	89 c8                	mov    %ecx,%eax
  8024e2:	89 f2                	mov    %esi,%edx
  8024e4:	f7 f7                	div    %edi
  8024e6:	89 d0                	mov    %edx,%eax
  8024e8:	31 d2                	xor    %edx,%edx
  8024ea:	83 c4 1c             	add    $0x1c,%esp
  8024ed:	5b                   	pop    %ebx
  8024ee:	5e                   	pop    %esi
  8024ef:	5f                   	pop    %edi
  8024f0:	5d                   	pop    %ebp
  8024f1:	c3                   	ret    
  8024f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024f8:	39 f2                	cmp    %esi,%edx
  8024fa:	89 d0                	mov    %edx,%eax
  8024fc:	77 52                	ja     802550 <__umoddi3+0xa0>
  8024fe:	0f bd ea             	bsr    %edx,%ebp
  802501:	83 f5 1f             	xor    $0x1f,%ebp
  802504:	75 5a                	jne    802560 <__umoddi3+0xb0>
  802506:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80250a:	0f 82 e0 00 00 00    	jb     8025f0 <__umoddi3+0x140>
  802510:	39 0c 24             	cmp    %ecx,(%esp)
  802513:	0f 86 d7 00 00 00    	jbe    8025f0 <__umoddi3+0x140>
  802519:	8b 44 24 08          	mov    0x8(%esp),%eax
  80251d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802521:	83 c4 1c             	add    $0x1c,%esp
  802524:	5b                   	pop    %ebx
  802525:	5e                   	pop    %esi
  802526:	5f                   	pop    %edi
  802527:	5d                   	pop    %ebp
  802528:	c3                   	ret    
  802529:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802530:	85 ff                	test   %edi,%edi
  802532:	89 fd                	mov    %edi,%ebp
  802534:	75 0b                	jne    802541 <__umoddi3+0x91>
  802536:	b8 01 00 00 00       	mov    $0x1,%eax
  80253b:	31 d2                	xor    %edx,%edx
  80253d:	f7 f7                	div    %edi
  80253f:	89 c5                	mov    %eax,%ebp
  802541:	89 f0                	mov    %esi,%eax
  802543:	31 d2                	xor    %edx,%edx
  802545:	f7 f5                	div    %ebp
  802547:	89 c8                	mov    %ecx,%eax
  802549:	f7 f5                	div    %ebp
  80254b:	89 d0                	mov    %edx,%eax
  80254d:	eb 99                	jmp    8024e8 <__umoddi3+0x38>
  80254f:	90                   	nop
  802550:	89 c8                	mov    %ecx,%eax
  802552:	89 f2                	mov    %esi,%edx
  802554:	83 c4 1c             	add    $0x1c,%esp
  802557:	5b                   	pop    %ebx
  802558:	5e                   	pop    %esi
  802559:	5f                   	pop    %edi
  80255a:	5d                   	pop    %ebp
  80255b:	c3                   	ret    
  80255c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802560:	8b 34 24             	mov    (%esp),%esi
  802563:	bf 20 00 00 00       	mov    $0x20,%edi
  802568:	89 e9                	mov    %ebp,%ecx
  80256a:	29 ef                	sub    %ebp,%edi
  80256c:	d3 e0                	shl    %cl,%eax
  80256e:	89 f9                	mov    %edi,%ecx
  802570:	89 f2                	mov    %esi,%edx
  802572:	d3 ea                	shr    %cl,%edx
  802574:	89 e9                	mov    %ebp,%ecx
  802576:	09 c2                	or     %eax,%edx
  802578:	89 d8                	mov    %ebx,%eax
  80257a:	89 14 24             	mov    %edx,(%esp)
  80257d:	89 f2                	mov    %esi,%edx
  80257f:	d3 e2                	shl    %cl,%edx
  802581:	89 f9                	mov    %edi,%ecx
  802583:	89 54 24 04          	mov    %edx,0x4(%esp)
  802587:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80258b:	d3 e8                	shr    %cl,%eax
  80258d:	89 e9                	mov    %ebp,%ecx
  80258f:	89 c6                	mov    %eax,%esi
  802591:	d3 e3                	shl    %cl,%ebx
  802593:	89 f9                	mov    %edi,%ecx
  802595:	89 d0                	mov    %edx,%eax
  802597:	d3 e8                	shr    %cl,%eax
  802599:	89 e9                	mov    %ebp,%ecx
  80259b:	09 d8                	or     %ebx,%eax
  80259d:	89 d3                	mov    %edx,%ebx
  80259f:	89 f2                	mov    %esi,%edx
  8025a1:	f7 34 24             	divl   (%esp)
  8025a4:	89 d6                	mov    %edx,%esi
  8025a6:	d3 e3                	shl    %cl,%ebx
  8025a8:	f7 64 24 04          	mull   0x4(%esp)
  8025ac:	39 d6                	cmp    %edx,%esi
  8025ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025b2:	89 d1                	mov    %edx,%ecx
  8025b4:	89 c3                	mov    %eax,%ebx
  8025b6:	72 08                	jb     8025c0 <__umoddi3+0x110>
  8025b8:	75 11                	jne    8025cb <__umoddi3+0x11b>
  8025ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8025be:	73 0b                	jae    8025cb <__umoddi3+0x11b>
  8025c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8025c4:	1b 14 24             	sbb    (%esp),%edx
  8025c7:	89 d1                	mov    %edx,%ecx
  8025c9:	89 c3                	mov    %eax,%ebx
  8025cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8025cf:	29 da                	sub    %ebx,%edx
  8025d1:	19 ce                	sbb    %ecx,%esi
  8025d3:	89 f9                	mov    %edi,%ecx
  8025d5:	89 f0                	mov    %esi,%eax
  8025d7:	d3 e0                	shl    %cl,%eax
  8025d9:	89 e9                	mov    %ebp,%ecx
  8025db:	d3 ea                	shr    %cl,%edx
  8025dd:	89 e9                	mov    %ebp,%ecx
  8025df:	d3 ee                	shr    %cl,%esi
  8025e1:	09 d0                	or     %edx,%eax
  8025e3:	89 f2                	mov    %esi,%edx
  8025e5:	83 c4 1c             	add    $0x1c,%esp
  8025e8:	5b                   	pop    %ebx
  8025e9:	5e                   	pop    %esi
  8025ea:	5f                   	pop    %edi
  8025eb:	5d                   	pop    %ebp
  8025ec:	c3                   	ret    
  8025ed:	8d 76 00             	lea    0x0(%esi),%esi
  8025f0:	29 f9                	sub    %edi,%ecx
  8025f2:	19 d6                	sbb    %edx,%esi
  8025f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025fc:	e9 18 ff ff ff       	jmp    802519 <__umoddi3+0x69>
