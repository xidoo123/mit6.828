
obj/user/testtime.debug:     file format elf32-i386


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
  80002c:	e8 c8 00 00 00       	call   8000f9 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <sleep>:
#include <inc/lib.h>
#include <inc/x86.h>

void
sleep(int sec)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
	unsigned now = sys_time_msec();
  80003a:	e8 6c 0d 00 00       	call   800dab <sys_time_msec>
	unsigned end = now + sec * 1000;
  80003f:	69 5d 08 e8 03 00 00 	imul   $0x3e8,0x8(%ebp),%ebx
  800046:	01 c3                	add    %eax,%ebx

	if ((int)now < 0 && (int)now > -MAXERROR)
  800048:	89 c2                	mov    %eax,%edx
  80004a:	c1 ea 1f             	shr    $0x1f,%edx
  80004d:	84 d2                	test   %dl,%dl
  80004f:	74 17                	je     800068 <sleep+0x35>
  800051:	83 f8 f1             	cmp    $0xfffffff1,%eax
  800054:	7c 12                	jl     800068 <sleep+0x35>
		panic("sys_time_msec: %e", (int)now);
  800056:	50                   	push   %eax
  800057:	68 20 23 80 00       	push   $0x802320
  80005c:	6a 0b                	push   $0xb
  80005e:	68 32 23 80 00       	push   $0x802332
  800063:	e8 f1 00 00 00       	call   800159 <_panic>
	if (end < now)
  800068:	39 d8                	cmp    %ebx,%eax
  80006a:	76 19                	jbe    800085 <sleep+0x52>
		panic("sleep: wrap");
  80006c:	83 ec 04             	sub    $0x4,%esp
  80006f:	68 42 23 80 00       	push   $0x802342
  800074:	6a 0d                	push   $0xd
  800076:	68 32 23 80 00       	push   $0x802332
  80007b:	e8 d9 00 00 00       	call   800159 <_panic>

	while (sys_time_msec() < end)
		sys_yield();
  800080:	e8 16 0b 00 00       	call   800b9b <sys_yield>
	if ((int)now < 0 && (int)now > -MAXERROR)
		panic("sys_time_msec: %e", (int)now);
	if (end < now)
		panic("sleep: wrap");

	while (sys_time_msec() < end)
  800085:	e8 21 0d 00 00       	call   800dab <sys_time_msec>
  80008a:	39 c3                	cmp    %eax,%ebx
  80008c:	77 f2                	ja     800080 <sleep+0x4d>
		sys_yield();
}
  80008e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800091:	c9                   	leave  
  800092:	c3                   	ret    

00800093 <umain>:

void
umain(int argc, char **argv)
{
  800093:	55                   	push   %ebp
  800094:	89 e5                	mov    %esp,%ebp
  800096:	53                   	push   %ebx
  800097:	83 ec 04             	sub    $0x4,%esp
  80009a:	bb 32 00 00 00       	mov    $0x32,%ebx
	int i;

	// Wait for the console to calm down
	for (i = 0; i < 50; i++)
		sys_yield();
  80009f:	e8 f7 0a 00 00       	call   800b9b <sys_yield>
umain(int argc, char **argv)
{
	int i;

	// Wait for the console to calm down
	for (i = 0; i < 50; i++)
  8000a4:	83 eb 01             	sub    $0x1,%ebx
  8000a7:	75 f6                	jne    80009f <umain+0xc>
		sys_yield();

	cprintf("starting count down: ");
  8000a9:	83 ec 0c             	sub    $0xc,%esp
  8000ac:	68 4e 23 80 00       	push   $0x80234e
  8000b1:	e8 7c 01 00 00       	call   800232 <cprintf>
  8000b6:	83 c4 10             	add    $0x10,%esp
	for (i = 5; i >= 0; i--) {
  8000b9:	bb 05 00 00 00       	mov    $0x5,%ebx
		cprintf("%d ", i);
  8000be:	83 ec 08             	sub    $0x8,%esp
  8000c1:	53                   	push   %ebx
  8000c2:	68 64 23 80 00       	push   $0x802364
  8000c7:	e8 66 01 00 00       	call   800232 <cprintf>
		sleep(1);
  8000cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000d3:	e8 5b ff ff ff       	call   800033 <sleep>
	// Wait for the console to calm down
	for (i = 0; i < 50; i++)
		sys_yield();

	cprintf("starting count down: ");
	for (i = 5; i >= 0; i--) {
  8000d8:	83 eb 01             	sub    $0x1,%ebx
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	83 fb ff             	cmp    $0xffffffff,%ebx
  8000e1:	75 db                	jne    8000be <umain+0x2b>
		cprintf("%d ", i);
		sleep(1);
	}
	cprintf("\n");
  8000e3:	83 ec 0c             	sub    $0xc,%esp
  8000e6:	68 e4 27 80 00       	push   $0x8027e4
  8000eb:	e8 42 01 00 00       	call   800232 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8000f0:	cc                   	int3   
	breakpoint();
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f7:	c9                   	leave  
  8000f8:	c3                   	ret    

008000f9 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	56                   	push   %esi
  8000fd:	53                   	push   %ebx
  8000fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800101:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800104:	e8 73 0a 00 00       	call   800b7c <sys_getenvid>
  800109:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800111:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800116:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011b:	85 db                	test   %ebx,%ebx
  80011d:	7e 07                	jle    800126 <libmain+0x2d>
		binaryname = argv[0];
  80011f:	8b 06                	mov    (%esi),%eax
  800121:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800126:	83 ec 08             	sub    $0x8,%esp
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
  80012b:	e8 63 ff ff ff       	call   800093 <umain>

	// exit gracefully
	exit();
  800130:	e8 0a 00 00 00       	call   80013f <exit>
}
  800135:	83 c4 10             	add    $0x10,%esp
  800138:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013b:	5b                   	pop    %ebx
  80013c:	5e                   	pop    %esi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800145:	e8 8d 0e 00 00       	call   800fd7 <close_all>
	sys_env_destroy(0);
  80014a:	83 ec 0c             	sub    $0xc,%esp
  80014d:	6a 00                	push   $0x0
  80014f:	e8 e7 09 00 00       	call   800b3b <sys_env_destroy>
}
  800154:	83 c4 10             	add    $0x10,%esp
  800157:	c9                   	leave  
  800158:	c3                   	ret    

00800159 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	56                   	push   %esi
  80015d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800161:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800167:	e8 10 0a 00 00       	call   800b7c <sys_getenvid>
  80016c:	83 ec 0c             	sub    $0xc,%esp
  80016f:	ff 75 0c             	pushl  0xc(%ebp)
  800172:	ff 75 08             	pushl  0x8(%ebp)
  800175:	56                   	push   %esi
  800176:	50                   	push   %eax
  800177:	68 74 23 80 00       	push   $0x802374
  80017c:	e8 b1 00 00 00       	call   800232 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800181:	83 c4 18             	add    $0x18,%esp
  800184:	53                   	push   %ebx
  800185:	ff 75 10             	pushl  0x10(%ebp)
  800188:	e8 54 00 00 00       	call   8001e1 <vcprintf>
	cprintf("\n");
  80018d:	c7 04 24 e4 27 80 00 	movl   $0x8027e4,(%esp)
  800194:	e8 99 00 00 00       	call   800232 <cprintf>
  800199:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019c:	cc                   	int3   
  80019d:	eb fd                	jmp    80019c <_panic+0x43>

0080019f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 04             	sub    $0x4,%esp
  8001a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a9:	8b 13                	mov    (%ebx),%edx
  8001ab:	8d 42 01             	lea    0x1(%edx),%eax
  8001ae:	89 03                	mov    %eax,(%ebx)
  8001b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bc:	75 1a                	jne    8001d8 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001be:	83 ec 08             	sub    $0x8,%esp
  8001c1:	68 ff 00 00 00       	push   $0xff
  8001c6:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c9:	50                   	push   %eax
  8001ca:	e8 2f 09 00 00       	call   800afe <sys_cputs>
		b->idx = 0;
  8001cf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d5:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001d8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001df:	c9                   	leave  
  8001e0:	c3                   	ret    

008001e1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e1:	55                   	push   %ebp
  8001e2:	89 e5                	mov    %esp,%ebp
  8001e4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ea:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f1:	00 00 00 
	b.cnt = 0;
  8001f4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fe:	ff 75 0c             	pushl  0xc(%ebp)
  800201:	ff 75 08             	pushl  0x8(%ebp)
  800204:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020a:	50                   	push   %eax
  80020b:	68 9f 01 80 00       	push   $0x80019f
  800210:	e8 54 01 00 00       	call   800369 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800215:	83 c4 08             	add    $0x8,%esp
  800218:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800224:	50                   	push   %eax
  800225:	e8 d4 08 00 00       	call   800afe <sys_cputs>

	return b.cnt;
}
  80022a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800230:	c9                   	leave  
  800231:	c3                   	ret    

00800232 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800238:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023b:	50                   	push   %eax
  80023c:	ff 75 08             	pushl  0x8(%ebp)
  80023f:	e8 9d ff ff ff       	call   8001e1 <vcprintf>
	va_end(ap);

	return cnt;
}
  800244:	c9                   	leave  
  800245:	c3                   	ret    

00800246 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
  800249:	57                   	push   %edi
  80024a:	56                   	push   %esi
  80024b:	53                   	push   %ebx
  80024c:	83 ec 1c             	sub    $0x1c,%esp
  80024f:	89 c7                	mov    %eax,%edi
  800251:	89 d6                	mov    %edx,%esi
  800253:	8b 45 08             	mov    0x8(%ebp),%eax
  800256:	8b 55 0c             	mov    0xc(%ebp),%edx
  800259:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800262:	bb 00 00 00 00       	mov    $0x0,%ebx
  800267:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80026a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80026d:	39 d3                	cmp    %edx,%ebx
  80026f:	72 05                	jb     800276 <printnum+0x30>
  800271:	39 45 10             	cmp    %eax,0x10(%ebp)
  800274:	77 45                	ja     8002bb <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800276:	83 ec 0c             	sub    $0xc,%esp
  800279:	ff 75 18             	pushl  0x18(%ebp)
  80027c:	8b 45 14             	mov    0x14(%ebp),%eax
  80027f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800282:	53                   	push   %ebx
  800283:	ff 75 10             	pushl  0x10(%ebp)
  800286:	83 ec 08             	sub    $0x8,%esp
  800289:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028c:	ff 75 e0             	pushl  -0x20(%ebp)
  80028f:	ff 75 dc             	pushl  -0x24(%ebp)
  800292:	ff 75 d8             	pushl  -0x28(%ebp)
  800295:	e8 e6 1d 00 00       	call   802080 <__udivdi3>
  80029a:	83 c4 18             	add    $0x18,%esp
  80029d:	52                   	push   %edx
  80029e:	50                   	push   %eax
  80029f:	89 f2                	mov    %esi,%edx
  8002a1:	89 f8                	mov    %edi,%eax
  8002a3:	e8 9e ff ff ff       	call   800246 <printnum>
  8002a8:	83 c4 20             	add    $0x20,%esp
  8002ab:	eb 18                	jmp    8002c5 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ad:	83 ec 08             	sub    $0x8,%esp
  8002b0:	56                   	push   %esi
  8002b1:	ff 75 18             	pushl  0x18(%ebp)
  8002b4:	ff d7                	call   *%edi
  8002b6:	83 c4 10             	add    $0x10,%esp
  8002b9:	eb 03                	jmp    8002be <printnum+0x78>
  8002bb:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002be:	83 eb 01             	sub    $0x1,%ebx
  8002c1:	85 db                	test   %ebx,%ebx
  8002c3:	7f e8                	jg     8002ad <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c5:	83 ec 08             	sub    $0x8,%esp
  8002c8:	56                   	push   %esi
  8002c9:	83 ec 04             	sub    $0x4,%esp
  8002cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d8:	e8 d3 1e 00 00       	call   8021b0 <__umoddi3>
  8002dd:	83 c4 14             	add    $0x14,%esp
  8002e0:	0f be 80 97 23 80 00 	movsbl 0x802397(%eax),%eax
  8002e7:	50                   	push   %eax
  8002e8:	ff d7                	call   *%edi
}
  8002ea:	83 c4 10             	add    $0x10,%esp
  8002ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f0:	5b                   	pop    %ebx
  8002f1:	5e                   	pop    %esi
  8002f2:	5f                   	pop    %edi
  8002f3:	5d                   	pop    %ebp
  8002f4:	c3                   	ret    

008002f5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f8:	83 fa 01             	cmp    $0x1,%edx
  8002fb:	7e 0e                	jle    80030b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002fd:	8b 10                	mov    (%eax),%edx
  8002ff:	8d 4a 08             	lea    0x8(%edx),%ecx
  800302:	89 08                	mov    %ecx,(%eax)
  800304:	8b 02                	mov    (%edx),%eax
  800306:	8b 52 04             	mov    0x4(%edx),%edx
  800309:	eb 22                	jmp    80032d <getuint+0x38>
	else if (lflag)
  80030b:	85 d2                	test   %edx,%edx
  80030d:	74 10                	je     80031f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80030f:	8b 10                	mov    (%eax),%edx
  800311:	8d 4a 04             	lea    0x4(%edx),%ecx
  800314:	89 08                	mov    %ecx,(%eax)
  800316:	8b 02                	mov    (%edx),%eax
  800318:	ba 00 00 00 00       	mov    $0x0,%edx
  80031d:	eb 0e                	jmp    80032d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80031f:	8b 10                	mov    (%eax),%edx
  800321:	8d 4a 04             	lea    0x4(%edx),%ecx
  800324:	89 08                	mov    %ecx,(%eax)
  800326:	8b 02                	mov    (%edx),%eax
  800328:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800335:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800339:	8b 10                	mov    (%eax),%edx
  80033b:	3b 50 04             	cmp    0x4(%eax),%edx
  80033e:	73 0a                	jae    80034a <sprintputch+0x1b>
		*b->buf++ = ch;
  800340:	8d 4a 01             	lea    0x1(%edx),%ecx
  800343:	89 08                	mov    %ecx,(%eax)
  800345:	8b 45 08             	mov    0x8(%ebp),%eax
  800348:	88 02                	mov    %al,(%edx)
}
  80034a:	5d                   	pop    %ebp
  80034b:	c3                   	ret    

0080034c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800352:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800355:	50                   	push   %eax
  800356:	ff 75 10             	pushl  0x10(%ebp)
  800359:	ff 75 0c             	pushl  0xc(%ebp)
  80035c:	ff 75 08             	pushl  0x8(%ebp)
  80035f:	e8 05 00 00 00       	call   800369 <vprintfmt>
	va_end(ap);
}
  800364:	83 c4 10             	add    $0x10,%esp
  800367:	c9                   	leave  
  800368:	c3                   	ret    

00800369 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800369:	55                   	push   %ebp
  80036a:	89 e5                	mov    %esp,%ebp
  80036c:	57                   	push   %edi
  80036d:	56                   	push   %esi
  80036e:	53                   	push   %ebx
  80036f:	83 ec 2c             	sub    $0x2c,%esp
  800372:	8b 75 08             	mov    0x8(%ebp),%esi
  800375:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800378:	8b 7d 10             	mov    0x10(%ebp),%edi
  80037b:	eb 12                	jmp    80038f <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037d:	85 c0                	test   %eax,%eax
  80037f:	0f 84 89 03 00 00    	je     80070e <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800385:	83 ec 08             	sub    $0x8,%esp
  800388:	53                   	push   %ebx
  800389:	50                   	push   %eax
  80038a:	ff d6                	call   *%esi
  80038c:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038f:	83 c7 01             	add    $0x1,%edi
  800392:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800396:	83 f8 25             	cmp    $0x25,%eax
  800399:	75 e2                	jne    80037d <vprintfmt+0x14>
  80039b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80039f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003a6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ad:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b9:	eb 07                	jmp    8003c2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003be:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8d 47 01             	lea    0x1(%edi),%eax
  8003c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c8:	0f b6 07             	movzbl (%edi),%eax
  8003cb:	0f b6 c8             	movzbl %al,%ecx
  8003ce:	83 e8 23             	sub    $0x23,%eax
  8003d1:	3c 55                	cmp    $0x55,%al
  8003d3:	0f 87 1a 03 00 00    	ja     8006f3 <vprintfmt+0x38a>
  8003d9:	0f b6 c0             	movzbl %al,%eax
  8003dc:	ff 24 85 e0 24 80 00 	jmp    *0x8024e0(,%eax,4)
  8003e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e6:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003ea:	eb d6                	jmp    8003c2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003fa:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003fe:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800401:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800404:	83 fa 09             	cmp    $0x9,%edx
  800407:	77 39                	ja     800442 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800409:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80040c:	eb e9                	jmp    8003f7 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80040e:	8b 45 14             	mov    0x14(%ebp),%eax
  800411:	8d 48 04             	lea    0x4(%eax),%ecx
  800414:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800417:	8b 00                	mov    (%eax),%eax
  800419:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80041f:	eb 27                	jmp    800448 <vprintfmt+0xdf>
  800421:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800424:	85 c0                	test   %eax,%eax
  800426:	b9 00 00 00 00       	mov    $0x0,%ecx
  80042b:	0f 49 c8             	cmovns %eax,%ecx
  80042e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800431:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800434:	eb 8c                	jmp    8003c2 <vprintfmt+0x59>
  800436:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800439:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800440:	eb 80                	jmp    8003c2 <vprintfmt+0x59>
  800442:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800445:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800448:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044c:	0f 89 70 ff ff ff    	jns    8003c2 <vprintfmt+0x59>
				width = precision, precision = -1;
  800452:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800455:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800458:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80045f:	e9 5e ff ff ff       	jmp    8003c2 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800464:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800467:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80046a:	e9 53 ff ff ff       	jmp    8003c2 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80046f:	8b 45 14             	mov    0x14(%ebp),%eax
  800472:	8d 50 04             	lea    0x4(%eax),%edx
  800475:	89 55 14             	mov    %edx,0x14(%ebp)
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	53                   	push   %ebx
  80047c:	ff 30                	pushl  (%eax)
  80047e:	ff d6                	call   *%esi
			break;
  800480:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800483:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800486:	e9 04 ff ff ff       	jmp    80038f <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80048b:	8b 45 14             	mov    0x14(%ebp),%eax
  80048e:	8d 50 04             	lea    0x4(%eax),%edx
  800491:	89 55 14             	mov    %edx,0x14(%ebp)
  800494:	8b 00                	mov    (%eax),%eax
  800496:	99                   	cltd   
  800497:	31 d0                	xor    %edx,%eax
  800499:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049b:	83 f8 0f             	cmp    $0xf,%eax
  80049e:	7f 0b                	jg     8004ab <vprintfmt+0x142>
  8004a0:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  8004a7:	85 d2                	test   %edx,%edx
  8004a9:	75 18                	jne    8004c3 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004ab:	50                   	push   %eax
  8004ac:	68 af 23 80 00       	push   $0x8023af
  8004b1:	53                   	push   %ebx
  8004b2:	56                   	push   %esi
  8004b3:	e8 94 fe ff ff       	call   80034c <printfmt>
  8004b8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004be:	e9 cc fe ff ff       	jmp    80038f <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004c3:	52                   	push   %edx
  8004c4:	68 79 27 80 00       	push   $0x802779
  8004c9:	53                   	push   %ebx
  8004ca:	56                   	push   %esi
  8004cb:	e8 7c fe ff ff       	call   80034c <printfmt>
  8004d0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d6:	e9 b4 fe ff ff       	jmp    80038f <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004db:	8b 45 14             	mov    0x14(%ebp),%eax
  8004de:	8d 50 04             	lea    0x4(%eax),%edx
  8004e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e4:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004e6:	85 ff                	test   %edi,%edi
  8004e8:	b8 a8 23 80 00       	mov    $0x8023a8,%eax
  8004ed:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004f0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f4:	0f 8e 94 00 00 00    	jle    80058e <vprintfmt+0x225>
  8004fa:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004fe:	0f 84 98 00 00 00    	je     80059c <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	ff 75 d0             	pushl  -0x30(%ebp)
  80050a:	57                   	push   %edi
  80050b:	e8 86 02 00 00       	call   800796 <strnlen>
  800510:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800513:	29 c1                	sub    %eax,%ecx
  800515:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800518:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80051b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80051f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800522:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800525:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800527:	eb 0f                	jmp    800538 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800529:	83 ec 08             	sub    $0x8,%esp
  80052c:	53                   	push   %ebx
  80052d:	ff 75 e0             	pushl  -0x20(%ebp)
  800530:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800532:	83 ef 01             	sub    $0x1,%edi
  800535:	83 c4 10             	add    $0x10,%esp
  800538:	85 ff                	test   %edi,%edi
  80053a:	7f ed                	jg     800529 <vprintfmt+0x1c0>
  80053c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80053f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800542:	85 c9                	test   %ecx,%ecx
  800544:	b8 00 00 00 00       	mov    $0x0,%eax
  800549:	0f 49 c1             	cmovns %ecx,%eax
  80054c:	29 c1                	sub    %eax,%ecx
  80054e:	89 75 08             	mov    %esi,0x8(%ebp)
  800551:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800554:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800557:	89 cb                	mov    %ecx,%ebx
  800559:	eb 4d                	jmp    8005a8 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80055b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80055f:	74 1b                	je     80057c <vprintfmt+0x213>
  800561:	0f be c0             	movsbl %al,%eax
  800564:	83 e8 20             	sub    $0x20,%eax
  800567:	83 f8 5e             	cmp    $0x5e,%eax
  80056a:	76 10                	jbe    80057c <vprintfmt+0x213>
					putch('?', putdat);
  80056c:	83 ec 08             	sub    $0x8,%esp
  80056f:	ff 75 0c             	pushl  0xc(%ebp)
  800572:	6a 3f                	push   $0x3f
  800574:	ff 55 08             	call   *0x8(%ebp)
  800577:	83 c4 10             	add    $0x10,%esp
  80057a:	eb 0d                	jmp    800589 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80057c:	83 ec 08             	sub    $0x8,%esp
  80057f:	ff 75 0c             	pushl  0xc(%ebp)
  800582:	52                   	push   %edx
  800583:	ff 55 08             	call   *0x8(%ebp)
  800586:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800589:	83 eb 01             	sub    $0x1,%ebx
  80058c:	eb 1a                	jmp    8005a8 <vprintfmt+0x23f>
  80058e:	89 75 08             	mov    %esi,0x8(%ebp)
  800591:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800594:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800597:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059a:	eb 0c                	jmp    8005a8 <vprintfmt+0x23f>
  80059c:	89 75 08             	mov    %esi,0x8(%ebp)
  80059f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a8:	83 c7 01             	add    $0x1,%edi
  8005ab:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005af:	0f be d0             	movsbl %al,%edx
  8005b2:	85 d2                	test   %edx,%edx
  8005b4:	74 23                	je     8005d9 <vprintfmt+0x270>
  8005b6:	85 f6                	test   %esi,%esi
  8005b8:	78 a1                	js     80055b <vprintfmt+0x1f2>
  8005ba:	83 ee 01             	sub    $0x1,%esi
  8005bd:	79 9c                	jns    80055b <vprintfmt+0x1f2>
  8005bf:	89 df                	mov    %ebx,%edi
  8005c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c7:	eb 18                	jmp    8005e1 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005c9:	83 ec 08             	sub    $0x8,%esp
  8005cc:	53                   	push   %ebx
  8005cd:	6a 20                	push   $0x20
  8005cf:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d1:	83 ef 01             	sub    $0x1,%edi
  8005d4:	83 c4 10             	add    $0x10,%esp
  8005d7:	eb 08                	jmp    8005e1 <vprintfmt+0x278>
  8005d9:	89 df                	mov    %ebx,%edi
  8005db:	8b 75 08             	mov    0x8(%ebp),%esi
  8005de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e1:	85 ff                	test   %edi,%edi
  8005e3:	7f e4                	jg     8005c9 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e8:	e9 a2 fd ff ff       	jmp    80038f <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ed:	83 fa 01             	cmp    $0x1,%edx
  8005f0:	7e 16                	jle    800608 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8d 50 08             	lea    0x8(%eax),%edx
  8005f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fb:	8b 50 04             	mov    0x4(%eax),%edx
  8005fe:	8b 00                	mov    (%eax),%eax
  800600:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800603:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800606:	eb 32                	jmp    80063a <vprintfmt+0x2d1>
	else if (lflag)
  800608:	85 d2                	test   %edx,%edx
  80060a:	74 18                	je     800624 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8d 50 04             	lea    0x4(%eax),%edx
  800612:	89 55 14             	mov    %edx,0x14(%ebp)
  800615:	8b 00                	mov    (%eax),%eax
  800617:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061a:	89 c1                	mov    %eax,%ecx
  80061c:	c1 f9 1f             	sar    $0x1f,%ecx
  80061f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800622:	eb 16                	jmp    80063a <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8d 50 04             	lea    0x4(%eax),%edx
  80062a:	89 55 14             	mov    %edx,0x14(%ebp)
  80062d:	8b 00                	mov    (%eax),%eax
  80062f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800632:	89 c1                	mov    %eax,%ecx
  800634:	c1 f9 1f             	sar    $0x1f,%ecx
  800637:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80063a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80063d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800640:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800645:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800649:	79 74                	jns    8006bf <vprintfmt+0x356>
				putch('-', putdat);
  80064b:	83 ec 08             	sub    $0x8,%esp
  80064e:	53                   	push   %ebx
  80064f:	6a 2d                	push   $0x2d
  800651:	ff d6                	call   *%esi
				num = -(long long) num;
  800653:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800656:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800659:	f7 d8                	neg    %eax
  80065b:	83 d2 00             	adc    $0x0,%edx
  80065e:	f7 da                	neg    %edx
  800660:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800663:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800668:	eb 55                	jmp    8006bf <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80066a:	8d 45 14             	lea    0x14(%ebp),%eax
  80066d:	e8 83 fc ff ff       	call   8002f5 <getuint>
			base = 10;
  800672:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800677:	eb 46                	jmp    8006bf <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800679:	8d 45 14             	lea    0x14(%ebp),%eax
  80067c:	e8 74 fc ff ff       	call   8002f5 <getuint>
			base = 8;
  800681:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800686:	eb 37                	jmp    8006bf <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800688:	83 ec 08             	sub    $0x8,%esp
  80068b:	53                   	push   %ebx
  80068c:	6a 30                	push   $0x30
  80068e:	ff d6                	call   *%esi
			putch('x', putdat);
  800690:	83 c4 08             	add    $0x8,%esp
  800693:	53                   	push   %ebx
  800694:	6a 78                	push   $0x78
  800696:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8d 50 04             	lea    0x4(%eax),%edx
  80069e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a1:	8b 00                	mov    (%eax),%eax
  8006a3:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ab:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006b0:	eb 0d                	jmp    8006bf <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b5:	e8 3b fc ff ff       	call   8002f5 <getuint>
			base = 16;
  8006ba:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006bf:	83 ec 0c             	sub    $0xc,%esp
  8006c2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006c6:	57                   	push   %edi
  8006c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ca:	51                   	push   %ecx
  8006cb:	52                   	push   %edx
  8006cc:	50                   	push   %eax
  8006cd:	89 da                	mov    %ebx,%edx
  8006cf:	89 f0                	mov    %esi,%eax
  8006d1:	e8 70 fb ff ff       	call   800246 <printnum>
			break;
  8006d6:	83 c4 20             	add    $0x20,%esp
  8006d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006dc:	e9 ae fc ff ff       	jmp    80038f <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e1:	83 ec 08             	sub    $0x8,%esp
  8006e4:	53                   	push   %ebx
  8006e5:	51                   	push   %ecx
  8006e6:	ff d6                	call   *%esi
			break;
  8006e8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ee:	e9 9c fc ff ff       	jmp    80038f <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f3:	83 ec 08             	sub    $0x8,%esp
  8006f6:	53                   	push   %ebx
  8006f7:	6a 25                	push   $0x25
  8006f9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fb:	83 c4 10             	add    $0x10,%esp
  8006fe:	eb 03                	jmp    800703 <vprintfmt+0x39a>
  800700:	83 ef 01             	sub    $0x1,%edi
  800703:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800707:	75 f7                	jne    800700 <vprintfmt+0x397>
  800709:	e9 81 fc ff ff       	jmp    80038f <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80070e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800711:	5b                   	pop    %ebx
  800712:	5e                   	pop    %esi
  800713:	5f                   	pop    %edi
  800714:	5d                   	pop    %ebp
  800715:	c3                   	ret    

00800716 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
  800719:	83 ec 18             	sub    $0x18,%esp
  80071c:	8b 45 08             	mov    0x8(%ebp),%eax
  80071f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800722:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800725:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800729:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800733:	85 c0                	test   %eax,%eax
  800735:	74 26                	je     80075d <vsnprintf+0x47>
  800737:	85 d2                	test   %edx,%edx
  800739:	7e 22                	jle    80075d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073b:	ff 75 14             	pushl  0x14(%ebp)
  80073e:	ff 75 10             	pushl  0x10(%ebp)
  800741:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800744:	50                   	push   %eax
  800745:	68 2f 03 80 00       	push   $0x80032f
  80074a:	e8 1a fc ff ff       	call   800369 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800752:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800755:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800758:	83 c4 10             	add    $0x10,%esp
  80075b:	eb 05                	jmp    800762 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800762:	c9                   	leave  
  800763:	c3                   	ret    

00800764 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076d:	50                   	push   %eax
  80076e:	ff 75 10             	pushl  0x10(%ebp)
  800771:	ff 75 0c             	pushl  0xc(%ebp)
  800774:	ff 75 08             	pushl  0x8(%ebp)
  800777:	e8 9a ff ff ff       	call   800716 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077c:	c9                   	leave  
  80077d:	c3                   	ret    

0080077e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800784:	b8 00 00 00 00       	mov    $0x0,%eax
  800789:	eb 03                	jmp    80078e <strlen+0x10>
		n++;
  80078b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80078e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800792:	75 f7                	jne    80078b <strlen+0xd>
		n++;
	return n;
}
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079f:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a4:	eb 03                	jmp    8007a9 <strnlen+0x13>
		n++;
  8007a6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a9:	39 c2                	cmp    %eax,%edx
  8007ab:	74 08                	je     8007b5 <strnlen+0x1f>
  8007ad:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007b1:	75 f3                	jne    8007a6 <strnlen+0x10>
  8007b3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	53                   	push   %ebx
  8007bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c1:	89 c2                	mov    %eax,%edx
  8007c3:	83 c2 01             	add    $0x1,%edx
  8007c6:	83 c1 01             	add    $0x1,%ecx
  8007c9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007cd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d0:	84 db                	test   %bl,%bl
  8007d2:	75 ef                	jne    8007c3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d4:	5b                   	pop    %ebx
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	53                   	push   %ebx
  8007db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007de:	53                   	push   %ebx
  8007df:	e8 9a ff ff ff       	call   80077e <strlen>
  8007e4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ea:	01 d8                	add    %ebx,%eax
  8007ec:	50                   	push   %eax
  8007ed:	e8 c5 ff ff ff       	call   8007b7 <strcpy>
	return dst;
}
  8007f2:	89 d8                	mov    %ebx,%eax
  8007f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f7:	c9                   	leave  
  8007f8:	c3                   	ret    

008007f9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	56                   	push   %esi
  8007fd:	53                   	push   %ebx
  8007fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800801:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800804:	89 f3                	mov    %esi,%ebx
  800806:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800809:	89 f2                	mov    %esi,%edx
  80080b:	eb 0f                	jmp    80081c <strncpy+0x23>
		*dst++ = *src;
  80080d:	83 c2 01             	add    $0x1,%edx
  800810:	0f b6 01             	movzbl (%ecx),%eax
  800813:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800816:	80 39 01             	cmpb   $0x1,(%ecx)
  800819:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081c:	39 da                	cmp    %ebx,%edx
  80081e:	75 ed                	jne    80080d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800820:	89 f0                	mov    %esi,%eax
  800822:	5b                   	pop    %ebx
  800823:	5e                   	pop    %esi
  800824:	5d                   	pop    %ebp
  800825:	c3                   	ret    

00800826 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	56                   	push   %esi
  80082a:	53                   	push   %ebx
  80082b:	8b 75 08             	mov    0x8(%ebp),%esi
  80082e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800831:	8b 55 10             	mov    0x10(%ebp),%edx
  800834:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800836:	85 d2                	test   %edx,%edx
  800838:	74 21                	je     80085b <strlcpy+0x35>
  80083a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80083e:	89 f2                	mov    %esi,%edx
  800840:	eb 09                	jmp    80084b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800842:	83 c2 01             	add    $0x1,%edx
  800845:	83 c1 01             	add    $0x1,%ecx
  800848:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80084b:	39 c2                	cmp    %eax,%edx
  80084d:	74 09                	je     800858 <strlcpy+0x32>
  80084f:	0f b6 19             	movzbl (%ecx),%ebx
  800852:	84 db                	test   %bl,%bl
  800854:	75 ec                	jne    800842 <strlcpy+0x1c>
  800856:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800858:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80085b:	29 f0                	sub    %esi,%eax
}
  80085d:	5b                   	pop    %ebx
  80085e:	5e                   	pop    %esi
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800867:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80086a:	eb 06                	jmp    800872 <strcmp+0x11>
		p++, q++;
  80086c:	83 c1 01             	add    $0x1,%ecx
  80086f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800872:	0f b6 01             	movzbl (%ecx),%eax
  800875:	84 c0                	test   %al,%al
  800877:	74 04                	je     80087d <strcmp+0x1c>
  800879:	3a 02                	cmp    (%edx),%al
  80087b:	74 ef                	je     80086c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087d:	0f b6 c0             	movzbl %al,%eax
  800880:	0f b6 12             	movzbl (%edx),%edx
  800883:	29 d0                	sub    %edx,%eax
}
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	53                   	push   %ebx
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800891:	89 c3                	mov    %eax,%ebx
  800893:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800896:	eb 06                	jmp    80089e <strncmp+0x17>
		n--, p++, q++;
  800898:	83 c0 01             	add    $0x1,%eax
  80089b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80089e:	39 d8                	cmp    %ebx,%eax
  8008a0:	74 15                	je     8008b7 <strncmp+0x30>
  8008a2:	0f b6 08             	movzbl (%eax),%ecx
  8008a5:	84 c9                	test   %cl,%cl
  8008a7:	74 04                	je     8008ad <strncmp+0x26>
  8008a9:	3a 0a                	cmp    (%edx),%cl
  8008ab:	74 eb                	je     800898 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ad:	0f b6 00             	movzbl (%eax),%eax
  8008b0:	0f b6 12             	movzbl (%edx),%edx
  8008b3:	29 d0                	sub    %edx,%eax
  8008b5:	eb 05                	jmp    8008bc <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008bc:	5b                   	pop    %ebx
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c9:	eb 07                	jmp    8008d2 <strchr+0x13>
		if (*s == c)
  8008cb:	38 ca                	cmp    %cl,%dl
  8008cd:	74 0f                	je     8008de <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008cf:	83 c0 01             	add    $0x1,%eax
  8008d2:	0f b6 10             	movzbl (%eax),%edx
  8008d5:	84 d2                	test   %dl,%dl
  8008d7:	75 f2                	jne    8008cb <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ea:	eb 03                	jmp    8008ef <strfind+0xf>
  8008ec:	83 c0 01             	add    $0x1,%eax
  8008ef:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f2:	38 ca                	cmp    %cl,%dl
  8008f4:	74 04                	je     8008fa <strfind+0x1a>
  8008f6:	84 d2                	test   %dl,%dl
  8008f8:	75 f2                	jne    8008ec <strfind+0xc>
			break;
	return (char *) s;
}
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    

008008fc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	57                   	push   %edi
  800900:	56                   	push   %esi
  800901:	53                   	push   %ebx
  800902:	8b 7d 08             	mov    0x8(%ebp),%edi
  800905:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800908:	85 c9                	test   %ecx,%ecx
  80090a:	74 36                	je     800942 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800912:	75 28                	jne    80093c <memset+0x40>
  800914:	f6 c1 03             	test   $0x3,%cl
  800917:	75 23                	jne    80093c <memset+0x40>
		c &= 0xFF;
  800919:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091d:	89 d3                	mov    %edx,%ebx
  80091f:	c1 e3 08             	shl    $0x8,%ebx
  800922:	89 d6                	mov    %edx,%esi
  800924:	c1 e6 18             	shl    $0x18,%esi
  800927:	89 d0                	mov    %edx,%eax
  800929:	c1 e0 10             	shl    $0x10,%eax
  80092c:	09 f0                	or     %esi,%eax
  80092e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800930:	89 d8                	mov    %ebx,%eax
  800932:	09 d0                	or     %edx,%eax
  800934:	c1 e9 02             	shr    $0x2,%ecx
  800937:	fc                   	cld    
  800938:	f3 ab                	rep stos %eax,%es:(%edi)
  80093a:	eb 06                	jmp    800942 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093f:	fc                   	cld    
  800940:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800942:	89 f8                	mov    %edi,%eax
  800944:	5b                   	pop    %ebx
  800945:	5e                   	pop    %esi
  800946:	5f                   	pop    %edi
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	57                   	push   %edi
  80094d:	56                   	push   %esi
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	8b 75 0c             	mov    0xc(%ebp),%esi
  800954:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800957:	39 c6                	cmp    %eax,%esi
  800959:	73 35                	jae    800990 <memmove+0x47>
  80095b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095e:	39 d0                	cmp    %edx,%eax
  800960:	73 2e                	jae    800990 <memmove+0x47>
		s += n;
		d += n;
  800962:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800965:	89 d6                	mov    %edx,%esi
  800967:	09 fe                	or     %edi,%esi
  800969:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096f:	75 13                	jne    800984 <memmove+0x3b>
  800971:	f6 c1 03             	test   $0x3,%cl
  800974:	75 0e                	jne    800984 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800976:	83 ef 04             	sub    $0x4,%edi
  800979:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097c:	c1 e9 02             	shr    $0x2,%ecx
  80097f:	fd                   	std    
  800980:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800982:	eb 09                	jmp    80098d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800984:	83 ef 01             	sub    $0x1,%edi
  800987:	8d 72 ff             	lea    -0x1(%edx),%esi
  80098a:	fd                   	std    
  80098b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098d:	fc                   	cld    
  80098e:	eb 1d                	jmp    8009ad <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800990:	89 f2                	mov    %esi,%edx
  800992:	09 c2                	or     %eax,%edx
  800994:	f6 c2 03             	test   $0x3,%dl
  800997:	75 0f                	jne    8009a8 <memmove+0x5f>
  800999:	f6 c1 03             	test   $0x3,%cl
  80099c:	75 0a                	jne    8009a8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80099e:	c1 e9 02             	shr    $0x2,%ecx
  8009a1:	89 c7                	mov    %eax,%edi
  8009a3:	fc                   	cld    
  8009a4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a6:	eb 05                	jmp    8009ad <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a8:	89 c7                	mov    %eax,%edi
  8009aa:	fc                   	cld    
  8009ab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ad:	5e                   	pop    %esi
  8009ae:	5f                   	pop    %edi
  8009af:	5d                   	pop    %ebp
  8009b0:	c3                   	ret    

008009b1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b4:	ff 75 10             	pushl  0x10(%ebp)
  8009b7:	ff 75 0c             	pushl  0xc(%ebp)
  8009ba:	ff 75 08             	pushl  0x8(%ebp)
  8009bd:	e8 87 ff ff ff       	call   800949 <memmove>
}
  8009c2:	c9                   	leave  
  8009c3:	c3                   	ret    

008009c4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	56                   	push   %esi
  8009c8:	53                   	push   %ebx
  8009c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cf:	89 c6                	mov    %eax,%esi
  8009d1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d4:	eb 1a                	jmp    8009f0 <memcmp+0x2c>
		if (*s1 != *s2)
  8009d6:	0f b6 08             	movzbl (%eax),%ecx
  8009d9:	0f b6 1a             	movzbl (%edx),%ebx
  8009dc:	38 d9                	cmp    %bl,%cl
  8009de:	74 0a                	je     8009ea <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009e0:	0f b6 c1             	movzbl %cl,%eax
  8009e3:	0f b6 db             	movzbl %bl,%ebx
  8009e6:	29 d8                	sub    %ebx,%eax
  8009e8:	eb 0f                	jmp    8009f9 <memcmp+0x35>
		s1++, s2++;
  8009ea:	83 c0 01             	add    $0x1,%eax
  8009ed:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f0:	39 f0                	cmp    %esi,%eax
  8009f2:	75 e2                	jne    8009d6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f9:	5b                   	pop    %ebx
  8009fa:	5e                   	pop    %esi
  8009fb:	5d                   	pop    %ebp
  8009fc:	c3                   	ret    

008009fd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	53                   	push   %ebx
  800a01:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a04:	89 c1                	mov    %eax,%ecx
  800a06:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a09:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0d:	eb 0a                	jmp    800a19 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0f:	0f b6 10             	movzbl (%eax),%edx
  800a12:	39 da                	cmp    %ebx,%edx
  800a14:	74 07                	je     800a1d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a16:	83 c0 01             	add    $0x1,%eax
  800a19:	39 c8                	cmp    %ecx,%eax
  800a1b:	72 f2                	jb     800a0f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a1d:	5b                   	pop    %ebx
  800a1e:	5d                   	pop    %ebp
  800a1f:	c3                   	ret    

00800a20 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	57                   	push   %edi
  800a24:	56                   	push   %esi
  800a25:	53                   	push   %ebx
  800a26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a29:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2c:	eb 03                	jmp    800a31 <strtol+0x11>
		s++;
  800a2e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a31:	0f b6 01             	movzbl (%ecx),%eax
  800a34:	3c 20                	cmp    $0x20,%al
  800a36:	74 f6                	je     800a2e <strtol+0xe>
  800a38:	3c 09                	cmp    $0x9,%al
  800a3a:	74 f2                	je     800a2e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a3c:	3c 2b                	cmp    $0x2b,%al
  800a3e:	75 0a                	jne    800a4a <strtol+0x2a>
		s++;
  800a40:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a43:	bf 00 00 00 00       	mov    $0x0,%edi
  800a48:	eb 11                	jmp    800a5b <strtol+0x3b>
  800a4a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a4f:	3c 2d                	cmp    $0x2d,%al
  800a51:	75 08                	jne    800a5b <strtol+0x3b>
		s++, neg = 1;
  800a53:	83 c1 01             	add    $0x1,%ecx
  800a56:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a61:	75 15                	jne    800a78 <strtol+0x58>
  800a63:	80 39 30             	cmpb   $0x30,(%ecx)
  800a66:	75 10                	jne    800a78 <strtol+0x58>
  800a68:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a6c:	75 7c                	jne    800aea <strtol+0xca>
		s += 2, base = 16;
  800a6e:	83 c1 02             	add    $0x2,%ecx
  800a71:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a76:	eb 16                	jmp    800a8e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a78:	85 db                	test   %ebx,%ebx
  800a7a:	75 12                	jne    800a8e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a81:	80 39 30             	cmpb   $0x30,(%ecx)
  800a84:	75 08                	jne    800a8e <strtol+0x6e>
		s++, base = 8;
  800a86:	83 c1 01             	add    $0x1,%ecx
  800a89:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a93:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a96:	0f b6 11             	movzbl (%ecx),%edx
  800a99:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a9c:	89 f3                	mov    %esi,%ebx
  800a9e:	80 fb 09             	cmp    $0x9,%bl
  800aa1:	77 08                	ja     800aab <strtol+0x8b>
			dig = *s - '0';
  800aa3:	0f be d2             	movsbl %dl,%edx
  800aa6:	83 ea 30             	sub    $0x30,%edx
  800aa9:	eb 22                	jmp    800acd <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aab:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aae:	89 f3                	mov    %esi,%ebx
  800ab0:	80 fb 19             	cmp    $0x19,%bl
  800ab3:	77 08                	ja     800abd <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ab5:	0f be d2             	movsbl %dl,%edx
  800ab8:	83 ea 57             	sub    $0x57,%edx
  800abb:	eb 10                	jmp    800acd <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800abd:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac0:	89 f3                	mov    %esi,%ebx
  800ac2:	80 fb 19             	cmp    $0x19,%bl
  800ac5:	77 16                	ja     800add <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ac7:	0f be d2             	movsbl %dl,%edx
  800aca:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800acd:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad0:	7d 0b                	jge    800add <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad2:	83 c1 01             	add    $0x1,%ecx
  800ad5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800adb:	eb b9                	jmp    800a96 <strtol+0x76>

	if (endptr)
  800add:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae1:	74 0d                	je     800af0 <strtol+0xd0>
		*endptr = (char *) s;
  800ae3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae6:	89 0e                	mov    %ecx,(%esi)
  800ae8:	eb 06                	jmp    800af0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aea:	85 db                	test   %ebx,%ebx
  800aec:	74 98                	je     800a86 <strtol+0x66>
  800aee:	eb 9e                	jmp    800a8e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800af0:	89 c2                	mov    %eax,%edx
  800af2:	f7 da                	neg    %edx
  800af4:	85 ff                	test   %edi,%edi
  800af6:	0f 45 c2             	cmovne %edx,%eax
}
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800b04:	b8 00 00 00 00       	mov    $0x0,%eax
  800b09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0f:	89 c3                	mov    %eax,%ebx
  800b11:	89 c7                	mov    %eax,%edi
  800b13:	89 c6                	mov    %eax,%esi
  800b15:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b17:	5b                   	pop    %ebx
  800b18:	5e                   	pop    %esi
  800b19:	5f                   	pop    %edi
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b22:	ba 00 00 00 00       	mov    $0x0,%edx
  800b27:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2c:	89 d1                	mov    %edx,%ecx
  800b2e:	89 d3                	mov    %edx,%ebx
  800b30:	89 d7                	mov    %edx,%edi
  800b32:	89 d6                	mov    %edx,%esi
  800b34:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	57                   	push   %edi
  800b3f:	56                   	push   %esi
  800b40:	53                   	push   %ebx
  800b41:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b44:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b49:	b8 03 00 00 00       	mov    $0x3,%eax
  800b4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b51:	89 cb                	mov    %ecx,%ebx
  800b53:	89 cf                	mov    %ecx,%edi
  800b55:	89 ce                	mov    %ecx,%esi
  800b57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b59:	85 c0                	test   %eax,%eax
  800b5b:	7e 17                	jle    800b74 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5d:	83 ec 0c             	sub    $0xc,%esp
  800b60:	50                   	push   %eax
  800b61:	6a 03                	push   $0x3
  800b63:	68 9f 26 80 00       	push   $0x80269f
  800b68:	6a 23                	push   $0x23
  800b6a:	68 bc 26 80 00       	push   $0x8026bc
  800b6f:	e8 e5 f5 ff ff       	call   800159 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b82:	ba 00 00 00 00       	mov    $0x0,%edx
  800b87:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8c:	89 d1                	mov    %edx,%ecx
  800b8e:	89 d3                	mov    %edx,%ebx
  800b90:	89 d7                	mov    %edx,%edi
  800b92:	89 d6                	mov    %edx,%esi
  800b94:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <sys_yield>:

void
sys_yield(void)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	57                   	push   %edi
  800b9f:	56                   	push   %esi
  800ba0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bab:	89 d1                	mov    %edx,%ecx
  800bad:	89 d3                	mov    %edx,%ebx
  800baf:	89 d7                	mov    %edx,%edi
  800bb1:	89 d6                	mov    %edx,%esi
  800bb3:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
  800bc0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc3:	be 00 00 00 00       	mov    $0x0,%esi
  800bc8:	b8 04 00 00 00       	mov    $0x4,%eax
  800bcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd6:	89 f7                	mov    %esi,%edi
  800bd8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bda:	85 c0                	test   %eax,%eax
  800bdc:	7e 17                	jle    800bf5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bde:	83 ec 0c             	sub    $0xc,%esp
  800be1:	50                   	push   %eax
  800be2:	6a 04                	push   $0x4
  800be4:	68 9f 26 80 00       	push   $0x80269f
  800be9:	6a 23                	push   $0x23
  800beb:	68 bc 26 80 00       	push   $0x8026bc
  800bf0:	e8 64 f5 ff ff       	call   800159 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5f                   	pop    %edi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    

00800bfd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	57                   	push   %edi
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
  800c03:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c06:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c11:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c14:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c17:	8b 75 18             	mov    0x18(%ebp),%esi
  800c1a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1c:	85 c0                	test   %eax,%eax
  800c1e:	7e 17                	jle    800c37 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c20:	83 ec 0c             	sub    $0xc,%esp
  800c23:	50                   	push   %eax
  800c24:	6a 05                	push   $0x5
  800c26:	68 9f 26 80 00       	push   $0x80269f
  800c2b:	6a 23                	push   $0x23
  800c2d:	68 bc 26 80 00       	push   $0x8026bc
  800c32:	e8 22 f5 ff ff       	call   800159 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3a:	5b                   	pop    %ebx
  800c3b:	5e                   	pop    %esi
  800c3c:	5f                   	pop    %edi
  800c3d:	5d                   	pop    %ebp
  800c3e:	c3                   	ret    

00800c3f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	57                   	push   %edi
  800c43:	56                   	push   %esi
  800c44:	53                   	push   %ebx
  800c45:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4d:	b8 06 00 00 00       	mov    $0x6,%eax
  800c52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c55:	8b 55 08             	mov    0x8(%ebp),%edx
  800c58:	89 df                	mov    %ebx,%edi
  800c5a:	89 de                	mov    %ebx,%esi
  800c5c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5e:	85 c0                	test   %eax,%eax
  800c60:	7e 17                	jle    800c79 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c62:	83 ec 0c             	sub    $0xc,%esp
  800c65:	50                   	push   %eax
  800c66:	6a 06                	push   $0x6
  800c68:	68 9f 26 80 00       	push   $0x80269f
  800c6d:	6a 23                	push   $0x23
  800c6f:	68 bc 26 80 00       	push   $0x8026bc
  800c74:	e8 e0 f4 ff ff       	call   800159 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7c:	5b                   	pop    %ebx
  800c7d:	5e                   	pop    %esi
  800c7e:	5f                   	pop    %edi
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    

00800c81 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	57                   	push   %edi
  800c85:	56                   	push   %esi
  800c86:	53                   	push   %ebx
  800c87:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8f:	b8 08 00 00 00       	mov    $0x8,%eax
  800c94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9a:	89 df                	mov    %ebx,%edi
  800c9c:	89 de                	mov    %ebx,%esi
  800c9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca0:	85 c0                	test   %eax,%eax
  800ca2:	7e 17                	jle    800cbb <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca4:	83 ec 0c             	sub    $0xc,%esp
  800ca7:	50                   	push   %eax
  800ca8:	6a 08                	push   $0x8
  800caa:	68 9f 26 80 00       	push   $0x80269f
  800caf:	6a 23                	push   $0x23
  800cb1:	68 bc 26 80 00       	push   $0x8026bc
  800cb6:	e8 9e f4 ff ff       	call   800159 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
  800cc9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd1:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	89 df                	mov    %ebx,%edi
  800cde:	89 de                	mov    %ebx,%esi
  800ce0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce2:	85 c0                	test   %eax,%eax
  800ce4:	7e 17                	jle    800cfd <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce6:	83 ec 0c             	sub    $0xc,%esp
  800ce9:	50                   	push   %eax
  800cea:	6a 09                	push   $0x9
  800cec:	68 9f 26 80 00       	push   $0x80269f
  800cf1:	6a 23                	push   $0x23
  800cf3:	68 bc 26 80 00       	push   $0x8026bc
  800cf8:	e8 5c f4 ff ff       	call   800159 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
  800d0b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d13:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1e:	89 df                	mov    %ebx,%edi
  800d20:	89 de                	mov    %ebx,%esi
  800d22:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d24:	85 c0                	test   %eax,%eax
  800d26:	7e 17                	jle    800d3f <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d28:	83 ec 0c             	sub    $0xc,%esp
  800d2b:	50                   	push   %eax
  800d2c:	6a 0a                	push   $0xa
  800d2e:	68 9f 26 80 00       	push   $0x80269f
  800d33:	6a 23                	push   $0x23
  800d35:	68 bc 26 80 00       	push   $0x8026bc
  800d3a:	e8 1a f4 ff ff       	call   800159 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d42:	5b                   	pop    %ebx
  800d43:	5e                   	pop    %esi
  800d44:	5f                   	pop    %edi
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	57                   	push   %edi
  800d4b:	56                   	push   %esi
  800d4c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4d:	be 00 00 00 00       	mov    $0x0,%esi
  800d52:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d60:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d63:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d65:	5b                   	pop    %ebx
  800d66:	5e                   	pop    %esi
  800d67:	5f                   	pop    %edi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    

00800d6a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	57                   	push   %edi
  800d6e:	56                   	push   %esi
  800d6f:	53                   	push   %ebx
  800d70:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d73:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d78:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d80:	89 cb                	mov    %ecx,%ebx
  800d82:	89 cf                	mov    %ecx,%edi
  800d84:	89 ce                	mov    %ecx,%esi
  800d86:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d88:	85 c0                	test   %eax,%eax
  800d8a:	7e 17                	jle    800da3 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8c:	83 ec 0c             	sub    $0xc,%esp
  800d8f:	50                   	push   %eax
  800d90:	6a 0d                	push   $0xd
  800d92:	68 9f 26 80 00       	push   $0x80269f
  800d97:	6a 23                	push   $0x23
  800d99:	68 bc 26 80 00       	push   $0x8026bc
  800d9e:	e8 b6 f3 ff ff       	call   800159 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da6:	5b                   	pop    %ebx
  800da7:	5e                   	pop    %esi
  800da8:	5f                   	pop    %edi
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	57                   	push   %edi
  800daf:	56                   	push   %esi
  800db0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db1:	ba 00 00 00 00       	mov    $0x0,%edx
  800db6:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dbb:	89 d1                	mov    %edx,%ecx
  800dbd:	89 d3                	mov    %edx,%ebx
  800dbf:	89 d7                	mov    %edx,%edi
  800dc1:	89 d6                	mov    %edx,%esi
  800dc3:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    

00800dca <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	57                   	push   %edi
  800dce:	56                   	push   %esi
  800dcf:	53                   	push   %ebx
  800dd0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd8:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ddd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de0:	8b 55 08             	mov    0x8(%ebp),%edx
  800de3:	89 df                	mov    %ebx,%edi
  800de5:	89 de                	mov    %ebx,%esi
  800de7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de9:	85 c0                	test   %eax,%eax
  800deb:	7e 17                	jle    800e04 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ded:	83 ec 0c             	sub    $0xc,%esp
  800df0:	50                   	push   %eax
  800df1:	6a 0f                	push   $0xf
  800df3:	68 9f 26 80 00       	push   $0x80269f
  800df8:	6a 23                	push   $0x23
  800dfa:	68 bc 26 80 00       	push   $0x8026bc
  800dff:	e8 55 f3 ff ff       	call   800159 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800e04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e07:	5b                   	pop    %ebx
  800e08:	5e                   	pop    %esi
  800e09:	5f                   	pop    %edi
  800e0a:	5d                   	pop    %ebp
  800e0b:	c3                   	ret    

00800e0c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e12:	05 00 00 00 30       	add    $0x30000000,%eax
  800e17:	c1 e8 0c             	shr    $0xc,%eax
}
  800e1a:	5d                   	pop    %ebp
  800e1b:	c3                   	ret    

00800e1c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e22:	05 00 00 00 30       	add    $0x30000000,%eax
  800e27:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e2c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    

00800e33 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e39:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e3e:	89 c2                	mov    %eax,%edx
  800e40:	c1 ea 16             	shr    $0x16,%edx
  800e43:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e4a:	f6 c2 01             	test   $0x1,%dl
  800e4d:	74 11                	je     800e60 <fd_alloc+0x2d>
  800e4f:	89 c2                	mov    %eax,%edx
  800e51:	c1 ea 0c             	shr    $0xc,%edx
  800e54:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e5b:	f6 c2 01             	test   $0x1,%dl
  800e5e:	75 09                	jne    800e69 <fd_alloc+0x36>
			*fd_store = fd;
  800e60:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e62:	b8 00 00 00 00       	mov    $0x0,%eax
  800e67:	eb 17                	jmp    800e80 <fd_alloc+0x4d>
  800e69:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e6e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e73:	75 c9                	jne    800e3e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e75:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e7b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    

00800e82 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e88:	83 f8 1f             	cmp    $0x1f,%eax
  800e8b:	77 36                	ja     800ec3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e8d:	c1 e0 0c             	shl    $0xc,%eax
  800e90:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e95:	89 c2                	mov    %eax,%edx
  800e97:	c1 ea 16             	shr    $0x16,%edx
  800e9a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ea1:	f6 c2 01             	test   $0x1,%dl
  800ea4:	74 24                	je     800eca <fd_lookup+0x48>
  800ea6:	89 c2                	mov    %eax,%edx
  800ea8:	c1 ea 0c             	shr    $0xc,%edx
  800eab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eb2:	f6 c2 01             	test   $0x1,%dl
  800eb5:	74 1a                	je     800ed1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800eb7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eba:	89 02                	mov    %eax,(%edx)
	return 0;
  800ebc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec1:	eb 13                	jmp    800ed6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ec3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec8:	eb 0c                	jmp    800ed6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ecf:	eb 05                	jmp    800ed6 <fd_lookup+0x54>
  800ed1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ed6:	5d                   	pop    %ebp
  800ed7:	c3                   	ret    

00800ed8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	83 ec 08             	sub    $0x8,%esp
  800ede:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee1:	ba 4c 27 80 00       	mov    $0x80274c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ee6:	eb 13                	jmp    800efb <dev_lookup+0x23>
  800ee8:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800eeb:	39 08                	cmp    %ecx,(%eax)
  800eed:	75 0c                	jne    800efb <dev_lookup+0x23>
			*dev = devtab[i];
  800eef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef2:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ef4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef9:	eb 2e                	jmp    800f29 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800efb:	8b 02                	mov    (%edx),%eax
  800efd:	85 c0                	test   %eax,%eax
  800eff:	75 e7                	jne    800ee8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f01:	a1 08 40 80 00       	mov    0x804008,%eax
  800f06:	8b 40 48             	mov    0x48(%eax),%eax
  800f09:	83 ec 04             	sub    $0x4,%esp
  800f0c:	51                   	push   %ecx
  800f0d:	50                   	push   %eax
  800f0e:	68 cc 26 80 00       	push   $0x8026cc
  800f13:	e8 1a f3 ff ff       	call   800232 <cprintf>
	*dev = 0;
  800f18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f21:	83 c4 10             	add    $0x10,%esp
  800f24:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f29:	c9                   	leave  
  800f2a:	c3                   	ret    

00800f2b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
  800f2e:	56                   	push   %esi
  800f2f:	53                   	push   %ebx
  800f30:	83 ec 10             	sub    $0x10,%esp
  800f33:	8b 75 08             	mov    0x8(%ebp),%esi
  800f36:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f39:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f3c:	50                   	push   %eax
  800f3d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f43:	c1 e8 0c             	shr    $0xc,%eax
  800f46:	50                   	push   %eax
  800f47:	e8 36 ff ff ff       	call   800e82 <fd_lookup>
  800f4c:	83 c4 08             	add    $0x8,%esp
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	78 05                	js     800f58 <fd_close+0x2d>
	    || fd != fd2)
  800f53:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f56:	74 0c                	je     800f64 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f58:	84 db                	test   %bl,%bl
  800f5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800f5f:	0f 44 c2             	cmove  %edx,%eax
  800f62:	eb 41                	jmp    800fa5 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f64:	83 ec 08             	sub    $0x8,%esp
  800f67:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f6a:	50                   	push   %eax
  800f6b:	ff 36                	pushl  (%esi)
  800f6d:	e8 66 ff ff ff       	call   800ed8 <dev_lookup>
  800f72:	89 c3                	mov    %eax,%ebx
  800f74:	83 c4 10             	add    $0x10,%esp
  800f77:	85 c0                	test   %eax,%eax
  800f79:	78 1a                	js     800f95 <fd_close+0x6a>
		if (dev->dev_close)
  800f7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f7e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f81:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f86:	85 c0                	test   %eax,%eax
  800f88:	74 0b                	je     800f95 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f8a:	83 ec 0c             	sub    $0xc,%esp
  800f8d:	56                   	push   %esi
  800f8e:	ff d0                	call   *%eax
  800f90:	89 c3                	mov    %eax,%ebx
  800f92:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f95:	83 ec 08             	sub    $0x8,%esp
  800f98:	56                   	push   %esi
  800f99:	6a 00                	push   $0x0
  800f9b:	e8 9f fc ff ff       	call   800c3f <sys_page_unmap>
	return r;
  800fa0:	83 c4 10             	add    $0x10,%esp
  800fa3:	89 d8                	mov    %ebx,%eax
}
  800fa5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fa8:	5b                   	pop    %ebx
  800fa9:	5e                   	pop    %esi
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    

00800fac <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb5:	50                   	push   %eax
  800fb6:	ff 75 08             	pushl  0x8(%ebp)
  800fb9:	e8 c4 fe ff ff       	call   800e82 <fd_lookup>
  800fbe:	83 c4 08             	add    $0x8,%esp
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	78 10                	js     800fd5 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fc5:	83 ec 08             	sub    $0x8,%esp
  800fc8:	6a 01                	push   $0x1
  800fca:	ff 75 f4             	pushl  -0xc(%ebp)
  800fcd:	e8 59 ff ff ff       	call   800f2b <fd_close>
  800fd2:	83 c4 10             	add    $0x10,%esp
}
  800fd5:	c9                   	leave  
  800fd6:	c3                   	ret    

00800fd7 <close_all>:

void
close_all(void)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	53                   	push   %ebx
  800fdb:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fde:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fe3:	83 ec 0c             	sub    $0xc,%esp
  800fe6:	53                   	push   %ebx
  800fe7:	e8 c0 ff ff ff       	call   800fac <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fec:	83 c3 01             	add    $0x1,%ebx
  800fef:	83 c4 10             	add    $0x10,%esp
  800ff2:	83 fb 20             	cmp    $0x20,%ebx
  800ff5:	75 ec                	jne    800fe3 <close_all+0xc>
		close(i);
}
  800ff7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ffa:	c9                   	leave  
  800ffb:	c3                   	ret    

00800ffc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	57                   	push   %edi
  801000:	56                   	push   %esi
  801001:	53                   	push   %ebx
  801002:	83 ec 2c             	sub    $0x2c,%esp
  801005:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801008:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80100b:	50                   	push   %eax
  80100c:	ff 75 08             	pushl  0x8(%ebp)
  80100f:	e8 6e fe ff ff       	call   800e82 <fd_lookup>
  801014:	83 c4 08             	add    $0x8,%esp
  801017:	85 c0                	test   %eax,%eax
  801019:	0f 88 c1 00 00 00    	js     8010e0 <dup+0xe4>
		return r;
	close(newfdnum);
  80101f:	83 ec 0c             	sub    $0xc,%esp
  801022:	56                   	push   %esi
  801023:	e8 84 ff ff ff       	call   800fac <close>

	newfd = INDEX2FD(newfdnum);
  801028:	89 f3                	mov    %esi,%ebx
  80102a:	c1 e3 0c             	shl    $0xc,%ebx
  80102d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801033:	83 c4 04             	add    $0x4,%esp
  801036:	ff 75 e4             	pushl  -0x1c(%ebp)
  801039:	e8 de fd ff ff       	call   800e1c <fd2data>
  80103e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801040:	89 1c 24             	mov    %ebx,(%esp)
  801043:	e8 d4 fd ff ff       	call   800e1c <fd2data>
  801048:	83 c4 10             	add    $0x10,%esp
  80104b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80104e:	89 f8                	mov    %edi,%eax
  801050:	c1 e8 16             	shr    $0x16,%eax
  801053:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80105a:	a8 01                	test   $0x1,%al
  80105c:	74 37                	je     801095 <dup+0x99>
  80105e:	89 f8                	mov    %edi,%eax
  801060:	c1 e8 0c             	shr    $0xc,%eax
  801063:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80106a:	f6 c2 01             	test   $0x1,%dl
  80106d:	74 26                	je     801095 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80106f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801076:	83 ec 0c             	sub    $0xc,%esp
  801079:	25 07 0e 00 00       	and    $0xe07,%eax
  80107e:	50                   	push   %eax
  80107f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801082:	6a 00                	push   $0x0
  801084:	57                   	push   %edi
  801085:	6a 00                	push   $0x0
  801087:	e8 71 fb ff ff       	call   800bfd <sys_page_map>
  80108c:	89 c7                	mov    %eax,%edi
  80108e:	83 c4 20             	add    $0x20,%esp
  801091:	85 c0                	test   %eax,%eax
  801093:	78 2e                	js     8010c3 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801095:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801098:	89 d0                	mov    %edx,%eax
  80109a:	c1 e8 0c             	shr    $0xc,%eax
  80109d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010a4:	83 ec 0c             	sub    $0xc,%esp
  8010a7:	25 07 0e 00 00       	and    $0xe07,%eax
  8010ac:	50                   	push   %eax
  8010ad:	53                   	push   %ebx
  8010ae:	6a 00                	push   $0x0
  8010b0:	52                   	push   %edx
  8010b1:	6a 00                	push   $0x0
  8010b3:	e8 45 fb ff ff       	call   800bfd <sys_page_map>
  8010b8:	89 c7                	mov    %eax,%edi
  8010ba:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010bd:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010bf:	85 ff                	test   %edi,%edi
  8010c1:	79 1d                	jns    8010e0 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010c3:	83 ec 08             	sub    $0x8,%esp
  8010c6:	53                   	push   %ebx
  8010c7:	6a 00                	push   $0x0
  8010c9:	e8 71 fb ff ff       	call   800c3f <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010ce:	83 c4 08             	add    $0x8,%esp
  8010d1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010d4:	6a 00                	push   $0x0
  8010d6:	e8 64 fb ff ff       	call   800c3f <sys_page_unmap>
	return r;
  8010db:	83 c4 10             	add    $0x10,%esp
  8010de:	89 f8                	mov    %edi,%eax
}
  8010e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e3:	5b                   	pop    %ebx
  8010e4:	5e                   	pop    %esi
  8010e5:	5f                   	pop    %edi
  8010e6:	5d                   	pop    %ebp
  8010e7:	c3                   	ret    

008010e8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010e8:	55                   	push   %ebp
  8010e9:	89 e5                	mov    %esp,%ebp
  8010eb:	53                   	push   %ebx
  8010ec:	83 ec 14             	sub    $0x14,%esp
  8010ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010f5:	50                   	push   %eax
  8010f6:	53                   	push   %ebx
  8010f7:	e8 86 fd ff ff       	call   800e82 <fd_lookup>
  8010fc:	83 c4 08             	add    $0x8,%esp
  8010ff:	89 c2                	mov    %eax,%edx
  801101:	85 c0                	test   %eax,%eax
  801103:	78 6d                	js     801172 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801105:	83 ec 08             	sub    $0x8,%esp
  801108:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80110b:	50                   	push   %eax
  80110c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80110f:	ff 30                	pushl  (%eax)
  801111:	e8 c2 fd ff ff       	call   800ed8 <dev_lookup>
  801116:	83 c4 10             	add    $0x10,%esp
  801119:	85 c0                	test   %eax,%eax
  80111b:	78 4c                	js     801169 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80111d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801120:	8b 42 08             	mov    0x8(%edx),%eax
  801123:	83 e0 03             	and    $0x3,%eax
  801126:	83 f8 01             	cmp    $0x1,%eax
  801129:	75 21                	jne    80114c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80112b:	a1 08 40 80 00       	mov    0x804008,%eax
  801130:	8b 40 48             	mov    0x48(%eax),%eax
  801133:	83 ec 04             	sub    $0x4,%esp
  801136:	53                   	push   %ebx
  801137:	50                   	push   %eax
  801138:	68 10 27 80 00       	push   $0x802710
  80113d:	e8 f0 f0 ff ff       	call   800232 <cprintf>
		return -E_INVAL;
  801142:	83 c4 10             	add    $0x10,%esp
  801145:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80114a:	eb 26                	jmp    801172 <read+0x8a>
	}
	if (!dev->dev_read)
  80114c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80114f:	8b 40 08             	mov    0x8(%eax),%eax
  801152:	85 c0                	test   %eax,%eax
  801154:	74 17                	je     80116d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801156:	83 ec 04             	sub    $0x4,%esp
  801159:	ff 75 10             	pushl  0x10(%ebp)
  80115c:	ff 75 0c             	pushl  0xc(%ebp)
  80115f:	52                   	push   %edx
  801160:	ff d0                	call   *%eax
  801162:	89 c2                	mov    %eax,%edx
  801164:	83 c4 10             	add    $0x10,%esp
  801167:	eb 09                	jmp    801172 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801169:	89 c2                	mov    %eax,%edx
  80116b:	eb 05                	jmp    801172 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80116d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801172:	89 d0                	mov    %edx,%eax
  801174:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801177:	c9                   	leave  
  801178:	c3                   	ret    

00801179 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801179:	55                   	push   %ebp
  80117a:	89 e5                	mov    %esp,%ebp
  80117c:	57                   	push   %edi
  80117d:	56                   	push   %esi
  80117e:	53                   	push   %ebx
  80117f:	83 ec 0c             	sub    $0xc,%esp
  801182:	8b 7d 08             	mov    0x8(%ebp),%edi
  801185:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801188:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118d:	eb 21                	jmp    8011b0 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80118f:	83 ec 04             	sub    $0x4,%esp
  801192:	89 f0                	mov    %esi,%eax
  801194:	29 d8                	sub    %ebx,%eax
  801196:	50                   	push   %eax
  801197:	89 d8                	mov    %ebx,%eax
  801199:	03 45 0c             	add    0xc(%ebp),%eax
  80119c:	50                   	push   %eax
  80119d:	57                   	push   %edi
  80119e:	e8 45 ff ff ff       	call   8010e8 <read>
		if (m < 0)
  8011a3:	83 c4 10             	add    $0x10,%esp
  8011a6:	85 c0                	test   %eax,%eax
  8011a8:	78 10                	js     8011ba <readn+0x41>
			return m;
		if (m == 0)
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	74 0a                	je     8011b8 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011ae:	01 c3                	add    %eax,%ebx
  8011b0:	39 f3                	cmp    %esi,%ebx
  8011b2:	72 db                	jb     80118f <readn+0x16>
  8011b4:	89 d8                	mov    %ebx,%eax
  8011b6:	eb 02                	jmp    8011ba <readn+0x41>
  8011b8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bd:	5b                   	pop    %ebx
  8011be:	5e                   	pop    %esi
  8011bf:	5f                   	pop    %edi
  8011c0:	5d                   	pop    %ebp
  8011c1:	c3                   	ret    

008011c2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011c2:	55                   	push   %ebp
  8011c3:	89 e5                	mov    %esp,%ebp
  8011c5:	53                   	push   %ebx
  8011c6:	83 ec 14             	sub    $0x14,%esp
  8011c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011cf:	50                   	push   %eax
  8011d0:	53                   	push   %ebx
  8011d1:	e8 ac fc ff ff       	call   800e82 <fd_lookup>
  8011d6:	83 c4 08             	add    $0x8,%esp
  8011d9:	89 c2                	mov    %eax,%edx
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	78 68                	js     801247 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011df:	83 ec 08             	sub    $0x8,%esp
  8011e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e5:	50                   	push   %eax
  8011e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e9:	ff 30                	pushl  (%eax)
  8011eb:	e8 e8 fc ff ff       	call   800ed8 <dev_lookup>
  8011f0:	83 c4 10             	add    $0x10,%esp
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	78 47                	js     80123e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011fa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011fe:	75 21                	jne    801221 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801200:	a1 08 40 80 00       	mov    0x804008,%eax
  801205:	8b 40 48             	mov    0x48(%eax),%eax
  801208:	83 ec 04             	sub    $0x4,%esp
  80120b:	53                   	push   %ebx
  80120c:	50                   	push   %eax
  80120d:	68 2c 27 80 00       	push   $0x80272c
  801212:	e8 1b f0 ff ff       	call   800232 <cprintf>
		return -E_INVAL;
  801217:	83 c4 10             	add    $0x10,%esp
  80121a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80121f:	eb 26                	jmp    801247 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801221:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801224:	8b 52 0c             	mov    0xc(%edx),%edx
  801227:	85 d2                	test   %edx,%edx
  801229:	74 17                	je     801242 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80122b:	83 ec 04             	sub    $0x4,%esp
  80122e:	ff 75 10             	pushl  0x10(%ebp)
  801231:	ff 75 0c             	pushl  0xc(%ebp)
  801234:	50                   	push   %eax
  801235:	ff d2                	call   *%edx
  801237:	89 c2                	mov    %eax,%edx
  801239:	83 c4 10             	add    $0x10,%esp
  80123c:	eb 09                	jmp    801247 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80123e:	89 c2                	mov    %eax,%edx
  801240:	eb 05                	jmp    801247 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801242:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801247:	89 d0                	mov    %edx,%eax
  801249:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80124c:	c9                   	leave  
  80124d:	c3                   	ret    

0080124e <seek>:

int
seek(int fdnum, off_t offset)
{
  80124e:	55                   	push   %ebp
  80124f:	89 e5                	mov    %esp,%ebp
  801251:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801254:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801257:	50                   	push   %eax
  801258:	ff 75 08             	pushl  0x8(%ebp)
  80125b:	e8 22 fc ff ff       	call   800e82 <fd_lookup>
  801260:	83 c4 08             	add    $0x8,%esp
  801263:	85 c0                	test   %eax,%eax
  801265:	78 0e                	js     801275 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801267:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80126a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80126d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801270:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801275:	c9                   	leave  
  801276:	c3                   	ret    

00801277 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801277:	55                   	push   %ebp
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	53                   	push   %ebx
  80127b:	83 ec 14             	sub    $0x14,%esp
  80127e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801281:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801284:	50                   	push   %eax
  801285:	53                   	push   %ebx
  801286:	e8 f7 fb ff ff       	call   800e82 <fd_lookup>
  80128b:	83 c4 08             	add    $0x8,%esp
  80128e:	89 c2                	mov    %eax,%edx
  801290:	85 c0                	test   %eax,%eax
  801292:	78 65                	js     8012f9 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801294:	83 ec 08             	sub    $0x8,%esp
  801297:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129a:	50                   	push   %eax
  80129b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129e:	ff 30                	pushl  (%eax)
  8012a0:	e8 33 fc ff ff       	call   800ed8 <dev_lookup>
  8012a5:	83 c4 10             	add    $0x10,%esp
  8012a8:	85 c0                	test   %eax,%eax
  8012aa:	78 44                	js     8012f0 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012af:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012b3:	75 21                	jne    8012d6 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012b5:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012ba:	8b 40 48             	mov    0x48(%eax),%eax
  8012bd:	83 ec 04             	sub    $0x4,%esp
  8012c0:	53                   	push   %ebx
  8012c1:	50                   	push   %eax
  8012c2:	68 ec 26 80 00       	push   $0x8026ec
  8012c7:	e8 66 ef ff ff       	call   800232 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012cc:	83 c4 10             	add    $0x10,%esp
  8012cf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012d4:	eb 23                	jmp    8012f9 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012d9:	8b 52 18             	mov    0x18(%edx),%edx
  8012dc:	85 d2                	test   %edx,%edx
  8012de:	74 14                	je     8012f4 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012e0:	83 ec 08             	sub    $0x8,%esp
  8012e3:	ff 75 0c             	pushl  0xc(%ebp)
  8012e6:	50                   	push   %eax
  8012e7:	ff d2                	call   *%edx
  8012e9:	89 c2                	mov    %eax,%edx
  8012eb:	83 c4 10             	add    $0x10,%esp
  8012ee:	eb 09                	jmp    8012f9 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f0:	89 c2                	mov    %eax,%edx
  8012f2:	eb 05                	jmp    8012f9 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012f4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012f9:	89 d0                	mov    %edx,%eax
  8012fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012fe:	c9                   	leave  
  8012ff:	c3                   	ret    

00801300 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	53                   	push   %ebx
  801304:	83 ec 14             	sub    $0x14,%esp
  801307:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80130a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130d:	50                   	push   %eax
  80130e:	ff 75 08             	pushl  0x8(%ebp)
  801311:	e8 6c fb ff ff       	call   800e82 <fd_lookup>
  801316:	83 c4 08             	add    $0x8,%esp
  801319:	89 c2                	mov    %eax,%edx
  80131b:	85 c0                	test   %eax,%eax
  80131d:	78 58                	js     801377 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131f:	83 ec 08             	sub    $0x8,%esp
  801322:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801325:	50                   	push   %eax
  801326:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801329:	ff 30                	pushl  (%eax)
  80132b:	e8 a8 fb ff ff       	call   800ed8 <dev_lookup>
  801330:	83 c4 10             	add    $0x10,%esp
  801333:	85 c0                	test   %eax,%eax
  801335:	78 37                	js     80136e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801337:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80133a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80133e:	74 32                	je     801372 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801340:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801343:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80134a:	00 00 00 
	stat->st_isdir = 0;
  80134d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801354:	00 00 00 
	stat->st_dev = dev;
  801357:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80135d:	83 ec 08             	sub    $0x8,%esp
  801360:	53                   	push   %ebx
  801361:	ff 75 f0             	pushl  -0x10(%ebp)
  801364:	ff 50 14             	call   *0x14(%eax)
  801367:	89 c2                	mov    %eax,%edx
  801369:	83 c4 10             	add    $0x10,%esp
  80136c:	eb 09                	jmp    801377 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80136e:	89 c2                	mov    %eax,%edx
  801370:	eb 05                	jmp    801377 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801372:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801377:	89 d0                	mov    %edx,%eax
  801379:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137c:	c9                   	leave  
  80137d:	c3                   	ret    

0080137e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80137e:	55                   	push   %ebp
  80137f:	89 e5                	mov    %esp,%ebp
  801381:	56                   	push   %esi
  801382:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801383:	83 ec 08             	sub    $0x8,%esp
  801386:	6a 00                	push   $0x0
  801388:	ff 75 08             	pushl  0x8(%ebp)
  80138b:	e8 d6 01 00 00       	call   801566 <open>
  801390:	89 c3                	mov    %eax,%ebx
  801392:	83 c4 10             	add    $0x10,%esp
  801395:	85 c0                	test   %eax,%eax
  801397:	78 1b                	js     8013b4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801399:	83 ec 08             	sub    $0x8,%esp
  80139c:	ff 75 0c             	pushl  0xc(%ebp)
  80139f:	50                   	push   %eax
  8013a0:	e8 5b ff ff ff       	call   801300 <fstat>
  8013a5:	89 c6                	mov    %eax,%esi
	close(fd);
  8013a7:	89 1c 24             	mov    %ebx,(%esp)
  8013aa:	e8 fd fb ff ff       	call   800fac <close>
	return r;
  8013af:	83 c4 10             	add    $0x10,%esp
  8013b2:	89 f0                	mov    %esi,%eax
}
  8013b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013b7:	5b                   	pop    %ebx
  8013b8:	5e                   	pop    %esi
  8013b9:	5d                   	pop    %ebp
  8013ba:	c3                   	ret    

008013bb <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013bb:	55                   	push   %ebp
  8013bc:	89 e5                	mov    %esp,%ebp
  8013be:	56                   	push   %esi
  8013bf:	53                   	push   %ebx
  8013c0:	89 c6                	mov    %eax,%esi
  8013c2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013c4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013cb:	75 12                	jne    8013df <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013cd:	83 ec 0c             	sub    $0xc,%esp
  8013d0:	6a 01                	push   $0x1
  8013d2:	e8 34 0c 00 00       	call   80200b <ipc_find_env>
  8013d7:	a3 00 40 80 00       	mov    %eax,0x804000
  8013dc:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013df:	6a 07                	push   $0x7
  8013e1:	68 00 50 80 00       	push   $0x805000
  8013e6:	56                   	push   %esi
  8013e7:	ff 35 00 40 80 00    	pushl  0x804000
  8013ed:	e8 c5 0b 00 00       	call   801fb7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013f2:	83 c4 0c             	add    $0xc,%esp
  8013f5:	6a 00                	push   $0x0
  8013f7:	53                   	push   %ebx
  8013f8:	6a 00                	push   $0x0
  8013fa:	e8 51 0b 00 00       	call   801f50 <ipc_recv>
}
  8013ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801402:	5b                   	pop    %ebx
  801403:	5e                   	pop    %esi
  801404:	5d                   	pop    %ebp
  801405:	c3                   	ret    

00801406 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801406:	55                   	push   %ebp
  801407:	89 e5                	mov    %esp,%ebp
  801409:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80140c:	8b 45 08             	mov    0x8(%ebp),%eax
  80140f:	8b 40 0c             	mov    0xc(%eax),%eax
  801412:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801417:	8b 45 0c             	mov    0xc(%ebp),%eax
  80141a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80141f:	ba 00 00 00 00       	mov    $0x0,%edx
  801424:	b8 02 00 00 00       	mov    $0x2,%eax
  801429:	e8 8d ff ff ff       	call   8013bb <fsipc>
}
  80142e:	c9                   	leave  
  80142f:	c3                   	ret    

00801430 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801436:	8b 45 08             	mov    0x8(%ebp),%eax
  801439:	8b 40 0c             	mov    0xc(%eax),%eax
  80143c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801441:	ba 00 00 00 00       	mov    $0x0,%edx
  801446:	b8 06 00 00 00       	mov    $0x6,%eax
  80144b:	e8 6b ff ff ff       	call   8013bb <fsipc>
}
  801450:	c9                   	leave  
  801451:	c3                   	ret    

00801452 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801452:	55                   	push   %ebp
  801453:	89 e5                	mov    %esp,%ebp
  801455:	53                   	push   %ebx
  801456:	83 ec 04             	sub    $0x4,%esp
  801459:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80145c:	8b 45 08             	mov    0x8(%ebp),%eax
  80145f:	8b 40 0c             	mov    0xc(%eax),%eax
  801462:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801467:	ba 00 00 00 00       	mov    $0x0,%edx
  80146c:	b8 05 00 00 00       	mov    $0x5,%eax
  801471:	e8 45 ff ff ff       	call   8013bb <fsipc>
  801476:	85 c0                	test   %eax,%eax
  801478:	78 2c                	js     8014a6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80147a:	83 ec 08             	sub    $0x8,%esp
  80147d:	68 00 50 80 00       	push   $0x805000
  801482:	53                   	push   %ebx
  801483:	e8 2f f3 ff ff       	call   8007b7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801488:	a1 80 50 80 00       	mov    0x805080,%eax
  80148d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801493:	a1 84 50 80 00       	mov    0x805084,%eax
  801498:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80149e:	83 c4 10             	add    $0x10,%esp
  8014a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a9:	c9                   	leave  
  8014aa:	c3                   	ret    

008014ab <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014ab:	55                   	push   %ebp
  8014ac:	89 e5                	mov    %esp,%ebp
  8014ae:	83 ec 0c             	sub    $0xc,%esp
  8014b1:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8014b7:	8b 52 0c             	mov    0xc(%edx),%edx
  8014ba:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014c0:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014c5:	50                   	push   %eax
  8014c6:	ff 75 0c             	pushl  0xc(%ebp)
  8014c9:	68 08 50 80 00       	push   $0x805008
  8014ce:	e8 76 f4 ff ff       	call   800949 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8014d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d8:	b8 04 00 00 00       	mov    $0x4,%eax
  8014dd:	e8 d9 fe ff ff       	call   8013bb <fsipc>

}
  8014e2:	c9                   	leave  
  8014e3:	c3                   	ret    

008014e4 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	56                   	push   %esi
  8014e8:	53                   	push   %ebx
  8014e9:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ef:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014f7:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801502:	b8 03 00 00 00       	mov    $0x3,%eax
  801507:	e8 af fe ff ff       	call   8013bb <fsipc>
  80150c:	89 c3                	mov    %eax,%ebx
  80150e:	85 c0                	test   %eax,%eax
  801510:	78 4b                	js     80155d <devfile_read+0x79>
		return r;
	assert(r <= n);
  801512:	39 c6                	cmp    %eax,%esi
  801514:	73 16                	jae    80152c <devfile_read+0x48>
  801516:	68 60 27 80 00       	push   $0x802760
  80151b:	68 67 27 80 00       	push   $0x802767
  801520:	6a 7c                	push   $0x7c
  801522:	68 7c 27 80 00       	push   $0x80277c
  801527:	e8 2d ec ff ff       	call   800159 <_panic>
	assert(r <= PGSIZE);
  80152c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801531:	7e 16                	jle    801549 <devfile_read+0x65>
  801533:	68 87 27 80 00       	push   $0x802787
  801538:	68 67 27 80 00       	push   $0x802767
  80153d:	6a 7d                	push   $0x7d
  80153f:	68 7c 27 80 00       	push   $0x80277c
  801544:	e8 10 ec ff ff       	call   800159 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801549:	83 ec 04             	sub    $0x4,%esp
  80154c:	50                   	push   %eax
  80154d:	68 00 50 80 00       	push   $0x805000
  801552:	ff 75 0c             	pushl  0xc(%ebp)
  801555:	e8 ef f3 ff ff       	call   800949 <memmove>
	return r;
  80155a:	83 c4 10             	add    $0x10,%esp
}
  80155d:	89 d8                	mov    %ebx,%eax
  80155f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801562:	5b                   	pop    %ebx
  801563:	5e                   	pop    %esi
  801564:	5d                   	pop    %ebp
  801565:	c3                   	ret    

00801566 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801566:	55                   	push   %ebp
  801567:	89 e5                	mov    %esp,%ebp
  801569:	53                   	push   %ebx
  80156a:	83 ec 20             	sub    $0x20,%esp
  80156d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801570:	53                   	push   %ebx
  801571:	e8 08 f2 ff ff       	call   80077e <strlen>
  801576:	83 c4 10             	add    $0x10,%esp
  801579:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80157e:	7f 67                	jg     8015e7 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801580:	83 ec 0c             	sub    $0xc,%esp
  801583:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801586:	50                   	push   %eax
  801587:	e8 a7 f8 ff ff       	call   800e33 <fd_alloc>
  80158c:	83 c4 10             	add    $0x10,%esp
		return r;
  80158f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801591:	85 c0                	test   %eax,%eax
  801593:	78 57                	js     8015ec <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801595:	83 ec 08             	sub    $0x8,%esp
  801598:	53                   	push   %ebx
  801599:	68 00 50 80 00       	push   $0x805000
  80159e:	e8 14 f2 ff ff       	call   8007b7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015a6:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8015b3:	e8 03 fe ff ff       	call   8013bb <fsipc>
  8015b8:	89 c3                	mov    %eax,%ebx
  8015ba:	83 c4 10             	add    $0x10,%esp
  8015bd:	85 c0                	test   %eax,%eax
  8015bf:	79 14                	jns    8015d5 <open+0x6f>
		fd_close(fd, 0);
  8015c1:	83 ec 08             	sub    $0x8,%esp
  8015c4:	6a 00                	push   $0x0
  8015c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8015c9:	e8 5d f9 ff ff       	call   800f2b <fd_close>
		return r;
  8015ce:	83 c4 10             	add    $0x10,%esp
  8015d1:	89 da                	mov    %ebx,%edx
  8015d3:	eb 17                	jmp    8015ec <open+0x86>
	}

	return fd2num(fd);
  8015d5:	83 ec 0c             	sub    $0xc,%esp
  8015d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8015db:	e8 2c f8 ff ff       	call   800e0c <fd2num>
  8015e0:	89 c2                	mov    %eax,%edx
  8015e2:	83 c4 10             	add    $0x10,%esp
  8015e5:	eb 05                	jmp    8015ec <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015e7:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015ec:	89 d0                	mov    %edx,%eax
  8015ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f1:	c9                   	leave  
  8015f2:	c3                   	ret    

008015f3 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015f3:	55                   	push   %ebp
  8015f4:	89 e5                	mov    %esp,%ebp
  8015f6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8015fe:	b8 08 00 00 00       	mov    $0x8,%eax
  801603:	e8 b3 fd ff ff       	call   8013bb <fsipc>
}
  801608:	c9                   	leave  
  801609:	c3                   	ret    

0080160a <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801610:	68 93 27 80 00       	push   $0x802793
  801615:	ff 75 0c             	pushl  0xc(%ebp)
  801618:	e8 9a f1 ff ff       	call   8007b7 <strcpy>
	return 0;
}
  80161d:	b8 00 00 00 00       	mov    $0x0,%eax
  801622:	c9                   	leave  
  801623:	c3                   	ret    

00801624 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801624:	55                   	push   %ebp
  801625:	89 e5                	mov    %esp,%ebp
  801627:	53                   	push   %ebx
  801628:	83 ec 10             	sub    $0x10,%esp
  80162b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80162e:	53                   	push   %ebx
  80162f:	e8 10 0a 00 00       	call   802044 <pageref>
  801634:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801637:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80163c:	83 f8 01             	cmp    $0x1,%eax
  80163f:	75 10                	jne    801651 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801641:	83 ec 0c             	sub    $0xc,%esp
  801644:	ff 73 0c             	pushl  0xc(%ebx)
  801647:	e8 c0 02 00 00       	call   80190c <nsipc_close>
  80164c:	89 c2                	mov    %eax,%edx
  80164e:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801651:	89 d0                	mov    %edx,%eax
  801653:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801656:	c9                   	leave  
  801657:	c3                   	ret    

00801658 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801658:	55                   	push   %ebp
  801659:	89 e5                	mov    %esp,%ebp
  80165b:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80165e:	6a 00                	push   $0x0
  801660:	ff 75 10             	pushl  0x10(%ebp)
  801663:	ff 75 0c             	pushl  0xc(%ebp)
  801666:	8b 45 08             	mov    0x8(%ebp),%eax
  801669:	ff 70 0c             	pushl  0xc(%eax)
  80166c:	e8 78 03 00 00       	call   8019e9 <nsipc_send>
}
  801671:	c9                   	leave  
  801672:	c3                   	ret    

00801673 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801679:	6a 00                	push   $0x0
  80167b:	ff 75 10             	pushl  0x10(%ebp)
  80167e:	ff 75 0c             	pushl  0xc(%ebp)
  801681:	8b 45 08             	mov    0x8(%ebp),%eax
  801684:	ff 70 0c             	pushl  0xc(%eax)
  801687:	e8 f1 02 00 00       	call   80197d <nsipc_recv>
}
  80168c:	c9                   	leave  
  80168d:	c3                   	ret    

0080168e <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801694:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801697:	52                   	push   %edx
  801698:	50                   	push   %eax
  801699:	e8 e4 f7 ff ff       	call   800e82 <fd_lookup>
  80169e:	83 c4 10             	add    $0x10,%esp
  8016a1:	85 c0                	test   %eax,%eax
  8016a3:	78 17                	js     8016bc <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8016a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a8:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8016ae:	39 08                	cmp    %ecx,(%eax)
  8016b0:	75 05                	jne    8016b7 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8016b2:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b5:	eb 05                	jmp    8016bc <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8016b7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8016bc:	c9                   	leave  
  8016bd:	c3                   	ret    

008016be <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8016be:	55                   	push   %ebp
  8016bf:	89 e5                	mov    %esp,%ebp
  8016c1:	56                   	push   %esi
  8016c2:	53                   	push   %ebx
  8016c3:	83 ec 1c             	sub    $0x1c,%esp
  8016c6:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8016c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016cb:	50                   	push   %eax
  8016cc:	e8 62 f7 ff ff       	call   800e33 <fd_alloc>
  8016d1:	89 c3                	mov    %eax,%ebx
  8016d3:	83 c4 10             	add    $0x10,%esp
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	78 1b                	js     8016f5 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8016da:	83 ec 04             	sub    $0x4,%esp
  8016dd:	68 07 04 00 00       	push   $0x407
  8016e2:	ff 75 f4             	pushl  -0xc(%ebp)
  8016e5:	6a 00                	push   $0x0
  8016e7:	e8 ce f4 ff ff       	call   800bba <sys_page_alloc>
  8016ec:	89 c3                	mov    %eax,%ebx
  8016ee:	83 c4 10             	add    $0x10,%esp
  8016f1:	85 c0                	test   %eax,%eax
  8016f3:	79 10                	jns    801705 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8016f5:	83 ec 0c             	sub    $0xc,%esp
  8016f8:	56                   	push   %esi
  8016f9:	e8 0e 02 00 00       	call   80190c <nsipc_close>
		return r;
  8016fe:	83 c4 10             	add    $0x10,%esp
  801701:	89 d8                	mov    %ebx,%eax
  801703:	eb 24                	jmp    801729 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801705:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80170b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80170e:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801710:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801713:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80171a:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80171d:	83 ec 0c             	sub    $0xc,%esp
  801720:	50                   	push   %eax
  801721:	e8 e6 f6 ff ff       	call   800e0c <fd2num>
  801726:	83 c4 10             	add    $0x10,%esp
}
  801729:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80172c:	5b                   	pop    %ebx
  80172d:	5e                   	pop    %esi
  80172e:	5d                   	pop    %ebp
  80172f:	c3                   	ret    

00801730 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801736:	8b 45 08             	mov    0x8(%ebp),%eax
  801739:	e8 50 ff ff ff       	call   80168e <fd2sockid>
		return r;
  80173e:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801740:	85 c0                	test   %eax,%eax
  801742:	78 1f                	js     801763 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801744:	83 ec 04             	sub    $0x4,%esp
  801747:	ff 75 10             	pushl  0x10(%ebp)
  80174a:	ff 75 0c             	pushl  0xc(%ebp)
  80174d:	50                   	push   %eax
  80174e:	e8 12 01 00 00       	call   801865 <nsipc_accept>
  801753:	83 c4 10             	add    $0x10,%esp
		return r;
  801756:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801758:	85 c0                	test   %eax,%eax
  80175a:	78 07                	js     801763 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80175c:	e8 5d ff ff ff       	call   8016be <alloc_sockfd>
  801761:	89 c1                	mov    %eax,%ecx
}
  801763:	89 c8                	mov    %ecx,%eax
  801765:	c9                   	leave  
  801766:	c3                   	ret    

00801767 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801767:	55                   	push   %ebp
  801768:	89 e5                	mov    %esp,%ebp
  80176a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80176d:	8b 45 08             	mov    0x8(%ebp),%eax
  801770:	e8 19 ff ff ff       	call   80168e <fd2sockid>
  801775:	85 c0                	test   %eax,%eax
  801777:	78 12                	js     80178b <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801779:	83 ec 04             	sub    $0x4,%esp
  80177c:	ff 75 10             	pushl  0x10(%ebp)
  80177f:	ff 75 0c             	pushl  0xc(%ebp)
  801782:	50                   	push   %eax
  801783:	e8 2d 01 00 00       	call   8018b5 <nsipc_bind>
  801788:	83 c4 10             	add    $0x10,%esp
}
  80178b:	c9                   	leave  
  80178c:	c3                   	ret    

0080178d <shutdown>:

int
shutdown(int s, int how)
{
  80178d:	55                   	push   %ebp
  80178e:	89 e5                	mov    %esp,%ebp
  801790:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801793:	8b 45 08             	mov    0x8(%ebp),%eax
  801796:	e8 f3 fe ff ff       	call   80168e <fd2sockid>
  80179b:	85 c0                	test   %eax,%eax
  80179d:	78 0f                	js     8017ae <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80179f:	83 ec 08             	sub    $0x8,%esp
  8017a2:	ff 75 0c             	pushl  0xc(%ebp)
  8017a5:	50                   	push   %eax
  8017a6:	e8 3f 01 00 00       	call   8018ea <nsipc_shutdown>
  8017ab:	83 c4 10             	add    $0x10,%esp
}
  8017ae:	c9                   	leave  
  8017af:	c3                   	ret    

008017b0 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b9:	e8 d0 fe ff ff       	call   80168e <fd2sockid>
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	78 12                	js     8017d4 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8017c2:	83 ec 04             	sub    $0x4,%esp
  8017c5:	ff 75 10             	pushl  0x10(%ebp)
  8017c8:	ff 75 0c             	pushl  0xc(%ebp)
  8017cb:	50                   	push   %eax
  8017cc:	e8 55 01 00 00       	call   801926 <nsipc_connect>
  8017d1:	83 c4 10             	add    $0x10,%esp
}
  8017d4:	c9                   	leave  
  8017d5:	c3                   	ret    

008017d6 <listen>:

int
listen(int s, int backlog)
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017df:	e8 aa fe ff ff       	call   80168e <fd2sockid>
  8017e4:	85 c0                	test   %eax,%eax
  8017e6:	78 0f                	js     8017f7 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8017e8:	83 ec 08             	sub    $0x8,%esp
  8017eb:	ff 75 0c             	pushl  0xc(%ebp)
  8017ee:	50                   	push   %eax
  8017ef:	e8 67 01 00 00       	call   80195b <nsipc_listen>
  8017f4:	83 c4 10             	add    $0x10,%esp
}
  8017f7:	c9                   	leave  
  8017f8:	c3                   	ret    

008017f9 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8017f9:	55                   	push   %ebp
  8017fa:	89 e5                	mov    %esp,%ebp
  8017fc:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8017ff:	ff 75 10             	pushl  0x10(%ebp)
  801802:	ff 75 0c             	pushl  0xc(%ebp)
  801805:	ff 75 08             	pushl  0x8(%ebp)
  801808:	e8 3a 02 00 00       	call   801a47 <nsipc_socket>
  80180d:	83 c4 10             	add    $0x10,%esp
  801810:	85 c0                	test   %eax,%eax
  801812:	78 05                	js     801819 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801814:	e8 a5 fe ff ff       	call   8016be <alloc_sockfd>
}
  801819:	c9                   	leave  
  80181a:	c3                   	ret    

0080181b <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	53                   	push   %ebx
  80181f:	83 ec 04             	sub    $0x4,%esp
  801822:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801824:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80182b:	75 12                	jne    80183f <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80182d:	83 ec 0c             	sub    $0xc,%esp
  801830:	6a 02                	push   $0x2
  801832:	e8 d4 07 00 00       	call   80200b <ipc_find_env>
  801837:	a3 04 40 80 00       	mov    %eax,0x804004
  80183c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80183f:	6a 07                	push   $0x7
  801841:	68 00 60 80 00       	push   $0x806000
  801846:	53                   	push   %ebx
  801847:	ff 35 04 40 80 00    	pushl  0x804004
  80184d:	e8 65 07 00 00       	call   801fb7 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801852:	83 c4 0c             	add    $0xc,%esp
  801855:	6a 00                	push   $0x0
  801857:	6a 00                	push   $0x0
  801859:	6a 00                	push   $0x0
  80185b:	e8 f0 06 00 00       	call   801f50 <ipc_recv>
}
  801860:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801863:	c9                   	leave  
  801864:	c3                   	ret    

00801865 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801865:	55                   	push   %ebp
  801866:	89 e5                	mov    %esp,%ebp
  801868:	56                   	push   %esi
  801869:	53                   	push   %ebx
  80186a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80186d:	8b 45 08             	mov    0x8(%ebp),%eax
  801870:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801875:	8b 06                	mov    (%esi),%eax
  801877:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80187c:	b8 01 00 00 00       	mov    $0x1,%eax
  801881:	e8 95 ff ff ff       	call   80181b <nsipc>
  801886:	89 c3                	mov    %eax,%ebx
  801888:	85 c0                	test   %eax,%eax
  80188a:	78 20                	js     8018ac <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80188c:	83 ec 04             	sub    $0x4,%esp
  80188f:	ff 35 10 60 80 00    	pushl  0x806010
  801895:	68 00 60 80 00       	push   $0x806000
  80189a:	ff 75 0c             	pushl  0xc(%ebp)
  80189d:	e8 a7 f0 ff ff       	call   800949 <memmove>
		*addrlen = ret->ret_addrlen;
  8018a2:	a1 10 60 80 00       	mov    0x806010,%eax
  8018a7:	89 06                	mov    %eax,(%esi)
  8018a9:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8018ac:	89 d8                	mov    %ebx,%eax
  8018ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b1:	5b                   	pop    %ebx
  8018b2:	5e                   	pop    %esi
  8018b3:	5d                   	pop    %ebp
  8018b4:	c3                   	ret    

008018b5 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8018b5:	55                   	push   %ebp
  8018b6:	89 e5                	mov    %esp,%ebp
  8018b8:	53                   	push   %ebx
  8018b9:	83 ec 08             	sub    $0x8,%esp
  8018bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8018bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c2:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8018c7:	53                   	push   %ebx
  8018c8:	ff 75 0c             	pushl  0xc(%ebp)
  8018cb:	68 04 60 80 00       	push   $0x806004
  8018d0:	e8 74 f0 ff ff       	call   800949 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8018d5:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8018db:	b8 02 00 00 00       	mov    $0x2,%eax
  8018e0:	e8 36 ff ff ff       	call   80181b <nsipc>
}
  8018e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e8:	c9                   	leave  
  8018e9:	c3                   	ret    

008018ea <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8018ea:	55                   	push   %ebp
  8018eb:	89 e5                	mov    %esp,%ebp
  8018ed:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8018f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8018f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018fb:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801900:	b8 03 00 00 00       	mov    $0x3,%eax
  801905:	e8 11 ff ff ff       	call   80181b <nsipc>
}
  80190a:	c9                   	leave  
  80190b:	c3                   	ret    

0080190c <nsipc_close>:

int
nsipc_close(int s)
{
  80190c:	55                   	push   %ebp
  80190d:	89 e5                	mov    %esp,%ebp
  80190f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801912:	8b 45 08             	mov    0x8(%ebp),%eax
  801915:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  80191a:	b8 04 00 00 00       	mov    $0x4,%eax
  80191f:	e8 f7 fe ff ff       	call   80181b <nsipc>
}
  801924:	c9                   	leave  
  801925:	c3                   	ret    

00801926 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	53                   	push   %ebx
  80192a:	83 ec 08             	sub    $0x8,%esp
  80192d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801930:	8b 45 08             	mov    0x8(%ebp),%eax
  801933:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801938:	53                   	push   %ebx
  801939:	ff 75 0c             	pushl  0xc(%ebp)
  80193c:	68 04 60 80 00       	push   $0x806004
  801941:	e8 03 f0 ff ff       	call   800949 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801946:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  80194c:	b8 05 00 00 00       	mov    $0x5,%eax
  801951:	e8 c5 fe ff ff       	call   80181b <nsipc>
}
  801956:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801959:	c9                   	leave  
  80195a:	c3                   	ret    

0080195b <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80195b:	55                   	push   %ebp
  80195c:	89 e5                	mov    %esp,%ebp
  80195e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801961:	8b 45 08             	mov    0x8(%ebp),%eax
  801964:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801969:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801971:	b8 06 00 00 00       	mov    $0x6,%eax
  801976:	e8 a0 fe ff ff       	call   80181b <nsipc>
}
  80197b:	c9                   	leave  
  80197c:	c3                   	ret    

0080197d <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80197d:	55                   	push   %ebp
  80197e:	89 e5                	mov    %esp,%ebp
  801980:	56                   	push   %esi
  801981:	53                   	push   %ebx
  801982:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801985:	8b 45 08             	mov    0x8(%ebp),%eax
  801988:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80198d:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801993:	8b 45 14             	mov    0x14(%ebp),%eax
  801996:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80199b:	b8 07 00 00 00       	mov    $0x7,%eax
  8019a0:	e8 76 fe ff ff       	call   80181b <nsipc>
  8019a5:	89 c3                	mov    %eax,%ebx
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	78 35                	js     8019e0 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8019ab:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8019b0:	7f 04                	jg     8019b6 <nsipc_recv+0x39>
  8019b2:	39 c6                	cmp    %eax,%esi
  8019b4:	7d 16                	jge    8019cc <nsipc_recv+0x4f>
  8019b6:	68 9f 27 80 00       	push   $0x80279f
  8019bb:	68 67 27 80 00       	push   $0x802767
  8019c0:	6a 62                	push   $0x62
  8019c2:	68 b4 27 80 00       	push   $0x8027b4
  8019c7:	e8 8d e7 ff ff       	call   800159 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8019cc:	83 ec 04             	sub    $0x4,%esp
  8019cf:	50                   	push   %eax
  8019d0:	68 00 60 80 00       	push   $0x806000
  8019d5:	ff 75 0c             	pushl  0xc(%ebp)
  8019d8:	e8 6c ef ff ff       	call   800949 <memmove>
  8019dd:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8019e0:	89 d8                	mov    %ebx,%eax
  8019e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019e5:	5b                   	pop    %ebx
  8019e6:	5e                   	pop    %esi
  8019e7:	5d                   	pop    %ebp
  8019e8:	c3                   	ret    

008019e9 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	53                   	push   %ebx
  8019ed:	83 ec 04             	sub    $0x4,%esp
  8019f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8019f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f6:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8019fb:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a01:	7e 16                	jle    801a19 <nsipc_send+0x30>
  801a03:	68 c0 27 80 00       	push   $0x8027c0
  801a08:	68 67 27 80 00       	push   $0x802767
  801a0d:	6a 6d                	push   $0x6d
  801a0f:	68 b4 27 80 00       	push   $0x8027b4
  801a14:	e8 40 e7 ff ff       	call   800159 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a19:	83 ec 04             	sub    $0x4,%esp
  801a1c:	53                   	push   %ebx
  801a1d:	ff 75 0c             	pushl  0xc(%ebp)
  801a20:	68 0c 60 80 00       	push   $0x80600c
  801a25:	e8 1f ef ff ff       	call   800949 <memmove>
	nsipcbuf.send.req_size = size;
  801a2a:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801a30:	8b 45 14             	mov    0x14(%ebp),%eax
  801a33:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801a38:	b8 08 00 00 00       	mov    $0x8,%eax
  801a3d:	e8 d9 fd ff ff       	call   80181b <nsipc>
}
  801a42:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a45:	c9                   	leave  
  801a46:	c3                   	ret    

00801a47 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a47:	55                   	push   %ebp
  801a48:	89 e5                	mov    %esp,%ebp
  801a4a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a50:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801a55:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a58:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801a5d:	8b 45 10             	mov    0x10(%ebp),%eax
  801a60:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801a65:	b8 09 00 00 00       	mov    $0x9,%eax
  801a6a:	e8 ac fd ff ff       	call   80181b <nsipc>
}
  801a6f:	c9                   	leave  
  801a70:	c3                   	ret    

00801a71 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	56                   	push   %esi
  801a75:	53                   	push   %ebx
  801a76:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a79:	83 ec 0c             	sub    $0xc,%esp
  801a7c:	ff 75 08             	pushl  0x8(%ebp)
  801a7f:	e8 98 f3 ff ff       	call   800e1c <fd2data>
  801a84:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a86:	83 c4 08             	add    $0x8,%esp
  801a89:	68 cc 27 80 00       	push   $0x8027cc
  801a8e:	53                   	push   %ebx
  801a8f:	e8 23 ed ff ff       	call   8007b7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a94:	8b 46 04             	mov    0x4(%esi),%eax
  801a97:	2b 06                	sub    (%esi),%eax
  801a99:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a9f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801aa6:	00 00 00 
	stat->st_dev = &devpipe;
  801aa9:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801ab0:	30 80 00 
	return 0;
}
  801ab3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ab8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801abb:	5b                   	pop    %ebx
  801abc:	5e                   	pop    %esi
  801abd:	5d                   	pop    %ebp
  801abe:	c3                   	ret    

00801abf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801abf:	55                   	push   %ebp
  801ac0:	89 e5                	mov    %esp,%ebp
  801ac2:	53                   	push   %ebx
  801ac3:	83 ec 0c             	sub    $0xc,%esp
  801ac6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ac9:	53                   	push   %ebx
  801aca:	6a 00                	push   $0x0
  801acc:	e8 6e f1 ff ff       	call   800c3f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ad1:	89 1c 24             	mov    %ebx,(%esp)
  801ad4:	e8 43 f3 ff ff       	call   800e1c <fd2data>
  801ad9:	83 c4 08             	add    $0x8,%esp
  801adc:	50                   	push   %eax
  801add:	6a 00                	push   $0x0
  801adf:	e8 5b f1 ff ff       	call   800c3f <sys_page_unmap>
}
  801ae4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ae7:	c9                   	leave  
  801ae8:	c3                   	ret    

00801ae9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ae9:	55                   	push   %ebp
  801aea:	89 e5                	mov    %esp,%ebp
  801aec:	57                   	push   %edi
  801aed:	56                   	push   %esi
  801aee:	53                   	push   %ebx
  801aef:	83 ec 1c             	sub    $0x1c,%esp
  801af2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801af5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801af7:	a1 08 40 80 00       	mov    0x804008,%eax
  801afc:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801aff:	83 ec 0c             	sub    $0xc,%esp
  801b02:	ff 75 e0             	pushl  -0x20(%ebp)
  801b05:	e8 3a 05 00 00       	call   802044 <pageref>
  801b0a:	89 c3                	mov    %eax,%ebx
  801b0c:	89 3c 24             	mov    %edi,(%esp)
  801b0f:	e8 30 05 00 00       	call   802044 <pageref>
  801b14:	83 c4 10             	add    $0x10,%esp
  801b17:	39 c3                	cmp    %eax,%ebx
  801b19:	0f 94 c1             	sete   %cl
  801b1c:	0f b6 c9             	movzbl %cl,%ecx
  801b1f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b22:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b28:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b2b:	39 ce                	cmp    %ecx,%esi
  801b2d:	74 1b                	je     801b4a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b2f:	39 c3                	cmp    %eax,%ebx
  801b31:	75 c4                	jne    801af7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b33:	8b 42 58             	mov    0x58(%edx),%eax
  801b36:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b39:	50                   	push   %eax
  801b3a:	56                   	push   %esi
  801b3b:	68 d3 27 80 00       	push   $0x8027d3
  801b40:	e8 ed e6 ff ff       	call   800232 <cprintf>
  801b45:	83 c4 10             	add    $0x10,%esp
  801b48:	eb ad                	jmp    801af7 <_pipeisclosed+0xe>
	}
}
  801b4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b50:	5b                   	pop    %ebx
  801b51:	5e                   	pop    %esi
  801b52:	5f                   	pop    %edi
  801b53:	5d                   	pop    %ebp
  801b54:	c3                   	ret    

00801b55 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	57                   	push   %edi
  801b59:	56                   	push   %esi
  801b5a:	53                   	push   %ebx
  801b5b:	83 ec 28             	sub    $0x28,%esp
  801b5e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b61:	56                   	push   %esi
  801b62:	e8 b5 f2 ff ff       	call   800e1c <fd2data>
  801b67:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b69:	83 c4 10             	add    $0x10,%esp
  801b6c:	bf 00 00 00 00       	mov    $0x0,%edi
  801b71:	eb 4b                	jmp    801bbe <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b73:	89 da                	mov    %ebx,%edx
  801b75:	89 f0                	mov    %esi,%eax
  801b77:	e8 6d ff ff ff       	call   801ae9 <_pipeisclosed>
  801b7c:	85 c0                	test   %eax,%eax
  801b7e:	75 48                	jne    801bc8 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b80:	e8 16 f0 ff ff       	call   800b9b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b85:	8b 43 04             	mov    0x4(%ebx),%eax
  801b88:	8b 0b                	mov    (%ebx),%ecx
  801b8a:	8d 51 20             	lea    0x20(%ecx),%edx
  801b8d:	39 d0                	cmp    %edx,%eax
  801b8f:	73 e2                	jae    801b73 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b94:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b98:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b9b:	89 c2                	mov    %eax,%edx
  801b9d:	c1 fa 1f             	sar    $0x1f,%edx
  801ba0:	89 d1                	mov    %edx,%ecx
  801ba2:	c1 e9 1b             	shr    $0x1b,%ecx
  801ba5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ba8:	83 e2 1f             	and    $0x1f,%edx
  801bab:	29 ca                	sub    %ecx,%edx
  801bad:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bb1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bb5:	83 c0 01             	add    $0x1,%eax
  801bb8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bbb:	83 c7 01             	add    $0x1,%edi
  801bbe:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bc1:	75 c2                	jne    801b85 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bc3:	8b 45 10             	mov    0x10(%ebp),%eax
  801bc6:	eb 05                	jmp    801bcd <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bc8:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bcd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd0:	5b                   	pop    %ebx
  801bd1:	5e                   	pop    %esi
  801bd2:	5f                   	pop    %edi
  801bd3:	5d                   	pop    %ebp
  801bd4:	c3                   	ret    

00801bd5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bd5:	55                   	push   %ebp
  801bd6:	89 e5                	mov    %esp,%ebp
  801bd8:	57                   	push   %edi
  801bd9:	56                   	push   %esi
  801bda:	53                   	push   %ebx
  801bdb:	83 ec 18             	sub    $0x18,%esp
  801bde:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801be1:	57                   	push   %edi
  801be2:	e8 35 f2 ff ff       	call   800e1c <fd2data>
  801be7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be9:	83 c4 10             	add    $0x10,%esp
  801bec:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bf1:	eb 3d                	jmp    801c30 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bf3:	85 db                	test   %ebx,%ebx
  801bf5:	74 04                	je     801bfb <devpipe_read+0x26>
				return i;
  801bf7:	89 d8                	mov    %ebx,%eax
  801bf9:	eb 44                	jmp    801c3f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bfb:	89 f2                	mov    %esi,%edx
  801bfd:	89 f8                	mov    %edi,%eax
  801bff:	e8 e5 fe ff ff       	call   801ae9 <_pipeisclosed>
  801c04:	85 c0                	test   %eax,%eax
  801c06:	75 32                	jne    801c3a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c08:	e8 8e ef ff ff       	call   800b9b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c0d:	8b 06                	mov    (%esi),%eax
  801c0f:	3b 46 04             	cmp    0x4(%esi),%eax
  801c12:	74 df                	je     801bf3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c14:	99                   	cltd   
  801c15:	c1 ea 1b             	shr    $0x1b,%edx
  801c18:	01 d0                	add    %edx,%eax
  801c1a:	83 e0 1f             	and    $0x1f,%eax
  801c1d:	29 d0                	sub    %edx,%eax
  801c1f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c27:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c2a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c2d:	83 c3 01             	add    $0x1,%ebx
  801c30:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c33:	75 d8                	jne    801c0d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c35:	8b 45 10             	mov    0x10(%ebp),%eax
  801c38:	eb 05                	jmp    801c3f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c3a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c42:	5b                   	pop    %ebx
  801c43:	5e                   	pop    %esi
  801c44:	5f                   	pop    %edi
  801c45:	5d                   	pop    %ebp
  801c46:	c3                   	ret    

00801c47 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c47:	55                   	push   %ebp
  801c48:	89 e5                	mov    %esp,%ebp
  801c4a:	56                   	push   %esi
  801c4b:	53                   	push   %ebx
  801c4c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c52:	50                   	push   %eax
  801c53:	e8 db f1 ff ff       	call   800e33 <fd_alloc>
  801c58:	83 c4 10             	add    $0x10,%esp
  801c5b:	89 c2                	mov    %eax,%edx
  801c5d:	85 c0                	test   %eax,%eax
  801c5f:	0f 88 2c 01 00 00    	js     801d91 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c65:	83 ec 04             	sub    $0x4,%esp
  801c68:	68 07 04 00 00       	push   $0x407
  801c6d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c70:	6a 00                	push   $0x0
  801c72:	e8 43 ef ff ff       	call   800bba <sys_page_alloc>
  801c77:	83 c4 10             	add    $0x10,%esp
  801c7a:	89 c2                	mov    %eax,%edx
  801c7c:	85 c0                	test   %eax,%eax
  801c7e:	0f 88 0d 01 00 00    	js     801d91 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c84:	83 ec 0c             	sub    $0xc,%esp
  801c87:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c8a:	50                   	push   %eax
  801c8b:	e8 a3 f1 ff ff       	call   800e33 <fd_alloc>
  801c90:	89 c3                	mov    %eax,%ebx
  801c92:	83 c4 10             	add    $0x10,%esp
  801c95:	85 c0                	test   %eax,%eax
  801c97:	0f 88 e2 00 00 00    	js     801d7f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c9d:	83 ec 04             	sub    $0x4,%esp
  801ca0:	68 07 04 00 00       	push   $0x407
  801ca5:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca8:	6a 00                	push   $0x0
  801caa:	e8 0b ef ff ff       	call   800bba <sys_page_alloc>
  801caf:	89 c3                	mov    %eax,%ebx
  801cb1:	83 c4 10             	add    $0x10,%esp
  801cb4:	85 c0                	test   %eax,%eax
  801cb6:	0f 88 c3 00 00 00    	js     801d7f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cbc:	83 ec 0c             	sub    $0xc,%esp
  801cbf:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc2:	e8 55 f1 ff ff       	call   800e1c <fd2data>
  801cc7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc9:	83 c4 0c             	add    $0xc,%esp
  801ccc:	68 07 04 00 00       	push   $0x407
  801cd1:	50                   	push   %eax
  801cd2:	6a 00                	push   $0x0
  801cd4:	e8 e1 ee ff ff       	call   800bba <sys_page_alloc>
  801cd9:	89 c3                	mov    %eax,%ebx
  801cdb:	83 c4 10             	add    $0x10,%esp
  801cde:	85 c0                	test   %eax,%eax
  801ce0:	0f 88 89 00 00 00    	js     801d6f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce6:	83 ec 0c             	sub    $0xc,%esp
  801ce9:	ff 75 f0             	pushl  -0x10(%ebp)
  801cec:	e8 2b f1 ff ff       	call   800e1c <fd2data>
  801cf1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cf8:	50                   	push   %eax
  801cf9:	6a 00                	push   $0x0
  801cfb:	56                   	push   %esi
  801cfc:	6a 00                	push   $0x0
  801cfe:	e8 fa ee ff ff       	call   800bfd <sys_page_map>
  801d03:	89 c3                	mov    %eax,%ebx
  801d05:	83 c4 20             	add    $0x20,%esp
  801d08:	85 c0                	test   %eax,%eax
  801d0a:	78 55                	js     801d61 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d0c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d15:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d21:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d2a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d2f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d36:	83 ec 0c             	sub    $0xc,%esp
  801d39:	ff 75 f4             	pushl  -0xc(%ebp)
  801d3c:	e8 cb f0 ff ff       	call   800e0c <fd2num>
  801d41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d44:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d46:	83 c4 04             	add    $0x4,%esp
  801d49:	ff 75 f0             	pushl  -0x10(%ebp)
  801d4c:	e8 bb f0 ff ff       	call   800e0c <fd2num>
  801d51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d54:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d57:	83 c4 10             	add    $0x10,%esp
  801d5a:	ba 00 00 00 00       	mov    $0x0,%edx
  801d5f:	eb 30                	jmp    801d91 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d61:	83 ec 08             	sub    $0x8,%esp
  801d64:	56                   	push   %esi
  801d65:	6a 00                	push   $0x0
  801d67:	e8 d3 ee ff ff       	call   800c3f <sys_page_unmap>
  801d6c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d6f:	83 ec 08             	sub    $0x8,%esp
  801d72:	ff 75 f0             	pushl  -0x10(%ebp)
  801d75:	6a 00                	push   $0x0
  801d77:	e8 c3 ee ff ff       	call   800c3f <sys_page_unmap>
  801d7c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d7f:	83 ec 08             	sub    $0x8,%esp
  801d82:	ff 75 f4             	pushl  -0xc(%ebp)
  801d85:	6a 00                	push   $0x0
  801d87:	e8 b3 ee ff ff       	call   800c3f <sys_page_unmap>
  801d8c:	83 c4 10             	add    $0x10,%esp
  801d8f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d91:	89 d0                	mov    %edx,%eax
  801d93:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d96:	5b                   	pop    %ebx
  801d97:	5e                   	pop    %esi
  801d98:	5d                   	pop    %ebp
  801d99:	c3                   	ret    

00801d9a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d9a:	55                   	push   %ebp
  801d9b:	89 e5                	mov    %esp,%ebp
  801d9d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801da0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da3:	50                   	push   %eax
  801da4:	ff 75 08             	pushl  0x8(%ebp)
  801da7:	e8 d6 f0 ff ff       	call   800e82 <fd_lookup>
  801dac:	83 c4 10             	add    $0x10,%esp
  801daf:	85 c0                	test   %eax,%eax
  801db1:	78 18                	js     801dcb <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801db3:	83 ec 0c             	sub    $0xc,%esp
  801db6:	ff 75 f4             	pushl  -0xc(%ebp)
  801db9:	e8 5e f0 ff ff       	call   800e1c <fd2data>
	return _pipeisclosed(fd, p);
  801dbe:	89 c2                	mov    %eax,%edx
  801dc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc3:	e8 21 fd ff ff       	call   801ae9 <_pipeisclosed>
  801dc8:	83 c4 10             	add    $0x10,%esp
}
  801dcb:	c9                   	leave  
  801dcc:	c3                   	ret    

00801dcd <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801dcd:	55                   	push   %ebp
  801dce:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801dd0:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd5:	5d                   	pop    %ebp
  801dd6:	c3                   	ret    

00801dd7 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dd7:	55                   	push   %ebp
  801dd8:	89 e5                	mov    %esp,%ebp
  801dda:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ddd:	68 eb 27 80 00       	push   $0x8027eb
  801de2:	ff 75 0c             	pushl  0xc(%ebp)
  801de5:	e8 cd e9 ff ff       	call   8007b7 <strcpy>
	return 0;
}
  801dea:	b8 00 00 00 00       	mov    $0x0,%eax
  801def:	c9                   	leave  
  801df0:	c3                   	ret    

00801df1 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801df1:	55                   	push   %ebp
  801df2:	89 e5                	mov    %esp,%ebp
  801df4:	57                   	push   %edi
  801df5:	56                   	push   %esi
  801df6:	53                   	push   %ebx
  801df7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dfd:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e02:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e08:	eb 2d                	jmp    801e37 <devcons_write+0x46>
		m = n - tot;
  801e0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e0d:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e0f:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e12:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e17:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e1a:	83 ec 04             	sub    $0x4,%esp
  801e1d:	53                   	push   %ebx
  801e1e:	03 45 0c             	add    0xc(%ebp),%eax
  801e21:	50                   	push   %eax
  801e22:	57                   	push   %edi
  801e23:	e8 21 eb ff ff       	call   800949 <memmove>
		sys_cputs(buf, m);
  801e28:	83 c4 08             	add    $0x8,%esp
  801e2b:	53                   	push   %ebx
  801e2c:	57                   	push   %edi
  801e2d:	e8 cc ec ff ff       	call   800afe <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e32:	01 de                	add    %ebx,%esi
  801e34:	83 c4 10             	add    $0x10,%esp
  801e37:	89 f0                	mov    %esi,%eax
  801e39:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e3c:	72 cc                	jb     801e0a <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e41:	5b                   	pop    %ebx
  801e42:	5e                   	pop    %esi
  801e43:	5f                   	pop    %edi
  801e44:	5d                   	pop    %ebp
  801e45:	c3                   	ret    

00801e46 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e46:	55                   	push   %ebp
  801e47:	89 e5                	mov    %esp,%ebp
  801e49:	83 ec 08             	sub    $0x8,%esp
  801e4c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e51:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e55:	74 2a                	je     801e81 <devcons_read+0x3b>
  801e57:	eb 05                	jmp    801e5e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e59:	e8 3d ed ff ff       	call   800b9b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e5e:	e8 b9 ec ff ff       	call   800b1c <sys_cgetc>
  801e63:	85 c0                	test   %eax,%eax
  801e65:	74 f2                	je     801e59 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e67:	85 c0                	test   %eax,%eax
  801e69:	78 16                	js     801e81 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e6b:	83 f8 04             	cmp    $0x4,%eax
  801e6e:	74 0c                	je     801e7c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e70:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e73:	88 02                	mov    %al,(%edx)
	return 1;
  801e75:	b8 01 00 00 00       	mov    $0x1,%eax
  801e7a:	eb 05                	jmp    801e81 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e7c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e81:	c9                   	leave  
  801e82:	c3                   	ret    

00801e83 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e83:	55                   	push   %ebp
  801e84:	89 e5                	mov    %esp,%ebp
  801e86:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e89:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e8f:	6a 01                	push   $0x1
  801e91:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e94:	50                   	push   %eax
  801e95:	e8 64 ec ff ff       	call   800afe <sys_cputs>
}
  801e9a:	83 c4 10             	add    $0x10,%esp
  801e9d:	c9                   	leave  
  801e9e:	c3                   	ret    

00801e9f <getchar>:

int
getchar(void)
{
  801e9f:	55                   	push   %ebp
  801ea0:	89 e5                	mov    %esp,%ebp
  801ea2:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ea5:	6a 01                	push   $0x1
  801ea7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eaa:	50                   	push   %eax
  801eab:	6a 00                	push   $0x0
  801ead:	e8 36 f2 ff ff       	call   8010e8 <read>
	if (r < 0)
  801eb2:	83 c4 10             	add    $0x10,%esp
  801eb5:	85 c0                	test   %eax,%eax
  801eb7:	78 0f                	js     801ec8 <getchar+0x29>
		return r;
	if (r < 1)
  801eb9:	85 c0                	test   %eax,%eax
  801ebb:	7e 06                	jle    801ec3 <getchar+0x24>
		return -E_EOF;
	return c;
  801ebd:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ec1:	eb 05                	jmp    801ec8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ec3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ec8:	c9                   	leave  
  801ec9:	c3                   	ret    

00801eca <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801eca:	55                   	push   %ebp
  801ecb:	89 e5                	mov    %esp,%ebp
  801ecd:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ed0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed3:	50                   	push   %eax
  801ed4:	ff 75 08             	pushl  0x8(%ebp)
  801ed7:	e8 a6 ef ff ff       	call   800e82 <fd_lookup>
  801edc:	83 c4 10             	add    $0x10,%esp
  801edf:	85 c0                	test   %eax,%eax
  801ee1:	78 11                	js     801ef4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ee3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee6:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801eec:	39 10                	cmp    %edx,(%eax)
  801eee:	0f 94 c0             	sete   %al
  801ef1:	0f b6 c0             	movzbl %al,%eax
}
  801ef4:	c9                   	leave  
  801ef5:	c3                   	ret    

00801ef6 <opencons>:

int
opencons(void)
{
  801ef6:	55                   	push   %ebp
  801ef7:	89 e5                	mov    %esp,%ebp
  801ef9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801efc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eff:	50                   	push   %eax
  801f00:	e8 2e ef ff ff       	call   800e33 <fd_alloc>
  801f05:	83 c4 10             	add    $0x10,%esp
		return r;
  801f08:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f0a:	85 c0                	test   %eax,%eax
  801f0c:	78 3e                	js     801f4c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f0e:	83 ec 04             	sub    $0x4,%esp
  801f11:	68 07 04 00 00       	push   $0x407
  801f16:	ff 75 f4             	pushl  -0xc(%ebp)
  801f19:	6a 00                	push   $0x0
  801f1b:	e8 9a ec ff ff       	call   800bba <sys_page_alloc>
  801f20:	83 c4 10             	add    $0x10,%esp
		return r;
  801f23:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f25:	85 c0                	test   %eax,%eax
  801f27:	78 23                	js     801f4c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f29:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f32:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f37:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f3e:	83 ec 0c             	sub    $0xc,%esp
  801f41:	50                   	push   %eax
  801f42:	e8 c5 ee ff ff       	call   800e0c <fd2num>
  801f47:	89 c2                	mov    %eax,%edx
  801f49:	83 c4 10             	add    $0x10,%esp
}
  801f4c:	89 d0                	mov    %edx,%eax
  801f4e:	c9                   	leave  
  801f4f:	c3                   	ret    

00801f50 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f50:	55                   	push   %ebp
  801f51:	89 e5                	mov    %esp,%ebp
  801f53:	56                   	push   %esi
  801f54:	53                   	push   %ebx
  801f55:	8b 75 08             	mov    0x8(%ebp),%esi
  801f58:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801f5e:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801f60:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f65:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801f68:	83 ec 0c             	sub    $0xc,%esp
  801f6b:	50                   	push   %eax
  801f6c:	e8 f9 ed ff ff       	call   800d6a <sys_ipc_recv>

	if (from_env_store != NULL)
  801f71:	83 c4 10             	add    $0x10,%esp
  801f74:	85 f6                	test   %esi,%esi
  801f76:	74 14                	je     801f8c <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801f78:	ba 00 00 00 00       	mov    $0x0,%edx
  801f7d:	85 c0                	test   %eax,%eax
  801f7f:	78 09                	js     801f8a <ipc_recv+0x3a>
  801f81:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f87:	8b 52 74             	mov    0x74(%edx),%edx
  801f8a:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801f8c:	85 db                	test   %ebx,%ebx
  801f8e:	74 14                	je     801fa4 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801f90:	ba 00 00 00 00       	mov    $0x0,%edx
  801f95:	85 c0                	test   %eax,%eax
  801f97:	78 09                	js     801fa2 <ipc_recv+0x52>
  801f99:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f9f:	8b 52 78             	mov    0x78(%edx),%edx
  801fa2:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801fa4:	85 c0                	test   %eax,%eax
  801fa6:	78 08                	js     801fb0 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801fa8:	a1 08 40 80 00       	mov    0x804008,%eax
  801fad:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fb0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fb3:	5b                   	pop    %ebx
  801fb4:	5e                   	pop    %esi
  801fb5:	5d                   	pop    %ebp
  801fb6:	c3                   	ret    

00801fb7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fb7:	55                   	push   %ebp
  801fb8:	89 e5                	mov    %esp,%ebp
  801fba:	57                   	push   %edi
  801fbb:	56                   	push   %esi
  801fbc:	53                   	push   %ebx
  801fbd:	83 ec 0c             	sub    $0xc,%esp
  801fc0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fc3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fc6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801fc9:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801fcb:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fd0:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801fd3:	ff 75 14             	pushl  0x14(%ebp)
  801fd6:	53                   	push   %ebx
  801fd7:	56                   	push   %esi
  801fd8:	57                   	push   %edi
  801fd9:	e8 69 ed ff ff       	call   800d47 <sys_ipc_try_send>

		if (err < 0) {
  801fde:	83 c4 10             	add    $0x10,%esp
  801fe1:	85 c0                	test   %eax,%eax
  801fe3:	79 1e                	jns    802003 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801fe5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fe8:	75 07                	jne    801ff1 <ipc_send+0x3a>
				sys_yield();
  801fea:	e8 ac eb ff ff       	call   800b9b <sys_yield>
  801fef:	eb e2                	jmp    801fd3 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801ff1:	50                   	push   %eax
  801ff2:	68 f7 27 80 00       	push   $0x8027f7
  801ff7:	6a 49                	push   $0x49
  801ff9:	68 04 28 80 00       	push   $0x802804
  801ffe:	e8 56 e1 ff ff       	call   800159 <_panic>
		}

	} while (err < 0);

}
  802003:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802006:	5b                   	pop    %ebx
  802007:	5e                   	pop    %esi
  802008:	5f                   	pop    %edi
  802009:	5d                   	pop    %ebp
  80200a:	c3                   	ret    

0080200b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80200b:	55                   	push   %ebp
  80200c:	89 e5                	mov    %esp,%ebp
  80200e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802011:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802016:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802019:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80201f:	8b 52 50             	mov    0x50(%edx),%edx
  802022:	39 ca                	cmp    %ecx,%edx
  802024:	75 0d                	jne    802033 <ipc_find_env+0x28>
			return envs[i].env_id;
  802026:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802029:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80202e:	8b 40 48             	mov    0x48(%eax),%eax
  802031:	eb 0f                	jmp    802042 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802033:	83 c0 01             	add    $0x1,%eax
  802036:	3d 00 04 00 00       	cmp    $0x400,%eax
  80203b:	75 d9                	jne    802016 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80203d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802042:	5d                   	pop    %ebp
  802043:	c3                   	ret    

00802044 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802044:	55                   	push   %ebp
  802045:	89 e5                	mov    %esp,%ebp
  802047:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80204a:	89 d0                	mov    %edx,%eax
  80204c:	c1 e8 16             	shr    $0x16,%eax
  80204f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802056:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80205b:	f6 c1 01             	test   $0x1,%cl
  80205e:	74 1d                	je     80207d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802060:	c1 ea 0c             	shr    $0xc,%edx
  802063:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80206a:	f6 c2 01             	test   $0x1,%dl
  80206d:	74 0e                	je     80207d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80206f:	c1 ea 0c             	shr    $0xc,%edx
  802072:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802079:	ef 
  80207a:	0f b7 c0             	movzwl %ax,%eax
}
  80207d:	5d                   	pop    %ebp
  80207e:	c3                   	ret    
  80207f:	90                   	nop

00802080 <__udivdi3>:
  802080:	55                   	push   %ebp
  802081:	57                   	push   %edi
  802082:	56                   	push   %esi
  802083:	53                   	push   %ebx
  802084:	83 ec 1c             	sub    $0x1c,%esp
  802087:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80208b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80208f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802093:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802097:	85 f6                	test   %esi,%esi
  802099:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80209d:	89 ca                	mov    %ecx,%edx
  80209f:	89 f8                	mov    %edi,%eax
  8020a1:	75 3d                	jne    8020e0 <__udivdi3+0x60>
  8020a3:	39 cf                	cmp    %ecx,%edi
  8020a5:	0f 87 c5 00 00 00    	ja     802170 <__udivdi3+0xf0>
  8020ab:	85 ff                	test   %edi,%edi
  8020ad:	89 fd                	mov    %edi,%ebp
  8020af:	75 0b                	jne    8020bc <__udivdi3+0x3c>
  8020b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b6:	31 d2                	xor    %edx,%edx
  8020b8:	f7 f7                	div    %edi
  8020ba:	89 c5                	mov    %eax,%ebp
  8020bc:	89 c8                	mov    %ecx,%eax
  8020be:	31 d2                	xor    %edx,%edx
  8020c0:	f7 f5                	div    %ebp
  8020c2:	89 c1                	mov    %eax,%ecx
  8020c4:	89 d8                	mov    %ebx,%eax
  8020c6:	89 cf                	mov    %ecx,%edi
  8020c8:	f7 f5                	div    %ebp
  8020ca:	89 c3                	mov    %eax,%ebx
  8020cc:	89 d8                	mov    %ebx,%eax
  8020ce:	89 fa                	mov    %edi,%edx
  8020d0:	83 c4 1c             	add    $0x1c,%esp
  8020d3:	5b                   	pop    %ebx
  8020d4:	5e                   	pop    %esi
  8020d5:	5f                   	pop    %edi
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    
  8020d8:	90                   	nop
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	39 ce                	cmp    %ecx,%esi
  8020e2:	77 74                	ja     802158 <__udivdi3+0xd8>
  8020e4:	0f bd fe             	bsr    %esi,%edi
  8020e7:	83 f7 1f             	xor    $0x1f,%edi
  8020ea:	0f 84 98 00 00 00    	je     802188 <__udivdi3+0x108>
  8020f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020f5:	89 f9                	mov    %edi,%ecx
  8020f7:	89 c5                	mov    %eax,%ebp
  8020f9:	29 fb                	sub    %edi,%ebx
  8020fb:	d3 e6                	shl    %cl,%esi
  8020fd:	89 d9                	mov    %ebx,%ecx
  8020ff:	d3 ed                	shr    %cl,%ebp
  802101:	89 f9                	mov    %edi,%ecx
  802103:	d3 e0                	shl    %cl,%eax
  802105:	09 ee                	or     %ebp,%esi
  802107:	89 d9                	mov    %ebx,%ecx
  802109:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80210d:	89 d5                	mov    %edx,%ebp
  80210f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802113:	d3 ed                	shr    %cl,%ebp
  802115:	89 f9                	mov    %edi,%ecx
  802117:	d3 e2                	shl    %cl,%edx
  802119:	89 d9                	mov    %ebx,%ecx
  80211b:	d3 e8                	shr    %cl,%eax
  80211d:	09 c2                	or     %eax,%edx
  80211f:	89 d0                	mov    %edx,%eax
  802121:	89 ea                	mov    %ebp,%edx
  802123:	f7 f6                	div    %esi
  802125:	89 d5                	mov    %edx,%ebp
  802127:	89 c3                	mov    %eax,%ebx
  802129:	f7 64 24 0c          	mull   0xc(%esp)
  80212d:	39 d5                	cmp    %edx,%ebp
  80212f:	72 10                	jb     802141 <__udivdi3+0xc1>
  802131:	8b 74 24 08          	mov    0x8(%esp),%esi
  802135:	89 f9                	mov    %edi,%ecx
  802137:	d3 e6                	shl    %cl,%esi
  802139:	39 c6                	cmp    %eax,%esi
  80213b:	73 07                	jae    802144 <__udivdi3+0xc4>
  80213d:	39 d5                	cmp    %edx,%ebp
  80213f:	75 03                	jne    802144 <__udivdi3+0xc4>
  802141:	83 eb 01             	sub    $0x1,%ebx
  802144:	31 ff                	xor    %edi,%edi
  802146:	89 d8                	mov    %ebx,%eax
  802148:	89 fa                	mov    %edi,%edx
  80214a:	83 c4 1c             	add    $0x1c,%esp
  80214d:	5b                   	pop    %ebx
  80214e:	5e                   	pop    %esi
  80214f:	5f                   	pop    %edi
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    
  802152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802158:	31 ff                	xor    %edi,%edi
  80215a:	31 db                	xor    %ebx,%ebx
  80215c:	89 d8                	mov    %ebx,%eax
  80215e:	89 fa                	mov    %edi,%edx
  802160:	83 c4 1c             	add    $0x1c,%esp
  802163:	5b                   	pop    %ebx
  802164:	5e                   	pop    %esi
  802165:	5f                   	pop    %edi
  802166:	5d                   	pop    %ebp
  802167:	c3                   	ret    
  802168:	90                   	nop
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	89 d8                	mov    %ebx,%eax
  802172:	f7 f7                	div    %edi
  802174:	31 ff                	xor    %edi,%edi
  802176:	89 c3                	mov    %eax,%ebx
  802178:	89 d8                	mov    %ebx,%eax
  80217a:	89 fa                	mov    %edi,%edx
  80217c:	83 c4 1c             	add    $0x1c,%esp
  80217f:	5b                   	pop    %ebx
  802180:	5e                   	pop    %esi
  802181:	5f                   	pop    %edi
  802182:	5d                   	pop    %ebp
  802183:	c3                   	ret    
  802184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802188:	39 ce                	cmp    %ecx,%esi
  80218a:	72 0c                	jb     802198 <__udivdi3+0x118>
  80218c:	31 db                	xor    %ebx,%ebx
  80218e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802192:	0f 87 34 ff ff ff    	ja     8020cc <__udivdi3+0x4c>
  802198:	bb 01 00 00 00       	mov    $0x1,%ebx
  80219d:	e9 2a ff ff ff       	jmp    8020cc <__udivdi3+0x4c>
  8021a2:	66 90                	xchg   %ax,%ax
  8021a4:	66 90                	xchg   %ax,%ax
  8021a6:	66 90                	xchg   %ax,%ax
  8021a8:	66 90                	xchg   %ax,%ax
  8021aa:	66 90                	xchg   %ax,%ax
  8021ac:	66 90                	xchg   %ax,%ax
  8021ae:	66 90                	xchg   %ax,%ax

008021b0 <__umoddi3>:
  8021b0:	55                   	push   %ebp
  8021b1:	57                   	push   %edi
  8021b2:	56                   	push   %esi
  8021b3:	53                   	push   %ebx
  8021b4:	83 ec 1c             	sub    $0x1c,%esp
  8021b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021c7:	85 d2                	test   %edx,%edx
  8021c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021d1:	89 f3                	mov    %esi,%ebx
  8021d3:	89 3c 24             	mov    %edi,(%esp)
  8021d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021da:	75 1c                	jne    8021f8 <__umoddi3+0x48>
  8021dc:	39 f7                	cmp    %esi,%edi
  8021de:	76 50                	jbe    802230 <__umoddi3+0x80>
  8021e0:	89 c8                	mov    %ecx,%eax
  8021e2:	89 f2                	mov    %esi,%edx
  8021e4:	f7 f7                	div    %edi
  8021e6:	89 d0                	mov    %edx,%eax
  8021e8:	31 d2                	xor    %edx,%edx
  8021ea:	83 c4 1c             	add    $0x1c,%esp
  8021ed:	5b                   	pop    %ebx
  8021ee:	5e                   	pop    %esi
  8021ef:	5f                   	pop    %edi
  8021f0:	5d                   	pop    %ebp
  8021f1:	c3                   	ret    
  8021f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021f8:	39 f2                	cmp    %esi,%edx
  8021fa:	89 d0                	mov    %edx,%eax
  8021fc:	77 52                	ja     802250 <__umoddi3+0xa0>
  8021fe:	0f bd ea             	bsr    %edx,%ebp
  802201:	83 f5 1f             	xor    $0x1f,%ebp
  802204:	75 5a                	jne    802260 <__umoddi3+0xb0>
  802206:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80220a:	0f 82 e0 00 00 00    	jb     8022f0 <__umoddi3+0x140>
  802210:	39 0c 24             	cmp    %ecx,(%esp)
  802213:	0f 86 d7 00 00 00    	jbe    8022f0 <__umoddi3+0x140>
  802219:	8b 44 24 08          	mov    0x8(%esp),%eax
  80221d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802221:	83 c4 1c             	add    $0x1c,%esp
  802224:	5b                   	pop    %ebx
  802225:	5e                   	pop    %esi
  802226:	5f                   	pop    %edi
  802227:	5d                   	pop    %ebp
  802228:	c3                   	ret    
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	85 ff                	test   %edi,%edi
  802232:	89 fd                	mov    %edi,%ebp
  802234:	75 0b                	jne    802241 <__umoddi3+0x91>
  802236:	b8 01 00 00 00       	mov    $0x1,%eax
  80223b:	31 d2                	xor    %edx,%edx
  80223d:	f7 f7                	div    %edi
  80223f:	89 c5                	mov    %eax,%ebp
  802241:	89 f0                	mov    %esi,%eax
  802243:	31 d2                	xor    %edx,%edx
  802245:	f7 f5                	div    %ebp
  802247:	89 c8                	mov    %ecx,%eax
  802249:	f7 f5                	div    %ebp
  80224b:	89 d0                	mov    %edx,%eax
  80224d:	eb 99                	jmp    8021e8 <__umoddi3+0x38>
  80224f:	90                   	nop
  802250:	89 c8                	mov    %ecx,%eax
  802252:	89 f2                	mov    %esi,%edx
  802254:	83 c4 1c             	add    $0x1c,%esp
  802257:	5b                   	pop    %ebx
  802258:	5e                   	pop    %esi
  802259:	5f                   	pop    %edi
  80225a:	5d                   	pop    %ebp
  80225b:	c3                   	ret    
  80225c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802260:	8b 34 24             	mov    (%esp),%esi
  802263:	bf 20 00 00 00       	mov    $0x20,%edi
  802268:	89 e9                	mov    %ebp,%ecx
  80226a:	29 ef                	sub    %ebp,%edi
  80226c:	d3 e0                	shl    %cl,%eax
  80226e:	89 f9                	mov    %edi,%ecx
  802270:	89 f2                	mov    %esi,%edx
  802272:	d3 ea                	shr    %cl,%edx
  802274:	89 e9                	mov    %ebp,%ecx
  802276:	09 c2                	or     %eax,%edx
  802278:	89 d8                	mov    %ebx,%eax
  80227a:	89 14 24             	mov    %edx,(%esp)
  80227d:	89 f2                	mov    %esi,%edx
  80227f:	d3 e2                	shl    %cl,%edx
  802281:	89 f9                	mov    %edi,%ecx
  802283:	89 54 24 04          	mov    %edx,0x4(%esp)
  802287:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80228b:	d3 e8                	shr    %cl,%eax
  80228d:	89 e9                	mov    %ebp,%ecx
  80228f:	89 c6                	mov    %eax,%esi
  802291:	d3 e3                	shl    %cl,%ebx
  802293:	89 f9                	mov    %edi,%ecx
  802295:	89 d0                	mov    %edx,%eax
  802297:	d3 e8                	shr    %cl,%eax
  802299:	89 e9                	mov    %ebp,%ecx
  80229b:	09 d8                	or     %ebx,%eax
  80229d:	89 d3                	mov    %edx,%ebx
  80229f:	89 f2                	mov    %esi,%edx
  8022a1:	f7 34 24             	divl   (%esp)
  8022a4:	89 d6                	mov    %edx,%esi
  8022a6:	d3 e3                	shl    %cl,%ebx
  8022a8:	f7 64 24 04          	mull   0x4(%esp)
  8022ac:	39 d6                	cmp    %edx,%esi
  8022ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022b2:	89 d1                	mov    %edx,%ecx
  8022b4:	89 c3                	mov    %eax,%ebx
  8022b6:	72 08                	jb     8022c0 <__umoddi3+0x110>
  8022b8:	75 11                	jne    8022cb <__umoddi3+0x11b>
  8022ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022be:	73 0b                	jae    8022cb <__umoddi3+0x11b>
  8022c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022c4:	1b 14 24             	sbb    (%esp),%edx
  8022c7:	89 d1                	mov    %edx,%ecx
  8022c9:	89 c3                	mov    %eax,%ebx
  8022cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022cf:	29 da                	sub    %ebx,%edx
  8022d1:	19 ce                	sbb    %ecx,%esi
  8022d3:	89 f9                	mov    %edi,%ecx
  8022d5:	89 f0                	mov    %esi,%eax
  8022d7:	d3 e0                	shl    %cl,%eax
  8022d9:	89 e9                	mov    %ebp,%ecx
  8022db:	d3 ea                	shr    %cl,%edx
  8022dd:	89 e9                	mov    %ebp,%ecx
  8022df:	d3 ee                	shr    %cl,%esi
  8022e1:	09 d0                	or     %edx,%eax
  8022e3:	89 f2                	mov    %esi,%edx
  8022e5:	83 c4 1c             	add    $0x1c,%esp
  8022e8:	5b                   	pop    %ebx
  8022e9:	5e                   	pop    %esi
  8022ea:	5f                   	pop    %edi
  8022eb:	5d                   	pop    %ebp
  8022ec:	c3                   	ret    
  8022ed:	8d 76 00             	lea    0x0(%esi),%esi
  8022f0:	29 f9                	sub    %edi,%ecx
  8022f2:	19 d6                	sbb    %edx,%esi
  8022f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022fc:	e9 18 ff ff ff       	jmp    802219 <__umoddi3+0x69>
