
obj/user/yield.debug:     file format elf32-i386


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
  80002c:	e8 69 00 00 00       	call   80009a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int i;
	// cprintf("[%p]\n", umain);
	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 08 40 80 00       	mov    0x804008,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 c0 22 80 00       	push   $0x8022c0
  800048:	e8 40 01 00 00       	call   80018d <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 9c 0a 00 00       	call   800af6 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 08 40 80 00       	mov    0x804008,%eax
	int i;
	// cprintf("[%p]\n", umain);
	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  80005f:	8b 40 48             	mov    0x48(%eax),%eax
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 e0 22 80 00       	push   $0x8022e0
  80006c:	e8 1c 01 00 00       	call   80018d <cprintf>
umain(int argc, char **argv)
{
	int i;
	// cprintf("[%p]\n", umain);
	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800071:	83 c3 01             	add    $0x1,%ebx
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	83 fb 05             	cmp    $0x5,%ebx
  80007a:	75 d9                	jne    800055 <umain+0x22>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007c:	a1 08 40 80 00       	mov    0x804008,%eax
  800081:	8b 40 48             	mov    0x48(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 0c 23 80 00       	push   $0x80230c
  80008d:	e8 fb 00 00 00       	call   80018d <cprintf>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000a5:	e8 2d 0a 00 00       	call   800ad7 <sys_getenvid>
  8000aa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000af:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b7:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bc:	85 db                	test   %ebx,%ebx
  8000be:	7e 07                	jle    8000c7 <libmain+0x2d>
		binaryname = argv[0];
  8000c0:	8b 06                	mov    (%esi),%eax
  8000c2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000c7:	83 ec 08             	sub    $0x8,%esp
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
  8000cc:	e8 62 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d1:	e8 0a 00 00 00       	call   8000e0 <exit>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000e6:	e8 47 0e 00 00       	call   800f32 <close_all>
	sys_env_destroy(0);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	6a 00                	push   $0x0
  8000f0:	e8 a1 09 00 00       	call   800a96 <sys_env_destroy>
}
  8000f5:	83 c4 10             	add    $0x10,%esp
  8000f8:	c9                   	leave  
  8000f9:	c3                   	ret    

008000fa <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	53                   	push   %ebx
  8000fe:	83 ec 04             	sub    $0x4,%esp
  800101:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800104:	8b 13                	mov    (%ebx),%edx
  800106:	8d 42 01             	lea    0x1(%edx),%eax
  800109:	89 03                	mov    %eax,(%ebx)
  80010b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800112:	3d ff 00 00 00       	cmp    $0xff,%eax
  800117:	75 1a                	jne    800133 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800119:	83 ec 08             	sub    $0x8,%esp
  80011c:	68 ff 00 00 00       	push   $0xff
  800121:	8d 43 08             	lea    0x8(%ebx),%eax
  800124:	50                   	push   %eax
  800125:	e8 2f 09 00 00       	call   800a59 <sys_cputs>
		b->idx = 0;
  80012a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800130:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800133:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800137:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800145:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014c:	00 00 00 
	b.cnt = 0;
  80014f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800156:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800159:	ff 75 0c             	pushl  0xc(%ebp)
  80015c:	ff 75 08             	pushl  0x8(%ebp)
  80015f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	68 fa 00 80 00       	push   $0x8000fa
  80016b:	e8 54 01 00 00       	call   8002c4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800170:	83 c4 08             	add    $0x8,%esp
  800173:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800179:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017f:	50                   	push   %eax
  800180:	e8 d4 08 00 00       	call   800a59 <sys_cputs>

	return b.cnt;
}
  800185:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    

0080018d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800193:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800196:	50                   	push   %eax
  800197:	ff 75 08             	pushl  0x8(%ebp)
  80019a:	e8 9d ff ff ff       	call   80013c <vcprintf>
	va_end(ap);

	return cnt;
}
  80019f:	c9                   	leave  
  8001a0:	c3                   	ret    

008001a1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 1c             	sub    $0x1c,%esp
  8001aa:	89 c7                	mov    %eax,%edi
  8001ac:	89 d6                	mov    %edx,%esi
  8001ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001c5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001c8:	39 d3                	cmp    %edx,%ebx
  8001ca:	72 05                	jb     8001d1 <printnum+0x30>
  8001cc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001cf:	77 45                	ja     800216 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d1:	83 ec 0c             	sub    $0xc,%esp
  8001d4:	ff 75 18             	pushl  0x18(%ebp)
  8001d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8001da:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001dd:	53                   	push   %ebx
  8001de:	ff 75 10             	pushl  0x10(%ebp)
  8001e1:	83 ec 08             	sub    $0x8,%esp
  8001e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ea:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f0:	e8 2b 1e 00 00       	call   802020 <__udivdi3>
  8001f5:	83 c4 18             	add    $0x18,%esp
  8001f8:	52                   	push   %edx
  8001f9:	50                   	push   %eax
  8001fa:	89 f2                	mov    %esi,%edx
  8001fc:	89 f8                	mov    %edi,%eax
  8001fe:	e8 9e ff ff ff       	call   8001a1 <printnum>
  800203:	83 c4 20             	add    $0x20,%esp
  800206:	eb 18                	jmp    800220 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	56                   	push   %esi
  80020c:	ff 75 18             	pushl  0x18(%ebp)
  80020f:	ff d7                	call   *%edi
  800211:	83 c4 10             	add    $0x10,%esp
  800214:	eb 03                	jmp    800219 <printnum+0x78>
  800216:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800219:	83 eb 01             	sub    $0x1,%ebx
  80021c:	85 db                	test   %ebx,%ebx
  80021e:	7f e8                	jg     800208 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800220:	83 ec 08             	sub    $0x8,%esp
  800223:	56                   	push   %esi
  800224:	83 ec 04             	sub    $0x4,%esp
  800227:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022a:	ff 75 e0             	pushl  -0x20(%ebp)
  80022d:	ff 75 dc             	pushl  -0x24(%ebp)
  800230:	ff 75 d8             	pushl  -0x28(%ebp)
  800233:	e8 18 1f 00 00       	call   802150 <__umoddi3>
  800238:	83 c4 14             	add    $0x14,%esp
  80023b:	0f be 80 35 23 80 00 	movsbl 0x802335(%eax),%eax
  800242:	50                   	push   %eax
  800243:	ff d7                	call   *%edi
}
  800245:	83 c4 10             	add    $0x10,%esp
  800248:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024b:	5b                   	pop    %ebx
  80024c:	5e                   	pop    %esi
  80024d:	5f                   	pop    %edi
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    

00800250 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800253:	83 fa 01             	cmp    $0x1,%edx
  800256:	7e 0e                	jle    800266 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800258:	8b 10                	mov    (%eax),%edx
  80025a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025d:	89 08                	mov    %ecx,(%eax)
  80025f:	8b 02                	mov    (%edx),%eax
  800261:	8b 52 04             	mov    0x4(%edx),%edx
  800264:	eb 22                	jmp    800288 <getuint+0x38>
	else if (lflag)
  800266:	85 d2                	test   %edx,%edx
  800268:	74 10                	je     80027a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80026a:	8b 10                	mov    (%eax),%edx
  80026c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026f:	89 08                	mov    %ecx,(%eax)
  800271:	8b 02                	mov    (%edx),%eax
  800273:	ba 00 00 00 00       	mov    $0x0,%edx
  800278:	eb 0e                	jmp    800288 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80027a:	8b 10                	mov    (%eax),%edx
  80027c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027f:	89 08                	mov    %ecx,(%eax)
  800281:	8b 02                	mov    (%edx),%eax
  800283:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800290:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800294:	8b 10                	mov    (%eax),%edx
  800296:	3b 50 04             	cmp    0x4(%eax),%edx
  800299:	73 0a                	jae    8002a5 <sprintputch+0x1b>
		*b->buf++ = ch;
  80029b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80029e:	89 08                	mov    %ecx,(%eax)
  8002a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a3:	88 02                	mov    %al,(%edx)
}
  8002a5:	5d                   	pop    %ebp
  8002a6:	c3                   	ret    

008002a7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ad:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b0:	50                   	push   %eax
  8002b1:	ff 75 10             	pushl  0x10(%ebp)
  8002b4:	ff 75 0c             	pushl  0xc(%ebp)
  8002b7:	ff 75 08             	pushl  0x8(%ebp)
  8002ba:	e8 05 00 00 00       	call   8002c4 <vprintfmt>
	va_end(ap);
}
  8002bf:	83 c4 10             	add    $0x10,%esp
  8002c2:	c9                   	leave  
  8002c3:	c3                   	ret    

008002c4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	57                   	push   %edi
  8002c8:	56                   	push   %esi
  8002c9:	53                   	push   %ebx
  8002ca:	83 ec 2c             	sub    $0x2c,%esp
  8002cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d6:	eb 12                	jmp    8002ea <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d8:	85 c0                	test   %eax,%eax
  8002da:	0f 84 89 03 00 00    	je     800669 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002e0:	83 ec 08             	sub    $0x8,%esp
  8002e3:	53                   	push   %ebx
  8002e4:	50                   	push   %eax
  8002e5:	ff d6                	call   *%esi
  8002e7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ea:	83 c7 01             	add    $0x1,%edi
  8002ed:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002f1:	83 f8 25             	cmp    $0x25,%eax
  8002f4:	75 e2                	jne    8002d8 <vprintfmt+0x14>
  8002f6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002fa:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800301:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800308:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80030f:	ba 00 00 00 00       	mov    $0x0,%edx
  800314:	eb 07                	jmp    80031d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800316:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800319:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031d:	8d 47 01             	lea    0x1(%edi),%eax
  800320:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800323:	0f b6 07             	movzbl (%edi),%eax
  800326:	0f b6 c8             	movzbl %al,%ecx
  800329:	83 e8 23             	sub    $0x23,%eax
  80032c:	3c 55                	cmp    $0x55,%al
  80032e:	0f 87 1a 03 00 00    	ja     80064e <vprintfmt+0x38a>
  800334:	0f b6 c0             	movzbl %al,%eax
  800337:	ff 24 85 80 24 80 00 	jmp    *0x802480(,%eax,4)
  80033e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800341:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800345:	eb d6                	jmp    80031d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800347:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80034a:	b8 00 00 00 00       	mov    $0x0,%eax
  80034f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800352:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800355:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800359:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80035c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80035f:	83 fa 09             	cmp    $0x9,%edx
  800362:	77 39                	ja     80039d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800364:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800367:	eb e9                	jmp    800352 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800369:	8b 45 14             	mov    0x14(%ebp),%eax
  80036c:	8d 48 04             	lea    0x4(%eax),%ecx
  80036f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800372:	8b 00                	mov    (%eax),%eax
  800374:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80037a:	eb 27                	jmp    8003a3 <vprintfmt+0xdf>
  80037c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80037f:	85 c0                	test   %eax,%eax
  800381:	b9 00 00 00 00       	mov    $0x0,%ecx
  800386:	0f 49 c8             	cmovns %eax,%ecx
  800389:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80038f:	eb 8c                	jmp    80031d <vprintfmt+0x59>
  800391:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800394:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80039b:	eb 80                	jmp    80031d <vprintfmt+0x59>
  80039d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003a0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003a3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a7:	0f 89 70 ff ff ff    	jns    80031d <vprintfmt+0x59>
				width = precision, precision = -1;
  8003ad:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ba:	e9 5e ff ff ff       	jmp    80031d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003bf:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003c5:	e9 53 ff ff ff       	jmp    80031d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cd:	8d 50 04             	lea    0x4(%eax),%edx
  8003d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d3:	83 ec 08             	sub    $0x8,%esp
  8003d6:	53                   	push   %ebx
  8003d7:	ff 30                	pushl  (%eax)
  8003d9:	ff d6                	call   *%esi
			break;
  8003db:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003e1:	e9 04 ff ff ff       	jmp    8002ea <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e9:	8d 50 04             	lea    0x4(%eax),%edx
  8003ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ef:	8b 00                	mov    (%eax),%eax
  8003f1:	99                   	cltd   
  8003f2:	31 d0                	xor    %edx,%eax
  8003f4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f6:	83 f8 0f             	cmp    $0xf,%eax
  8003f9:	7f 0b                	jg     800406 <vprintfmt+0x142>
  8003fb:	8b 14 85 e0 25 80 00 	mov    0x8025e0(,%eax,4),%edx
  800402:	85 d2                	test   %edx,%edx
  800404:	75 18                	jne    80041e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800406:	50                   	push   %eax
  800407:	68 4d 23 80 00       	push   $0x80234d
  80040c:	53                   	push   %ebx
  80040d:	56                   	push   %esi
  80040e:	e8 94 fe ff ff       	call   8002a7 <printfmt>
  800413:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800419:	e9 cc fe ff ff       	jmp    8002ea <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80041e:	52                   	push   %edx
  80041f:	68 15 27 80 00       	push   $0x802715
  800424:	53                   	push   %ebx
  800425:	56                   	push   %esi
  800426:	e8 7c fe ff ff       	call   8002a7 <printfmt>
  80042b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800431:	e9 b4 fe ff ff       	jmp    8002ea <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800436:	8b 45 14             	mov    0x14(%ebp),%eax
  800439:	8d 50 04             	lea    0x4(%eax),%edx
  80043c:	89 55 14             	mov    %edx,0x14(%ebp)
  80043f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800441:	85 ff                	test   %edi,%edi
  800443:	b8 46 23 80 00       	mov    $0x802346,%eax
  800448:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80044b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044f:	0f 8e 94 00 00 00    	jle    8004e9 <vprintfmt+0x225>
  800455:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800459:	0f 84 98 00 00 00    	je     8004f7 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	ff 75 d0             	pushl  -0x30(%ebp)
  800465:	57                   	push   %edi
  800466:	e8 86 02 00 00       	call   8006f1 <strnlen>
  80046b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80046e:	29 c1                	sub    %eax,%ecx
  800470:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800473:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800476:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80047a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800480:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800482:	eb 0f                	jmp    800493 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800484:	83 ec 08             	sub    $0x8,%esp
  800487:	53                   	push   %ebx
  800488:	ff 75 e0             	pushl  -0x20(%ebp)
  80048b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048d:	83 ef 01             	sub    $0x1,%edi
  800490:	83 c4 10             	add    $0x10,%esp
  800493:	85 ff                	test   %edi,%edi
  800495:	7f ed                	jg     800484 <vprintfmt+0x1c0>
  800497:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80049a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80049d:	85 c9                	test   %ecx,%ecx
  80049f:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a4:	0f 49 c1             	cmovns %ecx,%eax
  8004a7:	29 c1                	sub    %eax,%ecx
  8004a9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ac:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004af:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b2:	89 cb                	mov    %ecx,%ebx
  8004b4:	eb 4d                	jmp    800503 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004b6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ba:	74 1b                	je     8004d7 <vprintfmt+0x213>
  8004bc:	0f be c0             	movsbl %al,%eax
  8004bf:	83 e8 20             	sub    $0x20,%eax
  8004c2:	83 f8 5e             	cmp    $0x5e,%eax
  8004c5:	76 10                	jbe    8004d7 <vprintfmt+0x213>
					putch('?', putdat);
  8004c7:	83 ec 08             	sub    $0x8,%esp
  8004ca:	ff 75 0c             	pushl  0xc(%ebp)
  8004cd:	6a 3f                	push   $0x3f
  8004cf:	ff 55 08             	call   *0x8(%ebp)
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	eb 0d                	jmp    8004e4 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	ff 75 0c             	pushl  0xc(%ebp)
  8004dd:	52                   	push   %edx
  8004de:	ff 55 08             	call   *0x8(%ebp)
  8004e1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e4:	83 eb 01             	sub    $0x1,%ebx
  8004e7:	eb 1a                	jmp    800503 <vprintfmt+0x23f>
  8004e9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ec:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ef:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f5:	eb 0c                	jmp    800503 <vprintfmt+0x23f>
  8004f7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004fa:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004fd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800500:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800503:	83 c7 01             	add    $0x1,%edi
  800506:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80050a:	0f be d0             	movsbl %al,%edx
  80050d:	85 d2                	test   %edx,%edx
  80050f:	74 23                	je     800534 <vprintfmt+0x270>
  800511:	85 f6                	test   %esi,%esi
  800513:	78 a1                	js     8004b6 <vprintfmt+0x1f2>
  800515:	83 ee 01             	sub    $0x1,%esi
  800518:	79 9c                	jns    8004b6 <vprintfmt+0x1f2>
  80051a:	89 df                	mov    %ebx,%edi
  80051c:	8b 75 08             	mov    0x8(%ebp),%esi
  80051f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800522:	eb 18                	jmp    80053c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800524:	83 ec 08             	sub    $0x8,%esp
  800527:	53                   	push   %ebx
  800528:	6a 20                	push   $0x20
  80052a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80052c:	83 ef 01             	sub    $0x1,%edi
  80052f:	83 c4 10             	add    $0x10,%esp
  800532:	eb 08                	jmp    80053c <vprintfmt+0x278>
  800534:	89 df                	mov    %ebx,%edi
  800536:	8b 75 08             	mov    0x8(%ebp),%esi
  800539:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053c:	85 ff                	test   %edi,%edi
  80053e:	7f e4                	jg     800524 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800540:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800543:	e9 a2 fd ff ff       	jmp    8002ea <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800548:	83 fa 01             	cmp    $0x1,%edx
  80054b:	7e 16                	jle    800563 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8d 50 08             	lea    0x8(%eax),%edx
  800553:	89 55 14             	mov    %edx,0x14(%ebp)
  800556:	8b 50 04             	mov    0x4(%eax),%edx
  800559:	8b 00                	mov    (%eax),%eax
  80055b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800561:	eb 32                	jmp    800595 <vprintfmt+0x2d1>
	else if (lflag)
  800563:	85 d2                	test   %edx,%edx
  800565:	74 18                	je     80057f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 50 04             	lea    0x4(%eax),%edx
  80056d:	89 55 14             	mov    %edx,0x14(%ebp)
  800570:	8b 00                	mov    (%eax),%eax
  800572:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800575:	89 c1                	mov    %eax,%ecx
  800577:	c1 f9 1f             	sar    $0x1f,%ecx
  80057a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80057d:	eb 16                	jmp    800595 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80057f:	8b 45 14             	mov    0x14(%ebp),%eax
  800582:	8d 50 04             	lea    0x4(%eax),%edx
  800585:	89 55 14             	mov    %edx,0x14(%ebp)
  800588:	8b 00                	mov    (%eax),%eax
  80058a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058d:	89 c1                	mov    %eax,%ecx
  80058f:	c1 f9 1f             	sar    $0x1f,%ecx
  800592:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800595:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800598:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80059b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a4:	79 74                	jns    80061a <vprintfmt+0x356>
				putch('-', putdat);
  8005a6:	83 ec 08             	sub    $0x8,%esp
  8005a9:	53                   	push   %ebx
  8005aa:	6a 2d                	push   $0x2d
  8005ac:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ae:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005b4:	f7 d8                	neg    %eax
  8005b6:	83 d2 00             	adc    $0x0,%edx
  8005b9:	f7 da                	neg    %edx
  8005bb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005be:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005c3:	eb 55                	jmp    80061a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005c5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c8:	e8 83 fc ff ff       	call   800250 <getuint>
			base = 10;
  8005cd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005d2:	eb 46                	jmp    80061a <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8005d4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d7:	e8 74 fc ff ff       	call   800250 <getuint>
			base = 8;
  8005dc:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005e1:	eb 37                	jmp    80061a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005e3:	83 ec 08             	sub    $0x8,%esp
  8005e6:	53                   	push   %ebx
  8005e7:	6a 30                	push   $0x30
  8005e9:	ff d6                	call   *%esi
			putch('x', putdat);
  8005eb:	83 c4 08             	add    $0x8,%esp
  8005ee:	53                   	push   %ebx
  8005ef:	6a 78                	push   $0x78
  8005f1:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8d 50 04             	lea    0x4(%eax),%edx
  8005f9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005fc:	8b 00                	mov    (%eax),%eax
  8005fe:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800603:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800606:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80060b:	eb 0d                	jmp    80061a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80060d:	8d 45 14             	lea    0x14(%ebp),%eax
  800610:	e8 3b fc ff ff       	call   800250 <getuint>
			base = 16;
  800615:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80061a:	83 ec 0c             	sub    $0xc,%esp
  80061d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800621:	57                   	push   %edi
  800622:	ff 75 e0             	pushl  -0x20(%ebp)
  800625:	51                   	push   %ecx
  800626:	52                   	push   %edx
  800627:	50                   	push   %eax
  800628:	89 da                	mov    %ebx,%edx
  80062a:	89 f0                	mov    %esi,%eax
  80062c:	e8 70 fb ff ff       	call   8001a1 <printnum>
			break;
  800631:	83 c4 20             	add    $0x20,%esp
  800634:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800637:	e9 ae fc ff ff       	jmp    8002ea <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80063c:	83 ec 08             	sub    $0x8,%esp
  80063f:	53                   	push   %ebx
  800640:	51                   	push   %ecx
  800641:	ff d6                	call   *%esi
			break;
  800643:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800646:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800649:	e9 9c fc ff ff       	jmp    8002ea <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	53                   	push   %ebx
  800652:	6a 25                	push   $0x25
  800654:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800656:	83 c4 10             	add    $0x10,%esp
  800659:	eb 03                	jmp    80065e <vprintfmt+0x39a>
  80065b:	83 ef 01             	sub    $0x1,%edi
  80065e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800662:	75 f7                	jne    80065b <vprintfmt+0x397>
  800664:	e9 81 fc ff ff       	jmp    8002ea <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800669:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066c:	5b                   	pop    %ebx
  80066d:	5e                   	pop    %esi
  80066e:	5f                   	pop    %edi
  80066f:	5d                   	pop    %ebp
  800670:	c3                   	ret    

00800671 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800671:	55                   	push   %ebp
  800672:	89 e5                	mov    %esp,%ebp
  800674:	83 ec 18             	sub    $0x18,%esp
  800677:	8b 45 08             	mov    0x8(%ebp),%eax
  80067a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80067d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800680:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800684:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800687:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80068e:	85 c0                	test   %eax,%eax
  800690:	74 26                	je     8006b8 <vsnprintf+0x47>
  800692:	85 d2                	test   %edx,%edx
  800694:	7e 22                	jle    8006b8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800696:	ff 75 14             	pushl  0x14(%ebp)
  800699:	ff 75 10             	pushl  0x10(%ebp)
  80069c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80069f:	50                   	push   %eax
  8006a0:	68 8a 02 80 00       	push   $0x80028a
  8006a5:	e8 1a fc ff ff       	call   8002c4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ad:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b3:	83 c4 10             	add    $0x10,%esp
  8006b6:	eb 05                	jmp    8006bd <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006bd:	c9                   	leave  
  8006be:	c3                   	ret    

008006bf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006bf:	55                   	push   %ebp
  8006c0:	89 e5                	mov    %esp,%ebp
  8006c2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006c8:	50                   	push   %eax
  8006c9:	ff 75 10             	pushl  0x10(%ebp)
  8006cc:	ff 75 0c             	pushl  0xc(%ebp)
  8006cf:	ff 75 08             	pushl  0x8(%ebp)
  8006d2:	e8 9a ff ff ff       	call   800671 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006d7:	c9                   	leave  
  8006d8:	c3                   	ret    

008006d9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006d9:	55                   	push   %ebp
  8006da:	89 e5                	mov    %esp,%ebp
  8006dc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006df:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e4:	eb 03                	jmp    8006e9 <strlen+0x10>
		n++;
  8006e6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006ed:	75 f7                	jne    8006e6 <strlen+0xd>
		n++;
	return n;
}
  8006ef:	5d                   	pop    %ebp
  8006f0:	c3                   	ret    

008006f1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f1:	55                   	push   %ebp
  8006f2:	89 e5                	mov    %esp,%ebp
  8006f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8006ff:	eb 03                	jmp    800704 <strnlen+0x13>
		n++;
  800701:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800704:	39 c2                	cmp    %eax,%edx
  800706:	74 08                	je     800710 <strnlen+0x1f>
  800708:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80070c:	75 f3                	jne    800701 <strnlen+0x10>
  80070e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800710:	5d                   	pop    %ebp
  800711:	c3                   	ret    

00800712 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
  800715:	53                   	push   %ebx
  800716:	8b 45 08             	mov    0x8(%ebp),%eax
  800719:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80071c:	89 c2                	mov    %eax,%edx
  80071e:	83 c2 01             	add    $0x1,%edx
  800721:	83 c1 01             	add    $0x1,%ecx
  800724:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800728:	88 5a ff             	mov    %bl,-0x1(%edx)
  80072b:	84 db                	test   %bl,%bl
  80072d:	75 ef                	jne    80071e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80072f:	5b                   	pop    %ebx
  800730:	5d                   	pop    %ebp
  800731:	c3                   	ret    

00800732 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	53                   	push   %ebx
  800736:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800739:	53                   	push   %ebx
  80073a:	e8 9a ff ff ff       	call   8006d9 <strlen>
  80073f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800742:	ff 75 0c             	pushl  0xc(%ebp)
  800745:	01 d8                	add    %ebx,%eax
  800747:	50                   	push   %eax
  800748:	e8 c5 ff ff ff       	call   800712 <strcpy>
	return dst;
}
  80074d:	89 d8                	mov    %ebx,%eax
  80074f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800752:	c9                   	leave  
  800753:	c3                   	ret    

00800754 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	56                   	push   %esi
  800758:	53                   	push   %ebx
  800759:	8b 75 08             	mov    0x8(%ebp),%esi
  80075c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80075f:	89 f3                	mov    %esi,%ebx
  800761:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800764:	89 f2                	mov    %esi,%edx
  800766:	eb 0f                	jmp    800777 <strncpy+0x23>
		*dst++ = *src;
  800768:	83 c2 01             	add    $0x1,%edx
  80076b:	0f b6 01             	movzbl (%ecx),%eax
  80076e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800771:	80 39 01             	cmpb   $0x1,(%ecx)
  800774:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800777:	39 da                	cmp    %ebx,%edx
  800779:	75 ed                	jne    800768 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80077b:	89 f0                	mov    %esi,%eax
  80077d:	5b                   	pop    %ebx
  80077e:	5e                   	pop    %esi
  80077f:	5d                   	pop    %ebp
  800780:	c3                   	ret    

00800781 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	56                   	push   %esi
  800785:	53                   	push   %ebx
  800786:	8b 75 08             	mov    0x8(%ebp),%esi
  800789:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078c:	8b 55 10             	mov    0x10(%ebp),%edx
  80078f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800791:	85 d2                	test   %edx,%edx
  800793:	74 21                	je     8007b6 <strlcpy+0x35>
  800795:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800799:	89 f2                	mov    %esi,%edx
  80079b:	eb 09                	jmp    8007a6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80079d:	83 c2 01             	add    $0x1,%edx
  8007a0:	83 c1 01             	add    $0x1,%ecx
  8007a3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007a6:	39 c2                	cmp    %eax,%edx
  8007a8:	74 09                	je     8007b3 <strlcpy+0x32>
  8007aa:	0f b6 19             	movzbl (%ecx),%ebx
  8007ad:	84 db                	test   %bl,%bl
  8007af:	75 ec                	jne    80079d <strlcpy+0x1c>
  8007b1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007b3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007b6:	29 f0                	sub    %esi,%eax
}
  8007b8:	5b                   	pop    %ebx
  8007b9:	5e                   	pop    %esi
  8007ba:	5d                   	pop    %ebp
  8007bb:	c3                   	ret    

008007bc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c5:	eb 06                	jmp    8007cd <strcmp+0x11>
		p++, q++;
  8007c7:	83 c1 01             	add    $0x1,%ecx
  8007ca:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007cd:	0f b6 01             	movzbl (%ecx),%eax
  8007d0:	84 c0                	test   %al,%al
  8007d2:	74 04                	je     8007d8 <strcmp+0x1c>
  8007d4:	3a 02                	cmp    (%edx),%al
  8007d6:	74 ef                	je     8007c7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d8:	0f b6 c0             	movzbl %al,%eax
  8007db:	0f b6 12             	movzbl (%edx),%edx
  8007de:	29 d0                	sub    %edx,%eax
}
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	53                   	push   %ebx
  8007e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ec:	89 c3                	mov    %eax,%ebx
  8007ee:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007f1:	eb 06                	jmp    8007f9 <strncmp+0x17>
		n--, p++, q++;
  8007f3:	83 c0 01             	add    $0x1,%eax
  8007f6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007f9:	39 d8                	cmp    %ebx,%eax
  8007fb:	74 15                	je     800812 <strncmp+0x30>
  8007fd:	0f b6 08             	movzbl (%eax),%ecx
  800800:	84 c9                	test   %cl,%cl
  800802:	74 04                	je     800808 <strncmp+0x26>
  800804:	3a 0a                	cmp    (%edx),%cl
  800806:	74 eb                	je     8007f3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800808:	0f b6 00             	movzbl (%eax),%eax
  80080b:	0f b6 12             	movzbl (%edx),%edx
  80080e:	29 d0                	sub    %edx,%eax
  800810:	eb 05                	jmp    800817 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800812:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800817:	5b                   	pop    %ebx
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	8b 45 08             	mov    0x8(%ebp),%eax
  800820:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800824:	eb 07                	jmp    80082d <strchr+0x13>
		if (*s == c)
  800826:	38 ca                	cmp    %cl,%dl
  800828:	74 0f                	je     800839 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80082a:	83 c0 01             	add    $0x1,%eax
  80082d:	0f b6 10             	movzbl (%eax),%edx
  800830:	84 d2                	test   %dl,%dl
  800832:	75 f2                	jne    800826 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800834:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	8b 45 08             	mov    0x8(%ebp),%eax
  800841:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800845:	eb 03                	jmp    80084a <strfind+0xf>
  800847:	83 c0 01             	add    $0x1,%eax
  80084a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80084d:	38 ca                	cmp    %cl,%dl
  80084f:	74 04                	je     800855 <strfind+0x1a>
  800851:	84 d2                	test   %dl,%dl
  800853:	75 f2                	jne    800847 <strfind+0xc>
			break;
	return (char *) s;
}
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	57                   	push   %edi
  80085b:	56                   	push   %esi
  80085c:	53                   	push   %ebx
  80085d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800860:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800863:	85 c9                	test   %ecx,%ecx
  800865:	74 36                	je     80089d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800867:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80086d:	75 28                	jne    800897 <memset+0x40>
  80086f:	f6 c1 03             	test   $0x3,%cl
  800872:	75 23                	jne    800897 <memset+0x40>
		c &= 0xFF;
  800874:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800878:	89 d3                	mov    %edx,%ebx
  80087a:	c1 e3 08             	shl    $0x8,%ebx
  80087d:	89 d6                	mov    %edx,%esi
  80087f:	c1 e6 18             	shl    $0x18,%esi
  800882:	89 d0                	mov    %edx,%eax
  800884:	c1 e0 10             	shl    $0x10,%eax
  800887:	09 f0                	or     %esi,%eax
  800889:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80088b:	89 d8                	mov    %ebx,%eax
  80088d:	09 d0                	or     %edx,%eax
  80088f:	c1 e9 02             	shr    $0x2,%ecx
  800892:	fc                   	cld    
  800893:	f3 ab                	rep stos %eax,%es:(%edi)
  800895:	eb 06                	jmp    80089d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800897:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089a:	fc                   	cld    
  80089b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80089d:	89 f8                	mov    %edi,%eax
  80089f:	5b                   	pop    %ebx
  8008a0:	5e                   	pop    %esi
  8008a1:	5f                   	pop    %edi
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	57                   	push   %edi
  8008a8:	56                   	push   %esi
  8008a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ac:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008af:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008b2:	39 c6                	cmp    %eax,%esi
  8008b4:	73 35                	jae    8008eb <memmove+0x47>
  8008b6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008b9:	39 d0                	cmp    %edx,%eax
  8008bb:	73 2e                	jae    8008eb <memmove+0x47>
		s += n;
		d += n;
  8008bd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c0:	89 d6                	mov    %edx,%esi
  8008c2:	09 fe                	or     %edi,%esi
  8008c4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ca:	75 13                	jne    8008df <memmove+0x3b>
  8008cc:	f6 c1 03             	test   $0x3,%cl
  8008cf:	75 0e                	jne    8008df <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008d1:	83 ef 04             	sub    $0x4,%edi
  8008d4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008d7:	c1 e9 02             	shr    $0x2,%ecx
  8008da:	fd                   	std    
  8008db:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008dd:	eb 09                	jmp    8008e8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008df:	83 ef 01             	sub    $0x1,%edi
  8008e2:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008e5:	fd                   	std    
  8008e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008e8:	fc                   	cld    
  8008e9:	eb 1d                	jmp    800908 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008eb:	89 f2                	mov    %esi,%edx
  8008ed:	09 c2                	or     %eax,%edx
  8008ef:	f6 c2 03             	test   $0x3,%dl
  8008f2:	75 0f                	jne    800903 <memmove+0x5f>
  8008f4:	f6 c1 03             	test   $0x3,%cl
  8008f7:	75 0a                	jne    800903 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008f9:	c1 e9 02             	shr    $0x2,%ecx
  8008fc:	89 c7                	mov    %eax,%edi
  8008fe:	fc                   	cld    
  8008ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800901:	eb 05                	jmp    800908 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800903:	89 c7                	mov    %eax,%edi
  800905:	fc                   	cld    
  800906:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800908:	5e                   	pop    %esi
  800909:	5f                   	pop    %edi
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80090f:	ff 75 10             	pushl  0x10(%ebp)
  800912:	ff 75 0c             	pushl  0xc(%ebp)
  800915:	ff 75 08             	pushl  0x8(%ebp)
  800918:	e8 87 ff ff ff       	call   8008a4 <memmove>
}
  80091d:	c9                   	leave  
  80091e:	c3                   	ret    

0080091f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	56                   	push   %esi
  800923:	53                   	push   %ebx
  800924:	8b 45 08             	mov    0x8(%ebp),%eax
  800927:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092a:	89 c6                	mov    %eax,%esi
  80092c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80092f:	eb 1a                	jmp    80094b <memcmp+0x2c>
		if (*s1 != *s2)
  800931:	0f b6 08             	movzbl (%eax),%ecx
  800934:	0f b6 1a             	movzbl (%edx),%ebx
  800937:	38 d9                	cmp    %bl,%cl
  800939:	74 0a                	je     800945 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80093b:	0f b6 c1             	movzbl %cl,%eax
  80093e:	0f b6 db             	movzbl %bl,%ebx
  800941:	29 d8                	sub    %ebx,%eax
  800943:	eb 0f                	jmp    800954 <memcmp+0x35>
		s1++, s2++;
  800945:	83 c0 01             	add    $0x1,%eax
  800948:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094b:	39 f0                	cmp    %esi,%eax
  80094d:	75 e2                	jne    800931 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80094f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800954:	5b                   	pop    %ebx
  800955:	5e                   	pop    %esi
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	53                   	push   %ebx
  80095c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80095f:	89 c1                	mov    %eax,%ecx
  800961:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800964:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800968:	eb 0a                	jmp    800974 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80096a:	0f b6 10             	movzbl (%eax),%edx
  80096d:	39 da                	cmp    %ebx,%edx
  80096f:	74 07                	je     800978 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800971:	83 c0 01             	add    $0x1,%eax
  800974:	39 c8                	cmp    %ecx,%eax
  800976:	72 f2                	jb     80096a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800978:	5b                   	pop    %ebx
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	57                   	push   %edi
  80097f:	56                   	push   %esi
  800980:	53                   	push   %ebx
  800981:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800984:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800987:	eb 03                	jmp    80098c <strtol+0x11>
		s++;
  800989:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098c:	0f b6 01             	movzbl (%ecx),%eax
  80098f:	3c 20                	cmp    $0x20,%al
  800991:	74 f6                	je     800989 <strtol+0xe>
  800993:	3c 09                	cmp    $0x9,%al
  800995:	74 f2                	je     800989 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800997:	3c 2b                	cmp    $0x2b,%al
  800999:	75 0a                	jne    8009a5 <strtol+0x2a>
		s++;
  80099b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80099e:	bf 00 00 00 00       	mov    $0x0,%edi
  8009a3:	eb 11                	jmp    8009b6 <strtol+0x3b>
  8009a5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009aa:	3c 2d                	cmp    $0x2d,%al
  8009ac:	75 08                	jne    8009b6 <strtol+0x3b>
		s++, neg = 1;
  8009ae:	83 c1 01             	add    $0x1,%ecx
  8009b1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009b6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009bc:	75 15                	jne    8009d3 <strtol+0x58>
  8009be:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c1:	75 10                	jne    8009d3 <strtol+0x58>
  8009c3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009c7:	75 7c                	jne    800a45 <strtol+0xca>
		s += 2, base = 16;
  8009c9:	83 c1 02             	add    $0x2,%ecx
  8009cc:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009d1:	eb 16                	jmp    8009e9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009d3:	85 db                	test   %ebx,%ebx
  8009d5:	75 12                	jne    8009e9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009d7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009dc:	80 39 30             	cmpb   $0x30,(%ecx)
  8009df:	75 08                	jne    8009e9 <strtol+0x6e>
		s++, base = 8;
  8009e1:	83 c1 01             	add    $0x1,%ecx
  8009e4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ee:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f1:	0f b6 11             	movzbl (%ecx),%edx
  8009f4:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009f7:	89 f3                	mov    %esi,%ebx
  8009f9:	80 fb 09             	cmp    $0x9,%bl
  8009fc:	77 08                	ja     800a06 <strtol+0x8b>
			dig = *s - '0';
  8009fe:	0f be d2             	movsbl %dl,%edx
  800a01:	83 ea 30             	sub    $0x30,%edx
  800a04:	eb 22                	jmp    800a28 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a06:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a09:	89 f3                	mov    %esi,%ebx
  800a0b:	80 fb 19             	cmp    $0x19,%bl
  800a0e:	77 08                	ja     800a18 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a10:	0f be d2             	movsbl %dl,%edx
  800a13:	83 ea 57             	sub    $0x57,%edx
  800a16:	eb 10                	jmp    800a28 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a18:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a1b:	89 f3                	mov    %esi,%ebx
  800a1d:	80 fb 19             	cmp    $0x19,%bl
  800a20:	77 16                	ja     800a38 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a22:	0f be d2             	movsbl %dl,%edx
  800a25:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a28:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a2b:	7d 0b                	jge    800a38 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a2d:	83 c1 01             	add    $0x1,%ecx
  800a30:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a34:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a36:	eb b9                	jmp    8009f1 <strtol+0x76>

	if (endptr)
  800a38:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a3c:	74 0d                	je     800a4b <strtol+0xd0>
		*endptr = (char *) s;
  800a3e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a41:	89 0e                	mov    %ecx,(%esi)
  800a43:	eb 06                	jmp    800a4b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a45:	85 db                	test   %ebx,%ebx
  800a47:	74 98                	je     8009e1 <strtol+0x66>
  800a49:	eb 9e                	jmp    8009e9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a4b:	89 c2                	mov    %eax,%edx
  800a4d:	f7 da                	neg    %edx
  800a4f:	85 ff                	test   %edi,%edi
  800a51:	0f 45 c2             	cmovne %edx,%eax
}
  800a54:	5b                   	pop    %ebx
  800a55:	5e                   	pop    %esi
  800a56:	5f                   	pop    %edi
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	57                   	push   %edi
  800a5d:	56                   	push   %esi
  800a5e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a67:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6a:	89 c3                	mov    %eax,%ebx
  800a6c:	89 c7                	mov    %eax,%edi
  800a6e:	89 c6                	mov    %eax,%esi
  800a70:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a72:	5b                   	pop    %ebx
  800a73:	5e                   	pop    %esi
  800a74:	5f                   	pop    %edi
  800a75:	5d                   	pop    %ebp
  800a76:	c3                   	ret    

00800a77 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	57                   	push   %edi
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a82:	b8 01 00 00 00       	mov    $0x1,%eax
  800a87:	89 d1                	mov    %edx,%ecx
  800a89:	89 d3                	mov    %edx,%ebx
  800a8b:	89 d7                	mov    %edx,%edi
  800a8d:	89 d6                	mov    %edx,%esi
  800a8f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a91:	5b                   	pop    %ebx
  800a92:	5e                   	pop    %esi
  800a93:	5f                   	pop    %edi
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    

00800a96 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	57                   	push   %edi
  800a9a:	56                   	push   %esi
  800a9b:	53                   	push   %ebx
  800a9c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa4:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa9:	8b 55 08             	mov    0x8(%ebp),%edx
  800aac:	89 cb                	mov    %ecx,%ebx
  800aae:	89 cf                	mov    %ecx,%edi
  800ab0:	89 ce                	mov    %ecx,%esi
  800ab2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ab4:	85 c0                	test   %eax,%eax
  800ab6:	7e 17                	jle    800acf <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ab8:	83 ec 0c             	sub    $0xc,%esp
  800abb:	50                   	push   %eax
  800abc:	6a 03                	push   $0x3
  800abe:	68 3f 26 80 00       	push   $0x80263f
  800ac3:	6a 23                	push   $0x23
  800ac5:	68 5c 26 80 00       	push   $0x80265c
  800aca:	e8 dc 13 00 00       	call   801eab <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800acf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5f                   	pop    %edi
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    

00800ad7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	57                   	push   %edi
  800adb:	56                   	push   %esi
  800adc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800add:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae2:	b8 02 00 00 00       	mov    $0x2,%eax
  800ae7:	89 d1                	mov    %edx,%ecx
  800ae9:	89 d3                	mov    %edx,%ebx
  800aeb:	89 d7                	mov    %edx,%edi
  800aed:	89 d6                	mov    %edx,%esi
  800aef:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5f                   	pop    %edi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <sys_yield>:

void
sys_yield(void)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	57                   	push   %edi
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afc:	ba 00 00 00 00       	mov    $0x0,%edx
  800b01:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b06:	89 d1                	mov    %edx,%ecx
  800b08:	89 d3                	mov    %edx,%ebx
  800b0a:	89 d7                	mov    %edx,%edi
  800b0c:	89 d6                	mov    %edx,%esi
  800b0e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b10:	5b                   	pop    %ebx
  800b11:	5e                   	pop    %esi
  800b12:	5f                   	pop    %edi
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	57                   	push   %edi
  800b19:	56                   	push   %esi
  800b1a:	53                   	push   %ebx
  800b1b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1e:	be 00 00 00 00       	mov    $0x0,%esi
  800b23:	b8 04 00 00 00       	mov    $0x4,%eax
  800b28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b31:	89 f7                	mov    %esi,%edi
  800b33:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b35:	85 c0                	test   %eax,%eax
  800b37:	7e 17                	jle    800b50 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b39:	83 ec 0c             	sub    $0xc,%esp
  800b3c:	50                   	push   %eax
  800b3d:	6a 04                	push   $0x4
  800b3f:	68 3f 26 80 00       	push   $0x80263f
  800b44:	6a 23                	push   $0x23
  800b46:	68 5c 26 80 00       	push   $0x80265c
  800b4b:	e8 5b 13 00 00       	call   801eab <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5f                   	pop    %edi
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
  800b5e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b61:	b8 05 00 00 00       	mov    $0x5,%eax
  800b66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b69:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b6f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b72:	8b 75 18             	mov    0x18(%ebp),%esi
  800b75:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b77:	85 c0                	test   %eax,%eax
  800b79:	7e 17                	jle    800b92 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7b:	83 ec 0c             	sub    $0xc,%esp
  800b7e:	50                   	push   %eax
  800b7f:	6a 05                	push   $0x5
  800b81:	68 3f 26 80 00       	push   $0x80263f
  800b86:	6a 23                	push   $0x23
  800b88:	68 5c 26 80 00       	push   $0x80265c
  800b8d:	e8 19 13 00 00       	call   801eab <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
  800ba0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ba8:	b8 06 00 00 00       	mov    $0x6,%eax
  800bad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb3:	89 df                	mov    %ebx,%edi
  800bb5:	89 de                	mov    %ebx,%esi
  800bb7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb9:	85 c0                	test   %eax,%eax
  800bbb:	7e 17                	jle    800bd4 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbd:	83 ec 0c             	sub    $0xc,%esp
  800bc0:	50                   	push   %eax
  800bc1:	6a 06                	push   $0x6
  800bc3:	68 3f 26 80 00       	push   $0x80263f
  800bc8:	6a 23                	push   $0x23
  800bca:	68 5c 26 80 00       	push   $0x80265c
  800bcf:	e8 d7 12 00 00       	call   801eab <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	57                   	push   %edi
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
  800be2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bea:	b8 08 00 00 00       	mov    $0x8,%eax
  800bef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf5:	89 df                	mov    %ebx,%edi
  800bf7:	89 de                	mov    %ebx,%esi
  800bf9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	7e 17                	jle    800c16 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bff:	83 ec 0c             	sub    $0xc,%esp
  800c02:	50                   	push   %eax
  800c03:	6a 08                	push   $0x8
  800c05:	68 3f 26 80 00       	push   $0x80263f
  800c0a:	6a 23                	push   $0x23
  800c0c:	68 5c 26 80 00       	push   $0x80265c
  800c11:	e8 95 12 00 00       	call   801eab <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c27:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2c:	b8 09 00 00 00       	mov    $0x9,%eax
  800c31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c34:	8b 55 08             	mov    0x8(%ebp),%edx
  800c37:	89 df                	mov    %ebx,%edi
  800c39:	89 de                	mov    %ebx,%esi
  800c3b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	7e 17                	jle    800c58 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c41:	83 ec 0c             	sub    $0xc,%esp
  800c44:	50                   	push   %eax
  800c45:	6a 09                	push   $0x9
  800c47:	68 3f 26 80 00       	push   $0x80263f
  800c4c:	6a 23                	push   $0x23
  800c4e:	68 5c 26 80 00       	push   $0x80265c
  800c53:	e8 53 12 00 00       	call   801eab <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
  800c66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	89 df                	mov    %ebx,%edi
  800c7b:	89 de                	mov    %ebx,%esi
  800c7d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	7e 17                	jle    800c9a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c83:	83 ec 0c             	sub    $0xc,%esp
  800c86:	50                   	push   %eax
  800c87:	6a 0a                	push   $0xa
  800c89:	68 3f 26 80 00       	push   $0x80263f
  800c8e:	6a 23                	push   $0x23
  800c90:	68 5c 26 80 00       	push   $0x80265c
  800c95:	e8 11 12 00 00       	call   801eab <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca8:	be 00 00 00 00       	mov    $0x0,%esi
  800cad:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cbe:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
  800ccb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cce:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	89 cb                	mov    %ecx,%ebx
  800cdd:	89 cf                	mov    %ecx,%edi
  800cdf:	89 ce                	mov    %ecx,%esi
  800ce1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 17                	jle    800cfe <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	83 ec 0c             	sub    $0xc,%esp
  800cea:	50                   	push   %eax
  800ceb:	6a 0d                	push   $0xd
  800ced:	68 3f 26 80 00       	push   $0x80263f
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 5c 26 80 00       	push   $0x80265c
  800cf9:	e8 ad 11 00 00       	call   801eab <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d11:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d16:	89 d1                	mov    %edx,%ecx
  800d18:	89 d3                	mov    %edx,%ebx
  800d1a:	89 d7                	mov    %edx,%edi
  800d1c:	89 d6                	mov    %edx,%esi
  800d1e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    

00800d25 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	57                   	push   %edi
  800d29:	56                   	push   %esi
  800d2a:	53                   	push   %ebx
  800d2b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d33:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3e:	89 df                	mov    %ebx,%edi
  800d40:	89 de                	mov    %ebx,%esi
  800d42:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d44:	85 c0                	test   %eax,%eax
  800d46:	7e 17                	jle    800d5f <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d48:	83 ec 0c             	sub    $0xc,%esp
  800d4b:	50                   	push   %eax
  800d4c:	6a 0f                	push   $0xf
  800d4e:	68 3f 26 80 00       	push   $0x80263f
  800d53:	6a 23                	push   $0x23
  800d55:	68 5c 26 80 00       	push   $0x80265c
  800d5a:	e8 4c 11 00 00       	call   801eab <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800d5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6d:	05 00 00 00 30       	add    $0x30000000,%eax
  800d72:	c1 e8 0c             	shr    $0xc,%eax
}
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7d:	05 00 00 00 30       	add    $0x30000000,%eax
  800d82:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d87:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    

00800d8e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d94:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d99:	89 c2                	mov    %eax,%edx
  800d9b:	c1 ea 16             	shr    $0x16,%edx
  800d9e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800da5:	f6 c2 01             	test   $0x1,%dl
  800da8:	74 11                	je     800dbb <fd_alloc+0x2d>
  800daa:	89 c2                	mov    %eax,%edx
  800dac:	c1 ea 0c             	shr    $0xc,%edx
  800daf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800db6:	f6 c2 01             	test   $0x1,%dl
  800db9:	75 09                	jne    800dc4 <fd_alloc+0x36>
			*fd_store = fd;
  800dbb:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dbd:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc2:	eb 17                	jmp    800ddb <fd_alloc+0x4d>
  800dc4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dc9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dce:	75 c9                	jne    800d99 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dd0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800dd6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    

00800ddd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800de3:	83 f8 1f             	cmp    $0x1f,%eax
  800de6:	77 36                	ja     800e1e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800de8:	c1 e0 0c             	shl    $0xc,%eax
  800deb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800df0:	89 c2                	mov    %eax,%edx
  800df2:	c1 ea 16             	shr    $0x16,%edx
  800df5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dfc:	f6 c2 01             	test   $0x1,%dl
  800dff:	74 24                	je     800e25 <fd_lookup+0x48>
  800e01:	89 c2                	mov    %eax,%edx
  800e03:	c1 ea 0c             	shr    $0xc,%edx
  800e06:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e0d:	f6 c2 01             	test   $0x1,%dl
  800e10:	74 1a                	je     800e2c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e12:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e15:	89 02                	mov    %eax,(%edx)
	return 0;
  800e17:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1c:	eb 13                	jmp    800e31 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e1e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e23:	eb 0c                	jmp    800e31 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e25:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e2a:	eb 05                	jmp    800e31 <fd_lookup+0x54>
  800e2c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    

00800e33 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	83 ec 08             	sub    $0x8,%esp
  800e39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3c:	ba e8 26 80 00       	mov    $0x8026e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e41:	eb 13                	jmp    800e56 <dev_lookup+0x23>
  800e43:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e46:	39 08                	cmp    %ecx,(%eax)
  800e48:	75 0c                	jne    800e56 <dev_lookup+0x23>
			*dev = devtab[i];
  800e4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4d:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e54:	eb 2e                	jmp    800e84 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e56:	8b 02                	mov    (%edx),%eax
  800e58:	85 c0                	test   %eax,%eax
  800e5a:	75 e7                	jne    800e43 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e5c:	a1 08 40 80 00       	mov    0x804008,%eax
  800e61:	8b 40 48             	mov    0x48(%eax),%eax
  800e64:	83 ec 04             	sub    $0x4,%esp
  800e67:	51                   	push   %ecx
  800e68:	50                   	push   %eax
  800e69:	68 6c 26 80 00       	push   $0x80266c
  800e6e:	e8 1a f3 ff ff       	call   80018d <cprintf>
	*dev = 0;
  800e73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e76:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e7c:	83 c4 10             	add    $0x10,%esp
  800e7f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e84:	c9                   	leave  
  800e85:	c3                   	ret    

00800e86 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	56                   	push   %esi
  800e8a:	53                   	push   %ebx
  800e8b:	83 ec 10             	sub    $0x10,%esp
  800e8e:	8b 75 08             	mov    0x8(%ebp),%esi
  800e91:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e94:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e97:	50                   	push   %eax
  800e98:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e9e:	c1 e8 0c             	shr    $0xc,%eax
  800ea1:	50                   	push   %eax
  800ea2:	e8 36 ff ff ff       	call   800ddd <fd_lookup>
  800ea7:	83 c4 08             	add    $0x8,%esp
  800eaa:	85 c0                	test   %eax,%eax
  800eac:	78 05                	js     800eb3 <fd_close+0x2d>
	    || fd != fd2)
  800eae:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800eb1:	74 0c                	je     800ebf <fd_close+0x39>
		return (must_exist ? r : 0);
  800eb3:	84 db                	test   %bl,%bl
  800eb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800eba:	0f 44 c2             	cmove  %edx,%eax
  800ebd:	eb 41                	jmp    800f00 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ebf:	83 ec 08             	sub    $0x8,%esp
  800ec2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ec5:	50                   	push   %eax
  800ec6:	ff 36                	pushl  (%esi)
  800ec8:	e8 66 ff ff ff       	call   800e33 <dev_lookup>
  800ecd:	89 c3                	mov    %eax,%ebx
  800ecf:	83 c4 10             	add    $0x10,%esp
  800ed2:	85 c0                	test   %eax,%eax
  800ed4:	78 1a                	js     800ef0 <fd_close+0x6a>
		if (dev->dev_close)
  800ed6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ed9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800edc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ee1:	85 c0                	test   %eax,%eax
  800ee3:	74 0b                	je     800ef0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ee5:	83 ec 0c             	sub    $0xc,%esp
  800ee8:	56                   	push   %esi
  800ee9:	ff d0                	call   *%eax
  800eeb:	89 c3                	mov    %eax,%ebx
  800eed:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ef0:	83 ec 08             	sub    $0x8,%esp
  800ef3:	56                   	push   %esi
  800ef4:	6a 00                	push   $0x0
  800ef6:	e8 9f fc ff ff       	call   800b9a <sys_page_unmap>
	return r;
  800efb:	83 c4 10             	add    $0x10,%esp
  800efe:	89 d8                	mov    %ebx,%eax
}
  800f00:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f03:	5b                   	pop    %ebx
  800f04:	5e                   	pop    %esi
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f10:	50                   	push   %eax
  800f11:	ff 75 08             	pushl  0x8(%ebp)
  800f14:	e8 c4 fe ff ff       	call   800ddd <fd_lookup>
  800f19:	83 c4 08             	add    $0x8,%esp
  800f1c:	85 c0                	test   %eax,%eax
  800f1e:	78 10                	js     800f30 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f20:	83 ec 08             	sub    $0x8,%esp
  800f23:	6a 01                	push   $0x1
  800f25:	ff 75 f4             	pushl  -0xc(%ebp)
  800f28:	e8 59 ff ff ff       	call   800e86 <fd_close>
  800f2d:	83 c4 10             	add    $0x10,%esp
}
  800f30:	c9                   	leave  
  800f31:	c3                   	ret    

00800f32 <close_all>:

void
close_all(void)
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	53                   	push   %ebx
  800f36:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f39:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f3e:	83 ec 0c             	sub    $0xc,%esp
  800f41:	53                   	push   %ebx
  800f42:	e8 c0 ff ff ff       	call   800f07 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f47:	83 c3 01             	add    $0x1,%ebx
  800f4a:	83 c4 10             	add    $0x10,%esp
  800f4d:	83 fb 20             	cmp    $0x20,%ebx
  800f50:	75 ec                	jne    800f3e <close_all+0xc>
		close(i);
}
  800f52:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f55:	c9                   	leave  
  800f56:	c3                   	ret    

00800f57 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
  800f5a:	57                   	push   %edi
  800f5b:	56                   	push   %esi
  800f5c:	53                   	push   %ebx
  800f5d:	83 ec 2c             	sub    $0x2c,%esp
  800f60:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f63:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f66:	50                   	push   %eax
  800f67:	ff 75 08             	pushl  0x8(%ebp)
  800f6a:	e8 6e fe ff ff       	call   800ddd <fd_lookup>
  800f6f:	83 c4 08             	add    $0x8,%esp
  800f72:	85 c0                	test   %eax,%eax
  800f74:	0f 88 c1 00 00 00    	js     80103b <dup+0xe4>
		return r;
	close(newfdnum);
  800f7a:	83 ec 0c             	sub    $0xc,%esp
  800f7d:	56                   	push   %esi
  800f7e:	e8 84 ff ff ff       	call   800f07 <close>

	newfd = INDEX2FD(newfdnum);
  800f83:	89 f3                	mov    %esi,%ebx
  800f85:	c1 e3 0c             	shl    $0xc,%ebx
  800f88:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f8e:	83 c4 04             	add    $0x4,%esp
  800f91:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f94:	e8 de fd ff ff       	call   800d77 <fd2data>
  800f99:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f9b:	89 1c 24             	mov    %ebx,(%esp)
  800f9e:	e8 d4 fd ff ff       	call   800d77 <fd2data>
  800fa3:	83 c4 10             	add    $0x10,%esp
  800fa6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fa9:	89 f8                	mov    %edi,%eax
  800fab:	c1 e8 16             	shr    $0x16,%eax
  800fae:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fb5:	a8 01                	test   $0x1,%al
  800fb7:	74 37                	je     800ff0 <dup+0x99>
  800fb9:	89 f8                	mov    %edi,%eax
  800fbb:	c1 e8 0c             	shr    $0xc,%eax
  800fbe:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fc5:	f6 c2 01             	test   $0x1,%dl
  800fc8:	74 26                	je     800ff0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fca:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fd1:	83 ec 0c             	sub    $0xc,%esp
  800fd4:	25 07 0e 00 00       	and    $0xe07,%eax
  800fd9:	50                   	push   %eax
  800fda:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fdd:	6a 00                	push   $0x0
  800fdf:	57                   	push   %edi
  800fe0:	6a 00                	push   $0x0
  800fe2:	e8 71 fb ff ff       	call   800b58 <sys_page_map>
  800fe7:	89 c7                	mov    %eax,%edi
  800fe9:	83 c4 20             	add    $0x20,%esp
  800fec:	85 c0                	test   %eax,%eax
  800fee:	78 2e                	js     80101e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800ff0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ff3:	89 d0                	mov    %edx,%eax
  800ff5:	c1 e8 0c             	shr    $0xc,%eax
  800ff8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fff:	83 ec 0c             	sub    $0xc,%esp
  801002:	25 07 0e 00 00       	and    $0xe07,%eax
  801007:	50                   	push   %eax
  801008:	53                   	push   %ebx
  801009:	6a 00                	push   $0x0
  80100b:	52                   	push   %edx
  80100c:	6a 00                	push   $0x0
  80100e:	e8 45 fb ff ff       	call   800b58 <sys_page_map>
  801013:	89 c7                	mov    %eax,%edi
  801015:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801018:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80101a:	85 ff                	test   %edi,%edi
  80101c:	79 1d                	jns    80103b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80101e:	83 ec 08             	sub    $0x8,%esp
  801021:	53                   	push   %ebx
  801022:	6a 00                	push   $0x0
  801024:	e8 71 fb ff ff       	call   800b9a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801029:	83 c4 08             	add    $0x8,%esp
  80102c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80102f:	6a 00                	push   $0x0
  801031:	e8 64 fb ff ff       	call   800b9a <sys_page_unmap>
	return r;
  801036:	83 c4 10             	add    $0x10,%esp
  801039:	89 f8                	mov    %edi,%eax
}
  80103b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80103e:	5b                   	pop    %ebx
  80103f:	5e                   	pop    %esi
  801040:	5f                   	pop    %edi
  801041:	5d                   	pop    %ebp
  801042:	c3                   	ret    

00801043 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	53                   	push   %ebx
  801047:	83 ec 14             	sub    $0x14,%esp
  80104a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80104d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801050:	50                   	push   %eax
  801051:	53                   	push   %ebx
  801052:	e8 86 fd ff ff       	call   800ddd <fd_lookup>
  801057:	83 c4 08             	add    $0x8,%esp
  80105a:	89 c2                	mov    %eax,%edx
  80105c:	85 c0                	test   %eax,%eax
  80105e:	78 6d                	js     8010cd <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801060:	83 ec 08             	sub    $0x8,%esp
  801063:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801066:	50                   	push   %eax
  801067:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80106a:	ff 30                	pushl  (%eax)
  80106c:	e8 c2 fd ff ff       	call   800e33 <dev_lookup>
  801071:	83 c4 10             	add    $0x10,%esp
  801074:	85 c0                	test   %eax,%eax
  801076:	78 4c                	js     8010c4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801078:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80107b:	8b 42 08             	mov    0x8(%edx),%eax
  80107e:	83 e0 03             	and    $0x3,%eax
  801081:	83 f8 01             	cmp    $0x1,%eax
  801084:	75 21                	jne    8010a7 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801086:	a1 08 40 80 00       	mov    0x804008,%eax
  80108b:	8b 40 48             	mov    0x48(%eax),%eax
  80108e:	83 ec 04             	sub    $0x4,%esp
  801091:	53                   	push   %ebx
  801092:	50                   	push   %eax
  801093:	68 ad 26 80 00       	push   $0x8026ad
  801098:	e8 f0 f0 ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  80109d:	83 c4 10             	add    $0x10,%esp
  8010a0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010a5:	eb 26                	jmp    8010cd <read+0x8a>
	}
	if (!dev->dev_read)
  8010a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010aa:	8b 40 08             	mov    0x8(%eax),%eax
  8010ad:	85 c0                	test   %eax,%eax
  8010af:	74 17                	je     8010c8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010b1:	83 ec 04             	sub    $0x4,%esp
  8010b4:	ff 75 10             	pushl  0x10(%ebp)
  8010b7:	ff 75 0c             	pushl  0xc(%ebp)
  8010ba:	52                   	push   %edx
  8010bb:	ff d0                	call   *%eax
  8010bd:	89 c2                	mov    %eax,%edx
  8010bf:	83 c4 10             	add    $0x10,%esp
  8010c2:	eb 09                	jmp    8010cd <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010c4:	89 c2                	mov    %eax,%edx
  8010c6:	eb 05                	jmp    8010cd <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010c8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010cd:	89 d0                	mov    %edx,%eax
  8010cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d2:	c9                   	leave  
  8010d3:	c3                   	ret    

008010d4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	57                   	push   %edi
  8010d8:	56                   	push   %esi
  8010d9:	53                   	push   %ebx
  8010da:	83 ec 0c             	sub    $0xc,%esp
  8010dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010e0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010e8:	eb 21                	jmp    80110b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010ea:	83 ec 04             	sub    $0x4,%esp
  8010ed:	89 f0                	mov    %esi,%eax
  8010ef:	29 d8                	sub    %ebx,%eax
  8010f1:	50                   	push   %eax
  8010f2:	89 d8                	mov    %ebx,%eax
  8010f4:	03 45 0c             	add    0xc(%ebp),%eax
  8010f7:	50                   	push   %eax
  8010f8:	57                   	push   %edi
  8010f9:	e8 45 ff ff ff       	call   801043 <read>
		if (m < 0)
  8010fe:	83 c4 10             	add    $0x10,%esp
  801101:	85 c0                	test   %eax,%eax
  801103:	78 10                	js     801115 <readn+0x41>
			return m;
		if (m == 0)
  801105:	85 c0                	test   %eax,%eax
  801107:	74 0a                	je     801113 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801109:	01 c3                	add    %eax,%ebx
  80110b:	39 f3                	cmp    %esi,%ebx
  80110d:	72 db                	jb     8010ea <readn+0x16>
  80110f:	89 d8                	mov    %ebx,%eax
  801111:	eb 02                	jmp    801115 <readn+0x41>
  801113:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801115:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801118:	5b                   	pop    %ebx
  801119:	5e                   	pop    %esi
  80111a:	5f                   	pop    %edi
  80111b:	5d                   	pop    %ebp
  80111c:	c3                   	ret    

0080111d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80111d:	55                   	push   %ebp
  80111e:	89 e5                	mov    %esp,%ebp
  801120:	53                   	push   %ebx
  801121:	83 ec 14             	sub    $0x14,%esp
  801124:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801127:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80112a:	50                   	push   %eax
  80112b:	53                   	push   %ebx
  80112c:	e8 ac fc ff ff       	call   800ddd <fd_lookup>
  801131:	83 c4 08             	add    $0x8,%esp
  801134:	89 c2                	mov    %eax,%edx
  801136:	85 c0                	test   %eax,%eax
  801138:	78 68                	js     8011a2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80113a:	83 ec 08             	sub    $0x8,%esp
  80113d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801140:	50                   	push   %eax
  801141:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801144:	ff 30                	pushl  (%eax)
  801146:	e8 e8 fc ff ff       	call   800e33 <dev_lookup>
  80114b:	83 c4 10             	add    $0x10,%esp
  80114e:	85 c0                	test   %eax,%eax
  801150:	78 47                	js     801199 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801152:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801155:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801159:	75 21                	jne    80117c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80115b:	a1 08 40 80 00       	mov    0x804008,%eax
  801160:	8b 40 48             	mov    0x48(%eax),%eax
  801163:	83 ec 04             	sub    $0x4,%esp
  801166:	53                   	push   %ebx
  801167:	50                   	push   %eax
  801168:	68 c9 26 80 00       	push   $0x8026c9
  80116d:	e8 1b f0 ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  801172:	83 c4 10             	add    $0x10,%esp
  801175:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80117a:	eb 26                	jmp    8011a2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80117c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80117f:	8b 52 0c             	mov    0xc(%edx),%edx
  801182:	85 d2                	test   %edx,%edx
  801184:	74 17                	je     80119d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801186:	83 ec 04             	sub    $0x4,%esp
  801189:	ff 75 10             	pushl  0x10(%ebp)
  80118c:	ff 75 0c             	pushl  0xc(%ebp)
  80118f:	50                   	push   %eax
  801190:	ff d2                	call   *%edx
  801192:	89 c2                	mov    %eax,%edx
  801194:	83 c4 10             	add    $0x10,%esp
  801197:	eb 09                	jmp    8011a2 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801199:	89 c2                	mov    %eax,%edx
  80119b:	eb 05                	jmp    8011a2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80119d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011a2:	89 d0                	mov    %edx,%eax
  8011a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a7:	c9                   	leave  
  8011a8:	c3                   	ret    

008011a9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011a9:	55                   	push   %ebp
  8011aa:	89 e5                	mov    %esp,%ebp
  8011ac:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011af:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011b2:	50                   	push   %eax
  8011b3:	ff 75 08             	pushl  0x8(%ebp)
  8011b6:	e8 22 fc ff ff       	call   800ddd <fd_lookup>
  8011bb:	83 c4 08             	add    $0x8,%esp
  8011be:	85 c0                	test   %eax,%eax
  8011c0:	78 0e                	js     8011d0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011d0:	c9                   	leave  
  8011d1:	c3                   	ret    

008011d2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	53                   	push   %ebx
  8011d6:	83 ec 14             	sub    $0x14,%esp
  8011d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011df:	50                   	push   %eax
  8011e0:	53                   	push   %ebx
  8011e1:	e8 f7 fb ff ff       	call   800ddd <fd_lookup>
  8011e6:	83 c4 08             	add    $0x8,%esp
  8011e9:	89 c2                	mov    %eax,%edx
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	78 65                	js     801254 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ef:	83 ec 08             	sub    $0x8,%esp
  8011f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f5:	50                   	push   %eax
  8011f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f9:	ff 30                	pushl  (%eax)
  8011fb:	e8 33 fc ff ff       	call   800e33 <dev_lookup>
  801200:	83 c4 10             	add    $0x10,%esp
  801203:	85 c0                	test   %eax,%eax
  801205:	78 44                	js     80124b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801207:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80120e:	75 21                	jne    801231 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801210:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801215:	8b 40 48             	mov    0x48(%eax),%eax
  801218:	83 ec 04             	sub    $0x4,%esp
  80121b:	53                   	push   %ebx
  80121c:	50                   	push   %eax
  80121d:	68 8c 26 80 00       	push   $0x80268c
  801222:	e8 66 ef ff ff       	call   80018d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801227:	83 c4 10             	add    $0x10,%esp
  80122a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80122f:	eb 23                	jmp    801254 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801231:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801234:	8b 52 18             	mov    0x18(%edx),%edx
  801237:	85 d2                	test   %edx,%edx
  801239:	74 14                	je     80124f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80123b:	83 ec 08             	sub    $0x8,%esp
  80123e:	ff 75 0c             	pushl  0xc(%ebp)
  801241:	50                   	push   %eax
  801242:	ff d2                	call   *%edx
  801244:	89 c2                	mov    %eax,%edx
  801246:	83 c4 10             	add    $0x10,%esp
  801249:	eb 09                	jmp    801254 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80124b:	89 c2                	mov    %eax,%edx
  80124d:	eb 05                	jmp    801254 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80124f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801254:	89 d0                	mov    %edx,%eax
  801256:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801259:	c9                   	leave  
  80125a:	c3                   	ret    

0080125b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80125b:	55                   	push   %ebp
  80125c:	89 e5                	mov    %esp,%ebp
  80125e:	53                   	push   %ebx
  80125f:	83 ec 14             	sub    $0x14,%esp
  801262:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801265:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801268:	50                   	push   %eax
  801269:	ff 75 08             	pushl  0x8(%ebp)
  80126c:	e8 6c fb ff ff       	call   800ddd <fd_lookup>
  801271:	83 c4 08             	add    $0x8,%esp
  801274:	89 c2                	mov    %eax,%edx
  801276:	85 c0                	test   %eax,%eax
  801278:	78 58                	js     8012d2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80127a:	83 ec 08             	sub    $0x8,%esp
  80127d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801280:	50                   	push   %eax
  801281:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801284:	ff 30                	pushl  (%eax)
  801286:	e8 a8 fb ff ff       	call   800e33 <dev_lookup>
  80128b:	83 c4 10             	add    $0x10,%esp
  80128e:	85 c0                	test   %eax,%eax
  801290:	78 37                	js     8012c9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801292:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801295:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801299:	74 32                	je     8012cd <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80129b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80129e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012a5:	00 00 00 
	stat->st_isdir = 0;
  8012a8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012af:	00 00 00 
	stat->st_dev = dev;
  8012b2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012b8:	83 ec 08             	sub    $0x8,%esp
  8012bb:	53                   	push   %ebx
  8012bc:	ff 75 f0             	pushl  -0x10(%ebp)
  8012bf:	ff 50 14             	call   *0x14(%eax)
  8012c2:	89 c2                	mov    %eax,%edx
  8012c4:	83 c4 10             	add    $0x10,%esp
  8012c7:	eb 09                	jmp    8012d2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c9:	89 c2                	mov    %eax,%edx
  8012cb:	eb 05                	jmp    8012d2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012cd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012d2:	89 d0                	mov    %edx,%eax
  8012d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d7:	c9                   	leave  
  8012d8:	c3                   	ret    

008012d9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012d9:	55                   	push   %ebp
  8012da:	89 e5                	mov    %esp,%ebp
  8012dc:	56                   	push   %esi
  8012dd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012de:	83 ec 08             	sub    $0x8,%esp
  8012e1:	6a 00                	push   $0x0
  8012e3:	ff 75 08             	pushl  0x8(%ebp)
  8012e6:	e8 d6 01 00 00       	call   8014c1 <open>
  8012eb:	89 c3                	mov    %eax,%ebx
  8012ed:	83 c4 10             	add    $0x10,%esp
  8012f0:	85 c0                	test   %eax,%eax
  8012f2:	78 1b                	js     80130f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012f4:	83 ec 08             	sub    $0x8,%esp
  8012f7:	ff 75 0c             	pushl  0xc(%ebp)
  8012fa:	50                   	push   %eax
  8012fb:	e8 5b ff ff ff       	call   80125b <fstat>
  801300:	89 c6                	mov    %eax,%esi
	close(fd);
  801302:	89 1c 24             	mov    %ebx,(%esp)
  801305:	e8 fd fb ff ff       	call   800f07 <close>
	return r;
  80130a:	83 c4 10             	add    $0x10,%esp
  80130d:	89 f0                	mov    %esi,%eax
}
  80130f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801312:	5b                   	pop    %ebx
  801313:	5e                   	pop    %esi
  801314:	5d                   	pop    %ebp
  801315:	c3                   	ret    

00801316 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801316:	55                   	push   %ebp
  801317:	89 e5                	mov    %esp,%ebp
  801319:	56                   	push   %esi
  80131a:	53                   	push   %ebx
  80131b:	89 c6                	mov    %eax,%esi
  80131d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80131f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801326:	75 12                	jne    80133a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801328:	83 ec 0c             	sub    $0xc,%esp
  80132b:	6a 01                	push   $0x1
  80132d:	e8 7a 0c 00 00       	call   801fac <ipc_find_env>
  801332:	a3 00 40 80 00       	mov    %eax,0x804000
  801337:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80133a:	6a 07                	push   $0x7
  80133c:	68 00 50 80 00       	push   $0x805000
  801341:	56                   	push   %esi
  801342:	ff 35 00 40 80 00    	pushl  0x804000
  801348:	e8 0b 0c 00 00       	call   801f58 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80134d:	83 c4 0c             	add    $0xc,%esp
  801350:	6a 00                	push   $0x0
  801352:	53                   	push   %ebx
  801353:	6a 00                	push   $0x0
  801355:	e8 97 0b 00 00       	call   801ef1 <ipc_recv>
}
  80135a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80135d:	5b                   	pop    %ebx
  80135e:	5e                   	pop    %esi
  80135f:	5d                   	pop    %ebp
  801360:	c3                   	ret    

00801361 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801361:	55                   	push   %ebp
  801362:	89 e5                	mov    %esp,%ebp
  801364:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801367:	8b 45 08             	mov    0x8(%ebp),%eax
  80136a:	8b 40 0c             	mov    0xc(%eax),%eax
  80136d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801372:	8b 45 0c             	mov    0xc(%ebp),%eax
  801375:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80137a:	ba 00 00 00 00       	mov    $0x0,%edx
  80137f:	b8 02 00 00 00       	mov    $0x2,%eax
  801384:	e8 8d ff ff ff       	call   801316 <fsipc>
}
  801389:	c9                   	leave  
  80138a:	c3                   	ret    

0080138b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80138b:	55                   	push   %ebp
  80138c:	89 e5                	mov    %esp,%ebp
  80138e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801391:	8b 45 08             	mov    0x8(%ebp),%eax
  801394:	8b 40 0c             	mov    0xc(%eax),%eax
  801397:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80139c:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a1:	b8 06 00 00 00       	mov    $0x6,%eax
  8013a6:	e8 6b ff ff ff       	call   801316 <fsipc>
}
  8013ab:	c9                   	leave  
  8013ac:	c3                   	ret    

008013ad <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013ad:	55                   	push   %ebp
  8013ae:	89 e5                	mov    %esp,%ebp
  8013b0:	53                   	push   %ebx
  8013b1:	83 ec 04             	sub    $0x4,%esp
  8013b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ba:	8b 40 0c             	mov    0xc(%eax),%eax
  8013bd:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c7:	b8 05 00 00 00       	mov    $0x5,%eax
  8013cc:	e8 45 ff ff ff       	call   801316 <fsipc>
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	78 2c                	js     801401 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013d5:	83 ec 08             	sub    $0x8,%esp
  8013d8:	68 00 50 80 00       	push   $0x805000
  8013dd:	53                   	push   %ebx
  8013de:	e8 2f f3 ff ff       	call   800712 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013e3:	a1 80 50 80 00       	mov    0x805080,%eax
  8013e8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013ee:	a1 84 50 80 00       	mov    0x805084,%eax
  8013f3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013f9:	83 c4 10             	add    $0x10,%esp
  8013fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801401:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801404:	c9                   	leave  
  801405:	c3                   	ret    

00801406 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801406:	55                   	push   %ebp
  801407:	89 e5                	mov    %esp,%ebp
  801409:	83 ec 0c             	sub    $0xc,%esp
  80140c:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80140f:	8b 55 08             	mov    0x8(%ebp),%edx
  801412:	8b 52 0c             	mov    0xc(%edx),%edx
  801415:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80141b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801420:	50                   	push   %eax
  801421:	ff 75 0c             	pushl  0xc(%ebp)
  801424:	68 08 50 80 00       	push   $0x805008
  801429:	e8 76 f4 ff ff       	call   8008a4 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80142e:	ba 00 00 00 00       	mov    $0x0,%edx
  801433:	b8 04 00 00 00       	mov    $0x4,%eax
  801438:	e8 d9 fe ff ff       	call   801316 <fsipc>

}
  80143d:	c9                   	leave  
  80143e:	c3                   	ret    

0080143f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	56                   	push   %esi
  801443:	53                   	push   %ebx
  801444:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801447:	8b 45 08             	mov    0x8(%ebp),%eax
  80144a:	8b 40 0c             	mov    0xc(%eax),%eax
  80144d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801452:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801458:	ba 00 00 00 00       	mov    $0x0,%edx
  80145d:	b8 03 00 00 00       	mov    $0x3,%eax
  801462:	e8 af fe ff ff       	call   801316 <fsipc>
  801467:	89 c3                	mov    %eax,%ebx
  801469:	85 c0                	test   %eax,%eax
  80146b:	78 4b                	js     8014b8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80146d:	39 c6                	cmp    %eax,%esi
  80146f:	73 16                	jae    801487 <devfile_read+0x48>
  801471:	68 fc 26 80 00       	push   $0x8026fc
  801476:	68 03 27 80 00       	push   $0x802703
  80147b:	6a 7c                	push   $0x7c
  80147d:	68 18 27 80 00       	push   $0x802718
  801482:	e8 24 0a 00 00       	call   801eab <_panic>
	assert(r <= PGSIZE);
  801487:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80148c:	7e 16                	jle    8014a4 <devfile_read+0x65>
  80148e:	68 23 27 80 00       	push   $0x802723
  801493:	68 03 27 80 00       	push   $0x802703
  801498:	6a 7d                	push   $0x7d
  80149a:	68 18 27 80 00       	push   $0x802718
  80149f:	e8 07 0a 00 00       	call   801eab <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014a4:	83 ec 04             	sub    $0x4,%esp
  8014a7:	50                   	push   %eax
  8014a8:	68 00 50 80 00       	push   $0x805000
  8014ad:	ff 75 0c             	pushl  0xc(%ebp)
  8014b0:	e8 ef f3 ff ff       	call   8008a4 <memmove>
	return r;
  8014b5:	83 c4 10             	add    $0x10,%esp
}
  8014b8:	89 d8                	mov    %ebx,%eax
  8014ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014bd:	5b                   	pop    %ebx
  8014be:	5e                   	pop    %esi
  8014bf:	5d                   	pop    %ebp
  8014c0:	c3                   	ret    

008014c1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014c1:	55                   	push   %ebp
  8014c2:	89 e5                	mov    %esp,%ebp
  8014c4:	53                   	push   %ebx
  8014c5:	83 ec 20             	sub    $0x20,%esp
  8014c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014cb:	53                   	push   %ebx
  8014cc:	e8 08 f2 ff ff       	call   8006d9 <strlen>
  8014d1:	83 c4 10             	add    $0x10,%esp
  8014d4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014d9:	7f 67                	jg     801542 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014db:	83 ec 0c             	sub    $0xc,%esp
  8014de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e1:	50                   	push   %eax
  8014e2:	e8 a7 f8 ff ff       	call   800d8e <fd_alloc>
  8014e7:	83 c4 10             	add    $0x10,%esp
		return r;
  8014ea:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014ec:	85 c0                	test   %eax,%eax
  8014ee:	78 57                	js     801547 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014f0:	83 ec 08             	sub    $0x8,%esp
  8014f3:	53                   	push   %ebx
  8014f4:	68 00 50 80 00       	push   $0x805000
  8014f9:	e8 14 f2 ff ff       	call   800712 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801501:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801506:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801509:	b8 01 00 00 00       	mov    $0x1,%eax
  80150e:	e8 03 fe ff ff       	call   801316 <fsipc>
  801513:	89 c3                	mov    %eax,%ebx
  801515:	83 c4 10             	add    $0x10,%esp
  801518:	85 c0                	test   %eax,%eax
  80151a:	79 14                	jns    801530 <open+0x6f>
		fd_close(fd, 0);
  80151c:	83 ec 08             	sub    $0x8,%esp
  80151f:	6a 00                	push   $0x0
  801521:	ff 75 f4             	pushl  -0xc(%ebp)
  801524:	e8 5d f9 ff ff       	call   800e86 <fd_close>
		return r;
  801529:	83 c4 10             	add    $0x10,%esp
  80152c:	89 da                	mov    %ebx,%edx
  80152e:	eb 17                	jmp    801547 <open+0x86>
	}

	return fd2num(fd);
  801530:	83 ec 0c             	sub    $0xc,%esp
  801533:	ff 75 f4             	pushl  -0xc(%ebp)
  801536:	e8 2c f8 ff ff       	call   800d67 <fd2num>
  80153b:	89 c2                	mov    %eax,%edx
  80153d:	83 c4 10             	add    $0x10,%esp
  801540:	eb 05                	jmp    801547 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801542:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801547:	89 d0                	mov    %edx,%eax
  801549:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80154c:	c9                   	leave  
  80154d:	c3                   	ret    

0080154e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80154e:	55                   	push   %ebp
  80154f:	89 e5                	mov    %esp,%ebp
  801551:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801554:	ba 00 00 00 00       	mov    $0x0,%edx
  801559:	b8 08 00 00 00       	mov    $0x8,%eax
  80155e:	e8 b3 fd ff ff       	call   801316 <fsipc>
}
  801563:	c9                   	leave  
  801564:	c3                   	ret    

00801565 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801565:	55                   	push   %ebp
  801566:	89 e5                	mov    %esp,%ebp
  801568:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80156b:	68 2f 27 80 00       	push   $0x80272f
  801570:	ff 75 0c             	pushl  0xc(%ebp)
  801573:	e8 9a f1 ff ff       	call   800712 <strcpy>
	return 0;
}
  801578:	b8 00 00 00 00       	mov    $0x0,%eax
  80157d:	c9                   	leave  
  80157e:	c3                   	ret    

0080157f <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80157f:	55                   	push   %ebp
  801580:	89 e5                	mov    %esp,%ebp
  801582:	53                   	push   %ebx
  801583:	83 ec 10             	sub    $0x10,%esp
  801586:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801589:	53                   	push   %ebx
  80158a:	e8 56 0a 00 00       	call   801fe5 <pageref>
  80158f:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801592:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801597:	83 f8 01             	cmp    $0x1,%eax
  80159a:	75 10                	jne    8015ac <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80159c:	83 ec 0c             	sub    $0xc,%esp
  80159f:	ff 73 0c             	pushl  0xc(%ebx)
  8015a2:	e8 c0 02 00 00       	call   801867 <nsipc_close>
  8015a7:	89 c2                	mov    %eax,%edx
  8015a9:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8015ac:	89 d0                	mov    %edx,%eax
  8015ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b1:	c9                   	leave  
  8015b2:	c3                   	ret    

008015b3 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8015b3:	55                   	push   %ebp
  8015b4:	89 e5                	mov    %esp,%ebp
  8015b6:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8015b9:	6a 00                	push   $0x0
  8015bb:	ff 75 10             	pushl  0x10(%ebp)
  8015be:	ff 75 0c             	pushl  0xc(%ebp)
  8015c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c4:	ff 70 0c             	pushl  0xc(%eax)
  8015c7:	e8 78 03 00 00       	call   801944 <nsipc_send>
}
  8015cc:	c9                   	leave  
  8015cd:	c3                   	ret    

008015ce <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8015ce:	55                   	push   %ebp
  8015cf:	89 e5                	mov    %esp,%ebp
  8015d1:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8015d4:	6a 00                	push   $0x0
  8015d6:	ff 75 10             	pushl  0x10(%ebp)
  8015d9:	ff 75 0c             	pushl  0xc(%ebp)
  8015dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8015df:	ff 70 0c             	pushl  0xc(%eax)
  8015e2:	e8 f1 02 00 00       	call   8018d8 <nsipc_recv>
}
  8015e7:	c9                   	leave  
  8015e8:	c3                   	ret    

008015e9 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8015e9:	55                   	push   %ebp
  8015ea:	89 e5                	mov    %esp,%ebp
  8015ec:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8015ef:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015f2:	52                   	push   %edx
  8015f3:	50                   	push   %eax
  8015f4:	e8 e4 f7 ff ff       	call   800ddd <fd_lookup>
  8015f9:	83 c4 10             	add    $0x10,%esp
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	78 17                	js     801617 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801600:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801603:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801609:	39 08                	cmp    %ecx,(%eax)
  80160b:	75 05                	jne    801612 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80160d:	8b 40 0c             	mov    0xc(%eax),%eax
  801610:	eb 05                	jmp    801617 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801612:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801617:	c9                   	leave  
  801618:	c3                   	ret    

00801619 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801619:	55                   	push   %ebp
  80161a:	89 e5                	mov    %esp,%ebp
  80161c:	56                   	push   %esi
  80161d:	53                   	push   %ebx
  80161e:	83 ec 1c             	sub    $0x1c,%esp
  801621:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801623:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801626:	50                   	push   %eax
  801627:	e8 62 f7 ff ff       	call   800d8e <fd_alloc>
  80162c:	89 c3                	mov    %eax,%ebx
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	85 c0                	test   %eax,%eax
  801633:	78 1b                	js     801650 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801635:	83 ec 04             	sub    $0x4,%esp
  801638:	68 07 04 00 00       	push   $0x407
  80163d:	ff 75 f4             	pushl  -0xc(%ebp)
  801640:	6a 00                	push   $0x0
  801642:	e8 ce f4 ff ff       	call   800b15 <sys_page_alloc>
  801647:	89 c3                	mov    %eax,%ebx
  801649:	83 c4 10             	add    $0x10,%esp
  80164c:	85 c0                	test   %eax,%eax
  80164e:	79 10                	jns    801660 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801650:	83 ec 0c             	sub    $0xc,%esp
  801653:	56                   	push   %esi
  801654:	e8 0e 02 00 00       	call   801867 <nsipc_close>
		return r;
  801659:	83 c4 10             	add    $0x10,%esp
  80165c:	89 d8                	mov    %ebx,%eax
  80165e:	eb 24                	jmp    801684 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801660:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801666:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801669:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80166b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80166e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801675:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801678:	83 ec 0c             	sub    $0xc,%esp
  80167b:	50                   	push   %eax
  80167c:	e8 e6 f6 ff ff       	call   800d67 <fd2num>
  801681:	83 c4 10             	add    $0x10,%esp
}
  801684:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801687:	5b                   	pop    %ebx
  801688:	5e                   	pop    %esi
  801689:	5d                   	pop    %ebp
  80168a:	c3                   	ret    

0080168b <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801691:	8b 45 08             	mov    0x8(%ebp),%eax
  801694:	e8 50 ff ff ff       	call   8015e9 <fd2sockid>
		return r;
  801699:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80169b:	85 c0                	test   %eax,%eax
  80169d:	78 1f                	js     8016be <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80169f:	83 ec 04             	sub    $0x4,%esp
  8016a2:	ff 75 10             	pushl  0x10(%ebp)
  8016a5:	ff 75 0c             	pushl  0xc(%ebp)
  8016a8:	50                   	push   %eax
  8016a9:	e8 12 01 00 00       	call   8017c0 <nsipc_accept>
  8016ae:	83 c4 10             	add    $0x10,%esp
		return r;
  8016b1:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016b3:	85 c0                	test   %eax,%eax
  8016b5:	78 07                	js     8016be <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8016b7:	e8 5d ff ff ff       	call   801619 <alloc_sockfd>
  8016bc:	89 c1                	mov    %eax,%ecx
}
  8016be:	89 c8                	mov    %ecx,%eax
  8016c0:	c9                   	leave  
  8016c1:	c3                   	ret    

008016c2 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8016c2:	55                   	push   %ebp
  8016c3:	89 e5                	mov    %esp,%ebp
  8016c5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cb:	e8 19 ff ff ff       	call   8015e9 <fd2sockid>
  8016d0:	85 c0                	test   %eax,%eax
  8016d2:	78 12                	js     8016e6 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8016d4:	83 ec 04             	sub    $0x4,%esp
  8016d7:	ff 75 10             	pushl  0x10(%ebp)
  8016da:	ff 75 0c             	pushl  0xc(%ebp)
  8016dd:	50                   	push   %eax
  8016de:	e8 2d 01 00 00       	call   801810 <nsipc_bind>
  8016e3:	83 c4 10             	add    $0x10,%esp
}
  8016e6:	c9                   	leave  
  8016e7:	c3                   	ret    

008016e8 <shutdown>:

int
shutdown(int s, int how)
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f1:	e8 f3 fe ff ff       	call   8015e9 <fd2sockid>
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	78 0f                	js     801709 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8016fa:	83 ec 08             	sub    $0x8,%esp
  8016fd:	ff 75 0c             	pushl  0xc(%ebp)
  801700:	50                   	push   %eax
  801701:	e8 3f 01 00 00       	call   801845 <nsipc_shutdown>
  801706:	83 c4 10             	add    $0x10,%esp
}
  801709:	c9                   	leave  
  80170a:	c3                   	ret    

0080170b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80170b:	55                   	push   %ebp
  80170c:	89 e5                	mov    %esp,%ebp
  80170e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801711:	8b 45 08             	mov    0x8(%ebp),%eax
  801714:	e8 d0 fe ff ff       	call   8015e9 <fd2sockid>
  801719:	85 c0                	test   %eax,%eax
  80171b:	78 12                	js     80172f <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80171d:	83 ec 04             	sub    $0x4,%esp
  801720:	ff 75 10             	pushl  0x10(%ebp)
  801723:	ff 75 0c             	pushl  0xc(%ebp)
  801726:	50                   	push   %eax
  801727:	e8 55 01 00 00       	call   801881 <nsipc_connect>
  80172c:	83 c4 10             	add    $0x10,%esp
}
  80172f:	c9                   	leave  
  801730:	c3                   	ret    

00801731 <listen>:

int
listen(int s, int backlog)
{
  801731:	55                   	push   %ebp
  801732:	89 e5                	mov    %esp,%ebp
  801734:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801737:	8b 45 08             	mov    0x8(%ebp),%eax
  80173a:	e8 aa fe ff ff       	call   8015e9 <fd2sockid>
  80173f:	85 c0                	test   %eax,%eax
  801741:	78 0f                	js     801752 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801743:	83 ec 08             	sub    $0x8,%esp
  801746:	ff 75 0c             	pushl  0xc(%ebp)
  801749:	50                   	push   %eax
  80174a:	e8 67 01 00 00       	call   8018b6 <nsipc_listen>
  80174f:	83 c4 10             	add    $0x10,%esp
}
  801752:	c9                   	leave  
  801753:	c3                   	ret    

00801754 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801754:	55                   	push   %ebp
  801755:	89 e5                	mov    %esp,%ebp
  801757:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80175a:	ff 75 10             	pushl  0x10(%ebp)
  80175d:	ff 75 0c             	pushl  0xc(%ebp)
  801760:	ff 75 08             	pushl  0x8(%ebp)
  801763:	e8 3a 02 00 00       	call   8019a2 <nsipc_socket>
  801768:	83 c4 10             	add    $0x10,%esp
  80176b:	85 c0                	test   %eax,%eax
  80176d:	78 05                	js     801774 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80176f:	e8 a5 fe ff ff       	call   801619 <alloc_sockfd>
}
  801774:	c9                   	leave  
  801775:	c3                   	ret    

00801776 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801776:	55                   	push   %ebp
  801777:	89 e5                	mov    %esp,%ebp
  801779:	53                   	push   %ebx
  80177a:	83 ec 04             	sub    $0x4,%esp
  80177d:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80177f:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801786:	75 12                	jne    80179a <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801788:	83 ec 0c             	sub    $0xc,%esp
  80178b:	6a 02                	push   $0x2
  80178d:	e8 1a 08 00 00       	call   801fac <ipc_find_env>
  801792:	a3 04 40 80 00       	mov    %eax,0x804004
  801797:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80179a:	6a 07                	push   $0x7
  80179c:	68 00 60 80 00       	push   $0x806000
  8017a1:	53                   	push   %ebx
  8017a2:	ff 35 04 40 80 00    	pushl  0x804004
  8017a8:	e8 ab 07 00 00       	call   801f58 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8017ad:	83 c4 0c             	add    $0xc,%esp
  8017b0:	6a 00                	push   $0x0
  8017b2:	6a 00                	push   $0x0
  8017b4:	6a 00                	push   $0x0
  8017b6:	e8 36 07 00 00       	call   801ef1 <ipc_recv>
}
  8017bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017be:	c9                   	leave  
  8017bf:	c3                   	ret    

008017c0 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017c0:	55                   	push   %ebp
  8017c1:	89 e5                	mov    %esp,%ebp
  8017c3:	56                   	push   %esi
  8017c4:	53                   	push   %ebx
  8017c5:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8017c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8017d0:	8b 06                	mov    (%esi),%eax
  8017d2:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8017d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8017dc:	e8 95 ff ff ff       	call   801776 <nsipc>
  8017e1:	89 c3                	mov    %eax,%ebx
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	78 20                	js     801807 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8017e7:	83 ec 04             	sub    $0x4,%esp
  8017ea:	ff 35 10 60 80 00    	pushl  0x806010
  8017f0:	68 00 60 80 00       	push   $0x806000
  8017f5:	ff 75 0c             	pushl  0xc(%ebp)
  8017f8:	e8 a7 f0 ff ff       	call   8008a4 <memmove>
		*addrlen = ret->ret_addrlen;
  8017fd:	a1 10 60 80 00       	mov    0x806010,%eax
  801802:	89 06                	mov    %eax,(%esi)
  801804:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801807:	89 d8                	mov    %ebx,%eax
  801809:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80180c:	5b                   	pop    %ebx
  80180d:	5e                   	pop    %esi
  80180e:	5d                   	pop    %ebp
  80180f:	c3                   	ret    

00801810 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	53                   	push   %ebx
  801814:	83 ec 08             	sub    $0x8,%esp
  801817:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80181a:	8b 45 08             	mov    0x8(%ebp),%eax
  80181d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801822:	53                   	push   %ebx
  801823:	ff 75 0c             	pushl  0xc(%ebp)
  801826:	68 04 60 80 00       	push   $0x806004
  80182b:	e8 74 f0 ff ff       	call   8008a4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801830:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801836:	b8 02 00 00 00       	mov    $0x2,%eax
  80183b:	e8 36 ff ff ff       	call   801776 <nsipc>
}
  801840:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801843:	c9                   	leave  
  801844:	c3                   	ret    

00801845 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80184b:	8b 45 08             	mov    0x8(%ebp),%eax
  80184e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801853:	8b 45 0c             	mov    0xc(%ebp),%eax
  801856:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  80185b:	b8 03 00 00 00       	mov    $0x3,%eax
  801860:	e8 11 ff ff ff       	call   801776 <nsipc>
}
  801865:	c9                   	leave  
  801866:	c3                   	ret    

00801867 <nsipc_close>:

int
nsipc_close(int s)
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80186d:	8b 45 08             	mov    0x8(%ebp),%eax
  801870:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801875:	b8 04 00 00 00       	mov    $0x4,%eax
  80187a:	e8 f7 fe ff ff       	call   801776 <nsipc>
}
  80187f:	c9                   	leave  
  801880:	c3                   	ret    

00801881 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801881:	55                   	push   %ebp
  801882:	89 e5                	mov    %esp,%ebp
  801884:	53                   	push   %ebx
  801885:	83 ec 08             	sub    $0x8,%esp
  801888:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80188b:	8b 45 08             	mov    0x8(%ebp),%eax
  80188e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801893:	53                   	push   %ebx
  801894:	ff 75 0c             	pushl  0xc(%ebp)
  801897:	68 04 60 80 00       	push   $0x806004
  80189c:	e8 03 f0 ff ff       	call   8008a4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8018a1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8018a7:	b8 05 00 00 00       	mov    $0x5,%eax
  8018ac:	e8 c5 fe ff ff       	call   801776 <nsipc>
}
  8018b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b4:	c9                   	leave  
  8018b5:	c3                   	ret    

008018b6 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
  8018b9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8018bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8018c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c7:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8018cc:	b8 06 00 00 00       	mov    $0x6,%eax
  8018d1:	e8 a0 fe ff ff       	call   801776 <nsipc>
}
  8018d6:	c9                   	leave  
  8018d7:	c3                   	ret    

008018d8 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	56                   	push   %esi
  8018dc:	53                   	push   %ebx
  8018dd:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8018e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8018e8:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8018ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8018f1:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8018f6:	b8 07 00 00 00       	mov    $0x7,%eax
  8018fb:	e8 76 fe ff ff       	call   801776 <nsipc>
  801900:	89 c3                	mov    %eax,%ebx
  801902:	85 c0                	test   %eax,%eax
  801904:	78 35                	js     80193b <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801906:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80190b:	7f 04                	jg     801911 <nsipc_recv+0x39>
  80190d:	39 c6                	cmp    %eax,%esi
  80190f:	7d 16                	jge    801927 <nsipc_recv+0x4f>
  801911:	68 3b 27 80 00       	push   $0x80273b
  801916:	68 03 27 80 00       	push   $0x802703
  80191b:	6a 62                	push   $0x62
  80191d:	68 50 27 80 00       	push   $0x802750
  801922:	e8 84 05 00 00       	call   801eab <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801927:	83 ec 04             	sub    $0x4,%esp
  80192a:	50                   	push   %eax
  80192b:	68 00 60 80 00       	push   $0x806000
  801930:	ff 75 0c             	pushl  0xc(%ebp)
  801933:	e8 6c ef ff ff       	call   8008a4 <memmove>
  801938:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80193b:	89 d8                	mov    %ebx,%eax
  80193d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801940:	5b                   	pop    %ebx
  801941:	5e                   	pop    %esi
  801942:	5d                   	pop    %ebp
  801943:	c3                   	ret    

00801944 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
  801947:	53                   	push   %ebx
  801948:	83 ec 04             	sub    $0x4,%esp
  80194b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80194e:	8b 45 08             	mov    0x8(%ebp),%eax
  801951:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801956:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80195c:	7e 16                	jle    801974 <nsipc_send+0x30>
  80195e:	68 5c 27 80 00       	push   $0x80275c
  801963:	68 03 27 80 00       	push   $0x802703
  801968:	6a 6d                	push   $0x6d
  80196a:	68 50 27 80 00       	push   $0x802750
  80196f:	e8 37 05 00 00       	call   801eab <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801974:	83 ec 04             	sub    $0x4,%esp
  801977:	53                   	push   %ebx
  801978:	ff 75 0c             	pushl  0xc(%ebp)
  80197b:	68 0c 60 80 00       	push   $0x80600c
  801980:	e8 1f ef ff ff       	call   8008a4 <memmove>
	nsipcbuf.send.req_size = size;
  801985:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80198b:	8b 45 14             	mov    0x14(%ebp),%eax
  80198e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801993:	b8 08 00 00 00       	mov    $0x8,%eax
  801998:	e8 d9 fd ff ff       	call   801776 <nsipc>
}
  80199d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a0:	c9                   	leave  
  8019a1:	c3                   	ret    

008019a2 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8019a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ab:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8019b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b3:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8019b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8019bb:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8019c0:	b8 09 00 00 00       	mov    $0x9,%eax
  8019c5:	e8 ac fd ff ff       	call   801776 <nsipc>
}
  8019ca:	c9                   	leave  
  8019cb:	c3                   	ret    

008019cc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019cc:	55                   	push   %ebp
  8019cd:	89 e5                	mov    %esp,%ebp
  8019cf:	56                   	push   %esi
  8019d0:	53                   	push   %ebx
  8019d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019d4:	83 ec 0c             	sub    $0xc,%esp
  8019d7:	ff 75 08             	pushl  0x8(%ebp)
  8019da:	e8 98 f3 ff ff       	call   800d77 <fd2data>
  8019df:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019e1:	83 c4 08             	add    $0x8,%esp
  8019e4:	68 68 27 80 00       	push   $0x802768
  8019e9:	53                   	push   %ebx
  8019ea:	e8 23 ed ff ff       	call   800712 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019ef:	8b 46 04             	mov    0x4(%esi),%eax
  8019f2:	2b 06                	sub    (%esi),%eax
  8019f4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019fa:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a01:	00 00 00 
	stat->st_dev = &devpipe;
  801a04:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a0b:	30 80 00 
	return 0;
}
  801a0e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a16:	5b                   	pop    %ebx
  801a17:	5e                   	pop    %esi
  801a18:	5d                   	pop    %ebp
  801a19:	c3                   	ret    

00801a1a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	53                   	push   %ebx
  801a1e:	83 ec 0c             	sub    $0xc,%esp
  801a21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a24:	53                   	push   %ebx
  801a25:	6a 00                	push   $0x0
  801a27:	e8 6e f1 ff ff       	call   800b9a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a2c:	89 1c 24             	mov    %ebx,(%esp)
  801a2f:	e8 43 f3 ff ff       	call   800d77 <fd2data>
  801a34:	83 c4 08             	add    $0x8,%esp
  801a37:	50                   	push   %eax
  801a38:	6a 00                	push   $0x0
  801a3a:	e8 5b f1 ff ff       	call   800b9a <sys_page_unmap>
}
  801a3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a42:	c9                   	leave  
  801a43:	c3                   	ret    

00801a44 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a44:	55                   	push   %ebp
  801a45:	89 e5                	mov    %esp,%ebp
  801a47:	57                   	push   %edi
  801a48:	56                   	push   %esi
  801a49:	53                   	push   %ebx
  801a4a:	83 ec 1c             	sub    $0x1c,%esp
  801a4d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a50:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a52:	a1 08 40 80 00       	mov    0x804008,%eax
  801a57:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a5a:	83 ec 0c             	sub    $0xc,%esp
  801a5d:	ff 75 e0             	pushl  -0x20(%ebp)
  801a60:	e8 80 05 00 00       	call   801fe5 <pageref>
  801a65:	89 c3                	mov    %eax,%ebx
  801a67:	89 3c 24             	mov    %edi,(%esp)
  801a6a:	e8 76 05 00 00       	call   801fe5 <pageref>
  801a6f:	83 c4 10             	add    $0x10,%esp
  801a72:	39 c3                	cmp    %eax,%ebx
  801a74:	0f 94 c1             	sete   %cl
  801a77:	0f b6 c9             	movzbl %cl,%ecx
  801a7a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a7d:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a83:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a86:	39 ce                	cmp    %ecx,%esi
  801a88:	74 1b                	je     801aa5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a8a:	39 c3                	cmp    %eax,%ebx
  801a8c:	75 c4                	jne    801a52 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a8e:	8b 42 58             	mov    0x58(%edx),%eax
  801a91:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a94:	50                   	push   %eax
  801a95:	56                   	push   %esi
  801a96:	68 6f 27 80 00       	push   $0x80276f
  801a9b:	e8 ed e6 ff ff       	call   80018d <cprintf>
  801aa0:	83 c4 10             	add    $0x10,%esp
  801aa3:	eb ad                	jmp    801a52 <_pipeisclosed+0xe>
	}
}
  801aa5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aa8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aab:	5b                   	pop    %ebx
  801aac:	5e                   	pop    %esi
  801aad:	5f                   	pop    %edi
  801aae:	5d                   	pop    %ebp
  801aaf:	c3                   	ret    

00801ab0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ab0:	55                   	push   %ebp
  801ab1:	89 e5                	mov    %esp,%ebp
  801ab3:	57                   	push   %edi
  801ab4:	56                   	push   %esi
  801ab5:	53                   	push   %ebx
  801ab6:	83 ec 28             	sub    $0x28,%esp
  801ab9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801abc:	56                   	push   %esi
  801abd:	e8 b5 f2 ff ff       	call   800d77 <fd2data>
  801ac2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac4:	83 c4 10             	add    $0x10,%esp
  801ac7:	bf 00 00 00 00       	mov    $0x0,%edi
  801acc:	eb 4b                	jmp    801b19 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ace:	89 da                	mov    %ebx,%edx
  801ad0:	89 f0                	mov    %esi,%eax
  801ad2:	e8 6d ff ff ff       	call   801a44 <_pipeisclosed>
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	75 48                	jne    801b23 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801adb:	e8 16 f0 ff ff       	call   800af6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ae0:	8b 43 04             	mov    0x4(%ebx),%eax
  801ae3:	8b 0b                	mov    (%ebx),%ecx
  801ae5:	8d 51 20             	lea    0x20(%ecx),%edx
  801ae8:	39 d0                	cmp    %edx,%eax
  801aea:	73 e2                	jae    801ace <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801aec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aef:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801af3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801af6:	89 c2                	mov    %eax,%edx
  801af8:	c1 fa 1f             	sar    $0x1f,%edx
  801afb:	89 d1                	mov    %edx,%ecx
  801afd:	c1 e9 1b             	shr    $0x1b,%ecx
  801b00:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b03:	83 e2 1f             	and    $0x1f,%edx
  801b06:	29 ca                	sub    %ecx,%edx
  801b08:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b0c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b10:	83 c0 01             	add    $0x1,%eax
  801b13:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b16:	83 c7 01             	add    $0x1,%edi
  801b19:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b1c:	75 c2                	jne    801ae0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b1e:	8b 45 10             	mov    0x10(%ebp),%eax
  801b21:	eb 05                	jmp    801b28 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b23:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b2b:	5b                   	pop    %ebx
  801b2c:	5e                   	pop    %esi
  801b2d:	5f                   	pop    %edi
  801b2e:	5d                   	pop    %ebp
  801b2f:	c3                   	ret    

00801b30 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	57                   	push   %edi
  801b34:	56                   	push   %esi
  801b35:	53                   	push   %ebx
  801b36:	83 ec 18             	sub    $0x18,%esp
  801b39:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b3c:	57                   	push   %edi
  801b3d:	e8 35 f2 ff ff       	call   800d77 <fd2data>
  801b42:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b44:	83 c4 10             	add    $0x10,%esp
  801b47:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b4c:	eb 3d                	jmp    801b8b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b4e:	85 db                	test   %ebx,%ebx
  801b50:	74 04                	je     801b56 <devpipe_read+0x26>
				return i;
  801b52:	89 d8                	mov    %ebx,%eax
  801b54:	eb 44                	jmp    801b9a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b56:	89 f2                	mov    %esi,%edx
  801b58:	89 f8                	mov    %edi,%eax
  801b5a:	e8 e5 fe ff ff       	call   801a44 <_pipeisclosed>
  801b5f:	85 c0                	test   %eax,%eax
  801b61:	75 32                	jne    801b95 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b63:	e8 8e ef ff ff       	call   800af6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b68:	8b 06                	mov    (%esi),%eax
  801b6a:	3b 46 04             	cmp    0x4(%esi),%eax
  801b6d:	74 df                	je     801b4e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b6f:	99                   	cltd   
  801b70:	c1 ea 1b             	shr    $0x1b,%edx
  801b73:	01 d0                	add    %edx,%eax
  801b75:	83 e0 1f             	and    $0x1f,%eax
  801b78:	29 d0                	sub    %edx,%eax
  801b7a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b82:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b85:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b88:	83 c3 01             	add    $0x1,%ebx
  801b8b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b8e:	75 d8                	jne    801b68 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b90:	8b 45 10             	mov    0x10(%ebp),%eax
  801b93:	eb 05                	jmp    801b9a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b95:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b9d:	5b                   	pop    %ebx
  801b9e:	5e                   	pop    %esi
  801b9f:	5f                   	pop    %edi
  801ba0:	5d                   	pop    %ebp
  801ba1:	c3                   	ret    

00801ba2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ba2:	55                   	push   %ebp
  801ba3:	89 e5                	mov    %esp,%ebp
  801ba5:	56                   	push   %esi
  801ba6:	53                   	push   %ebx
  801ba7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801baa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bad:	50                   	push   %eax
  801bae:	e8 db f1 ff ff       	call   800d8e <fd_alloc>
  801bb3:	83 c4 10             	add    $0x10,%esp
  801bb6:	89 c2                	mov    %eax,%edx
  801bb8:	85 c0                	test   %eax,%eax
  801bba:	0f 88 2c 01 00 00    	js     801cec <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc0:	83 ec 04             	sub    $0x4,%esp
  801bc3:	68 07 04 00 00       	push   $0x407
  801bc8:	ff 75 f4             	pushl  -0xc(%ebp)
  801bcb:	6a 00                	push   $0x0
  801bcd:	e8 43 ef ff ff       	call   800b15 <sys_page_alloc>
  801bd2:	83 c4 10             	add    $0x10,%esp
  801bd5:	89 c2                	mov    %eax,%edx
  801bd7:	85 c0                	test   %eax,%eax
  801bd9:	0f 88 0d 01 00 00    	js     801cec <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bdf:	83 ec 0c             	sub    $0xc,%esp
  801be2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801be5:	50                   	push   %eax
  801be6:	e8 a3 f1 ff ff       	call   800d8e <fd_alloc>
  801beb:	89 c3                	mov    %eax,%ebx
  801bed:	83 c4 10             	add    $0x10,%esp
  801bf0:	85 c0                	test   %eax,%eax
  801bf2:	0f 88 e2 00 00 00    	js     801cda <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf8:	83 ec 04             	sub    $0x4,%esp
  801bfb:	68 07 04 00 00       	push   $0x407
  801c00:	ff 75 f0             	pushl  -0x10(%ebp)
  801c03:	6a 00                	push   $0x0
  801c05:	e8 0b ef ff ff       	call   800b15 <sys_page_alloc>
  801c0a:	89 c3                	mov    %eax,%ebx
  801c0c:	83 c4 10             	add    $0x10,%esp
  801c0f:	85 c0                	test   %eax,%eax
  801c11:	0f 88 c3 00 00 00    	js     801cda <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c17:	83 ec 0c             	sub    $0xc,%esp
  801c1a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c1d:	e8 55 f1 ff ff       	call   800d77 <fd2data>
  801c22:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c24:	83 c4 0c             	add    $0xc,%esp
  801c27:	68 07 04 00 00       	push   $0x407
  801c2c:	50                   	push   %eax
  801c2d:	6a 00                	push   $0x0
  801c2f:	e8 e1 ee ff ff       	call   800b15 <sys_page_alloc>
  801c34:	89 c3                	mov    %eax,%ebx
  801c36:	83 c4 10             	add    $0x10,%esp
  801c39:	85 c0                	test   %eax,%eax
  801c3b:	0f 88 89 00 00 00    	js     801cca <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c41:	83 ec 0c             	sub    $0xc,%esp
  801c44:	ff 75 f0             	pushl  -0x10(%ebp)
  801c47:	e8 2b f1 ff ff       	call   800d77 <fd2data>
  801c4c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c53:	50                   	push   %eax
  801c54:	6a 00                	push   $0x0
  801c56:	56                   	push   %esi
  801c57:	6a 00                	push   $0x0
  801c59:	e8 fa ee ff ff       	call   800b58 <sys_page_map>
  801c5e:	89 c3                	mov    %eax,%ebx
  801c60:	83 c4 20             	add    $0x20,%esp
  801c63:	85 c0                	test   %eax,%eax
  801c65:	78 55                	js     801cbc <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c67:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c70:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c75:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c7c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c85:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c87:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c8a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c91:	83 ec 0c             	sub    $0xc,%esp
  801c94:	ff 75 f4             	pushl  -0xc(%ebp)
  801c97:	e8 cb f0 ff ff       	call   800d67 <fd2num>
  801c9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c9f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ca1:	83 c4 04             	add    $0x4,%esp
  801ca4:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca7:	e8 bb f0 ff ff       	call   800d67 <fd2num>
  801cac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801caf:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cb2:	83 c4 10             	add    $0x10,%esp
  801cb5:	ba 00 00 00 00       	mov    $0x0,%edx
  801cba:	eb 30                	jmp    801cec <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cbc:	83 ec 08             	sub    $0x8,%esp
  801cbf:	56                   	push   %esi
  801cc0:	6a 00                	push   $0x0
  801cc2:	e8 d3 ee ff ff       	call   800b9a <sys_page_unmap>
  801cc7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cca:	83 ec 08             	sub    $0x8,%esp
  801ccd:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd0:	6a 00                	push   $0x0
  801cd2:	e8 c3 ee ff ff       	call   800b9a <sys_page_unmap>
  801cd7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cda:	83 ec 08             	sub    $0x8,%esp
  801cdd:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce0:	6a 00                	push   $0x0
  801ce2:	e8 b3 ee ff ff       	call   800b9a <sys_page_unmap>
  801ce7:	83 c4 10             	add    $0x10,%esp
  801cea:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cec:	89 d0                	mov    %edx,%eax
  801cee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cf1:	5b                   	pop    %ebx
  801cf2:	5e                   	pop    %esi
  801cf3:	5d                   	pop    %ebp
  801cf4:	c3                   	ret    

00801cf5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cf5:	55                   	push   %ebp
  801cf6:	89 e5                	mov    %esp,%ebp
  801cf8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cfb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cfe:	50                   	push   %eax
  801cff:	ff 75 08             	pushl  0x8(%ebp)
  801d02:	e8 d6 f0 ff ff       	call   800ddd <fd_lookup>
  801d07:	83 c4 10             	add    $0x10,%esp
  801d0a:	85 c0                	test   %eax,%eax
  801d0c:	78 18                	js     801d26 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d0e:	83 ec 0c             	sub    $0xc,%esp
  801d11:	ff 75 f4             	pushl  -0xc(%ebp)
  801d14:	e8 5e f0 ff ff       	call   800d77 <fd2data>
	return _pipeisclosed(fd, p);
  801d19:	89 c2                	mov    %eax,%edx
  801d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1e:	e8 21 fd ff ff       	call   801a44 <_pipeisclosed>
  801d23:	83 c4 10             	add    $0x10,%esp
}
  801d26:	c9                   	leave  
  801d27:	c3                   	ret    

00801d28 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d28:	55                   	push   %ebp
  801d29:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d2b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d30:	5d                   	pop    %ebp
  801d31:	c3                   	ret    

00801d32 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d32:	55                   	push   %ebp
  801d33:	89 e5                	mov    %esp,%ebp
  801d35:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d38:	68 87 27 80 00       	push   $0x802787
  801d3d:	ff 75 0c             	pushl  0xc(%ebp)
  801d40:	e8 cd e9 ff ff       	call   800712 <strcpy>
	return 0;
}
  801d45:	b8 00 00 00 00       	mov    $0x0,%eax
  801d4a:	c9                   	leave  
  801d4b:	c3                   	ret    

00801d4c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
  801d4f:	57                   	push   %edi
  801d50:	56                   	push   %esi
  801d51:	53                   	push   %ebx
  801d52:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d58:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d5d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d63:	eb 2d                	jmp    801d92 <devcons_write+0x46>
		m = n - tot;
  801d65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d68:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d6a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d6d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d72:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d75:	83 ec 04             	sub    $0x4,%esp
  801d78:	53                   	push   %ebx
  801d79:	03 45 0c             	add    0xc(%ebp),%eax
  801d7c:	50                   	push   %eax
  801d7d:	57                   	push   %edi
  801d7e:	e8 21 eb ff ff       	call   8008a4 <memmove>
		sys_cputs(buf, m);
  801d83:	83 c4 08             	add    $0x8,%esp
  801d86:	53                   	push   %ebx
  801d87:	57                   	push   %edi
  801d88:	e8 cc ec ff ff       	call   800a59 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d8d:	01 de                	add    %ebx,%esi
  801d8f:	83 c4 10             	add    $0x10,%esp
  801d92:	89 f0                	mov    %esi,%eax
  801d94:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d97:	72 cc                	jb     801d65 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d9c:	5b                   	pop    %ebx
  801d9d:	5e                   	pop    %esi
  801d9e:	5f                   	pop    %edi
  801d9f:	5d                   	pop    %ebp
  801da0:	c3                   	ret    

00801da1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801da1:	55                   	push   %ebp
  801da2:	89 e5                	mov    %esp,%ebp
  801da4:	83 ec 08             	sub    $0x8,%esp
  801da7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801dac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801db0:	74 2a                	je     801ddc <devcons_read+0x3b>
  801db2:	eb 05                	jmp    801db9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801db4:	e8 3d ed ff ff       	call   800af6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801db9:	e8 b9 ec ff ff       	call   800a77 <sys_cgetc>
  801dbe:	85 c0                	test   %eax,%eax
  801dc0:	74 f2                	je     801db4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801dc2:	85 c0                	test   %eax,%eax
  801dc4:	78 16                	js     801ddc <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dc6:	83 f8 04             	cmp    $0x4,%eax
  801dc9:	74 0c                	je     801dd7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801dcb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dce:	88 02                	mov    %al,(%edx)
	return 1;
  801dd0:	b8 01 00 00 00       	mov    $0x1,%eax
  801dd5:	eb 05                	jmp    801ddc <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dd7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ddc:	c9                   	leave  
  801ddd:	c3                   	ret    

00801dde <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dde:	55                   	push   %ebp
  801ddf:	89 e5                	mov    %esp,%ebp
  801de1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801de4:	8b 45 08             	mov    0x8(%ebp),%eax
  801de7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801dea:	6a 01                	push   $0x1
  801dec:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801def:	50                   	push   %eax
  801df0:	e8 64 ec ff ff       	call   800a59 <sys_cputs>
}
  801df5:	83 c4 10             	add    $0x10,%esp
  801df8:	c9                   	leave  
  801df9:	c3                   	ret    

00801dfa <getchar>:

int
getchar(void)
{
  801dfa:	55                   	push   %ebp
  801dfb:	89 e5                	mov    %esp,%ebp
  801dfd:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e00:	6a 01                	push   $0x1
  801e02:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e05:	50                   	push   %eax
  801e06:	6a 00                	push   $0x0
  801e08:	e8 36 f2 ff ff       	call   801043 <read>
	if (r < 0)
  801e0d:	83 c4 10             	add    $0x10,%esp
  801e10:	85 c0                	test   %eax,%eax
  801e12:	78 0f                	js     801e23 <getchar+0x29>
		return r;
	if (r < 1)
  801e14:	85 c0                	test   %eax,%eax
  801e16:	7e 06                	jle    801e1e <getchar+0x24>
		return -E_EOF;
	return c;
  801e18:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e1c:	eb 05                	jmp    801e23 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e1e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e23:	c9                   	leave  
  801e24:	c3                   	ret    

00801e25 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e25:	55                   	push   %ebp
  801e26:	89 e5                	mov    %esp,%ebp
  801e28:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e2e:	50                   	push   %eax
  801e2f:	ff 75 08             	pushl  0x8(%ebp)
  801e32:	e8 a6 ef ff ff       	call   800ddd <fd_lookup>
  801e37:	83 c4 10             	add    $0x10,%esp
  801e3a:	85 c0                	test   %eax,%eax
  801e3c:	78 11                	js     801e4f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e41:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e47:	39 10                	cmp    %edx,(%eax)
  801e49:	0f 94 c0             	sete   %al
  801e4c:	0f b6 c0             	movzbl %al,%eax
}
  801e4f:	c9                   	leave  
  801e50:	c3                   	ret    

00801e51 <opencons>:

int
opencons(void)
{
  801e51:	55                   	push   %ebp
  801e52:	89 e5                	mov    %esp,%ebp
  801e54:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e5a:	50                   	push   %eax
  801e5b:	e8 2e ef ff ff       	call   800d8e <fd_alloc>
  801e60:	83 c4 10             	add    $0x10,%esp
		return r;
  801e63:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e65:	85 c0                	test   %eax,%eax
  801e67:	78 3e                	js     801ea7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e69:	83 ec 04             	sub    $0x4,%esp
  801e6c:	68 07 04 00 00       	push   $0x407
  801e71:	ff 75 f4             	pushl  -0xc(%ebp)
  801e74:	6a 00                	push   $0x0
  801e76:	e8 9a ec ff ff       	call   800b15 <sys_page_alloc>
  801e7b:	83 c4 10             	add    $0x10,%esp
		return r;
  801e7e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e80:	85 c0                	test   %eax,%eax
  801e82:	78 23                	js     801ea7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e84:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e92:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e99:	83 ec 0c             	sub    $0xc,%esp
  801e9c:	50                   	push   %eax
  801e9d:	e8 c5 ee ff ff       	call   800d67 <fd2num>
  801ea2:	89 c2                	mov    %eax,%edx
  801ea4:	83 c4 10             	add    $0x10,%esp
}
  801ea7:	89 d0                	mov    %edx,%eax
  801ea9:	c9                   	leave  
  801eaa:	c3                   	ret    

00801eab <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801eab:	55                   	push   %ebp
  801eac:	89 e5                	mov    %esp,%ebp
  801eae:	56                   	push   %esi
  801eaf:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801eb0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801eb3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801eb9:	e8 19 ec ff ff       	call   800ad7 <sys_getenvid>
  801ebe:	83 ec 0c             	sub    $0xc,%esp
  801ec1:	ff 75 0c             	pushl  0xc(%ebp)
  801ec4:	ff 75 08             	pushl  0x8(%ebp)
  801ec7:	56                   	push   %esi
  801ec8:	50                   	push   %eax
  801ec9:	68 94 27 80 00       	push   $0x802794
  801ece:	e8 ba e2 ff ff       	call   80018d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ed3:	83 c4 18             	add    $0x18,%esp
  801ed6:	53                   	push   %ebx
  801ed7:	ff 75 10             	pushl  0x10(%ebp)
  801eda:	e8 5d e2 ff ff       	call   80013c <vcprintf>
	cprintf("\n");
  801edf:	c7 04 24 80 27 80 00 	movl   $0x802780,(%esp)
  801ee6:	e8 a2 e2 ff ff       	call   80018d <cprintf>
  801eeb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801eee:	cc                   	int3   
  801eef:	eb fd                	jmp    801eee <_panic+0x43>

00801ef1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ef1:	55                   	push   %ebp
  801ef2:	89 e5                	mov    %esp,%ebp
  801ef4:	56                   	push   %esi
  801ef5:	53                   	push   %ebx
  801ef6:	8b 75 08             	mov    0x8(%ebp),%esi
  801ef9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801efc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801eff:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801f01:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f06:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801f09:	83 ec 0c             	sub    $0xc,%esp
  801f0c:	50                   	push   %eax
  801f0d:	e8 b3 ed ff ff       	call   800cc5 <sys_ipc_recv>

	if (from_env_store != NULL)
  801f12:	83 c4 10             	add    $0x10,%esp
  801f15:	85 f6                	test   %esi,%esi
  801f17:	74 14                	je     801f2d <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801f19:	ba 00 00 00 00       	mov    $0x0,%edx
  801f1e:	85 c0                	test   %eax,%eax
  801f20:	78 09                	js     801f2b <ipc_recv+0x3a>
  801f22:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f28:	8b 52 74             	mov    0x74(%edx),%edx
  801f2b:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801f2d:	85 db                	test   %ebx,%ebx
  801f2f:	74 14                	je     801f45 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801f31:	ba 00 00 00 00       	mov    $0x0,%edx
  801f36:	85 c0                	test   %eax,%eax
  801f38:	78 09                	js     801f43 <ipc_recv+0x52>
  801f3a:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f40:	8b 52 78             	mov    0x78(%edx),%edx
  801f43:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801f45:	85 c0                	test   %eax,%eax
  801f47:	78 08                	js     801f51 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801f49:	a1 08 40 80 00       	mov    0x804008,%eax
  801f4e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f54:	5b                   	pop    %ebx
  801f55:	5e                   	pop    %esi
  801f56:	5d                   	pop    %ebp
  801f57:	c3                   	ret    

00801f58 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f58:	55                   	push   %ebp
  801f59:	89 e5                	mov    %esp,%ebp
  801f5b:	57                   	push   %edi
  801f5c:	56                   	push   %esi
  801f5d:	53                   	push   %ebx
  801f5e:	83 ec 0c             	sub    $0xc,%esp
  801f61:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f64:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f6a:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f6c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f71:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f74:	ff 75 14             	pushl  0x14(%ebp)
  801f77:	53                   	push   %ebx
  801f78:	56                   	push   %esi
  801f79:	57                   	push   %edi
  801f7a:	e8 23 ed ff ff       	call   800ca2 <sys_ipc_try_send>

		if (err < 0) {
  801f7f:	83 c4 10             	add    $0x10,%esp
  801f82:	85 c0                	test   %eax,%eax
  801f84:	79 1e                	jns    801fa4 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801f86:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f89:	75 07                	jne    801f92 <ipc_send+0x3a>
				sys_yield();
  801f8b:	e8 66 eb ff ff       	call   800af6 <sys_yield>
  801f90:	eb e2                	jmp    801f74 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f92:	50                   	push   %eax
  801f93:	68 b8 27 80 00       	push   $0x8027b8
  801f98:	6a 49                	push   $0x49
  801f9a:	68 c5 27 80 00       	push   $0x8027c5
  801f9f:	e8 07 ff ff ff       	call   801eab <_panic>
		}

	} while (err < 0);

}
  801fa4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fa7:	5b                   	pop    %ebx
  801fa8:	5e                   	pop    %esi
  801fa9:	5f                   	pop    %edi
  801faa:	5d                   	pop    %ebp
  801fab:	c3                   	ret    

00801fac <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fac:	55                   	push   %ebp
  801fad:	89 e5                	mov    %esp,%ebp
  801faf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fb2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fb7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fba:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fc0:	8b 52 50             	mov    0x50(%edx),%edx
  801fc3:	39 ca                	cmp    %ecx,%edx
  801fc5:	75 0d                	jne    801fd4 <ipc_find_env+0x28>
			return envs[i].env_id;
  801fc7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fcf:	8b 40 48             	mov    0x48(%eax),%eax
  801fd2:	eb 0f                	jmp    801fe3 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fd4:	83 c0 01             	add    $0x1,%eax
  801fd7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fdc:	75 d9                	jne    801fb7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fde:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fe3:	5d                   	pop    %ebp
  801fe4:	c3                   	ret    

00801fe5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fe5:	55                   	push   %ebp
  801fe6:	89 e5                	mov    %esp,%ebp
  801fe8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801feb:	89 d0                	mov    %edx,%eax
  801fed:	c1 e8 16             	shr    $0x16,%eax
  801ff0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ff7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ffc:	f6 c1 01             	test   $0x1,%cl
  801fff:	74 1d                	je     80201e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802001:	c1 ea 0c             	shr    $0xc,%edx
  802004:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80200b:	f6 c2 01             	test   $0x1,%dl
  80200e:	74 0e                	je     80201e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802010:	c1 ea 0c             	shr    $0xc,%edx
  802013:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80201a:	ef 
  80201b:	0f b7 c0             	movzwl %ax,%eax
}
  80201e:	5d                   	pop    %ebp
  80201f:	c3                   	ret    

00802020 <__udivdi3>:
  802020:	55                   	push   %ebp
  802021:	57                   	push   %edi
  802022:	56                   	push   %esi
  802023:	53                   	push   %ebx
  802024:	83 ec 1c             	sub    $0x1c,%esp
  802027:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80202b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80202f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802033:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802037:	85 f6                	test   %esi,%esi
  802039:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80203d:	89 ca                	mov    %ecx,%edx
  80203f:	89 f8                	mov    %edi,%eax
  802041:	75 3d                	jne    802080 <__udivdi3+0x60>
  802043:	39 cf                	cmp    %ecx,%edi
  802045:	0f 87 c5 00 00 00    	ja     802110 <__udivdi3+0xf0>
  80204b:	85 ff                	test   %edi,%edi
  80204d:	89 fd                	mov    %edi,%ebp
  80204f:	75 0b                	jne    80205c <__udivdi3+0x3c>
  802051:	b8 01 00 00 00       	mov    $0x1,%eax
  802056:	31 d2                	xor    %edx,%edx
  802058:	f7 f7                	div    %edi
  80205a:	89 c5                	mov    %eax,%ebp
  80205c:	89 c8                	mov    %ecx,%eax
  80205e:	31 d2                	xor    %edx,%edx
  802060:	f7 f5                	div    %ebp
  802062:	89 c1                	mov    %eax,%ecx
  802064:	89 d8                	mov    %ebx,%eax
  802066:	89 cf                	mov    %ecx,%edi
  802068:	f7 f5                	div    %ebp
  80206a:	89 c3                	mov    %eax,%ebx
  80206c:	89 d8                	mov    %ebx,%eax
  80206e:	89 fa                	mov    %edi,%edx
  802070:	83 c4 1c             	add    $0x1c,%esp
  802073:	5b                   	pop    %ebx
  802074:	5e                   	pop    %esi
  802075:	5f                   	pop    %edi
  802076:	5d                   	pop    %ebp
  802077:	c3                   	ret    
  802078:	90                   	nop
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	39 ce                	cmp    %ecx,%esi
  802082:	77 74                	ja     8020f8 <__udivdi3+0xd8>
  802084:	0f bd fe             	bsr    %esi,%edi
  802087:	83 f7 1f             	xor    $0x1f,%edi
  80208a:	0f 84 98 00 00 00    	je     802128 <__udivdi3+0x108>
  802090:	bb 20 00 00 00       	mov    $0x20,%ebx
  802095:	89 f9                	mov    %edi,%ecx
  802097:	89 c5                	mov    %eax,%ebp
  802099:	29 fb                	sub    %edi,%ebx
  80209b:	d3 e6                	shl    %cl,%esi
  80209d:	89 d9                	mov    %ebx,%ecx
  80209f:	d3 ed                	shr    %cl,%ebp
  8020a1:	89 f9                	mov    %edi,%ecx
  8020a3:	d3 e0                	shl    %cl,%eax
  8020a5:	09 ee                	or     %ebp,%esi
  8020a7:	89 d9                	mov    %ebx,%ecx
  8020a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020ad:	89 d5                	mov    %edx,%ebp
  8020af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020b3:	d3 ed                	shr    %cl,%ebp
  8020b5:	89 f9                	mov    %edi,%ecx
  8020b7:	d3 e2                	shl    %cl,%edx
  8020b9:	89 d9                	mov    %ebx,%ecx
  8020bb:	d3 e8                	shr    %cl,%eax
  8020bd:	09 c2                	or     %eax,%edx
  8020bf:	89 d0                	mov    %edx,%eax
  8020c1:	89 ea                	mov    %ebp,%edx
  8020c3:	f7 f6                	div    %esi
  8020c5:	89 d5                	mov    %edx,%ebp
  8020c7:	89 c3                	mov    %eax,%ebx
  8020c9:	f7 64 24 0c          	mull   0xc(%esp)
  8020cd:	39 d5                	cmp    %edx,%ebp
  8020cf:	72 10                	jb     8020e1 <__udivdi3+0xc1>
  8020d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020d5:	89 f9                	mov    %edi,%ecx
  8020d7:	d3 e6                	shl    %cl,%esi
  8020d9:	39 c6                	cmp    %eax,%esi
  8020db:	73 07                	jae    8020e4 <__udivdi3+0xc4>
  8020dd:	39 d5                	cmp    %edx,%ebp
  8020df:	75 03                	jne    8020e4 <__udivdi3+0xc4>
  8020e1:	83 eb 01             	sub    $0x1,%ebx
  8020e4:	31 ff                	xor    %edi,%edi
  8020e6:	89 d8                	mov    %ebx,%eax
  8020e8:	89 fa                	mov    %edi,%edx
  8020ea:	83 c4 1c             	add    $0x1c,%esp
  8020ed:	5b                   	pop    %ebx
  8020ee:	5e                   	pop    %esi
  8020ef:	5f                   	pop    %edi
  8020f0:	5d                   	pop    %ebp
  8020f1:	c3                   	ret    
  8020f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020f8:	31 ff                	xor    %edi,%edi
  8020fa:	31 db                	xor    %ebx,%ebx
  8020fc:	89 d8                	mov    %ebx,%eax
  8020fe:	89 fa                	mov    %edi,%edx
  802100:	83 c4 1c             	add    $0x1c,%esp
  802103:	5b                   	pop    %ebx
  802104:	5e                   	pop    %esi
  802105:	5f                   	pop    %edi
  802106:	5d                   	pop    %ebp
  802107:	c3                   	ret    
  802108:	90                   	nop
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	89 d8                	mov    %ebx,%eax
  802112:	f7 f7                	div    %edi
  802114:	31 ff                	xor    %edi,%edi
  802116:	89 c3                	mov    %eax,%ebx
  802118:	89 d8                	mov    %ebx,%eax
  80211a:	89 fa                	mov    %edi,%edx
  80211c:	83 c4 1c             	add    $0x1c,%esp
  80211f:	5b                   	pop    %ebx
  802120:	5e                   	pop    %esi
  802121:	5f                   	pop    %edi
  802122:	5d                   	pop    %ebp
  802123:	c3                   	ret    
  802124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802128:	39 ce                	cmp    %ecx,%esi
  80212a:	72 0c                	jb     802138 <__udivdi3+0x118>
  80212c:	31 db                	xor    %ebx,%ebx
  80212e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802132:	0f 87 34 ff ff ff    	ja     80206c <__udivdi3+0x4c>
  802138:	bb 01 00 00 00       	mov    $0x1,%ebx
  80213d:	e9 2a ff ff ff       	jmp    80206c <__udivdi3+0x4c>
  802142:	66 90                	xchg   %ax,%ax
  802144:	66 90                	xchg   %ax,%ax
  802146:	66 90                	xchg   %ax,%ax
  802148:	66 90                	xchg   %ax,%ax
  80214a:	66 90                	xchg   %ax,%ax
  80214c:	66 90                	xchg   %ax,%ax
  80214e:	66 90                	xchg   %ax,%ax

00802150 <__umoddi3>:
  802150:	55                   	push   %ebp
  802151:	57                   	push   %edi
  802152:	56                   	push   %esi
  802153:	53                   	push   %ebx
  802154:	83 ec 1c             	sub    $0x1c,%esp
  802157:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80215b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80215f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802163:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802167:	85 d2                	test   %edx,%edx
  802169:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80216d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802171:	89 f3                	mov    %esi,%ebx
  802173:	89 3c 24             	mov    %edi,(%esp)
  802176:	89 74 24 04          	mov    %esi,0x4(%esp)
  80217a:	75 1c                	jne    802198 <__umoddi3+0x48>
  80217c:	39 f7                	cmp    %esi,%edi
  80217e:	76 50                	jbe    8021d0 <__umoddi3+0x80>
  802180:	89 c8                	mov    %ecx,%eax
  802182:	89 f2                	mov    %esi,%edx
  802184:	f7 f7                	div    %edi
  802186:	89 d0                	mov    %edx,%eax
  802188:	31 d2                	xor    %edx,%edx
  80218a:	83 c4 1c             	add    $0x1c,%esp
  80218d:	5b                   	pop    %ebx
  80218e:	5e                   	pop    %esi
  80218f:	5f                   	pop    %edi
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    
  802192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802198:	39 f2                	cmp    %esi,%edx
  80219a:	89 d0                	mov    %edx,%eax
  80219c:	77 52                	ja     8021f0 <__umoddi3+0xa0>
  80219e:	0f bd ea             	bsr    %edx,%ebp
  8021a1:	83 f5 1f             	xor    $0x1f,%ebp
  8021a4:	75 5a                	jne    802200 <__umoddi3+0xb0>
  8021a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021aa:	0f 82 e0 00 00 00    	jb     802290 <__umoddi3+0x140>
  8021b0:	39 0c 24             	cmp    %ecx,(%esp)
  8021b3:	0f 86 d7 00 00 00    	jbe    802290 <__umoddi3+0x140>
  8021b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021c1:	83 c4 1c             	add    $0x1c,%esp
  8021c4:	5b                   	pop    %ebx
  8021c5:	5e                   	pop    %esi
  8021c6:	5f                   	pop    %edi
  8021c7:	5d                   	pop    %ebp
  8021c8:	c3                   	ret    
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	85 ff                	test   %edi,%edi
  8021d2:	89 fd                	mov    %edi,%ebp
  8021d4:	75 0b                	jne    8021e1 <__umoddi3+0x91>
  8021d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021db:	31 d2                	xor    %edx,%edx
  8021dd:	f7 f7                	div    %edi
  8021df:	89 c5                	mov    %eax,%ebp
  8021e1:	89 f0                	mov    %esi,%eax
  8021e3:	31 d2                	xor    %edx,%edx
  8021e5:	f7 f5                	div    %ebp
  8021e7:	89 c8                	mov    %ecx,%eax
  8021e9:	f7 f5                	div    %ebp
  8021eb:	89 d0                	mov    %edx,%eax
  8021ed:	eb 99                	jmp    802188 <__umoddi3+0x38>
  8021ef:	90                   	nop
  8021f0:	89 c8                	mov    %ecx,%eax
  8021f2:	89 f2                	mov    %esi,%edx
  8021f4:	83 c4 1c             	add    $0x1c,%esp
  8021f7:	5b                   	pop    %ebx
  8021f8:	5e                   	pop    %esi
  8021f9:	5f                   	pop    %edi
  8021fa:	5d                   	pop    %ebp
  8021fb:	c3                   	ret    
  8021fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802200:	8b 34 24             	mov    (%esp),%esi
  802203:	bf 20 00 00 00       	mov    $0x20,%edi
  802208:	89 e9                	mov    %ebp,%ecx
  80220a:	29 ef                	sub    %ebp,%edi
  80220c:	d3 e0                	shl    %cl,%eax
  80220e:	89 f9                	mov    %edi,%ecx
  802210:	89 f2                	mov    %esi,%edx
  802212:	d3 ea                	shr    %cl,%edx
  802214:	89 e9                	mov    %ebp,%ecx
  802216:	09 c2                	or     %eax,%edx
  802218:	89 d8                	mov    %ebx,%eax
  80221a:	89 14 24             	mov    %edx,(%esp)
  80221d:	89 f2                	mov    %esi,%edx
  80221f:	d3 e2                	shl    %cl,%edx
  802221:	89 f9                	mov    %edi,%ecx
  802223:	89 54 24 04          	mov    %edx,0x4(%esp)
  802227:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80222b:	d3 e8                	shr    %cl,%eax
  80222d:	89 e9                	mov    %ebp,%ecx
  80222f:	89 c6                	mov    %eax,%esi
  802231:	d3 e3                	shl    %cl,%ebx
  802233:	89 f9                	mov    %edi,%ecx
  802235:	89 d0                	mov    %edx,%eax
  802237:	d3 e8                	shr    %cl,%eax
  802239:	89 e9                	mov    %ebp,%ecx
  80223b:	09 d8                	or     %ebx,%eax
  80223d:	89 d3                	mov    %edx,%ebx
  80223f:	89 f2                	mov    %esi,%edx
  802241:	f7 34 24             	divl   (%esp)
  802244:	89 d6                	mov    %edx,%esi
  802246:	d3 e3                	shl    %cl,%ebx
  802248:	f7 64 24 04          	mull   0x4(%esp)
  80224c:	39 d6                	cmp    %edx,%esi
  80224e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802252:	89 d1                	mov    %edx,%ecx
  802254:	89 c3                	mov    %eax,%ebx
  802256:	72 08                	jb     802260 <__umoddi3+0x110>
  802258:	75 11                	jne    80226b <__umoddi3+0x11b>
  80225a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80225e:	73 0b                	jae    80226b <__umoddi3+0x11b>
  802260:	2b 44 24 04          	sub    0x4(%esp),%eax
  802264:	1b 14 24             	sbb    (%esp),%edx
  802267:	89 d1                	mov    %edx,%ecx
  802269:	89 c3                	mov    %eax,%ebx
  80226b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80226f:	29 da                	sub    %ebx,%edx
  802271:	19 ce                	sbb    %ecx,%esi
  802273:	89 f9                	mov    %edi,%ecx
  802275:	89 f0                	mov    %esi,%eax
  802277:	d3 e0                	shl    %cl,%eax
  802279:	89 e9                	mov    %ebp,%ecx
  80227b:	d3 ea                	shr    %cl,%edx
  80227d:	89 e9                	mov    %ebp,%ecx
  80227f:	d3 ee                	shr    %cl,%esi
  802281:	09 d0                	or     %edx,%eax
  802283:	89 f2                	mov    %esi,%edx
  802285:	83 c4 1c             	add    $0x1c,%esp
  802288:	5b                   	pop    %ebx
  802289:	5e                   	pop    %esi
  80228a:	5f                   	pop    %edi
  80228b:	5d                   	pop    %ebp
  80228c:	c3                   	ret    
  80228d:	8d 76 00             	lea    0x0(%esi),%esi
  802290:	29 f9                	sub    %edi,%ecx
  802292:	19 d6                	sbb    %edx,%esi
  802294:	89 74 24 04          	mov    %esi,0x4(%esp)
  802298:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80229c:	e9 18 ff ff ff       	jmp    8021b9 <__umoddi3+0x69>
