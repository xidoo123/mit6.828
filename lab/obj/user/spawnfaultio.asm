
obj/user/spawnfaultio.debug:     file format elf32-i386


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
  80002c:	e8 4a 00 00 00       	call   80007b <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  800039:	a1 08 40 80 00       	mov    0x804008,%eax
  80003e:	8b 40 48             	mov    0x48(%eax),%eax
  800041:	50                   	push   %eax
  800042:	68 e0 28 80 00       	push   $0x8028e0
  800047:	e8 68 01 00 00       	call   8001b4 <cprintf>
	if ((r = spawnl("faultio", "faultio", 0)) < 0)
  80004c:	83 c4 0c             	add    $0xc,%esp
  80004f:	6a 00                	push   $0x0
  800051:	68 fe 28 80 00       	push   $0x8028fe
  800056:	68 fe 28 80 00       	push   $0x8028fe
  80005b:	e8 eb 1a 00 00       	call   801b4b <spawnl>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	85 c0                	test   %eax,%eax
  800065:	79 12                	jns    800079 <umain+0x46>
		panic("spawn(faultio) failed: %e", r);
  800067:	50                   	push   %eax
  800068:	68 06 29 80 00       	push   $0x802906
  80006d:	6a 09                	push   $0x9
  80006f:	68 20 29 80 00       	push   $0x802920
  800074:	e8 62 00 00 00       	call   8000db <_panic>
}
  800079:	c9                   	leave  
  80007a:	c3                   	ret    

0080007b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80007b:	55                   	push   %ebp
  80007c:	89 e5                	mov    %esp,%ebp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800083:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800086:	e8 73 0a 00 00       	call   800afe <sys_getenvid>
  80008b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800090:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800093:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800098:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009d:	85 db                	test   %ebx,%ebx
  80009f:	7e 07                	jle    8000a8 <libmain+0x2d>
		binaryname = argv[0];
  8000a1:	8b 06                	mov    (%esi),%eax
  8000a3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 81 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b2:	e8 0a 00 00 00       	call   8000c1 <exit>
}
  8000b7:	83 c4 10             	add    $0x10,%esp
  8000ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	5d                   	pop    %ebp
  8000c0:	c3                   	ret    

008000c1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000c7:	e8 cf 0e 00 00       	call   800f9b <close_all>
	sys_env_destroy(0);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	6a 00                	push   $0x0
  8000d1:	e8 e7 09 00 00       	call   800abd <sys_env_destroy>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	c9                   	leave  
  8000da:	c3                   	ret    

008000db <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8000e0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8000e3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8000e9:	e8 10 0a 00 00       	call   800afe <sys_getenvid>
  8000ee:	83 ec 0c             	sub    $0xc,%esp
  8000f1:	ff 75 0c             	pushl  0xc(%ebp)
  8000f4:	ff 75 08             	pushl  0x8(%ebp)
  8000f7:	56                   	push   %esi
  8000f8:	50                   	push   %eax
  8000f9:	68 40 29 80 00       	push   $0x802940
  8000fe:	e8 b1 00 00 00       	call   8001b4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800103:	83 c4 18             	add    $0x18,%esp
  800106:	53                   	push   %ebx
  800107:	ff 75 10             	pushl  0x10(%ebp)
  80010a:	e8 54 00 00 00       	call   800163 <vcprintf>
	cprintf("\n");
  80010f:	c7 04 24 55 2e 80 00 	movl   $0x802e55,(%esp)
  800116:	e8 99 00 00 00       	call   8001b4 <cprintf>
  80011b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80011e:	cc                   	int3   
  80011f:	eb fd                	jmp    80011e <_panic+0x43>

00800121 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	53                   	push   %ebx
  800125:	83 ec 04             	sub    $0x4,%esp
  800128:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012b:	8b 13                	mov    (%ebx),%edx
  80012d:	8d 42 01             	lea    0x1(%edx),%eax
  800130:	89 03                	mov    %eax,(%ebx)
  800132:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800135:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800139:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013e:	75 1a                	jne    80015a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800140:	83 ec 08             	sub    $0x8,%esp
  800143:	68 ff 00 00 00       	push   $0xff
  800148:	8d 43 08             	lea    0x8(%ebx),%eax
  80014b:	50                   	push   %eax
  80014c:	e8 2f 09 00 00       	call   800a80 <sys_cputs>
		b->idx = 0;
  800151:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800157:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80015a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800161:	c9                   	leave  
  800162:	c3                   	ret    

00800163 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800173:	00 00 00 
	b.cnt = 0;
  800176:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800180:	ff 75 0c             	pushl  0xc(%ebp)
  800183:	ff 75 08             	pushl  0x8(%ebp)
  800186:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018c:	50                   	push   %eax
  80018d:	68 21 01 80 00       	push   $0x800121
  800192:	e8 54 01 00 00       	call   8002eb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800197:	83 c4 08             	add    $0x8,%esp
  80019a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a6:	50                   	push   %eax
  8001a7:	e8 d4 08 00 00       	call   800a80 <sys_cputs>

	return b.cnt;
}
  8001ac:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ba:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001bd:	50                   	push   %eax
  8001be:	ff 75 08             	pushl  0x8(%ebp)
  8001c1:	e8 9d ff ff ff       	call   800163 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    

008001c8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	57                   	push   %edi
  8001cc:	56                   	push   %esi
  8001cd:	53                   	push   %ebx
  8001ce:	83 ec 1c             	sub    $0x1c,%esp
  8001d1:	89 c7                	mov    %eax,%edi
  8001d3:	89 d6                	mov    %edx,%esi
  8001d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001de:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ec:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ef:	39 d3                	cmp    %edx,%ebx
  8001f1:	72 05                	jb     8001f8 <printnum+0x30>
  8001f3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f6:	77 45                	ja     80023d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f8:	83 ec 0c             	sub    $0xc,%esp
  8001fb:	ff 75 18             	pushl  0x18(%ebp)
  8001fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800201:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800204:	53                   	push   %ebx
  800205:	ff 75 10             	pushl  0x10(%ebp)
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020e:	ff 75 e0             	pushl  -0x20(%ebp)
  800211:	ff 75 dc             	pushl  -0x24(%ebp)
  800214:	ff 75 d8             	pushl  -0x28(%ebp)
  800217:	e8 24 24 00 00       	call   802640 <__udivdi3>
  80021c:	83 c4 18             	add    $0x18,%esp
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	89 f2                	mov    %esi,%edx
  800223:	89 f8                	mov    %edi,%eax
  800225:	e8 9e ff ff ff       	call   8001c8 <printnum>
  80022a:	83 c4 20             	add    $0x20,%esp
  80022d:	eb 18                	jmp    800247 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022f:	83 ec 08             	sub    $0x8,%esp
  800232:	56                   	push   %esi
  800233:	ff 75 18             	pushl  0x18(%ebp)
  800236:	ff d7                	call   *%edi
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	eb 03                	jmp    800240 <printnum+0x78>
  80023d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800240:	83 eb 01             	sub    $0x1,%ebx
  800243:	85 db                	test   %ebx,%ebx
  800245:	7f e8                	jg     80022f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800247:	83 ec 08             	sub    $0x8,%esp
  80024a:	56                   	push   %esi
  80024b:	83 ec 04             	sub    $0x4,%esp
  80024e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800251:	ff 75 e0             	pushl  -0x20(%ebp)
  800254:	ff 75 dc             	pushl  -0x24(%ebp)
  800257:	ff 75 d8             	pushl  -0x28(%ebp)
  80025a:	e8 11 25 00 00       	call   802770 <__umoddi3>
  80025f:	83 c4 14             	add    $0x14,%esp
  800262:	0f be 80 63 29 80 00 	movsbl 0x802963(%eax),%eax
  800269:	50                   	push   %eax
  80026a:	ff d7                	call   *%edi
}
  80026c:	83 c4 10             	add    $0x10,%esp
  80026f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800272:	5b                   	pop    %ebx
  800273:	5e                   	pop    %esi
  800274:	5f                   	pop    %edi
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80027a:	83 fa 01             	cmp    $0x1,%edx
  80027d:	7e 0e                	jle    80028d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027f:	8b 10                	mov    (%eax),%edx
  800281:	8d 4a 08             	lea    0x8(%edx),%ecx
  800284:	89 08                	mov    %ecx,(%eax)
  800286:	8b 02                	mov    (%edx),%eax
  800288:	8b 52 04             	mov    0x4(%edx),%edx
  80028b:	eb 22                	jmp    8002af <getuint+0x38>
	else if (lflag)
  80028d:	85 d2                	test   %edx,%edx
  80028f:	74 10                	je     8002a1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800291:	8b 10                	mov    (%eax),%edx
  800293:	8d 4a 04             	lea    0x4(%edx),%ecx
  800296:	89 08                	mov    %ecx,(%eax)
  800298:	8b 02                	mov    (%edx),%eax
  80029a:	ba 00 00 00 00       	mov    $0x0,%edx
  80029f:	eb 0e                	jmp    8002af <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a1:	8b 10                	mov    (%eax),%edx
  8002a3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a6:	89 08                	mov    %ecx,(%eax)
  8002a8:	8b 02                	mov    (%edx),%eax
  8002aa:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002bb:	8b 10                	mov    (%eax),%edx
  8002bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c0:	73 0a                	jae    8002cc <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ca:	88 02                	mov    %al,(%edx)
}
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d7:	50                   	push   %eax
  8002d8:	ff 75 10             	pushl  0x10(%ebp)
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	e8 05 00 00 00       	call   8002eb <vprintfmt>
	va_end(ap);
}
  8002e6:	83 c4 10             	add    $0x10,%esp
  8002e9:	c9                   	leave  
  8002ea:	c3                   	ret    

008002eb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
  8002f1:	83 ec 2c             	sub    $0x2c,%esp
  8002f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fa:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002fd:	eb 12                	jmp    800311 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ff:	85 c0                	test   %eax,%eax
  800301:	0f 84 89 03 00 00    	je     800690 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	53                   	push   %ebx
  80030b:	50                   	push   %eax
  80030c:	ff d6                	call   *%esi
  80030e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800311:	83 c7 01             	add    $0x1,%edi
  800314:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800318:	83 f8 25             	cmp    $0x25,%eax
  80031b:	75 e2                	jne    8002ff <vprintfmt+0x14>
  80031d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800321:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800328:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80032f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800336:	ba 00 00 00 00       	mov    $0x0,%edx
  80033b:	eb 07                	jmp    800344 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800340:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800344:	8d 47 01             	lea    0x1(%edi),%eax
  800347:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034a:	0f b6 07             	movzbl (%edi),%eax
  80034d:	0f b6 c8             	movzbl %al,%ecx
  800350:	83 e8 23             	sub    $0x23,%eax
  800353:	3c 55                	cmp    $0x55,%al
  800355:	0f 87 1a 03 00 00    	ja     800675 <vprintfmt+0x38a>
  80035b:	0f b6 c0             	movzbl %al,%eax
  80035e:	ff 24 85 a0 2a 80 00 	jmp    *0x802aa0(,%eax,4)
  800365:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800368:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80036c:	eb d6                	jmp    800344 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800371:	b8 00 00 00 00       	mov    $0x0,%eax
  800376:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800379:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80037c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800380:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800383:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800386:	83 fa 09             	cmp    $0x9,%edx
  800389:	77 39                	ja     8003c4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80038e:	eb e9                	jmp    800379 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800390:	8b 45 14             	mov    0x14(%ebp),%eax
  800393:	8d 48 04             	lea    0x4(%eax),%ecx
  800396:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800399:	8b 00                	mov    (%eax),%eax
  80039b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a1:	eb 27                	jmp    8003ca <vprintfmt+0xdf>
  8003a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a6:	85 c0                	test   %eax,%eax
  8003a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ad:	0f 49 c8             	cmovns %eax,%ecx
  8003b0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b6:	eb 8c                	jmp    800344 <vprintfmt+0x59>
  8003b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003bb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c2:	eb 80                	jmp    800344 <vprintfmt+0x59>
  8003c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003c7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003ca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ce:	0f 89 70 ff ff ff    	jns    800344 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003d4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003da:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e1:	e9 5e ff ff ff       	jmp    800344 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ec:	e9 53 ff ff ff       	jmp    800344 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	8d 50 04             	lea    0x4(%eax),%edx
  8003f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fa:	83 ec 08             	sub    $0x8,%esp
  8003fd:	53                   	push   %ebx
  8003fe:	ff 30                	pushl  (%eax)
  800400:	ff d6                	call   *%esi
			break;
  800402:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800408:	e9 04 ff ff ff       	jmp    800311 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	8d 50 04             	lea    0x4(%eax),%edx
  800413:	89 55 14             	mov    %edx,0x14(%ebp)
  800416:	8b 00                	mov    (%eax),%eax
  800418:	99                   	cltd   
  800419:	31 d0                	xor    %edx,%eax
  80041b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041d:	83 f8 0f             	cmp    $0xf,%eax
  800420:	7f 0b                	jg     80042d <vprintfmt+0x142>
  800422:	8b 14 85 00 2c 80 00 	mov    0x802c00(,%eax,4),%edx
  800429:	85 d2                	test   %edx,%edx
  80042b:	75 18                	jne    800445 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80042d:	50                   	push   %eax
  80042e:	68 7b 29 80 00       	push   $0x80297b
  800433:	53                   	push   %ebx
  800434:	56                   	push   %esi
  800435:	e8 94 fe ff ff       	call   8002ce <printfmt>
  80043a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800440:	e9 cc fe ff ff       	jmp    800311 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800445:	52                   	push   %edx
  800446:	68 35 2d 80 00       	push   $0x802d35
  80044b:	53                   	push   %ebx
  80044c:	56                   	push   %esi
  80044d:	e8 7c fe ff ff       	call   8002ce <printfmt>
  800452:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800455:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800458:	e9 b4 fe ff ff       	jmp    800311 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80045d:	8b 45 14             	mov    0x14(%ebp),%eax
  800460:	8d 50 04             	lea    0x4(%eax),%edx
  800463:	89 55 14             	mov    %edx,0x14(%ebp)
  800466:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800468:	85 ff                	test   %edi,%edi
  80046a:	b8 74 29 80 00       	mov    $0x802974,%eax
  80046f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800472:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800476:	0f 8e 94 00 00 00    	jle    800510 <vprintfmt+0x225>
  80047c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800480:	0f 84 98 00 00 00    	je     80051e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800486:	83 ec 08             	sub    $0x8,%esp
  800489:	ff 75 d0             	pushl  -0x30(%ebp)
  80048c:	57                   	push   %edi
  80048d:	e8 86 02 00 00       	call   800718 <strnlen>
  800492:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800495:	29 c1                	sub    %eax,%ecx
  800497:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80049a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80049d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a9:	eb 0f                	jmp    8004ba <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004ab:	83 ec 08             	sub    $0x8,%esp
  8004ae:	53                   	push   %ebx
  8004af:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b4:	83 ef 01             	sub    $0x1,%edi
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	85 ff                	test   %edi,%edi
  8004bc:	7f ed                	jg     8004ab <vprintfmt+0x1c0>
  8004be:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004c4:	85 c9                	test   %ecx,%ecx
  8004c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cb:	0f 49 c1             	cmovns %ecx,%eax
  8004ce:	29 c1                	sub    %eax,%ecx
  8004d0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d9:	89 cb                	mov    %ecx,%ebx
  8004db:	eb 4d                	jmp    80052a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004dd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e1:	74 1b                	je     8004fe <vprintfmt+0x213>
  8004e3:	0f be c0             	movsbl %al,%eax
  8004e6:	83 e8 20             	sub    $0x20,%eax
  8004e9:	83 f8 5e             	cmp    $0x5e,%eax
  8004ec:	76 10                	jbe    8004fe <vprintfmt+0x213>
					putch('?', putdat);
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	ff 75 0c             	pushl  0xc(%ebp)
  8004f4:	6a 3f                	push   $0x3f
  8004f6:	ff 55 08             	call   *0x8(%ebp)
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	eb 0d                	jmp    80050b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	ff 75 0c             	pushl  0xc(%ebp)
  800504:	52                   	push   %edx
  800505:	ff 55 08             	call   *0x8(%ebp)
  800508:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050b:	83 eb 01             	sub    $0x1,%ebx
  80050e:	eb 1a                	jmp    80052a <vprintfmt+0x23f>
  800510:	89 75 08             	mov    %esi,0x8(%ebp)
  800513:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800516:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800519:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051c:	eb 0c                	jmp    80052a <vprintfmt+0x23f>
  80051e:	89 75 08             	mov    %esi,0x8(%ebp)
  800521:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800524:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800527:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80052a:	83 c7 01             	add    $0x1,%edi
  80052d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800531:	0f be d0             	movsbl %al,%edx
  800534:	85 d2                	test   %edx,%edx
  800536:	74 23                	je     80055b <vprintfmt+0x270>
  800538:	85 f6                	test   %esi,%esi
  80053a:	78 a1                	js     8004dd <vprintfmt+0x1f2>
  80053c:	83 ee 01             	sub    $0x1,%esi
  80053f:	79 9c                	jns    8004dd <vprintfmt+0x1f2>
  800541:	89 df                	mov    %ebx,%edi
  800543:	8b 75 08             	mov    0x8(%ebp),%esi
  800546:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800549:	eb 18                	jmp    800563 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	53                   	push   %ebx
  80054f:	6a 20                	push   $0x20
  800551:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800553:	83 ef 01             	sub    $0x1,%edi
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	eb 08                	jmp    800563 <vprintfmt+0x278>
  80055b:	89 df                	mov    %ebx,%edi
  80055d:	8b 75 08             	mov    0x8(%ebp),%esi
  800560:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800563:	85 ff                	test   %edi,%edi
  800565:	7f e4                	jg     80054b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800567:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056a:	e9 a2 fd ff ff       	jmp    800311 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056f:	83 fa 01             	cmp    $0x1,%edx
  800572:	7e 16                	jle    80058a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 50 08             	lea    0x8(%eax),%edx
  80057a:	89 55 14             	mov    %edx,0x14(%ebp)
  80057d:	8b 50 04             	mov    0x4(%eax),%edx
  800580:	8b 00                	mov    (%eax),%eax
  800582:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800585:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800588:	eb 32                	jmp    8005bc <vprintfmt+0x2d1>
	else if (lflag)
  80058a:	85 d2                	test   %edx,%edx
  80058c:	74 18                	je     8005a6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8d 50 04             	lea    0x4(%eax),%edx
  800594:	89 55 14             	mov    %edx,0x14(%ebp)
  800597:	8b 00                	mov    (%eax),%eax
  800599:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059c:	89 c1                	mov    %eax,%ecx
  80059e:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a4:	eb 16                	jmp    8005bc <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8005af:	8b 00                	mov    (%eax),%eax
  8005b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b4:	89 c1                	mov    %eax,%ecx
  8005b6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005bf:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005cb:	79 74                	jns    800641 <vprintfmt+0x356>
				putch('-', putdat);
  8005cd:	83 ec 08             	sub    $0x8,%esp
  8005d0:	53                   	push   %ebx
  8005d1:	6a 2d                	push   $0x2d
  8005d3:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005db:	f7 d8                	neg    %eax
  8005dd:	83 d2 00             	adc    $0x0,%edx
  8005e0:	f7 da                	neg    %edx
  8005e2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005e5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005ea:	eb 55                	jmp    800641 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ef:	e8 83 fc ff ff       	call   800277 <getuint>
			base = 10;
  8005f4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005f9:	eb 46                	jmp    800641 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8005fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fe:	e8 74 fc ff ff       	call   800277 <getuint>
			base = 8;
  800603:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800608:	eb 37                	jmp    800641 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80060a:	83 ec 08             	sub    $0x8,%esp
  80060d:	53                   	push   %ebx
  80060e:	6a 30                	push   $0x30
  800610:	ff d6                	call   *%esi
			putch('x', putdat);
  800612:	83 c4 08             	add    $0x8,%esp
  800615:	53                   	push   %ebx
  800616:	6a 78                	push   $0x78
  800618:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8d 50 04             	lea    0x4(%eax),%edx
  800620:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800623:	8b 00                	mov    (%eax),%eax
  800625:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80062a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80062d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800632:	eb 0d                	jmp    800641 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800634:	8d 45 14             	lea    0x14(%ebp),%eax
  800637:	e8 3b fc ff ff       	call   800277 <getuint>
			base = 16;
  80063c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800641:	83 ec 0c             	sub    $0xc,%esp
  800644:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800648:	57                   	push   %edi
  800649:	ff 75 e0             	pushl  -0x20(%ebp)
  80064c:	51                   	push   %ecx
  80064d:	52                   	push   %edx
  80064e:	50                   	push   %eax
  80064f:	89 da                	mov    %ebx,%edx
  800651:	89 f0                	mov    %esi,%eax
  800653:	e8 70 fb ff ff       	call   8001c8 <printnum>
			break;
  800658:	83 c4 20             	add    $0x20,%esp
  80065b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065e:	e9 ae fc ff ff       	jmp    800311 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800663:	83 ec 08             	sub    $0x8,%esp
  800666:	53                   	push   %ebx
  800667:	51                   	push   %ecx
  800668:	ff d6                	call   *%esi
			break;
  80066a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800670:	e9 9c fc ff ff       	jmp    800311 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800675:	83 ec 08             	sub    $0x8,%esp
  800678:	53                   	push   %ebx
  800679:	6a 25                	push   $0x25
  80067b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80067d:	83 c4 10             	add    $0x10,%esp
  800680:	eb 03                	jmp    800685 <vprintfmt+0x39a>
  800682:	83 ef 01             	sub    $0x1,%edi
  800685:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800689:	75 f7                	jne    800682 <vprintfmt+0x397>
  80068b:	e9 81 fc ff ff       	jmp    800311 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800690:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800693:	5b                   	pop    %ebx
  800694:	5e                   	pop    %esi
  800695:	5f                   	pop    %edi
  800696:	5d                   	pop    %ebp
  800697:	c3                   	ret    

00800698 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800698:	55                   	push   %ebp
  800699:	89 e5                	mov    %esp,%ebp
  80069b:	83 ec 18             	sub    $0x18,%esp
  80069e:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ab:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b5:	85 c0                	test   %eax,%eax
  8006b7:	74 26                	je     8006df <vsnprintf+0x47>
  8006b9:	85 d2                	test   %edx,%edx
  8006bb:	7e 22                	jle    8006df <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006bd:	ff 75 14             	pushl  0x14(%ebp)
  8006c0:	ff 75 10             	pushl  0x10(%ebp)
  8006c3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c6:	50                   	push   %eax
  8006c7:	68 b1 02 80 00       	push   $0x8002b1
  8006cc:	e8 1a fc ff ff       	call   8002eb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006da:	83 c4 10             	add    $0x10,%esp
  8006dd:	eb 05                	jmp    8006e4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e4:	c9                   	leave  
  8006e5:	c3                   	ret    

008006e6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e6:	55                   	push   %ebp
  8006e7:	89 e5                	mov    %esp,%ebp
  8006e9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ec:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ef:	50                   	push   %eax
  8006f0:	ff 75 10             	pushl  0x10(%ebp)
  8006f3:	ff 75 0c             	pushl  0xc(%ebp)
  8006f6:	ff 75 08             	pushl  0x8(%ebp)
  8006f9:	e8 9a ff ff ff       	call   800698 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006fe:	c9                   	leave  
  8006ff:	c3                   	ret    

00800700 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800706:	b8 00 00 00 00       	mov    $0x0,%eax
  80070b:	eb 03                	jmp    800710 <strlen+0x10>
		n++;
  80070d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800710:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800714:	75 f7                	jne    80070d <strlen+0xd>
		n++;
	return n;
}
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80071e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800721:	ba 00 00 00 00       	mov    $0x0,%edx
  800726:	eb 03                	jmp    80072b <strnlen+0x13>
		n++;
  800728:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072b:	39 c2                	cmp    %eax,%edx
  80072d:	74 08                	je     800737 <strnlen+0x1f>
  80072f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800733:	75 f3                	jne    800728 <strnlen+0x10>
  800735:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800737:	5d                   	pop    %ebp
  800738:	c3                   	ret    

00800739 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800739:	55                   	push   %ebp
  80073a:	89 e5                	mov    %esp,%ebp
  80073c:	53                   	push   %ebx
  80073d:	8b 45 08             	mov    0x8(%ebp),%eax
  800740:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800743:	89 c2                	mov    %eax,%edx
  800745:	83 c2 01             	add    $0x1,%edx
  800748:	83 c1 01             	add    $0x1,%ecx
  80074b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80074f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800752:	84 db                	test   %bl,%bl
  800754:	75 ef                	jne    800745 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800756:	5b                   	pop    %ebx
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	53                   	push   %ebx
  80075d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800760:	53                   	push   %ebx
  800761:	e8 9a ff ff ff       	call   800700 <strlen>
  800766:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800769:	ff 75 0c             	pushl  0xc(%ebp)
  80076c:	01 d8                	add    %ebx,%eax
  80076e:	50                   	push   %eax
  80076f:	e8 c5 ff ff ff       	call   800739 <strcpy>
	return dst;
}
  800774:	89 d8                	mov    %ebx,%eax
  800776:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800779:	c9                   	leave  
  80077a:	c3                   	ret    

0080077b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	56                   	push   %esi
  80077f:	53                   	push   %ebx
  800780:	8b 75 08             	mov    0x8(%ebp),%esi
  800783:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800786:	89 f3                	mov    %esi,%ebx
  800788:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078b:	89 f2                	mov    %esi,%edx
  80078d:	eb 0f                	jmp    80079e <strncpy+0x23>
		*dst++ = *src;
  80078f:	83 c2 01             	add    $0x1,%edx
  800792:	0f b6 01             	movzbl (%ecx),%eax
  800795:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800798:	80 39 01             	cmpb   $0x1,(%ecx)
  80079b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079e:	39 da                	cmp    %ebx,%edx
  8007a0:	75 ed                	jne    80078f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a2:	89 f0                	mov    %esi,%eax
  8007a4:	5b                   	pop    %ebx
  8007a5:	5e                   	pop    %esi
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	56                   	push   %esi
  8007ac:	53                   	push   %ebx
  8007ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b3:	8b 55 10             	mov    0x10(%ebp),%edx
  8007b6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b8:	85 d2                	test   %edx,%edx
  8007ba:	74 21                	je     8007dd <strlcpy+0x35>
  8007bc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007c0:	89 f2                	mov    %esi,%edx
  8007c2:	eb 09                	jmp    8007cd <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c4:	83 c2 01             	add    $0x1,%edx
  8007c7:	83 c1 01             	add    $0x1,%ecx
  8007ca:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007cd:	39 c2                	cmp    %eax,%edx
  8007cf:	74 09                	je     8007da <strlcpy+0x32>
  8007d1:	0f b6 19             	movzbl (%ecx),%ebx
  8007d4:	84 db                	test   %bl,%bl
  8007d6:	75 ec                	jne    8007c4 <strlcpy+0x1c>
  8007d8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007da:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007dd:	29 f0                	sub    %esi,%eax
}
  8007df:	5b                   	pop    %ebx
  8007e0:	5e                   	pop    %esi
  8007e1:	5d                   	pop    %ebp
  8007e2:	c3                   	ret    

008007e3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ec:	eb 06                	jmp    8007f4 <strcmp+0x11>
		p++, q++;
  8007ee:	83 c1 01             	add    $0x1,%ecx
  8007f1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f4:	0f b6 01             	movzbl (%ecx),%eax
  8007f7:	84 c0                	test   %al,%al
  8007f9:	74 04                	je     8007ff <strcmp+0x1c>
  8007fb:	3a 02                	cmp    (%edx),%al
  8007fd:	74 ef                	je     8007ee <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ff:	0f b6 c0             	movzbl %al,%eax
  800802:	0f b6 12             	movzbl (%edx),%edx
  800805:	29 d0                	sub    %edx,%eax
}
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	53                   	push   %ebx
  80080d:	8b 45 08             	mov    0x8(%ebp),%eax
  800810:	8b 55 0c             	mov    0xc(%ebp),%edx
  800813:	89 c3                	mov    %eax,%ebx
  800815:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800818:	eb 06                	jmp    800820 <strncmp+0x17>
		n--, p++, q++;
  80081a:	83 c0 01             	add    $0x1,%eax
  80081d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800820:	39 d8                	cmp    %ebx,%eax
  800822:	74 15                	je     800839 <strncmp+0x30>
  800824:	0f b6 08             	movzbl (%eax),%ecx
  800827:	84 c9                	test   %cl,%cl
  800829:	74 04                	je     80082f <strncmp+0x26>
  80082b:	3a 0a                	cmp    (%edx),%cl
  80082d:	74 eb                	je     80081a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082f:	0f b6 00             	movzbl (%eax),%eax
  800832:	0f b6 12             	movzbl (%edx),%edx
  800835:	29 d0                	sub    %edx,%eax
  800837:	eb 05                	jmp    80083e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800839:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80083e:	5b                   	pop    %ebx
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084b:	eb 07                	jmp    800854 <strchr+0x13>
		if (*s == c)
  80084d:	38 ca                	cmp    %cl,%dl
  80084f:	74 0f                	je     800860 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800851:	83 c0 01             	add    $0x1,%eax
  800854:	0f b6 10             	movzbl (%eax),%edx
  800857:	84 d2                	test   %dl,%dl
  800859:	75 f2                	jne    80084d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80085b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	8b 45 08             	mov    0x8(%ebp),%eax
  800868:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086c:	eb 03                	jmp    800871 <strfind+0xf>
  80086e:	83 c0 01             	add    $0x1,%eax
  800871:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800874:	38 ca                	cmp    %cl,%dl
  800876:	74 04                	je     80087c <strfind+0x1a>
  800878:	84 d2                	test   %dl,%dl
  80087a:	75 f2                	jne    80086e <strfind+0xc>
			break;
	return (char *) s;
}
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	57                   	push   %edi
  800882:	56                   	push   %esi
  800883:	53                   	push   %ebx
  800884:	8b 7d 08             	mov    0x8(%ebp),%edi
  800887:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80088a:	85 c9                	test   %ecx,%ecx
  80088c:	74 36                	je     8008c4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80088e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800894:	75 28                	jne    8008be <memset+0x40>
  800896:	f6 c1 03             	test   $0x3,%cl
  800899:	75 23                	jne    8008be <memset+0x40>
		c &= 0xFF;
  80089b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80089f:	89 d3                	mov    %edx,%ebx
  8008a1:	c1 e3 08             	shl    $0x8,%ebx
  8008a4:	89 d6                	mov    %edx,%esi
  8008a6:	c1 e6 18             	shl    $0x18,%esi
  8008a9:	89 d0                	mov    %edx,%eax
  8008ab:	c1 e0 10             	shl    $0x10,%eax
  8008ae:	09 f0                	or     %esi,%eax
  8008b0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008b2:	89 d8                	mov    %ebx,%eax
  8008b4:	09 d0                	or     %edx,%eax
  8008b6:	c1 e9 02             	shr    $0x2,%ecx
  8008b9:	fc                   	cld    
  8008ba:	f3 ab                	rep stos %eax,%es:(%edi)
  8008bc:	eb 06                	jmp    8008c4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c1:	fc                   	cld    
  8008c2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c4:	89 f8                	mov    %edi,%eax
  8008c6:	5b                   	pop    %ebx
  8008c7:	5e                   	pop    %esi
  8008c8:	5f                   	pop    %edi
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	57                   	push   %edi
  8008cf:	56                   	push   %esi
  8008d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d9:	39 c6                	cmp    %eax,%esi
  8008db:	73 35                	jae    800912 <memmove+0x47>
  8008dd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e0:	39 d0                	cmp    %edx,%eax
  8008e2:	73 2e                	jae    800912 <memmove+0x47>
		s += n;
		d += n;
  8008e4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e7:	89 d6                	mov    %edx,%esi
  8008e9:	09 fe                	or     %edi,%esi
  8008eb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008f1:	75 13                	jne    800906 <memmove+0x3b>
  8008f3:	f6 c1 03             	test   $0x3,%cl
  8008f6:	75 0e                	jne    800906 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008f8:	83 ef 04             	sub    $0x4,%edi
  8008fb:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008fe:	c1 e9 02             	shr    $0x2,%ecx
  800901:	fd                   	std    
  800902:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800904:	eb 09                	jmp    80090f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800906:	83 ef 01             	sub    $0x1,%edi
  800909:	8d 72 ff             	lea    -0x1(%edx),%esi
  80090c:	fd                   	std    
  80090d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80090f:	fc                   	cld    
  800910:	eb 1d                	jmp    80092f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800912:	89 f2                	mov    %esi,%edx
  800914:	09 c2                	or     %eax,%edx
  800916:	f6 c2 03             	test   $0x3,%dl
  800919:	75 0f                	jne    80092a <memmove+0x5f>
  80091b:	f6 c1 03             	test   $0x3,%cl
  80091e:	75 0a                	jne    80092a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800920:	c1 e9 02             	shr    $0x2,%ecx
  800923:	89 c7                	mov    %eax,%edi
  800925:	fc                   	cld    
  800926:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800928:	eb 05                	jmp    80092f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80092a:	89 c7                	mov    %eax,%edi
  80092c:	fc                   	cld    
  80092d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80092f:	5e                   	pop    %esi
  800930:	5f                   	pop    %edi
  800931:	5d                   	pop    %ebp
  800932:	c3                   	ret    

00800933 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800936:	ff 75 10             	pushl  0x10(%ebp)
  800939:	ff 75 0c             	pushl  0xc(%ebp)
  80093c:	ff 75 08             	pushl  0x8(%ebp)
  80093f:	e8 87 ff ff ff       	call   8008cb <memmove>
}
  800944:	c9                   	leave  
  800945:	c3                   	ret    

00800946 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	56                   	push   %esi
  80094a:	53                   	push   %ebx
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800951:	89 c6                	mov    %eax,%esi
  800953:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800956:	eb 1a                	jmp    800972 <memcmp+0x2c>
		if (*s1 != *s2)
  800958:	0f b6 08             	movzbl (%eax),%ecx
  80095b:	0f b6 1a             	movzbl (%edx),%ebx
  80095e:	38 d9                	cmp    %bl,%cl
  800960:	74 0a                	je     80096c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800962:	0f b6 c1             	movzbl %cl,%eax
  800965:	0f b6 db             	movzbl %bl,%ebx
  800968:	29 d8                	sub    %ebx,%eax
  80096a:	eb 0f                	jmp    80097b <memcmp+0x35>
		s1++, s2++;
  80096c:	83 c0 01             	add    $0x1,%eax
  80096f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800972:	39 f0                	cmp    %esi,%eax
  800974:	75 e2                	jne    800958 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800976:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097b:	5b                   	pop    %ebx
  80097c:	5e                   	pop    %esi
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	53                   	push   %ebx
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800986:	89 c1                	mov    %eax,%ecx
  800988:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80098b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80098f:	eb 0a                	jmp    80099b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800991:	0f b6 10             	movzbl (%eax),%edx
  800994:	39 da                	cmp    %ebx,%edx
  800996:	74 07                	je     80099f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800998:	83 c0 01             	add    $0x1,%eax
  80099b:	39 c8                	cmp    %ecx,%eax
  80099d:	72 f2                	jb     800991 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80099f:	5b                   	pop    %ebx
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	57                   	push   %edi
  8009a6:	56                   	push   %esi
  8009a7:	53                   	push   %ebx
  8009a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ae:	eb 03                	jmp    8009b3 <strtol+0x11>
		s++;
  8009b0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b3:	0f b6 01             	movzbl (%ecx),%eax
  8009b6:	3c 20                	cmp    $0x20,%al
  8009b8:	74 f6                	je     8009b0 <strtol+0xe>
  8009ba:	3c 09                	cmp    $0x9,%al
  8009bc:	74 f2                	je     8009b0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009be:	3c 2b                	cmp    $0x2b,%al
  8009c0:	75 0a                	jne    8009cc <strtol+0x2a>
		s++;
  8009c2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c5:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ca:	eb 11                	jmp    8009dd <strtol+0x3b>
  8009cc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009d1:	3c 2d                	cmp    $0x2d,%al
  8009d3:	75 08                	jne    8009dd <strtol+0x3b>
		s++, neg = 1;
  8009d5:	83 c1 01             	add    $0x1,%ecx
  8009d8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009dd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e3:	75 15                	jne    8009fa <strtol+0x58>
  8009e5:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e8:	75 10                	jne    8009fa <strtol+0x58>
  8009ea:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ee:	75 7c                	jne    800a6c <strtol+0xca>
		s += 2, base = 16;
  8009f0:	83 c1 02             	add    $0x2,%ecx
  8009f3:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f8:	eb 16                	jmp    800a10 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009fa:	85 db                	test   %ebx,%ebx
  8009fc:	75 12                	jne    800a10 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009fe:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a03:	80 39 30             	cmpb   $0x30,(%ecx)
  800a06:	75 08                	jne    800a10 <strtol+0x6e>
		s++, base = 8;
  800a08:	83 c1 01             	add    $0x1,%ecx
  800a0b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a10:	b8 00 00 00 00       	mov    $0x0,%eax
  800a15:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a18:	0f b6 11             	movzbl (%ecx),%edx
  800a1b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a1e:	89 f3                	mov    %esi,%ebx
  800a20:	80 fb 09             	cmp    $0x9,%bl
  800a23:	77 08                	ja     800a2d <strtol+0x8b>
			dig = *s - '0';
  800a25:	0f be d2             	movsbl %dl,%edx
  800a28:	83 ea 30             	sub    $0x30,%edx
  800a2b:	eb 22                	jmp    800a4f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a2d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a30:	89 f3                	mov    %esi,%ebx
  800a32:	80 fb 19             	cmp    $0x19,%bl
  800a35:	77 08                	ja     800a3f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a37:	0f be d2             	movsbl %dl,%edx
  800a3a:	83 ea 57             	sub    $0x57,%edx
  800a3d:	eb 10                	jmp    800a4f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a3f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a42:	89 f3                	mov    %esi,%ebx
  800a44:	80 fb 19             	cmp    $0x19,%bl
  800a47:	77 16                	ja     800a5f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a49:	0f be d2             	movsbl %dl,%edx
  800a4c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a4f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a52:	7d 0b                	jge    800a5f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a54:	83 c1 01             	add    $0x1,%ecx
  800a57:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a5b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a5d:	eb b9                	jmp    800a18 <strtol+0x76>

	if (endptr)
  800a5f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a63:	74 0d                	je     800a72 <strtol+0xd0>
		*endptr = (char *) s;
  800a65:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a68:	89 0e                	mov    %ecx,(%esi)
  800a6a:	eb 06                	jmp    800a72 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a6c:	85 db                	test   %ebx,%ebx
  800a6e:	74 98                	je     800a08 <strtol+0x66>
  800a70:	eb 9e                	jmp    800a10 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a72:	89 c2                	mov    %eax,%edx
  800a74:	f7 da                	neg    %edx
  800a76:	85 ff                	test   %edi,%edi
  800a78:	0f 45 c2             	cmovne %edx,%eax
}
  800a7b:	5b                   	pop    %ebx
  800a7c:	5e                   	pop    %esi
  800a7d:	5f                   	pop    %edi
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	57                   	push   %edi
  800a84:	56                   	push   %esi
  800a85:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a86:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a91:	89 c3                	mov    %eax,%ebx
  800a93:	89 c7                	mov    %eax,%edi
  800a95:	89 c6                	mov    %eax,%esi
  800a97:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a99:	5b                   	pop    %ebx
  800a9a:	5e                   	pop    %esi
  800a9b:	5f                   	pop    %edi
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	57                   	push   %edi
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa4:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa9:	b8 01 00 00 00       	mov    $0x1,%eax
  800aae:	89 d1                	mov    %edx,%ecx
  800ab0:	89 d3                	mov    %edx,%ebx
  800ab2:	89 d7                	mov    %edx,%edi
  800ab4:	89 d6                	mov    %edx,%esi
  800ab6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5f                   	pop    %edi
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	57                   	push   %edi
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
  800ac3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800acb:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad3:	89 cb                	mov    %ecx,%ebx
  800ad5:	89 cf                	mov    %ecx,%edi
  800ad7:	89 ce                	mov    %ecx,%esi
  800ad9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800adb:	85 c0                	test   %eax,%eax
  800add:	7e 17                	jle    800af6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800adf:	83 ec 0c             	sub    $0xc,%esp
  800ae2:	50                   	push   %eax
  800ae3:	6a 03                	push   $0x3
  800ae5:	68 5f 2c 80 00       	push   $0x802c5f
  800aea:	6a 23                	push   $0x23
  800aec:	68 7c 2c 80 00       	push   $0x802c7c
  800af1:	e8 e5 f5 ff ff       	call   8000db <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800af6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	57                   	push   %edi
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b04:	ba 00 00 00 00       	mov    $0x0,%edx
  800b09:	b8 02 00 00 00       	mov    $0x2,%eax
  800b0e:	89 d1                	mov    %edx,%ecx
  800b10:	89 d3                	mov    %edx,%ebx
  800b12:	89 d7                	mov    %edx,%edi
  800b14:	89 d6                	mov    %edx,%esi
  800b16:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5f                   	pop    %edi
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <sys_yield>:

void
sys_yield(void)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b23:	ba 00 00 00 00       	mov    $0x0,%edx
  800b28:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b2d:	89 d1                	mov    %edx,%ecx
  800b2f:	89 d3                	mov    %edx,%ebx
  800b31:	89 d7                	mov    %edx,%edi
  800b33:	89 d6                	mov    %edx,%esi
  800b35:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
  800b42:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b45:	be 00 00 00 00       	mov    $0x0,%esi
  800b4a:	b8 04 00 00 00       	mov    $0x4,%eax
  800b4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b52:	8b 55 08             	mov    0x8(%ebp),%edx
  800b55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b58:	89 f7                	mov    %esi,%edi
  800b5a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b5c:	85 c0                	test   %eax,%eax
  800b5e:	7e 17                	jle    800b77 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b60:	83 ec 0c             	sub    $0xc,%esp
  800b63:	50                   	push   %eax
  800b64:	6a 04                	push   $0x4
  800b66:	68 5f 2c 80 00       	push   $0x802c5f
  800b6b:	6a 23                	push   $0x23
  800b6d:	68 7c 2c 80 00       	push   $0x802c7c
  800b72:	e8 64 f5 ff ff       	call   8000db <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	57                   	push   %edi
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
  800b85:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b88:	b8 05 00 00 00       	mov    $0x5,%eax
  800b8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b90:	8b 55 08             	mov    0x8(%ebp),%edx
  800b93:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b96:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b99:	8b 75 18             	mov    0x18(%ebp),%esi
  800b9c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9e:	85 c0                	test   %eax,%eax
  800ba0:	7e 17                	jle    800bb9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba2:	83 ec 0c             	sub    $0xc,%esp
  800ba5:	50                   	push   %eax
  800ba6:	6a 05                	push   $0x5
  800ba8:	68 5f 2c 80 00       	push   $0x802c5f
  800bad:	6a 23                	push   $0x23
  800baf:	68 7c 2c 80 00       	push   $0x802c7c
  800bb4:	e8 22 f5 ff ff       	call   8000db <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	57                   	push   %edi
  800bc5:	56                   	push   %esi
  800bc6:	53                   	push   %ebx
  800bc7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bcf:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bda:	89 df                	mov    %ebx,%edi
  800bdc:	89 de                	mov    %ebx,%esi
  800bde:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be0:	85 c0                	test   %eax,%eax
  800be2:	7e 17                	jle    800bfb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be4:	83 ec 0c             	sub    $0xc,%esp
  800be7:	50                   	push   %eax
  800be8:	6a 06                	push   $0x6
  800bea:	68 5f 2c 80 00       	push   $0x802c5f
  800bef:	6a 23                	push   $0x23
  800bf1:	68 7c 2c 80 00       	push   $0x802c7c
  800bf6:	e8 e0 f4 ff ff       	call   8000db <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c11:	b8 08 00 00 00       	mov    $0x8,%eax
  800c16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	89 df                	mov    %ebx,%edi
  800c1e:	89 de                	mov    %ebx,%esi
  800c20:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c22:	85 c0                	test   %eax,%eax
  800c24:	7e 17                	jle    800c3d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c26:	83 ec 0c             	sub    $0xc,%esp
  800c29:	50                   	push   %eax
  800c2a:	6a 08                	push   $0x8
  800c2c:	68 5f 2c 80 00       	push   $0x802c5f
  800c31:	6a 23                	push   $0x23
  800c33:	68 7c 2c 80 00       	push   $0x802c7c
  800c38:	e8 9e f4 ff ff       	call   8000db <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
  800c4b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c53:	b8 09 00 00 00       	mov    $0x9,%eax
  800c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5e:	89 df                	mov    %ebx,%edi
  800c60:	89 de                	mov    %ebx,%esi
  800c62:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c64:	85 c0                	test   %eax,%eax
  800c66:	7e 17                	jle    800c7f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c68:	83 ec 0c             	sub    $0xc,%esp
  800c6b:	50                   	push   %eax
  800c6c:	6a 09                	push   $0x9
  800c6e:	68 5f 2c 80 00       	push   $0x802c5f
  800c73:	6a 23                	push   $0x23
  800c75:	68 7c 2c 80 00       	push   $0x802c7c
  800c7a:	e8 5c f4 ff ff       	call   8000db <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c90:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c95:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca0:	89 df                	mov    %ebx,%edi
  800ca2:	89 de                	mov    %ebx,%esi
  800ca4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca6:	85 c0                	test   %eax,%eax
  800ca8:	7e 17                	jle    800cc1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800caa:	83 ec 0c             	sub    $0xc,%esp
  800cad:	50                   	push   %eax
  800cae:	6a 0a                	push   $0xa
  800cb0:	68 5f 2c 80 00       	push   $0x802c5f
  800cb5:	6a 23                	push   $0x23
  800cb7:	68 7c 2c 80 00       	push   $0x802c7c
  800cbc:	e8 1a f4 ff ff       	call   8000db <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccf:	be 00 00 00 00       	mov    $0x0,%esi
  800cd4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
  800cf2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cfa:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cff:	8b 55 08             	mov    0x8(%ebp),%edx
  800d02:	89 cb                	mov    %ecx,%ebx
  800d04:	89 cf                	mov    %ecx,%edi
  800d06:	89 ce                	mov    %ecx,%esi
  800d08:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0a:	85 c0                	test   %eax,%eax
  800d0c:	7e 17                	jle    800d25 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0e:	83 ec 0c             	sub    $0xc,%esp
  800d11:	50                   	push   %eax
  800d12:	6a 0d                	push   $0xd
  800d14:	68 5f 2c 80 00       	push   $0x802c5f
  800d19:	6a 23                	push   $0x23
  800d1b:	68 7c 2c 80 00       	push   $0x802c7c
  800d20:	e8 b6 f3 ff ff       	call   8000db <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5f                   	pop    %edi
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    

00800d2d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	57                   	push   %edi
  800d31:	56                   	push   %esi
  800d32:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d33:	ba 00 00 00 00       	mov    $0x0,%edx
  800d38:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d3d:	89 d1                	mov    %edx,%ecx
  800d3f:	89 d3                	mov    %edx,%ebx
  800d41:	89 d7                	mov    %edx,%edi
  800d43:	89 d6                	mov    %edx,%esi
  800d45:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	57                   	push   %edi
  800d50:	56                   	push   %esi
  800d51:	53                   	push   %ebx
  800d52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5a:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	89 df                	mov    %ebx,%edi
  800d67:	89 de                	mov    %ebx,%esi
  800d69:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	7e 17                	jle    800d86 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6f:	83 ec 0c             	sub    $0xc,%esp
  800d72:	50                   	push   %eax
  800d73:	6a 0f                	push   $0xf
  800d75:	68 5f 2c 80 00       	push   $0x802c5f
  800d7a:	6a 23                	push   $0x23
  800d7c:	68 7c 2c 80 00       	push   $0x802c7c
  800d81:	e8 55 f3 ff ff       	call   8000db <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800d86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5f                   	pop    %edi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    

00800d8e <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9c:	b8 10 00 00 00       	mov    $0x10,%eax
  800da1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da4:	8b 55 08             	mov    0x8(%ebp),%edx
  800da7:	89 df                	mov    %ebx,%edi
  800da9:	89 de                	mov    %ebx,%esi
  800dab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dad:	85 c0                	test   %eax,%eax
  800daf:	7e 17                	jle    800dc8 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db1:	83 ec 0c             	sub    $0xc,%esp
  800db4:	50                   	push   %eax
  800db5:	6a 10                	push   $0x10
  800db7:	68 5f 2c 80 00       	push   $0x802c5f
  800dbc:	6a 23                	push   $0x23
  800dbe:	68 7c 2c 80 00       	push   $0x802c7c
  800dc3:	e8 13 f3 ff ff       	call   8000db <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  800dc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcb:	5b                   	pop    %ebx
  800dcc:	5e                   	pop    %esi
  800dcd:	5f                   	pop    %edi
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd6:	05 00 00 00 30       	add    $0x30000000,%eax
  800ddb:	c1 e8 0c             	shr    $0xc,%eax
}
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800de3:	8b 45 08             	mov    0x8(%ebp),%eax
  800de6:	05 00 00 00 30       	add    $0x30000000,%eax
  800deb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800df0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800df5:	5d                   	pop    %ebp
  800df6:	c3                   	ret    

00800df7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dfd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e02:	89 c2                	mov    %eax,%edx
  800e04:	c1 ea 16             	shr    $0x16,%edx
  800e07:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e0e:	f6 c2 01             	test   $0x1,%dl
  800e11:	74 11                	je     800e24 <fd_alloc+0x2d>
  800e13:	89 c2                	mov    %eax,%edx
  800e15:	c1 ea 0c             	shr    $0xc,%edx
  800e18:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e1f:	f6 c2 01             	test   $0x1,%dl
  800e22:	75 09                	jne    800e2d <fd_alloc+0x36>
			*fd_store = fd;
  800e24:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e26:	b8 00 00 00 00       	mov    $0x0,%eax
  800e2b:	eb 17                	jmp    800e44 <fd_alloc+0x4d>
  800e2d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e32:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e37:	75 c9                	jne    800e02 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e39:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e3f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e44:	5d                   	pop    %ebp
  800e45:	c3                   	ret    

00800e46 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e4c:	83 f8 1f             	cmp    $0x1f,%eax
  800e4f:	77 36                	ja     800e87 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e51:	c1 e0 0c             	shl    $0xc,%eax
  800e54:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e59:	89 c2                	mov    %eax,%edx
  800e5b:	c1 ea 16             	shr    $0x16,%edx
  800e5e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e65:	f6 c2 01             	test   $0x1,%dl
  800e68:	74 24                	je     800e8e <fd_lookup+0x48>
  800e6a:	89 c2                	mov    %eax,%edx
  800e6c:	c1 ea 0c             	shr    $0xc,%edx
  800e6f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e76:	f6 c2 01             	test   $0x1,%dl
  800e79:	74 1a                	je     800e95 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e7b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e7e:	89 02                	mov    %eax,(%edx)
	return 0;
  800e80:	b8 00 00 00 00       	mov    $0x0,%eax
  800e85:	eb 13                	jmp    800e9a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e87:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e8c:	eb 0c                	jmp    800e9a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e8e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e93:	eb 05                	jmp    800e9a <fd_lookup+0x54>
  800e95:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	83 ec 08             	sub    $0x8,%esp
  800ea2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea5:	ba 08 2d 80 00       	mov    $0x802d08,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800eaa:	eb 13                	jmp    800ebf <dev_lookup+0x23>
  800eac:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800eaf:	39 08                	cmp    %ecx,(%eax)
  800eb1:	75 0c                	jne    800ebf <dev_lookup+0x23>
			*dev = devtab[i];
  800eb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb6:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eb8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebd:	eb 2e                	jmp    800eed <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ebf:	8b 02                	mov    (%edx),%eax
  800ec1:	85 c0                	test   %eax,%eax
  800ec3:	75 e7                	jne    800eac <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ec5:	a1 08 40 80 00       	mov    0x804008,%eax
  800eca:	8b 40 48             	mov    0x48(%eax),%eax
  800ecd:	83 ec 04             	sub    $0x4,%esp
  800ed0:	51                   	push   %ecx
  800ed1:	50                   	push   %eax
  800ed2:	68 8c 2c 80 00       	push   $0x802c8c
  800ed7:	e8 d8 f2 ff ff       	call   8001b4 <cprintf>
	*dev = 0;
  800edc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800edf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ee5:	83 c4 10             	add    $0x10,%esp
  800ee8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800eed:	c9                   	leave  
  800eee:	c3                   	ret    

00800eef <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	56                   	push   %esi
  800ef3:	53                   	push   %ebx
  800ef4:	83 ec 10             	sub    $0x10,%esp
  800ef7:	8b 75 08             	mov    0x8(%ebp),%esi
  800efa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800efd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f00:	50                   	push   %eax
  800f01:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f07:	c1 e8 0c             	shr    $0xc,%eax
  800f0a:	50                   	push   %eax
  800f0b:	e8 36 ff ff ff       	call   800e46 <fd_lookup>
  800f10:	83 c4 08             	add    $0x8,%esp
  800f13:	85 c0                	test   %eax,%eax
  800f15:	78 05                	js     800f1c <fd_close+0x2d>
	    || fd != fd2)
  800f17:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f1a:	74 0c                	je     800f28 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f1c:	84 db                	test   %bl,%bl
  800f1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f23:	0f 44 c2             	cmove  %edx,%eax
  800f26:	eb 41                	jmp    800f69 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f28:	83 ec 08             	sub    $0x8,%esp
  800f2b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f2e:	50                   	push   %eax
  800f2f:	ff 36                	pushl  (%esi)
  800f31:	e8 66 ff ff ff       	call   800e9c <dev_lookup>
  800f36:	89 c3                	mov    %eax,%ebx
  800f38:	83 c4 10             	add    $0x10,%esp
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	78 1a                	js     800f59 <fd_close+0x6a>
		if (dev->dev_close)
  800f3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f42:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f45:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f4a:	85 c0                	test   %eax,%eax
  800f4c:	74 0b                	je     800f59 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f4e:	83 ec 0c             	sub    $0xc,%esp
  800f51:	56                   	push   %esi
  800f52:	ff d0                	call   *%eax
  800f54:	89 c3                	mov    %eax,%ebx
  800f56:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f59:	83 ec 08             	sub    $0x8,%esp
  800f5c:	56                   	push   %esi
  800f5d:	6a 00                	push   $0x0
  800f5f:	e8 5d fc ff ff       	call   800bc1 <sys_page_unmap>
	return r;
  800f64:	83 c4 10             	add    $0x10,%esp
  800f67:	89 d8                	mov    %ebx,%eax
}
  800f69:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f6c:	5b                   	pop    %ebx
  800f6d:	5e                   	pop    %esi
  800f6e:	5d                   	pop    %ebp
  800f6f:	c3                   	ret    

00800f70 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f76:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f79:	50                   	push   %eax
  800f7a:	ff 75 08             	pushl  0x8(%ebp)
  800f7d:	e8 c4 fe ff ff       	call   800e46 <fd_lookup>
  800f82:	83 c4 08             	add    $0x8,%esp
  800f85:	85 c0                	test   %eax,%eax
  800f87:	78 10                	js     800f99 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f89:	83 ec 08             	sub    $0x8,%esp
  800f8c:	6a 01                	push   $0x1
  800f8e:	ff 75 f4             	pushl  -0xc(%ebp)
  800f91:	e8 59 ff ff ff       	call   800eef <fd_close>
  800f96:	83 c4 10             	add    $0x10,%esp
}
  800f99:	c9                   	leave  
  800f9a:	c3                   	ret    

00800f9b <close_all>:

void
close_all(void)
{
  800f9b:	55                   	push   %ebp
  800f9c:	89 e5                	mov    %esp,%ebp
  800f9e:	53                   	push   %ebx
  800f9f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fa2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fa7:	83 ec 0c             	sub    $0xc,%esp
  800faa:	53                   	push   %ebx
  800fab:	e8 c0 ff ff ff       	call   800f70 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fb0:	83 c3 01             	add    $0x1,%ebx
  800fb3:	83 c4 10             	add    $0x10,%esp
  800fb6:	83 fb 20             	cmp    $0x20,%ebx
  800fb9:	75 ec                	jne    800fa7 <close_all+0xc>
		close(i);
}
  800fbb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fbe:	c9                   	leave  
  800fbf:	c3                   	ret    

00800fc0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	57                   	push   %edi
  800fc4:	56                   	push   %esi
  800fc5:	53                   	push   %ebx
  800fc6:	83 ec 2c             	sub    $0x2c,%esp
  800fc9:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fcc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fcf:	50                   	push   %eax
  800fd0:	ff 75 08             	pushl  0x8(%ebp)
  800fd3:	e8 6e fe ff ff       	call   800e46 <fd_lookup>
  800fd8:	83 c4 08             	add    $0x8,%esp
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	0f 88 c1 00 00 00    	js     8010a4 <dup+0xe4>
		return r;
	close(newfdnum);
  800fe3:	83 ec 0c             	sub    $0xc,%esp
  800fe6:	56                   	push   %esi
  800fe7:	e8 84 ff ff ff       	call   800f70 <close>

	newfd = INDEX2FD(newfdnum);
  800fec:	89 f3                	mov    %esi,%ebx
  800fee:	c1 e3 0c             	shl    $0xc,%ebx
  800ff1:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800ff7:	83 c4 04             	add    $0x4,%esp
  800ffa:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ffd:	e8 de fd ff ff       	call   800de0 <fd2data>
  801002:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801004:	89 1c 24             	mov    %ebx,(%esp)
  801007:	e8 d4 fd ff ff       	call   800de0 <fd2data>
  80100c:	83 c4 10             	add    $0x10,%esp
  80100f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801012:	89 f8                	mov    %edi,%eax
  801014:	c1 e8 16             	shr    $0x16,%eax
  801017:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80101e:	a8 01                	test   $0x1,%al
  801020:	74 37                	je     801059 <dup+0x99>
  801022:	89 f8                	mov    %edi,%eax
  801024:	c1 e8 0c             	shr    $0xc,%eax
  801027:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80102e:	f6 c2 01             	test   $0x1,%dl
  801031:	74 26                	je     801059 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801033:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80103a:	83 ec 0c             	sub    $0xc,%esp
  80103d:	25 07 0e 00 00       	and    $0xe07,%eax
  801042:	50                   	push   %eax
  801043:	ff 75 d4             	pushl  -0x2c(%ebp)
  801046:	6a 00                	push   $0x0
  801048:	57                   	push   %edi
  801049:	6a 00                	push   $0x0
  80104b:	e8 2f fb ff ff       	call   800b7f <sys_page_map>
  801050:	89 c7                	mov    %eax,%edi
  801052:	83 c4 20             	add    $0x20,%esp
  801055:	85 c0                	test   %eax,%eax
  801057:	78 2e                	js     801087 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801059:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80105c:	89 d0                	mov    %edx,%eax
  80105e:	c1 e8 0c             	shr    $0xc,%eax
  801061:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801068:	83 ec 0c             	sub    $0xc,%esp
  80106b:	25 07 0e 00 00       	and    $0xe07,%eax
  801070:	50                   	push   %eax
  801071:	53                   	push   %ebx
  801072:	6a 00                	push   $0x0
  801074:	52                   	push   %edx
  801075:	6a 00                	push   $0x0
  801077:	e8 03 fb ff ff       	call   800b7f <sys_page_map>
  80107c:	89 c7                	mov    %eax,%edi
  80107e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801081:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801083:	85 ff                	test   %edi,%edi
  801085:	79 1d                	jns    8010a4 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801087:	83 ec 08             	sub    $0x8,%esp
  80108a:	53                   	push   %ebx
  80108b:	6a 00                	push   $0x0
  80108d:	e8 2f fb ff ff       	call   800bc1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801092:	83 c4 08             	add    $0x8,%esp
  801095:	ff 75 d4             	pushl  -0x2c(%ebp)
  801098:	6a 00                	push   $0x0
  80109a:	e8 22 fb ff ff       	call   800bc1 <sys_page_unmap>
	return r;
  80109f:	83 c4 10             	add    $0x10,%esp
  8010a2:	89 f8                	mov    %edi,%eax
}
  8010a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a7:	5b                   	pop    %ebx
  8010a8:	5e                   	pop    %esi
  8010a9:	5f                   	pop    %edi
  8010aa:	5d                   	pop    %ebp
  8010ab:	c3                   	ret    

008010ac <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
  8010af:	53                   	push   %ebx
  8010b0:	83 ec 14             	sub    $0x14,%esp
  8010b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010b9:	50                   	push   %eax
  8010ba:	53                   	push   %ebx
  8010bb:	e8 86 fd ff ff       	call   800e46 <fd_lookup>
  8010c0:	83 c4 08             	add    $0x8,%esp
  8010c3:	89 c2                	mov    %eax,%edx
  8010c5:	85 c0                	test   %eax,%eax
  8010c7:	78 6d                	js     801136 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010c9:	83 ec 08             	sub    $0x8,%esp
  8010cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010cf:	50                   	push   %eax
  8010d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010d3:	ff 30                	pushl  (%eax)
  8010d5:	e8 c2 fd ff ff       	call   800e9c <dev_lookup>
  8010da:	83 c4 10             	add    $0x10,%esp
  8010dd:	85 c0                	test   %eax,%eax
  8010df:	78 4c                	js     80112d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010e1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010e4:	8b 42 08             	mov    0x8(%edx),%eax
  8010e7:	83 e0 03             	and    $0x3,%eax
  8010ea:	83 f8 01             	cmp    $0x1,%eax
  8010ed:	75 21                	jne    801110 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010ef:	a1 08 40 80 00       	mov    0x804008,%eax
  8010f4:	8b 40 48             	mov    0x48(%eax),%eax
  8010f7:	83 ec 04             	sub    $0x4,%esp
  8010fa:	53                   	push   %ebx
  8010fb:	50                   	push   %eax
  8010fc:	68 cd 2c 80 00       	push   $0x802ccd
  801101:	e8 ae f0 ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  801106:	83 c4 10             	add    $0x10,%esp
  801109:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80110e:	eb 26                	jmp    801136 <read+0x8a>
	}
	if (!dev->dev_read)
  801110:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801113:	8b 40 08             	mov    0x8(%eax),%eax
  801116:	85 c0                	test   %eax,%eax
  801118:	74 17                	je     801131 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80111a:	83 ec 04             	sub    $0x4,%esp
  80111d:	ff 75 10             	pushl  0x10(%ebp)
  801120:	ff 75 0c             	pushl  0xc(%ebp)
  801123:	52                   	push   %edx
  801124:	ff d0                	call   *%eax
  801126:	89 c2                	mov    %eax,%edx
  801128:	83 c4 10             	add    $0x10,%esp
  80112b:	eb 09                	jmp    801136 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80112d:	89 c2                	mov    %eax,%edx
  80112f:	eb 05                	jmp    801136 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801131:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801136:	89 d0                	mov    %edx,%eax
  801138:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80113b:	c9                   	leave  
  80113c:	c3                   	ret    

0080113d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80113d:	55                   	push   %ebp
  80113e:	89 e5                	mov    %esp,%ebp
  801140:	57                   	push   %edi
  801141:	56                   	push   %esi
  801142:	53                   	push   %ebx
  801143:	83 ec 0c             	sub    $0xc,%esp
  801146:	8b 7d 08             	mov    0x8(%ebp),%edi
  801149:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80114c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801151:	eb 21                	jmp    801174 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801153:	83 ec 04             	sub    $0x4,%esp
  801156:	89 f0                	mov    %esi,%eax
  801158:	29 d8                	sub    %ebx,%eax
  80115a:	50                   	push   %eax
  80115b:	89 d8                	mov    %ebx,%eax
  80115d:	03 45 0c             	add    0xc(%ebp),%eax
  801160:	50                   	push   %eax
  801161:	57                   	push   %edi
  801162:	e8 45 ff ff ff       	call   8010ac <read>
		if (m < 0)
  801167:	83 c4 10             	add    $0x10,%esp
  80116a:	85 c0                	test   %eax,%eax
  80116c:	78 10                	js     80117e <readn+0x41>
			return m;
		if (m == 0)
  80116e:	85 c0                	test   %eax,%eax
  801170:	74 0a                	je     80117c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801172:	01 c3                	add    %eax,%ebx
  801174:	39 f3                	cmp    %esi,%ebx
  801176:	72 db                	jb     801153 <readn+0x16>
  801178:	89 d8                	mov    %ebx,%eax
  80117a:	eb 02                	jmp    80117e <readn+0x41>
  80117c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80117e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801181:	5b                   	pop    %ebx
  801182:	5e                   	pop    %esi
  801183:	5f                   	pop    %edi
  801184:	5d                   	pop    %ebp
  801185:	c3                   	ret    

00801186 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801186:	55                   	push   %ebp
  801187:	89 e5                	mov    %esp,%ebp
  801189:	53                   	push   %ebx
  80118a:	83 ec 14             	sub    $0x14,%esp
  80118d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801190:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801193:	50                   	push   %eax
  801194:	53                   	push   %ebx
  801195:	e8 ac fc ff ff       	call   800e46 <fd_lookup>
  80119a:	83 c4 08             	add    $0x8,%esp
  80119d:	89 c2                	mov    %eax,%edx
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	78 68                	js     80120b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a3:	83 ec 08             	sub    $0x8,%esp
  8011a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a9:	50                   	push   %eax
  8011aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ad:	ff 30                	pushl  (%eax)
  8011af:	e8 e8 fc ff ff       	call   800e9c <dev_lookup>
  8011b4:	83 c4 10             	add    $0x10,%esp
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	78 47                	js     801202 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011be:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011c2:	75 21                	jne    8011e5 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011c4:	a1 08 40 80 00       	mov    0x804008,%eax
  8011c9:	8b 40 48             	mov    0x48(%eax),%eax
  8011cc:	83 ec 04             	sub    $0x4,%esp
  8011cf:	53                   	push   %ebx
  8011d0:	50                   	push   %eax
  8011d1:	68 e9 2c 80 00       	push   $0x802ce9
  8011d6:	e8 d9 ef ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  8011db:	83 c4 10             	add    $0x10,%esp
  8011de:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011e3:	eb 26                	jmp    80120b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011e8:	8b 52 0c             	mov    0xc(%edx),%edx
  8011eb:	85 d2                	test   %edx,%edx
  8011ed:	74 17                	je     801206 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011ef:	83 ec 04             	sub    $0x4,%esp
  8011f2:	ff 75 10             	pushl  0x10(%ebp)
  8011f5:	ff 75 0c             	pushl  0xc(%ebp)
  8011f8:	50                   	push   %eax
  8011f9:	ff d2                	call   *%edx
  8011fb:	89 c2                	mov    %eax,%edx
  8011fd:	83 c4 10             	add    $0x10,%esp
  801200:	eb 09                	jmp    80120b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801202:	89 c2                	mov    %eax,%edx
  801204:	eb 05                	jmp    80120b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801206:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80120b:	89 d0                	mov    %edx,%eax
  80120d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801210:	c9                   	leave  
  801211:	c3                   	ret    

00801212 <seek>:

int
seek(int fdnum, off_t offset)
{
  801212:	55                   	push   %ebp
  801213:	89 e5                	mov    %esp,%ebp
  801215:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801218:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80121b:	50                   	push   %eax
  80121c:	ff 75 08             	pushl  0x8(%ebp)
  80121f:	e8 22 fc ff ff       	call   800e46 <fd_lookup>
  801224:	83 c4 08             	add    $0x8,%esp
  801227:	85 c0                	test   %eax,%eax
  801229:	78 0e                	js     801239 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80122b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80122e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801231:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801234:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801239:	c9                   	leave  
  80123a:	c3                   	ret    

0080123b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80123b:	55                   	push   %ebp
  80123c:	89 e5                	mov    %esp,%ebp
  80123e:	53                   	push   %ebx
  80123f:	83 ec 14             	sub    $0x14,%esp
  801242:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801245:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801248:	50                   	push   %eax
  801249:	53                   	push   %ebx
  80124a:	e8 f7 fb ff ff       	call   800e46 <fd_lookup>
  80124f:	83 c4 08             	add    $0x8,%esp
  801252:	89 c2                	mov    %eax,%edx
  801254:	85 c0                	test   %eax,%eax
  801256:	78 65                	js     8012bd <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801258:	83 ec 08             	sub    $0x8,%esp
  80125b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125e:	50                   	push   %eax
  80125f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801262:	ff 30                	pushl  (%eax)
  801264:	e8 33 fc ff ff       	call   800e9c <dev_lookup>
  801269:	83 c4 10             	add    $0x10,%esp
  80126c:	85 c0                	test   %eax,%eax
  80126e:	78 44                	js     8012b4 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801270:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801273:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801277:	75 21                	jne    80129a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801279:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80127e:	8b 40 48             	mov    0x48(%eax),%eax
  801281:	83 ec 04             	sub    $0x4,%esp
  801284:	53                   	push   %ebx
  801285:	50                   	push   %eax
  801286:	68 ac 2c 80 00       	push   $0x802cac
  80128b:	e8 24 ef ff ff       	call   8001b4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801290:	83 c4 10             	add    $0x10,%esp
  801293:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801298:	eb 23                	jmp    8012bd <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80129a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80129d:	8b 52 18             	mov    0x18(%edx),%edx
  8012a0:	85 d2                	test   %edx,%edx
  8012a2:	74 14                	je     8012b8 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012a4:	83 ec 08             	sub    $0x8,%esp
  8012a7:	ff 75 0c             	pushl  0xc(%ebp)
  8012aa:	50                   	push   %eax
  8012ab:	ff d2                	call   *%edx
  8012ad:	89 c2                	mov    %eax,%edx
  8012af:	83 c4 10             	add    $0x10,%esp
  8012b2:	eb 09                	jmp    8012bd <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b4:	89 c2                	mov    %eax,%edx
  8012b6:	eb 05                	jmp    8012bd <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012b8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012bd:	89 d0                	mov    %edx,%eax
  8012bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c2:	c9                   	leave  
  8012c3:	c3                   	ret    

008012c4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	53                   	push   %ebx
  8012c8:	83 ec 14             	sub    $0x14,%esp
  8012cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d1:	50                   	push   %eax
  8012d2:	ff 75 08             	pushl  0x8(%ebp)
  8012d5:	e8 6c fb ff ff       	call   800e46 <fd_lookup>
  8012da:	83 c4 08             	add    $0x8,%esp
  8012dd:	89 c2                	mov    %eax,%edx
  8012df:	85 c0                	test   %eax,%eax
  8012e1:	78 58                	js     80133b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e3:	83 ec 08             	sub    $0x8,%esp
  8012e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e9:	50                   	push   %eax
  8012ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ed:	ff 30                	pushl  (%eax)
  8012ef:	e8 a8 fb ff ff       	call   800e9c <dev_lookup>
  8012f4:	83 c4 10             	add    $0x10,%esp
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	78 37                	js     801332 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012fe:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801302:	74 32                	je     801336 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801304:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801307:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80130e:	00 00 00 
	stat->st_isdir = 0;
  801311:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801318:	00 00 00 
	stat->st_dev = dev;
  80131b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801321:	83 ec 08             	sub    $0x8,%esp
  801324:	53                   	push   %ebx
  801325:	ff 75 f0             	pushl  -0x10(%ebp)
  801328:	ff 50 14             	call   *0x14(%eax)
  80132b:	89 c2                	mov    %eax,%edx
  80132d:	83 c4 10             	add    $0x10,%esp
  801330:	eb 09                	jmp    80133b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801332:	89 c2                	mov    %eax,%edx
  801334:	eb 05                	jmp    80133b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801336:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80133b:	89 d0                	mov    %edx,%eax
  80133d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801340:	c9                   	leave  
  801341:	c3                   	ret    

00801342 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801342:	55                   	push   %ebp
  801343:	89 e5                	mov    %esp,%ebp
  801345:	56                   	push   %esi
  801346:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801347:	83 ec 08             	sub    $0x8,%esp
  80134a:	6a 00                	push   $0x0
  80134c:	ff 75 08             	pushl  0x8(%ebp)
  80134f:	e8 d6 01 00 00       	call   80152a <open>
  801354:	89 c3                	mov    %eax,%ebx
  801356:	83 c4 10             	add    $0x10,%esp
  801359:	85 c0                	test   %eax,%eax
  80135b:	78 1b                	js     801378 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80135d:	83 ec 08             	sub    $0x8,%esp
  801360:	ff 75 0c             	pushl  0xc(%ebp)
  801363:	50                   	push   %eax
  801364:	e8 5b ff ff ff       	call   8012c4 <fstat>
  801369:	89 c6                	mov    %eax,%esi
	close(fd);
  80136b:	89 1c 24             	mov    %ebx,(%esp)
  80136e:	e8 fd fb ff ff       	call   800f70 <close>
	return r;
  801373:	83 c4 10             	add    $0x10,%esp
  801376:	89 f0                	mov    %esi,%eax
}
  801378:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80137b:	5b                   	pop    %ebx
  80137c:	5e                   	pop    %esi
  80137d:	5d                   	pop    %ebp
  80137e:	c3                   	ret    

0080137f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  801382:	56                   	push   %esi
  801383:	53                   	push   %ebx
  801384:	89 c6                	mov    %eax,%esi
  801386:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801388:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80138f:	75 12                	jne    8013a3 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801391:	83 ec 0c             	sub    $0xc,%esp
  801394:	6a 01                	push   $0x1
  801396:	e8 24 12 00 00       	call   8025bf <ipc_find_env>
  80139b:	a3 00 40 80 00       	mov    %eax,0x804000
  8013a0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013a3:	6a 07                	push   $0x7
  8013a5:	68 00 50 80 00       	push   $0x805000
  8013aa:	56                   	push   %esi
  8013ab:	ff 35 00 40 80 00    	pushl  0x804000
  8013b1:	e8 b5 11 00 00       	call   80256b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013b6:	83 c4 0c             	add    $0xc,%esp
  8013b9:	6a 00                	push   $0x0
  8013bb:	53                   	push   %ebx
  8013bc:	6a 00                	push   $0x0
  8013be:	e8 41 11 00 00       	call   802504 <ipc_recv>
}
  8013c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c6:	5b                   	pop    %ebx
  8013c7:	5e                   	pop    %esi
  8013c8:	5d                   	pop    %ebp
  8013c9:	c3                   	ret    

008013ca <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d3:	8b 40 0c             	mov    0xc(%eax),%eax
  8013d6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013de:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e8:	b8 02 00 00 00       	mov    $0x2,%eax
  8013ed:	e8 8d ff ff ff       	call   80137f <fsipc>
}
  8013f2:	c9                   	leave  
  8013f3:	c3                   	ret    

008013f4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013f4:	55                   	push   %ebp
  8013f5:	89 e5                	mov    %esp,%ebp
  8013f7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801400:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801405:	ba 00 00 00 00       	mov    $0x0,%edx
  80140a:	b8 06 00 00 00       	mov    $0x6,%eax
  80140f:	e8 6b ff ff ff       	call   80137f <fsipc>
}
  801414:	c9                   	leave  
  801415:	c3                   	ret    

00801416 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	53                   	push   %ebx
  80141a:	83 ec 04             	sub    $0x4,%esp
  80141d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801420:	8b 45 08             	mov    0x8(%ebp),%eax
  801423:	8b 40 0c             	mov    0xc(%eax),%eax
  801426:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80142b:	ba 00 00 00 00       	mov    $0x0,%edx
  801430:	b8 05 00 00 00       	mov    $0x5,%eax
  801435:	e8 45 ff ff ff       	call   80137f <fsipc>
  80143a:	85 c0                	test   %eax,%eax
  80143c:	78 2c                	js     80146a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80143e:	83 ec 08             	sub    $0x8,%esp
  801441:	68 00 50 80 00       	push   $0x805000
  801446:	53                   	push   %ebx
  801447:	e8 ed f2 ff ff       	call   800739 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80144c:	a1 80 50 80 00       	mov    0x805080,%eax
  801451:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801457:	a1 84 50 80 00       	mov    0x805084,%eax
  80145c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801462:	83 c4 10             	add    $0x10,%esp
  801465:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80146a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80146d:	c9                   	leave  
  80146e:	c3                   	ret    

0080146f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80146f:	55                   	push   %ebp
  801470:	89 e5                	mov    %esp,%ebp
  801472:	83 ec 0c             	sub    $0xc,%esp
  801475:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801478:	8b 55 08             	mov    0x8(%ebp),%edx
  80147b:	8b 52 0c             	mov    0xc(%edx),%edx
  80147e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801484:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801489:	50                   	push   %eax
  80148a:	ff 75 0c             	pushl  0xc(%ebp)
  80148d:	68 08 50 80 00       	push   $0x805008
  801492:	e8 34 f4 ff ff       	call   8008cb <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801497:	ba 00 00 00 00       	mov    $0x0,%edx
  80149c:	b8 04 00 00 00       	mov    $0x4,%eax
  8014a1:	e8 d9 fe ff ff       	call   80137f <fsipc>

}
  8014a6:	c9                   	leave  
  8014a7:	c3                   	ret    

008014a8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014a8:	55                   	push   %ebp
  8014a9:	89 e5                	mov    %esp,%ebp
  8014ab:	56                   	push   %esi
  8014ac:	53                   	push   %ebx
  8014ad:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b3:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014bb:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c6:	b8 03 00 00 00       	mov    $0x3,%eax
  8014cb:	e8 af fe ff ff       	call   80137f <fsipc>
  8014d0:	89 c3                	mov    %eax,%ebx
  8014d2:	85 c0                	test   %eax,%eax
  8014d4:	78 4b                	js     801521 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014d6:	39 c6                	cmp    %eax,%esi
  8014d8:	73 16                	jae    8014f0 <devfile_read+0x48>
  8014da:	68 1c 2d 80 00       	push   $0x802d1c
  8014df:	68 23 2d 80 00       	push   $0x802d23
  8014e4:	6a 7c                	push   $0x7c
  8014e6:	68 38 2d 80 00       	push   $0x802d38
  8014eb:	e8 eb eb ff ff       	call   8000db <_panic>
	assert(r <= PGSIZE);
  8014f0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014f5:	7e 16                	jle    80150d <devfile_read+0x65>
  8014f7:	68 43 2d 80 00       	push   $0x802d43
  8014fc:	68 23 2d 80 00       	push   $0x802d23
  801501:	6a 7d                	push   $0x7d
  801503:	68 38 2d 80 00       	push   $0x802d38
  801508:	e8 ce eb ff ff       	call   8000db <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80150d:	83 ec 04             	sub    $0x4,%esp
  801510:	50                   	push   %eax
  801511:	68 00 50 80 00       	push   $0x805000
  801516:	ff 75 0c             	pushl  0xc(%ebp)
  801519:	e8 ad f3 ff ff       	call   8008cb <memmove>
	return r;
  80151e:	83 c4 10             	add    $0x10,%esp
}
  801521:	89 d8                	mov    %ebx,%eax
  801523:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801526:	5b                   	pop    %ebx
  801527:	5e                   	pop    %esi
  801528:	5d                   	pop    %ebp
  801529:	c3                   	ret    

0080152a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	53                   	push   %ebx
  80152e:	83 ec 20             	sub    $0x20,%esp
  801531:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801534:	53                   	push   %ebx
  801535:	e8 c6 f1 ff ff       	call   800700 <strlen>
  80153a:	83 c4 10             	add    $0x10,%esp
  80153d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801542:	7f 67                	jg     8015ab <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801544:	83 ec 0c             	sub    $0xc,%esp
  801547:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154a:	50                   	push   %eax
  80154b:	e8 a7 f8 ff ff       	call   800df7 <fd_alloc>
  801550:	83 c4 10             	add    $0x10,%esp
		return r;
  801553:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801555:	85 c0                	test   %eax,%eax
  801557:	78 57                	js     8015b0 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801559:	83 ec 08             	sub    $0x8,%esp
  80155c:	53                   	push   %ebx
  80155d:	68 00 50 80 00       	push   $0x805000
  801562:	e8 d2 f1 ff ff       	call   800739 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801567:	8b 45 0c             	mov    0xc(%ebp),%eax
  80156a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80156f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801572:	b8 01 00 00 00       	mov    $0x1,%eax
  801577:	e8 03 fe ff ff       	call   80137f <fsipc>
  80157c:	89 c3                	mov    %eax,%ebx
  80157e:	83 c4 10             	add    $0x10,%esp
  801581:	85 c0                	test   %eax,%eax
  801583:	79 14                	jns    801599 <open+0x6f>
		fd_close(fd, 0);
  801585:	83 ec 08             	sub    $0x8,%esp
  801588:	6a 00                	push   $0x0
  80158a:	ff 75 f4             	pushl  -0xc(%ebp)
  80158d:	e8 5d f9 ff ff       	call   800eef <fd_close>
		return r;
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	89 da                	mov    %ebx,%edx
  801597:	eb 17                	jmp    8015b0 <open+0x86>
	}

	return fd2num(fd);
  801599:	83 ec 0c             	sub    $0xc,%esp
  80159c:	ff 75 f4             	pushl  -0xc(%ebp)
  80159f:	e8 2c f8 ff ff       	call   800dd0 <fd2num>
  8015a4:	89 c2                	mov    %eax,%edx
  8015a6:	83 c4 10             	add    $0x10,%esp
  8015a9:	eb 05                	jmp    8015b0 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015ab:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015b0:	89 d0                	mov    %edx,%eax
  8015b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b5:	c9                   	leave  
  8015b6:	c3                   	ret    

008015b7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015b7:	55                   	push   %ebp
  8015b8:	89 e5                	mov    %esp,%ebp
  8015ba:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c2:	b8 08 00 00 00       	mov    $0x8,%eax
  8015c7:	e8 b3 fd ff ff       	call   80137f <fsipc>
}
  8015cc:	c9                   	leave  
  8015cd:	c3                   	ret    

008015ce <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8015ce:	55                   	push   %ebp
  8015cf:	89 e5                	mov    %esp,%ebp
  8015d1:	57                   	push   %edi
  8015d2:	56                   	push   %esi
  8015d3:	53                   	push   %ebx
  8015d4:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8015da:	6a 00                	push   $0x0
  8015dc:	ff 75 08             	pushl  0x8(%ebp)
  8015df:	e8 46 ff ff ff       	call   80152a <open>
  8015e4:	89 c7                	mov    %eax,%edi
  8015e6:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	0f 88 97 04 00 00    	js     801a8e <spawn+0x4c0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8015f7:	83 ec 04             	sub    $0x4,%esp
  8015fa:	68 00 02 00 00       	push   $0x200
  8015ff:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801605:	50                   	push   %eax
  801606:	57                   	push   %edi
  801607:	e8 31 fb ff ff       	call   80113d <readn>
  80160c:	83 c4 10             	add    $0x10,%esp
  80160f:	3d 00 02 00 00       	cmp    $0x200,%eax
  801614:	75 0c                	jne    801622 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801616:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80161d:	45 4c 46 
  801620:	74 33                	je     801655 <spawn+0x87>
		close(fd);
  801622:	83 ec 0c             	sub    $0xc,%esp
  801625:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80162b:	e8 40 f9 ff ff       	call   800f70 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801630:	83 c4 0c             	add    $0xc,%esp
  801633:	68 7f 45 4c 46       	push   $0x464c457f
  801638:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80163e:	68 4f 2d 80 00       	push   $0x802d4f
  801643:	e8 6c eb ff ff       	call   8001b4 <cprintf>
		return -E_NOT_EXEC;
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801650:	e9 ec 04 00 00       	jmp    801b41 <spawn+0x573>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801655:	b8 07 00 00 00       	mov    $0x7,%eax
  80165a:	cd 30                	int    $0x30
  80165c:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801662:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801668:	85 c0                	test   %eax,%eax
  80166a:	0f 88 29 04 00 00    	js     801a99 <spawn+0x4cb>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801670:	89 c6                	mov    %eax,%esi
  801672:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801678:	6b f6 7c             	imul   $0x7c,%esi,%esi
  80167b:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801681:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801687:	b9 11 00 00 00       	mov    $0x11,%ecx
  80168c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80168e:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801694:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80169a:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80169f:	be 00 00 00 00       	mov    $0x0,%esi
  8016a4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8016a7:	eb 13                	jmp    8016bc <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8016a9:	83 ec 0c             	sub    $0xc,%esp
  8016ac:	50                   	push   %eax
  8016ad:	e8 4e f0 ff ff       	call   800700 <strlen>
  8016b2:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8016b6:	83 c3 01             	add    $0x1,%ebx
  8016b9:	83 c4 10             	add    $0x10,%esp
  8016bc:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8016c3:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8016c6:	85 c0                	test   %eax,%eax
  8016c8:	75 df                	jne    8016a9 <spawn+0xdb>
  8016ca:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8016d0:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8016d6:	bf 00 10 40 00       	mov    $0x401000,%edi
  8016db:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8016dd:	89 fa                	mov    %edi,%edx
  8016df:	83 e2 fc             	and    $0xfffffffc,%edx
  8016e2:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8016e9:	29 c2                	sub    %eax,%edx
  8016eb:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8016f1:	8d 42 f8             	lea    -0x8(%edx),%eax
  8016f4:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8016f9:	0f 86 b0 03 00 00    	jbe    801aaf <spawn+0x4e1>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8016ff:	83 ec 04             	sub    $0x4,%esp
  801702:	6a 07                	push   $0x7
  801704:	68 00 00 40 00       	push   $0x400000
  801709:	6a 00                	push   $0x0
  80170b:	e8 2c f4 ff ff       	call   800b3c <sys_page_alloc>
  801710:	83 c4 10             	add    $0x10,%esp
  801713:	85 c0                	test   %eax,%eax
  801715:	0f 88 9e 03 00 00    	js     801ab9 <spawn+0x4eb>
  80171b:	be 00 00 00 00       	mov    $0x0,%esi
  801720:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801726:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801729:	eb 30                	jmp    80175b <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80172b:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801731:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801737:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  80173a:	83 ec 08             	sub    $0x8,%esp
  80173d:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801740:	57                   	push   %edi
  801741:	e8 f3 ef ff ff       	call   800739 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801746:	83 c4 04             	add    $0x4,%esp
  801749:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80174c:	e8 af ef ff ff       	call   800700 <strlen>
  801751:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801755:	83 c6 01             	add    $0x1,%esi
  801758:	83 c4 10             	add    $0x10,%esp
  80175b:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801761:	7f c8                	jg     80172b <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801763:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801769:	8b b5 80 fd ff ff    	mov    -0x280(%ebp),%esi
  80176f:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801776:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80177c:	74 19                	je     801797 <spawn+0x1c9>
  80177e:	68 dc 2d 80 00       	push   $0x802ddc
  801783:	68 23 2d 80 00       	push   $0x802d23
  801788:	68 f2 00 00 00       	push   $0xf2
  80178d:	68 69 2d 80 00       	push   $0x802d69
  801792:	e8 44 e9 ff ff       	call   8000db <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801797:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  80179d:	89 f8                	mov    %edi,%eax
  80179f:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8017a4:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  8017a7:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8017ad:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8017b0:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  8017b6:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8017bc:	83 ec 0c             	sub    $0xc,%esp
  8017bf:	6a 07                	push   $0x7
  8017c1:	68 00 d0 bf ee       	push   $0xeebfd000
  8017c6:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8017cc:	68 00 00 40 00       	push   $0x400000
  8017d1:	6a 00                	push   $0x0
  8017d3:	e8 a7 f3 ff ff       	call   800b7f <sys_page_map>
  8017d8:	89 c3                	mov    %eax,%ebx
  8017da:	83 c4 20             	add    $0x20,%esp
  8017dd:	85 c0                	test   %eax,%eax
  8017df:	0f 88 4a 03 00 00    	js     801b2f <spawn+0x561>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8017e5:	83 ec 08             	sub    $0x8,%esp
  8017e8:	68 00 00 40 00       	push   $0x400000
  8017ed:	6a 00                	push   $0x0
  8017ef:	e8 cd f3 ff ff       	call   800bc1 <sys_page_unmap>
  8017f4:	89 c3                	mov    %eax,%ebx
  8017f6:	83 c4 10             	add    $0x10,%esp
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	0f 88 2e 03 00 00    	js     801b2f <spawn+0x561>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801801:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801807:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  80180e:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801814:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  80181b:	00 00 00 
  80181e:	e9 8a 01 00 00       	jmp    8019ad <spawn+0x3df>
		if (ph->p_type != ELF_PROG_LOAD)
  801823:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801829:	83 38 01             	cmpl   $0x1,(%eax)
  80182c:	0f 85 6d 01 00 00    	jne    80199f <spawn+0x3d1>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801832:	89 c7                	mov    %eax,%edi
  801834:	8b 40 18             	mov    0x18(%eax),%eax
  801837:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  80183d:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801840:	83 f8 01             	cmp    $0x1,%eax
  801843:	19 c0                	sbb    %eax,%eax
  801845:	83 e0 fe             	and    $0xfffffffe,%eax
  801848:	83 c0 07             	add    $0x7,%eax
  80184b:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801851:	89 f8                	mov    %edi,%eax
  801853:	8b 7f 04             	mov    0x4(%edi),%edi
  801856:	89 f9                	mov    %edi,%ecx
  801858:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  80185e:	8b 78 10             	mov    0x10(%eax),%edi
  801861:	8b 70 14             	mov    0x14(%eax),%esi
  801864:	89 f3                	mov    %esi,%ebx
  801866:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  80186c:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80186f:	89 f0                	mov    %esi,%eax
  801871:	25 ff 0f 00 00       	and    $0xfff,%eax
  801876:	74 14                	je     80188c <spawn+0x2be>
		va -= i;
  801878:	29 c6                	sub    %eax,%esi
		memsz += i;
  80187a:	01 c3                	add    %eax,%ebx
  80187c:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  801882:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801884:	29 c1                	sub    %eax,%ecx
  801886:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80188c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801891:	e9 f7 00 00 00       	jmp    80198d <spawn+0x3bf>
		if (i >= filesz) {
  801896:	39 df                	cmp    %ebx,%edi
  801898:	77 27                	ja     8018c1 <spawn+0x2f3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  80189a:	83 ec 04             	sub    $0x4,%esp
  80189d:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8018a3:	56                   	push   %esi
  8018a4:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8018aa:	e8 8d f2 ff ff       	call   800b3c <sys_page_alloc>
  8018af:	83 c4 10             	add    $0x10,%esp
  8018b2:	85 c0                	test   %eax,%eax
  8018b4:	0f 89 c7 00 00 00    	jns    801981 <spawn+0x3b3>
  8018ba:	89 c3                	mov    %eax,%ebx
  8018bc:	e9 09 02 00 00       	jmp    801aca <spawn+0x4fc>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8018c1:	83 ec 04             	sub    $0x4,%esp
  8018c4:	6a 07                	push   $0x7
  8018c6:	68 00 00 40 00       	push   $0x400000
  8018cb:	6a 00                	push   $0x0
  8018cd:	e8 6a f2 ff ff       	call   800b3c <sys_page_alloc>
  8018d2:	83 c4 10             	add    $0x10,%esp
  8018d5:	85 c0                	test   %eax,%eax
  8018d7:	0f 88 e3 01 00 00    	js     801ac0 <spawn+0x4f2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8018dd:	83 ec 08             	sub    $0x8,%esp
  8018e0:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8018e6:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  8018ec:	50                   	push   %eax
  8018ed:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8018f3:	e8 1a f9 ff ff       	call   801212 <seek>
  8018f8:	83 c4 10             	add    $0x10,%esp
  8018fb:	85 c0                	test   %eax,%eax
  8018fd:	0f 88 c1 01 00 00    	js     801ac4 <spawn+0x4f6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801903:	83 ec 04             	sub    $0x4,%esp
  801906:	89 f8                	mov    %edi,%eax
  801908:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  80190e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801913:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801918:	0f 47 c1             	cmova  %ecx,%eax
  80191b:	50                   	push   %eax
  80191c:	68 00 00 40 00       	push   $0x400000
  801921:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801927:	e8 11 f8 ff ff       	call   80113d <readn>
  80192c:	83 c4 10             	add    $0x10,%esp
  80192f:	85 c0                	test   %eax,%eax
  801931:	0f 88 91 01 00 00    	js     801ac8 <spawn+0x4fa>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801937:	83 ec 0c             	sub    $0xc,%esp
  80193a:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801940:	56                   	push   %esi
  801941:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801947:	68 00 00 40 00       	push   $0x400000
  80194c:	6a 00                	push   $0x0
  80194e:	e8 2c f2 ff ff       	call   800b7f <sys_page_map>
  801953:	83 c4 20             	add    $0x20,%esp
  801956:	85 c0                	test   %eax,%eax
  801958:	79 15                	jns    80196f <spawn+0x3a1>
				panic("spawn: sys_page_map data: %e", r);
  80195a:	50                   	push   %eax
  80195b:	68 75 2d 80 00       	push   $0x802d75
  801960:	68 25 01 00 00       	push   $0x125
  801965:	68 69 2d 80 00       	push   $0x802d69
  80196a:	e8 6c e7 ff ff       	call   8000db <_panic>
			sys_page_unmap(0, UTEMP);
  80196f:	83 ec 08             	sub    $0x8,%esp
  801972:	68 00 00 40 00       	push   $0x400000
  801977:	6a 00                	push   $0x0
  801979:	e8 43 f2 ff ff       	call   800bc1 <sys_page_unmap>
  80197e:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801981:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801987:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80198d:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801993:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801999:	0f 87 f7 fe ff ff    	ja     801896 <spawn+0x2c8>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80199f:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  8019a6:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  8019ad:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8019b4:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8019ba:	0f 8c 63 fe ff ff    	jl     801823 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8019c0:	83 ec 0c             	sub    $0xc,%esp
  8019c3:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019c9:	e8 a2 f5 ff ff       	call   800f70 <close>
  8019ce:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  8019d1:	bb 00 08 00 00       	mov    $0x800,%ebx
  8019d6:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi

		addr = pn * PGSIZE;
  8019dc:	89 d8                	mov    %ebx,%eax
  8019de:	c1 e0 0c             	shl    $0xc,%eax

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  8019e1:	89 c2                	mov    %eax,%edx
  8019e3:	c1 ea 16             	shr    $0x16,%edx
  8019e6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8019ed:	f6 c2 01             	test   $0x1,%dl
  8019f0:	74 4b                	je     801a3d <spawn+0x46f>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  8019f2:	89 c2                	mov    %eax,%edx
  8019f4:	c1 ea 0c             	shr    $0xc,%edx
  8019f7:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  8019fe:	f6 c1 01             	test   $0x1,%cl
  801a01:	74 3a                	je     801a3d <spawn+0x46f>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & PTE_SHARE) != 0) {
  801a03:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801a0a:	f6 c6 04             	test   $0x4,%dh
  801a0d:	74 2e                	je     801a3d <spawn+0x46f>
					r = sys_page_map(thisenv->env_id, (void *)addr, child, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  801a0f:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  801a16:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801a1c:	8b 49 48             	mov    0x48(%ecx),%ecx
  801a1f:	83 ec 0c             	sub    $0xc,%esp
  801a22:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801a28:	52                   	push   %edx
  801a29:	50                   	push   %eax
  801a2a:	56                   	push   %esi
  801a2b:	50                   	push   %eax
  801a2c:	51                   	push   %ecx
  801a2d:	e8 4d f1 ff ff       	call   800b7f <sys_page_map>
					if (r < 0)
  801a32:	83 c4 20             	add    $0x20,%esp
  801a35:	85 c0                	test   %eax,%eax
  801a37:	0f 88 ae 00 00 00    	js     801aeb <spawn+0x51d>
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801a3d:	83 c3 01             	add    $0x1,%ebx
  801a40:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801a46:	75 94                	jne    8019dc <spawn+0x40e>
  801a48:	e9 b3 00 00 00       	jmp    801b00 <spawn+0x532>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801a4d:	50                   	push   %eax
  801a4e:	68 92 2d 80 00       	push   $0x802d92
  801a53:	68 86 00 00 00       	push   $0x86
  801a58:	68 69 2d 80 00       	push   $0x802d69
  801a5d:	e8 79 e6 ff ff       	call   8000db <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801a62:	83 ec 08             	sub    $0x8,%esp
  801a65:	6a 02                	push   $0x2
  801a67:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a6d:	e8 91 f1 ff ff       	call   800c03 <sys_env_set_status>
  801a72:	83 c4 10             	add    $0x10,%esp
  801a75:	85 c0                	test   %eax,%eax
  801a77:	79 2b                	jns    801aa4 <spawn+0x4d6>
		panic("sys_env_set_status: %e", r);
  801a79:	50                   	push   %eax
  801a7a:	68 ac 2d 80 00       	push   $0x802dac
  801a7f:	68 89 00 00 00       	push   $0x89
  801a84:	68 69 2d 80 00       	push   $0x802d69
  801a89:	e8 4d e6 ff ff       	call   8000db <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801a8e:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801a94:	e9 a8 00 00 00       	jmp    801b41 <spawn+0x573>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801a99:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801a9f:	e9 9d 00 00 00       	jmp    801b41 <spawn+0x573>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801aa4:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801aaa:	e9 92 00 00 00       	jmp    801b41 <spawn+0x573>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801aaf:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801ab4:	e9 88 00 00 00       	jmp    801b41 <spawn+0x573>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801ab9:	89 c3                	mov    %eax,%ebx
  801abb:	e9 81 00 00 00       	jmp    801b41 <spawn+0x573>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ac0:	89 c3                	mov    %eax,%ebx
  801ac2:	eb 06                	jmp    801aca <spawn+0x4fc>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801ac4:	89 c3                	mov    %eax,%ebx
  801ac6:	eb 02                	jmp    801aca <spawn+0x4fc>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801ac8:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801aca:	83 ec 0c             	sub    $0xc,%esp
  801acd:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ad3:	e8 e5 ef ff ff       	call   800abd <sys_env_destroy>
	close(fd);
  801ad8:	83 c4 04             	add    $0x4,%esp
  801adb:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ae1:	e8 8a f4 ff ff       	call   800f70 <close>
	return r;
  801ae6:	83 c4 10             	add    $0x10,%esp
  801ae9:	eb 56                	jmp    801b41 <spawn+0x573>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801aeb:	50                   	push   %eax
  801aec:	68 c3 2d 80 00       	push   $0x802dc3
  801af1:	68 82 00 00 00       	push   $0x82
  801af6:	68 69 2d 80 00       	push   $0x802d69
  801afb:	e8 db e5 ff ff       	call   8000db <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801b00:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801b07:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801b0a:	83 ec 08             	sub    $0x8,%esp
  801b0d:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801b13:	50                   	push   %eax
  801b14:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b1a:	e8 26 f1 ff ff       	call   800c45 <sys_env_set_trapframe>
  801b1f:	83 c4 10             	add    $0x10,%esp
  801b22:	85 c0                	test   %eax,%eax
  801b24:	0f 89 38 ff ff ff    	jns    801a62 <spawn+0x494>
  801b2a:	e9 1e ff ff ff       	jmp    801a4d <spawn+0x47f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801b2f:	83 ec 08             	sub    $0x8,%esp
  801b32:	68 00 00 40 00       	push   $0x400000
  801b37:	6a 00                	push   $0x0
  801b39:	e8 83 f0 ff ff       	call   800bc1 <sys_page_unmap>
  801b3e:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801b41:	89 d8                	mov    %ebx,%eax
  801b43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b46:	5b                   	pop    %ebx
  801b47:	5e                   	pop    %esi
  801b48:	5f                   	pop    %edi
  801b49:	5d                   	pop    %ebp
  801b4a:	c3                   	ret    

00801b4b <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801b4b:	55                   	push   %ebp
  801b4c:	89 e5                	mov    %esp,%ebp
  801b4e:	56                   	push   %esi
  801b4f:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b50:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801b53:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b58:	eb 03                	jmp    801b5d <spawnl+0x12>
		argc++;
  801b5a:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b5d:	83 c2 04             	add    $0x4,%edx
  801b60:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801b64:	75 f4                	jne    801b5a <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801b66:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801b6d:	83 e2 f0             	and    $0xfffffff0,%edx
  801b70:	29 d4                	sub    %edx,%esp
  801b72:	8d 54 24 03          	lea    0x3(%esp),%edx
  801b76:	c1 ea 02             	shr    $0x2,%edx
  801b79:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801b80:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801b82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b85:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801b8c:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801b93:	00 
  801b94:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801b96:	b8 00 00 00 00       	mov    $0x0,%eax
  801b9b:	eb 0a                	jmp    801ba7 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801b9d:	83 c0 01             	add    $0x1,%eax
  801ba0:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801ba4:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801ba7:	39 d0                	cmp    %edx,%eax
  801ba9:	75 f2                	jne    801b9d <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801bab:	83 ec 08             	sub    $0x8,%esp
  801bae:	56                   	push   %esi
  801baf:	ff 75 08             	pushl  0x8(%ebp)
  801bb2:	e8 17 fa ff ff       	call   8015ce <spawn>
}
  801bb7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bba:	5b                   	pop    %ebx
  801bbb:	5e                   	pop    %esi
  801bbc:	5d                   	pop    %ebp
  801bbd:	c3                   	ret    

00801bbe <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
  801bc1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801bc4:	68 04 2e 80 00       	push   $0x802e04
  801bc9:	ff 75 0c             	pushl  0xc(%ebp)
  801bcc:	e8 68 eb ff ff       	call   800739 <strcpy>
	return 0;
}
  801bd1:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd6:	c9                   	leave  
  801bd7:	c3                   	ret    

00801bd8 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	53                   	push   %ebx
  801bdc:	83 ec 10             	sub    $0x10,%esp
  801bdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801be2:	53                   	push   %ebx
  801be3:	e8 10 0a 00 00       	call   8025f8 <pageref>
  801be8:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801beb:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801bf0:	83 f8 01             	cmp    $0x1,%eax
  801bf3:	75 10                	jne    801c05 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801bf5:	83 ec 0c             	sub    $0xc,%esp
  801bf8:	ff 73 0c             	pushl  0xc(%ebx)
  801bfb:	e8 c0 02 00 00       	call   801ec0 <nsipc_close>
  801c00:	89 c2                	mov    %eax,%edx
  801c02:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801c05:	89 d0                	mov    %edx,%eax
  801c07:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c0a:	c9                   	leave  
  801c0b:	c3                   	ret    

00801c0c <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801c0c:	55                   	push   %ebp
  801c0d:	89 e5                	mov    %esp,%ebp
  801c0f:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c12:	6a 00                	push   $0x0
  801c14:	ff 75 10             	pushl  0x10(%ebp)
  801c17:	ff 75 0c             	pushl  0xc(%ebp)
  801c1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1d:	ff 70 0c             	pushl  0xc(%eax)
  801c20:	e8 78 03 00 00       	call   801f9d <nsipc_send>
}
  801c25:	c9                   	leave  
  801c26:	c3                   	ret    

00801c27 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801c27:	55                   	push   %ebp
  801c28:	89 e5                	mov    %esp,%ebp
  801c2a:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801c2d:	6a 00                	push   $0x0
  801c2f:	ff 75 10             	pushl  0x10(%ebp)
  801c32:	ff 75 0c             	pushl  0xc(%ebp)
  801c35:	8b 45 08             	mov    0x8(%ebp),%eax
  801c38:	ff 70 0c             	pushl  0xc(%eax)
  801c3b:	e8 f1 02 00 00       	call   801f31 <nsipc_recv>
}
  801c40:	c9                   	leave  
  801c41:	c3                   	ret    

00801c42 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c48:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c4b:	52                   	push   %edx
  801c4c:	50                   	push   %eax
  801c4d:	e8 f4 f1 ff ff       	call   800e46 <fd_lookup>
  801c52:	83 c4 10             	add    $0x10,%esp
  801c55:	85 c0                	test   %eax,%eax
  801c57:	78 17                	js     801c70 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c5c:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801c62:	39 08                	cmp    %ecx,(%eax)
  801c64:	75 05                	jne    801c6b <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801c66:	8b 40 0c             	mov    0xc(%eax),%eax
  801c69:	eb 05                	jmp    801c70 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801c6b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801c70:	c9                   	leave  
  801c71:	c3                   	ret    

00801c72 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801c72:	55                   	push   %ebp
  801c73:	89 e5                	mov    %esp,%ebp
  801c75:	56                   	push   %esi
  801c76:	53                   	push   %ebx
  801c77:	83 ec 1c             	sub    $0x1c,%esp
  801c7a:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801c7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c7f:	50                   	push   %eax
  801c80:	e8 72 f1 ff ff       	call   800df7 <fd_alloc>
  801c85:	89 c3                	mov    %eax,%ebx
  801c87:	83 c4 10             	add    $0x10,%esp
  801c8a:	85 c0                	test   %eax,%eax
  801c8c:	78 1b                	js     801ca9 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801c8e:	83 ec 04             	sub    $0x4,%esp
  801c91:	68 07 04 00 00       	push   $0x407
  801c96:	ff 75 f4             	pushl  -0xc(%ebp)
  801c99:	6a 00                	push   $0x0
  801c9b:	e8 9c ee ff ff       	call   800b3c <sys_page_alloc>
  801ca0:	89 c3                	mov    %eax,%ebx
  801ca2:	83 c4 10             	add    $0x10,%esp
  801ca5:	85 c0                	test   %eax,%eax
  801ca7:	79 10                	jns    801cb9 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801ca9:	83 ec 0c             	sub    $0xc,%esp
  801cac:	56                   	push   %esi
  801cad:	e8 0e 02 00 00       	call   801ec0 <nsipc_close>
		return r;
  801cb2:	83 c4 10             	add    $0x10,%esp
  801cb5:	89 d8                	mov    %ebx,%eax
  801cb7:	eb 24                	jmp    801cdd <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801cb9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc2:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801cc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801cce:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801cd1:	83 ec 0c             	sub    $0xc,%esp
  801cd4:	50                   	push   %eax
  801cd5:	e8 f6 f0 ff ff       	call   800dd0 <fd2num>
  801cda:	83 c4 10             	add    $0x10,%esp
}
  801cdd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ce0:	5b                   	pop    %ebx
  801ce1:	5e                   	pop    %esi
  801ce2:	5d                   	pop    %ebp
  801ce3:	c3                   	ret    

00801ce4 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ce4:	55                   	push   %ebp
  801ce5:	89 e5                	mov    %esp,%ebp
  801ce7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cea:	8b 45 08             	mov    0x8(%ebp),%eax
  801ced:	e8 50 ff ff ff       	call   801c42 <fd2sockid>
		return r;
  801cf2:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cf4:	85 c0                	test   %eax,%eax
  801cf6:	78 1f                	js     801d17 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801cf8:	83 ec 04             	sub    $0x4,%esp
  801cfb:	ff 75 10             	pushl  0x10(%ebp)
  801cfe:	ff 75 0c             	pushl  0xc(%ebp)
  801d01:	50                   	push   %eax
  801d02:	e8 12 01 00 00       	call   801e19 <nsipc_accept>
  801d07:	83 c4 10             	add    $0x10,%esp
		return r;
  801d0a:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d0c:	85 c0                	test   %eax,%eax
  801d0e:	78 07                	js     801d17 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801d10:	e8 5d ff ff ff       	call   801c72 <alloc_sockfd>
  801d15:	89 c1                	mov    %eax,%ecx
}
  801d17:	89 c8                	mov    %ecx,%eax
  801d19:	c9                   	leave  
  801d1a:	c3                   	ret    

00801d1b <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d21:	8b 45 08             	mov    0x8(%ebp),%eax
  801d24:	e8 19 ff ff ff       	call   801c42 <fd2sockid>
  801d29:	85 c0                	test   %eax,%eax
  801d2b:	78 12                	js     801d3f <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801d2d:	83 ec 04             	sub    $0x4,%esp
  801d30:	ff 75 10             	pushl  0x10(%ebp)
  801d33:	ff 75 0c             	pushl  0xc(%ebp)
  801d36:	50                   	push   %eax
  801d37:	e8 2d 01 00 00       	call   801e69 <nsipc_bind>
  801d3c:	83 c4 10             	add    $0x10,%esp
}
  801d3f:	c9                   	leave  
  801d40:	c3                   	ret    

00801d41 <shutdown>:

int
shutdown(int s, int how)
{
  801d41:	55                   	push   %ebp
  801d42:	89 e5                	mov    %esp,%ebp
  801d44:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d47:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4a:	e8 f3 fe ff ff       	call   801c42 <fd2sockid>
  801d4f:	85 c0                	test   %eax,%eax
  801d51:	78 0f                	js     801d62 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801d53:	83 ec 08             	sub    $0x8,%esp
  801d56:	ff 75 0c             	pushl  0xc(%ebp)
  801d59:	50                   	push   %eax
  801d5a:	e8 3f 01 00 00       	call   801e9e <nsipc_shutdown>
  801d5f:	83 c4 10             	add    $0x10,%esp
}
  801d62:	c9                   	leave  
  801d63:	c3                   	ret    

00801d64 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d64:	55                   	push   %ebp
  801d65:	89 e5                	mov    %esp,%ebp
  801d67:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6d:	e8 d0 fe ff ff       	call   801c42 <fd2sockid>
  801d72:	85 c0                	test   %eax,%eax
  801d74:	78 12                	js     801d88 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801d76:	83 ec 04             	sub    $0x4,%esp
  801d79:	ff 75 10             	pushl  0x10(%ebp)
  801d7c:	ff 75 0c             	pushl  0xc(%ebp)
  801d7f:	50                   	push   %eax
  801d80:	e8 55 01 00 00       	call   801eda <nsipc_connect>
  801d85:	83 c4 10             	add    $0x10,%esp
}
  801d88:	c9                   	leave  
  801d89:	c3                   	ret    

00801d8a <listen>:

int
listen(int s, int backlog)
{
  801d8a:	55                   	push   %ebp
  801d8b:	89 e5                	mov    %esp,%ebp
  801d8d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d90:	8b 45 08             	mov    0x8(%ebp),%eax
  801d93:	e8 aa fe ff ff       	call   801c42 <fd2sockid>
  801d98:	85 c0                	test   %eax,%eax
  801d9a:	78 0f                	js     801dab <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801d9c:	83 ec 08             	sub    $0x8,%esp
  801d9f:	ff 75 0c             	pushl  0xc(%ebp)
  801da2:	50                   	push   %eax
  801da3:	e8 67 01 00 00       	call   801f0f <nsipc_listen>
  801da8:	83 c4 10             	add    $0x10,%esp
}
  801dab:	c9                   	leave  
  801dac:	c3                   	ret    

00801dad <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801dad:	55                   	push   %ebp
  801dae:	89 e5                	mov    %esp,%ebp
  801db0:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801db3:	ff 75 10             	pushl  0x10(%ebp)
  801db6:	ff 75 0c             	pushl  0xc(%ebp)
  801db9:	ff 75 08             	pushl  0x8(%ebp)
  801dbc:	e8 3a 02 00 00       	call   801ffb <nsipc_socket>
  801dc1:	83 c4 10             	add    $0x10,%esp
  801dc4:	85 c0                	test   %eax,%eax
  801dc6:	78 05                	js     801dcd <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801dc8:	e8 a5 fe ff ff       	call   801c72 <alloc_sockfd>
}
  801dcd:	c9                   	leave  
  801dce:	c3                   	ret    

00801dcf <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801dcf:	55                   	push   %ebp
  801dd0:	89 e5                	mov    %esp,%ebp
  801dd2:	53                   	push   %ebx
  801dd3:	83 ec 04             	sub    $0x4,%esp
  801dd6:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801dd8:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801ddf:	75 12                	jne    801df3 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801de1:	83 ec 0c             	sub    $0xc,%esp
  801de4:	6a 02                	push   $0x2
  801de6:	e8 d4 07 00 00       	call   8025bf <ipc_find_env>
  801deb:	a3 04 40 80 00       	mov    %eax,0x804004
  801df0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801df3:	6a 07                	push   $0x7
  801df5:	68 00 60 80 00       	push   $0x806000
  801dfa:	53                   	push   %ebx
  801dfb:	ff 35 04 40 80 00    	pushl  0x804004
  801e01:	e8 65 07 00 00       	call   80256b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801e06:	83 c4 0c             	add    $0xc,%esp
  801e09:	6a 00                	push   $0x0
  801e0b:	6a 00                	push   $0x0
  801e0d:	6a 00                	push   $0x0
  801e0f:	e8 f0 06 00 00       	call   802504 <ipc_recv>
}
  801e14:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e17:	c9                   	leave  
  801e18:	c3                   	ret    

00801e19 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e19:	55                   	push   %ebp
  801e1a:	89 e5                	mov    %esp,%ebp
  801e1c:	56                   	push   %esi
  801e1d:	53                   	push   %ebx
  801e1e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801e21:	8b 45 08             	mov    0x8(%ebp),%eax
  801e24:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801e29:	8b 06                	mov    (%esi),%eax
  801e2b:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e30:	b8 01 00 00 00       	mov    $0x1,%eax
  801e35:	e8 95 ff ff ff       	call   801dcf <nsipc>
  801e3a:	89 c3                	mov    %eax,%ebx
  801e3c:	85 c0                	test   %eax,%eax
  801e3e:	78 20                	js     801e60 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801e40:	83 ec 04             	sub    $0x4,%esp
  801e43:	ff 35 10 60 80 00    	pushl  0x806010
  801e49:	68 00 60 80 00       	push   $0x806000
  801e4e:	ff 75 0c             	pushl  0xc(%ebp)
  801e51:	e8 75 ea ff ff       	call   8008cb <memmove>
		*addrlen = ret->ret_addrlen;
  801e56:	a1 10 60 80 00       	mov    0x806010,%eax
  801e5b:	89 06                	mov    %eax,(%esi)
  801e5d:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801e60:	89 d8                	mov    %ebx,%eax
  801e62:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e65:	5b                   	pop    %ebx
  801e66:	5e                   	pop    %esi
  801e67:	5d                   	pop    %ebp
  801e68:	c3                   	ret    

00801e69 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e69:	55                   	push   %ebp
  801e6a:	89 e5                	mov    %esp,%ebp
  801e6c:	53                   	push   %ebx
  801e6d:	83 ec 08             	sub    $0x8,%esp
  801e70:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e73:	8b 45 08             	mov    0x8(%ebp),%eax
  801e76:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801e7b:	53                   	push   %ebx
  801e7c:	ff 75 0c             	pushl  0xc(%ebp)
  801e7f:	68 04 60 80 00       	push   $0x806004
  801e84:	e8 42 ea ff ff       	call   8008cb <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801e89:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801e8f:	b8 02 00 00 00       	mov    $0x2,%eax
  801e94:	e8 36 ff ff ff       	call   801dcf <nsipc>
}
  801e99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e9c:	c9                   	leave  
  801e9d:	c3                   	ret    

00801e9e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801e9e:	55                   	push   %ebp
  801e9f:	89 e5                	mov    %esp,%ebp
  801ea1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801ea4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801eac:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eaf:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801eb4:	b8 03 00 00 00       	mov    $0x3,%eax
  801eb9:	e8 11 ff ff ff       	call   801dcf <nsipc>
}
  801ebe:	c9                   	leave  
  801ebf:	c3                   	ret    

00801ec0 <nsipc_close>:

int
nsipc_close(int s)
{
  801ec0:	55                   	push   %ebp
  801ec1:	89 e5                	mov    %esp,%ebp
  801ec3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ec6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec9:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801ece:	b8 04 00 00 00       	mov    $0x4,%eax
  801ed3:	e8 f7 fe ff ff       	call   801dcf <nsipc>
}
  801ed8:	c9                   	leave  
  801ed9:	c3                   	ret    

00801eda <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801eda:	55                   	push   %ebp
  801edb:	89 e5                	mov    %esp,%ebp
  801edd:	53                   	push   %ebx
  801ede:	83 ec 08             	sub    $0x8,%esp
  801ee1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801ee4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee7:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801eec:	53                   	push   %ebx
  801eed:	ff 75 0c             	pushl  0xc(%ebp)
  801ef0:	68 04 60 80 00       	push   $0x806004
  801ef5:	e8 d1 e9 ff ff       	call   8008cb <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801efa:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801f00:	b8 05 00 00 00       	mov    $0x5,%eax
  801f05:	e8 c5 fe ff ff       	call   801dcf <nsipc>
}
  801f0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f0d:	c9                   	leave  
  801f0e:	c3                   	ret    

00801f0f <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801f0f:	55                   	push   %ebp
  801f10:	89 e5                	mov    %esp,%ebp
  801f12:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801f15:	8b 45 08             	mov    0x8(%ebp),%eax
  801f18:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801f1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f20:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801f25:	b8 06 00 00 00       	mov    $0x6,%eax
  801f2a:	e8 a0 fe ff ff       	call   801dcf <nsipc>
}
  801f2f:	c9                   	leave  
  801f30:	c3                   	ret    

00801f31 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801f31:	55                   	push   %ebp
  801f32:	89 e5                	mov    %esp,%ebp
  801f34:	56                   	push   %esi
  801f35:	53                   	push   %ebx
  801f36:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801f39:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801f41:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801f47:	8b 45 14             	mov    0x14(%ebp),%eax
  801f4a:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801f4f:	b8 07 00 00 00       	mov    $0x7,%eax
  801f54:	e8 76 fe ff ff       	call   801dcf <nsipc>
  801f59:	89 c3                	mov    %eax,%ebx
  801f5b:	85 c0                	test   %eax,%eax
  801f5d:	78 35                	js     801f94 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801f5f:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801f64:	7f 04                	jg     801f6a <nsipc_recv+0x39>
  801f66:	39 c6                	cmp    %eax,%esi
  801f68:	7d 16                	jge    801f80 <nsipc_recv+0x4f>
  801f6a:	68 10 2e 80 00       	push   $0x802e10
  801f6f:	68 23 2d 80 00       	push   $0x802d23
  801f74:	6a 62                	push   $0x62
  801f76:	68 25 2e 80 00       	push   $0x802e25
  801f7b:	e8 5b e1 ff ff       	call   8000db <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f80:	83 ec 04             	sub    $0x4,%esp
  801f83:	50                   	push   %eax
  801f84:	68 00 60 80 00       	push   $0x806000
  801f89:	ff 75 0c             	pushl  0xc(%ebp)
  801f8c:	e8 3a e9 ff ff       	call   8008cb <memmove>
  801f91:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801f94:	89 d8                	mov    %ebx,%eax
  801f96:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f99:	5b                   	pop    %ebx
  801f9a:	5e                   	pop    %esi
  801f9b:	5d                   	pop    %ebp
  801f9c:	c3                   	ret    

00801f9d <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801f9d:	55                   	push   %ebp
  801f9e:	89 e5                	mov    %esp,%ebp
  801fa0:	53                   	push   %ebx
  801fa1:	83 ec 04             	sub    $0x4,%esp
  801fa4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801fa7:	8b 45 08             	mov    0x8(%ebp),%eax
  801faa:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801faf:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801fb5:	7e 16                	jle    801fcd <nsipc_send+0x30>
  801fb7:	68 31 2e 80 00       	push   $0x802e31
  801fbc:	68 23 2d 80 00       	push   $0x802d23
  801fc1:	6a 6d                	push   $0x6d
  801fc3:	68 25 2e 80 00       	push   $0x802e25
  801fc8:	e8 0e e1 ff ff       	call   8000db <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801fcd:	83 ec 04             	sub    $0x4,%esp
  801fd0:	53                   	push   %ebx
  801fd1:	ff 75 0c             	pushl  0xc(%ebp)
  801fd4:	68 0c 60 80 00       	push   $0x80600c
  801fd9:	e8 ed e8 ff ff       	call   8008cb <memmove>
	nsipcbuf.send.req_size = size;
  801fde:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801fe4:	8b 45 14             	mov    0x14(%ebp),%eax
  801fe7:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801fec:	b8 08 00 00 00       	mov    $0x8,%eax
  801ff1:	e8 d9 fd ff ff       	call   801dcf <nsipc>
}
  801ff6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ff9:	c9                   	leave  
  801ffa:	c3                   	ret    

00801ffb <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ffb:	55                   	push   %ebp
  801ffc:	89 e5                	mov    %esp,%ebp
  801ffe:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802001:	8b 45 08             	mov    0x8(%ebp),%eax
  802004:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802009:	8b 45 0c             	mov    0xc(%ebp),%eax
  80200c:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802011:	8b 45 10             	mov    0x10(%ebp),%eax
  802014:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802019:	b8 09 00 00 00       	mov    $0x9,%eax
  80201e:	e8 ac fd ff ff       	call   801dcf <nsipc>
}
  802023:	c9                   	leave  
  802024:	c3                   	ret    

00802025 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802025:	55                   	push   %ebp
  802026:	89 e5                	mov    %esp,%ebp
  802028:	56                   	push   %esi
  802029:	53                   	push   %ebx
  80202a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80202d:	83 ec 0c             	sub    $0xc,%esp
  802030:	ff 75 08             	pushl  0x8(%ebp)
  802033:	e8 a8 ed ff ff       	call   800de0 <fd2data>
  802038:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80203a:	83 c4 08             	add    $0x8,%esp
  80203d:	68 3d 2e 80 00       	push   $0x802e3d
  802042:	53                   	push   %ebx
  802043:	e8 f1 e6 ff ff       	call   800739 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802048:	8b 46 04             	mov    0x4(%esi),%eax
  80204b:	2b 06                	sub    (%esi),%eax
  80204d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802053:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80205a:	00 00 00 
	stat->st_dev = &devpipe;
  80205d:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  802064:	30 80 00 
	return 0;
}
  802067:	b8 00 00 00 00       	mov    $0x0,%eax
  80206c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80206f:	5b                   	pop    %ebx
  802070:	5e                   	pop    %esi
  802071:	5d                   	pop    %ebp
  802072:	c3                   	ret    

00802073 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802073:	55                   	push   %ebp
  802074:	89 e5                	mov    %esp,%ebp
  802076:	53                   	push   %ebx
  802077:	83 ec 0c             	sub    $0xc,%esp
  80207a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80207d:	53                   	push   %ebx
  80207e:	6a 00                	push   $0x0
  802080:	e8 3c eb ff ff       	call   800bc1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802085:	89 1c 24             	mov    %ebx,(%esp)
  802088:	e8 53 ed ff ff       	call   800de0 <fd2data>
  80208d:	83 c4 08             	add    $0x8,%esp
  802090:	50                   	push   %eax
  802091:	6a 00                	push   $0x0
  802093:	e8 29 eb ff ff       	call   800bc1 <sys_page_unmap>
}
  802098:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80209b:	c9                   	leave  
  80209c:	c3                   	ret    

0080209d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80209d:	55                   	push   %ebp
  80209e:	89 e5                	mov    %esp,%ebp
  8020a0:	57                   	push   %edi
  8020a1:	56                   	push   %esi
  8020a2:	53                   	push   %ebx
  8020a3:	83 ec 1c             	sub    $0x1c,%esp
  8020a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8020a9:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8020ab:	a1 08 40 80 00       	mov    0x804008,%eax
  8020b0:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8020b3:	83 ec 0c             	sub    $0xc,%esp
  8020b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8020b9:	e8 3a 05 00 00       	call   8025f8 <pageref>
  8020be:	89 c3                	mov    %eax,%ebx
  8020c0:	89 3c 24             	mov    %edi,(%esp)
  8020c3:	e8 30 05 00 00       	call   8025f8 <pageref>
  8020c8:	83 c4 10             	add    $0x10,%esp
  8020cb:	39 c3                	cmp    %eax,%ebx
  8020cd:	0f 94 c1             	sete   %cl
  8020d0:	0f b6 c9             	movzbl %cl,%ecx
  8020d3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8020d6:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8020dc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8020df:	39 ce                	cmp    %ecx,%esi
  8020e1:	74 1b                	je     8020fe <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8020e3:	39 c3                	cmp    %eax,%ebx
  8020e5:	75 c4                	jne    8020ab <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8020e7:	8b 42 58             	mov    0x58(%edx),%eax
  8020ea:	ff 75 e4             	pushl  -0x1c(%ebp)
  8020ed:	50                   	push   %eax
  8020ee:	56                   	push   %esi
  8020ef:	68 44 2e 80 00       	push   $0x802e44
  8020f4:	e8 bb e0 ff ff       	call   8001b4 <cprintf>
  8020f9:	83 c4 10             	add    $0x10,%esp
  8020fc:	eb ad                	jmp    8020ab <_pipeisclosed+0xe>
	}
}
  8020fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802101:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802104:	5b                   	pop    %ebx
  802105:	5e                   	pop    %esi
  802106:	5f                   	pop    %edi
  802107:	5d                   	pop    %ebp
  802108:	c3                   	ret    

00802109 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802109:	55                   	push   %ebp
  80210a:	89 e5                	mov    %esp,%ebp
  80210c:	57                   	push   %edi
  80210d:	56                   	push   %esi
  80210e:	53                   	push   %ebx
  80210f:	83 ec 28             	sub    $0x28,%esp
  802112:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802115:	56                   	push   %esi
  802116:	e8 c5 ec ff ff       	call   800de0 <fd2data>
  80211b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80211d:	83 c4 10             	add    $0x10,%esp
  802120:	bf 00 00 00 00       	mov    $0x0,%edi
  802125:	eb 4b                	jmp    802172 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802127:	89 da                	mov    %ebx,%edx
  802129:	89 f0                	mov    %esi,%eax
  80212b:	e8 6d ff ff ff       	call   80209d <_pipeisclosed>
  802130:	85 c0                	test   %eax,%eax
  802132:	75 48                	jne    80217c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802134:	e8 e4 e9 ff ff       	call   800b1d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802139:	8b 43 04             	mov    0x4(%ebx),%eax
  80213c:	8b 0b                	mov    (%ebx),%ecx
  80213e:	8d 51 20             	lea    0x20(%ecx),%edx
  802141:	39 d0                	cmp    %edx,%eax
  802143:	73 e2                	jae    802127 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802145:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802148:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80214c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80214f:	89 c2                	mov    %eax,%edx
  802151:	c1 fa 1f             	sar    $0x1f,%edx
  802154:	89 d1                	mov    %edx,%ecx
  802156:	c1 e9 1b             	shr    $0x1b,%ecx
  802159:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80215c:	83 e2 1f             	and    $0x1f,%edx
  80215f:	29 ca                	sub    %ecx,%edx
  802161:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802165:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802169:	83 c0 01             	add    $0x1,%eax
  80216c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80216f:	83 c7 01             	add    $0x1,%edi
  802172:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802175:	75 c2                	jne    802139 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802177:	8b 45 10             	mov    0x10(%ebp),%eax
  80217a:	eb 05                	jmp    802181 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80217c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802181:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802184:	5b                   	pop    %ebx
  802185:	5e                   	pop    %esi
  802186:	5f                   	pop    %edi
  802187:	5d                   	pop    %ebp
  802188:	c3                   	ret    

00802189 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802189:	55                   	push   %ebp
  80218a:	89 e5                	mov    %esp,%ebp
  80218c:	57                   	push   %edi
  80218d:	56                   	push   %esi
  80218e:	53                   	push   %ebx
  80218f:	83 ec 18             	sub    $0x18,%esp
  802192:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802195:	57                   	push   %edi
  802196:	e8 45 ec ff ff       	call   800de0 <fd2data>
  80219b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80219d:	83 c4 10             	add    $0x10,%esp
  8021a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021a5:	eb 3d                	jmp    8021e4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8021a7:	85 db                	test   %ebx,%ebx
  8021a9:	74 04                	je     8021af <devpipe_read+0x26>
				return i;
  8021ab:	89 d8                	mov    %ebx,%eax
  8021ad:	eb 44                	jmp    8021f3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8021af:	89 f2                	mov    %esi,%edx
  8021b1:	89 f8                	mov    %edi,%eax
  8021b3:	e8 e5 fe ff ff       	call   80209d <_pipeisclosed>
  8021b8:	85 c0                	test   %eax,%eax
  8021ba:	75 32                	jne    8021ee <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8021bc:	e8 5c e9 ff ff       	call   800b1d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8021c1:	8b 06                	mov    (%esi),%eax
  8021c3:	3b 46 04             	cmp    0x4(%esi),%eax
  8021c6:	74 df                	je     8021a7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8021c8:	99                   	cltd   
  8021c9:	c1 ea 1b             	shr    $0x1b,%edx
  8021cc:	01 d0                	add    %edx,%eax
  8021ce:	83 e0 1f             	and    $0x1f,%eax
  8021d1:	29 d0                	sub    %edx,%eax
  8021d3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8021d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021db:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8021de:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021e1:	83 c3 01             	add    $0x1,%ebx
  8021e4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8021e7:	75 d8                	jne    8021c1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8021e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8021ec:	eb 05                	jmp    8021f3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8021ee:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8021f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021f6:	5b                   	pop    %ebx
  8021f7:	5e                   	pop    %esi
  8021f8:	5f                   	pop    %edi
  8021f9:	5d                   	pop    %ebp
  8021fa:	c3                   	ret    

008021fb <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8021fb:	55                   	push   %ebp
  8021fc:	89 e5                	mov    %esp,%ebp
  8021fe:	56                   	push   %esi
  8021ff:	53                   	push   %ebx
  802200:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802203:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802206:	50                   	push   %eax
  802207:	e8 eb eb ff ff       	call   800df7 <fd_alloc>
  80220c:	83 c4 10             	add    $0x10,%esp
  80220f:	89 c2                	mov    %eax,%edx
  802211:	85 c0                	test   %eax,%eax
  802213:	0f 88 2c 01 00 00    	js     802345 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802219:	83 ec 04             	sub    $0x4,%esp
  80221c:	68 07 04 00 00       	push   $0x407
  802221:	ff 75 f4             	pushl  -0xc(%ebp)
  802224:	6a 00                	push   $0x0
  802226:	e8 11 e9 ff ff       	call   800b3c <sys_page_alloc>
  80222b:	83 c4 10             	add    $0x10,%esp
  80222e:	89 c2                	mov    %eax,%edx
  802230:	85 c0                	test   %eax,%eax
  802232:	0f 88 0d 01 00 00    	js     802345 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802238:	83 ec 0c             	sub    $0xc,%esp
  80223b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80223e:	50                   	push   %eax
  80223f:	e8 b3 eb ff ff       	call   800df7 <fd_alloc>
  802244:	89 c3                	mov    %eax,%ebx
  802246:	83 c4 10             	add    $0x10,%esp
  802249:	85 c0                	test   %eax,%eax
  80224b:	0f 88 e2 00 00 00    	js     802333 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802251:	83 ec 04             	sub    $0x4,%esp
  802254:	68 07 04 00 00       	push   $0x407
  802259:	ff 75 f0             	pushl  -0x10(%ebp)
  80225c:	6a 00                	push   $0x0
  80225e:	e8 d9 e8 ff ff       	call   800b3c <sys_page_alloc>
  802263:	89 c3                	mov    %eax,%ebx
  802265:	83 c4 10             	add    $0x10,%esp
  802268:	85 c0                	test   %eax,%eax
  80226a:	0f 88 c3 00 00 00    	js     802333 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802270:	83 ec 0c             	sub    $0xc,%esp
  802273:	ff 75 f4             	pushl  -0xc(%ebp)
  802276:	e8 65 eb ff ff       	call   800de0 <fd2data>
  80227b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80227d:	83 c4 0c             	add    $0xc,%esp
  802280:	68 07 04 00 00       	push   $0x407
  802285:	50                   	push   %eax
  802286:	6a 00                	push   $0x0
  802288:	e8 af e8 ff ff       	call   800b3c <sys_page_alloc>
  80228d:	89 c3                	mov    %eax,%ebx
  80228f:	83 c4 10             	add    $0x10,%esp
  802292:	85 c0                	test   %eax,%eax
  802294:	0f 88 89 00 00 00    	js     802323 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80229a:	83 ec 0c             	sub    $0xc,%esp
  80229d:	ff 75 f0             	pushl  -0x10(%ebp)
  8022a0:	e8 3b eb ff ff       	call   800de0 <fd2data>
  8022a5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8022ac:	50                   	push   %eax
  8022ad:	6a 00                	push   $0x0
  8022af:	56                   	push   %esi
  8022b0:	6a 00                	push   $0x0
  8022b2:	e8 c8 e8 ff ff       	call   800b7f <sys_page_map>
  8022b7:	89 c3                	mov    %eax,%ebx
  8022b9:	83 c4 20             	add    $0x20,%esp
  8022bc:	85 c0                	test   %eax,%eax
  8022be:	78 55                	js     802315 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8022c0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022c9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8022cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ce:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8022d5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022de:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8022e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022e3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8022ea:	83 ec 0c             	sub    $0xc,%esp
  8022ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8022f0:	e8 db ea ff ff       	call   800dd0 <fd2num>
  8022f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022f8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8022fa:	83 c4 04             	add    $0x4,%esp
  8022fd:	ff 75 f0             	pushl  -0x10(%ebp)
  802300:	e8 cb ea ff ff       	call   800dd0 <fd2num>
  802305:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802308:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80230b:	83 c4 10             	add    $0x10,%esp
  80230e:	ba 00 00 00 00       	mov    $0x0,%edx
  802313:	eb 30                	jmp    802345 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802315:	83 ec 08             	sub    $0x8,%esp
  802318:	56                   	push   %esi
  802319:	6a 00                	push   $0x0
  80231b:	e8 a1 e8 ff ff       	call   800bc1 <sys_page_unmap>
  802320:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802323:	83 ec 08             	sub    $0x8,%esp
  802326:	ff 75 f0             	pushl  -0x10(%ebp)
  802329:	6a 00                	push   $0x0
  80232b:	e8 91 e8 ff ff       	call   800bc1 <sys_page_unmap>
  802330:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802333:	83 ec 08             	sub    $0x8,%esp
  802336:	ff 75 f4             	pushl  -0xc(%ebp)
  802339:	6a 00                	push   $0x0
  80233b:	e8 81 e8 ff ff       	call   800bc1 <sys_page_unmap>
  802340:	83 c4 10             	add    $0x10,%esp
  802343:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802345:	89 d0                	mov    %edx,%eax
  802347:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80234a:	5b                   	pop    %ebx
  80234b:	5e                   	pop    %esi
  80234c:	5d                   	pop    %ebp
  80234d:	c3                   	ret    

0080234e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80234e:	55                   	push   %ebp
  80234f:	89 e5                	mov    %esp,%ebp
  802351:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802354:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802357:	50                   	push   %eax
  802358:	ff 75 08             	pushl  0x8(%ebp)
  80235b:	e8 e6 ea ff ff       	call   800e46 <fd_lookup>
  802360:	83 c4 10             	add    $0x10,%esp
  802363:	85 c0                	test   %eax,%eax
  802365:	78 18                	js     80237f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802367:	83 ec 0c             	sub    $0xc,%esp
  80236a:	ff 75 f4             	pushl  -0xc(%ebp)
  80236d:	e8 6e ea ff ff       	call   800de0 <fd2data>
	return _pipeisclosed(fd, p);
  802372:	89 c2                	mov    %eax,%edx
  802374:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802377:	e8 21 fd ff ff       	call   80209d <_pipeisclosed>
  80237c:	83 c4 10             	add    $0x10,%esp
}
  80237f:	c9                   	leave  
  802380:	c3                   	ret    

00802381 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802381:	55                   	push   %ebp
  802382:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802384:	b8 00 00 00 00       	mov    $0x0,%eax
  802389:	5d                   	pop    %ebp
  80238a:	c3                   	ret    

0080238b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80238b:	55                   	push   %ebp
  80238c:	89 e5                	mov    %esp,%ebp
  80238e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802391:	68 5c 2e 80 00       	push   $0x802e5c
  802396:	ff 75 0c             	pushl  0xc(%ebp)
  802399:	e8 9b e3 ff ff       	call   800739 <strcpy>
	return 0;
}
  80239e:	b8 00 00 00 00       	mov    $0x0,%eax
  8023a3:	c9                   	leave  
  8023a4:	c3                   	ret    

008023a5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8023a5:	55                   	push   %ebp
  8023a6:	89 e5                	mov    %esp,%ebp
  8023a8:	57                   	push   %edi
  8023a9:	56                   	push   %esi
  8023aa:	53                   	push   %ebx
  8023ab:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023b1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023b6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023bc:	eb 2d                	jmp    8023eb <devcons_write+0x46>
		m = n - tot;
  8023be:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8023c1:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8023c3:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8023c6:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8023cb:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023ce:	83 ec 04             	sub    $0x4,%esp
  8023d1:	53                   	push   %ebx
  8023d2:	03 45 0c             	add    0xc(%ebp),%eax
  8023d5:	50                   	push   %eax
  8023d6:	57                   	push   %edi
  8023d7:	e8 ef e4 ff ff       	call   8008cb <memmove>
		sys_cputs(buf, m);
  8023dc:	83 c4 08             	add    $0x8,%esp
  8023df:	53                   	push   %ebx
  8023e0:	57                   	push   %edi
  8023e1:	e8 9a e6 ff ff       	call   800a80 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023e6:	01 de                	add    %ebx,%esi
  8023e8:	83 c4 10             	add    $0x10,%esp
  8023eb:	89 f0                	mov    %esi,%eax
  8023ed:	3b 75 10             	cmp    0x10(%ebp),%esi
  8023f0:	72 cc                	jb     8023be <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8023f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023f5:	5b                   	pop    %ebx
  8023f6:	5e                   	pop    %esi
  8023f7:	5f                   	pop    %edi
  8023f8:	5d                   	pop    %ebp
  8023f9:	c3                   	ret    

008023fa <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8023fa:	55                   	push   %ebp
  8023fb:	89 e5                	mov    %esp,%ebp
  8023fd:	83 ec 08             	sub    $0x8,%esp
  802400:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802405:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802409:	74 2a                	je     802435 <devcons_read+0x3b>
  80240b:	eb 05                	jmp    802412 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80240d:	e8 0b e7 ff ff       	call   800b1d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802412:	e8 87 e6 ff ff       	call   800a9e <sys_cgetc>
  802417:	85 c0                	test   %eax,%eax
  802419:	74 f2                	je     80240d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80241b:	85 c0                	test   %eax,%eax
  80241d:	78 16                	js     802435 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80241f:	83 f8 04             	cmp    $0x4,%eax
  802422:	74 0c                	je     802430 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802424:	8b 55 0c             	mov    0xc(%ebp),%edx
  802427:	88 02                	mov    %al,(%edx)
	return 1;
  802429:	b8 01 00 00 00       	mov    $0x1,%eax
  80242e:	eb 05                	jmp    802435 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802430:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802435:	c9                   	leave  
  802436:	c3                   	ret    

00802437 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802437:	55                   	push   %ebp
  802438:	89 e5                	mov    %esp,%ebp
  80243a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80243d:	8b 45 08             	mov    0x8(%ebp),%eax
  802440:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802443:	6a 01                	push   $0x1
  802445:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802448:	50                   	push   %eax
  802449:	e8 32 e6 ff ff       	call   800a80 <sys_cputs>
}
  80244e:	83 c4 10             	add    $0x10,%esp
  802451:	c9                   	leave  
  802452:	c3                   	ret    

00802453 <getchar>:

int
getchar(void)
{
  802453:	55                   	push   %ebp
  802454:	89 e5                	mov    %esp,%ebp
  802456:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802459:	6a 01                	push   $0x1
  80245b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80245e:	50                   	push   %eax
  80245f:	6a 00                	push   $0x0
  802461:	e8 46 ec ff ff       	call   8010ac <read>
	if (r < 0)
  802466:	83 c4 10             	add    $0x10,%esp
  802469:	85 c0                	test   %eax,%eax
  80246b:	78 0f                	js     80247c <getchar+0x29>
		return r;
	if (r < 1)
  80246d:	85 c0                	test   %eax,%eax
  80246f:	7e 06                	jle    802477 <getchar+0x24>
		return -E_EOF;
	return c;
  802471:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802475:	eb 05                	jmp    80247c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802477:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80247c:	c9                   	leave  
  80247d:	c3                   	ret    

0080247e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80247e:	55                   	push   %ebp
  80247f:	89 e5                	mov    %esp,%ebp
  802481:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802484:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802487:	50                   	push   %eax
  802488:	ff 75 08             	pushl  0x8(%ebp)
  80248b:	e8 b6 e9 ff ff       	call   800e46 <fd_lookup>
  802490:	83 c4 10             	add    $0x10,%esp
  802493:	85 c0                	test   %eax,%eax
  802495:	78 11                	js     8024a8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802497:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80249a:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8024a0:	39 10                	cmp    %edx,(%eax)
  8024a2:	0f 94 c0             	sete   %al
  8024a5:	0f b6 c0             	movzbl %al,%eax
}
  8024a8:	c9                   	leave  
  8024a9:	c3                   	ret    

008024aa <opencons>:

int
opencons(void)
{
  8024aa:	55                   	push   %ebp
  8024ab:	89 e5                	mov    %esp,%ebp
  8024ad:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8024b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024b3:	50                   	push   %eax
  8024b4:	e8 3e e9 ff ff       	call   800df7 <fd_alloc>
  8024b9:	83 c4 10             	add    $0x10,%esp
		return r;
  8024bc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8024be:	85 c0                	test   %eax,%eax
  8024c0:	78 3e                	js     802500 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024c2:	83 ec 04             	sub    $0x4,%esp
  8024c5:	68 07 04 00 00       	push   $0x407
  8024ca:	ff 75 f4             	pushl  -0xc(%ebp)
  8024cd:	6a 00                	push   $0x0
  8024cf:	e8 68 e6 ff ff       	call   800b3c <sys_page_alloc>
  8024d4:	83 c4 10             	add    $0x10,%esp
		return r;
  8024d7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024d9:	85 c0                	test   %eax,%eax
  8024db:	78 23                	js     802500 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8024dd:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8024e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024e6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8024e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024eb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8024f2:	83 ec 0c             	sub    $0xc,%esp
  8024f5:	50                   	push   %eax
  8024f6:	e8 d5 e8 ff ff       	call   800dd0 <fd2num>
  8024fb:	89 c2                	mov    %eax,%edx
  8024fd:	83 c4 10             	add    $0x10,%esp
}
  802500:	89 d0                	mov    %edx,%eax
  802502:	c9                   	leave  
  802503:	c3                   	ret    

00802504 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802504:	55                   	push   %ebp
  802505:	89 e5                	mov    %esp,%ebp
  802507:	56                   	push   %esi
  802508:	53                   	push   %ebx
  802509:	8b 75 08             	mov    0x8(%ebp),%esi
  80250c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80250f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802512:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802514:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802519:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  80251c:	83 ec 0c             	sub    $0xc,%esp
  80251f:	50                   	push   %eax
  802520:	e8 c7 e7 ff ff       	call   800cec <sys_ipc_recv>

	if (from_env_store != NULL)
  802525:	83 c4 10             	add    $0x10,%esp
  802528:	85 f6                	test   %esi,%esi
  80252a:	74 14                	je     802540 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  80252c:	ba 00 00 00 00       	mov    $0x0,%edx
  802531:	85 c0                	test   %eax,%eax
  802533:	78 09                	js     80253e <ipc_recv+0x3a>
  802535:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80253b:	8b 52 74             	mov    0x74(%edx),%edx
  80253e:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802540:	85 db                	test   %ebx,%ebx
  802542:	74 14                	je     802558 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802544:	ba 00 00 00 00       	mov    $0x0,%edx
  802549:	85 c0                	test   %eax,%eax
  80254b:	78 09                	js     802556 <ipc_recv+0x52>
  80254d:	8b 15 08 40 80 00    	mov    0x804008,%edx
  802553:	8b 52 78             	mov    0x78(%edx),%edx
  802556:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802558:	85 c0                	test   %eax,%eax
  80255a:	78 08                	js     802564 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  80255c:	a1 08 40 80 00       	mov    0x804008,%eax
  802561:	8b 40 70             	mov    0x70(%eax),%eax
}
  802564:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802567:	5b                   	pop    %ebx
  802568:	5e                   	pop    %esi
  802569:	5d                   	pop    %ebp
  80256a:	c3                   	ret    

0080256b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80256b:	55                   	push   %ebp
  80256c:	89 e5                	mov    %esp,%ebp
  80256e:	57                   	push   %edi
  80256f:	56                   	push   %esi
  802570:	53                   	push   %ebx
  802571:	83 ec 0c             	sub    $0xc,%esp
  802574:	8b 7d 08             	mov    0x8(%ebp),%edi
  802577:	8b 75 0c             	mov    0xc(%ebp),%esi
  80257a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  80257d:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  80257f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802584:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  802587:	ff 75 14             	pushl  0x14(%ebp)
  80258a:	53                   	push   %ebx
  80258b:	56                   	push   %esi
  80258c:	57                   	push   %edi
  80258d:	e8 37 e7 ff ff       	call   800cc9 <sys_ipc_try_send>

		if (err < 0) {
  802592:	83 c4 10             	add    $0x10,%esp
  802595:	85 c0                	test   %eax,%eax
  802597:	79 1e                	jns    8025b7 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802599:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80259c:	75 07                	jne    8025a5 <ipc_send+0x3a>
				sys_yield();
  80259e:	e8 7a e5 ff ff       	call   800b1d <sys_yield>
  8025a3:	eb e2                	jmp    802587 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8025a5:	50                   	push   %eax
  8025a6:	68 68 2e 80 00       	push   $0x802e68
  8025ab:	6a 49                	push   $0x49
  8025ad:	68 75 2e 80 00       	push   $0x802e75
  8025b2:	e8 24 db ff ff       	call   8000db <_panic>
		}

	} while (err < 0);

}
  8025b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025ba:	5b                   	pop    %ebx
  8025bb:	5e                   	pop    %esi
  8025bc:	5f                   	pop    %edi
  8025bd:	5d                   	pop    %ebp
  8025be:	c3                   	ret    

008025bf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8025bf:	55                   	push   %ebp
  8025c0:	89 e5                	mov    %esp,%ebp
  8025c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8025c5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8025ca:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8025cd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8025d3:	8b 52 50             	mov    0x50(%edx),%edx
  8025d6:	39 ca                	cmp    %ecx,%edx
  8025d8:	75 0d                	jne    8025e7 <ipc_find_env+0x28>
			return envs[i].env_id;
  8025da:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8025dd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8025e2:	8b 40 48             	mov    0x48(%eax),%eax
  8025e5:	eb 0f                	jmp    8025f6 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025e7:	83 c0 01             	add    $0x1,%eax
  8025ea:	3d 00 04 00 00       	cmp    $0x400,%eax
  8025ef:	75 d9                	jne    8025ca <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8025f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8025f6:	5d                   	pop    %ebp
  8025f7:	c3                   	ret    

008025f8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025f8:	55                   	push   %ebp
  8025f9:	89 e5                	mov    %esp,%ebp
  8025fb:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025fe:	89 d0                	mov    %edx,%eax
  802600:	c1 e8 16             	shr    $0x16,%eax
  802603:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80260a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80260f:	f6 c1 01             	test   $0x1,%cl
  802612:	74 1d                	je     802631 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802614:	c1 ea 0c             	shr    $0xc,%edx
  802617:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80261e:	f6 c2 01             	test   $0x1,%dl
  802621:	74 0e                	je     802631 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802623:	c1 ea 0c             	shr    $0xc,%edx
  802626:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80262d:	ef 
  80262e:	0f b7 c0             	movzwl %ax,%eax
}
  802631:	5d                   	pop    %ebp
  802632:	c3                   	ret    
  802633:	66 90                	xchg   %ax,%ax
  802635:	66 90                	xchg   %ax,%ax
  802637:	66 90                	xchg   %ax,%ax
  802639:	66 90                	xchg   %ax,%ax
  80263b:	66 90                	xchg   %ax,%ax
  80263d:	66 90                	xchg   %ax,%ax
  80263f:	90                   	nop

00802640 <__udivdi3>:
  802640:	55                   	push   %ebp
  802641:	57                   	push   %edi
  802642:	56                   	push   %esi
  802643:	53                   	push   %ebx
  802644:	83 ec 1c             	sub    $0x1c,%esp
  802647:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80264b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80264f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802653:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802657:	85 f6                	test   %esi,%esi
  802659:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80265d:	89 ca                	mov    %ecx,%edx
  80265f:	89 f8                	mov    %edi,%eax
  802661:	75 3d                	jne    8026a0 <__udivdi3+0x60>
  802663:	39 cf                	cmp    %ecx,%edi
  802665:	0f 87 c5 00 00 00    	ja     802730 <__udivdi3+0xf0>
  80266b:	85 ff                	test   %edi,%edi
  80266d:	89 fd                	mov    %edi,%ebp
  80266f:	75 0b                	jne    80267c <__udivdi3+0x3c>
  802671:	b8 01 00 00 00       	mov    $0x1,%eax
  802676:	31 d2                	xor    %edx,%edx
  802678:	f7 f7                	div    %edi
  80267a:	89 c5                	mov    %eax,%ebp
  80267c:	89 c8                	mov    %ecx,%eax
  80267e:	31 d2                	xor    %edx,%edx
  802680:	f7 f5                	div    %ebp
  802682:	89 c1                	mov    %eax,%ecx
  802684:	89 d8                	mov    %ebx,%eax
  802686:	89 cf                	mov    %ecx,%edi
  802688:	f7 f5                	div    %ebp
  80268a:	89 c3                	mov    %eax,%ebx
  80268c:	89 d8                	mov    %ebx,%eax
  80268e:	89 fa                	mov    %edi,%edx
  802690:	83 c4 1c             	add    $0x1c,%esp
  802693:	5b                   	pop    %ebx
  802694:	5e                   	pop    %esi
  802695:	5f                   	pop    %edi
  802696:	5d                   	pop    %ebp
  802697:	c3                   	ret    
  802698:	90                   	nop
  802699:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026a0:	39 ce                	cmp    %ecx,%esi
  8026a2:	77 74                	ja     802718 <__udivdi3+0xd8>
  8026a4:	0f bd fe             	bsr    %esi,%edi
  8026a7:	83 f7 1f             	xor    $0x1f,%edi
  8026aa:	0f 84 98 00 00 00    	je     802748 <__udivdi3+0x108>
  8026b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8026b5:	89 f9                	mov    %edi,%ecx
  8026b7:	89 c5                	mov    %eax,%ebp
  8026b9:	29 fb                	sub    %edi,%ebx
  8026bb:	d3 e6                	shl    %cl,%esi
  8026bd:	89 d9                	mov    %ebx,%ecx
  8026bf:	d3 ed                	shr    %cl,%ebp
  8026c1:	89 f9                	mov    %edi,%ecx
  8026c3:	d3 e0                	shl    %cl,%eax
  8026c5:	09 ee                	or     %ebp,%esi
  8026c7:	89 d9                	mov    %ebx,%ecx
  8026c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026cd:	89 d5                	mov    %edx,%ebp
  8026cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026d3:	d3 ed                	shr    %cl,%ebp
  8026d5:	89 f9                	mov    %edi,%ecx
  8026d7:	d3 e2                	shl    %cl,%edx
  8026d9:	89 d9                	mov    %ebx,%ecx
  8026db:	d3 e8                	shr    %cl,%eax
  8026dd:	09 c2                	or     %eax,%edx
  8026df:	89 d0                	mov    %edx,%eax
  8026e1:	89 ea                	mov    %ebp,%edx
  8026e3:	f7 f6                	div    %esi
  8026e5:	89 d5                	mov    %edx,%ebp
  8026e7:	89 c3                	mov    %eax,%ebx
  8026e9:	f7 64 24 0c          	mull   0xc(%esp)
  8026ed:	39 d5                	cmp    %edx,%ebp
  8026ef:	72 10                	jb     802701 <__udivdi3+0xc1>
  8026f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8026f5:	89 f9                	mov    %edi,%ecx
  8026f7:	d3 e6                	shl    %cl,%esi
  8026f9:	39 c6                	cmp    %eax,%esi
  8026fb:	73 07                	jae    802704 <__udivdi3+0xc4>
  8026fd:	39 d5                	cmp    %edx,%ebp
  8026ff:	75 03                	jne    802704 <__udivdi3+0xc4>
  802701:	83 eb 01             	sub    $0x1,%ebx
  802704:	31 ff                	xor    %edi,%edi
  802706:	89 d8                	mov    %ebx,%eax
  802708:	89 fa                	mov    %edi,%edx
  80270a:	83 c4 1c             	add    $0x1c,%esp
  80270d:	5b                   	pop    %ebx
  80270e:	5e                   	pop    %esi
  80270f:	5f                   	pop    %edi
  802710:	5d                   	pop    %ebp
  802711:	c3                   	ret    
  802712:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802718:	31 ff                	xor    %edi,%edi
  80271a:	31 db                	xor    %ebx,%ebx
  80271c:	89 d8                	mov    %ebx,%eax
  80271e:	89 fa                	mov    %edi,%edx
  802720:	83 c4 1c             	add    $0x1c,%esp
  802723:	5b                   	pop    %ebx
  802724:	5e                   	pop    %esi
  802725:	5f                   	pop    %edi
  802726:	5d                   	pop    %ebp
  802727:	c3                   	ret    
  802728:	90                   	nop
  802729:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802730:	89 d8                	mov    %ebx,%eax
  802732:	f7 f7                	div    %edi
  802734:	31 ff                	xor    %edi,%edi
  802736:	89 c3                	mov    %eax,%ebx
  802738:	89 d8                	mov    %ebx,%eax
  80273a:	89 fa                	mov    %edi,%edx
  80273c:	83 c4 1c             	add    $0x1c,%esp
  80273f:	5b                   	pop    %ebx
  802740:	5e                   	pop    %esi
  802741:	5f                   	pop    %edi
  802742:	5d                   	pop    %ebp
  802743:	c3                   	ret    
  802744:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802748:	39 ce                	cmp    %ecx,%esi
  80274a:	72 0c                	jb     802758 <__udivdi3+0x118>
  80274c:	31 db                	xor    %ebx,%ebx
  80274e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802752:	0f 87 34 ff ff ff    	ja     80268c <__udivdi3+0x4c>
  802758:	bb 01 00 00 00       	mov    $0x1,%ebx
  80275d:	e9 2a ff ff ff       	jmp    80268c <__udivdi3+0x4c>
  802762:	66 90                	xchg   %ax,%ax
  802764:	66 90                	xchg   %ax,%ax
  802766:	66 90                	xchg   %ax,%ax
  802768:	66 90                	xchg   %ax,%ax
  80276a:	66 90                	xchg   %ax,%ax
  80276c:	66 90                	xchg   %ax,%ax
  80276e:	66 90                	xchg   %ax,%ax

00802770 <__umoddi3>:
  802770:	55                   	push   %ebp
  802771:	57                   	push   %edi
  802772:	56                   	push   %esi
  802773:	53                   	push   %ebx
  802774:	83 ec 1c             	sub    $0x1c,%esp
  802777:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80277b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80277f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802783:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802787:	85 d2                	test   %edx,%edx
  802789:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80278d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802791:	89 f3                	mov    %esi,%ebx
  802793:	89 3c 24             	mov    %edi,(%esp)
  802796:	89 74 24 04          	mov    %esi,0x4(%esp)
  80279a:	75 1c                	jne    8027b8 <__umoddi3+0x48>
  80279c:	39 f7                	cmp    %esi,%edi
  80279e:	76 50                	jbe    8027f0 <__umoddi3+0x80>
  8027a0:	89 c8                	mov    %ecx,%eax
  8027a2:	89 f2                	mov    %esi,%edx
  8027a4:	f7 f7                	div    %edi
  8027a6:	89 d0                	mov    %edx,%eax
  8027a8:	31 d2                	xor    %edx,%edx
  8027aa:	83 c4 1c             	add    $0x1c,%esp
  8027ad:	5b                   	pop    %ebx
  8027ae:	5e                   	pop    %esi
  8027af:	5f                   	pop    %edi
  8027b0:	5d                   	pop    %ebp
  8027b1:	c3                   	ret    
  8027b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027b8:	39 f2                	cmp    %esi,%edx
  8027ba:	89 d0                	mov    %edx,%eax
  8027bc:	77 52                	ja     802810 <__umoddi3+0xa0>
  8027be:	0f bd ea             	bsr    %edx,%ebp
  8027c1:	83 f5 1f             	xor    $0x1f,%ebp
  8027c4:	75 5a                	jne    802820 <__umoddi3+0xb0>
  8027c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8027ca:	0f 82 e0 00 00 00    	jb     8028b0 <__umoddi3+0x140>
  8027d0:	39 0c 24             	cmp    %ecx,(%esp)
  8027d3:	0f 86 d7 00 00 00    	jbe    8028b0 <__umoddi3+0x140>
  8027d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8027dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8027e1:	83 c4 1c             	add    $0x1c,%esp
  8027e4:	5b                   	pop    %ebx
  8027e5:	5e                   	pop    %esi
  8027e6:	5f                   	pop    %edi
  8027e7:	5d                   	pop    %ebp
  8027e8:	c3                   	ret    
  8027e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027f0:	85 ff                	test   %edi,%edi
  8027f2:	89 fd                	mov    %edi,%ebp
  8027f4:	75 0b                	jne    802801 <__umoddi3+0x91>
  8027f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8027fb:	31 d2                	xor    %edx,%edx
  8027fd:	f7 f7                	div    %edi
  8027ff:	89 c5                	mov    %eax,%ebp
  802801:	89 f0                	mov    %esi,%eax
  802803:	31 d2                	xor    %edx,%edx
  802805:	f7 f5                	div    %ebp
  802807:	89 c8                	mov    %ecx,%eax
  802809:	f7 f5                	div    %ebp
  80280b:	89 d0                	mov    %edx,%eax
  80280d:	eb 99                	jmp    8027a8 <__umoddi3+0x38>
  80280f:	90                   	nop
  802810:	89 c8                	mov    %ecx,%eax
  802812:	89 f2                	mov    %esi,%edx
  802814:	83 c4 1c             	add    $0x1c,%esp
  802817:	5b                   	pop    %ebx
  802818:	5e                   	pop    %esi
  802819:	5f                   	pop    %edi
  80281a:	5d                   	pop    %ebp
  80281b:	c3                   	ret    
  80281c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802820:	8b 34 24             	mov    (%esp),%esi
  802823:	bf 20 00 00 00       	mov    $0x20,%edi
  802828:	89 e9                	mov    %ebp,%ecx
  80282a:	29 ef                	sub    %ebp,%edi
  80282c:	d3 e0                	shl    %cl,%eax
  80282e:	89 f9                	mov    %edi,%ecx
  802830:	89 f2                	mov    %esi,%edx
  802832:	d3 ea                	shr    %cl,%edx
  802834:	89 e9                	mov    %ebp,%ecx
  802836:	09 c2                	or     %eax,%edx
  802838:	89 d8                	mov    %ebx,%eax
  80283a:	89 14 24             	mov    %edx,(%esp)
  80283d:	89 f2                	mov    %esi,%edx
  80283f:	d3 e2                	shl    %cl,%edx
  802841:	89 f9                	mov    %edi,%ecx
  802843:	89 54 24 04          	mov    %edx,0x4(%esp)
  802847:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80284b:	d3 e8                	shr    %cl,%eax
  80284d:	89 e9                	mov    %ebp,%ecx
  80284f:	89 c6                	mov    %eax,%esi
  802851:	d3 e3                	shl    %cl,%ebx
  802853:	89 f9                	mov    %edi,%ecx
  802855:	89 d0                	mov    %edx,%eax
  802857:	d3 e8                	shr    %cl,%eax
  802859:	89 e9                	mov    %ebp,%ecx
  80285b:	09 d8                	or     %ebx,%eax
  80285d:	89 d3                	mov    %edx,%ebx
  80285f:	89 f2                	mov    %esi,%edx
  802861:	f7 34 24             	divl   (%esp)
  802864:	89 d6                	mov    %edx,%esi
  802866:	d3 e3                	shl    %cl,%ebx
  802868:	f7 64 24 04          	mull   0x4(%esp)
  80286c:	39 d6                	cmp    %edx,%esi
  80286e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802872:	89 d1                	mov    %edx,%ecx
  802874:	89 c3                	mov    %eax,%ebx
  802876:	72 08                	jb     802880 <__umoddi3+0x110>
  802878:	75 11                	jne    80288b <__umoddi3+0x11b>
  80287a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80287e:	73 0b                	jae    80288b <__umoddi3+0x11b>
  802880:	2b 44 24 04          	sub    0x4(%esp),%eax
  802884:	1b 14 24             	sbb    (%esp),%edx
  802887:	89 d1                	mov    %edx,%ecx
  802889:	89 c3                	mov    %eax,%ebx
  80288b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80288f:	29 da                	sub    %ebx,%edx
  802891:	19 ce                	sbb    %ecx,%esi
  802893:	89 f9                	mov    %edi,%ecx
  802895:	89 f0                	mov    %esi,%eax
  802897:	d3 e0                	shl    %cl,%eax
  802899:	89 e9                	mov    %ebp,%ecx
  80289b:	d3 ea                	shr    %cl,%edx
  80289d:	89 e9                	mov    %ebp,%ecx
  80289f:	d3 ee                	shr    %cl,%esi
  8028a1:	09 d0                	or     %edx,%eax
  8028a3:	89 f2                	mov    %esi,%edx
  8028a5:	83 c4 1c             	add    $0x1c,%esp
  8028a8:	5b                   	pop    %ebx
  8028a9:	5e                   	pop    %esi
  8028aa:	5f                   	pop    %edi
  8028ab:	5d                   	pop    %ebp
  8028ac:	c3                   	ret    
  8028ad:	8d 76 00             	lea    0x0(%esi),%esi
  8028b0:	29 f9                	sub    %edi,%ecx
  8028b2:	19 d6                	sbb    %edx,%esi
  8028b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028bc:	e9 18 ff ff ff       	jmp    8027d9 <__umoddi3+0x69>
