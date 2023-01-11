
obj/user/primes.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 91 10 00 00       	call   8010dd <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 08 40 80 00       	mov    0x804008,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 60 26 80 00       	push   $0x802660
  800060:	e8 cc 01 00 00       	call   800231 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 bc 0e 00 00       	call   800f26 <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 6c 26 80 00       	push   $0x80266c
  800079:	6a 1a                	push   $0x1a
  80007b:	68 75 26 80 00       	push   $0x802675
  800080:	e8 d3 00 00 00       	call   800158 <_panic>
	if (id == 0)
  800085:	85 c0                	test   %eax,%eax
  800087:	74 b6                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800089:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80008c:	83 ec 04             	sub    $0x4,%esp
  80008f:	6a 00                	push   $0x0
  800091:	6a 00                	push   $0x0
  800093:	56                   	push   %esi
  800094:	e8 44 10 00 00       	call   8010dd <ipc_recv>
  800099:	89 c1                	mov    %eax,%ecx
		if (i % p)
  80009b:	99                   	cltd   
  80009c:	f7 fb                	idiv   %ebx
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	85 d2                	test   %edx,%edx
  8000a3:	74 e7                	je     80008c <primeproc+0x59>
			ipc_send(id, i, 0, 0);
  8000a5:	6a 00                	push   $0x0
  8000a7:	6a 00                	push   $0x0
  8000a9:	51                   	push   %ecx
  8000aa:	57                   	push   %edi
  8000ab:	e8 94 10 00 00       	call   801144 <ipc_send>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	eb d7                	jmp    80008c <primeproc+0x59>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 67 0e 00 00       	call   800f26 <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 6c 26 80 00       	push   $0x80266c
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 75 26 80 00       	push   $0x802675
  8000d2:	e8 81 00 00 00       	call   800158 <_panic>
  8000d7:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000dc:	85 c0                	test   %eax,%eax
  8000de:	75 05                	jne    8000e5 <umain+0x30>
		primeproc();
  8000e0:	e8 4e ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  8000e5:	6a 00                	push   $0x0
  8000e7:	6a 00                	push   $0x0
  8000e9:	53                   	push   %ebx
  8000ea:	56                   	push   %esi
  8000eb:	e8 54 10 00 00       	call   801144 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000f0:	83 c3 01             	add    $0x1,%ebx
  8000f3:	83 c4 10             	add    $0x10,%esp
  8000f6:	eb ed                	jmp    8000e5 <umain+0x30>

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800100:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800103:	e8 73 0a 00 00       	call   800b7b <sys_getenvid>
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800110:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800115:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011a:	85 db                	test   %ebx,%ebx
  80011c:	7e 07                	jle    800125 <libmain+0x2d>
		binaryname = argv[0];
  80011e:	8b 06                	mov    (%esi),%eax
  800120:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	e8 86 ff ff ff       	call   8000b5 <umain>

	// exit gracefully
	exit();
  80012f:	e8 0a 00 00 00       	call   80013e <exit>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5d                   	pop    %ebp
  80013d:	c3                   	ret    

0080013e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800144:	e8 53 12 00 00       	call   80139c <close_all>
	sys_env_destroy(0);
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	6a 00                	push   $0x0
  80014e:	e8 e7 09 00 00       	call   800b3a <sys_env_destroy>
}
  800153:	83 c4 10             	add    $0x10,%esp
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800160:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800166:	e8 10 0a 00 00       	call   800b7b <sys_getenvid>
  80016b:	83 ec 0c             	sub    $0xc,%esp
  80016e:	ff 75 0c             	pushl  0xc(%ebp)
  800171:	ff 75 08             	pushl  0x8(%ebp)
  800174:	56                   	push   %esi
  800175:	50                   	push   %eax
  800176:	68 90 26 80 00       	push   $0x802690
  80017b:	e8 b1 00 00 00       	call   800231 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	83 c4 18             	add    $0x18,%esp
  800183:	53                   	push   %ebx
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	e8 54 00 00 00       	call   8001e0 <vcprintf>
	cprintf("\n");
  80018c:	c7 04 24 d0 2b 80 00 	movl   $0x802bd0,(%esp)
  800193:	e8 99 00 00 00       	call   800231 <cprintf>
  800198:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019b:	cc                   	int3   
  80019c:	eb fd                	jmp    80019b <_panic+0x43>

0080019e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	53                   	push   %ebx
  8001a2:	83 ec 04             	sub    $0x4,%esp
  8001a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a8:	8b 13                	mov    (%ebx),%edx
  8001aa:	8d 42 01             	lea    0x1(%edx),%eax
  8001ad:	89 03                	mov    %eax,(%ebx)
  8001af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bb:	75 1a                	jne    8001d7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001bd:	83 ec 08             	sub    $0x8,%esp
  8001c0:	68 ff 00 00 00       	push   $0xff
  8001c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c8:	50                   	push   %eax
  8001c9:	e8 2f 09 00 00       	call   800afd <sys_cputs>
		b->idx = 0;
  8001ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001d7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f0:	00 00 00 
	b.cnt = 0;
  8001f3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fa:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fd:	ff 75 0c             	pushl  0xc(%ebp)
  800200:	ff 75 08             	pushl  0x8(%ebp)
  800203:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800209:	50                   	push   %eax
  80020a:	68 9e 01 80 00       	push   $0x80019e
  80020f:	e8 54 01 00 00       	call   800368 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800214:	83 c4 08             	add    $0x8,%esp
  800217:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800223:	50                   	push   %eax
  800224:	e8 d4 08 00 00       	call   800afd <sys_cputs>

	return b.cnt;
}
  800229:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022f:	c9                   	leave  
  800230:	c3                   	ret    

00800231 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800237:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023a:	50                   	push   %eax
  80023b:	ff 75 08             	pushl  0x8(%ebp)
  80023e:	e8 9d ff ff ff       	call   8001e0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800243:	c9                   	leave  
  800244:	c3                   	ret    

00800245 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	57                   	push   %edi
  800249:	56                   	push   %esi
  80024a:	53                   	push   %ebx
  80024b:	83 ec 1c             	sub    $0x1c,%esp
  80024e:	89 c7                	mov    %eax,%edi
  800250:	89 d6                	mov    %edx,%esi
  800252:	8b 45 08             	mov    0x8(%ebp),%eax
  800255:	8b 55 0c             	mov    0xc(%ebp),%edx
  800258:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800261:	bb 00 00 00 00       	mov    $0x0,%ebx
  800266:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800269:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80026c:	39 d3                	cmp    %edx,%ebx
  80026e:	72 05                	jb     800275 <printnum+0x30>
  800270:	39 45 10             	cmp    %eax,0x10(%ebp)
  800273:	77 45                	ja     8002ba <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800275:	83 ec 0c             	sub    $0xc,%esp
  800278:	ff 75 18             	pushl  0x18(%ebp)
  80027b:	8b 45 14             	mov    0x14(%ebp),%eax
  80027e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800281:	53                   	push   %ebx
  800282:	ff 75 10             	pushl  0x10(%ebp)
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 27 21 00 00       	call   8023c0 <__udivdi3>
  800299:	83 c4 18             	add    $0x18,%esp
  80029c:	52                   	push   %edx
  80029d:	50                   	push   %eax
  80029e:	89 f2                	mov    %esi,%edx
  8002a0:	89 f8                	mov    %edi,%eax
  8002a2:	e8 9e ff ff ff       	call   800245 <printnum>
  8002a7:	83 c4 20             	add    $0x20,%esp
  8002aa:	eb 18                	jmp    8002c4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ac:	83 ec 08             	sub    $0x8,%esp
  8002af:	56                   	push   %esi
  8002b0:	ff 75 18             	pushl  0x18(%ebp)
  8002b3:	ff d7                	call   *%edi
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	eb 03                	jmp    8002bd <printnum+0x78>
  8002ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002bd:	83 eb 01             	sub    $0x1,%ebx
  8002c0:	85 db                	test   %ebx,%ebx
  8002c2:	7f e8                	jg     8002ac <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c4:	83 ec 08             	sub    $0x8,%esp
  8002c7:	56                   	push   %esi
  8002c8:	83 ec 04             	sub    $0x4,%esp
  8002cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d7:	e8 14 22 00 00       	call   8024f0 <__umoddi3>
  8002dc:	83 c4 14             	add    $0x14,%esp
  8002df:	0f be 80 b3 26 80 00 	movsbl 0x8026b3(%eax),%eax
  8002e6:	50                   	push   %eax
  8002e7:	ff d7                	call   *%edi
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ef:	5b                   	pop    %ebx
  8002f0:	5e                   	pop    %esi
  8002f1:	5f                   	pop    %edi
  8002f2:	5d                   	pop    %ebp
  8002f3:	c3                   	ret    

008002f4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f7:	83 fa 01             	cmp    $0x1,%edx
  8002fa:	7e 0e                	jle    80030a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	8d 4a 08             	lea    0x8(%edx),%ecx
  800301:	89 08                	mov    %ecx,(%eax)
  800303:	8b 02                	mov    (%edx),%eax
  800305:	8b 52 04             	mov    0x4(%edx),%edx
  800308:	eb 22                	jmp    80032c <getuint+0x38>
	else if (lflag)
  80030a:	85 d2                	test   %edx,%edx
  80030c:	74 10                	je     80031e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80030e:	8b 10                	mov    (%eax),%edx
  800310:	8d 4a 04             	lea    0x4(%edx),%ecx
  800313:	89 08                	mov    %ecx,(%eax)
  800315:	8b 02                	mov    (%edx),%eax
  800317:	ba 00 00 00 00       	mov    $0x0,%edx
  80031c:	eb 0e                	jmp    80032c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80031e:	8b 10                	mov    (%eax),%edx
  800320:	8d 4a 04             	lea    0x4(%edx),%ecx
  800323:	89 08                	mov    %ecx,(%eax)
  800325:	8b 02                	mov    (%edx),%eax
  800327:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032c:	5d                   	pop    %ebp
  80032d:	c3                   	ret    

0080032e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800334:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800338:	8b 10                	mov    (%eax),%edx
  80033a:	3b 50 04             	cmp    0x4(%eax),%edx
  80033d:	73 0a                	jae    800349 <sprintputch+0x1b>
		*b->buf++ = ch;
  80033f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800342:	89 08                	mov    %ecx,(%eax)
  800344:	8b 45 08             	mov    0x8(%ebp),%eax
  800347:	88 02                	mov    %al,(%edx)
}
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800351:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800354:	50                   	push   %eax
  800355:	ff 75 10             	pushl  0x10(%ebp)
  800358:	ff 75 0c             	pushl  0xc(%ebp)
  80035b:	ff 75 08             	pushl  0x8(%ebp)
  80035e:	e8 05 00 00 00       	call   800368 <vprintfmt>
	va_end(ap);
}
  800363:	83 c4 10             	add    $0x10,%esp
  800366:	c9                   	leave  
  800367:	c3                   	ret    

00800368 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	57                   	push   %edi
  80036c:	56                   	push   %esi
  80036d:	53                   	push   %ebx
  80036e:	83 ec 2c             	sub    $0x2c,%esp
  800371:	8b 75 08             	mov    0x8(%ebp),%esi
  800374:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800377:	8b 7d 10             	mov    0x10(%ebp),%edi
  80037a:	eb 12                	jmp    80038e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037c:	85 c0                	test   %eax,%eax
  80037e:	0f 84 89 03 00 00    	je     80070d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800384:	83 ec 08             	sub    $0x8,%esp
  800387:	53                   	push   %ebx
  800388:	50                   	push   %eax
  800389:	ff d6                	call   *%esi
  80038b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038e:	83 c7 01             	add    $0x1,%edi
  800391:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800395:	83 f8 25             	cmp    $0x25,%eax
  800398:	75 e2                	jne    80037c <vprintfmt+0x14>
  80039a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80039e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003a5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ac:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b8:	eb 07                	jmp    8003c1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003bd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8d 47 01             	lea    0x1(%edi),%eax
  8003c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c7:	0f b6 07             	movzbl (%edi),%eax
  8003ca:	0f b6 c8             	movzbl %al,%ecx
  8003cd:	83 e8 23             	sub    $0x23,%eax
  8003d0:	3c 55                	cmp    $0x55,%al
  8003d2:	0f 87 1a 03 00 00    	ja     8006f2 <vprintfmt+0x38a>
  8003d8:	0f b6 c0             	movzbl %al,%eax
  8003db:	ff 24 85 00 28 80 00 	jmp    *0x802800(,%eax,4)
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003e9:	eb d6                	jmp    8003c1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003f9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003fd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800400:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800403:	83 fa 09             	cmp    $0x9,%edx
  800406:	77 39                	ja     800441 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800408:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80040b:	eb e9                	jmp    8003f6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	8d 48 04             	lea    0x4(%eax),%ecx
  800413:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800416:	8b 00                	mov    (%eax),%eax
  800418:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80041e:	eb 27                	jmp    800447 <vprintfmt+0xdf>
  800420:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800423:	85 c0                	test   %eax,%eax
  800425:	b9 00 00 00 00       	mov    $0x0,%ecx
  80042a:	0f 49 c8             	cmovns %eax,%ecx
  80042d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800430:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800433:	eb 8c                	jmp    8003c1 <vprintfmt+0x59>
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800438:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80043f:	eb 80                	jmp    8003c1 <vprintfmt+0x59>
  800441:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800444:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800447:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044b:	0f 89 70 ff ff ff    	jns    8003c1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800451:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800454:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800457:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80045e:	e9 5e ff ff ff       	jmp    8003c1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800463:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800469:	e9 53 ff ff ff       	jmp    8003c1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80046e:	8b 45 14             	mov    0x14(%ebp),%eax
  800471:	8d 50 04             	lea    0x4(%eax),%edx
  800474:	89 55 14             	mov    %edx,0x14(%ebp)
  800477:	83 ec 08             	sub    $0x8,%esp
  80047a:	53                   	push   %ebx
  80047b:	ff 30                	pushl  (%eax)
  80047d:	ff d6                	call   *%esi
			break;
  80047f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800485:	e9 04 ff ff ff       	jmp    80038e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80048a:	8b 45 14             	mov    0x14(%ebp),%eax
  80048d:	8d 50 04             	lea    0x4(%eax),%edx
  800490:	89 55 14             	mov    %edx,0x14(%ebp)
  800493:	8b 00                	mov    (%eax),%eax
  800495:	99                   	cltd   
  800496:	31 d0                	xor    %edx,%eax
  800498:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049a:	83 f8 0f             	cmp    $0xf,%eax
  80049d:	7f 0b                	jg     8004aa <vprintfmt+0x142>
  80049f:	8b 14 85 60 29 80 00 	mov    0x802960(,%eax,4),%edx
  8004a6:	85 d2                	test   %edx,%edx
  8004a8:	75 18                	jne    8004c2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004aa:	50                   	push   %eax
  8004ab:	68 cb 26 80 00       	push   $0x8026cb
  8004b0:	53                   	push   %ebx
  8004b1:	56                   	push   %esi
  8004b2:	e8 94 fe ff ff       	call   80034b <printfmt>
  8004b7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004bd:	e9 cc fe ff ff       	jmp    80038e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004c2:	52                   	push   %edx
  8004c3:	68 65 2b 80 00       	push   $0x802b65
  8004c8:	53                   	push   %ebx
  8004c9:	56                   	push   %esi
  8004ca:	e8 7c fe ff ff       	call   80034b <printfmt>
  8004cf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d5:	e9 b4 fe ff ff       	jmp    80038e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004da:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dd:	8d 50 04             	lea    0x4(%eax),%edx
  8004e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004e5:	85 ff                	test   %edi,%edi
  8004e7:	b8 c4 26 80 00       	mov    $0x8026c4,%eax
  8004ec:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004ef:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f3:	0f 8e 94 00 00 00    	jle    80058d <vprintfmt+0x225>
  8004f9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004fd:	0f 84 98 00 00 00    	je     80059b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800503:	83 ec 08             	sub    $0x8,%esp
  800506:	ff 75 d0             	pushl  -0x30(%ebp)
  800509:	57                   	push   %edi
  80050a:	e8 86 02 00 00       	call   800795 <strnlen>
  80050f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800512:	29 c1                	sub    %eax,%ecx
  800514:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800517:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80051a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80051e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800521:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800524:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800526:	eb 0f                	jmp    800537 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	53                   	push   %ebx
  80052c:	ff 75 e0             	pushl  -0x20(%ebp)
  80052f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800531:	83 ef 01             	sub    $0x1,%edi
  800534:	83 c4 10             	add    $0x10,%esp
  800537:	85 ff                	test   %edi,%edi
  800539:	7f ed                	jg     800528 <vprintfmt+0x1c0>
  80053b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80053e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800541:	85 c9                	test   %ecx,%ecx
  800543:	b8 00 00 00 00       	mov    $0x0,%eax
  800548:	0f 49 c1             	cmovns %ecx,%eax
  80054b:	29 c1                	sub    %eax,%ecx
  80054d:	89 75 08             	mov    %esi,0x8(%ebp)
  800550:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800553:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800556:	89 cb                	mov    %ecx,%ebx
  800558:	eb 4d                	jmp    8005a7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80055a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80055e:	74 1b                	je     80057b <vprintfmt+0x213>
  800560:	0f be c0             	movsbl %al,%eax
  800563:	83 e8 20             	sub    $0x20,%eax
  800566:	83 f8 5e             	cmp    $0x5e,%eax
  800569:	76 10                	jbe    80057b <vprintfmt+0x213>
					putch('?', putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	ff 75 0c             	pushl  0xc(%ebp)
  800571:	6a 3f                	push   $0x3f
  800573:	ff 55 08             	call   *0x8(%ebp)
  800576:	83 c4 10             	add    $0x10,%esp
  800579:	eb 0d                	jmp    800588 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	ff 75 0c             	pushl  0xc(%ebp)
  800581:	52                   	push   %edx
  800582:	ff 55 08             	call   *0x8(%ebp)
  800585:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800588:	83 eb 01             	sub    $0x1,%ebx
  80058b:	eb 1a                	jmp    8005a7 <vprintfmt+0x23f>
  80058d:	89 75 08             	mov    %esi,0x8(%ebp)
  800590:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800593:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800596:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800599:	eb 0c                	jmp    8005a7 <vprintfmt+0x23f>
  80059b:	89 75 08             	mov    %esi,0x8(%ebp)
  80059e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a7:	83 c7 01             	add    $0x1,%edi
  8005aa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005ae:	0f be d0             	movsbl %al,%edx
  8005b1:	85 d2                	test   %edx,%edx
  8005b3:	74 23                	je     8005d8 <vprintfmt+0x270>
  8005b5:	85 f6                	test   %esi,%esi
  8005b7:	78 a1                	js     80055a <vprintfmt+0x1f2>
  8005b9:	83 ee 01             	sub    $0x1,%esi
  8005bc:	79 9c                	jns    80055a <vprintfmt+0x1f2>
  8005be:	89 df                	mov    %ebx,%edi
  8005c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c6:	eb 18                	jmp    8005e0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005c8:	83 ec 08             	sub    $0x8,%esp
  8005cb:	53                   	push   %ebx
  8005cc:	6a 20                	push   $0x20
  8005ce:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d0:	83 ef 01             	sub    $0x1,%edi
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	eb 08                	jmp    8005e0 <vprintfmt+0x278>
  8005d8:	89 df                	mov    %ebx,%edi
  8005da:	8b 75 08             	mov    0x8(%ebp),%esi
  8005dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e0:	85 ff                	test   %edi,%edi
  8005e2:	7f e4                	jg     8005c8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e7:	e9 a2 fd ff ff       	jmp    80038e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ec:	83 fa 01             	cmp    $0x1,%edx
  8005ef:	7e 16                	jle    800607 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8d 50 08             	lea    0x8(%eax),%edx
  8005f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fa:	8b 50 04             	mov    0x4(%eax),%edx
  8005fd:	8b 00                	mov    (%eax),%eax
  8005ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800602:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800605:	eb 32                	jmp    800639 <vprintfmt+0x2d1>
	else if (lflag)
  800607:	85 d2                	test   %edx,%edx
  800609:	74 18                	je     800623 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8d 50 04             	lea    0x4(%eax),%edx
  800611:	89 55 14             	mov    %edx,0x14(%ebp)
  800614:	8b 00                	mov    (%eax),%eax
  800616:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800619:	89 c1                	mov    %eax,%ecx
  80061b:	c1 f9 1f             	sar    $0x1f,%ecx
  80061e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800621:	eb 16                	jmp    800639 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8d 50 04             	lea    0x4(%eax),%edx
  800629:	89 55 14             	mov    %edx,0x14(%ebp)
  80062c:	8b 00                	mov    (%eax),%eax
  80062e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800631:	89 c1                	mov    %eax,%ecx
  800633:	c1 f9 1f             	sar    $0x1f,%ecx
  800636:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800639:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80063c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80063f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800644:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800648:	79 74                	jns    8006be <vprintfmt+0x356>
				putch('-', putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	53                   	push   %ebx
  80064e:	6a 2d                	push   $0x2d
  800650:	ff d6                	call   *%esi
				num = -(long long) num;
  800652:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800655:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800658:	f7 d8                	neg    %eax
  80065a:	83 d2 00             	adc    $0x0,%edx
  80065d:	f7 da                	neg    %edx
  80065f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800662:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800667:	eb 55                	jmp    8006be <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800669:	8d 45 14             	lea    0x14(%ebp),%eax
  80066c:	e8 83 fc ff ff       	call   8002f4 <getuint>
			base = 10;
  800671:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800676:	eb 46                	jmp    8006be <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800678:	8d 45 14             	lea    0x14(%ebp),%eax
  80067b:	e8 74 fc ff ff       	call   8002f4 <getuint>
			base = 8;
  800680:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800685:	eb 37                	jmp    8006be <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800687:	83 ec 08             	sub    $0x8,%esp
  80068a:	53                   	push   %ebx
  80068b:	6a 30                	push   $0x30
  80068d:	ff d6                	call   *%esi
			putch('x', putdat);
  80068f:	83 c4 08             	add    $0x8,%esp
  800692:	53                   	push   %ebx
  800693:	6a 78                	push   $0x78
  800695:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8d 50 04             	lea    0x4(%eax),%edx
  80069d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a0:	8b 00                	mov    (%eax),%eax
  8006a2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006aa:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006af:	eb 0d                	jmp    8006be <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b4:	e8 3b fc ff ff       	call   8002f4 <getuint>
			base = 16;
  8006b9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006be:	83 ec 0c             	sub    $0xc,%esp
  8006c1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006c5:	57                   	push   %edi
  8006c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c9:	51                   	push   %ecx
  8006ca:	52                   	push   %edx
  8006cb:	50                   	push   %eax
  8006cc:	89 da                	mov    %ebx,%edx
  8006ce:	89 f0                	mov    %esi,%eax
  8006d0:	e8 70 fb ff ff       	call   800245 <printnum>
			break;
  8006d5:	83 c4 20             	add    $0x20,%esp
  8006d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006db:	e9 ae fc ff ff       	jmp    80038e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e0:	83 ec 08             	sub    $0x8,%esp
  8006e3:	53                   	push   %ebx
  8006e4:	51                   	push   %ecx
  8006e5:	ff d6                	call   *%esi
			break;
  8006e7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ed:	e9 9c fc ff ff       	jmp    80038e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	53                   	push   %ebx
  8006f6:	6a 25                	push   $0x25
  8006f8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	eb 03                	jmp    800702 <vprintfmt+0x39a>
  8006ff:	83 ef 01             	sub    $0x1,%edi
  800702:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800706:	75 f7                	jne    8006ff <vprintfmt+0x397>
  800708:	e9 81 fc ff ff       	jmp    80038e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80070d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800710:	5b                   	pop    %ebx
  800711:	5e                   	pop    %esi
  800712:	5f                   	pop    %edi
  800713:	5d                   	pop    %ebp
  800714:	c3                   	ret    

00800715 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800715:	55                   	push   %ebp
  800716:	89 e5                	mov    %esp,%ebp
  800718:	83 ec 18             	sub    $0x18,%esp
  80071b:	8b 45 08             	mov    0x8(%ebp),%eax
  80071e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800721:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800724:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800728:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800732:	85 c0                	test   %eax,%eax
  800734:	74 26                	je     80075c <vsnprintf+0x47>
  800736:	85 d2                	test   %edx,%edx
  800738:	7e 22                	jle    80075c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073a:	ff 75 14             	pushl  0x14(%ebp)
  80073d:	ff 75 10             	pushl  0x10(%ebp)
  800740:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800743:	50                   	push   %eax
  800744:	68 2e 03 80 00       	push   $0x80032e
  800749:	e8 1a fc ff ff       	call   800368 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800751:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800754:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800757:	83 c4 10             	add    $0x10,%esp
  80075a:	eb 05                	jmp    800761 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800761:	c9                   	leave  
  800762:	c3                   	ret    

00800763 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800769:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076c:	50                   	push   %eax
  80076d:	ff 75 10             	pushl  0x10(%ebp)
  800770:	ff 75 0c             	pushl  0xc(%ebp)
  800773:	ff 75 08             	pushl  0x8(%ebp)
  800776:	e8 9a ff ff ff       	call   800715 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077b:	c9                   	leave  
  80077c:	c3                   	ret    

0080077d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800783:	b8 00 00 00 00       	mov    $0x0,%eax
  800788:	eb 03                	jmp    80078d <strlen+0x10>
		n++;
  80078a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80078d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800791:	75 f7                	jne    80078a <strlen+0xd>
		n++;
	return n;
}
  800793:	5d                   	pop    %ebp
  800794:	c3                   	ret    

00800795 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079e:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a3:	eb 03                	jmp    8007a8 <strnlen+0x13>
		n++;
  8007a5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a8:	39 c2                	cmp    %eax,%edx
  8007aa:	74 08                	je     8007b4 <strnlen+0x1f>
  8007ac:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007b0:	75 f3                	jne    8007a5 <strnlen+0x10>
  8007b2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	53                   	push   %ebx
  8007ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c0:	89 c2                	mov    %eax,%edx
  8007c2:	83 c2 01             	add    $0x1,%edx
  8007c5:	83 c1 01             	add    $0x1,%ecx
  8007c8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007cc:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007cf:	84 db                	test   %bl,%bl
  8007d1:	75 ef                	jne    8007c2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d3:	5b                   	pop    %ebx
  8007d4:	5d                   	pop    %ebp
  8007d5:	c3                   	ret    

008007d6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	53                   	push   %ebx
  8007da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007dd:	53                   	push   %ebx
  8007de:	e8 9a ff ff ff       	call   80077d <strlen>
  8007e3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e6:	ff 75 0c             	pushl  0xc(%ebp)
  8007e9:	01 d8                	add    %ebx,%eax
  8007eb:	50                   	push   %eax
  8007ec:	e8 c5 ff ff ff       	call   8007b6 <strcpy>
	return dst;
}
  8007f1:	89 d8                	mov    %ebx,%eax
  8007f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f6:	c9                   	leave  
  8007f7:	c3                   	ret    

008007f8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	56                   	push   %esi
  8007fc:	53                   	push   %ebx
  8007fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800800:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800803:	89 f3                	mov    %esi,%ebx
  800805:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800808:	89 f2                	mov    %esi,%edx
  80080a:	eb 0f                	jmp    80081b <strncpy+0x23>
		*dst++ = *src;
  80080c:	83 c2 01             	add    $0x1,%edx
  80080f:	0f b6 01             	movzbl (%ecx),%eax
  800812:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800815:	80 39 01             	cmpb   $0x1,(%ecx)
  800818:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081b:	39 da                	cmp    %ebx,%edx
  80081d:	75 ed                	jne    80080c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80081f:	89 f0                	mov    %esi,%eax
  800821:	5b                   	pop    %ebx
  800822:	5e                   	pop    %esi
  800823:	5d                   	pop    %ebp
  800824:	c3                   	ret    

00800825 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	56                   	push   %esi
  800829:	53                   	push   %ebx
  80082a:	8b 75 08             	mov    0x8(%ebp),%esi
  80082d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800830:	8b 55 10             	mov    0x10(%ebp),%edx
  800833:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800835:	85 d2                	test   %edx,%edx
  800837:	74 21                	je     80085a <strlcpy+0x35>
  800839:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80083d:	89 f2                	mov    %esi,%edx
  80083f:	eb 09                	jmp    80084a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800841:	83 c2 01             	add    $0x1,%edx
  800844:	83 c1 01             	add    $0x1,%ecx
  800847:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80084a:	39 c2                	cmp    %eax,%edx
  80084c:	74 09                	je     800857 <strlcpy+0x32>
  80084e:	0f b6 19             	movzbl (%ecx),%ebx
  800851:	84 db                	test   %bl,%bl
  800853:	75 ec                	jne    800841 <strlcpy+0x1c>
  800855:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800857:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80085a:	29 f0                	sub    %esi,%eax
}
  80085c:	5b                   	pop    %ebx
  80085d:	5e                   	pop    %esi
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800866:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800869:	eb 06                	jmp    800871 <strcmp+0x11>
		p++, q++;
  80086b:	83 c1 01             	add    $0x1,%ecx
  80086e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800871:	0f b6 01             	movzbl (%ecx),%eax
  800874:	84 c0                	test   %al,%al
  800876:	74 04                	je     80087c <strcmp+0x1c>
  800878:	3a 02                	cmp    (%edx),%al
  80087a:	74 ef                	je     80086b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087c:	0f b6 c0             	movzbl %al,%eax
  80087f:	0f b6 12             	movzbl (%edx),%edx
  800882:	29 d0                	sub    %edx,%eax
}
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	53                   	push   %ebx
  80088a:	8b 45 08             	mov    0x8(%ebp),%eax
  80088d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800890:	89 c3                	mov    %eax,%ebx
  800892:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800895:	eb 06                	jmp    80089d <strncmp+0x17>
		n--, p++, q++;
  800897:	83 c0 01             	add    $0x1,%eax
  80089a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80089d:	39 d8                	cmp    %ebx,%eax
  80089f:	74 15                	je     8008b6 <strncmp+0x30>
  8008a1:	0f b6 08             	movzbl (%eax),%ecx
  8008a4:	84 c9                	test   %cl,%cl
  8008a6:	74 04                	je     8008ac <strncmp+0x26>
  8008a8:	3a 0a                	cmp    (%edx),%cl
  8008aa:	74 eb                	je     800897 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ac:	0f b6 00             	movzbl (%eax),%eax
  8008af:	0f b6 12             	movzbl (%edx),%edx
  8008b2:	29 d0                	sub    %edx,%eax
  8008b4:	eb 05                	jmp    8008bb <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008bb:	5b                   	pop    %ebx
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c8:	eb 07                	jmp    8008d1 <strchr+0x13>
		if (*s == c)
  8008ca:	38 ca                	cmp    %cl,%dl
  8008cc:	74 0f                	je     8008dd <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ce:	83 c0 01             	add    $0x1,%eax
  8008d1:	0f b6 10             	movzbl (%eax),%edx
  8008d4:	84 d2                	test   %dl,%dl
  8008d6:	75 f2                	jne    8008ca <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e9:	eb 03                	jmp    8008ee <strfind+0xf>
  8008eb:	83 c0 01             	add    $0x1,%eax
  8008ee:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f1:	38 ca                	cmp    %cl,%dl
  8008f3:	74 04                	je     8008f9 <strfind+0x1a>
  8008f5:	84 d2                	test   %dl,%dl
  8008f7:	75 f2                	jne    8008eb <strfind+0xc>
			break;
	return (char *) s;
}
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	57                   	push   %edi
  8008ff:	56                   	push   %esi
  800900:	53                   	push   %ebx
  800901:	8b 7d 08             	mov    0x8(%ebp),%edi
  800904:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800907:	85 c9                	test   %ecx,%ecx
  800909:	74 36                	je     800941 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800911:	75 28                	jne    80093b <memset+0x40>
  800913:	f6 c1 03             	test   $0x3,%cl
  800916:	75 23                	jne    80093b <memset+0x40>
		c &= 0xFF;
  800918:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091c:	89 d3                	mov    %edx,%ebx
  80091e:	c1 e3 08             	shl    $0x8,%ebx
  800921:	89 d6                	mov    %edx,%esi
  800923:	c1 e6 18             	shl    $0x18,%esi
  800926:	89 d0                	mov    %edx,%eax
  800928:	c1 e0 10             	shl    $0x10,%eax
  80092b:	09 f0                	or     %esi,%eax
  80092d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80092f:	89 d8                	mov    %ebx,%eax
  800931:	09 d0                	or     %edx,%eax
  800933:	c1 e9 02             	shr    $0x2,%ecx
  800936:	fc                   	cld    
  800937:	f3 ab                	rep stos %eax,%es:(%edi)
  800939:	eb 06                	jmp    800941 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093e:	fc                   	cld    
  80093f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800941:	89 f8                	mov    %edi,%eax
  800943:	5b                   	pop    %ebx
  800944:	5e                   	pop    %esi
  800945:	5f                   	pop    %edi
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	57                   	push   %edi
  80094c:	56                   	push   %esi
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
  800950:	8b 75 0c             	mov    0xc(%ebp),%esi
  800953:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800956:	39 c6                	cmp    %eax,%esi
  800958:	73 35                	jae    80098f <memmove+0x47>
  80095a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095d:	39 d0                	cmp    %edx,%eax
  80095f:	73 2e                	jae    80098f <memmove+0x47>
		s += n;
		d += n;
  800961:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800964:	89 d6                	mov    %edx,%esi
  800966:	09 fe                	or     %edi,%esi
  800968:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096e:	75 13                	jne    800983 <memmove+0x3b>
  800970:	f6 c1 03             	test   $0x3,%cl
  800973:	75 0e                	jne    800983 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800975:	83 ef 04             	sub    $0x4,%edi
  800978:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097b:	c1 e9 02             	shr    $0x2,%ecx
  80097e:	fd                   	std    
  80097f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800981:	eb 09                	jmp    80098c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800983:	83 ef 01             	sub    $0x1,%edi
  800986:	8d 72 ff             	lea    -0x1(%edx),%esi
  800989:	fd                   	std    
  80098a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098c:	fc                   	cld    
  80098d:	eb 1d                	jmp    8009ac <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098f:	89 f2                	mov    %esi,%edx
  800991:	09 c2                	or     %eax,%edx
  800993:	f6 c2 03             	test   $0x3,%dl
  800996:	75 0f                	jne    8009a7 <memmove+0x5f>
  800998:	f6 c1 03             	test   $0x3,%cl
  80099b:	75 0a                	jne    8009a7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80099d:	c1 e9 02             	shr    $0x2,%ecx
  8009a0:	89 c7                	mov    %eax,%edi
  8009a2:	fc                   	cld    
  8009a3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a5:	eb 05                	jmp    8009ac <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a7:	89 c7                	mov    %eax,%edi
  8009a9:	fc                   	cld    
  8009aa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ac:	5e                   	pop    %esi
  8009ad:	5f                   	pop    %edi
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    

008009b0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b3:	ff 75 10             	pushl  0x10(%ebp)
  8009b6:	ff 75 0c             	pushl  0xc(%ebp)
  8009b9:	ff 75 08             	pushl  0x8(%ebp)
  8009bc:	e8 87 ff ff ff       	call   800948 <memmove>
}
  8009c1:	c9                   	leave  
  8009c2:	c3                   	ret    

008009c3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	56                   	push   %esi
  8009c7:	53                   	push   %ebx
  8009c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ce:	89 c6                	mov    %eax,%esi
  8009d0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d3:	eb 1a                	jmp    8009ef <memcmp+0x2c>
		if (*s1 != *s2)
  8009d5:	0f b6 08             	movzbl (%eax),%ecx
  8009d8:	0f b6 1a             	movzbl (%edx),%ebx
  8009db:	38 d9                	cmp    %bl,%cl
  8009dd:	74 0a                	je     8009e9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009df:	0f b6 c1             	movzbl %cl,%eax
  8009e2:	0f b6 db             	movzbl %bl,%ebx
  8009e5:	29 d8                	sub    %ebx,%eax
  8009e7:	eb 0f                	jmp    8009f8 <memcmp+0x35>
		s1++, s2++;
  8009e9:	83 c0 01             	add    $0x1,%eax
  8009ec:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ef:	39 f0                	cmp    %esi,%eax
  8009f1:	75 e2                	jne    8009d5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f8:	5b                   	pop    %ebx
  8009f9:	5e                   	pop    %esi
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	53                   	push   %ebx
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a03:	89 c1                	mov    %eax,%ecx
  800a05:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a08:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0c:	eb 0a                	jmp    800a18 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0e:	0f b6 10             	movzbl (%eax),%edx
  800a11:	39 da                	cmp    %ebx,%edx
  800a13:	74 07                	je     800a1c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a15:	83 c0 01             	add    $0x1,%eax
  800a18:	39 c8                	cmp    %ecx,%eax
  800a1a:	72 f2                	jb     800a0e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a1c:	5b                   	pop    %ebx
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	57                   	push   %edi
  800a23:	56                   	push   %esi
  800a24:	53                   	push   %ebx
  800a25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a28:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2b:	eb 03                	jmp    800a30 <strtol+0x11>
		s++;
  800a2d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a30:	0f b6 01             	movzbl (%ecx),%eax
  800a33:	3c 20                	cmp    $0x20,%al
  800a35:	74 f6                	je     800a2d <strtol+0xe>
  800a37:	3c 09                	cmp    $0x9,%al
  800a39:	74 f2                	je     800a2d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a3b:	3c 2b                	cmp    $0x2b,%al
  800a3d:	75 0a                	jne    800a49 <strtol+0x2a>
		s++;
  800a3f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a42:	bf 00 00 00 00       	mov    $0x0,%edi
  800a47:	eb 11                	jmp    800a5a <strtol+0x3b>
  800a49:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a4e:	3c 2d                	cmp    $0x2d,%al
  800a50:	75 08                	jne    800a5a <strtol+0x3b>
		s++, neg = 1;
  800a52:	83 c1 01             	add    $0x1,%ecx
  800a55:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a60:	75 15                	jne    800a77 <strtol+0x58>
  800a62:	80 39 30             	cmpb   $0x30,(%ecx)
  800a65:	75 10                	jne    800a77 <strtol+0x58>
  800a67:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a6b:	75 7c                	jne    800ae9 <strtol+0xca>
		s += 2, base = 16;
  800a6d:	83 c1 02             	add    $0x2,%ecx
  800a70:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a75:	eb 16                	jmp    800a8d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a77:	85 db                	test   %ebx,%ebx
  800a79:	75 12                	jne    800a8d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a80:	80 39 30             	cmpb   $0x30,(%ecx)
  800a83:	75 08                	jne    800a8d <strtol+0x6e>
		s++, base = 8;
  800a85:	83 c1 01             	add    $0x1,%ecx
  800a88:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a92:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a95:	0f b6 11             	movzbl (%ecx),%edx
  800a98:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a9b:	89 f3                	mov    %esi,%ebx
  800a9d:	80 fb 09             	cmp    $0x9,%bl
  800aa0:	77 08                	ja     800aaa <strtol+0x8b>
			dig = *s - '0';
  800aa2:	0f be d2             	movsbl %dl,%edx
  800aa5:	83 ea 30             	sub    $0x30,%edx
  800aa8:	eb 22                	jmp    800acc <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aaa:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aad:	89 f3                	mov    %esi,%ebx
  800aaf:	80 fb 19             	cmp    $0x19,%bl
  800ab2:	77 08                	ja     800abc <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ab4:	0f be d2             	movsbl %dl,%edx
  800ab7:	83 ea 57             	sub    $0x57,%edx
  800aba:	eb 10                	jmp    800acc <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800abc:	8d 72 bf             	lea    -0x41(%edx),%esi
  800abf:	89 f3                	mov    %esi,%ebx
  800ac1:	80 fb 19             	cmp    $0x19,%bl
  800ac4:	77 16                	ja     800adc <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ac6:	0f be d2             	movsbl %dl,%edx
  800ac9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800acc:	3b 55 10             	cmp    0x10(%ebp),%edx
  800acf:	7d 0b                	jge    800adc <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad1:	83 c1 01             	add    $0x1,%ecx
  800ad4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ada:	eb b9                	jmp    800a95 <strtol+0x76>

	if (endptr)
  800adc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae0:	74 0d                	je     800aef <strtol+0xd0>
		*endptr = (char *) s;
  800ae2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae5:	89 0e                	mov    %ecx,(%esi)
  800ae7:	eb 06                	jmp    800aef <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae9:	85 db                	test   %ebx,%ebx
  800aeb:	74 98                	je     800a85 <strtol+0x66>
  800aed:	eb 9e                	jmp    800a8d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aef:	89 c2                	mov    %eax,%edx
  800af1:	f7 da                	neg    %edx
  800af3:	85 ff                	test   %edi,%edi
  800af5:	0f 45 c2             	cmovne %edx,%eax
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b03:	b8 00 00 00 00       	mov    $0x0,%eax
  800b08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0e:	89 c3                	mov    %eax,%ebx
  800b10:	89 c7                	mov    %eax,%edi
  800b12:	89 c6                	mov    %eax,%esi
  800b14:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	57                   	push   %edi
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b21:	ba 00 00 00 00       	mov    $0x0,%edx
  800b26:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2b:	89 d1                	mov    %edx,%ecx
  800b2d:	89 d3                	mov    %edx,%ebx
  800b2f:	89 d7                	mov    %edx,%edi
  800b31:	89 d6                	mov    %edx,%esi
  800b33:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b35:	5b                   	pop    %ebx
  800b36:	5e                   	pop    %esi
  800b37:	5f                   	pop    %edi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	57                   	push   %edi
  800b3e:	56                   	push   %esi
  800b3f:	53                   	push   %ebx
  800b40:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b43:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b48:	b8 03 00 00 00       	mov    $0x3,%eax
  800b4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b50:	89 cb                	mov    %ecx,%ebx
  800b52:	89 cf                	mov    %ecx,%edi
  800b54:	89 ce                	mov    %ecx,%esi
  800b56:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b58:	85 c0                	test   %eax,%eax
  800b5a:	7e 17                	jle    800b73 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5c:	83 ec 0c             	sub    $0xc,%esp
  800b5f:	50                   	push   %eax
  800b60:	6a 03                	push   $0x3
  800b62:	68 bf 29 80 00       	push   $0x8029bf
  800b67:	6a 23                	push   $0x23
  800b69:	68 dc 29 80 00       	push   $0x8029dc
  800b6e:	e8 e5 f5 ff ff       	call   800158 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5f                   	pop    %edi
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b81:	ba 00 00 00 00       	mov    $0x0,%edx
  800b86:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8b:	89 d1                	mov    %edx,%ecx
  800b8d:	89 d3                	mov    %edx,%ebx
  800b8f:	89 d7                	mov    %edx,%edi
  800b91:	89 d6                	mov    %edx,%esi
  800b93:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sys_yield>:

void
sys_yield(void)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800baa:	89 d1                	mov    %edx,%ecx
  800bac:	89 d3                	mov    %edx,%ebx
  800bae:	89 d7                	mov    %edx,%edi
  800bb0:	89 d6                	mov    %edx,%esi
  800bb2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	57                   	push   %edi
  800bbd:	56                   	push   %esi
  800bbe:	53                   	push   %ebx
  800bbf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc2:	be 00 00 00 00       	mov    $0x0,%esi
  800bc7:	b8 04 00 00 00       	mov    $0x4,%eax
  800bcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd5:	89 f7                	mov    %esi,%edi
  800bd7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd9:	85 c0                	test   %eax,%eax
  800bdb:	7e 17                	jle    800bf4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdd:	83 ec 0c             	sub    $0xc,%esp
  800be0:	50                   	push   %eax
  800be1:	6a 04                	push   $0x4
  800be3:	68 bf 29 80 00       	push   $0x8029bf
  800be8:	6a 23                	push   $0x23
  800bea:	68 dc 29 80 00       	push   $0x8029dc
  800bef:	e8 64 f5 ff ff       	call   800158 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
  800c02:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c05:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c10:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c13:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c16:	8b 75 18             	mov    0x18(%ebp),%esi
  800c19:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1b:	85 c0                	test   %eax,%eax
  800c1d:	7e 17                	jle    800c36 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1f:	83 ec 0c             	sub    $0xc,%esp
  800c22:	50                   	push   %eax
  800c23:	6a 05                	push   $0x5
  800c25:	68 bf 29 80 00       	push   $0x8029bf
  800c2a:	6a 23                	push   $0x23
  800c2c:	68 dc 29 80 00       	push   $0x8029dc
  800c31:	e8 22 f5 ff ff       	call   800158 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c47:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4c:	b8 06 00 00 00       	mov    $0x6,%eax
  800c51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c54:	8b 55 08             	mov    0x8(%ebp),%edx
  800c57:	89 df                	mov    %ebx,%edi
  800c59:	89 de                	mov    %ebx,%esi
  800c5b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5d:	85 c0                	test   %eax,%eax
  800c5f:	7e 17                	jle    800c78 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c61:	83 ec 0c             	sub    $0xc,%esp
  800c64:	50                   	push   %eax
  800c65:	6a 06                	push   $0x6
  800c67:	68 bf 29 80 00       	push   $0x8029bf
  800c6c:	6a 23                	push   $0x23
  800c6e:	68 dc 29 80 00       	push   $0x8029dc
  800c73:	e8 e0 f4 ff ff       	call   800158 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	53                   	push   %ebx
  800c86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c89:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c96:	8b 55 08             	mov    0x8(%ebp),%edx
  800c99:	89 df                	mov    %ebx,%edi
  800c9b:	89 de                	mov    %ebx,%esi
  800c9d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9f:	85 c0                	test   %eax,%eax
  800ca1:	7e 17                	jle    800cba <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca3:	83 ec 0c             	sub    $0xc,%esp
  800ca6:	50                   	push   %eax
  800ca7:	6a 08                	push   $0x8
  800ca9:	68 bf 29 80 00       	push   $0x8029bf
  800cae:	6a 23                	push   $0x23
  800cb0:	68 dc 29 80 00       	push   $0x8029dc
  800cb5:	e8 9e f4 ff ff       	call   800158 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
  800cc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd0:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	89 df                	mov    %ebx,%edi
  800cdd:	89 de                	mov    %ebx,%esi
  800cdf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	7e 17                	jle    800cfc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce5:	83 ec 0c             	sub    $0xc,%esp
  800ce8:	50                   	push   %eax
  800ce9:	6a 09                	push   $0x9
  800ceb:	68 bf 29 80 00       	push   $0x8029bf
  800cf0:	6a 23                	push   $0x23
  800cf2:	68 dc 29 80 00       	push   $0x8029dc
  800cf7:	e8 5c f4 ff ff       	call   800158 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
  800d0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d12:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1d:	89 df                	mov    %ebx,%edi
  800d1f:	89 de                	mov    %ebx,%esi
  800d21:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d23:	85 c0                	test   %eax,%eax
  800d25:	7e 17                	jle    800d3e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d27:	83 ec 0c             	sub    $0xc,%esp
  800d2a:	50                   	push   %eax
  800d2b:	6a 0a                	push   $0xa
  800d2d:	68 bf 29 80 00       	push   $0x8029bf
  800d32:	6a 23                	push   $0x23
  800d34:	68 dc 29 80 00       	push   $0x8029dc
  800d39:	e8 1a f4 ff ff       	call   800158 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	57                   	push   %edi
  800d4a:	56                   	push   %esi
  800d4b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4c:	be 00 00 00 00       	mov    $0x0,%esi
  800d51:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d62:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    

00800d69 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	57                   	push   %edi
  800d6d:	56                   	push   %esi
  800d6e:	53                   	push   %ebx
  800d6f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d72:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d77:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7f:	89 cb                	mov    %ecx,%ebx
  800d81:	89 cf                	mov    %ecx,%edi
  800d83:	89 ce                	mov    %ecx,%esi
  800d85:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d87:	85 c0                	test   %eax,%eax
  800d89:	7e 17                	jle    800da2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8b:	83 ec 0c             	sub    $0xc,%esp
  800d8e:	50                   	push   %eax
  800d8f:	6a 0d                	push   $0xd
  800d91:	68 bf 29 80 00       	push   $0x8029bf
  800d96:	6a 23                	push   $0x23
  800d98:	68 dc 29 80 00       	push   $0x8029dc
  800d9d:	e8 b6 f3 ff ff       	call   800158 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db0:	ba 00 00 00 00       	mov    $0x0,%edx
  800db5:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dba:	89 d1                	mov    %edx,%ecx
  800dbc:	89 d3                	mov    %edx,%ebx
  800dbe:	89 d7                	mov    %edx,%edi
  800dc0:	89 d6                	mov    %edx,%esi
  800dc2:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dc4:	5b                   	pop    %ebx
  800dc5:	5e                   	pop    %esi
  800dc6:	5f                   	pop    %edi
  800dc7:	5d                   	pop    %ebp
  800dc8:	c3                   	ret    

00800dc9 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800dc9:	55                   	push   %ebp
  800dca:	89 e5                	mov    %esp,%ebp
  800dcc:	57                   	push   %edi
  800dcd:	56                   	push   %esi
  800dce:	53                   	push   %ebx
  800dcf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd7:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ddc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddf:	8b 55 08             	mov    0x8(%ebp),%edx
  800de2:	89 df                	mov    %ebx,%edi
  800de4:	89 de                	mov    %ebx,%esi
  800de6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de8:	85 c0                	test   %eax,%eax
  800dea:	7e 17                	jle    800e03 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dec:	83 ec 0c             	sub    $0xc,%esp
  800def:	50                   	push   %eax
  800df0:	6a 0f                	push   $0xf
  800df2:	68 bf 29 80 00       	push   $0x8029bf
  800df7:	6a 23                	push   $0x23
  800df9:	68 dc 29 80 00       	push   $0x8029dc
  800dfe:	e8 55 f3 ff ff       	call   800158 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800e03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e06:	5b                   	pop    %ebx
  800e07:	5e                   	pop    %esi
  800e08:	5f                   	pop    %edi
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    

00800e0b <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	57                   	push   %edi
  800e0f:	56                   	push   %esi
  800e10:	53                   	push   %ebx
  800e11:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e14:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e19:	b8 10 00 00 00       	mov    $0x10,%eax
  800e1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e21:	8b 55 08             	mov    0x8(%ebp),%edx
  800e24:	89 df                	mov    %ebx,%edi
  800e26:	89 de                	mov    %ebx,%esi
  800e28:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e2a:	85 c0                	test   %eax,%eax
  800e2c:	7e 17                	jle    800e45 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2e:	83 ec 0c             	sub    $0xc,%esp
  800e31:	50                   	push   %eax
  800e32:	6a 10                	push   $0x10
  800e34:	68 bf 29 80 00       	push   $0x8029bf
  800e39:	6a 23                	push   $0x23
  800e3b:	68 dc 29 80 00       	push   $0x8029dc
  800e40:	e8 13 f3 ff ff       	call   800158 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  800e45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e48:	5b                   	pop    %ebx
  800e49:	5e                   	pop    %esi
  800e4a:	5f                   	pop    %edi
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	56                   	push   %esi
  800e51:	53                   	push   %ebx
  800e52:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e55:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800e57:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e5b:	75 25                	jne    800e82 <pgfault+0x35>
  800e5d:	89 d8                	mov    %ebx,%eax
  800e5f:	c1 e8 0c             	shr    $0xc,%eax
  800e62:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e69:	f6 c4 08             	test   $0x8,%ah
  800e6c:	75 14                	jne    800e82 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800e6e:	83 ec 04             	sub    $0x4,%esp
  800e71:	68 ec 29 80 00       	push   $0x8029ec
  800e76:	6a 1e                	push   $0x1e
  800e78:	68 80 2a 80 00       	push   $0x802a80
  800e7d:	e8 d6 f2 ff ff       	call   800158 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800e82:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800e88:	e8 ee fc ff ff       	call   800b7b <sys_getenvid>
  800e8d:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800e8f:	83 ec 04             	sub    $0x4,%esp
  800e92:	6a 07                	push   $0x7
  800e94:	68 00 f0 7f 00       	push   $0x7ff000
  800e99:	50                   	push   %eax
  800e9a:	e8 1a fd ff ff       	call   800bb9 <sys_page_alloc>
	if (r < 0)
  800e9f:	83 c4 10             	add    $0x10,%esp
  800ea2:	85 c0                	test   %eax,%eax
  800ea4:	79 12                	jns    800eb8 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800ea6:	50                   	push   %eax
  800ea7:	68 18 2a 80 00       	push   $0x802a18
  800eac:	6a 33                	push   $0x33
  800eae:	68 80 2a 80 00       	push   $0x802a80
  800eb3:	e8 a0 f2 ff ff       	call   800158 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800eb8:	83 ec 04             	sub    $0x4,%esp
  800ebb:	68 00 10 00 00       	push   $0x1000
  800ec0:	53                   	push   %ebx
  800ec1:	68 00 f0 7f 00       	push   $0x7ff000
  800ec6:	e8 e5 fa ff ff       	call   8009b0 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800ecb:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ed2:	53                   	push   %ebx
  800ed3:	56                   	push   %esi
  800ed4:	68 00 f0 7f 00       	push   $0x7ff000
  800ed9:	56                   	push   %esi
  800eda:	e8 1d fd ff ff       	call   800bfc <sys_page_map>
	if (r < 0)
  800edf:	83 c4 20             	add    $0x20,%esp
  800ee2:	85 c0                	test   %eax,%eax
  800ee4:	79 12                	jns    800ef8 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800ee6:	50                   	push   %eax
  800ee7:	68 3c 2a 80 00       	push   $0x802a3c
  800eec:	6a 3b                	push   $0x3b
  800eee:	68 80 2a 80 00       	push   $0x802a80
  800ef3:	e8 60 f2 ff ff       	call   800158 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800ef8:	83 ec 08             	sub    $0x8,%esp
  800efb:	68 00 f0 7f 00       	push   $0x7ff000
  800f00:	56                   	push   %esi
  800f01:	e8 38 fd ff ff       	call   800c3e <sys_page_unmap>
	if (r < 0)
  800f06:	83 c4 10             	add    $0x10,%esp
  800f09:	85 c0                	test   %eax,%eax
  800f0b:	79 12                	jns    800f1f <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800f0d:	50                   	push   %eax
  800f0e:	68 60 2a 80 00       	push   $0x802a60
  800f13:	6a 40                	push   $0x40
  800f15:	68 80 2a 80 00       	push   $0x802a80
  800f1a:	e8 39 f2 ff ff       	call   800158 <_panic>
}
  800f1f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f22:	5b                   	pop    %ebx
  800f23:	5e                   	pop    %esi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    

00800f26 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	57                   	push   %edi
  800f2a:	56                   	push   %esi
  800f2b:	53                   	push   %ebx
  800f2c:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800f2f:	68 4d 0e 80 00       	push   $0x800e4d
  800f34:	e8 dc 13 00 00       	call   802315 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f39:	b8 07 00 00 00       	mov    $0x7,%eax
  800f3e:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800f40:	83 c4 10             	add    $0x10,%esp
  800f43:	85 c0                	test   %eax,%eax
  800f45:	0f 88 64 01 00 00    	js     8010af <fork+0x189>
  800f4b:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800f50:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800f55:	85 c0                	test   %eax,%eax
  800f57:	75 21                	jne    800f7a <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f59:	e8 1d fc ff ff       	call   800b7b <sys_getenvid>
  800f5e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f63:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f66:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f6b:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  800f70:	ba 00 00 00 00       	mov    $0x0,%edx
  800f75:	e9 3f 01 00 00       	jmp    8010b9 <fork+0x193>
  800f7a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f7d:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800f7f:	89 d8                	mov    %ebx,%eax
  800f81:	c1 e8 16             	shr    $0x16,%eax
  800f84:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f8b:	a8 01                	test   $0x1,%al
  800f8d:	0f 84 bd 00 00 00    	je     801050 <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800f93:	89 d8                	mov    %ebx,%eax
  800f95:	c1 e8 0c             	shr    $0xc,%eax
  800f98:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f9f:	f6 c2 01             	test   $0x1,%dl
  800fa2:	0f 84 a8 00 00 00    	je     801050 <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  800fa8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800faf:	a8 04                	test   $0x4,%al
  800fb1:	0f 84 99 00 00 00    	je     801050 <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800fb7:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fbe:	f6 c4 04             	test   $0x4,%ah
  800fc1:	74 17                	je     800fda <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800fc3:	83 ec 0c             	sub    $0xc,%esp
  800fc6:	68 07 0e 00 00       	push   $0xe07
  800fcb:	53                   	push   %ebx
  800fcc:	57                   	push   %edi
  800fcd:	53                   	push   %ebx
  800fce:	6a 00                	push   $0x0
  800fd0:	e8 27 fc ff ff       	call   800bfc <sys_page_map>
  800fd5:	83 c4 20             	add    $0x20,%esp
  800fd8:	eb 76                	jmp    801050 <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800fda:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fe1:	a8 02                	test   $0x2,%al
  800fe3:	75 0c                	jne    800ff1 <fork+0xcb>
  800fe5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fec:	f6 c4 08             	test   $0x8,%ah
  800fef:	74 3f                	je     801030 <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800ff1:	83 ec 0c             	sub    $0xc,%esp
  800ff4:	68 05 08 00 00       	push   $0x805
  800ff9:	53                   	push   %ebx
  800ffa:	57                   	push   %edi
  800ffb:	53                   	push   %ebx
  800ffc:	6a 00                	push   $0x0
  800ffe:	e8 f9 fb ff ff       	call   800bfc <sys_page_map>
		if (r < 0)
  801003:	83 c4 20             	add    $0x20,%esp
  801006:	85 c0                	test   %eax,%eax
  801008:	0f 88 a5 00 00 00    	js     8010b3 <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  80100e:	83 ec 0c             	sub    $0xc,%esp
  801011:	68 05 08 00 00       	push   $0x805
  801016:	53                   	push   %ebx
  801017:	6a 00                	push   $0x0
  801019:	53                   	push   %ebx
  80101a:	6a 00                	push   $0x0
  80101c:	e8 db fb ff ff       	call   800bfc <sys_page_map>
  801021:	83 c4 20             	add    $0x20,%esp
  801024:	85 c0                	test   %eax,%eax
  801026:	b9 00 00 00 00       	mov    $0x0,%ecx
  80102b:	0f 4f c1             	cmovg  %ecx,%eax
  80102e:	eb 1c                	jmp    80104c <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  801030:	83 ec 0c             	sub    $0xc,%esp
  801033:	6a 05                	push   $0x5
  801035:	53                   	push   %ebx
  801036:	57                   	push   %edi
  801037:	53                   	push   %ebx
  801038:	6a 00                	push   $0x0
  80103a:	e8 bd fb ff ff       	call   800bfc <sys_page_map>
  80103f:	83 c4 20             	add    $0x20,%esp
  801042:	85 c0                	test   %eax,%eax
  801044:	b9 00 00 00 00       	mov    $0x0,%ecx
  801049:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  80104c:	85 c0                	test   %eax,%eax
  80104e:	78 67                	js     8010b7 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801050:	83 c6 01             	add    $0x1,%esi
  801053:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801059:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  80105f:	0f 85 1a ff ff ff    	jne    800f7f <fork+0x59>
  801065:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  801068:	83 ec 04             	sub    $0x4,%esp
  80106b:	6a 07                	push   $0x7
  80106d:	68 00 f0 bf ee       	push   $0xeebff000
  801072:	57                   	push   %edi
  801073:	e8 41 fb ff ff       	call   800bb9 <sys_page_alloc>
	if (r < 0)
  801078:	83 c4 10             	add    $0x10,%esp
		return r;
  80107b:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  80107d:	85 c0                	test   %eax,%eax
  80107f:	78 38                	js     8010b9 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801081:	83 ec 08             	sub    $0x8,%esp
  801084:	68 5c 23 80 00       	push   $0x80235c
  801089:	57                   	push   %edi
  80108a:	e8 75 fc ff ff       	call   800d04 <sys_env_set_pgfault_upcall>
	if (r < 0)
  80108f:	83 c4 10             	add    $0x10,%esp
		return r;
  801092:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  801094:	85 c0                	test   %eax,%eax
  801096:	78 21                	js     8010b9 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801098:	83 ec 08             	sub    $0x8,%esp
  80109b:	6a 02                	push   $0x2
  80109d:	57                   	push   %edi
  80109e:	e8 dd fb ff ff       	call   800c80 <sys_env_set_status>
	if (r < 0)
  8010a3:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	0f 48 f8             	cmovs  %eax,%edi
  8010ab:	89 fa                	mov    %edi,%edx
  8010ad:	eb 0a                	jmp    8010b9 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  8010af:	89 c2                	mov    %eax,%edx
  8010b1:	eb 06                	jmp    8010b9 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  8010b3:	89 c2                	mov    %eax,%edx
  8010b5:	eb 02                	jmp    8010b9 <fork+0x193>
  8010b7:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  8010b9:	89 d0                	mov    %edx,%eax
  8010bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010be:	5b                   	pop    %ebx
  8010bf:	5e                   	pop    %esi
  8010c0:	5f                   	pop    %edi
  8010c1:	5d                   	pop    %ebp
  8010c2:	c3                   	ret    

008010c3 <sfork>:

// Challenge!
int
sfork(void)
{
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010c9:	68 8b 2a 80 00       	push   $0x802a8b
  8010ce:	68 c9 00 00 00       	push   $0xc9
  8010d3:	68 80 2a 80 00       	push   $0x802a80
  8010d8:	e8 7b f0 ff ff       	call   800158 <_panic>

008010dd <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	56                   	push   %esi
  8010e1:	53                   	push   %ebx
  8010e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8010e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8010eb:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8010ed:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8010f2:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8010f5:	83 ec 0c             	sub    $0xc,%esp
  8010f8:	50                   	push   %eax
  8010f9:	e8 6b fc ff ff       	call   800d69 <sys_ipc_recv>

	if (from_env_store != NULL)
  8010fe:	83 c4 10             	add    $0x10,%esp
  801101:	85 f6                	test   %esi,%esi
  801103:	74 14                	je     801119 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801105:	ba 00 00 00 00       	mov    $0x0,%edx
  80110a:	85 c0                	test   %eax,%eax
  80110c:	78 09                	js     801117 <ipc_recv+0x3a>
  80110e:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801114:	8b 52 74             	mov    0x74(%edx),%edx
  801117:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801119:	85 db                	test   %ebx,%ebx
  80111b:	74 14                	je     801131 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  80111d:	ba 00 00 00 00       	mov    $0x0,%edx
  801122:	85 c0                	test   %eax,%eax
  801124:	78 09                	js     80112f <ipc_recv+0x52>
  801126:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80112c:	8b 52 78             	mov    0x78(%edx),%edx
  80112f:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801131:	85 c0                	test   %eax,%eax
  801133:	78 08                	js     80113d <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801135:	a1 08 40 80 00       	mov    0x804008,%eax
  80113a:	8b 40 70             	mov    0x70(%eax),%eax
}
  80113d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801140:	5b                   	pop    %ebx
  801141:	5e                   	pop    %esi
  801142:	5d                   	pop    %ebp
  801143:	c3                   	ret    

00801144 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
  801147:	57                   	push   %edi
  801148:	56                   	push   %esi
  801149:	53                   	push   %ebx
  80114a:	83 ec 0c             	sub    $0xc,%esp
  80114d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801150:	8b 75 0c             	mov    0xc(%ebp),%esi
  801153:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801156:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801158:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80115d:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801160:	ff 75 14             	pushl  0x14(%ebp)
  801163:	53                   	push   %ebx
  801164:	56                   	push   %esi
  801165:	57                   	push   %edi
  801166:	e8 db fb ff ff       	call   800d46 <sys_ipc_try_send>

		if (err < 0) {
  80116b:	83 c4 10             	add    $0x10,%esp
  80116e:	85 c0                	test   %eax,%eax
  801170:	79 1e                	jns    801190 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801172:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801175:	75 07                	jne    80117e <ipc_send+0x3a>
				sys_yield();
  801177:	e8 1e fa ff ff       	call   800b9a <sys_yield>
  80117c:	eb e2                	jmp    801160 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  80117e:	50                   	push   %eax
  80117f:	68 a1 2a 80 00       	push   $0x802aa1
  801184:	6a 49                	push   $0x49
  801186:	68 ae 2a 80 00       	push   $0x802aae
  80118b:	e8 c8 ef ff ff       	call   800158 <_panic>
		}

	} while (err < 0);

}
  801190:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801193:	5b                   	pop    %ebx
  801194:	5e                   	pop    %esi
  801195:	5f                   	pop    %edi
  801196:	5d                   	pop    %ebp
  801197:	c3                   	ret    

00801198 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801198:	55                   	push   %ebp
  801199:	89 e5                	mov    %esp,%ebp
  80119b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80119e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011a3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011a6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011ac:	8b 52 50             	mov    0x50(%edx),%edx
  8011af:	39 ca                	cmp    %ecx,%edx
  8011b1:	75 0d                	jne    8011c0 <ipc_find_env+0x28>
			return envs[i].env_id;
  8011b3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011b6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011bb:	8b 40 48             	mov    0x48(%eax),%eax
  8011be:	eb 0f                	jmp    8011cf <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011c0:	83 c0 01             	add    $0x1,%eax
  8011c3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011c8:	75 d9                	jne    8011a3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011cf:	5d                   	pop    %ebp
  8011d0:	c3                   	ret    

008011d1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d7:	05 00 00 00 30       	add    $0x30000000,%eax
  8011dc:	c1 e8 0c             	shr    $0xc,%eax
}
  8011df:	5d                   	pop    %ebp
  8011e0:	c3                   	ret    

008011e1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011e1:	55                   	push   %ebp
  8011e2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e7:	05 00 00 00 30       	add    $0x30000000,%eax
  8011ec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011f1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011f6:	5d                   	pop    %ebp
  8011f7:	c3                   	ret    

008011f8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011fe:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801203:	89 c2                	mov    %eax,%edx
  801205:	c1 ea 16             	shr    $0x16,%edx
  801208:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80120f:	f6 c2 01             	test   $0x1,%dl
  801212:	74 11                	je     801225 <fd_alloc+0x2d>
  801214:	89 c2                	mov    %eax,%edx
  801216:	c1 ea 0c             	shr    $0xc,%edx
  801219:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801220:	f6 c2 01             	test   $0x1,%dl
  801223:	75 09                	jne    80122e <fd_alloc+0x36>
			*fd_store = fd;
  801225:	89 01                	mov    %eax,(%ecx)
			return 0;
  801227:	b8 00 00 00 00       	mov    $0x0,%eax
  80122c:	eb 17                	jmp    801245 <fd_alloc+0x4d>
  80122e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801233:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801238:	75 c9                	jne    801203 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80123a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801240:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801245:	5d                   	pop    %ebp
  801246:	c3                   	ret    

00801247 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801247:	55                   	push   %ebp
  801248:	89 e5                	mov    %esp,%ebp
  80124a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80124d:	83 f8 1f             	cmp    $0x1f,%eax
  801250:	77 36                	ja     801288 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801252:	c1 e0 0c             	shl    $0xc,%eax
  801255:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80125a:	89 c2                	mov    %eax,%edx
  80125c:	c1 ea 16             	shr    $0x16,%edx
  80125f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801266:	f6 c2 01             	test   $0x1,%dl
  801269:	74 24                	je     80128f <fd_lookup+0x48>
  80126b:	89 c2                	mov    %eax,%edx
  80126d:	c1 ea 0c             	shr    $0xc,%edx
  801270:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801277:	f6 c2 01             	test   $0x1,%dl
  80127a:	74 1a                	je     801296 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80127c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80127f:	89 02                	mov    %eax,(%edx)
	return 0;
  801281:	b8 00 00 00 00       	mov    $0x0,%eax
  801286:	eb 13                	jmp    80129b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801288:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80128d:	eb 0c                	jmp    80129b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80128f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801294:	eb 05                	jmp    80129b <fd_lookup+0x54>
  801296:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80129b:	5d                   	pop    %ebp
  80129c:	c3                   	ret    

0080129d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	83 ec 08             	sub    $0x8,%esp
  8012a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012a6:	ba 38 2b 80 00       	mov    $0x802b38,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012ab:	eb 13                	jmp    8012c0 <dev_lookup+0x23>
  8012ad:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012b0:	39 08                	cmp    %ecx,(%eax)
  8012b2:	75 0c                	jne    8012c0 <dev_lookup+0x23>
			*dev = devtab[i];
  8012b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012be:	eb 2e                	jmp    8012ee <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012c0:	8b 02                	mov    (%edx),%eax
  8012c2:	85 c0                	test   %eax,%eax
  8012c4:	75 e7                	jne    8012ad <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012c6:	a1 08 40 80 00       	mov    0x804008,%eax
  8012cb:	8b 40 48             	mov    0x48(%eax),%eax
  8012ce:	83 ec 04             	sub    $0x4,%esp
  8012d1:	51                   	push   %ecx
  8012d2:	50                   	push   %eax
  8012d3:	68 b8 2a 80 00       	push   $0x802ab8
  8012d8:	e8 54 ef ff ff       	call   800231 <cprintf>
	*dev = 0;
  8012dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012e6:	83 c4 10             	add    $0x10,%esp
  8012e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012ee:	c9                   	leave  
  8012ef:	c3                   	ret    

008012f0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	56                   	push   %esi
  8012f4:	53                   	push   %ebx
  8012f5:	83 ec 10             	sub    $0x10,%esp
  8012f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8012fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801301:	50                   	push   %eax
  801302:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801308:	c1 e8 0c             	shr    $0xc,%eax
  80130b:	50                   	push   %eax
  80130c:	e8 36 ff ff ff       	call   801247 <fd_lookup>
  801311:	83 c4 08             	add    $0x8,%esp
  801314:	85 c0                	test   %eax,%eax
  801316:	78 05                	js     80131d <fd_close+0x2d>
	    || fd != fd2)
  801318:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80131b:	74 0c                	je     801329 <fd_close+0x39>
		return (must_exist ? r : 0);
  80131d:	84 db                	test   %bl,%bl
  80131f:	ba 00 00 00 00       	mov    $0x0,%edx
  801324:	0f 44 c2             	cmove  %edx,%eax
  801327:	eb 41                	jmp    80136a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801329:	83 ec 08             	sub    $0x8,%esp
  80132c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80132f:	50                   	push   %eax
  801330:	ff 36                	pushl  (%esi)
  801332:	e8 66 ff ff ff       	call   80129d <dev_lookup>
  801337:	89 c3                	mov    %eax,%ebx
  801339:	83 c4 10             	add    $0x10,%esp
  80133c:	85 c0                	test   %eax,%eax
  80133e:	78 1a                	js     80135a <fd_close+0x6a>
		if (dev->dev_close)
  801340:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801343:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801346:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80134b:	85 c0                	test   %eax,%eax
  80134d:	74 0b                	je     80135a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80134f:	83 ec 0c             	sub    $0xc,%esp
  801352:	56                   	push   %esi
  801353:	ff d0                	call   *%eax
  801355:	89 c3                	mov    %eax,%ebx
  801357:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80135a:	83 ec 08             	sub    $0x8,%esp
  80135d:	56                   	push   %esi
  80135e:	6a 00                	push   $0x0
  801360:	e8 d9 f8 ff ff       	call   800c3e <sys_page_unmap>
	return r;
  801365:	83 c4 10             	add    $0x10,%esp
  801368:	89 d8                	mov    %ebx,%eax
}
  80136a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80136d:	5b                   	pop    %ebx
  80136e:	5e                   	pop    %esi
  80136f:	5d                   	pop    %ebp
  801370:	c3                   	ret    

00801371 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801371:	55                   	push   %ebp
  801372:	89 e5                	mov    %esp,%ebp
  801374:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801377:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137a:	50                   	push   %eax
  80137b:	ff 75 08             	pushl  0x8(%ebp)
  80137e:	e8 c4 fe ff ff       	call   801247 <fd_lookup>
  801383:	83 c4 08             	add    $0x8,%esp
  801386:	85 c0                	test   %eax,%eax
  801388:	78 10                	js     80139a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80138a:	83 ec 08             	sub    $0x8,%esp
  80138d:	6a 01                	push   $0x1
  80138f:	ff 75 f4             	pushl  -0xc(%ebp)
  801392:	e8 59 ff ff ff       	call   8012f0 <fd_close>
  801397:	83 c4 10             	add    $0x10,%esp
}
  80139a:	c9                   	leave  
  80139b:	c3                   	ret    

0080139c <close_all>:

void
close_all(void)
{
  80139c:	55                   	push   %ebp
  80139d:	89 e5                	mov    %esp,%ebp
  80139f:	53                   	push   %ebx
  8013a0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013a3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013a8:	83 ec 0c             	sub    $0xc,%esp
  8013ab:	53                   	push   %ebx
  8013ac:	e8 c0 ff ff ff       	call   801371 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b1:	83 c3 01             	add    $0x1,%ebx
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	83 fb 20             	cmp    $0x20,%ebx
  8013ba:	75 ec                	jne    8013a8 <close_all+0xc>
		close(i);
}
  8013bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013bf:	c9                   	leave  
  8013c0:	c3                   	ret    

008013c1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013c1:	55                   	push   %ebp
  8013c2:	89 e5                	mov    %esp,%ebp
  8013c4:	57                   	push   %edi
  8013c5:	56                   	push   %esi
  8013c6:	53                   	push   %ebx
  8013c7:	83 ec 2c             	sub    $0x2c,%esp
  8013ca:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013cd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013d0:	50                   	push   %eax
  8013d1:	ff 75 08             	pushl  0x8(%ebp)
  8013d4:	e8 6e fe ff ff       	call   801247 <fd_lookup>
  8013d9:	83 c4 08             	add    $0x8,%esp
  8013dc:	85 c0                	test   %eax,%eax
  8013de:	0f 88 c1 00 00 00    	js     8014a5 <dup+0xe4>
		return r;
	close(newfdnum);
  8013e4:	83 ec 0c             	sub    $0xc,%esp
  8013e7:	56                   	push   %esi
  8013e8:	e8 84 ff ff ff       	call   801371 <close>

	newfd = INDEX2FD(newfdnum);
  8013ed:	89 f3                	mov    %esi,%ebx
  8013ef:	c1 e3 0c             	shl    $0xc,%ebx
  8013f2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013f8:	83 c4 04             	add    $0x4,%esp
  8013fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013fe:	e8 de fd ff ff       	call   8011e1 <fd2data>
  801403:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801405:	89 1c 24             	mov    %ebx,(%esp)
  801408:	e8 d4 fd ff ff       	call   8011e1 <fd2data>
  80140d:	83 c4 10             	add    $0x10,%esp
  801410:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801413:	89 f8                	mov    %edi,%eax
  801415:	c1 e8 16             	shr    $0x16,%eax
  801418:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80141f:	a8 01                	test   $0x1,%al
  801421:	74 37                	je     80145a <dup+0x99>
  801423:	89 f8                	mov    %edi,%eax
  801425:	c1 e8 0c             	shr    $0xc,%eax
  801428:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80142f:	f6 c2 01             	test   $0x1,%dl
  801432:	74 26                	je     80145a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801434:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80143b:	83 ec 0c             	sub    $0xc,%esp
  80143e:	25 07 0e 00 00       	and    $0xe07,%eax
  801443:	50                   	push   %eax
  801444:	ff 75 d4             	pushl  -0x2c(%ebp)
  801447:	6a 00                	push   $0x0
  801449:	57                   	push   %edi
  80144a:	6a 00                	push   $0x0
  80144c:	e8 ab f7 ff ff       	call   800bfc <sys_page_map>
  801451:	89 c7                	mov    %eax,%edi
  801453:	83 c4 20             	add    $0x20,%esp
  801456:	85 c0                	test   %eax,%eax
  801458:	78 2e                	js     801488 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80145a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80145d:	89 d0                	mov    %edx,%eax
  80145f:	c1 e8 0c             	shr    $0xc,%eax
  801462:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801469:	83 ec 0c             	sub    $0xc,%esp
  80146c:	25 07 0e 00 00       	and    $0xe07,%eax
  801471:	50                   	push   %eax
  801472:	53                   	push   %ebx
  801473:	6a 00                	push   $0x0
  801475:	52                   	push   %edx
  801476:	6a 00                	push   $0x0
  801478:	e8 7f f7 ff ff       	call   800bfc <sys_page_map>
  80147d:	89 c7                	mov    %eax,%edi
  80147f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801482:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801484:	85 ff                	test   %edi,%edi
  801486:	79 1d                	jns    8014a5 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801488:	83 ec 08             	sub    $0x8,%esp
  80148b:	53                   	push   %ebx
  80148c:	6a 00                	push   $0x0
  80148e:	e8 ab f7 ff ff       	call   800c3e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801493:	83 c4 08             	add    $0x8,%esp
  801496:	ff 75 d4             	pushl  -0x2c(%ebp)
  801499:	6a 00                	push   $0x0
  80149b:	e8 9e f7 ff ff       	call   800c3e <sys_page_unmap>
	return r;
  8014a0:	83 c4 10             	add    $0x10,%esp
  8014a3:	89 f8                	mov    %edi,%eax
}
  8014a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014a8:	5b                   	pop    %ebx
  8014a9:	5e                   	pop    %esi
  8014aa:	5f                   	pop    %edi
  8014ab:	5d                   	pop    %ebp
  8014ac:	c3                   	ret    

008014ad <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014ad:	55                   	push   %ebp
  8014ae:	89 e5                	mov    %esp,%ebp
  8014b0:	53                   	push   %ebx
  8014b1:	83 ec 14             	sub    $0x14,%esp
  8014b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ba:	50                   	push   %eax
  8014bb:	53                   	push   %ebx
  8014bc:	e8 86 fd ff ff       	call   801247 <fd_lookup>
  8014c1:	83 c4 08             	add    $0x8,%esp
  8014c4:	89 c2                	mov    %eax,%edx
  8014c6:	85 c0                	test   %eax,%eax
  8014c8:	78 6d                	js     801537 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ca:	83 ec 08             	sub    $0x8,%esp
  8014cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d0:	50                   	push   %eax
  8014d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d4:	ff 30                	pushl  (%eax)
  8014d6:	e8 c2 fd ff ff       	call   80129d <dev_lookup>
  8014db:	83 c4 10             	add    $0x10,%esp
  8014de:	85 c0                	test   %eax,%eax
  8014e0:	78 4c                	js     80152e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014e2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014e5:	8b 42 08             	mov    0x8(%edx),%eax
  8014e8:	83 e0 03             	and    $0x3,%eax
  8014eb:	83 f8 01             	cmp    $0x1,%eax
  8014ee:	75 21                	jne    801511 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f0:	a1 08 40 80 00       	mov    0x804008,%eax
  8014f5:	8b 40 48             	mov    0x48(%eax),%eax
  8014f8:	83 ec 04             	sub    $0x4,%esp
  8014fb:	53                   	push   %ebx
  8014fc:	50                   	push   %eax
  8014fd:	68 fc 2a 80 00       	push   $0x802afc
  801502:	e8 2a ed ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  801507:	83 c4 10             	add    $0x10,%esp
  80150a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80150f:	eb 26                	jmp    801537 <read+0x8a>
	}
	if (!dev->dev_read)
  801511:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801514:	8b 40 08             	mov    0x8(%eax),%eax
  801517:	85 c0                	test   %eax,%eax
  801519:	74 17                	je     801532 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80151b:	83 ec 04             	sub    $0x4,%esp
  80151e:	ff 75 10             	pushl  0x10(%ebp)
  801521:	ff 75 0c             	pushl  0xc(%ebp)
  801524:	52                   	push   %edx
  801525:	ff d0                	call   *%eax
  801527:	89 c2                	mov    %eax,%edx
  801529:	83 c4 10             	add    $0x10,%esp
  80152c:	eb 09                	jmp    801537 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152e:	89 c2                	mov    %eax,%edx
  801530:	eb 05                	jmp    801537 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801532:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801537:	89 d0                	mov    %edx,%eax
  801539:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153c:	c9                   	leave  
  80153d:	c3                   	ret    

0080153e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80153e:	55                   	push   %ebp
  80153f:	89 e5                	mov    %esp,%ebp
  801541:	57                   	push   %edi
  801542:	56                   	push   %esi
  801543:	53                   	push   %ebx
  801544:	83 ec 0c             	sub    $0xc,%esp
  801547:	8b 7d 08             	mov    0x8(%ebp),%edi
  80154a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80154d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801552:	eb 21                	jmp    801575 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801554:	83 ec 04             	sub    $0x4,%esp
  801557:	89 f0                	mov    %esi,%eax
  801559:	29 d8                	sub    %ebx,%eax
  80155b:	50                   	push   %eax
  80155c:	89 d8                	mov    %ebx,%eax
  80155e:	03 45 0c             	add    0xc(%ebp),%eax
  801561:	50                   	push   %eax
  801562:	57                   	push   %edi
  801563:	e8 45 ff ff ff       	call   8014ad <read>
		if (m < 0)
  801568:	83 c4 10             	add    $0x10,%esp
  80156b:	85 c0                	test   %eax,%eax
  80156d:	78 10                	js     80157f <readn+0x41>
			return m;
		if (m == 0)
  80156f:	85 c0                	test   %eax,%eax
  801571:	74 0a                	je     80157d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801573:	01 c3                	add    %eax,%ebx
  801575:	39 f3                	cmp    %esi,%ebx
  801577:	72 db                	jb     801554 <readn+0x16>
  801579:	89 d8                	mov    %ebx,%eax
  80157b:	eb 02                	jmp    80157f <readn+0x41>
  80157d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80157f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801582:	5b                   	pop    %ebx
  801583:	5e                   	pop    %esi
  801584:	5f                   	pop    %edi
  801585:	5d                   	pop    %ebp
  801586:	c3                   	ret    

00801587 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801587:	55                   	push   %ebp
  801588:	89 e5                	mov    %esp,%ebp
  80158a:	53                   	push   %ebx
  80158b:	83 ec 14             	sub    $0x14,%esp
  80158e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801591:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801594:	50                   	push   %eax
  801595:	53                   	push   %ebx
  801596:	e8 ac fc ff ff       	call   801247 <fd_lookup>
  80159b:	83 c4 08             	add    $0x8,%esp
  80159e:	89 c2                	mov    %eax,%edx
  8015a0:	85 c0                	test   %eax,%eax
  8015a2:	78 68                	js     80160c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a4:	83 ec 08             	sub    $0x8,%esp
  8015a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015aa:	50                   	push   %eax
  8015ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ae:	ff 30                	pushl  (%eax)
  8015b0:	e8 e8 fc ff ff       	call   80129d <dev_lookup>
  8015b5:	83 c4 10             	add    $0x10,%esp
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	78 47                	js     801603 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015bf:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015c3:	75 21                	jne    8015e6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015c5:	a1 08 40 80 00       	mov    0x804008,%eax
  8015ca:	8b 40 48             	mov    0x48(%eax),%eax
  8015cd:	83 ec 04             	sub    $0x4,%esp
  8015d0:	53                   	push   %ebx
  8015d1:	50                   	push   %eax
  8015d2:	68 18 2b 80 00       	push   $0x802b18
  8015d7:	e8 55 ec ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  8015dc:	83 c4 10             	add    $0x10,%esp
  8015df:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015e4:	eb 26                	jmp    80160c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015e9:	8b 52 0c             	mov    0xc(%edx),%edx
  8015ec:	85 d2                	test   %edx,%edx
  8015ee:	74 17                	je     801607 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015f0:	83 ec 04             	sub    $0x4,%esp
  8015f3:	ff 75 10             	pushl  0x10(%ebp)
  8015f6:	ff 75 0c             	pushl  0xc(%ebp)
  8015f9:	50                   	push   %eax
  8015fa:	ff d2                	call   *%edx
  8015fc:	89 c2                	mov    %eax,%edx
  8015fe:	83 c4 10             	add    $0x10,%esp
  801601:	eb 09                	jmp    80160c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801603:	89 c2                	mov    %eax,%edx
  801605:	eb 05                	jmp    80160c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801607:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80160c:	89 d0                	mov    %edx,%eax
  80160e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801611:	c9                   	leave  
  801612:	c3                   	ret    

00801613 <seek>:

int
seek(int fdnum, off_t offset)
{
  801613:	55                   	push   %ebp
  801614:	89 e5                	mov    %esp,%ebp
  801616:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801619:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80161c:	50                   	push   %eax
  80161d:	ff 75 08             	pushl  0x8(%ebp)
  801620:	e8 22 fc ff ff       	call   801247 <fd_lookup>
  801625:	83 c4 08             	add    $0x8,%esp
  801628:	85 c0                	test   %eax,%eax
  80162a:	78 0e                	js     80163a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80162c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80162f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801632:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801635:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80163a:	c9                   	leave  
  80163b:	c3                   	ret    

0080163c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	53                   	push   %ebx
  801640:	83 ec 14             	sub    $0x14,%esp
  801643:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801646:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801649:	50                   	push   %eax
  80164a:	53                   	push   %ebx
  80164b:	e8 f7 fb ff ff       	call   801247 <fd_lookup>
  801650:	83 c4 08             	add    $0x8,%esp
  801653:	89 c2                	mov    %eax,%edx
  801655:	85 c0                	test   %eax,%eax
  801657:	78 65                	js     8016be <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801659:	83 ec 08             	sub    $0x8,%esp
  80165c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165f:	50                   	push   %eax
  801660:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801663:	ff 30                	pushl  (%eax)
  801665:	e8 33 fc ff ff       	call   80129d <dev_lookup>
  80166a:	83 c4 10             	add    $0x10,%esp
  80166d:	85 c0                	test   %eax,%eax
  80166f:	78 44                	js     8016b5 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801671:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801674:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801678:	75 21                	jne    80169b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80167a:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80167f:	8b 40 48             	mov    0x48(%eax),%eax
  801682:	83 ec 04             	sub    $0x4,%esp
  801685:	53                   	push   %ebx
  801686:	50                   	push   %eax
  801687:	68 d8 2a 80 00       	push   $0x802ad8
  80168c:	e8 a0 eb ff ff       	call   800231 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801691:	83 c4 10             	add    $0x10,%esp
  801694:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801699:	eb 23                	jmp    8016be <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80169b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80169e:	8b 52 18             	mov    0x18(%edx),%edx
  8016a1:	85 d2                	test   %edx,%edx
  8016a3:	74 14                	je     8016b9 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016a5:	83 ec 08             	sub    $0x8,%esp
  8016a8:	ff 75 0c             	pushl  0xc(%ebp)
  8016ab:	50                   	push   %eax
  8016ac:	ff d2                	call   *%edx
  8016ae:	89 c2                	mov    %eax,%edx
  8016b0:	83 c4 10             	add    $0x10,%esp
  8016b3:	eb 09                	jmp    8016be <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b5:	89 c2                	mov    %eax,%edx
  8016b7:	eb 05                	jmp    8016be <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016b9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016be:	89 d0                	mov    %edx,%eax
  8016c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c3:	c9                   	leave  
  8016c4:	c3                   	ret    

008016c5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	53                   	push   %ebx
  8016c9:	83 ec 14             	sub    $0x14,%esp
  8016cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d2:	50                   	push   %eax
  8016d3:	ff 75 08             	pushl  0x8(%ebp)
  8016d6:	e8 6c fb ff ff       	call   801247 <fd_lookup>
  8016db:	83 c4 08             	add    $0x8,%esp
  8016de:	89 c2                	mov    %eax,%edx
  8016e0:	85 c0                	test   %eax,%eax
  8016e2:	78 58                	js     80173c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e4:	83 ec 08             	sub    $0x8,%esp
  8016e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ea:	50                   	push   %eax
  8016eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ee:	ff 30                	pushl  (%eax)
  8016f0:	e8 a8 fb ff ff       	call   80129d <dev_lookup>
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	85 c0                	test   %eax,%eax
  8016fa:	78 37                	js     801733 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ff:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801703:	74 32                	je     801737 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801705:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801708:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80170f:	00 00 00 
	stat->st_isdir = 0;
  801712:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801719:	00 00 00 
	stat->st_dev = dev;
  80171c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801722:	83 ec 08             	sub    $0x8,%esp
  801725:	53                   	push   %ebx
  801726:	ff 75 f0             	pushl  -0x10(%ebp)
  801729:	ff 50 14             	call   *0x14(%eax)
  80172c:	89 c2                	mov    %eax,%edx
  80172e:	83 c4 10             	add    $0x10,%esp
  801731:	eb 09                	jmp    80173c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801733:	89 c2                	mov    %eax,%edx
  801735:	eb 05                	jmp    80173c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801737:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80173c:	89 d0                	mov    %edx,%eax
  80173e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801741:	c9                   	leave  
  801742:	c3                   	ret    

00801743 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801743:	55                   	push   %ebp
  801744:	89 e5                	mov    %esp,%ebp
  801746:	56                   	push   %esi
  801747:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801748:	83 ec 08             	sub    $0x8,%esp
  80174b:	6a 00                	push   $0x0
  80174d:	ff 75 08             	pushl  0x8(%ebp)
  801750:	e8 d6 01 00 00       	call   80192b <open>
  801755:	89 c3                	mov    %eax,%ebx
  801757:	83 c4 10             	add    $0x10,%esp
  80175a:	85 c0                	test   %eax,%eax
  80175c:	78 1b                	js     801779 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80175e:	83 ec 08             	sub    $0x8,%esp
  801761:	ff 75 0c             	pushl  0xc(%ebp)
  801764:	50                   	push   %eax
  801765:	e8 5b ff ff ff       	call   8016c5 <fstat>
  80176a:	89 c6                	mov    %eax,%esi
	close(fd);
  80176c:	89 1c 24             	mov    %ebx,(%esp)
  80176f:	e8 fd fb ff ff       	call   801371 <close>
	return r;
  801774:	83 c4 10             	add    $0x10,%esp
  801777:	89 f0                	mov    %esi,%eax
}
  801779:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80177c:	5b                   	pop    %ebx
  80177d:	5e                   	pop    %esi
  80177e:	5d                   	pop    %ebp
  80177f:	c3                   	ret    

00801780 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	56                   	push   %esi
  801784:	53                   	push   %ebx
  801785:	89 c6                	mov    %eax,%esi
  801787:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801789:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801790:	75 12                	jne    8017a4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801792:	83 ec 0c             	sub    $0xc,%esp
  801795:	6a 01                	push   $0x1
  801797:	e8 fc f9 ff ff       	call   801198 <ipc_find_env>
  80179c:	a3 00 40 80 00       	mov    %eax,0x804000
  8017a1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017a4:	6a 07                	push   $0x7
  8017a6:	68 00 50 80 00       	push   $0x805000
  8017ab:	56                   	push   %esi
  8017ac:	ff 35 00 40 80 00    	pushl  0x804000
  8017b2:	e8 8d f9 ff ff       	call   801144 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017b7:	83 c4 0c             	add    $0xc,%esp
  8017ba:	6a 00                	push   $0x0
  8017bc:	53                   	push   %ebx
  8017bd:	6a 00                	push   $0x0
  8017bf:	e8 19 f9 ff ff       	call   8010dd <ipc_recv>
}
  8017c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c7:	5b                   	pop    %ebx
  8017c8:	5e                   	pop    %esi
  8017c9:	5d                   	pop    %ebp
  8017ca:	c3                   	ret    

008017cb <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017cb:	55                   	push   %ebp
  8017cc:	89 e5                	mov    %esp,%ebp
  8017ce:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017df:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e9:	b8 02 00 00 00       	mov    $0x2,%eax
  8017ee:	e8 8d ff ff ff       	call   801780 <fsipc>
}
  8017f3:	c9                   	leave  
  8017f4:	c3                   	ret    

008017f5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017f5:	55                   	push   %ebp
  8017f6:	89 e5                	mov    %esp,%ebp
  8017f8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fe:	8b 40 0c             	mov    0xc(%eax),%eax
  801801:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801806:	ba 00 00 00 00       	mov    $0x0,%edx
  80180b:	b8 06 00 00 00       	mov    $0x6,%eax
  801810:	e8 6b ff ff ff       	call   801780 <fsipc>
}
  801815:	c9                   	leave  
  801816:	c3                   	ret    

00801817 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801817:	55                   	push   %ebp
  801818:	89 e5                	mov    %esp,%ebp
  80181a:	53                   	push   %ebx
  80181b:	83 ec 04             	sub    $0x4,%esp
  80181e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801821:	8b 45 08             	mov    0x8(%ebp),%eax
  801824:	8b 40 0c             	mov    0xc(%eax),%eax
  801827:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80182c:	ba 00 00 00 00       	mov    $0x0,%edx
  801831:	b8 05 00 00 00       	mov    $0x5,%eax
  801836:	e8 45 ff ff ff       	call   801780 <fsipc>
  80183b:	85 c0                	test   %eax,%eax
  80183d:	78 2c                	js     80186b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80183f:	83 ec 08             	sub    $0x8,%esp
  801842:	68 00 50 80 00       	push   $0x805000
  801847:	53                   	push   %ebx
  801848:	e8 69 ef ff ff       	call   8007b6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80184d:	a1 80 50 80 00       	mov    0x805080,%eax
  801852:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801858:	a1 84 50 80 00       	mov    0x805084,%eax
  80185d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801863:	83 c4 10             	add    $0x10,%esp
  801866:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80186b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80186e:	c9                   	leave  
  80186f:	c3                   	ret    

00801870 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	83 ec 0c             	sub    $0xc,%esp
  801876:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801879:	8b 55 08             	mov    0x8(%ebp),%edx
  80187c:	8b 52 0c             	mov    0xc(%edx),%edx
  80187f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801885:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80188a:	50                   	push   %eax
  80188b:	ff 75 0c             	pushl  0xc(%ebp)
  80188e:	68 08 50 80 00       	push   $0x805008
  801893:	e8 b0 f0 ff ff       	call   800948 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801898:	ba 00 00 00 00       	mov    $0x0,%edx
  80189d:	b8 04 00 00 00       	mov    $0x4,%eax
  8018a2:	e8 d9 fe ff ff       	call   801780 <fsipc>

}
  8018a7:	c9                   	leave  
  8018a8:	c3                   	ret    

008018a9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018a9:	55                   	push   %ebp
  8018aa:	89 e5                	mov    %esp,%ebp
  8018ac:	56                   	push   %esi
  8018ad:	53                   	push   %ebx
  8018ae:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018bc:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c7:	b8 03 00 00 00       	mov    $0x3,%eax
  8018cc:	e8 af fe ff ff       	call   801780 <fsipc>
  8018d1:	89 c3                	mov    %eax,%ebx
  8018d3:	85 c0                	test   %eax,%eax
  8018d5:	78 4b                	js     801922 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018d7:	39 c6                	cmp    %eax,%esi
  8018d9:	73 16                	jae    8018f1 <devfile_read+0x48>
  8018db:	68 4c 2b 80 00       	push   $0x802b4c
  8018e0:	68 53 2b 80 00       	push   $0x802b53
  8018e5:	6a 7c                	push   $0x7c
  8018e7:	68 68 2b 80 00       	push   $0x802b68
  8018ec:	e8 67 e8 ff ff       	call   800158 <_panic>
	assert(r <= PGSIZE);
  8018f1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018f6:	7e 16                	jle    80190e <devfile_read+0x65>
  8018f8:	68 73 2b 80 00       	push   $0x802b73
  8018fd:	68 53 2b 80 00       	push   $0x802b53
  801902:	6a 7d                	push   $0x7d
  801904:	68 68 2b 80 00       	push   $0x802b68
  801909:	e8 4a e8 ff ff       	call   800158 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80190e:	83 ec 04             	sub    $0x4,%esp
  801911:	50                   	push   %eax
  801912:	68 00 50 80 00       	push   $0x805000
  801917:	ff 75 0c             	pushl  0xc(%ebp)
  80191a:	e8 29 f0 ff ff       	call   800948 <memmove>
	return r;
  80191f:	83 c4 10             	add    $0x10,%esp
}
  801922:	89 d8                	mov    %ebx,%eax
  801924:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801927:	5b                   	pop    %ebx
  801928:	5e                   	pop    %esi
  801929:	5d                   	pop    %ebp
  80192a:	c3                   	ret    

0080192b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80192b:	55                   	push   %ebp
  80192c:	89 e5                	mov    %esp,%ebp
  80192e:	53                   	push   %ebx
  80192f:	83 ec 20             	sub    $0x20,%esp
  801932:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801935:	53                   	push   %ebx
  801936:	e8 42 ee ff ff       	call   80077d <strlen>
  80193b:	83 c4 10             	add    $0x10,%esp
  80193e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801943:	7f 67                	jg     8019ac <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801945:	83 ec 0c             	sub    $0xc,%esp
  801948:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80194b:	50                   	push   %eax
  80194c:	e8 a7 f8 ff ff       	call   8011f8 <fd_alloc>
  801951:	83 c4 10             	add    $0x10,%esp
		return r;
  801954:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801956:	85 c0                	test   %eax,%eax
  801958:	78 57                	js     8019b1 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80195a:	83 ec 08             	sub    $0x8,%esp
  80195d:	53                   	push   %ebx
  80195e:	68 00 50 80 00       	push   $0x805000
  801963:	e8 4e ee ff ff       	call   8007b6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801968:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801970:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801973:	b8 01 00 00 00       	mov    $0x1,%eax
  801978:	e8 03 fe ff ff       	call   801780 <fsipc>
  80197d:	89 c3                	mov    %eax,%ebx
  80197f:	83 c4 10             	add    $0x10,%esp
  801982:	85 c0                	test   %eax,%eax
  801984:	79 14                	jns    80199a <open+0x6f>
		fd_close(fd, 0);
  801986:	83 ec 08             	sub    $0x8,%esp
  801989:	6a 00                	push   $0x0
  80198b:	ff 75 f4             	pushl  -0xc(%ebp)
  80198e:	e8 5d f9 ff ff       	call   8012f0 <fd_close>
		return r;
  801993:	83 c4 10             	add    $0x10,%esp
  801996:	89 da                	mov    %ebx,%edx
  801998:	eb 17                	jmp    8019b1 <open+0x86>
	}

	return fd2num(fd);
  80199a:	83 ec 0c             	sub    $0xc,%esp
  80199d:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a0:	e8 2c f8 ff ff       	call   8011d1 <fd2num>
  8019a5:	89 c2                	mov    %eax,%edx
  8019a7:	83 c4 10             	add    $0x10,%esp
  8019aa:	eb 05                	jmp    8019b1 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019ac:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019b1:	89 d0                	mov    %edx,%eax
  8019b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b6:	c9                   	leave  
  8019b7:	c3                   	ret    

008019b8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019b8:	55                   	push   %ebp
  8019b9:	89 e5                	mov    %esp,%ebp
  8019bb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019be:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c3:	b8 08 00 00 00       	mov    $0x8,%eax
  8019c8:	e8 b3 fd ff ff       	call   801780 <fsipc>
}
  8019cd:	c9                   	leave  
  8019ce:	c3                   	ret    

008019cf <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019cf:	55                   	push   %ebp
  8019d0:	89 e5                	mov    %esp,%ebp
  8019d2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019d5:	68 7f 2b 80 00       	push   $0x802b7f
  8019da:	ff 75 0c             	pushl  0xc(%ebp)
  8019dd:	e8 d4 ed ff ff       	call   8007b6 <strcpy>
	return 0;
}
  8019e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e7:	c9                   	leave  
  8019e8:	c3                   	ret    

008019e9 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	53                   	push   %ebx
  8019ed:	83 ec 10             	sub    $0x10,%esp
  8019f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019f3:	53                   	push   %ebx
  8019f4:	e8 87 09 00 00       	call   802380 <pageref>
  8019f9:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8019fc:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a01:	83 f8 01             	cmp    $0x1,%eax
  801a04:	75 10                	jne    801a16 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a06:	83 ec 0c             	sub    $0xc,%esp
  801a09:	ff 73 0c             	pushl  0xc(%ebx)
  801a0c:	e8 c0 02 00 00       	call   801cd1 <nsipc_close>
  801a11:	89 c2                	mov    %eax,%edx
  801a13:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a16:	89 d0                	mov    %edx,%eax
  801a18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1b:	c9                   	leave  
  801a1c:	c3                   	ret    

00801a1d <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
  801a20:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a23:	6a 00                	push   $0x0
  801a25:	ff 75 10             	pushl  0x10(%ebp)
  801a28:	ff 75 0c             	pushl  0xc(%ebp)
  801a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2e:	ff 70 0c             	pushl  0xc(%eax)
  801a31:	e8 78 03 00 00       	call   801dae <nsipc_send>
}
  801a36:	c9                   	leave  
  801a37:	c3                   	ret    

00801a38 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a3e:	6a 00                	push   $0x0
  801a40:	ff 75 10             	pushl  0x10(%ebp)
  801a43:	ff 75 0c             	pushl  0xc(%ebp)
  801a46:	8b 45 08             	mov    0x8(%ebp),%eax
  801a49:	ff 70 0c             	pushl  0xc(%eax)
  801a4c:	e8 f1 02 00 00       	call   801d42 <nsipc_recv>
}
  801a51:	c9                   	leave  
  801a52:	c3                   	ret    

00801a53 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a53:	55                   	push   %ebp
  801a54:	89 e5                	mov    %esp,%ebp
  801a56:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a59:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a5c:	52                   	push   %edx
  801a5d:	50                   	push   %eax
  801a5e:	e8 e4 f7 ff ff       	call   801247 <fd_lookup>
  801a63:	83 c4 10             	add    $0x10,%esp
  801a66:	85 c0                	test   %eax,%eax
  801a68:	78 17                	js     801a81 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a6d:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a73:	39 08                	cmp    %ecx,(%eax)
  801a75:	75 05                	jne    801a7c <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a77:	8b 40 0c             	mov    0xc(%eax),%eax
  801a7a:	eb 05                	jmp    801a81 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a7c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a81:	c9                   	leave  
  801a82:	c3                   	ret    

00801a83 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a83:	55                   	push   %ebp
  801a84:	89 e5                	mov    %esp,%ebp
  801a86:	56                   	push   %esi
  801a87:	53                   	push   %ebx
  801a88:	83 ec 1c             	sub    $0x1c,%esp
  801a8b:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a8d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a90:	50                   	push   %eax
  801a91:	e8 62 f7 ff ff       	call   8011f8 <fd_alloc>
  801a96:	89 c3                	mov    %eax,%ebx
  801a98:	83 c4 10             	add    $0x10,%esp
  801a9b:	85 c0                	test   %eax,%eax
  801a9d:	78 1b                	js     801aba <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a9f:	83 ec 04             	sub    $0x4,%esp
  801aa2:	68 07 04 00 00       	push   $0x407
  801aa7:	ff 75 f4             	pushl  -0xc(%ebp)
  801aaa:	6a 00                	push   $0x0
  801aac:	e8 08 f1 ff ff       	call   800bb9 <sys_page_alloc>
  801ab1:	89 c3                	mov    %eax,%ebx
  801ab3:	83 c4 10             	add    $0x10,%esp
  801ab6:	85 c0                	test   %eax,%eax
  801ab8:	79 10                	jns    801aca <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801aba:	83 ec 0c             	sub    $0xc,%esp
  801abd:	56                   	push   %esi
  801abe:	e8 0e 02 00 00       	call   801cd1 <nsipc_close>
		return r;
  801ac3:	83 c4 10             	add    $0x10,%esp
  801ac6:	89 d8                	mov    %ebx,%eax
  801ac8:	eb 24                	jmp    801aee <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801aca:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad3:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801adf:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801ae2:	83 ec 0c             	sub    $0xc,%esp
  801ae5:	50                   	push   %eax
  801ae6:	e8 e6 f6 ff ff       	call   8011d1 <fd2num>
  801aeb:	83 c4 10             	add    $0x10,%esp
}
  801aee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af1:	5b                   	pop    %ebx
  801af2:	5e                   	pop    %esi
  801af3:	5d                   	pop    %ebp
  801af4:	c3                   	ret    

00801af5 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801af5:	55                   	push   %ebp
  801af6:	89 e5                	mov    %esp,%ebp
  801af8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801afb:	8b 45 08             	mov    0x8(%ebp),%eax
  801afe:	e8 50 ff ff ff       	call   801a53 <fd2sockid>
		return r;
  801b03:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b05:	85 c0                	test   %eax,%eax
  801b07:	78 1f                	js     801b28 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b09:	83 ec 04             	sub    $0x4,%esp
  801b0c:	ff 75 10             	pushl  0x10(%ebp)
  801b0f:	ff 75 0c             	pushl  0xc(%ebp)
  801b12:	50                   	push   %eax
  801b13:	e8 12 01 00 00       	call   801c2a <nsipc_accept>
  801b18:	83 c4 10             	add    $0x10,%esp
		return r;
  801b1b:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b1d:	85 c0                	test   %eax,%eax
  801b1f:	78 07                	js     801b28 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b21:	e8 5d ff ff ff       	call   801a83 <alloc_sockfd>
  801b26:	89 c1                	mov    %eax,%ecx
}
  801b28:	89 c8                	mov    %ecx,%eax
  801b2a:	c9                   	leave  
  801b2b:	c3                   	ret    

00801b2c <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
  801b2f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b32:	8b 45 08             	mov    0x8(%ebp),%eax
  801b35:	e8 19 ff ff ff       	call   801a53 <fd2sockid>
  801b3a:	85 c0                	test   %eax,%eax
  801b3c:	78 12                	js     801b50 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801b3e:	83 ec 04             	sub    $0x4,%esp
  801b41:	ff 75 10             	pushl  0x10(%ebp)
  801b44:	ff 75 0c             	pushl  0xc(%ebp)
  801b47:	50                   	push   %eax
  801b48:	e8 2d 01 00 00       	call   801c7a <nsipc_bind>
  801b4d:	83 c4 10             	add    $0x10,%esp
}
  801b50:	c9                   	leave  
  801b51:	c3                   	ret    

00801b52 <shutdown>:

int
shutdown(int s, int how)
{
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b58:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5b:	e8 f3 fe ff ff       	call   801a53 <fd2sockid>
  801b60:	85 c0                	test   %eax,%eax
  801b62:	78 0f                	js     801b73 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b64:	83 ec 08             	sub    $0x8,%esp
  801b67:	ff 75 0c             	pushl  0xc(%ebp)
  801b6a:	50                   	push   %eax
  801b6b:	e8 3f 01 00 00       	call   801caf <nsipc_shutdown>
  801b70:	83 c4 10             	add    $0x10,%esp
}
  801b73:	c9                   	leave  
  801b74:	c3                   	ret    

00801b75 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b75:	55                   	push   %ebp
  801b76:	89 e5                	mov    %esp,%ebp
  801b78:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7e:	e8 d0 fe ff ff       	call   801a53 <fd2sockid>
  801b83:	85 c0                	test   %eax,%eax
  801b85:	78 12                	js     801b99 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b87:	83 ec 04             	sub    $0x4,%esp
  801b8a:	ff 75 10             	pushl  0x10(%ebp)
  801b8d:	ff 75 0c             	pushl  0xc(%ebp)
  801b90:	50                   	push   %eax
  801b91:	e8 55 01 00 00       	call   801ceb <nsipc_connect>
  801b96:	83 c4 10             	add    $0x10,%esp
}
  801b99:	c9                   	leave  
  801b9a:	c3                   	ret    

00801b9b <listen>:

int
listen(int s, int backlog)
{
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
  801b9e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ba1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba4:	e8 aa fe ff ff       	call   801a53 <fd2sockid>
  801ba9:	85 c0                	test   %eax,%eax
  801bab:	78 0f                	js     801bbc <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801bad:	83 ec 08             	sub    $0x8,%esp
  801bb0:	ff 75 0c             	pushl  0xc(%ebp)
  801bb3:	50                   	push   %eax
  801bb4:	e8 67 01 00 00       	call   801d20 <nsipc_listen>
  801bb9:	83 c4 10             	add    $0x10,%esp
}
  801bbc:	c9                   	leave  
  801bbd:	c3                   	ret    

00801bbe <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
  801bc1:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bc4:	ff 75 10             	pushl  0x10(%ebp)
  801bc7:	ff 75 0c             	pushl  0xc(%ebp)
  801bca:	ff 75 08             	pushl  0x8(%ebp)
  801bcd:	e8 3a 02 00 00       	call   801e0c <nsipc_socket>
  801bd2:	83 c4 10             	add    $0x10,%esp
  801bd5:	85 c0                	test   %eax,%eax
  801bd7:	78 05                	js     801bde <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801bd9:	e8 a5 fe ff ff       	call   801a83 <alloc_sockfd>
}
  801bde:	c9                   	leave  
  801bdf:	c3                   	ret    

00801be0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801be0:	55                   	push   %ebp
  801be1:	89 e5                	mov    %esp,%ebp
  801be3:	53                   	push   %ebx
  801be4:	83 ec 04             	sub    $0x4,%esp
  801be7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801be9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801bf0:	75 12                	jne    801c04 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801bf2:	83 ec 0c             	sub    $0xc,%esp
  801bf5:	6a 02                	push   $0x2
  801bf7:	e8 9c f5 ff ff       	call   801198 <ipc_find_env>
  801bfc:	a3 04 40 80 00       	mov    %eax,0x804004
  801c01:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c04:	6a 07                	push   $0x7
  801c06:	68 00 60 80 00       	push   $0x806000
  801c0b:	53                   	push   %ebx
  801c0c:	ff 35 04 40 80 00    	pushl  0x804004
  801c12:	e8 2d f5 ff ff       	call   801144 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c17:	83 c4 0c             	add    $0xc,%esp
  801c1a:	6a 00                	push   $0x0
  801c1c:	6a 00                	push   $0x0
  801c1e:	6a 00                	push   $0x0
  801c20:	e8 b8 f4 ff ff       	call   8010dd <ipc_recv>
}
  801c25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c28:	c9                   	leave  
  801c29:	c3                   	ret    

00801c2a <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c2a:	55                   	push   %ebp
  801c2b:	89 e5                	mov    %esp,%ebp
  801c2d:	56                   	push   %esi
  801c2e:	53                   	push   %ebx
  801c2f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c32:	8b 45 08             	mov    0x8(%ebp),%eax
  801c35:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c3a:	8b 06                	mov    (%esi),%eax
  801c3c:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c41:	b8 01 00 00 00       	mov    $0x1,%eax
  801c46:	e8 95 ff ff ff       	call   801be0 <nsipc>
  801c4b:	89 c3                	mov    %eax,%ebx
  801c4d:	85 c0                	test   %eax,%eax
  801c4f:	78 20                	js     801c71 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c51:	83 ec 04             	sub    $0x4,%esp
  801c54:	ff 35 10 60 80 00    	pushl  0x806010
  801c5a:	68 00 60 80 00       	push   $0x806000
  801c5f:	ff 75 0c             	pushl  0xc(%ebp)
  801c62:	e8 e1 ec ff ff       	call   800948 <memmove>
		*addrlen = ret->ret_addrlen;
  801c67:	a1 10 60 80 00       	mov    0x806010,%eax
  801c6c:	89 06                	mov    %eax,(%esi)
  801c6e:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c71:	89 d8                	mov    %ebx,%eax
  801c73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c76:	5b                   	pop    %ebx
  801c77:	5e                   	pop    %esi
  801c78:	5d                   	pop    %ebp
  801c79:	c3                   	ret    

00801c7a <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c7a:	55                   	push   %ebp
  801c7b:	89 e5                	mov    %esp,%ebp
  801c7d:	53                   	push   %ebx
  801c7e:	83 ec 08             	sub    $0x8,%esp
  801c81:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c84:	8b 45 08             	mov    0x8(%ebp),%eax
  801c87:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c8c:	53                   	push   %ebx
  801c8d:	ff 75 0c             	pushl  0xc(%ebp)
  801c90:	68 04 60 80 00       	push   $0x806004
  801c95:	e8 ae ec ff ff       	call   800948 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c9a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801ca0:	b8 02 00 00 00       	mov    $0x2,%eax
  801ca5:	e8 36 ff ff ff       	call   801be0 <nsipc>
}
  801caa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cad:	c9                   	leave  
  801cae:	c3                   	ret    

00801caf <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801caf:	55                   	push   %ebp
  801cb0:	89 e5                	mov    %esp,%ebp
  801cb2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801cb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801cbd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc0:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801cc5:	b8 03 00 00 00       	mov    $0x3,%eax
  801cca:	e8 11 ff ff ff       	call   801be0 <nsipc>
}
  801ccf:	c9                   	leave  
  801cd0:	c3                   	ret    

00801cd1 <nsipc_close>:

int
nsipc_close(int s)
{
  801cd1:	55                   	push   %ebp
  801cd2:	89 e5                	mov    %esp,%ebp
  801cd4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801cd7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cda:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801cdf:	b8 04 00 00 00       	mov    $0x4,%eax
  801ce4:	e8 f7 fe ff ff       	call   801be0 <nsipc>
}
  801ce9:	c9                   	leave  
  801cea:	c3                   	ret    

00801ceb <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ceb:	55                   	push   %ebp
  801cec:	89 e5                	mov    %esp,%ebp
  801cee:	53                   	push   %ebx
  801cef:	83 ec 08             	sub    $0x8,%esp
  801cf2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cf5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf8:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801cfd:	53                   	push   %ebx
  801cfe:	ff 75 0c             	pushl  0xc(%ebp)
  801d01:	68 04 60 80 00       	push   $0x806004
  801d06:	e8 3d ec ff ff       	call   800948 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d0b:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d11:	b8 05 00 00 00       	mov    $0x5,%eax
  801d16:	e8 c5 fe ff ff       	call   801be0 <nsipc>
}
  801d1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d1e:	c9                   	leave  
  801d1f:	c3                   	ret    

00801d20 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d20:	55                   	push   %ebp
  801d21:	89 e5                	mov    %esp,%ebp
  801d23:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d26:	8b 45 08             	mov    0x8(%ebp),%eax
  801d29:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d31:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d36:	b8 06 00 00 00       	mov    $0x6,%eax
  801d3b:	e8 a0 fe ff ff       	call   801be0 <nsipc>
}
  801d40:	c9                   	leave  
  801d41:	c3                   	ret    

00801d42 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d42:	55                   	push   %ebp
  801d43:	89 e5                	mov    %esp,%ebp
  801d45:	56                   	push   %esi
  801d46:	53                   	push   %ebx
  801d47:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d52:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d58:	8b 45 14             	mov    0x14(%ebp),%eax
  801d5b:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d60:	b8 07 00 00 00       	mov    $0x7,%eax
  801d65:	e8 76 fe ff ff       	call   801be0 <nsipc>
  801d6a:	89 c3                	mov    %eax,%ebx
  801d6c:	85 c0                	test   %eax,%eax
  801d6e:	78 35                	js     801da5 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d70:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d75:	7f 04                	jg     801d7b <nsipc_recv+0x39>
  801d77:	39 c6                	cmp    %eax,%esi
  801d79:	7d 16                	jge    801d91 <nsipc_recv+0x4f>
  801d7b:	68 8b 2b 80 00       	push   $0x802b8b
  801d80:	68 53 2b 80 00       	push   $0x802b53
  801d85:	6a 62                	push   $0x62
  801d87:	68 a0 2b 80 00       	push   $0x802ba0
  801d8c:	e8 c7 e3 ff ff       	call   800158 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d91:	83 ec 04             	sub    $0x4,%esp
  801d94:	50                   	push   %eax
  801d95:	68 00 60 80 00       	push   $0x806000
  801d9a:	ff 75 0c             	pushl  0xc(%ebp)
  801d9d:	e8 a6 eb ff ff       	call   800948 <memmove>
  801da2:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801da5:	89 d8                	mov    %ebx,%eax
  801da7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801daa:	5b                   	pop    %ebx
  801dab:	5e                   	pop    %esi
  801dac:	5d                   	pop    %ebp
  801dad:	c3                   	ret    

00801dae <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801dae:	55                   	push   %ebp
  801daf:	89 e5                	mov    %esp,%ebp
  801db1:	53                   	push   %ebx
  801db2:	83 ec 04             	sub    $0x4,%esp
  801db5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801db8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbb:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801dc0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801dc6:	7e 16                	jle    801dde <nsipc_send+0x30>
  801dc8:	68 ac 2b 80 00       	push   $0x802bac
  801dcd:	68 53 2b 80 00       	push   $0x802b53
  801dd2:	6a 6d                	push   $0x6d
  801dd4:	68 a0 2b 80 00       	push   $0x802ba0
  801dd9:	e8 7a e3 ff ff       	call   800158 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801dde:	83 ec 04             	sub    $0x4,%esp
  801de1:	53                   	push   %ebx
  801de2:	ff 75 0c             	pushl  0xc(%ebp)
  801de5:	68 0c 60 80 00       	push   $0x80600c
  801dea:	e8 59 eb ff ff       	call   800948 <memmove>
	nsipcbuf.send.req_size = size;
  801def:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801df5:	8b 45 14             	mov    0x14(%ebp),%eax
  801df8:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801dfd:	b8 08 00 00 00       	mov    $0x8,%eax
  801e02:	e8 d9 fd ff ff       	call   801be0 <nsipc>
}
  801e07:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e0a:	c9                   	leave  
  801e0b:	c3                   	ret    

00801e0c <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e0c:	55                   	push   %ebp
  801e0d:	89 e5                	mov    %esp,%ebp
  801e0f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e12:	8b 45 08             	mov    0x8(%ebp),%eax
  801e15:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e1d:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e22:	8b 45 10             	mov    0x10(%ebp),%eax
  801e25:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e2a:	b8 09 00 00 00       	mov    $0x9,%eax
  801e2f:	e8 ac fd ff ff       	call   801be0 <nsipc>
}
  801e34:	c9                   	leave  
  801e35:	c3                   	ret    

00801e36 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e36:	55                   	push   %ebp
  801e37:	89 e5                	mov    %esp,%ebp
  801e39:	56                   	push   %esi
  801e3a:	53                   	push   %ebx
  801e3b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e3e:	83 ec 0c             	sub    $0xc,%esp
  801e41:	ff 75 08             	pushl  0x8(%ebp)
  801e44:	e8 98 f3 ff ff       	call   8011e1 <fd2data>
  801e49:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e4b:	83 c4 08             	add    $0x8,%esp
  801e4e:	68 b8 2b 80 00       	push   $0x802bb8
  801e53:	53                   	push   %ebx
  801e54:	e8 5d e9 ff ff       	call   8007b6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e59:	8b 46 04             	mov    0x4(%esi),%eax
  801e5c:	2b 06                	sub    (%esi),%eax
  801e5e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e64:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e6b:	00 00 00 
	stat->st_dev = &devpipe;
  801e6e:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e75:	30 80 00 
	return 0;
}
  801e78:	b8 00 00 00 00       	mov    $0x0,%eax
  801e7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e80:	5b                   	pop    %ebx
  801e81:	5e                   	pop    %esi
  801e82:	5d                   	pop    %ebp
  801e83:	c3                   	ret    

00801e84 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e84:	55                   	push   %ebp
  801e85:	89 e5                	mov    %esp,%ebp
  801e87:	53                   	push   %ebx
  801e88:	83 ec 0c             	sub    $0xc,%esp
  801e8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e8e:	53                   	push   %ebx
  801e8f:	6a 00                	push   $0x0
  801e91:	e8 a8 ed ff ff       	call   800c3e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e96:	89 1c 24             	mov    %ebx,(%esp)
  801e99:	e8 43 f3 ff ff       	call   8011e1 <fd2data>
  801e9e:	83 c4 08             	add    $0x8,%esp
  801ea1:	50                   	push   %eax
  801ea2:	6a 00                	push   $0x0
  801ea4:	e8 95 ed ff ff       	call   800c3e <sys_page_unmap>
}
  801ea9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eac:	c9                   	leave  
  801ead:	c3                   	ret    

00801eae <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801eae:	55                   	push   %ebp
  801eaf:	89 e5                	mov    %esp,%ebp
  801eb1:	57                   	push   %edi
  801eb2:	56                   	push   %esi
  801eb3:	53                   	push   %ebx
  801eb4:	83 ec 1c             	sub    $0x1c,%esp
  801eb7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801eba:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ebc:	a1 08 40 80 00       	mov    0x804008,%eax
  801ec1:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ec4:	83 ec 0c             	sub    $0xc,%esp
  801ec7:	ff 75 e0             	pushl  -0x20(%ebp)
  801eca:	e8 b1 04 00 00       	call   802380 <pageref>
  801ecf:	89 c3                	mov    %eax,%ebx
  801ed1:	89 3c 24             	mov    %edi,(%esp)
  801ed4:	e8 a7 04 00 00       	call   802380 <pageref>
  801ed9:	83 c4 10             	add    $0x10,%esp
  801edc:	39 c3                	cmp    %eax,%ebx
  801ede:	0f 94 c1             	sete   %cl
  801ee1:	0f b6 c9             	movzbl %cl,%ecx
  801ee4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ee7:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801eed:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ef0:	39 ce                	cmp    %ecx,%esi
  801ef2:	74 1b                	je     801f0f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ef4:	39 c3                	cmp    %eax,%ebx
  801ef6:	75 c4                	jne    801ebc <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ef8:	8b 42 58             	mov    0x58(%edx),%eax
  801efb:	ff 75 e4             	pushl  -0x1c(%ebp)
  801efe:	50                   	push   %eax
  801eff:	56                   	push   %esi
  801f00:	68 bf 2b 80 00       	push   $0x802bbf
  801f05:	e8 27 e3 ff ff       	call   800231 <cprintf>
  801f0a:	83 c4 10             	add    $0x10,%esp
  801f0d:	eb ad                	jmp    801ebc <_pipeisclosed+0xe>
	}
}
  801f0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f15:	5b                   	pop    %ebx
  801f16:	5e                   	pop    %esi
  801f17:	5f                   	pop    %edi
  801f18:	5d                   	pop    %ebp
  801f19:	c3                   	ret    

00801f1a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f1a:	55                   	push   %ebp
  801f1b:	89 e5                	mov    %esp,%ebp
  801f1d:	57                   	push   %edi
  801f1e:	56                   	push   %esi
  801f1f:	53                   	push   %ebx
  801f20:	83 ec 28             	sub    $0x28,%esp
  801f23:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f26:	56                   	push   %esi
  801f27:	e8 b5 f2 ff ff       	call   8011e1 <fd2data>
  801f2c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f2e:	83 c4 10             	add    $0x10,%esp
  801f31:	bf 00 00 00 00       	mov    $0x0,%edi
  801f36:	eb 4b                	jmp    801f83 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f38:	89 da                	mov    %ebx,%edx
  801f3a:	89 f0                	mov    %esi,%eax
  801f3c:	e8 6d ff ff ff       	call   801eae <_pipeisclosed>
  801f41:	85 c0                	test   %eax,%eax
  801f43:	75 48                	jne    801f8d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f45:	e8 50 ec ff ff       	call   800b9a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f4a:	8b 43 04             	mov    0x4(%ebx),%eax
  801f4d:	8b 0b                	mov    (%ebx),%ecx
  801f4f:	8d 51 20             	lea    0x20(%ecx),%edx
  801f52:	39 d0                	cmp    %edx,%eax
  801f54:	73 e2                	jae    801f38 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f59:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f5d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f60:	89 c2                	mov    %eax,%edx
  801f62:	c1 fa 1f             	sar    $0x1f,%edx
  801f65:	89 d1                	mov    %edx,%ecx
  801f67:	c1 e9 1b             	shr    $0x1b,%ecx
  801f6a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f6d:	83 e2 1f             	and    $0x1f,%edx
  801f70:	29 ca                	sub    %ecx,%edx
  801f72:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f76:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f7a:	83 c0 01             	add    $0x1,%eax
  801f7d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f80:	83 c7 01             	add    $0x1,%edi
  801f83:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f86:	75 c2                	jne    801f4a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f88:	8b 45 10             	mov    0x10(%ebp),%eax
  801f8b:	eb 05                	jmp    801f92 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f8d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f95:	5b                   	pop    %ebx
  801f96:	5e                   	pop    %esi
  801f97:	5f                   	pop    %edi
  801f98:	5d                   	pop    %ebp
  801f99:	c3                   	ret    

00801f9a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f9a:	55                   	push   %ebp
  801f9b:	89 e5                	mov    %esp,%ebp
  801f9d:	57                   	push   %edi
  801f9e:	56                   	push   %esi
  801f9f:	53                   	push   %ebx
  801fa0:	83 ec 18             	sub    $0x18,%esp
  801fa3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fa6:	57                   	push   %edi
  801fa7:	e8 35 f2 ff ff       	call   8011e1 <fd2data>
  801fac:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fae:	83 c4 10             	add    $0x10,%esp
  801fb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fb6:	eb 3d                	jmp    801ff5 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801fb8:	85 db                	test   %ebx,%ebx
  801fba:	74 04                	je     801fc0 <devpipe_read+0x26>
				return i;
  801fbc:	89 d8                	mov    %ebx,%eax
  801fbe:	eb 44                	jmp    802004 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fc0:	89 f2                	mov    %esi,%edx
  801fc2:	89 f8                	mov    %edi,%eax
  801fc4:	e8 e5 fe ff ff       	call   801eae <_pipeisclosed>
  801fc9:	85 c0                	test   %eax,%eax
  801fcb:	75 32                	jne    801fff <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801fcd:	e8 c8 eb ff ff       	call   800b9a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801fd2:	8b 06                	mov    (%esi),%eax
  801fd4:	3b 46 04             	cmp    0x4(%esi),%eax
  801fd7:	74 df                	je     801fb8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fd9:	99                   	cltd   
  801fda:	c1 ea 1b             	shr    $0x1b,%edx
  801fdd:	01 d0                	add    %edx,%eax
  801fdf:	83 e0 1f             	and    $0x1f,%eax
  801fe2:	29 d0                	sub    %edx,%eax
  801fe4:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801fe9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fec:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801fef:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ff2:	83 c3 01             	add    $0x1,%ebx
  801ff5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ff8:	75 d8                	jne    801fd2 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ffa:	8b 45 10             	mov    0x10(%ebp),%eax
  801ffd:	eb 05                	jmp    802004 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fff:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802004:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802007:	5b                   	pop    %ebx
  802008:	5e                   	pop    %esi
  802009:	5f                   	pop    %edi
  80200a:	5d                   	pop    %ebp
  80200b:	c3                   	ret    

0080200c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80200c:	55                   	push   %ebp
  80200d:	89 e5                	mov    %esp,%ebp
  80200f:	56                   	push   %esi
  802010:	53                   	push   %ebx
  802011:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802014:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802017:	50                   	push   %eax
  802018:	e8 db f1 ff ff       	call   8011f8 <fd_alloc>
  80201d:	83 c4 10             	add    $0x10,%esp
  802020:	89 c2                	mov    %eax,%edx
  802022:	85 c0                	test   %eax,%eax
  802024:	0f 88 2c 01 00 00    	js     802156 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80202a:	83 ec 04             	sub    $0x4,%esp
  80202d:	68 07 04 00 00       	push   $0x407
  802032:	ff 75 f4             	pushl  -0xc(%ebp)
  802035:	6a 00                	push   $0x0
  802037:	e8 7d eb ff ff       	call   800bb9 <sys_page_alloc>
  80203c:	83 c4 10             	add    $0x10,%esp
  80203f:	89 c2                	mov    %eax,%edx
  802041:	85 c0                	test   %eax,%eax
  802043:	0f 88 0d 01 00 00    	js     802156 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802049:	83 ec 0c             	sub    $0xc,%esp
  80204c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80204f:	50                   	push   %eax
  802050:	e8 a3 f1 ff ff       	call   8011f8 <fd_alloc>
  802055:	89 c3                	mov    %eax,%ebx
  802057:	83 c4 10             	add    $0x10,%esp
  80205a:	85 c0                	test   %eax,%eax
  80205c:	0f 88 e2 00 00 00    	js     802144 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802062:	83 ec 04             	sub    $0x4,%esp
  802065:	68 07 04 00 00       	push   $0x407
  80206a:	ff 75 f0             	pushl  -0x10(%ebp)
  80206d:	6a 00                	push   $0x0
  80206f:	e8 45 eb ff ff       	call   800bb9 <sys_page_alloc>
  802074:	89 c3                	mov    %eax,%ebx
  802076:	83 c4 10             	add    $0x10,%esp
  802079:	85 c0                	test   %eax,%eax
  80207b:	0f 88 c3 00 00 00    	js     802144 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802081:	83 ec 0c             	sub    $0xc,%esp
  802084:	ff 75 f4             	pushl  -0xc(%ebp)
  802087:	e8 55 f1 ff ff       	call   8011e1 <fd2data>
  80208c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80208e:	83 c4 0c             	add    $0xc,%esp
  802091:	68 07 04 00 00       	push   $0x407
  802096:	50                   	push   %eax
  802097:	6a 00                	push   $0x0
  802099:	e8 1b eb ff ff       	call   800bb9 <sys_page_alloc>
  80209e:	89 c3                	mov    %eax,%ebx
  8020a0:	83 c4 10             	add    $0x10,%esp
  8020a3:	85 c0                	test   %eax,%eax
  8020a5:	0f 88 89 00 00 00    	js     802134 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020ab:	83 ec 0c             	sub    $0xc,%esp
  8020ae:	ff 75 f0             	pushl  -0x10(%ebp)
  8020b1:	e8 2b f1 ff ff       	call   8011e1 <fd2data>
  8020b6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020bd:	50                   	push   %eax
  8020be:	6a 00                	push   $0x0
  8020c0:	56                   	push   %esi
  8020c1:	6a 00                	push   $0x0
  8020c3:	e8 34 eb ff ff       	call   800bfc <sys_page_map>
  8020c8:	89 c3                	mov    %eax,%ebx
  8020ca:	83 c4 20             	add    $0x20,%esp
  8020cd:	85 c0                	test   %eax,%eax
  8020cf:	78 55                	js     802126 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020d1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020da:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020df:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020e6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020ef:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020f4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020fb:	83 ec 0c             	sub    $0xc,%esp
  8020fe:	ff 75 f4             	pushl  -0xc(%ebp)
  802101:	e8 cb f0 ff ff       	call   8011d1 <fd2num>
  802106:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802109:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80210b:	83 c4 04             	add    $0x4,%esp
  80210e:	ff 75 f0             	pushl  -0x10(%ebp)
  802111:	e8 bb f0 ff ff       	call   8011d1 <fd2num>
  802116:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802119:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80211c:	83 c4 10             	add    $0x10,%esp
  80211f:	ba 00 00 00 00       	mov    $0x0,%edx
  802124:	eb 30                	jmp    802156 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802126:	83 ec 08             	sub    $0x8,%esp
  802129:	56                   	push   %esi
  80212a:	6a 00                	push   $0x0
  80212c:	e8 0d eb ff ff       	call   800c3e <sys_page_unmap>
  802131:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802134:	83 ec 08             	sub    $0x8,%esp
  802137:	ff 75 f0             	pushl  -0x10(%ebp)
  80213a:	6a 00                	push   $0x0
  80213c:	e8 fd ea ff ff       	call   800c3e <sys_page_unmap>
  802141:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802144:	83 ec 08             	sub    $0x8,%esp
  802147:	ff 75 f4             	pushl  -0xc(%ebp)
  80214a:	6a 00                	push   $0x0
  80214c:	e8 ed ea ff ff       	call   800c3e <sys_page_unmap>
  802151:	83 c4 10             	add    $0x10,%esp
  802154:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802156:	89 d0                	mov    %edx,%eax
  802158:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80215b:	5b                   	pop    %ebx
  80215c:	5e                   	pop    %esi
  80215d:	5d                   	pop    %ebp
  80215e:	c3                   	ret    

0080215f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80215f:	55                   	push   %ebp
  802160:	89 e5                	mov    %esp,%ebp
  802162:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802165:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802168:	50                   	push   %eax
  802169:	ff 75 08             	pushl  0x8(%ebp)
  80216c:	e8 d6 f0 ff ff       	call   801247 <fd_lookup>
  802171:	83 c4 10             	add    $0x10,%esp
  802174:	85 c0                	test   %eax,%eax
  802176:	78 18                	js     802190 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802178:	83 ec 0c             	sub    $0xc,%esp
  80217b:	ff 75 f4             	pushl  -0xc(%ebp)
  80217e:	e8 5e f0 ff ff       	call   8011e1 <fd2data>
	return _pipeisclosed(fd, p);
  802183:	89 c2                	mov    %eax,%edx
  802185:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802188:	e8 21 fd ff ff       	call   801eae <_pipeisclosed>
  80218d:	83 c4 10             	add    $0x10,%esp
}
  802190:	c9                   	leave  
  802191:	c3                   	ret    

00802192 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802192:	55                   	push   %ebp
  802193:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802195:	b8 00 00 00 00       	mov    $0x0,%eax
  80219a:	5d                   	pop    %ebp
  80219b:	c3                   	ret    

0080219c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80219c:	55                   	push   %ebp
  80219d:	89 e5                	mov    %esp,%ebp
  80219f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021a2:	68 d7 2b 80 00       	push   $0x802bd7
  8021a7:	ff 75 0c             	pushl  0xc(%ebp)
  8021aa:	e8 07 e6 ff ff       	call   8007b6 <strcpy>
	return 0;
}
  8021af:	b8 00 00 00 00       	mov    $0x0,%eax
  8021b4:	c9                   	leave  
  8021b5:	c3                   	ret    

008021b6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021b6:	55                   	push   %ebp
  8021b7:	89 e5                	mov    %esp,%ebp
  8021b9:	57                   	push   %edi
  8021ba:	56                   	push   %esi
  8021bb:	53                   	push   %ebx
  8021bc:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021c2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021c7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021cd:	eb 2d                	jmp    8021fc <devcons_write+0x46>
		m = n - tot;
  8021cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021d2:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8021d4:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8021d7:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8021dc:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021df:	83 ec 04             	sub    $0x4,%esp
  8021e2:	53                   	push   %ebx
  8021e3:	03 45 0c             	add    0xc(%ebp),%eax
  8021e6:	50                   	push   %eax
  8021e7:	57                   	push   %edi
  8021e8:	e8 5b e7 ff ff       	call   800948 <memmove>
		sys_cputs(buf, m);
  8021ed:	83 c4 08             	add    $0x8,%esp
  8021f0:	53                   	push   %ebx
  8021f1:	57                   	push   %edi
  8021f2:	e8 06 e9 ff ff       	call   800afd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021f7:	01 de                	add    %ebx,%esi
  8021f9:	83 c4 10             	add    $0x10,%esp
  8021fc:	89 f0                	mov    %esi,%eax
  8021fe:	3b 75 10             	cmp    0x10(%ebp),%esi
  802201:	72 cc                	jb     8021cf <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802203:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802206:	5b                   	pop    %ebx
  802207:	5e                   	pop    %esi
  802208:	5f                   	pop    %edi
  802209:	5d                   	pop    %ebp
  80220a:	c3                   	ret    

0080220b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80220b:	55                   	push   %ebp
  80220c:	89 e5                	mov    %esp,%ebp
  80220e:	83 ec 08             	sub    $0x8,%esp
  802211:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802216:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80221a:	74 2a                	je     802246 <devcons_read+0x3b>
  80221c:	eb 05                	jmp    802223 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80221e:	e8 77 e9 ff ff       	call   800b9a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802223:	e8 f3 e8 ff ff       	call   800b1b <sys_cgetc>
  802228:	85 c0                	test   %eax,%eax
  80222a:	74 f2                	je     80221e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80222c:	85 c0                	test   %eax,%eax
  80222e:	78 16                	js     802246 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802230:	83 f8 04             	cmp    $0x4,%eax
  802233:	74 0c                	je     802241 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802235:	8b 55 0c             	mov    0xc(%ebp),%edx
  802238:	88 02                	mov    %al,(%edx)
	return 1;
  80223a:	b8 01 00 00 00       	mov    $0x1,%eax
  80223f:	eb 05                	jmp    802246 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802241:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802246:	c9                   	leave  
  802247:	c3                   	ret    

00802248 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802248:	55                   	push   %ebp
  802249:	89 e5                	mov    %esp,%ebp
  80224b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80224e:	8b 45 08             	mov    0x8(%ebp),%eax
  802251:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802254:	6a 01                	push   $0x1
  802256:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802259:	50                   	push   %eax
  80225a:	e8 9e e8 ff ff       	call   800afd <sys_cputs>
}
  80225f:	83 c4 10             	add    $0x10,%esp
  802262:	c9                   	leave  
  802263:	c3                   	ret    

00802264 <getchar>:

int
getchar(void)
{
  802264:	55                   	push   %ebp
  802265:	89 e5                	mov    %esp,%ebp
  802267:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80226a:	6a 01                	push   $0x1
  80226c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80226f:	50                   	push   %eax
  802270:	6a 00                	push   $0x0
  802272:	e8 36 f2 ff ff       	call   8014ad <read>
	if (r < 0)
  802277:	83 c4 10             	add    $0x10,%esp
  80227a:	85 c0                	test   %eax,%eax
  80227c:	78 0f                	js     80228d <getchar+0x29>
		return r;
	if (r < 1)
  80227e:	85 c0                	test   %eax,%eax
  802280:	7e 06                	jle    802288 <getchar+0x24>
		return -E_EOF;
	return c;
  802282:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802286:	eb 05                	jmp    80228d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802288:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80228d:	c9                   	leave  
  80228e:	c3                   	ret    

0080228f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80228f:	55                   	push   %ebp
  802290:	89 e5                	mov    %esp,%ebp
  802292:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802295:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802298:	50                   	push   %eax
  802299:	ff 75 08             	pushl  0x8(%ebp)
  80229c:	e8 a6 ef ff ff       	call   801247 <fd_lookup>
  8022a1:	83 c4 10             	add    $0x10,%esp
  8022a4:	85 c0                	test   %eax,%eax
  8022a6:	78 11                	js     8022b9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ab:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022b1:	39 10                	cmp    %edx,(%eax)
  8022b3:	0f 94 c0             	sete   %al
  8022b6:	0f b6 c0             	movzbl %al,%eax
}
  8022b9:	c9                   	leave  
  8022ba:	c3                   	ret    

008022bb <opencons>:

int
opencons(void)
{
  8022bb:	55                   	push   %ebp
  8022bc:	89 e5                	mov    %esp,%ebp
  8022be:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022c4:	50                   	push   %eax
  8022c5:	e8 2e ef ff ff       	call   8011f8 <fd_alloc>
  8022ca:	83 c4 10             	add    $0x10,%esp
		return r;
  8022cd:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022cf:	85 c0                	test   %eax,%eax
  8022d1:	78 3e                	js     802311 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022d3:	83 ec 04             	sub    $0x4,%esp
  8022d6:	68 07 04 00 00       	push   $0x407
  8022db:	ff 75 f4             	pushl  -0xc(%ebp)
  8022de:	6a 00                	push   $0x0
  8022e0:	e8 d4 e8 ff ff       	call   800bb9 <sys_page_alloc>
  8022e5:	83 c4 10             	add    $0x10,%esp
		return r;
  8022e8:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022ea:	85 c0                	test   %eax,%eax
  8022ec:	78 23                	js     802311 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022ee:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022f7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022fc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802303:	83 ec 0c             	sub    $0xc,%esp
  802306:	50                   	push   %eax
  802307:	e8 c5 ee ff ff       	call   8011d1 <fd2num>
  80230c:	89 c2                	mov    %eax,%edx
  80230e:	83 c4 10             	add    $0x10,%esp
}
  802311:	89 d0                	mov    %edx,%eax
  802313:	c9                   	leave  
  802314:	c3                   	ret    

00802315 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802315:	55                   	push   %ebp
  802316:	89 e5                	mov    %esp,%ebp
  802318:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80231b:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802322:	75 2e                	jne    802352 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  802324:	e8 52 e8 ff ff       	call   800b7b <sys_getenvid>
  802329:	83 ec 04             	sub    $0x4,%esp
  80232c:	68 07 0e 00 00       	push   $0xe07
  802331:	68 00 f0 bf ee       	push   $0xeebff000
  802336:	50                   	push   %eax
  802337:	e8 7d e8 ff ff       	call   800bb9 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  80233c:	e8 3a e8 ff ff       	call   800b7b <sys_getenvid>
  802341:	83 c4 08             	add    $0x8,%esp
  802344:	68 5c 23 80 00       	push   $0x80235c
  802349:	50                   	push   %eax
  80234a:	e8 b5 e9 ff ff       	call   800d04 <sys_env_set_pgfault_upcall>
  80234f:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802352:	8b 45 08             	mov    0x8(%ebp),%eax
  802355:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80235a:	c9                   	leave  
  80235b:	c3                   	ret    

0080235c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80235c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80235d:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802362:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802364:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  802367:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  80236b:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  80236f:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  802372:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  802375:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  802376:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  802379:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  80237a:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  80237b:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  80237f:	c3                   	ret    

00802380 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802380:	55                   	push   %ebp
  802381:	89 e5                	mov    %esp,%ebp
  802383:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802386:	89 d0                	mov    %edx,%eax
  802388:	c1 e8 16             	shr    $0x16,%eax
  80238b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802392:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802397:	f6 c1 01             	test   $0x1,%cl
  80239a:	74 1d                	je     8023b9 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80239c:	c1 ea 0c             	shr    $0xc,%edx
  80239f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023a6:	f6 c2 01             	test   $0x1,%dl
  8023a9:	74 0e                	je     8023b9 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023ab:	c1 ea 0c             	shr    $0xc,%edx
  8023ae:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8023b5:	ef 
  8023b6:	0f b7 c0             	movzwl %ax,%eax
}
  8023b9:	5d                   	pop    %ebp
  8023ba:	c3                   	ret    
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
