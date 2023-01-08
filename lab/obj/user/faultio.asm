
obj/user/faultio.debug:     file format elf32-i386


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
  80002c:	e8 44 00 00 00       	call   800075 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>
#include <inc/x86.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
  800039:	9c                   	pushf  
  80003a:	58                   	pop    %eax
        int x, r;
	int nsecs = 1;
	int secno = 0;
	int diskno = 1;

	if (read_eflags() & FL_IOPL_3)
  80003b:	f6 c4 30             	test   $0x30,%ah
  80003e:	74 18                	je     800058 <umain+0x25>
  800040:	9c                   	pushf  
  800041:	58                   	pop    %eax
		cprintf("eflags wrong, 0x%x\n", read_eflags() & FL_IOPL_3);
  800042:	83 ec 08             	sub    $0x8,%esp
  800045:	25 00 30 00 00       	and    $0x3000,%eax
  80004a:	50                   	push   %eax
  80004b:	68 60 22 80 00       	push   $0x802260
  800050:	e8 13 01 00 00       	call   800168 <cprintf>
  800055:	83 c4 10             	add    $0x10,%esp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800058:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80005d:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  800062:	ee                   	out    %al,(%dx)

	// this outb to select disk 1 should result in a general protection
	// fault, because user-level code shouldn't be able to use the io space.
	outb(0x1F6, 0xE0 | (1<<4));

        cprintf("%s: made it here --- bug\n");
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	68 74 22 80 00       	push   $0x802274
  80006b:	e8 f8 00 00 00       	call   800168 <cprintf>
}
  800070:	83 c4 10             	add    $0x10,%esp
  800073:	c9                   	leave  
  800074:	c3                   	ret    

00800075 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800075:	55                   	push   %ebp
  800076:	89 e5                	mov    %esp,%ebp
  800078:	56                   	push   %esi
  800079:	53                   	push   %ebx
  80007a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800080:	e8 2d 0a 00 00       	call   800ab2 <sys_getenvid>
  800085:	25 ff 03 00 00       	and    $0x3ff,%eax
  80008a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80008d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800092:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800097:	85 db                	test   %ebx,%ebx
  800099:	7e 07                	jle    8000a2 <libmain+0x2d>
		binaryname = argv[0];
  80009b:	8b 06                	mov    (%esi),%eax
  80009d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000a2:	83 ec 08             	sub    $0x8,%esp
  8000a5:	56                   	push   %esi
  8000a6:	53                   	push   %ebx
  8000a7:	e8 87 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ac:	e8 0a 00 00 00       	call   8000bb <exit>
}
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5d                   	pop    %ebp
  8000ba:	c3                   	ret    

008000bb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bb:	55                   	push   %ebp
  8000bc:	89 e5                	mov    %esp,%ebp
  8000be:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000c1:	e8 05 0e 00 00       	call   800ecb <close_all>
	sys_env_destroy(0);
  8000c6:	83 ec 0c             	sub    $0xc,%esp
  8000c9:	6a 00                	push   $0x0
  8000cb:	e8 a1 09 00 00       	call   800a71 <sys_env_destroy>
}
  8000d0:	83 c4 10             	add    $0x10,%esp
  8000d3:	c9                   	leave  
  8000d4:	c3                   	ret    

008000d5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d5:	55                   	push   %ebp
  8000d6:	89 e5                	mov    %esp,%ebp
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 04             	sub    $0x4,%esp
  8000dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000df:	8b 13                	mov    (%ebx),%edx
  8000e1:	8d 42 01             	lea    0x1(%edx),%eax
  8000e4:	89 03                	mov    %eax,(%ebx)
  8000e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000ed:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f2:	75 1a                	jne    80010e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000f4:	83 ec 08             	sub    $0x8,%esp
  8000f7:	68 ff 00 00 00       	push   $0xff
  8000fc:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ff:	50                   	push   %eax
  800100:	e8 2f 09 00 00       	call   800a34 <sys_cputs>
		b->idx = 0;
  800105:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80010b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80010e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800112:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800115:	c9                   	leave  
  800116:	c3                   	ret    

00800117 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800120:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800127:	00 00 00 
	b.cnt = 0;
  80012a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800131:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800134:	ff 75 0c             	pushl  0xc(%ebp)
  800137:	ff 75 08             	pushl  0x8(%ebp)
  80013a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800140:	50                   	push   %eax
  800141:	68 d5 00 80 00       	push   $0x8000d5
  800146:	e8 54 01 00 00       	call   80029f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014b:	83 c4 08             	add    $0x8,%esp
  80014e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800154:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80015a:	50                   	push   %eax
  80015b:	e8 d4 08 00 00       	call   800a34 <sys_cputs>

	return b.cnt;
}
  800160:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800166:	c9                   	leave  
  800167:	c3                   	ret    

00800168 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800171:	50                   	push   %eax
  800172:	ff 75 08             	pushl  0x8(%ebp)
  800175:	e8 9d ff ff ff       	call   800117 <vcprintf>
	va_end(ap);

	return cnt;
}
  80017a:	c9                   	leave  
  80017b:	c3                   	ret    

0080017c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	57                   	push   %edi
  800180:	56                   	push   %esi
  800181:	53                   	push   %ebx
  800182:	83 ec 1c             	sub    $0x1c,%esp
  800185:	89 c7                	mov    %eax,%edi
  800187:	89 d6                	mov    %edx,%esi
  800189:	8b 45 08             	mov    0x8(%ebp),%eax
  80018c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800192:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800195:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800198:	bb 00 00 00 00       	mov    $0x0,%ebx
  80019d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001a0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001a3:	39 d3                	cmp    %edx,%ebx
  8001a5:	72 05                	jb     8001ac <printnum+0x30>
  8001a7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001aa:	77 45                	ja     8001f1 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ac:	83 ec 0c             	sub    $0xc,%esp
  8001af:	ff 75 18             	pushl  0x18(%ebp)
  8001b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8001b5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001b8:	53                   	push   %ebx
  8001b9:	ff 75 10             	pushl  0x10(%ebp)
  8001bc:	83 ec 08             	sub    $0x8,%esp
  8001bf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001c2:	ff 75 e0             	pushl  -0x20(%ebp)
  8001c5:	ff 75 dc             	pushl  -0x24(%ebp)
  8001c8:	ff 75 d8             	pushl  -0x28(%ebp)
  8001cb:	e8 f0 1d 00 00       	call   801fc0 <__udivdi3>
  8001d0:	83 c4 18             	add    $0x18,%esp
  8001d3:	52                   	push   %edx
  8001d4:	50                   	push   %eax
  8001d5:	89 f2                	mov    %esi,%edx
  8001d7:	89 f8                	mov    %edi,%eax
  8001d9:	e8 9e ff ff ff       	call   80017c <printnum>
  8001de:	83 c4 20             	add    $0x20,%esp
  8001e1:	eb 18                	jmp    8001fb <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001e3:	83 ec 08             	sub    $0x8,%esp
  8001e6:	56                   	push   %esi
  8001e7:	ff 75 18             	pushl  0x18(%ebp)
  8001ea:	ff d7                	call   *%edi
  8001ec:	83 c4 10             	add    $0x10,%esp
  8001ef:	eb 03                	jmp    8001f4 <printnum+0x78>
  8001f1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001f4:	83 eb 01             	sub    $0x1,%ebx
  8001f7:	85 db                	test   %ebx,%ebx
  8001f9:	7f e8                	jg     8001e3 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001fb:	83 ec 08             	sub    $0x8,%esp
  8001fe:	56                   	push   %esi
  8001ff:	83 ec 04             	sub    $0x4,%esp
  800202:	ff 75 e4             	pushl  -0x1c(%ebp)
  800205:	ff 75 e0             	pushl  -0x20(%ebp)
  800208:	ff 75 dc             	pushl  -0x24(%ebp)
  80020b:	ff 75 d8             	pushl  -0x28(%ebp)
  80020e:	e8 dd 1e 00 00       	call   8020f0 <__umoddi3>
  800213:	83 c4 14             	add    $0x14,%esp
  800216:	0f be 80 98 22 80 00 	movsbl 0x802298(%eax),%eax
  80021d:	50                   	push   %eax
  80021e:	ff d7                	call   *%edi
}
  800220:	83 c4 10             	add    $0x10,%esp
  800223:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800226:	5b                   	pop    %ebx
  800227:	5e                   	pop    %esi
  800228:	5f                   	pop    %edi
  800229:	5d                   	pop    %ebp
  80022a:	c3                   	ret    

0080022b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80022e:	83 fa 01             	cmp    $0x1,%edx
  800231:	7e 0e                	jle    800241 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800233:	8b 10                	mov    (%eax),%edx
  800235:	8d 4a 08             	lea    0x8(%edx),%ecx
  800238:	89 08                	mov    %ecx,(%eax)
  80023a:	8b 02                	mov    (%edx),%eax
  80023c:	8b 52 04             	mov    0x4(%edx),%edx
  80023f:	eb 22                	jmp    800263 <getuint+0x38>
	else if (lflag)
  800241:	85 d2                	test   %edx,%edx
  800243:	74 10                	je     800255 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800245:	8b 10                	mov    (%eax),%edx
  800247:	8d 4a 04             	lea    0x4(%edx),%ecx
  80024a:	89 08                	mov    %ecx,(%eax)
  80024c:	8b 02                	mov    (%edx),%eax
  80024e:	ba 00 00 00 00       	mov    $0x0,%edx
  800253:	eb 0e                	jmp    800263 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800255:	8b 10                	mov    (%eax),%edx
  800257:	8d 4a 04             	lea    0x4(%edx),%ecx
  80025a:	89 08                	mov    %ecx,(%eax)
  80025c:	8b 02                	mov    (%edx),%eax
  80025e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800263:	5d                   	pop    %ebp
  800264:	c3                   	ret    

00800265 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800265:	55                   	push   %ebp
  800266:	89 e5                	mov    %esp,%ebp
  800268:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80026b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80026f:	8b 10                	mov    (%eax),%edx
  800271:	3b 50 04             	cmp    0x4(%eax),%edx
  800274:	73 0a                	jae    800280 <sprintputch+0x1b>
		*b->buf++ = ch;
  800276:	8d 4a 01             	lea    0x1(%edx),%ecx
  800279:	89 08                	mov    %ecx,(%eax)
  80027b:	8b 45 08             	mov    0x8(%ebp),%eax
  80027e:	88 02                	mov    %al,(%edx)
}
  800280:	5d                   	pop    %ebp
  800281:	c3                   	ret    

00800282 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800288:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80028b:	50                   	push   %eax
  80028c:	ff 75 10             	pushl  0x10(%ebp)
  80028f:	ff 75 0c             	pushl  0xc(%ebp)
  800292:	ff 75 08             	pushl  0x8(%ebp)
  800295:	e8 05 00 00 00       	call   80029f <vprintfmt>
	va_end(ap);
}
  80029a:	83 c4 10             	add    $0x10,%esp
  80029d:	c9                   	leave  
  80029e:	c3                   	ret    

0080029f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80029f:	55                   	push   %ebp
  8002a0:	89 e5                	mov    %esp,%ebp
  8002a2:	57                   	push   %edi
  8002a3:	56                   	push   %esi
  8002a4:	53                   	push   %ebx
  8002a5:	83 ec 2c             	sub    $0x2c,%esp
  8002a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8002ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ae:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002b1:	eb 12                	jmp    8002c5 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002b3:	85 c0                	test   %eax,%eax
  8002b5:	0f 84 89 03 00 00    	je     800644 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002bb:	83 ec 08             	sub    $0x8,%esp
  8002be:	53                   	push   %ebx
  8002bf:	50                   	push   %eax
  8002c0:	ff d6                	call   *%esi
  8002c2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002c5:	83 c7 01             	add    $0x1,%edi
  8002c8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002cc:	83 f8 25             	cmp    $0x25,%eax
  8002cf:	75 e2                	jne    8002b3 <vprintfmt+0x14>
  8002d1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002d5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002dc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002e3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ef:	eb 07                	jmp    8002f8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002f4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f8:	8d 47 01             	lea    0x1(%edi),%eax
  8002fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002fe:	0f b6 07             	movzbl (%edi),%eax
  800301:	0f b6 c8             	movzbl %al,%ecx
  800304:	83 e8 23             	sub    $0x23,%eax
  800307:	3c 55                	cmp    $0x55,%al
  800309:	0f 87 1a 03 00 00    	ja     800629 <vprintfmt+0x38a>
  80030f:	0f b6 c0             	movzbl %al,%eax
  800312:	ff 24 85 e0 23 80 00 	jmp    *0x8023e0(,%eax,4)
  800319:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80031c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800320:	eb d6                	jmp    8002f8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800322:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800325:	b8 00 00 00 00       	mov    $0x0,%eax
  80032a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80032d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800330:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800334:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800337:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80033a:	83 fa 09             	cmp    $0x9,%edx
  80033d:	77 39                	ja     800378 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80033f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800342:	eb e9                	jmp    80032d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800344:	8b 45 14             	mov    0x14(%ebp),%eax
  800347:	8d 48 04             	lea    0x4(%eax),%ecx
  80034a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80034d:	8b 00                	mov    (%eax),%eax
  80034f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800352:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800355:	eb 27                	jmp    80037e <vprintfmt+0xdf>
  800357:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80035a:	85 c0                	test   %eax,%eax
  80035c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800361:	0f 49 c8             	cmovns %eax,%ecx
  800364:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800367:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036a:	eb 8c                	jmp    8002f8 <vprintfmt+0x59>
  80036c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80036f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800376:	eb 80                	jmp    8002f8 <vprintfmt+0x59>
  800378:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80037b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80037e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800382:	0f 89 70 ff ff ff    	jns    8002f8 <vprintfmt+0x59>
				width = precision, precision = -1;
  800388:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80038b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80038e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800395:	e9 5e ff ff ff       	jmp    8002f8 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80039a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003a0:	e9 53 ff ff ff       	jmp    8002f8 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a8:	8d 50 04             	lea    0x4(%eax),%edx
  8003ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ae:	83 ec 08             	sub    $0x8,%esp
  8003b1:	53                   	push   %ebx
  8003b2:	ff 30                	pushl  (%eax)
  8003b4:	ff d6                	call   *%esi
			break;
  8003b6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003bc:	e9 04 ff ff ff       	jmp    8002c5 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c4:	8d 50 04             	lea    0x4(%eax),%edx
  8003c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ca:	8b 00                	mov    (%eax),%eax
  8003cc:	99                   	cltd   
  8003cd:	31 d0                	xor    %edx,%eax
  8003cf:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d1:	83 f8 0f             	cmp    $0xf,%eax
  8003d4:	7f 0b                	jg     8003e1 <vprintfmt+0x142>
  8003d6:	8b 14 85 40 25 80 00 	mov    0x802540(,%eax,4),%edx
  8003dd:	85 d2                	test   %edx,%edx
  8003df:	75 18                	jne    8003f9 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003e1:	50                   	push   %eax
  8003e2:	68 b0 22 80 00       	push   $0x8022b0
  8003e7:	53                   	push   %ebx
  8003e8:	56                   	push   %esi
  8003e9:	e8 94 fe ff ff       	call   800282 <printfmt>
  8003ee:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003f4:	e9 cc fe ff ff       	jmp    8002c5 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003f9:	52                   	push   %edx
  8003fa:	68 75 26 80 00       	push   $0x802675
  8003ff:	53                   	push   %ebx
  800400:	56                   	push   %esi
  800401:	e8 7c fe ff ff       	call   800282 <printfmt>
  800406:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80040c:	e9 b4 fe ff ff       	jmp    8002c5 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800411:	8b 45 14             	mov    0x14(%ebp),%eax
  800414:	8d 50 04             	lea    0x4(%eax),%edx
  800417:	89 55 14             	mov    %edx,0x14(%ebp)
  80041a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80041c:	85 ff                	test   %edi,%edi
  80041e:	b8 a9 22 80 00       	mov    $0x8022a9,%eax
  800423:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800426:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042a:	0f 8e 94 00 00 00    	jle    8004c4 <vprintfmt+0x225>
  800430:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800434:	0f 84 98 00 00 00    	je     8004d2 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80043a:	83 ec 08             	sub    $0x8,%esp
  80043d:	ff 75 d0             	pushl  -0x30(%ebp)
  800440:	57                   	push   %edi
  800441:	e8 86 02 00 00       	call   8006cc <strnlen>
  800446:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800449:	29 c1                	sub    %eax,%ecx
  80044b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80044e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800451:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800455:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800458:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80045b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80045d:	eb 0f                	jmp    80046e <vprintfmt+0x1cf>
					putch(padc, putdat);
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	53                   	push   %ebx
  800463:	ff 75 e0             	pushl  -0x20(%ebp)
  800466:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800468:	83 ef 01             	sub    $0x1,%edi
  80046b:	83 c4 10             	add    $0x10,%esp
  80046e:	85 ff                	test   %edi,%edi
  800470:	7f ed                	jg     80045f <vprintfmt+0x1c0>
  800472:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800475:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800478:	85 c9                	test   %ecx,%ecx
  80047a:	b8 00 00 00 00       	mov    $0x0,%eax
  80047f:	0f 49 c1             	cmovns %ecx,%eax
  800482:	29 c1                	sub    %eax,%ecx
  800484:	89 75 08             	mov    %esi,0x8(%ebp)
  800487:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80048a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80048d:	89 cb                	mov    %ecx,%ebx
  80048f:	eb 4d                	jmp    8004de <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800491:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800495:	74 1b                	je     8004b2 <vprintfmt+0x213>
  800497:	0f be c0             	movsbl %al,%eax
  80049a:	83 e8 20             	sub    $0x20,%eax
  80049d:	83 f8 5e             	cmp    $0x5e,%eax
  8004a0:	76 10                	jbe    8004b2 <vprintfmt+0x213>
					putch('?', putdat);
  8004a2:	83 ec 08             	sub    $0x8,%esp
  8004a5:	ff 75 0c             	pushl  0xc(%ebp)
  8004a8:	6a 3f                	push   $0x3f
  8004aa:	ff 55 08             	call   *0x8(%ebp)
  8004ad:	83 c4 10             	add    $0x10,%esp
  8004b0:	eb 0d                	jmp    8004bf <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	ff 75 0c             	pushl  0xc(%ebp)
  8004b8:	52                   	push   %edx
  8004b9:	ff 55 08             	call   *0x8(%ebp)
  8004bc:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004bf:	83 eb 01             	sub    $0x1,%ebx
  8004c2:	eb 1a                	jmp    8004de <vprintfmt+0x23f>
  8004c4:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ca:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004cd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004d0:	eb 0c                	jmp    8004de <vprintfmt+0x23f>
  8004d2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004db:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004de:	83 c7 01             	add    $0x1,%edi
  8004e1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004e5:	0f be d0             	movsbl %al,%edx
  8004e8:	85 d2                	test   %edx,%edx
  8004ea:	74 23                	je     80050f <vprintfmt+0x270>
  8004ec:	85 f6                	test   %esi,%esi
  8004ee:	78 a1                	js     800491 <vprintfmt+0x1f2>
  8004f0:	83 ee 01             	sub    $0x1,%esi
  8004f3:	79 9c                	jns    800491 <vprintfmt+0x1f2>
  8004f5:	89 df                	mov    %ebx,%edi
  8004f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004fd:	eb 18                	jmp    800517 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004ff:	83 ec 08             	sub    $0x8,%esp
  800502:	53                   	push   %ebx
  800503:	6a 20                	push   $0x20
  800505:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800507:	83 ef 01             	sub    $0x1,%edi
  80050a:	83 c4 10             	add    $0x10,%esp
  80050d:	eb 08                	jmp    800517 <vprintfmt+0x278>
  80050f:	89 df                	mov    %ebx,%edi
  800511:	8b 75 08             	mov    0x8(%ebp),%esi
  800514:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800517:	85 ff                	test   %edi,%edi
  800519:	7f e4                	jg     8004ff <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80051e:	e9 a2 fd ff ff       	jmp    8002c5 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800523:	83 fa 01             	cmp    $0x1,%edx
  800526:	7e 16                	jle    80053e <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800528:	8b 45 14             	mov    0x14(%ebp),%eax
  80052b:	8d 50 08             	lea    0x8(%eax),%edx
  80052e:	89 55 14             	mov    %edx,0x14(%ebp)
  800531:	8b 50 04             	mov    0x4(%eax),%edx
  800534:	8b 00                	mov    (%eax),%eax
  800536:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800539:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80053c:	eb 32                	jmp    800570 <vprintfmt+0x2d1>
	else if (lflag)
  80053e:	85 d2                	test   %edx,%edx
  800540:	74 18                	je     80055a <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8d 50 04             	lea    0x4(%eax),%edx
  800548:	89 55 14             	mov    %edx,0x14(%ebp)
  80054b:	8b 00                	mov    (%eax),%eax
  80054d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800550:	89 c1                	mov    %eax,%ecx
  800552:	c1 f9 1f             	sar    $0x1f,%ecx
  800555:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800558:	eb 16                	jmp    800570 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8d 50 04             	lea    0x4(%eax),%edx
  800560:	89 55 14             	mov    %edx,0x14(%ebp)
  800563:	8b 00                	mov    (%eax),%eax
  800565:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800568:	89 c1                	mov    %eax,%ecx
  80056a:	c1 f9 1f             	sar    $0x1f,%ecx
  80056d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800570:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800573:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800576:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80057b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80057f:	79 74                	jns    8005f5 <vprintfmt+0x356>
				putch('-', putdat);
  800581:	83 ec 08             	sub    $0x8,%esp
  800584:	53                   	push   %ebx
  800585:	6a 2d                	push   $0x2d
  800587:	ff d6                	call   *%esi
				num = -(long long) num;
  800589:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80058c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80058f:	f7 d8                	neg    %eax
  800591:	83 d2 00             	adc    $0x0,%edx
  800594:	f7 da                	neg    %edx
  800596:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800599:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80059e:	eb 55                	jmp    8005f5 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a3:	e8 83 fc ff ff       	call   80022b <getuint>
			base = 10;
  8005a8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005ad:	eb 46                	jmp    8005f5 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8005af:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b2:	e8 74 fc ff ff       	call   80022b <getuint>
			base = 8;
  8005b7:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005bc:	eb 37                	jmp    8005f5 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	53                   	push   %ebx
  8005c2:	6a 30                	push   $0x30
  8005c4:	ff d6                	call   *%esi
			putch('x', putdat);
  8005c6:	83 c4 08             	add    $0x8,%esp
  8005c9:	53                   	push   %ebx
  8005ca:	6a 78                	push   $0x78
  8005cc:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8d 50 04             	lea    0x4(%eax),%edx
  8005d4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005d7:	8b 00                	mov    (%eax),%eax
  8005d9:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005de:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005e1:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005e6:	eb 0d                	jmp    8005f5 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005e8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005eb:	e8 3b fc ff ff       	call   80022b <getuint>
			base = 16;
  8005f0:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005f5:	83 ec 0c             	sub    $0xc,%esp
  8005f8:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005fc:	57                   	push   %edi
  8005fd:	ff 75 e0             	pushl  -0x20(%ebp)
  800600:	51                   	push   %ecx
  800601:	52                   	push   %edx
  800602:	50                   	push   %eax
  800603:	89 da                	mov    %ebx,%edx
  800605:	89 f0                	mov    %esi,%eax
  800607:	e8 70 fb ff ff       	call   80017c <printnum>
			break;
  80060c:	83 c4 20             	add    $0x20,%esp
  80060f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800612:	e9 ae fc ff ff       	jmp    8002c5 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	53                   	push   %ebx
  80061b:	51                   	push   %ecx
  80061c:	ff d6                	call   *%esi
			break;
  80061e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800621:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800624:	e9 9c fc ff ff       	jmp    8002c5 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	53                   	push   %ebx
  80062d:	6a 25                	push   $0x25
  80062f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800631:	83 c4 10             	add    $0x10,%esp
  800634:	eb 03                	jmp    800639 <vprintfmt+0x39a>
  800636:	83 ef 01             	sub    $0x1,%edi
  800639:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80063d:	75 f7                	jne    800636 <vprintfmt+0x397>
  80063f:	e9 81 fc ff ff       	jmp    8002c5 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800644:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800647:	5b                   	pop    %ebx
  800648:	5e                   	pop    %esi
  800649:	5f                   	pop    %edi
  80064a:	5d                   	pop    %ebp
  80064b:	c3                   	ret    

0080064c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80064c:	55                   	push   %ebp
  80064d:	89 e5                	mov    %esp,%ebp
  80064f:	83 ec 18             	sub    $0x18,%esp
  800652:	8b 45 08             	mov    0x8(%ebp),%eax
  800655:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800658:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80065b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80065f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800662:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800669:	85 c0                	test   %eax,%eax
  80066b:	74 26                	je     800693 <vsnprintf+0x47>
  80066d:	85 d2                	test   %edx,%edx
  80066f:	7e 22                	jle    800693 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800671:	ff 75 14             	pushl  0x14(%ebp)
  800674:	ff 75 10             	pushl  0x10(%ebp)
  800677:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80067a:	50                   	push   %eax
  80067b:	68 65 02 80 00       	push   $0x800265
  800680:	e8 1a fc ff ff       	call   80029f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800685:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800688:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80068b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068e:	83 c4 10             	add    $0x10,%esp
  800691:	eb 05                	jmp    800698 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800693:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800698:	c9                   	leave  
  800699:	c3                   	ret    

0080069a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80069a:	55                   	push   %ebp
  80069b:	89 e5                	mov    %esp,%ebp
  80069d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006a0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006a3:	50                   	push   %eax
  8006a4:	ff 75 10             	pushl  0x10(%ebp)
  8006a7:	ff 75 0c             	pushl  0xc(%ebp)
  8006aa:	ff 75 08             	pushl  0x8(%ebp)
  8006ad:	e8 9a ff ff ff       	call   80064c <vsnprintf>
	va_end(ap);

	return rc;
}
  8006b2:	c9                   	leave  
  8006b3:	c3                   	ret    

008006b4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bf:	eb 03                	jmp    8006c4 <strlen+0x10>
		n++;
  8006c1:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006c8:	75 f7                	jne    8006c1 <strlen+0xd>
		n++;
	return n;
}
  8006ca:	5d                   	pop    %ebp
  8006cb:	c3                   	ret    

008006cc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006cc:	55                   	push   %ebp
  8006cd:	89 e5                	mov    %esp,%ebp
  8006cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006d2:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8006da:	eb 03                	jmp    8006df <strnlen+0x13>
		n++;
  8006dc:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006df:	39 c2                	cmp    %eax,%edx
  8006e1:	74 08                	je     8006eb <strnlen+0x1f>
  8006e3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006e7:	75 f3                	jne    8006dc <strnlen+0x10>
  8006e9:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006eb:	5d                   	pop    %ebp
  8006ec:	c3                   	ret    

008006ed <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006ed:	55                   	push   %ebp
  8006ee:	89 e5                	mov    %esp,%ebp
  8006f0:	53                   	push   %ebx
  8006f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006f7:	89 c2                	mov    %eax,%edx
  8006f9:	83 c2 01             	add    $0x1,%edx
  8006fc:	83 c1 01             	add    $0x1,%ecx
  8006ff:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800703:	88 5a ff             	mov    %bl,-0x1(%edx)
  800706:	84 db                	test   %bl,%bl
  800708:	75 ef                	jne    8006f9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80070a:	5b                   	pop    %ebx
  80070b:	5d                   	pop    %ebp
  80070c:	c3                   	ret    

0080070d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	53                   	push   %ebx
  800711:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800714:	53                   	push   %ebx
  800715:	e8 9a ff ff ff       	call   8006b4 <strlen>
  80071a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80071d:	ff 75 0c             	pushl  0xc(%ebp)
  800720:	01 d8                	add    %ebx,%eax
  800722:	50                   	push   %eax
  800723:	e8 c5 ff ff ff       	call   8006ed <strcpy>
	return dst;
}
  800728:	89 d8                	mov    %ebx,%eax
  80072a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80072d:	c9                   	leave  
  80072e:	c3                   	ret    

0080072f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
  800732:	56                   	push   %esi
  800733:	53                   	push   %ebx
  800734:	8b 75 08             	mov    0x8(%ebp),%esi
  800737:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80073a:	89 f3                	mov    %esi,%ebx
  80073c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80073f:	89 f2                	mov    %esi,%edx
  800741:	eb 0f                	jmp    800752 <strncpy+0x23>
		*dst++ = *src;
  800743:	83 c2 01             	add    $0x1,%edx
  800746:	0f b6 01             	movzbl (%ecx),%eax
  800749:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80074c:	80 39 01             	cmpb   $0x1,(%ecx)
  80074f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800752:	39 da                	cmp    %ebx,%edx
  800754:	75 ed                	jne    800743 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800756:	89 f0                	mov    %esi,%eax
  800758:	5b                   	pop    %ebx
  800759:	5e                   	pop    %esi
  80075a:	5d                   	pop    %ebp
  80075b:	c3                   	ret    

0080075c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	56                   	push   %esi
  800760:	53                   	push   %ebx
  800761:	8b 75 08             	mov    0x8(%ebp),%esi
  800764:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800767:	8b 55 10             	mov    0x10(%ebp),%edx
  80076a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80076c:	85 d2                	test   %edx,%edx
  80076e:	74 21                	je     800791 <strlcpy+0x35>
  800770:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800774:	89 f2                	mov    %esi,%edx
  800776:	eb 09                	jmp    800781 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800778:	83 c2 01             	add    $0x1,%edx
  80077b:	83 c1 01             	add    $0x1,%ecx
  80077e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800781:	39 c2                	cmp    %eax,%edx
  800783:	74 09                	je     80078e <strlcpy+0x32>
  800785:	0f b6 19             	movzbl (%ecx),%ebx
  800788:	84 db                	test   %bl,%bl
  80078a:	75 ec                	jne    800778 <strlcpy+0x1c>
  80078c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80078e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800791:	29 f0                	sub    %esi,%eax
}
  800793:	5b                   	pop    %ebx
  800794:	5e                   	pop    %esi
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007a0:	eb 06                	jmp    8007a8 <strcmp+0x11>
		p++, q++;
  8007a2:	83 c1 01             	add    $0x1,%ecx
  8007a5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007a8:	0f b6 01             	movzbl (%ecx),%eax
  8007ab:	84 c0                	test   %al,%al
  8007ad:	74 04                	je     8007b3 <strcmp+0x1c>
  8007af:	3a 02                	cmp    (%edx),%al
  8007b1:	74 ef                	je     8007a2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007b3:	0f b6 c0             	movzbl %al,%eax
  8007b6:	0f b6 12             	movzbl (%edx),%edx
  8007b9:	29 d0                	sub    %edx,%eax
}
  8007bb:	5d                   	pop    %ebp
  8007bc:	c3                   	ret    

008007bd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	53                   	push   %ebx
  8007c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c7:	89 c3                	mov    %eax,%ebx
  8007c9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007cc:	eb 06                	jmp    8007d4 <strncmp+0x17>
		n--, p++, q++;
  8007ce:	83 c0 01             	add    $0x1,%eax
  8007d1:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007d4:	39 d8                	cmp    %ebx,%eax
  8007d6:	74 15                	je     8007ed <strncmp+0x30>
  8007d8:	0f b6 08             	movzbl (%eax),%ecx
  8007db:	84 c9                	test   %cl,%cl
  8007dd:	74 04                	je     8007e3 <strncmp+0x26>
  8007df:	3a 0a                	cmp    (%edx),%cl
  8007e1:	74 eb                	je     8007ce <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e3:	0f b6 00             	movzbl (%eax),%eax
  8007e6:	0f b6 12             	movzbl (%edx),%edx
  8007e9:	29 d0                	sub    %edx,%eax
  8007eb:	eb 05                	jmp    8007f2 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007ed:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007f2:	5b                   	pop    %ebx
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    

008007f5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007ff:	eb 07                	jmp    800808 <strchr+0x13>
		if (*s == c)
  800801:	38 ca                	cmp    %cl,%dl
  800803:	74 0f                	je     800814 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800805:	83 c0 01             	add    $0x1,%eax
  800808:	0f b6 10             	movzbl (%eax),%edx
  80080b:	84 d2                	test   %dl,%dl
  80080d:	75 f2                	jne    800801 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80080f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	8b 45 08             	mov    0x8(%ebp),%eax
  80081c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800820:	eb 03                	jmp    800825 <strfind+0xf>
  800822:	83 c0 01             	add    $0x1,%eax
  800825:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800828:	38 ca                	cmp    %cl,%dl
  80082a:	74 04                	je     800830 <strfind+0x1a>
  80082c:	84 d2                	test   %dl,%dl
  80082e:	75 f2                	jne    800822 <strfind+0xc>
			break;
	return (char *) s;
}
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	57                   	push   %edi
  800836:	56                   	push   %esi
  800837:	53                   	push   %ebx
  800838:	8b 7d 08             	mov    0x8(%ebp),%edi
  80083b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80083e:	85 c9                	test   %ecx,%ecx
  800840:	74 36                	je     800878 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800842:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800848:	75 28                	jne    800872 <memset+0x40>
  80084a:	f6 c1 03             	test   $0x3,%cl
  80084d:	75 23                	jne    800872 <memset+0x40>
		c &= 0xFF;
  80084f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800853:	89 d3                	mov    %edx,%ebx
  800855:	c1 e3 08             	shl    $0x8,%ebx
  800858:	89 d6                	mov    %edx,%esi
  80085a:	c1 e6 18             	shl    $0x18,%esi
  80085d:	89 d0                	mov    %edx,%eax
  80085f:	c1 e0 10             	shl    $0x10,%eax
  800862:	09 f0                	or     %esi,%eax
  800864:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800866:	89 d8                	mov    %ebx,%eax
  800868:	09 d0                	or     %edx,%eax
  80086a:	c1 e9 02             	shr    $0x2,%ecx
  80086d:	fc                   	cld    
  80086e:	f3 ab                	rep stos %eax,%es:(%edi)
  800870:	eb 06                	jmp    800878 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800872:	8b 45 0c             	mov    0xc(%ebp),%eax
  800875:	fc                   	cld    
  800876:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800878:	89 f8                	mov    %edi,%eax
  80087a:	5b                   	pop    %ebx
  80087b:	5e                   	pop    %esi
  80087c:	5f                   	pop    %edi
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	57                   	push   %edi
  800883:	56                   	push   %esi
  800884:	8b 45 08             	mov    0x8(%ebp),%eax
  800887:	8b 75 0c             	mov    0xc(%ebp),%esi
  80088a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80088d:	39 c6                	cmp    %eax,%esi
  80088f:	73 35                	jae    8008c6 <memmove+0x47>
  800891:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800894:	39 d0                	cmp    %edx,%eax
  800896:	73 2e                	jae    8008c6 <memmove+0x47>
		s += n;
		d += n;
  800898:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80089b:	89 d6                	mov    %edx,%esi
  80089d:	09 fe                	or     %edi,%esi
  80089f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008a5:	75 13                	jne    8008ba <memmove+0x3b>
  8008a7:	f6 c1 03             	test   $0x3,%cl
  8008aa:	75 0e                	jne    8008ba <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008ac:	83 ef 04             	sub    $0x4,%edi
  8008af:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008b2:	c1 e9 02             	shr    $0x2,%ecx
  8008b5:	fd                   	std    
  8008b6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008b8:	eb 09                	jmp    8008c3 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008ba:	83 ef 01             	sub    $0x1,%edi
  8008bd:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008c0:	fd                   	std    
  8008c1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008c3:	fc                   	cld    
  8008c4:	eb 1d                	jmp    8008e3 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c6:	89 f2                	mov    %esi,%edx
  8008c8:	09 c2                	or     %eax,%edx
  8008ca:	f6 c2 03             	test   $0x3,%dl
  8008cd:	75 0f                	jne    8008de <memmove+0x5f>
  8008cf:	f6 c1 03             	test   $0x3,%cl
  8008d2:	75 0a                	jne    8008de <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008d4:	c1 e9 02             	shr    $0x2,%ecx
  8008d7:	89 c7                	mov    %eax,%edi
  8008d9:	fc                   	cld    
  8008da:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008dc:	eb 05                	jmp    8008e3 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008de:	89 c7                	mov    %eax,%edi
  8008e0:	fc                   	cld    
  8008e1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008e3:	5e                   	pop    %esi
  8008e4:	5f                   	pop    %edi
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008ea:	ff 75 10             	pushl  0x10(%ebp)
  8008ed:	ff 75 0c             	pushl  0xc(%ebp)
  8008f0:	ff 75 08             	pushl  0x8(%ebp)
  8008f3:	e8 87 ff ff ff       	call   80087f <memmove>
}
  8008f8:	c9                   	leave  
  8008f9:	c3                   	ret    

008008fa <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	56                   	push   %esi
  8008fe:	53                   	push   %ebx
  8008ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800902:	8b 55 0c             	mov    0xc(%ebp),%edx
  800905:	89 c6                	mov    %eax,%esi
  800907:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80090a:	eb 1a                	jmp    800926 <memcmp+0x2c>
		if (*s1 != *s2)
  80090c:	0f b6 08             	movzbl (%eax),%ecx
  80090f:	0f b6 1a             	movzbl (%edx),%ebx
  800912:	38 d9                	cmp    %bl,%cl
  800914:	74 0a                	je     800920 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800916:	0f b6 c1             	movzbl %cl,%eax
  800919:	0f b6 db             	movzbl %bl,%ebx
  80091c:	29 d8                	sub    %ebx,%eax
  80091e:	eb 0f                	jmp    80092f <memcmp+0x35>
		s1++, s2++;
  800920:	83 c0 01             	add    $0x1,%eax
  800923:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800926:	39 f0                	cmp    %esi,%eax
  800928:	75 e2                	jne    80090c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80092a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80092f:	5b                   	pop    %ebx
  800930:	5e                   	pop    %esi
  800931:	5d                   	pop    %ebp
  800932:	c3                   	ret    

00800933 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	53                   	push   %ebx
  800937:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80093a:	89 c1                	mov    %eax,%ecx
  80093c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80093f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800943:	eb 0a                	jmp    80094f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800945:	0f b6 10             	movzbl (%eax),%edx
  800948:	39 da                	cmp    %ebx,%edx
  80094a:	74 07                	je     800953 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80094c:	83 c0 01             	add    $0x1,%eax
  80094f:	39 c8                	cmp    %ecx,%eax
  800951:	72 f2                	jb     800945 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800953:	5b                   	pop    %ebx
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	57                   	push   %edi
  80095a:	56                   	push   %esi
  80095b:	53                   	push   %ebx
  80095c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800962:	eb 03                	jmp    800967 <strtol+0x11>
		s++;
  800964:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800967:	0f b6 01             	movzbl (%ecx),%eax
  80096a:	3c 20                	cmp    $0x20,%al
  80096c:	74 f6                	je     800964 <strtol+0xe>
  80096e:	3c 09                	cmp    $0x9,%al
  800970:	74 f2                	je     800964 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800972:	3c 2b                	cmp    $0x2b,%al
  800974:	75 0a                	jne    800980 <strtol+0x2a>
		s++;
  800976:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800979:	bf 00 00 00 00       	mov    $0x0,%edi
  80097e:	eb 11                	jmp    800991 <strtol+0x3b>
  800980:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800985:	3c 2d                	cmp    $0x2d,%al
  800987:	75 08                	jne    800991 <strtol+0x3b>
		s++, neg = 1;
  800989:	83 c1 01             	add    $0x1,%ecx
  80098c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800991:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800997:	75 15                	jne    8009ae <strtol+0x58>
  800999:	80 39 30             	cmpb   $0x30,(%ecx)
  80099c:	75 10                	jne    8009ae <strtol+0x58>
  80099e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009a2:	75 7c                	jne    800a20 <strtol+0xca>
		s += 2, base = 16;
  8009a4:	83 c1 02             	add    $0x2,%ecx
  8009a7:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009ac:	eb 16                	jmp    8009c4 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009ae:	85 db                	test   %ebx,%ebx
  8009b0:	75 12                	jne    8009c4 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009b2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009b7:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ba:	75 08                	jne    8009c4 <strtol+0x6e>
		s++, base = 8;
  8009bc:	83 c1 01             	add    $0x1,%ecx
  8009bf:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009cc:	0f b6 11             	movzbl (%ecx),%edx
  8009cf:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009d2:	89 f3                	mov    %esi,%ebx
  8009d4:	80 fb 09             	cmp    $0x9,%bl
  8009d7:	77 08                	ja     8009e1 <strtol+0x8b>
			dig = *s - '0';
  8009d9:	0f be d2             	movsbl %dl,%edx
  8009dc:	83 ea 30             	sub    $0x30,%edx
  8009df:	eb 22                	jmp    800a03 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009e1:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009e4:	89 f3                	mov    %esi,%ebx
  8009e6:	80 fb 19             	cmp    $0x19,%bl
  8009e9:	77 08                	ja     8009f3 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009eb:	0f be d2             	movsbl %dl,%edx
  8009ee:	83 ea 57             	sub    $0x57,%edx
  8009f1:	eb 10                	jmp    800a03 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009f3:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009f6:	89 f3                	mov    %esi,%ebx
  8009f8:	80 fb 19             	cmp    $0x19,%bl
  8009fb:	77 16                	ja     800a13 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8009fd:	0f be d2             	movsbl %dl,%edx
  800a00:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a03:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a06:	7d 0b                	jge    800a13 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a08:	83 c1 01             	add    $0x1,%ecx
  800a0b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a0f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a11:	eb b9                	jmp    8009cc <strtol+0x76>

	if (endptr)
  800a13:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a17:	74 0d                	je     800a26 <strtol+0xd0>
		*endptr = (char *) s;
  800a19:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1c:	89 0e                	mov    %ecx,(%esi)
  800a1e:	eb 06                	jmp    800a26 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a20:	85 db                	test   %ebx,%ebx
  800a22:	74 98                	je     8009bc <strtol+0x66>
  800a24:	eb 9e                	jmp    8009c4 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a26:	89 c2                	mov    %eax,%edx
  800a28:	f7 da                	neg    %edx
  800a2a:	85 ff                	test   %edi,%edi
  800a2c:	0f 45 c2             	cmovne %edx,%eax
}
  800a2f:	5b                   	pop    %ebx
  800a30:	5e                   	pop    %esi
  800a31:	5f                   	pop    %edi
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	57                   	push   %edi
  800a38:	56                   	push   %esi
  800a39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a42:	8b 55 08             	mov    0x8(%ebp),%edx
  800a45:	89 c3                	mov    %eax,%ebx
  800a47:	89 c7                	mov    %eax,%edi
  800a49:	89 c6                	mov    %eax,%esi
  800a4b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a4d:	5b                   	pop    %ebx
  800a4e:	5e                   	pop    %esi
  800a4f:	5f                   	pop    %edi
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	57                   	push   %edi
  800a56:	56                   	push   %esi
  800a57:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a58:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5d:	b8 01 00 00 00       	mov    $0x1,%eax
  800a62:	89 d1                	mov    %edx,%ecx
  800a64:	89 d3                	mov    %edx,%ebx
  800a66:	89 d7                	mov    %edx,%edi
  800a68:	89 d6                	mov    %edx,%esi
  800a6a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a6c:	5b                   	pop    %ebx
  800a6d:	5e                   	pop    %esi
  800a6e:	5f                   	pop    %edi
  800a6f:	5d                   	pop    %ebp
  800a70:	c3                   	ret    

00800a71 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	57                   	push   %edi
  800a75:	56                   	push   %esi
  800a76:	53                   	push   %ebx
  800a77:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a7f:	b8 03 00 00 00       	mov    $0x3,%eax
  800a84:	8b 55 08             	mov    0x8(%ebp),%edx
  800a87:	89 cb                	mov    %ecx,%ebx
  800a89:	89 cf                	mov    %ecx,%edi
  800a8b:	89 ce                	mov    %ecx,%esi
  800a8d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a8f:	85 c0                	test   %eax,%eax
  800a91:	7e 17                	jle    800aaa <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a93:	83 ec 0c             	sub    $0xc,%esp
  800a96:	50                   	push   %eax
  800a97:	6a 03                	push   $0x3
  800a99:	68 9f 25 80 00       	push   $0x80259f
  800a9e:	6a 23                	push   $0x23
  800aa0:	68 bc 25 80 00       	push   $0x8025bc
  800aa5:	e8 9a 13 00 00       	call   801e44 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aaa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aad:	5b                   	pop    %ebx
  800aae:	5e                   	pop    %esi
  800aaf:	5f                   	pop    %edi
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	57                   	push   %edi
  800ab6:	56                   	push   %esi
  800ab7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab8:	ba 00 00 00 00       	mov    $0x0,%edx
  800abd:	b8 02 00 00 00       	mov    $0x2,%eax
  800ac2:	89 d1                	mov    %edx,%ecx
  800ac4:	89 d3                	mov    %edx,%ebx
  800ac6:	89 d7                	mov    %edx,%edi
  800ac8:	89 d6                	mov    %edx,%esi
  800aca:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5f                   	pop    %edi
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <sys_yield>:

void
sys_yield(void)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	57                   	push   %edi
  800ad5:	56                   	push   %esi
  800ad6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad7:	ba 00 00 00 00       	mov    $0x0,%edx
  800adc:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ae1:	89 d1                	mov    %edx,%ecx
  800ae3:	89 d3                	mov    %edx,%ebx
  800ae5:	89 d7                	mov    %edx,%edi
  800ae7:	89 d6                	mov    %edx,%esi
  800ae9:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800aeb:	5b                   	pop    %ebx
  800aec:	5e                   	pop    %esi
  800aed:	5f                   	pop    %edi
  800aee:	5d                   	pop    %ebp
  800aef:	c3                   	ret    

00800af0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	57                   	push   %edi
  800af4:	56                   	push   %esi
  800af5:	53                   	push   %ebx
  800af6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af9:	be 00 00 00 00       	mov    $0x0,%esi
  800afe:	b8 04 00 00 00       	mov    $0x4,%eax
  800b03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b06:	8b 55 08             	mov    0x8(%ebp),%edx
  800b09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b0c:	89 f7                	mov    %esi,%edi
  800b0e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b10:	85 c0                	test   %eax,%eax
  800b12:	7e 17                	jle    800b2b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b14:	83 ec 0c             	sub    $0xc,%esp
  800b17:	50                   	push   %eax
  800b18:	6a 04                	push   $0x4
  800b1a:	68 9f 25 80 00       	push   $0x80259f
  800b1f:	6a 23                	push   $0x23
  800b21:	68 bc 25 80 00       	push   $0x8025bc
  800b26:	e8 19 13 00 00       	call   801e44 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b2e:	5b                   	pop    %ebx
  800b2f:	5e                   	pop    %esi
  800b30:	5f                   	pop    %edi
  800b31:	5d                   	pop    %ebp
  800b32:	c3                   	ret    

00800b33 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	57                   	push   %edi
  800b37:	56                   	push   %esi
  800b38:	53                   	push   %ebx
  800b39:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3c:	b8 05 00 00 00       	mov    $0x5,%eax
  800b41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b44:	8b 55 08             	mov    0x8(%ebp),%edx
  800b47:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b4a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b4d:	8b 75 18             	mov    0x18(%ebp),%esi
  800b50:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b52:	85 c0                	test   %eax,%eax
  800b54:	7e 17                	jle    800b6d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b56:	83 ec 0c             	sub    $0xc,%esp
  800b59:	50                   	push   %eax
  800b5a:	6a 05                	push   $0x5
  800b5c:	68 9f 25 80 00       	push   $0x80259f
  800b61:	6a 23                	push   $0x23
  800b63:	68 bc 25 80 00       	push   $0x8025bc
  800b68:	e8 d7 12 00 00       	call   801e44 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
  800b7b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b83:	b8 06 00 00 00       	mov    $0x6,%eax
  800b88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8e:	89 df                	mov    %ebx,%edi
  800b90:	89 de                	mov    %ebx,%esi
  800b92:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b94:	85 c0                	test   %eax,%eax
  800b96:	7e 17                	jle    800baf <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b98:	83 ec 0c             	sub    $0xc,%esp
  800b9b:	50                   	push   %eax
  800b9c:	6a 06                	push   $0x6
  800b9e:	68 9f 25 80 00       	push   $0x80259f
  800ba3:	6a 23                	push   $0x23
  800ba5:	68 bc 25 80 00       	push   $0x8025bc
  800baa:	e8 95 12 00 00       	call   801e44 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800baf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	57                   	push   %edi
  800bbb:	56                   	push   %esi
  800bbc:	53                   	push   %ebx
  800bbd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bc5:	b8 08 00 00 00       	mov    $0x8,%eax
  800bca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd0:	89 df                	mov    %ebx,%edi
  800bd2:	89 de                	mov    %ebx,%esi
  800bd4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd6:	85 c0                	test   %eax,%eax
  800bd8:	7e 17                	jle    800bf1 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bda:	83 ec 0c             	sub    $0xc,%esp
  800bdd:	50                   	push   %eax
  800bde:	6a 08                	push   $0x8
  800be0:	68 9f 25 80 00       	push   $0x80259f
  800be5:	6a 23                	push   $0x23
  800be7:	68 bc 25 80 00       	push   $0x8025bc
  800bec:	e8 53 12 00 00       	call   801e44 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
  800bff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c07:	b8 09 00 00 00       	mov    $0x9,%eax
  800c0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c12:	89 df                	mov    %ebx,%edi
  800c14:	89 de                	mov    %ebx,%esi
  800c16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c18:	85 c0                	test   %eax,%eax
  800c1a:	7e 17                	jle    800c33 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1c:	83 ec 0c             	sub    $0xc,%esp
  800c1f:	50                   	push   %eax
  800c20:	6a 09                	push   $0x9
  800c22:	68 9f 25 80 00       	push   $0x80259f
  800c27:	6a 23                	push   $0x23
  800c29:	68 bc 25 80 00       	push   $0x8025bc
  800c2e:	e8 11 12 00 00       	call   801e44 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c44:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c49:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c51:	8b 55 08             	mov    0x8(%ebp),%edx
  800c54:	89 df                	mov    %ebx,%edi
  800c56:	89 de                	mov    %ebx,%esi
  800c58:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5a:	85 c0                	test   %eax,%eax
  800c5c:	7e 17                	jle    800c75 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5e:	83 ec 0c             	sub    $0xc,%esp
  800c61:	50                   	push   %eax
  800c62:	6a 0a                	push   $0xa
  800c64:	68 9f 25 80 00       	push   $0x80259f
  800c69:	6a 23                	push   $0x23
  800c6b:	68 bc 25 80 00       	push   $0x8025bc
  800c70:	e8 cf 11 00 00       	call   801e44 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	57                   	push   %edi
  800c81:	56                   	push   %esi
  800c82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c83:	be 00 00 00 00       	mov    $0x0,%esi
  800c88:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c90:	8b 55 08             	mov    0x8(%ebp),%edx
  800c93:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c96:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c99:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    

00800ca0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	57                   	push   %edi
  800ca4:	56                   	push   %esi
  800ca5:	53                   	push   %ebx
  800ca6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cae:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb6:	89 cb                	mov    %ecx,%ebx
  800cb8:	89 cf                	mov    %ecx,%edi
  800cba:	89 ce                	mov    %ecx,%esi
  800cbc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbe:	85 c0                	test   %eax,%eax
  800cc0:	7e 17                	jle    800cd9 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc2:	83 ec 0c             	sub    $0xc,%esp
  800cc5:	50                   	push   %eax
  800cc6:	6a 0d                	push   $0xd
  800cc8:	68 9f 25 80 00       	push   $0x80259f
  800ccd:	6a 23                	push   $0x23
  800ccf:	68 bc 25 80 00       	push   $0x8025bc
  800cd4:	e8 6b 11 00 00       	call   801e44 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdc:	5b                   	pop    %ebx
  800cdd:	5e                   	pop    %esi
  800cde:	5f                   	pop    %edi
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    

00800ce1 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	57                   	push   %edi
  800ce5:	56                   	push   %esi
  800ce6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce7:	ba 00 00 00 00       	mov    $0x0,%edx
  800cec:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cf1:	89 d1                	mov    %edx,%ecx
  800cf3:	89 d3                	mov    %edx,%ebx
  800cf5:	89 d7                	mov    %edx,%edi
  800cf7:	89 d6                	mov    %edx,%esi
  800cf9:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d03:	8b 45 08             	mov    0x8(%ebp),%eax
  800d06:	05 00 00 00 30       	add    $0x30000000,%eax
  800d0b:	c1 e8 0c             	shr    $0xc,%eax
}
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d13:	8b 45 08             	mov    0x8(%ebp),%eax
  800d16:	05 00 00 00 30       	add    $0x30000000,%eax
  800d1b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d20:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d2d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d32:	89 c2                	mov    %eax,%edx
  800d34:	c1 ea 16             	shr    $0x16,%edx
  800d37:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d3e:	f6 c2 01             	test   $0x1,%dl
  800d41:	74 11                	je     800d54 <fd_alloc+0x2d>
  800d43:	89 c2                	mov    %eax,%edx
  800d45:	c1 ea 0c             	shr    $0xc,%edx
  800d48:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d4f:	f6 c2 01             	test   $0x1,%dl
  800d52:	75 09                	jne    800d5d <fd_alloc+0x36>
			*fd_store = fd;
  800d54:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d56:	b8 00 00 00 00       	mov    $0x0,%eax
  800d5b:	eb 17                	jmp    800d74 <fd_alloc+0x4d>
  800d5d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d62:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d67:	75 c9                	jne    800d32 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d69:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d6f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d74:	5d                   	pop    %ebp
  800d75:	c3                   	ret    

00800d76 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d76:	55                   	push   %ebp
  800d77:	89 e5                	mov    %esp,%ebp
  800d79:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d7c:	83 f8 1f             	cmp    $0x1f,%eax
  800d7f:	77 36                	ja     800db7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d81:	c1 e0 0c             	shl    $0xc,%eax
  800d84:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d89:	89 c2                	mov    %eax,%edx
  800d8b:	c1 ea 16             	shr    $0x16,%edx
  800d8e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d95:	f6 c2 01             	test   $0x1,%dl
  800d98:	74 24                	je     800dbe <fd_lookup+0x48>
  800d9a:	89 c2                	mov    %eax,%edx
  800d9c:	c1 ea 0c             	shr    $0xc,%edx
  800d9f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800da6:	f6 c2 01             	test   $0x1,%dl
  800da9:	74 1a                	je     800dc5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dab:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dae:	89 02                	mov    %eax,(%edx)
	return 0;
  800db0:	b8 00 00 00 00       	mov    $0x0,%eax
  800db5:	eb 13                	jmp    800dca <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800db7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dbc:	eb 0c                	jmp    800dca <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dbe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dc3:	eb 05                	jmp    800dca <fd_lookup+0x54>
  800dc5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	83 ec 08             	sub    $0x8,%esp
  800dd2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd5:	ba 48 26 80 00       	mov    $0x802648,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800dda:	eb 13                	jmp    800def <dev_lookup+0x23>
  800ddc:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ddf:	39 08                	cmp    %ecx,(%eax)
  800de1:	75 0c                	jne    800def <dev_lookup+0x23>
			*dev = devtab[i];
  800de3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de6:	89 01                	mov    %eax,(%ecx)
			return 0;
  800de8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ded:	eb 2e                	jmp    800e1d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800def:	8b 02                	mov    (%edx),%eax
  800df1:	85 c0                	test   %eax,%eax
  800df3:	75 e7                	jne    800ddc <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800df5:	a1 08 40 80 00       	mov    0x804008,%eax
  800dfa:	8b 40 48             	mov    0x48(%eax),%eax
  800dfd:	83 ec 04             	sub    $0x4,%esp
  800e00:	51                   	push   %ecx
  800e01:	50                   	push   %eax
  800e02:	68 cc 25 80 00       	push   $0x8025cc
  800e07:	e8 5c f3 ff ff       	call   800168 <cprintf>
	*dev = 0;
  800e0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e0f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e15:	83 c4 10             	add    $0x10,%esp
  800e18:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e1d:	c9                   	leave  
  800e1e:	c3                   	ret    

00800e1f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	56                   	push   %esi
  800e23:	53                   	push   %ebx
  800e24:	83 ec 10             	sub    $0x10,%esp
  800e27:	8b 75 08             	mov    0x8(%ebp),%esi
  800e2a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e30:	50                   	push   %eax
  800e31:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e37:	c1 e8 0c             	shr    $0xc,%eax
  800e3a:	50                   	push   %eax
  800e3b:	e8 36 ff ff ff       	call   800d76 <fd_lookup>
  800e40:	83 c4 08             	add    $0x8,%esp
  800e43:	85 c0                	test   %eax,%eax
  800e45:	78 05                	js     800e4c <fd_close+0x2d>
	    || fd != fd2)
  800e47:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e4a:	74 0c                	je     800e58 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e4c:	84 db                	test   %bl,%bl
  800e4e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e53:	0f 44 c2             	cmove  %edx,%eax
  800e56:	eb 41                	jmp    800e99 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e58:	83 ec 08             	sub    $0x8,%esp
  800e5b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e5e:	50                   	push   %eax
  800e5f:	ff 36                	pushl  (%esi)
  800e61:	e8 66 ff ff ff       	call   800dcc <dev_lookup>
  800e66:	89 c3                	mov    %eax,%ebx
  800e68:	83 c4 10             	add    $0x10,%esp
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	78 1a                	js     800e89 <fd_close+0x6a>
		if (dev->dev_close)
  800e6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e72:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e75:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e7a:	85 c0                	test   %eax,%eax
  800e7c:	74 0b                	je     800e89 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e7e:	83 ec 0c             	sub    $0xc,%esp
  800e81:	56                   	push   %esi
  800e82:	ff d0                	call   *%eax
  800e84:	89 c3                	mov    %eax,%ebx
  800e86:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e89:	83 ec 08             	sub    $0x8,%esp
  800e8c:	56                   	push   %esi
  800e8d:	6a 00                	push   $0x0
  800e8f:	e8 e1 fc ff ff       	call   800b75 <sys_page_unmap>
	return r;
  800e94:	83 c4 10             	add    $0x10,%esp
  800e97:	89 d8                	mov    %ebx,%eax
}
  800e99:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e9c:	5b                   	pop    %ebx
  800e9d:	5e                   	pop    %esi
  800e9e:	5d                   	pop    %ebp
  800e9f:	c3                   	ret    

00800ea0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ea6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ea9:	50                   	push   %eax
  800eaa:	ff 75 08             	pushl  0x8(%ebp)
  800ead:	e8 c4 fe ff ff       	call   800d76 <fd_lookup>
  800eb2:	83 c4 08             	add    $0x8,%esp
  800eb5:	85 c0                	test   %eax,%eax
  800eb7:	78 10                	js     800ec9 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800eb9:	83 ec 08             	sub    $0x8,%esp
  800ebc:	6a 01                	push   $0x1
  800ebe:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec1:	e8 59 ff ff ff       	call   800e1f <fd_close>
  800ec6:	83 c4 10             	add    $0x10,%esp
}
  800ec9:	c9                   	leave  
  800eca:	c3                   	ret    

00800ecb <close_all>:

void
close_all(void)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	53                   	push   %ebx
  800ecf:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ed2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ed7:	83 ec 0c             	sub    $0xc,%esp
  800eda:	53                   	push   %ebx
  800edb:	e8 c0 ff ff ff       	call   800ea0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ee0:	83 c3 01             	add    $0x1,%ebx
  800ee3:	83 c4 10             	add    $0x10,%esp
  800ee6:	83 fb 20             	cmp    $0x20,%ebx
  800ee9:	75 ec                	jne    800ed7 <close_all+0xc>
		close(i);
}
  800eeb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eee:	c9                   	leave  
  800eef:	c3                   	ret    

00800ef0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	57                   	push   %edi
  800ef4:	56                   	push   %esi
  800ef5:	53                   	push   %ebx
  800ef6:	83 ec 2c             	sub    $0x2c,%esp
  800ef9:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800efc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800eff:	50                   	push   %eax
  800f00:	ff 75 08             	pushl  0x8(%ebp)
  800f03:	e8 6e fe ff ff       	call   800d76 <fd_lookup>
  800f08:	83 c4 08             	add    $0x8,%esp
  800f0b:	85 c0                	test   %eax,%eax
  800f0d:	0f 88 c1 00 00 00    	js     800fd4 <dup+0xe4>
		return r;
	close(newfdnum);
  800f13:	83 ec 0c             	sub    $0xc,%esp
  800f16:	56                   	push   %esi
  800f17:	e8 84 ff ff ff       	call   800ea0 <close>

	newfd = INDEX2FD(newfdnum);
  800f1c:	89 f3                	mov    %esi,%ebx
  800f1e:	c1 e3 0c             	shl    $0xc,%ebx
  800f21:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f27:	83 c4 04             	add    $0x4,%esp
  800f2a:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f2d:	e8 de fd ff ff       	call   800d10 <fd2data>
  800f32:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f34:	89 1c 24             	mov    %ebx,(%esp)
  800f37:	e8 d4 fd ff ff       	call   800d10 <fd2data>
  800f3c:	83 c4 10             	add    $0x10,%esp
  800f3f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f42:	89 f8                	mov    %edi,%eax
  800f44:	c1 e8 16             	shr    $0x16,%eax
  800f47:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f4e:	a8 01                	test   $0x1,%al
  800f50:	74 37                	je     800f89 <dup+0x99>
  800f52:	89 f8                	mov    %edi,%eax
  800f54:	c1 e8 0c             	shr    $0xc,%eax
  800f57:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f5e:	f6 c2 01             	test   $0x1,%dl
  800f61:	74 26                	je     800f89 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f63:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f6a:	83 ec 0c             	sub    $0xc,%esp
  800f6d:	25 07 0e 00 00       	and    $0xe07,%eax
  800f72:	50                   	push   %eax
  800f73:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f76:	6a 00                	push   $0x0
  800f78:	57                   	push   %edi
  800f79:	6a 00                	push   $0x0
  800f7b:	e8 b3 fb ff ff       	call   800b33 <sys_page_map>
  800f80:	89 c7                	mov    %eax,%edi
  800f82:	83 c4 20             	add    $0x20,%esp
  800f85:	85 c0                	test   %eax,%eax
  800f87:	78 2e                	js     800fb7 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f89:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f8c:	89 d0                	mov    %edx,%eax
  800f8e:	c1 e8 0c             	shr    $0xc,%eax
  800f91:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f98:	83 ec 0c             	sub    $0xc,%esp
  800f9b:	25 07 0e 00 00       	and    $0xe07,%eax
  800fa0:	50                   	push   %eax
  800fa1:	53                   	push   %ebx
  800fa2:	6a 00                	push   $0x0
  800fa4:	52                   	push   %edx
  800fa5:	6a 00                	push   $0x0
  800fa7:	e8 87 fb ff ff       	call   800b33 <sys_page_map>
  800fac:	89 c7                	mov    %eax,%edi
  800fae:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fb1:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fb3:	85 ff                	test   %edi,%edi
  800fb5:	79 1d                	jns    800fd4 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fb7:	83 ec 08             	sub    $0x8,%esp
  800fba:	53                   	push   %ebx
  800fbb:	6a 00                	push   $0x0
  800fbd:	e8 b3 fb ff ff       	call   800b75 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fc2:	83 c4 08             	add    $0x8,%esp
  800fc5:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fc8:	6a 00                	push   $0x0
  800fca:	e8 a6 fb ff ff       	call   800b75 <sys_page_unmap>
	return r;
  800fcf:	83 c4 10             	add    $0x10,%esp
  800fd2:	89 f8                	mov    %edi,%eax
}
  800fd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd7:	5b                   	pop    %ebx
  800fd8:	5e                   	pop    %esi
  800fd9:	5f                   	pop    %edi
  800fda:	5d                   	pop    %ebp
  800fdb:	c3                   	ret    

00800fdc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	53                   	push   %ebx
  800fe0:	83 ec 14             	sub    $0x14,%esp
  800fe3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fe6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fe9:	50                   	push   %eax
  800fea:	53                   	push   %ebx
  800feb:	e8 86 fd ff ff       	call   800d76 <fd_lookup>
  800ff0:	83 c4 08             	add    $0x8,%esp
  800ff3:	89 c2                	mov    %eax,%edx
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	78 6d                	js     801066 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ff9:	83 ec 08             	sub    $0x8,%esp
  800ffc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fff:	50                   	push   %eax
  801000:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801003:	ff 30                	pushl  (%eax)
  801005:	e8 c2 fd ff ff       	call   800dcc <dev_lookup>
  80100a:	83 c4 10             	add    $0x10,%esp
  80100d:	85 c0                	test   %eax,%eax
  80100f:	78 4c                	js     80105d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801011:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801014:	8b 42 08             	mov    0x8(%edx),%eax
  801017:	83 e0 03             	and    $0x3,%eax
  80101a:	83 f8 01             	cmp    $0x1,%eax
  80101d:	75 21                	jne    801040 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80101f:	a1 08 40 80 00       	mov    0x804008,%eax
  801024:	8b 40 48             	mov    0x48(%eax),%eax
  801027:	83 ec 04             	sub    $0x4,%esp
  80102a:	53                   	push   %ebx
  80102b:	50                   	push   %eax
  80102c:	68 0d 26 80 00       	push   $0x80260d
  801031:	e8 32 f1 ff ff       	call   800168 <cprintf>
		return -E_INVAL;
  801036:	83 c4 10             	add    $0x10,%esp
  801039:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80103e:	eb 26                	jmp    801066 <read+0x8a>
	}
	if (!dev->dev_read)
  801040:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801043:	8b 40 08             	mov    0x8(%eax),%eax
  801046:	85 c0                	test   %eax,%eax
  801048:	74 17                	je     801061 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80104a:	83 ec 04             	sub    $0x4,%esp
  80104d:	ff 75 10             	pushl  0x10(%ebp)
  801050:	ff 75 0c             	pushl  0xc(%ebp)
  801053:	52                   	push   %edx
  801054:	ff d0                	call   *%eax
  801056:	89 c2                	mov    %eax,%edx
  801058:	83 c4 10             	add    $0x10,%esp
  80105b:	eb 09                	jmp    801066 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80105d:	89 c2                	mov    %eax,%edx
  80105f:	eb 05                	jmp    801066 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801061:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801066:	89 d0                	mov    %edx,%eax
  801068:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80106b:	c9                   	leave  
  80106c:	c3                   	ret    

0080106d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
  801070:	57                   	push   %edi
  801071:	56                   	push   %esi
  801072:	53                   	push   %ebx
  801073:	83 ec 0c             	sub    $0xc,%esp
  801076:	8b 7d 08             	mov    0x8(%ebp),%edi
  801079:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80107c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801081:	eb 21                	jmp    8010a4 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801083:	83 ec 04             	sub    $0x4,%esp
  801086:	89 f0                	mov    %esi,%eax
  801088:	29 d8                	sub    %ebx,%eax
  80108a:	50                   	push   %eax
  80108b:	89 d8                	mov    %ebx,%eax
  80108d:	03 45 0c             	add    0xc(%ebp),%eax
  801090:	50                   	push   %eax
  801091:	57                   	push   %edi
  801092:	e8 45 ff ff ff       	call   800fdc <read>
		if (m < 0)
  801097:	83 c4 10             	add    $0x10,%esp
  80109a:	85 c0                	test   %eax,%eax
  80109c:	78 10                	js     8010ae <readn+0x41>
			return m;
		if (m == 0)
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	74 0a                	je     8010ac <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010a2:	01 c3                	add    %eax,%ebx
  8010a4:	39 f3                	cmp    %esi,%ebx
  8010a6:	72 db                	jb     801083 <readn+0x16>
  8010a8:	89 d8                	mov    %ebx,%eax
  8010aa:	eb 02                	jmp    8010ae <readn+0x41>
  8010ac:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b1:	5b                   	pop    %ebx
  8010b2:	5e                   	pop    %esi
  8010b3:	5f                   	pop    %edi
  8010b4:	5d                   	pop    %ebp
  8010b5:	c3                   	ret    

008010b6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010b6:	55                   	push   %ebp
  8010b7:	89 e5                	mov    %esp,%ebp
  8010b9:	53                   	push   %ebx
  8010ba:	83 ec 14             	sub    $0x14,%esp
  8010bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010c3:	50                   	push   %eax
  8010c4:	53                   	push   %ebx
  8010c5:	e8 ac fc ff ff       	call   800d76 <fd_lookup>
  8010ca:	83 c4 08             	add    $0x8,%esp
  8010cd:	89 c2                	mov    %eax,%edx
  8010cf:	85 c0                	test   %eax,%eax
  8010d1:	78 68                	js     80113b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010d3:	83 ec 08             	sub    $0x8,%esp
  8010d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010d9:	50                   	push   %eax
  8010da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010dd:	ff 30                	pushl  (%eax)
  8010df:	e8 e8 fc ff ff       	call   800dcc <dev_lookup>
  8010e4:	83 c4 10             	add    $0x10,%esp
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	78 47                	js     801132 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010ee:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010f2:	75 21                	jne    801115 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010f4:	a1 08 40 80 00       	mov    0x804008,%eax
  8010f9:	8b 40 48             	mov    0x48(%eax),%eax
  8010fc:	83 ec 04             	sub    $0x4,%esp
  8010ff:	53                   	push   %ebx
  801100:	50                   	push   %eax
  801101:	68 29 26 80 00       	push   $0x802629
  801106:	e8 5d f0 ff ff       	call   800168 <cprintf>
		return -E_INVAL;
  80110b:	83 c4 10             	add    $0x10,%esp
  80110e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801113:	eb 26                	jmp    80113b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801115:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801118:	8b 52 0c             	mov    0xc(%edx),%edx
  80111b:	85 d2                	test   %edx,%edx
  80111d:	74 17                	je     801136 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80111f:	83 ec 04             	sub    $0x4,%esp
  801122:	ff 75 10             	pushl  0x10(%ebp)
  801125:	ff 75 0c             	pushl  0xc(%ebp)
  801128:	50                   	push   %eax
  801129:	ff d2                	call   *%edx
  80112b:	89 c2                	mov    %eax,%edx
  80112d:	83 c4 10             	add    $0x10,%esp
  801130:	eb 09                	jmp    80113b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801132:	89 c2                	mov    %eax,%edx
  801134:	eb 05                	jmp    80113b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801136:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80113b:	89 d0                	mov    %edx,%eax
  80113d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801140:	c9                   	leave  
  801141:	c3                   	ret    

00801142 <seek>:

int
seek(int fdnum, off_t offset)
{
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
  801145:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801148:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80114b:	50                   	push   %eax
  80114c:	ff 75 08             	pushl  0x8(%ebp)
  80114f:	e8 22 fc ff ff       	call   800d76 <fd_lookup>
  801154:	83 c4 08             	add    $0x8,%esp
  801157:	85 c0                	test   %eax,%eax
  801159:	78 0e                	js     801169 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80115b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80115e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801161:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801164:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801169:	c9                   	leave  
  80116a:	c3                   	ret    

0080116b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80116b:	55                   	push   %ebp
  80116c:	89 e5                	mov    %esp,%ebp
  80116e:	53                   	push   %ebx
  80116f:	83 ec 14             	sub    $0x14,%esp
  801172:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801175:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801178:	50                   	push   %eax
  801179:	53                   	push   %ebx
  80117a:	e8 f7 fb ff ff       	call   800d76 <fd_lookup>
  80117f:	83 c4 08             	add    $0x8,%esp
  801182:	89 c2                	mov    %eax,%edx
  801184:	85 c0                	test   %eax,%eax
  801186:	78 65                	js     8011ed <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801188:	83 ec 08             	sub    $0x8,%esp
  80118b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80118e:	50                   	push   %eax
  80118f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801192:	ff 30                	pushl  (%eax)
  801194:	e8 33 fc ff ff       	call   800dcc <dev_lookup>
  801199:	83 c4 10             	add    $0x10,%esp
  80119c:	85 c0                	test   %eax,%eax
  80119e:	78 44                	js     8011e4 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011a7:	75 21                	jne    8011ca <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011a9:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011ae:	8b 40 48             	mov    0x48(%eax),%eax
  8011b1:	83 ec 04             	sub    $0x4,%esp
  8011b4:	53                   	push   %ebx
  8011b5:	50                   	push   %eax
  8011b6:	68 ec 25 80 00       	push   $0x8025ec
  8011bb:	e8 a8 ef ff ff       	call   800168 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011c0:	83 c4 10             	add    $0x10,%esp
  8011c3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011c8:	eb 23                	jmp    8011ed <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011cd:	8b 52 18             	mov    0x18(%edx),%edx
  8011d0:	85 d2                	test   %edx,%edx
  8011d2:	74 14                	je     8011e8 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011d4:	83 ec 08             	sub    $0x8,%esp
  8011d7:	ff 75 0c             	pushl  0xc(%ebp)
  8011da:	50                   	push   %eax
  8011db:	ff d2                	call   *%edx
  8011dd:	89 c2                	mov    %eax,%edx
  8011df:	83 c4 10             	add    $0x10,%esp
  8011e2:	eb 09                	jmp    8011ed <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e4:	89 c2                	mov    %eax,%edx
  8011e6:	eb 05                	jmp    8011ed <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011e8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8011ed:	89 d0                	mov    %edx,%eax
  8011ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f2:	c9                   	leave  
  8011f3:	c3                   	ret    

008011f4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
  8011f7:	53                   	push   %ebx
  8011f8:	83 ec 14             	sub    $0x14,%esp
  8011fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801201:	50                   	push   %eax
  801202:	ff 75 08             	pushl  0x8(%ebp)
  801205:	e8 6c fb ff ff       	call   800d76 <fd_lookup>
  80120a:	83 c4 08             	add    $0x8,%esp
  80120d:	89 c2                	mov    %eax,%edx
  80120f:	85 c0                	test   %eax,%eax
  801211:	78 58                	js     80126b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801213:	83 ec 08             	sub    $0x8,%esp
  801216:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801219:	50                   	push   %eax
  80121a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121d:	ff 30                	pushl  (%eax)
  80121f:	e8 a8 fb ff ff       	call   800dcc <dev_lookup>
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	85 c0                	test   %eax,%eax
  801229:	78 37                	js     801262 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80122b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80122e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801232:	74 32                	je     801266 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801234:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801237:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80123e:	00 00 00 
	stat->st_isdir = 0;
  801241:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801248:	00 00 00 
	stat->st_dev = dev;
  80124b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801251:	83 ec 08             	sub    $0x8,%esp
  801254:	53                   	push   %ebx
  801255:	ff 75 f0             	pushl  -0x10(%ebp)
  801258:	ff 50 14             	call   *0x14(%eax)
  80125b:	89 c2                	mov    %eax,%edx
  80125d:	83 c4 10             	add    $0x10,%esp
  801260:	eb 09                	jmp    80126b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801262:	89 c2                	mov    %eax,%edx
  801264:	eb 05                	jmp    80126b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801266:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80126b:	89 d0                	mov    %edx,%eax
  80126d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801270:	c9                   	leave  
  801271:	c3                   	ret    

00801272 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	56                   	push   %esi
  801276:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801277:	83 ec 08             	sub    $0x8,%esp
  80127a:	6a 00                	push   $0x0
  80127c:	ff 75 08             	pushl  0x8(%ebp)
  80127f:	e8 d6 01 00 00       	call   80145a <open>
  801284:	89 c3                	mov    %eax,%ebx
  801286:	83 c4 10             	add    $0x10,%esp
  801289:	85 c0                	test   %eax,%eax
  80128b:	78 1b                	js     8012a8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80128d:	83 ec 08             	sub    $0x8,%esp
  801290:	ff 75 0c             	pushl  0xc(%ebp)
  801293:	50                   	push   %eax
  801294:	e8 5b ff ff ff       	call   8011f4 <fstat>
  801299:	89 c6                	mov    %eax,%esi
	close(fd);
  80129b:	89 1c 24             	mov    %ebx,(%esp)
  80129e:	e8 fd fb ff ff       	call   800ea0 <close>
	return r;
  8012a3:	83 c4 10             	add    $0x10,%esp
  8012a6:	89 f0                	mov    %esi,%eax
}
  8012a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ab:	5b                   	pop    %ebx
  8012ac:	5e                   	pop    %esi
  8012ad:	5d                   	pop    %ebp
  8012ae:	c3                   	ret    

008012af <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
  8012b2:	56                   	push   %esi
  8012b3:	53                   	push   %ebx
  8012b4:	89 c6                	mov    %eax,%esi
  8012b6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012b8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012bf:	75 12                	jne    8012d3 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012c1:	83 ec 0c             	sub    $0xc,%esp
  8012c4:	6a 01                	push   $0x1
  8012c6:	e8 7a 0c 00 00       	call   801f45 <ipc_find_env>
  8012cb:	a3 00 40 80 00       	mov    %eax,0x804000
  8012d0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012d3:	6a 07                	push   $0x7
  8012d5:	68 00 50 80 00       	push   $0x805000
  8012da:	56                   	push   %esi
  8012db:	ff 35 00 40 80 00    	pushl  0x804000
  8012e1:	e8 0b 0c 00 00       	call   801ef1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012e6:	83 c4 0c             	add    $0xc,%esp
  8012e9:	6a 00                	push   $0x0
  8012eb:	53                   	push   %ebx
  8012ec:	6a 00                	push   $0x0
  8012ee:	e8 97 0b 00 00       	call   801e8a <ipc_recv>
}
  8012f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f6:	5b                   	pop    %ebx
  8012f7:	5e                   	pop    %esi
  8012f8:	5d                   	pop    %ebp
  8012f9:	c3                   	ret    

008012fa <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012fa:	55                   	push   %ebp
  8012fb:	89 e5                	mov    %esp,%ebp
  8012fd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801300:	8b 45 08             	mov    0x8(%ebp),%eax
  801303:	8b 40 0c             	mov    0xc(%eax),%eax
  801306:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80130b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80130e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801313:	ba 00 00 00 00       	mov    $0x0,%edx
  801318:	b8 02 00 00 00       	mov    $0x2,%eax
  80131d:	e8 8d ff ff ff       	call   8012af <fsipc>
}
  801322:	c9                   	leave  
  801323:	c3                   	ret    

00801324 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80132a:	8b 45 08             	mov    0x8(%ebp),%eax
  80132d:	8b 40 0c             	mov    0xc(%eax),%eax
  801330:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801335:	ba 00 00 00 00       	mov    $0x0,%edx
  80133a:	b8 06 00 00 00       	mov    $0x6,%eax
  80133f:	e8 6b ff ff ff       	call   8012af <fsipc>
}
  801344:	c9                   	leave  
  801345:	c3                   	ret    

00801346 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	53                   	push   %ebx
  80134a:	83 ec 04             	sub    $0x4,%esp
  80134d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801350:	8b 45 08             	mov    0x8(%ebp),%eax
  801353:	8b 40 0c             	mov    0xc(%eax),%eax
  801356:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80135b:	ba 00 00 00 00       	mov    $0x0,%edx
  801360:	b8 05 00 00 00       	mov    $0x5,%eax
  801365:	e8 45 ff ff ff       	call   8012af <fsipc>
  80136a:	85 c0                	test   %eax,%eax
  80136c:	78 2c                	js     80139a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80136e:	83 ec 08             	sub    $0x8,%esp
  801371:	68 00 50 80 00       	push   $0x805000
  801376:	53                   	push   %ebx
  801377:	e8 71 f3 ff ff       	call   8006ed <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80137c:	a1 80 50 80 00       	mov    0x805080,%eax
  801381:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801387:	a1 84 50 80 00       	mov    0x805084,%eax
  80138c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801392:	83 c4 10             	add    $0x10,%esp
  801395:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80139a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139d:	c9                   	leave  
  80139e:	c3                   	ret    

0080139f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80139f:	55                   	push   %ebp
  8013a0:	89 e5                	mov    %esp,%ebp
  8013a2:	83 ec 0c             	sub    $0xc,%esp
  8013a5:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ab:	8b 52 0c             	mov    0xc(%edx),%edx
  8013ae:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8013b4:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8013b9:	50                   	push   %eax
  8013ba:	ff 75 0c             	pushl  0xc(%ebp)
  8013bd:	68 08 50 80 00       	push   $0x805008
  8013c2:	e8 b8 f4 ff ff       	call   80087f <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8013c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013cc:	b8 04 00 00 00       	mov    $0x4,%eax
  8013d1:	e8 d9 fe ff ff       	call   8012af <fsipc>

}
  8013d6:	c9                   	leave  
  8013d7:	c3                   	ret    

008013d8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013d8:	55                   	push   %ebp
  8013d9:	89 e5                	mov    %esp,%ebp
  8013db:	56                   	push   %esi
  8013dc:	53                   	push   %ebx
  8013dd:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8013e6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013eb:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f6:	b8 03 00 00 00       	mov    $0x3,%eax
  8013fb:	e8 af fe ff ff       	call   8012af <fsipc>
  801400:	89 c3                	mov    %eax,%ebx
  801402:	85 c0                	test   %eax,%eax
  801404:	78 4b                	js     801451 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801406:	39 c6                	cmp    %eax,%esi
  801408:	73 16                	jae    801420 <devfile_read+0x48>
  80140a:	68 5c 26 80 00       	push   $0x80265c
  80140f:	68 63 26 80 00       	push   $0x802663
  801414:	6a 7c                	push   $0x7c
  801416:	68 78 26 80 00       	push   $0x802678
  80141b:	e8 24 0a 00 00       	call   801e44 <_panic>
	assert(r <= PGSIZE);
  801420:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801425:	7e 16                	jle    80143d <devfile_read+0x65>
  801427:	68 83 26 80 00       	push   $0x802683
  80142c:	68 63 26 80 00       	push   $0x802663
  801431:	6a 7d                	push   $0x7d
  801433:	68 78 26 80 00       	push   $0x802678
  801438:	e8 07 0a 00 00       	call   801e44 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80143d:	83 ec 04             	sub    $0x4,%esp
  801440:	50                   	push   %eax
  801441:	68 00 50 80 00       	push   $0x805000
  801446:	ff 75 0c             	pushl  0xc(%ebp)
  801449:	e8 31 f4 ff ff       	call   80087f <memmove>
	return r;
  80144e:	83 c4 10             	add    $0x10,%esp
}
  801451:	89 d8                	mov    %ebx,%eax
  801453:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801456:	5b                   	pop    %ebx
  801457:	5e                   	pop    %esi
  801458:	5d                   	pop    %ebp
  801459:	c3                   	ret    

0080145a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	53                   	push   %ebx
  80145e:	83 ec 20             	sub    $0x20,%esp
  801461:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801464:	53                   	push   %ebx
  801465:	e8 4a f2 ff ff       	call   8006b4 <strlen>
  80146a:	83 c4 10             	add    $0x10,%esp
  80146d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801472:	7f 67                	jg     8014db <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801474:	83 ec 0c             	sub    $0xc,%esp
  801477:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147a:	50                   	push   %eax
  80147b:	e8 a7 f8 ff ff       	call   800d27 <fd_alloc>
  801480:	83 c4 10             	add    $0x10,%esp
		return r;
  801483:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801485:	85 c0                	test   %eax,%eax
  801487:	78 57                	js     8014e0 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801489:	83 ec 08             	sub    $0x8,%esp
  80148c:	53                   	push   %ebx
  80148d:	68 00 50 80 00       	push   $0x805000
  801492:	e8 56 f2 ff ff       	call   8006ed <strcpy>
	fsipcbuf.open.req_omode = mode;
  801497:	8b 45 0c             	mov    0xc(%ebp),%eax
  80149a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80149f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8014a7:	e8 03 fe ff ff       	call   8012af <fsipc>
  8014ac:	89 c3                	mov    %eax,%ebx
  8014ae:	83 c4 10             	add    $0x10,%esp
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	79 14                	jns    8014c9 <open+0x6f>
		fd_close(fd, 0);
  8014b5:	83 ec 08             	sub    $0x8,%esp
  8014b8:	6a 00                	push   $0x0
  8014ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8014bd:	e8 5d f9 ff ff       	call   800e1f <fd_close>
		return r;
  8014c2:	83 c4 10             	add    $0x10,%esp
  8014c5:	89 da                	mov    %ebx,%edx
  8014c7:	eb 17                	jmp    8014e0 <open+0x86>
	}

	return fd2num(fd);
  8014c9:	83 ec 0c             	sub    $0xc,%esp
  8014cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8014cf:	e8 2c f8 ff ff       	call   800d00 <fd2num>
  8014d4:	89 c2                	mov    %eax,%edx
  8014d6:	83 c4 10             	add    $0x10,%esp
  8014d9:	eb 05                	jmp    8014e0 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014db:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8014e0:	89 d0                	mov    %edx,%eax
  8014e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e5:	c9                   	leave  
  8014e6:	c3                   	ret    

008014e7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014e7:	55                   	push   %ebp
  8014e8:	89 e5                	mov    %esp,%ebp
  8014ea:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8014ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f2:	b8 08 00 00 00       	mov    $0x8,%eax
  8014f7:	e8 b3 fd ff ff       	call   8012af <fsipc>
}
  8014fc:	c9                   	leave  
  8014fd:	c3                   	ret    

008014fe <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	56                   	push   %esi
  801502:	53                   	push   %ebx
  801503:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801506:	83 ec 0c             	sub    $0xc,%esp
  801509:	ff 75 08             	pushl  0x8(%ebp)
  80150c:	e8 ff f7 ff ff       	call   800d10 <fd2data>
  801511:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801513:	83 c4 08             	add    $0x8,%esp
  801516:	68 8f 26 80 00       	push   $0x80268f
  80151b:	53                   	push   %ebx
  80151c:	e8 cc f1 ff ff       	call   8006ed <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801521:	8b 46 04             	mov    0x4(%esi),%eax
  801524:	2b 06                	sub    (%esi),%eax
  801526:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80152c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801533:	00 00 00 
	stat->st_dev = &devpipe;
  801536:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80153d:	30 80 00 
	return 0;
}
  801540:	b8 00 00 00 00       	mov    $0x0,%eax
  801545:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801548:	5b                   	pop    %ebx
  801549:	5e                   	pop    %esi
  80154a:	5d                   	pop    %ebp
  80154b:	c3                   	ret    

0080154c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80154c:	55                   	push   %ebp
  80154d:	89 e5                	mov    %esp,%ebp
  80154f:	53                   	push   %ebx
  801550:	83 ec 0c             	sub    $0xc,%esp
  801553:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801556:	53                   	push   %ebx
  801557:	6a 00                	push   $0x0
  801559:	e8 17 f6 ff ff       	call   800b75 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80155e:	89 1c 24             	mov    %ebx,(%esp)
  801561:	e8 aa f7 ff ff       	call   800d10 <fd2data>
  801566:	83 c4 08             	add    $0x8,%esp
  801569:	50                   	push   %eax
  80156a:	6a 00                	push   $0x0
  80156c:	e8 04 f6 ff ff       	call   800b75 <sys_page_unmap>
}
  801571:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801574:	c9                   	leave  
  801575:	c3                   	ret    

00801576 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801576:	55                   	push   %ebp
  801577:	89 e5                	mov    %esp,%ebp
  801579:	57                   	push   %edi
  80157a:	56                   	push   %esi
  80157b:	53                   	push   %ebx
  80157c:	83 ec 1c             	sub    $0x1c,%esp
  80157f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801582:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801584:	a1 08 40 80 00       	mov    0x804008,%eax
  801589:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80158c:	83 ec 0c             	sub    $0xc,%esp
  80158f:	ff 75 e0             	pushl  -0x20(%ebp)
  801592:	e8 e7 09 00 00       	call   801f7e <pageref>
  801597:	89 c3                	mov    %eax,%ebx
  801599:	89 3c 24             	mov    %edi,(%esp)
  80159c:	e8 dd 09 00 00       	call   801f7e <pageref>
  8015a1:	83 c4 10             	add    $0x10,%esp
  8015a4:	39 c3                	cmp    %eax,%ebx
  8015a6:	0f 94 c1             	sete   %cl
  8015a9:	0f b6 c9             	movzbl %cl,%ecx
  8015ac:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015af:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8015b5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015b8:	39 ce                	cmp    %ecx,%esi
  8015ba:	74 1b                	je     8015d7 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015bc:	39 c3                	cmp    %eax,%ebx
  8015be:	75 c4                	jne    801584 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015c0:	8b 42 58             	mov    0x58(%edx),%eax
  8015c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015c6:	50                   	push   %eax
  8015c7:	56                   	push   %esi
  8015c8:	68 96 26 80 00       	push   $0x802696
  8015cd:	e8 96 eb ff ff       	call   800168 <cprintf>
  8015d2:	83 c4 10             	add    $0x10,%esp
  8015d5:	eb ad                	jmp    801584 <_pipeisclosed+0xe>
	}
}
  8015d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015dd:	5b                   	pop    %ebx
  8015de:	5e                   	pop    %esi
  8015df:	5f                   	pop    %edi
  8015e0:	5d                   	pop    %ebp
  8015e1:	c3                   	ret    

008015e2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	57                   	push   %edi
  8015e6:	56                   	push   %esi
  8015e7:	53                   	push   %ebx
  8015e8:	83 ec 28             	sub    $0x28,%esp
  8015eb:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8015ee:	56                   	push   %esi
  8015ef:	e8 1c f7 ff ff       	call   800d10 <fd2data>
  8015f4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	bf 00 00 00 00       	mov    $0x0,%edi
  8015fe:	eb 4b                	jmp    80164b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801600:	89 da                	mov    %ebx,%edx
  801602:	89 f0                	mov    %esi,%eax
  801604:	e8 6d ff ff ff       	call   801576 <_pipeisclosed>
  801609:	85 c0                	test   %eax,%eax
  80160b:	75 48                	jne    801655 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80160d:	e8 bf f4 ff ff       	call   800ad1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801612:	8b 43 04             	mov    0x4(%ebx),%eax
  801615:	8b 0b                	mov    (%ebx),%ecx
  801617:	8d 51 20             	lea    0x20(%ecx),%edx
  80161a:	39 d0                	cmp    %edx,%eax
  80161c:	73 e2                	jae    801600 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80161e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801621:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801625:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801628:	89 c2                	mov    %eax,%edx
  80162a:	c1 fa 1f             	sar    $0x1f,%edx
  80162d:	89 d1                	mov    %edx,%ecx
  80162f:	c1 e9 1b             	shr    $0x1b,%ecx
  801632:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801635:	83 e2 1f             	and    $0x1f,%edx
  801638:	29 ca                	sub    %ecx,%edx
  80163a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80163e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801642:	83 c0 01             	add    $0x1,%eax
  801645:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801648:	83 c7 01             	add    $0x1,%edi
  80164b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80164e:	75 c2                	jne    801612 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801650:	8b 45 10             	mov    0x10(%ebp),%eax
  801653:	eb 05                	jmp    80165a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801655:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80165a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80165d:	5b                   	pop    %ebx
  80165e:	5e                   	pop    %esi
  80165f:	5f                   	pop    %edi
  801660:	5d                   	pop    %ebp
  801661:	c3                   	ret    

00801662 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801662:	55                   	push   %ebp
  801663:	89 e5                	mov    %esp,%ebp
  801665:	57                   	push   %edi
  801666:	56                   	push   %esi
  801667:	53                   	push   %ebx
  801668:	83 ec 18             	sub    $0x18,%esp
  80166b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80166e:	57                   	push   %edi
  80166f:	e8 9c f6 ff ff       	call   800d10 <fd2data>
  801674:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801676:	83 c4 10             	add    $0x10,%esp
  801679:	bb 00 00 00 00       	mov    $0x0,%ebx
  80167e:	eb 3d                	jmp    8016bd <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801680:	85 db                	test   %ebx,%ebx
  801682:	74 04                	je     801688 <devpipe_read+0x26>
				return i;
  801684:	89 d8                	mov    %ebx,%eax
  801686:	eb 44                	jmp    8016cc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801688:	89 f2                	mov    %esi,%edx
  80168a:	89 f8                	mov    %edi,%eax
  80168c:	e8 e5 fe ff ff       	call   801576 <_pipeisclosed>
  801691:	85 c0                	test   %eax,%eax
  801693:	75 32                	jne    8016c7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801695:	e8 37 f4 ff ff       	call   800ad1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80169a:	8b 06                	mov    (%esi),%eax
  80169c:	3b 46 04             	cmp    0x4(%esi),%eax
  80169f:	74 df                	je     801680 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016a1:	99                   	cltd   
  8016a2:	c1 ea 1b             	shr    $0x1b,%edx
  8016a5:	01 d0                	add    %edx,%eax
  8016a7:	83 e0 1f             	and    $0x1f,%eax
  8016aa:	29 d0                	sub    %edx,%eax
  8016ac:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016b4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016b7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016ba:	83 c3 01             	add    $0x1,%ebx
  8016bd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016c0:	75 d8                	jne    80169a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8016c5:	eb 05                	jmp    8016cc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016c7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016cf:	5b                   	pop    %ebx
  8016d0:	5e                   	pop    %esi
  8016d1:	5f                   	pop    %edi
  8016d2:	5d                   	pop    %ebp
  8016d3:	c3                   	ret    

008016d4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	56                   	push   %esi
  8016d8:	53                   	push   %ebx
  8016d9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016df:	50                   	push   %eax
  8016e0:	e8 42 f6 ff ff       	call   800d27 <fd_alloc>
  8016e5:	83 c4 10             	add    $0x10,%esp
  8016e8:	89 c2                	mov    %eax,%edx
  8016ea:	85 c0                	test   %eax,%eax
  8016ec:	0f 88 2c 01 00 00    	js     80181e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016f2:	83 ec 04             	sub    $0x4,%esp
  8016f5:	68 07 04 00 00       	push   $0x407
  8016fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8016fd:	6a 00                	push   $0x0
  8016ff:	e8 ec f3 ff ff       	call   800af0 <sys_page_alloc>
  801704:	83 c4 10             	add    $0x10,%esp
  801707:	89 c2                	mov    %eax,%edx
  801709:	85 c0                	test   %eax,%eax
  80170b:	0f 88 0d 01 00 00    	js     80181e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801711:	83 ec 0c             	sub    $0xc,%esp
  801714:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801717:	50                   	push   %eax
  801718:	e8 0a f6 ff ff       	call   800d27 <fd_alloc>
  80171d:	89 c3                	mov    %eax,%ebx
  80171f:	83 c4 10             	add    $0x10,%esp
  801722:	85 c0                	test   %eax,%eax
  801724:	0f 88 e2 00 00 00    	js     80180c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80172a:	83 ec 04             	sub    $0x4,%esp
  80172d:	68 07 04 00 00       	push   $0x407
  801732:	ff 75 f0             	pushl  -0x10(%ebp)
  801735:	6a 00                	push   $0x0
  801737:	e8 b4 f3 ff ff       	call   800af0 <sys_page_alloc>
  80173c:	89 c3                	mov    %eax,%ebx
  80173e:	83 c4 10             	add    $0x10,%esp
  801741:	85 c0                	test   %eax,%eax
  801743:	0f 88 c3 00 00 00    	js     80180c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801749:	83 ec 0c             	sub    $0xc,%esp
  80174c:	ff 75 f4             	pushl  -0xc(%ebp)
  80174f:	e8 bc f5 ff ff       	call   800d10 <fd2data>
  801754:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801756:	83 c4 0c             	add    $0xc,%esp
  801759:	68 07 04 00 00       	push   $0x407
  80175e:	50                   	push   %eax
  80175f:	6a 00                	push   $0x0
  801761:	e8 8a f3 ff ff       	call   800af0 <sys_page_alloc>
  801766:	89 c3                	mov    %eax,%ebx
  801768:	83 c4 10             	add    $0x10,%esp
  80176b:	85 c0                	test   %eax,%eax
  80176d:	0f 88 89 00 00 00    	js     8017fc <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801773:	83 ec 0c             	sub    $0xc,%esp
  801776:	ff 75 f0             	pushl  -0x10(%ebp)
  801779:	e8 92 f5 ff ff       	call   800d10 <fd2data>
  80177e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801785:	50                   	push   %eax
  801786:	6a 00                	push   $0x0
  801788:	56                   	push   %esi
  801789:	6a 00                	push   $0x0
  80178b:	e8 a3 f3 ff ff       	call   800b33 <sys_page_map>
  801790:	89 c3                	mov    %eax,%ebx
  801792:	83 c4 20             	add    $0x20,%esp
  801795:	85 c0                	test   %eax,%eax
  801797:	78 55                	js     8017ee <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801799:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80179f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017ae:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017bc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017c3:	83 ec 0c             	sub    $0xc,%esp
  8017c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8017c9:	e8 32 f5 ff ff       	call   800d00 <fd2num>
  8017ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017d1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017d3:	83 c4 04             	add    $0x4,%esp
  8017d6:	ff 75 f0             	pushl  -0x10(%ebp)
  8017d9:	e8 22 f5 ff ff       	call   800d00 <fd2num>
  8017de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017e1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8017e4:	83 c4 10             	add    $0x10,%esp
  8017e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ec:	eb 30                	jmp    80181e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8017ee:	83 ec 08             	sub    $0x8,%esp
  8017f1:	56                   	push   %esi
  8017f2:	6a 00                	push   $0x0
  8017f4:	e8 7c f3 ff ff       	call   800b75 <sys_page_unmap>
  8017f9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8017fc:	83 ec 08             	sub    $0x8,%esp
  8017ff:	ff 75 f0             	pushl  -0x10(%ebp)
  801802:	6a 00                	push   $0x0
  801804:	e8 6c f3 ff ff       	call   800b75 <sys_page_unmap>
  801809:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80180c:	83 ec 08             	sub    $0x8,%esp
  80180f:	ff 75 f4             	pushl  -0xc(%ebp)
  801812:	6a 00                	push   $0x0
  801814:	e8 5c f3 ff ff       	call   800b75 <sys_page_unmap>
  801819:	83 c4 10             	add    $0x10,%esp
  80181c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80181e:	89 d0                	mov    %edx,%eax
  801820:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801823:	5b                   	pop    %ebx
  801824:	5e                   	pop    %esi
  801825:	5d                   	pop    %ebp
  801826:	c3                   	ret    

00801827 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801827:	55                   	push   %ebp
  801828:	89 e5                	mov    %esp,%ebp
  80182a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80182d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801830:	50                   	push   %eax
  801831:	ff 75 08             	pushl  0x8(%ebp)
  801834:	e8 3d f5 ff ff       	call   800d76 <fd_lookup>
  801839:	83 c4 10             	add    $0x10,%esp
  80183c:	85 c0                	test   %eax,%eax
  80183e:	78 18                	js     801858 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801840:	83 ec 0c             	sub    $0xc,%esp
  801843:	ff 75 f4             	pushl  -0xc(%ebp)
  801846:	e8 c5 f4 ff ff       	call   800d10 <fd2data>
	return _pipeisclosed(fd, p);
  80184b:	89 c2                	mov    %eax,%edx
  80184d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801850:	e8 21 fd ff ff       	call   801576 <_pipeisclosed>
  801855:	83 c4 10             	add    $0x10,%esp
}
  801858:	c9                   	leave  
  801859:	c3                   	ret    

0080185a <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80185a:	55                   	push   %ebp
  80185b:	89 e5                	mov    %esp,%ebp
  80185d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801860:	68 ae 26 80 00       	push   $0x8026ae
  801865:	ff 75 0c             	pushl  0xc(%ebp)
  801868:	e8 80 ee ff ff       	call   8006ed <strcpy>
	return 0;
}
  80186d:	b8 00 00 00 00       	mov    $0x0,%eax
  801872:	c9                   	leave  
  801873:	c3                   	ret    

00801874 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801874:	55                   	push   %ebp
  801875:	89 e5                	mov    %esp,%ebp
  801877:	53                   	push   %ebx
  801878:	83 ec 10             	sub    $0x10,%esp
  80187b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80187e:	53                   	push   %ebx
  80187f:	e8 fa 06 00 00       	call   801f7e <pageref>
  801884:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801887:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80188c:	83 f8 01             	cmp    $0x1,%eax
  80188f:	75 10                	jne    8018a1 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801891:	83 ec 0c             	sub    $0xc,%esp
  801894:	ff 73 0c             	pushl  0xc(%ebx)
  801897:	e8 c0 02 00 00       	call   801b5c <nsipc_close>
  80189c:	89 c2                	mov    %eax,%edx
  80189e:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8018a1:	89 d0                	mov    %edx,%eax
  8018a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a6:	c9                   	leave  
  8018a7:	c3                   	ret    

008018a8 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8018a8:	55                   	push   %ebp
  8018a9:	89 e5                	mov    %esp,%ebp
  8018ab:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8018ae:	6a 00                	push   $0x0
  8018b0:	ff 75 10             	pushl  0x10(%ebp)
  8018b3:	ff 75 0c             	pushl  0xc(%ebp)
  8018b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b9:	ff 70 0c             	pushl  0xc(%eax)
  8018bc:	e8 78 03 00 00       	call   801c39 <nsipc_send>
}
  8018c1:	c9                   	leave  
  8018c2:	c3                   	ret    

008018c3 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8018c3:	55                   	push   %ebp
  8018c4:	89 e5                	mov    %esp,%ebp
  8018c6:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8018c9:	6a 00                	push   $0x0
  8018cb:	ff 75 10             	pushl  0x10(%ebp)
  8018ce:	ff 75 0c             	pushl  0xc(%ebp)
  8018d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d4:	ff 70 0c             	pushl  0xc(%eax)
  8018d7:	e8 f1 02 00 00       	call   801bcd <nsipc_recv>
}
  8018dc:	c9                   	leave  
  8018dd:	c3                   	ret    

008018de <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8018de:	55                   	push   %ebp
  8018df:	89 e5                	mov    %esp,%ebp
  8018e1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8018e4:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8018e7:	52                   	push   %edx
  8018e8:	50                   	push   %eax
  8018e9:	e8 88 f4 ff ff       	call   800d76 <fd_lookup>
  8018ee:	83 c4 10             	add    $0x10,%esp
  8018f1:	85 c0                	test   %eax,%eax
  8018f3:	78 17                	js     80190c <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8018f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f8:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  8018fe:	39 08                	cmp    %ecx,(%eax)
  801900:	75 05                	jne    801907 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801902:	8b 40 0c             	mov    0xc(%eax),%eax
  801905:	eb 05                	jmp    80190c <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801907:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80190c:	c9                   	leave  
  80190d:	c3                   	ret    

0080190e <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	56                   	push   %esi
  801912:	53                   	push   %ebx
  801913:	83 ec 1c             	sub    $0x1c,%esp
  801916:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801918:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80191b:	50                   	push   %eax
  80191c:	e8 06 f4 ff ff       	call   800d27 <fd_alloc>
  801921:	89 c3                	mov    %eax,%ebx
  801923:	83 c4 10             	add    $0x10,%esp
  801926:	85 c0                	test   %eax,%eax
  801928:	78 1b                	js     801945 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80192a:	83 ec 04             	sub    $0x4,%esp
  80192d:	68 07 04 00 00       	push   $0x407
  801932:	ff 75 f4             	pushl  -0xc(%ebp)
  801935:	6a 00                	push   $0x0
  801937:	e8 b4 f1 ff ff       	call   800af0 <sys_page_alloc>
  80193c:	89 c3                	mov    %eax,%ebx
  80193e:	83 c4 10             	add    $0x10,%esp
  801941:	85 c0                	test   %eax,%eax
  801943:	79 10                	jns    801955 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801945:	83 ec 0c             	sub    $0xc,%esp
  801948:	56                   	push   %esi
  801949:	e8 0e 02 00 00       	call   801b5c <nsipc_close>
		return r;
  80194e:	83 c4 10             	add    $0x10,%esp
  801951:	89 d8                	mov    %ebx,%eax
  801953:	eb 24                	jmp    801979 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801955:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80195b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80195e:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801960:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801963:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80196a:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80196d:	83 ec 0c             	sub    $0xc,%esp
  801970:	50                   	push   %eax
  801971:	e8 8a f3 ff ff       	call   800d00 <fd2num>
  801976:	83 c4 10             	add    $0x10,%esp
}
  801979:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80197c:	5b                   	pop    %ebx
  80197d:	5e                   	pop    %esi
  80197e:	5d                   	pop    %ebp
  80197f:	c3                   	ret    

00801980 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801986:	8b 45 08             	mov    0x8(%ebp),%eax
  801989:	e8 50 ff ff ff       	call   8018de <fd2sockid>
		return r;
  80198e:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801990:	85 c0                	test   %eax,%eax
  801992:	78 1f                	js     8019b3 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801994:	83 ec 04             	sub    $0x4,%esp
  801997:	ff 75 10             	pushl  0x10(%ebp)
  80199a:	ff 75 0c             	pushl  0xc(%ebp)
  80199d:	50                   	push   %eax
  80199e:	e8 12 01 00 00       	call   801ab5 <nsipc_accept>
  8019a3:	83 c4 10             	add    $0x10,%esp
		return r;
  8019a6:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019a8:	85 c0                	test   %eax,%eax
  8019aa:	78 07                	js     8019b3 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8019ac:	e8 5d ff ff ff       	call   80190e <alloc_sockfd>
  8019b1:	89 c1                	mov    %eax,%ecx
}
  8019b3:	89 c8                	mov    %ecx,%eax
  8019b5:	c9                   	leave  
  8019b6:	c3                   	ret    

008019b7 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8019b7:	55                   	push   %ebp
  8019b8:	89 e5                	mov    %esp,%ebp
  8019ba:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c0:	e8 19 ff ff ff       	call   8018de <fd2sockid>
  8019c5:	85 c0                	test   %eax,%eax
  8019c7:	78 12                	js     8019db <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8019c9:	83 ec 04             	sub    $0x4,%esp
  8019cc:	ff 75 10             	pushl  0x10(%ebp)
  8019cf:	ff 75 0c             	pushl  0xc(%ebp)
  8019d2:	50                   	push   %eax
  8019d3:	e8 2d 01 00 00       	call   801b05 <nsipc_bind>
  8019d8:	83 c4 10             	add    $0x10,%esp
}
  8019db:	c9                   	leave  
  8019dc:	c3                   	ret    

008019dd <shutdown>:

int
shutdown(int s, int how)
{
  8019dd:	55                   	push   %ebp
  8019de:	89 e5                	mov    %esp,%ebp
  8019e0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e6:	e8 f3 fe ff ff       	call   8018de <fd2sockid>
  8019eb:	85 c0                	test   %eax,%eax
  8019ed:	78 0f                	js     8019fe <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8019ef:	83 ec 08             	sub    $0x8,%esp
  8019f2:	ff 75 0c             	pushl  0xc(%ebp)
  8019f5:	50                   	push   %eax
  8019f6:	e8 3f 01 00 00       	call   801b3a <nsipc_shutdown>
  8019fb:	83 c4 10             	add    $0x10,%esp
}
  8019fe:	c9                   	leave  
  8019ff:	c3                   	ret    

00801a00 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a06:	8b 45 08             	mov    0x8(%ebp),%eax
  801a09:	e8 d0 fe ff ff       	call   8018de <fd2sockid>
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	78 12                	js     801a24 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801a12:	83 ec 04             	sub    $0x4,%esp
  801a15:	ff 75 10             	pushl  0x10(%ebp)
  801a18:	ff 75 0c             	pushl  0xc(%ebp)
  801a1b:	50                   	push   %eax
  801a1c:	e8 55 01 00 00       	call   801b76 <nsipc_connect>
  801a21:	83 c4 10             	add    $0x10,%esp
}
  801a24:	c9                   	leave  
  801a25:	c3                   	ret    

00801a26 <listen>:

int
listen(int s, int backlog)
{
  801a26:	55                   	push   %ebp
  801a27:	89 e5                	mov    %esp,%ebp
  801a29:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2f:	e8 aa fe ff ff       	call   8018de <fd2sockid>
  801a34:	85 c0                	test   %eax,%eax
  801a36:	78 0f                	js     801a47 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801a38:	83 ec 08             	sub    $0x8,%esp
  801a3b:	ff 75 0c             	pushl  0xc(%ebp)
  801a3e:	50                   	push   %eax
  801a3f:	e8 67 01 00 00       	call   801bab <nsipc_listen>
  801a44:	83 c4 10             	add    $0x10,%esp
}
  801a47:	c9                   	leave  
  801a48:	c3                   	ret    

00801a49 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801a49:	55                   	push   %ebp
  801a4a:	89 e5                	mov    %esp,%ebp
  801a4c:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a4f:	ff 75 10             	pushl  0x10(%ebp)
  801a52:	ff 75 0c             	pushl  0xc(%ebp)
  801a55:	ff 75 08             	pushl  0x8(%ebp)
  801a58:	e8 3a 02 00 00       	call   801c97 <nsipc_socket>
  801a5d:	83 c4 10             	add    $0x10,%esp
  801a60:	85 c0                	test   %eax,%eax
  801a62:	78 05                	js     801a69 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801a64:	e8 a5 fe ff ff       	call   80190e <alloc_sockfd>
}
  801a69:	c9                   	leave  
  801a6a:	c3                   	ret    

00801a6b <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	53                   	push   %ebx
  801a6f:	83 ec 04             	sub    $0x4,%esp
  801a72:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a74:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801a7b:	75 12                	jne    801a8f <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801a7d:	83 ec 0c             	sub    $0xc,%esp
  801a80:	6a 02                	push   $0x2
  801a82:	e8 be 04 00 00       	call   801f45 <ipc_find_env>
  801a87:	a3 04 40 80 00       	mov    %eax,0x804004
  801a8c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801a8f:	6a 07                	push   $0x7
  801a91:	68 00 60 80 00       	push   $0x806000
  801a96:	53                   	push   %ebx
  801a97:	ff 35 04 40 80 00    	pushl  0x804004
  801a9d:	e8 4f 04 00 00       	call   801ef1 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801aa2:	83 c4 0c             	add    $0xc,%esp
  801aa5:	6a 00                	push   $0x0
  801aa7:	6a 00                	push   $0x0
  801aa9:	6a 00                	push   $0x0
  801aab:	e8 da 03 00 00       	call   801e8a <ipc_recv>
}
  801ab0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab3:	c9                   	leave  
  801ab4:	c3                   	ret    

00801ab5 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ab5:	55                   	push   %ebp
  801ab6:	89 e5                	mov    %esp,%ebp
  801ab8:	56                   	push   %esi
  801ab9:	53                   	push   %ebx
  801aba:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801abd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ac5:	8b 06                	mov    (%esi),%eax
  801ac7:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801acc:	b8 01 00 00 00       	mov    $0x1,%eax
  801ad1:	e8 95 ff ff ff       	call   801a6b <nsipc>
  801ad6:	89 c3                	mov    %eax,%ebx
  801ad8:	85 c0                	test   %eax,%eax
  801ada:	78 20                	js     801afc <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801adc:	83 ec 04             	sub    $0x4,%esp
  801adf:	ff 35 10 60 80 00    	pushl  0x806010
  801ae5:	68 00 60 80 00       	push   $0x806000
  801aea:	ff 75 0c             	pushl  0xc(%ebp)
  801aed:	e8 8d ed ff ff       	call   80087f <memmove>
		*addrlen = ret->ret_addrlen;
  801af2:	a1 10 60 80 00       	mov    0x806010,%eax
  801af7:	89 06                	mov    %eax,(%esi)
  801af9:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801afc:	89 d8                	mov    %ebx,%eax
  801afe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b01:	5b                   	pop    %ebx
  801b02:	5e                   	pop    %esi
  801b03:	5d                   	pop    %ebp
  801b04:	c3                   	ret    

00801b05 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b05:	55                   	push   %ebp
  801b06:	89 e5                	mov    %esp,%ebp
  801b08:	53                   	push   %ebx
  801b09:	83 ec 08             	sub    $0x8,%esp
  801b0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b12:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b17:	53                   	push   %ebx
  801b18:	ff 75 0c             	pushl  0xc(%ebp)
  801b1b:	68 04 60 80 00       	push   $0x806004
  801b20:	e8 5a ed ff ff       	call   80087f <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b25:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801b2b:	b8 02 00 00 00       	mov    $0x2,%eax
  801b30:	e8 36 ff ff ff       	call   801a6b <nsipc>
}
  801b35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b38:	c9                   	leave  
  801b39:	c3                   	ret    

00801b3a <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b3a:	55                   	push   %ebp
  801b3b:	89 e5                	mov    %esp,%ebp
  801b3d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b40:	8b 45 08             	mov    0x8(%ebp),%eax
  801b43:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801b48:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b4b:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801b50:	b8 03 00 00 00       	mov    $0x3,%eax
  801b55:	e8 11 ff ff ff       	call   801a6b <nsipc>
}
  801b5a:	c9                   	leave  
  801b5b:	c3                   	ret    

00801b5c <nsipc_close>:

int
nsipc_close(int s)
{
  801b5c:	55                   	push   %ebp
  801b5d:	89 e5                	mov    %esp,%ebp
  801b5f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b62:	8b 45 08             	mov    0x8(%ebp),%eax
  801b65:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801b6a:	b8 04 00 00 00       	mov    $0x4,%eax
  801b6f:	e8 f7 fe ff ff       	call   801a6b <nsipc>
}
  801b74:	c9                   	leave  
  801b75:	c3                   	ret    

00801b76 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b76:	55                   	push   %ebp
  801b77:	89 e5                	mov    %esp,%ebp
  801b79:	53                   	push   %ebx
  801b7a:	83 ec 08             	sub    $0x8,%esp
  801b7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b80:	8b 45 08             	mov    0x8(%ebp),%eax
  801b83:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801b88:	53                   	push   %ebx
  801b89:	ff 75 0c             	pushl  0xc(%ebp)
  801b8c:	68 04 60 80 00       	push   $0x806004
  801b91:	e8 e9 ec ff ff       	call   80087f <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801b96:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801b9c:	b8 05 00 00 00       	mov    $0x5,%eax
  801ba1:	e8 c5 fe ff ff       	call   801a6b <nsipc>
}
  801ba6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ba9:	c9                   	leave  
  801baa:	c3                   	ret    

00801bab <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801bb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bbc:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801bc1:	b8 06 00 00 00       	mov    $0x6,%eax
  801bc6:	e8 a0 fe ff ff       	call   801a6b <nsipc>
}
  801bcb:	c9                   	leave  
  801bcc:	c3                   	ret    

00801bcd <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
  801bd0:	56                   	push   %esi
  801bd1:	53                   	push   %ebx
  801bd2:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801bd5:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801bdd:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801be3:	8b 45 14             	mov    0x14(%ebp),%eax
  801be6:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801beb:	b8 07 00 00 00       	mov    $0x7,%eax
  801bf0:	e8 76 fe ff ff       	call   801a6b <nsipc>
  801bf5:	89 c3                	mov    %eax,%ebx
  801bf7:	85 c0                	test   %eax,%eax
  801bf9:	78 35                	js     801c30 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801bfb:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801c00:	7f 04                	jg     801c06 <nsipc_recv+0x39>
  801c02:	39 c6                	cmp    %eax,%esi
  801c04:	7d 16                	jge    801c1c <nsipc_recv+0x4f>
  801c06:	68 ba 26 80 00       	push   $0x8026ba
  801c0b:	68 63 26 80 00       	push   $0x802663
  801c10:	6a 62                	push   $0x62
  801c12:	68 cf 26 80 00       	push   $0x8026cf
  801c17:	e8 28 02 00 00       	call   801e44 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c1c:	83 ec 04             	sub    $0x4,%esp
  801c1f:	50                   	push   %eax
  801c20:	68 00 60 80 00       	push   $0x806000
  801c25:	ff 75 0c             	pushl  0xc(%ebp)
  801c28:	e8 52 ec ff ff       	call   80087f <memmove>
  801c2d:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c30:	89 d8                	mov    %ebx,%eax
  801c32:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c35:	5b                   	pop    %ebx
  801c36:	5e                   	pop    %esi
  801c37:	5d                   	pop    %ebp
  801c38:	c3                   	ret    

00801c39 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c39:	55                   	push   %ebp
  801c3a:	89 e5                	mov    %esp,%ebp
  801c3c:	53                   	push   %ebx
  801c3d:	83 ec 04             	sub    $0x4,%esp
  801c40:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c43:	8b 45 08             	mov    0x8(%ebp),%eax
  801c46:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801c4b:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c51:	7e 16                	jle    801c69 <nsipc_send+0x30>
  801c53:	68 db 26 80 00       	push   $0x8026db
  801c58:	68 63 26 80 00       	push   $0x802663
  801c5d:	6a 6d                	push   $0x6d
  801c5f:	68 cf 26 80 00       	push   $0x8026cf
  801c64:	e8 db 01 00 00       	call   801e44 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c69:	83 ec 04             	sub    $0x4,%esp
  801c6c:	53                   	push   %ebx
  801c6d:	ff 75 0c             	pushl  0xc(%ebp)
  801c70:	68 0c 60 80 00       	push   $0x80600c
  801c75:	e8 05 ec ff ff       	call   80087f <memmove>
	nsipcbuf.send.req_size = size;
  801c7a:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801c80:	8b 45 14             	mov    0x14(%ebp),%eax
  801c83:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801c88:	b8 08 00 00 00       	mov    $0x8,%eax
  801c8d:	e8 d9 fd ff ff       	call   801a6b <nsipc>
}
  801c92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c95:	c9                   	leave  
  801c96:	c3                   	ret    

00801c97 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801c97:	55                   	push   %ebp
  801c98:	89 e5                	mov    %esp,%ebp
  801c9a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801ca5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ca8:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801cad:	8b 45 10             	mov    0x10(%ebp),%eax
  801cb0:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801cb5:	b8 09 00 00 00       	mov    $0x9,%eax
  801cba:	e8 ac fd ff ff       	call   801a6b <nsipc>
}
  801cbf:	c9                   	leave  
  801cc0:	c3                   	ret    

00801cc1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cc1:	55                   	push   %ebp
  801cc2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cc4:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc9:	5d                   	pop    %ebp
  801cca:	c3                   	ret    

00801ccb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ccb:	55                   	push   %ebp
  801ccc:	89 e5                	mov    %esp,%ebp
  801cce:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cd1:	68 e7 26 80 00       	push   $0x8026e7
  801cd6:	ff 75 0c             	pushl  0xc(%ebp)
  801cd9:	e8 0f ea ff ff       	call   8006ed <strcpy>
	return 0;
}
  801cde:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce3:	c9                   	leave  
  801ce4:	c3                   	ret    

00801ce5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ce5:	55                   	push   %ebp
  801ce6:	89 e5                	mov    %esp,%ebp
  801ce8:	57                   	push   %edi
  801ce9:	56                   	push   %esi
  801cea:	53                   	push   %ebx
  801ceb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cf1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cf6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cfc:	eb 2d                	jmp    801d2b <devcons_write+0x46>
		m = n - tot;
  801cfe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d01:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d03:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d06:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d0b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d0e:	83 ec 04             	sub    $0x4,%esp
  801d11:	53                   	push   %ebx
  801d12:	03 45 0c             	add    0xc(%ebp),%eax
  801d15:	50                   	push   %eax
  801d16:	57                   	push   %edi
  801d17:	e8 63 eb ff ff       	call   80087f <memmove>
		sys_cputs(buf, m);
  801d1c:	83 c4 08             	add    $0x8,%esp
  801d1f:	53                   	push   %ebx
  801d20:	57                   	push   %edi
  801d21:	e8 0e ed ff ff       	call   800a34 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d26:	01 de                	add    %ebx,%esi
  801d28:	83 c4 10             	add    $0x10,%esp
  801d2b:	89 f0                	mov    %esi,%eax
  801d2d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d30:	72 cc                	jb     801cfe <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d35:	5b                   	pop    %ebx
  801d36:	5e                   	pop    %esi
  801d37:	5f                   	pop    %edi
  801d38:	5d                   	pop    %ebp
  801d39:	c3                   	ret    

00801d3a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d3a:	55                   	push   %ebp
  801d3b:	89 e5                	mov    %esp,%ebp
  801d3d:	83 ec 08             	sub    $0x8,%esp
  801d40:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d45:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d49:	74 2a                	je     801d75 <devcons_read+0x3b>
  801d4b:	eb 05                	jmp    801d52 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d4d:	e8 7f ed ff ff       	call   800ad1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d52:	e8 fb ec ff ff       	call   800a52 <sys_cgetc>
  801d57:	85 c0                	test   %eax,%eax
  801d59:	74 f2                	je     801d4d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d5b:	85 c0                	test   %eax,%eax
  801d5d:	78 16                	js     801d75 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d5f:	83 f8 04             	cmp    $0x4,%eax
  801d62:	74 0c                	je     801d70 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d64:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d67:	88 02                	mov    %al,(%edx)
	return 1;
  801d69:	b8 01 00 00 00       	mov    $0x1,%eax
  801d6e:	eb 05                	jmp    801d75 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d70:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d75:	c9                   	leave  
  801d76:	c3                   	ret    

00801d77 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d77:	55                   	push   %ebp
  801d78:	89 e5                	mov    %esp,%ebp
  801d7a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d80:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d83:	6a 01                	push   $0x1
  801d85:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d88:	50                   	push   %eax
  801d89:	e8 a6 ec ff ff       	call   800a34 <sys_cputs>
}
  801d8e:	83 c4 10             	add    $0x10,%esp
  801d91:	c9                   	leave  
  801d92:	c3                   	ret    

00801d93 <getchar>:

int
getchar(void)
{
  801d93:	55                   	push   %ebp
  801d94:	89 e5                	mov    %esp,%ebp
  801d96:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d99:	6a 01                	push   $0x1
  801d9b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d9e:	50                   	push   %eax
  801d9f:	6a 00                	push   $0x0
  801da1:	e8 36 f2 ff ff       	call   800fdc <read>
	if (r < 0)
  801da6:	83 c4 10             	add    $0x10,%esp
  801da9:	85 c0                	test   %eax,%eax
  801dab:	78 0f                	js     801dbc <getchar+0x29>
		return r;
	if (r < 1)
  801dad:	85 c0                	test   %eax,%eax
  801daf:	7e 06                	jle    801db7 <getchar+0x24>
		return -E_EOF;
	return c;
  801db1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801db5:	eb 05                	jmp    801dbc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801db7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801dbc:	c9                   	leave  
  801dbd:	c3                   	ret    

00801dbe <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801dbe:	55                   	push   %ebp
  801dbf:	89 e5                	mov    %esp,%ebp
  801dc1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dc4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dc7:	50                   	push   %eax
  801dc8:	ff 75 08             	pushl  0x8(%ebp)
  801dcb:	e8 a6 ef ff ff       	call   800d76 <fd_lookup>
  801dd0:	83 c4 10             	add    $0x10,%esp
  801dd3:	85 c0                	test   %eax,%eax
  801dd5:	78 11                	js     801de8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dda:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801de0:	39 10                	cmp    %edx,(%eax)
  801de2:	0f 94 c0             	sete   %al
  801de5:	0f b6 c0             	movzbl %al,%eax
}
  801de8:	c9                   	leave  
  801de9:	c3                   	ret    

00801dea <opencons>:

int
opencons(void)
{
  801dea:	55                   	push   %ebp
  801deb:	89 e5                	mov    %esp,%ebp
  801ded:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801df0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df3:	50                   	push   %eax
  801df4:	e8 2e ef ff ff       	call   800d27 <fd_alloc>
  801df9:	83 c4 10             	add    $0x10,%esp
		return r;
  801dfc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dfe:	85 c0                	test   %eax,%eax
  801e00:	78 3e                	js     801e40 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e02:	83 ec 04             	sub    $0x4,%esp
  801e05:	68 07 04 00 00       	push   $0x407
  801e0a:	ff 75 f4             	pushl  -0xc(%ebp)
  801e0d:	6a 00                	push   $0x0
  801e0f:	e8 dc ec ff ff       	call   800af0 <sys_page_alloc>
  801e14:	83 c4 10             	add    $0x10,%esp
		return r;
  801e17:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e19:	85 c0                	test   %eax,%eax
  801e1b:	78 23                	js     801e40 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e1d:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e26:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e32:	83 ec 0c             	sub    $0xc,%esp
  801e35:	50                   	push   %eax
  801e36:	e8 c5 ee ff ff       	call   800d00 <fd2num>
  801e3b:	89 c2                	mov    %eax,%edx
  801e3d:	83 c4 10             	add    $0x10,%esp
}
  801e40:	89 d0                	mov    %edx,%eax
  801e42:	c9                   	leave  
  801e43:	c3                   	ret    

00801e44 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e44:	55                   	push   %ebp
  801e45:	89 e5                	mov    %esp,%ebp
  801e47:	56                   	push   %esi
  801e48:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e49:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e4c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e52:	e8 5b ec ff ff       	call   800ab2 <sys_getenvid>
  801e57:	83 ec 0c             	sub    $0xc,%esp
  801e5a:	ff 75 0c             	pushl  0xc(%ebp)
  801e5d:	ff 75 08             	pushl  0x8(%ebp)
  801e60:	56                   	push   %esi
  801e61:	50                   	push   %eax
  801e62:	68 f4 26 80 00       	push   $0x8026f4
  801e67:	e8 fc e2 ff ff       	call   800168 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e6c:	83 c4 18             	add    $0x18,%esp
  801e6f:	53                   	push   %ebx
  801e70:	ff 75 10             	pushl  0x10(%ebp)
  801e73:	e8 9f e2 ff ff       	call   800117 <vcprintf>
	cprintf("\n");
  801e78:	c7 04 24 a7 26 80 00 	movl   $0x8026a7,(%esp)
  801e7f:	e8 e4 e2 ff ff       	call   800168 <cprintf>
  801e84:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e87:	cc                   	int3   
  801e88:	eb fd                	jmp    801e87 <_panic+0x43>

00801e8a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e8a:	55                   	push   %ebp
  801e8b:	89 e5                	mov    %esp,%ebp
  801e8d:	56                   	push   %esi
  801e8e:	53                   	push   %ebx
  801e8f:	8b 75 08             	mov    0x8(%ebp),%esi
  801e92:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e95:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801e98:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801e9a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801e9f:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801ea2:	83 ec 0c             	sub    $0xc,%esp
  801ea5:	50                   	push   %eax
  801ea6:	e8 f5 ed ff ff       	call   800ca0 <sys_ipc_recv>

	if (from_env_store != NULL)
  801eab:	83 c4 10             	add    $0x10,%esp
  801eae:	85 f6                	test   %esi,%esi
  801eb0:	74 14                	je     801ec6 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801eb2:	ba 00 00 00 00       	mov    $0x0,%edx
  801eb7:	85 c0                	test   %eax,%eax
  801eb9:	78 09                	js     801ec4 <ipc_recv+0x3a>
  801ebb:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ec1:	8b 52 74             	mov    0x74(%edx),%edx
  801ec4:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801ec6:	85 db                	test   %ebx,%ebx
  801ec8:	74 14                	je     801ede <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801eca:	ba 00 00 00 00       	mov    $0x0,%edx
  801ecf:	85 c0                	test   %eax,%eax
  801ed1:	78 09                	js     801edc <ipc_recv+0x52>
  801ed3:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ed9:	8b 52 78             	mov    0x78(%edx),%edx
  801edc:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801ede:	85 c0                	test   %eax,%eax
  801ee0:	78 08                	js     801eea <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801ee2:	a1 08 40 80 00       	mov    0x804008,%eax
  801ee7:	8b 40 70             	mov    0x70(%eax),%eax
}
  801eea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eed:	5b                   	pop    %ebx
  801eee:	5e                   	pop    %esi
  801eef:	5d                   	pop    %ebp
  801ef0:	c3                   	ret    

00801ef1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ef1:	55                   	push   %ebp
  801ef2:	89 e5                	mov    %esp,%ebp
  801ef4:	57                   	push   %edi
  801ef5:	56                   	push   %esi
  801ef6:	53                   	push   %ebx
  801ef7:	83 ec 0c             	sub    $0xc,%esp
  801efa:	8b 7d 08             	mov    0x8(%ebp),%edi
  801efd:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f00:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f03:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f05:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f0a:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f0d:	ff 75 14             	pushl  0x14(%ebp)
  801f10:	53                   	push   %ebx
  801f11:	56                   	push   %esi
  801f12:	57                   	push   %edi
  801f13:	e8 65 ed ff ff       	call   800c7d <sys_ipc_try_send>

		if (err < 0) {
  801f18:	83 c4 10             	add    $0x10,%esp
  801f1b:	85 c0                	test   %eax,%eax
  801f1d:	79 1e                	jns    801f3d <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801f1f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f22:	75 07                	jne    801f2b <ipc_send+0x3a>
				sys_yield();
  801f24:	e8 a8 eb ff ff       	call   800ad1 <sys_yield>
  801f29:	eb e2                	jmp    801f0d <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f2b:	50                   	push   %eax
  801f2c:	68 18 27 80 00       	push   $0x802718
  801f31:	6a 49                	push   $0x49
  801f33:	68 25 27 80 00       	push   $0x802725
  801f38:	e8 07 ff ff ff       	call   801e44 <_panic>
		}

	} while (err < 0);

}
  801f3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f40:	5b                   	pop    %ebx
  801f41:	5e                   	pop    %esi
  801f42:	5f                   	pop    %edi
  801f43:	5d                   	pop    %ebp
  801f44:	c3                   	ret    

00801f45 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f45:	55                   	push   %ebp
  801f46:	89 e5                	mov    %esp,%ebp
  801f48:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f4b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f50:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f53:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f59:	8b 52 50             	mov    0x50(%edx),%edx
  801f5c:	39 ca                	cmp    %ecx,%edx
  801f5e:	75 0d                	jne    801f6d <ipc_find_env+0x28>
			return envs[i].env_id;
  801f60:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f63:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f68:	8b 40 48             	mov    0x48(%eax),%eax
  801f6b:	eb 0f                	jmp    801f7c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f6d:	83 c0 01             	add    $0x1,%eax
  801f70:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f75:	75 d9                	jne    801f50 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f7c:	5d                   	pop    %ebp
  801f7d:	c3                   	ret    

00801f7e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f7e:	55                   	push   %ebp
  801f7f:	89 e5                	mov    %esp,%ebp
  801f81:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f84:	89 d0                	mov    %edx,%eax
  801f86:	c1 e8 16             	shr    $0x16,%eax
  801f89:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f90:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f95:	f6 c1 01             	test   $0x1,%cl
  801f98:	74 1d                	je     801fb7 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f9a:	c1 ea 0c             	shr    $0xc,%edx
  801f9d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fa4:	f6 c2 01             	test   $0x1,%dl
  801fa7:	74 0e                	je     801fb7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fa9:	c1 ea 0c             	shr    $0xc,%edx
  801fac:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fb3:	ef 
  801fb4:	0f b7 c0             	movzwl %ax,%eax
}
  801fb7:	5d                   	pop    %ebp
  801fb8:	c3                   	ret    
  801fb9:	66 90                	xchg   %ax,%ax
  801fbb:	66 90                	xchg   %ax,%ax
  801fbd:	66 90                	xchg   %ax,%ax
  801fbf:	90                   	nop

00801fc0 <__udivdi3>:
  801fc0:	55                   	push   %ebp
  801fc1:	57                   	push   %edi
  801fc2:	56                   	push   %esi
  801fc3:	53                   	push   %ebx
  801fc4:	83 ec 1c             	sub    $0x1c,%esp
  801fc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fd7:	85 f6                	test   %esi,%esi
  801fd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fdd:	89 ca                	mov    %ecx,%edx
  801fdf:	89 f8                	mov    %edi,%eax
  801fe1:	75 3d                	jne    802020 <__udivdi3+0x60>
  801fe3:	39 cf                	cmp    %ecx,%edi
  801fe5:	0f 87 c5 00 00 00    	ja     8020b0 <__udivdi3+0xf0>
  801feb:	85 ff                	test   %edi,%edi
  801fed:	89 fd                	mov    %edi,%ebp
  801fef:	75 0b                	jne    801ffc <__udivdi3+0x3c>
  801ff1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ff6:	31 d2                	xor    %edx,%edx
  801ff8:	f7 f7                	div    %edi
  801ffa:	89 c5                	mov    %eax,%ebp
  801ffc:	89 c8                	mov    %ecx,%eax
  801ffe:	31 d2                	xor    %edx,%edx
  802000:	f7 f5                	div    %ebp
  802002:	89 c1                	mov    %eax,%ecx
  802004:	89 d8                	mov    %ebx,%eax
  802006:	89 cf                	mov    %ecx,%edi
  802008:	f7 f5                	div    %ebp
  80200a:	89 c3                	mov    %eax,%ebx
  80200c:	89 d8                	mov    %ebx,%eax
  80200e:	89 fa                	mov    %edi,%edx
  802010:	83 c4 1c             	add    $0x1c,%esp
  802013:	5b                   	pop    %ebx
  802014:	5e                   	pop    %esi
  802015:	5f                   	pop    %edi
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    
  802018:	90                   	nop
  802019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802020:	39 ce                	cmp    %ecx,%esi
  802022:	77 74                	ja     802098 <__udivdi3+0xd8>
  802024:	0f bd fe             	bsr    %esi,%edi
  802027:	83 f7 1f             	xor    $0x1f,%edi
  80202a:	0f 84 98 00 00 00    	je     8020c8 <__udivdi3+0x108>
  802030:	bb 20 00 00 00       	mov    $0x20,%ebx
  802035:	89 f9                	mov    %edi,%ecx
  802037:	89 c5                	mov    %eax,%ebp
  802039:	29 fb                	sub    %edi,%ebx
  80203b:	d3 e6                	shl    %cl,%esi
  80203d:	89 d9                	mov    %ebx,%ecx
  80203f:	d3 ed                	shr    %cl,%ebp
  802041:	89 f9                	mov    %edi,%ecx
  802043:	d3 e0                	shl    %cl,%eax
  802045:	09 ee                	or     %ebp,%esi
  802047:	89 d9                	mov    %ebx,%ecx
  802049:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80204d:	89 d5                	mov    %edx,%ebp
  80204f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802053:	d3 ed                	shr    %cl,%ebp
  802055:	89 f9                	mov    %edi,%ecx
  802057:	d3 e2                	shl    %cl,%edx
  802059:	89 d9                	mov    %ebx,%ecx
  80205b:	d3 e8                	shr    %cl,%eax
  80205d:	09 c2                	or     %eax,%edx
  80205f:	89 d0                	mov    %edx,%eax
  802061:	89 ea                	mov    %ebp,%edx
  802063:	f7 f6                	div    %esi
  802065:	89 d5                	mov    %edx,%ebp
  802067:	89 c3                	mov    %eax,%ebx
  802069:	f7 64 24 0c          	mull   0xc(%esp)
  80206d:	39 d5                	cmp    %edx,%ebp
  80206f:	72 10                	jb     802081 <__udivdi3+0xc1>
  802071:	8b 74 24 08          	mov    0x8(%esp),%esi
  802075:	89 f9                	mov    %edi,%ecx
  802077:	d3 e6                	shl    %cl,%esi
  802079:	39 c6                	cmp    %eax,%esi
  80207b:	73 07                	jae    802084 <__udivdi3+0xc4>
  80207d:	39 d5                	cmp    %edx,%ebp
  80207f:	75 03                	jne    802084 <__udivdi3+0xc4>
  802081:	83 eb 01             	sub    $0x1,%ebx
  802084:	31 ff                	xor    %edi,%edi
  802086:	89 d8                	mov    %ebx,%eax
  802088:	89 fa                	mov    %edi,%edx
  80208a:	83 c4 1c             	add    $0x1c,%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    
  802092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802098:	31 ff                	xor    %edi,%edi
  80209a:	31 db                	xor    %ebx,%ebx
  80209c:	89 d8                	mov    %ebx,%eax
  80209e:	89 fa                	mov    %edi,%edx
  8020a0:	83 c4 1c             	add    $0x1c,%esp
  8020a3:	5b                   	pop    %ebx
  8020a4:	5e                   	pop    %esi
  8020a5:	5f                   	pop    %edi
  8020a6:	5d                   	pop    %ebp
  8020a7:	c3                   	ret    
  8020a8:	90                   	nop
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	89 d8                	mov    %ebx,%eax
  8020b2:	f7 f7                	div    %edi
  8020b4:	31 ff                	xor    %edi,%edi
  8020b6:	89 c3                	mov    %eax,%ebx
  8020b8:	89 d8                	mov    %ebx,%eax
  8020ba:	89 fa                	mov    %edi,%edx
  8020bc:	83 c4 1c             	add    $0x1c,%esp
  8020bf:	5b                   	pop    %ebx
  8020c0:	5e                   	pop    %esi
  8020c1:	5f                   	pop    %edi
  8020c2:	5d                   	pop    %ebp
  8020c3:	c3                   	ret    
  8020c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c8:	39 ce                	cmp    %ecx,%esi
  8020ca:	72 0c                	jb     8020d8 <__udivdi3+0x118>
  8020cc:	31 db                	xor    %ebx,%ebx
  8020ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020d2:	0f 87 34 ff ff ff    	ja     80200c <__udivdi3+0x4c>
  8020d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020dd:	e9 2a ff ff ff       	jmp    80200c <__udivdi3+0x4c>
  8020e2:	66 90                	xchg   %ax,%ax
  8020e4:	66 90                	xchg   %ax,%ax
  8020e6:	66 90                	xchg   %ax,%ax
  8020e8:	66 90                	xchg   %ax,%ax
  8020ea:	66 90                	xchg   %ax,%ax
  8020ec:	66 90                	xchg   %ax,%ax
  8020ee:	66 90                	xchg   %ax,%ax

008020f0 <__umoddi3>:
  8020f0:	55                   	push   %ebp
  8020f1:	57                   	push   %edi
  8020f2:	56                   	push   %esi
  8020f3:	53                   	push   %ebx
  8020f4:	83 ec 1c             	sub    $0x1c,%esp
  8020f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802103:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802107:	85 d2                	test   %edx,%edx
  802109:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80210d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802111:	89 f3                	mov    %esi,%ebx
  802113:	89 3c 24             	mov    %edi,(%esp)
  802116:	89 74 24 04          	mov    %esi,0x4(%esp)
  80211a:	75 1c                	jne    802138 <__umoddi3+0x48>
  80211c:	39 f7                	cmp    %esi,%edi
  80211e:	76 50                	jbe    802170 <__umoddi3+0x80>
  802120:	89 c8                	mov    %ecx,%eax
  802122:	89 f2                	mov    %esi,%edx
  802124:	f7 f7                	div    %edi
  802126:	89 d0                	mov    %edx,%eax
  802128:	31 d2                	xor    %edx,%edx
  80212a:	83 c4 1c             	add    $0x1c,%esp
  80212d:	5b                   	pop    %ebx
  80212e:	5e                   	pop    %esi
  80212f:	5f                   	pop    %edi
  802130:	5d                   	pop    %ebp
  802131:	c3                   	ret    
  802132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802138:	39 f2                	cmp    %esi,%edx
  80213a:	89 d0                	mov    %edx,%eax
  80213c:	77 52                	ja     802190 <__umoddi3+0xa0>
  80213e:	0f bd ea             	bsr    %edx,%ebp
  802141:	83 f5 1f             	xor    $0x1f,%ebp
  802144:	75 5a                	jne    8021a0 <__umoddi3+0xb0>
  802146:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80214a:	0f 82 e0 00 00 00    	jb     802230 <__umoddi3+0x140>
  802150:	39 0c 24             	cmp    %ecx,(%esp)
  802153:	0f 86 d7 00 00 00    	jbe    802230 <__umoddi3+0x140>
  802159:	8b 44 24 08          	mov    0x8(%esp),%eax
  80215d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802161:	83 c4 1c             	add    $0x1c,%esp
  802164:	5b                   	pop    %ebx
  802165:	5e                   	pop    %esi
  802166:	5f                   	pop    %edi
  802167:	5d                   	pop    %ebp
  802168:	c3                   	ret    
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	85 ff                	test   %edi,%edi
  802172:	89 fd                	mov    %edi,%ebp
  802174:	75 0b                	jne    802181 <__umoddi3+0x91>
  802176:	b8 01 00 00 00       	mov    $0x1,%eax
  80217b:	31 d2                	xor    %edx,%edx
  80217d:	f7 f7                	div    %edi
  80217f:	89 c5                	mov    %eax,%ebp
  802181:	89 f0                	mov    %esi,%eax
  802183:	31 d2                	xor    %edx,%edx
  802185:	f7 f5                	div    %ebp
  802187:	89 c8                	mov    %ecx,%eax
  802189:	f7 f5                	div    %ebp
  80218b:	89 d0                	mov    %edx,%eax
  80218d:	eb 99                	jmp    802128 <__umoddi3+0x38>
  80218f:	90                   	nop
  802190:	89 c8                	mov    %ecx,%eax
  802192:	89 f2                	mov    %esi,%edx
  802194:	83 c4 1c             	add    $0x1c,%esp
  802197:	5b                   	pop    %ebx
  802198:	5e                   	pop    %esi
  802199:	5f                   	pop    %edi
  80219a:	5d                   	pop    %ebp
  80219b:	c3                   	ret    
  80219c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	8b 34 24             	mov    (%esp),%esi
  8021a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021a8:	89 e9                	mov    %ebp,%ecx
  8021aa:	29 ef                	sub    %ebp,%edi
  8021ac:	d3 e0                	shl    %cl,%eax
  8021ae:	89 f9                	mov    %edi,%ecx
  8021b0:	89 f2                	mov    %esi,%edx
  8021b2:	d3 ea                	shr    %cl,%edx
  8021b4:	89 e9                	mov    %ebp,%ecx
  8021b6:	09 c2                	or     %eax,%edx
  8021b8:	89 d8                	mov    %ebx,%eax
  8021ba:	89 14 24             	mov    %edx,(%esp)
  8021bd:	89 f2                	mov    %esi,%edx
  8021bf:	d3 e2                	shl    %cl,%edx
  8021c1:	89 f9                	mov    %edi,%ecx
  8021c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021cb:	d3 e8                	shr    %cl,%eax
  8021cd:	89 e9                	mov    %ebp,%ecx
  8021cf:	89 c6                	mov    %eax,%esi
  8021d1:	d3 e3                	shl    %cl,%ebx
  8021d3:	89 f9                	mov    %edi,%ecx
  8021d5:	89 d0                	mov    %edx,%eax
  8021d7:	d3 e8                	shr    %cl,%eax
  8021d9:	89 e9                	mov    %ebp,%ecx
  8021db:	09 d8                	or     %ebx,%eax
  8021dd:	89 d3                	mov    %edx,%ebx
  8021df:	89 f2                	mov    %esi,%edx
  8021e1:	f7 34 24             	divl   (%esp)
  8021e4:	89 d6                	mov    %edx,%esi
  8021e6:	d3 e3                	shl    %cl,%ebx
  8021e8:	f7 64 24 04          	mull   0x4(%esp)
  8021ec:	39 d6                	cmp    %edx,%esi
  8021ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021f2:	89 d1                	mov    %edx,%ecx
  8021f4:	89 c3                	mov    %eax,%ebx
  8021f6:	72 08                	jb     802200 <__umoddi3+0x110>
  8021f8:	75 11                	jne    80220b <__umoddi3+0x11b>
  8021fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021fe:	73 0b                	jae    80220b <__umoddi3+0x11b>
  802200:	2b 44 24 04          	sub    0x4(%esp),%eax
  802204:	1b 14 24             	sbb    (%esp),%edx
  802207:	89 d1                	mov    %edx,%ecx
  802209:	89 c3                	mov    %eax,%ebx
  80220b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80220f:	29 da                	sub    %ebx,%edx
  802211:	19 ce                	sbb    %ecx,%esi
  802213:	89 f9                	mov    %edi,%ecx
  802215:	89 f0                	mov    %esi,%eax
  802217:	d3 e0                	shl    %cl,%eax
  802219:	89 e9                	mov    %ebp,%ecx
  80221b:	d3 ea                	shr    %cl,%edx
  80221d:	89 e9                	mov    %ebp,%ecx
  80221f:	d3 ee                	shr    %cl,%esi
  802221:	09 d0                	or     %edx,%eax
  802223:	89 f2                	mov    %esi,%edx
  802225:	83 c4 1c             	add    $0x1c,%esp
  802228:	5b                   	pop    %ebx
  802229:	5e                   	pop    %esi
  80222a:	5f                   	pop    %edi
  80222b:	5d                   	pop    %ebp
  80222c:	c3                   	ret    
  80222d:	8d 76 00             	lea    0x0(%esi),%esi
  802230:	29 f9                	sub    %edi,%ecx
  802232:	19 d6                	sbb    %edx,%esi
  802234:	89 74 24 04          	mov    %esi,0x4(%esp)
  802238:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80223c:	e9 18 ff ff ff       	jmp    802159 <__umoddi3+0x69>
