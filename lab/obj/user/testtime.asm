
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
  800057:	68 e0 22 80 00       	push   $0x8022e0
  80005c:	6a 0b                	push   $0xb
  80005e:	68 f2 22 80 00       	push   $0x8022f2
  800063:	e8 f1 00 00 00       	call   800159 <_panic>
	if (end < now)
  800068:	39 d8                	cmp    %ebx,%eax
  80006a:	76 19                	jbe    800085 <sleep+0x52>
		panic("sleep: wrap");
  80006c:	83 ec 04             	sub    $0x4,%esp
  80006f:	68 02 23 80 00       	push   $0x802302
  800074:	6a 0d                	push   $0xd
  800076:	68 f2 22 80 00       	push   $0x8022f2
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
  8000ac:	68 0e 23 80 00       	push   $0x80230e
  8000b1:	e8 7c 01 00 00       	call   800232 <cprintf>
  8000b6:	83 c4 10             	add    $0x10,%esp
	for (i = 5; i >= 0; i--) {
  8000b9:	bb 05 00 00 00       	mov    $0x5,%ebx
		cprintf("%d ", i);
  8000be:	83 ec 08             	sub    $0x8,%esp
  8000c1:	53                   	push   %ebx
  8000c2:	68 24 23 80 00       	push   $0x802324
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
  8000e6:	68 a4 27 80 00       	push   $0x8027a4
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
  800145:	e8 4b 0e 00 00       	call   800f95 <close_all>
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
  800177:	68 34 23 80 00       	push   $0x802334
  80017c:	e8 b1 00 00 00       	call   800232 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800181:	83 c4 18             	add    $0x18,%esp
  800184:	53                   	push   %ebx
  800185:	ff 75 10             	pushl  0x10(%ebp)
  800188:	e8 54 00 00 00       	call   8001e1 <vcprintf>
	cprintf("\n");
  80018d:	c7 04 24 a4 27 80 00 	movl   $0x8027a4,(%esp)
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
  800295:	e8 a6 1d 00 00       	call   802040 <__udivdi3>
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
  8002d8:	e8 93 1e 00 00       	call   802170 <__umoddi3>
  8002dd:	83 c4 14             	add    $0x14,%esp
  8002e0:	0f be 80 57 23 80 00 	movsbl 0x802357(%eax),%eax
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
  8003dc:	ff 24 85 a0 24 80 00 	jmp    *0x8024a0(,%eax,4)
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
  8004a0:	8b 14 85 00 26 80 00 	mov    0x802600(,%eax,4),%edx
  8004a7:	85 d2                	test   %edx,%edx
  8004a9:	75 18                	jne    8004c3 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004ab:	50                   	push   %eax
  8004ac:	68 6f 23 80 00       	push   $0x80236f
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
  8004c4:	68 39 27 80 00       	push   $0x802739
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
  8004e8:	b8 68 23 80 00       	mov    $0x802368,%eax
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
  800b63:	68 5f 26 80 00       	push   $0x80265f
  800b68:	6a 23                	push   $0x23
  800b6a:	68 7c 26 80 00       	push   $0x80267c
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
  800be4:	68 5f 26 80 00       	push   $0x80265f
  800be9:	6a 23                	push   $0x23
  800beb:	68 7c 26 80 00       	push   $0x80267c
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
  800c26:	68 5f 26 80 00       	push   $0x80265f
  800c2b:	6a 23                	push   $0x23
  800c2d:	68 7c 26 80 00       	push   $0x80267c
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
  800c68:	68 5f 26 80 00       	push   $0x80265f
  800c6d:	6a 23                	push   $0x23
  800c6f:	68 7c 26 80 00       	push   $0x80267c
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
  800caa:	68 5f 26 80 00       	push   $0x80265f
  800caf:	6a 23                	push   $0x23
  800cb1:	68 7c 26 80 00       	push   $0x80267c
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
  800cec:	68 5f 26 80 00       	push   $0x80265f
  800cf1:	6a 23                	push   $0x23
  800cf3:	68 7c 26 80 00       	push   $0x80267c
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
  800d2e:	68 5f 26 80 00       	push   $0x80265f
  800d33:	6a 23                	push   $0x23
  800d35:	68 7c 26 80 00       	push   $0x80267c
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
  800d92:	68 5f 26 80 00       	push   $0x80265f
  800d97:	6a 23                	push   $0x23
  800d99:	68 7c 26 80 00       	push   $0x80267c
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

00800dca <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dcd:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd0:	05 00 00 00 30       	add    $0x30000000,%eax
  800dd5:	c1 e8 0c             	shr    $0xc,%eax
}
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ddd:	8b 45 08             	mov    0x8(%ebp),%eax
  800de0:	05 00 00 00 30       	add    $0x30000000,%eax
  800de5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dea:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800def:	5d                   	pop    %ebp
  800df0:	c3                   	ret    

00800df1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
  800df4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dfc:	89 c2                	mov    %eax,%edx
  800dfe:	c1 ea 16             	shr    $0x16,%edx
  800e01:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e08:	f6 c2 01             	test   $0x1,%dl
  800e0b:	74 11                	je     800e1e <fd_alloc+0x2d>
  800e0d:	89 c2                	mov    %eax,%edx
  800e0f:	c1 ea 0c             	shr    $0xc,%edx
  800e12:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e19:	f6 c2 01             	test   $0x1,%dl
  800e1c:	75 09                	jne    800e27 <fd_alloc+0x36>
			*fd_store = fd;
  800e1e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e20:	b8 00 00 00 00       	mov    $0x0,%eax
  800e25:	eb 17                	jmp    800e3e <fd_alloc+0x4d>
  800e27:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e2c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e31:	75 c9                	jne    800dfc <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e33:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e39:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e3e:	5d                   	pop    %ebp
  800e3f:	c3                   	ret    

00800e40 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e46:	83 f8 1f             	cmp    $0x1f,%eax
  800e49:	77 36                	ja     800e81 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e4b:	c1 e0 0c             	shl    $0xc,%eax
  800e4e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e53:	89 c2                	mov    %eax,%edx
  800e55:	c1 ea 16             	shr    $0x16,%edx
  800e58:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e5f:	f6 c2 01             	test   $0x1,%dl
  800e62:	74 24                	je     800e88 <fd_lookup+0x48>
  800e64:	89 c2                	mov    %eax,%edx
  800e66:	c1 ea 0c             	shr    $0xc,%edx
  800e69:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e70:	f6 c2 01             	test   $0x1,%dl
  800e73:	74 1a                	je     800e8f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e75:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e78:	89 02                	mov    %eax,(%edx)
	return 0;
  800e7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7f:	eb 13                	jmp    800e94 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e81:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e86:	eb 0c                	jmp    800e94 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e88:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e8d:	eb 05                	jmp    800e94 <fd_lookup+0x54>
  800e8f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	83 ec 08             	sub    $0x8,%esp
  800e9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e9f:	ba 0c 27 80 00       	mov    $0x80270c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ea4:	eb 13                	jmp    800eb9 <dev_lookup+0x23>
  800ea6:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ea9:	39 08                	cmp    %ecx,(%eax)
  800eab:	75 0c                	jne    800eb9 <dev_lookup+0x23>
			*dev = devtab[i];
  800ead:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb0:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb7:	eb 2e                	jmp    800ee7 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800eb9:	8b 02                	mov    (%edx),%eax
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	75 e7                	jne    800ea6 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ebf:	a1 08 40 80 00       	mov    0x804008,%eax
  800ec4:	8b 40 48             	mov    0x48(%eax),%eax
  800ec7:	83 ec 04             	sub    $0x4,%esp
  800eca:	51                   	push   %ecx
  800ecb:	50                   	push   %eax
  800ecc:	68 8c 26 80 00       	push   $0x80268c
  800ed1:	e8 5c f3 ff ff       	call   800232 <cprintf>
	*dev = 0;
  800ed6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800edf:	83 c4 10             	add    $0x10,%esp
  800ee2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ee7:	c9                   	leave  
  800ee8:	c3                   	ret    

00800ee9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	56                   	push   %esi
  800eed:	53                   	push   %ebx
  800eee:	83 ec 10             	sub    $0x10,%esp
  800ef1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ef4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ef7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800efa:	50                   	push   %eax
  800efb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f01:	c1 e8 0c             	shr    $0xc,%eax
  800f04:	50                   	push   %eax
  800f05:	e8 36 ff ff ff       	call   800e40 <fd_lookup>
  800f0a:	83 c4 08             	add    $0x8,%esp
  800f0d:	85 c0                	test   %eax,%eax
  800f0f:	78 05                	js     800f16 <fd_close+0x2d>
	    || fd != fd2)
  800f11:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f14:	74 0c                	je     800f22 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f16:	84 db                	test   %bl,%bl
  800f18:	ba 00 00 00 00       	mov    $0x0,%edx
  800f1d:	0f 44 c2             	cmove  %edx,%eax
  800f20:	eb 41                	jmp    800f63 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f22:	83 ec 08             	sub    $0x8,%esp
  800f25:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f28:	50                   	push   %eax
  800f29:	ff 36                	pushl  (%esi)
  800f2b:	e8 66 ff ff ff       	call   800e96 <dev_lookup>
  800f30:	89 c3                	mov    %eax,%ebx
  800f32:	83 c4 10             	add    $0x10,%esp
  800f35:	85 c0                	test   %eax,%eax
  800f37:	78 1a                	js     800f53 <fd_close+0x6a>
		if (dev->dev_close)
  800f39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f3c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f3f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f44:	85 c0                	test   %eax,%eax
  800f46:	74 0b                	je     800f53 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f48:	83 ec 0c             	sub    $0xc,%esp
  800f4b:	56                   	push   %esi
  800f4c:	ff d0                	call   *%eax
  800f4e:	89 c3                	mov    %eax,%ebx
  800f50:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f53:	83 ec 08             	sub    $0x8,%esp
  800f56:	56                   	push   %esi
  800f57:	6a 00                	push   $0x0
  800f59:	e8 e1 fc ff ff       	call   800c3f <sys_page_unmap>
	return r;
  800f5e:	83 c4 10             	add    $0x10,%esp
  800f61:	89 d8                	mov    %ebx,%eax
}
  800f63:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f66:	5b                   	pop    %ebx
  800f67:	5e                   	pop    %esi
  800f68:	5d                   	pop    %ebp
  800f69:	c3                   	ret    

00800f6a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f73:	50                   	push   %eax
  800f74:	ff 75 08             	pushl  0x8(%ebp)
  800f77:	e8 c4 fe ff ff       	call   800e40 <fd_lookup>
  800f7c:	83 c4 08             	add    $0x8,%esp
  800f7f:	85 c0                	test   %eax,%eax
  800f81:	78 10                	js     800f93 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f83:	83 ec 08             	sub    $0x8,%esp
  800f86:	6a 01                	push   $0x1
  800f88:	ff 75 f4             	pushl  -0xc(%ebp)
  800f8b:	e8 59 ff ff ff       	call   800ee9 <fd_close>
  800f90:	83 c4 10             	add    $0x10,%esp
}
  800f93:	c9                   	leave  
  800f94:	c3                   	ret    

00800f95 <close_all>:

void
close_all(void)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	53                   	push   %ebx
  800f99:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f9c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fa1:	83 ec 0c             	sub    $0xc,%esp
  800fa4:	53                   	push   %ebx
  800fa5:	e8 c0 ff ff ff       	call   800f6a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800faa:	83 c3 01             	add    $0x1,%ebx
  800fad:	83 c4 10             	add    $0x10,%esp
  800fb0:	83 fb 20             	cmp    $0x20,%ebx
  800fb3:	75 ec                	jne    800fa1 <close_all+0xc>
		close(i);
}
  800fb5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb8:	c9                   	leave  
  800fb9:	c3                   	ret    

00800fba <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	57                   	push   %edi
  800fbe:	56                   	push   %esi
  800fbf:	53                   	push   %ebx
  800fc0:	83 ec 2c             	sub    $0x2c,%esp
  800fc3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fc6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fc9:	50                   	push   %eax
  800fca:	ff 75 08             	pushl  0x8(%ebp)
  800fcd:	e8 6e fe ff ff       	call   800e40 <fd_lookup>
  800fd2:	83 c4 08             	add    $0x8,%esp
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	0f 88 c1 00 00 00    	js     80109e <dup+0xe4>
		return r;
	close(newfdnum);
  800fdd:	83 ec 0c             	sub    $0xc,%esp
  800fe0:	56                   	push   %esi
  800fe1:	e8 84 ff ff ff       	call   800f6a <close>

	newfd = INDEX2FD(newfdnum);
  800fe6:	89 f3                	mov    %esi,%ebx
  800fe8:	c1 e3 0c             	shl    $0xc,%ebx
  800feb:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800ff1:	83 c4 04             	add    $0x4,%esp
  800ff4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ff7:	e8 de fd ff ff       	call   800dda <fd2data>
  800ffc:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800ffe:	89 1c 24             	mov    %ebx,(%esp)
  801001:	e8 d4 fd ff ff       	call   800dda <fd2data>
  801006:	83 c4 10             	add    $0x10,%esp
  801009:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80100c:	89 f8                	mov    %edi,%eax
  80100e:	c1 e8 16             	shr    $0x16,%eax
  801011:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801018:	a8 01                	test   $0x1,%al
  80101a:	74 37                	je     801053 <dup+0x99>
  80101c:	89 f8                	mov    %edi,%eax
  80101e:	c1 e8 0c             	shr    $0xc,%eax
  801021:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801028:	f6 c2 01             	test   $0x1,%dl
  80102b:	74 26                	je     801053 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80102d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801034:	83 ec 0c             	sub    $0xc,%esp
  801037:	25 07 0e 00 00       	and    $0xe07,%eax
  80103c:	50                   	push   %eax
  80103d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801040:	6a 00                	push   $0x0
  801042:	57                   	push   %edi
  801043:	6a 00                	push   $0x0
  801045:	e8 b3 fb ff ff       	call   800bfd <sys_page_map>
  80104a:	89 c7                	mov    %eax,%edi
  80104c:	83 c4 20             	add    $0x20,%esp
  80104f:	85 c0                	test   %eax,%eax
  801051:	78 2e                	js     801081 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801053:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801056:	89 d0                	mov    %edx,%eax
  801058:	c1 e8 0c             	shr    $0xc,%eax
  80105b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801062:	83 ec 0c             	sub    $0xc,%esp
  801065:	25 07 0e 00 00       	and    $0xe07,%eax
  80106a:	50                   	push   %eax
  80106b:	53                   	push   %ebx
  80106c:	6a 00                	push   $0x0
  80106e:	52                   	push   %edx
  80106f:	6a 00                	push   $0x0
  801071:	e8 87 fb ff ff       	call   800bfd <sys_page_map>
  801076:	89 c7                	mov    %eax,%edi
  801078:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80107b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80107d:	85 ff                	test   %edi,%edi
  80107f:	79 1d                	jns    80109e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801081:	83 ec 08             	sub    $0x8,%esp
  801084:	53                   	push   %ebx
  801085:	6a 00                	push   $0x0
  801087:	e8 b3 fb ff ff       	call   800c3f <sys_page_unmap>
	sys_page_unmap(0, nva);
  80108c:	83 c4 08             	add    $0x8,%esp
  80108f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801092:	6a 00                	push   $0x0
  801094:	e8 a6 fb ff ff       	call   800c3f <sys_page_unmap>
	return r;
  801099:	83 c4 10             	add    $0x10,%esp
  80109c:	89 f8                	mov    %edi,%eax
}
  80109e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a1:	5b                   	pop    %ebx
  8010a2:	5e                   	pop    %esi
  8010a3:	5f                   	pop    %edi
  8010a4:	5d                   	pop    %ebp
  8010a5:	c3                   	ret    

008010a6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	53                   	push   %ebx
  8010aa:	83 ec 14             	sub    $0x14,%esp
  8010ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010b3:	50                   	push   %eax
  8010b4:	53                   	push   %ebx
  8010b5:	e8 86 fd ff ff       	call   800e40 <fd_lookup>
  8010ba:	83 c4 08             	add    $0x8,%esp
  8010bd:	89 c2                	mov    %eax,%edx
  8010bf:	85 c0                	test   %eax,%eax
  8010c1:	78 6d                	js     801130 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010c3:	83 ec 08             	sub    $0x8,%esp
  8010c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c9:	50                   	push   %eax
  8010ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010cd:	ff 30                	pushl  (%eax)
  8010cf:	e8 c2 fd ff ff       	call   800e96 <dev_lookup>
  8010d4:	83 c4 10             	add    $0x10,%esp
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	78 4c                	js     801127 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010db:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010de:	8b 42 08             	mov    0x8(%edx),%eax
  8010e1:	83 e0 03             	and    $0x3,%eax
  8010e4:	83 f8 01             	cmp    $0x1,%eax
  8010e7:	75 21                	jne    80110a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010e9:	a1 08 40 80 00       	mov    0x804008,%eax
  8010ee:	8b 40 48             	mov    0x48(%eax),%eax
  8010f1:	83 ec 04             	sub    $0x4,%esp
  8010f4:	53                   	push   %ebx
  8010f5:	50                   	push   %eax
  8010f6:	68 d0 26 80 00       	push   $0x8026d0
  8010fb:	e8 32 f1 ff ff       	call   800232 <cprintf>
		return -E_INVAL;
  801100:	83 c4 10             	add    $0x10,%esp
  801103:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801108:	eb 26                	jmp    801130 <read+0x8a>
	}
	if (!dev->dev_read)
  80110a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80110d:	8b 40 08             	mov    0x8(%eax),%eax
  801110:	85 c0                	test   %eax,%eax
  801112:	74 17                	je     80112b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801114:	83 ec 04             	sub    $0x4,%esp
  801117:	ff 75 10             	pushl  0x10(%ebp)
  80111a:	ff 75 0c             	pushl  0xc(%ebp)
  80111d:	52                   	push   %edx
  80111e:	ff d0                	call   *%eax
  801120:	89 c2                	mov    %eax,%edx
  801122:	83 c4 10             	add    $0x10,%esp
  801125:	eb 09                	jmp    801130 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801127:	89 c2                	mov    %eax,%edx
  801129:	eb 05                	jmp    801130 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80112b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801130:	89 d0                	mov    %edx,%eax
  801132:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801135:	c9                   	leave  
  801136:	c3                   	ret    

00801137 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	57                   	push   %edi
  80113b:	56                   	push   %esi
  80113c:	53                   	push   %ebx
  80113d:	83 ec 0c             	sub    $0xc,%esp
  801140:	8b 7d 08             	mov    0x8(%ebp),%edi
  801143:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801146:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114b:	eb 21                	jmp    80116e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80114d:	83 ec 04             	sub    $0x4,%esp
  801150:	89 f0                	mov    %esi,%eax
  801152:	29 d8                	sub    %ebx,%eax
  801154:	50                   	push   %eax
  801155:	89 d8                	mov    %ebx,%eax
  801157:	03 45 0c             	add    0xc(%ebp),%eax
  80115a:	50                   	push   %eax
  80115b:	57                   	push   %edi
  80115c:	e8 45 ff ff ff       	call   8010a6 <read>
		if (m < 0)
  801161:	83 c4 10             	add    $0x10,%esp
  801164:	85 c0                	test   %eax,%eax
  801166:	78 10                	js     801178 <readn+0x41>
			return m;
		if (m == 0)
  801168:	85 c0                	test   %eax,%eax
  80116a:	74 0a                	je     801176 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80116c:	01 c3                	add    %eax,%ebx
  80116e:	39 f3                	cmp    %esi,%ebx
  801170:	72 db                	jb     80114d <readn+0x16>
  801172:	89 d8                	mov    %ebx,%eax
  801174:	eb 02                	jmp    801178 <readn+0x41>
  801176:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801178:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117b:	5b                   	pop    %ebx
  80117c:	5e                   	pop    %esi
  80117d:	5f                   	pop    %edi
  80117e:	5d                   	pop    %ebp
  80117f:	c3                   	ret    

00801180 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	53                   	push   %ebx
  801184:	83 ec 14             	sub    $0x14,%esp
  801187:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80118a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80118d:	50                   	push   %eax
  80118e:	53                   	push   %ebx
  80118f:	e8 ac fc ff ff       	call   800e40 <fd_lookup>
  801194:	83 c4 08             	add    $0x8,%esp
  801197:	89 c2                	mov    %eax,%edx
  801199:	85 c0                	test   %eax,%eax
  80119b:	78 68                	js     801205 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80119d:	83 ec 08             	sub    $0x8,%esp
  8011a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a3:	50                   	push   %eax
  8011a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a7:	ff 30                	pushl  (%eax)
  8011a9:	e8 e8 fc ff ff       	call   800e96 <dev_lookup>
  8011ae:	83 c4 10             	add    $0x10,%esp
  8011b1:	85 c0                	test   %eax,%eax
  8011b3:	78 47                	js     8011fc <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011bc:	75 21                	jne    8011df <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011be:	a1 08 40 80 00       	mov    0x804008,%eax
  8011c3:	8b 40 48             	mov    0x48(%eax),%eax
  8011c6:	83 ec 04             	sub    $0x4,%esp
  8011c9:	53                   	push   %ebx
  8011ca:	50                   	push   %eax
  8011cb:	68 ec 26 80 00       	push   $0x8026ec
  8011d0:	e8 5d f0 ff ff       	call   800232 <cprintf>
		return -E_INVAL;
  8011d5:	83 c4 10             	add    $0x10,%esp
  8011d8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011dd:	eb 26                	jmp    801205 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011e2:	8b 52 0c             	mov    0xc(%edx),%edx
  8011e5:	85 d2                	test   %edx,%edx
  8011e7:	74 17                	je     801200 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011e9:	83 ec 04             	sub    $0x4,%esp
  8011ec:	ff 75 10             	pushl  0x10(%ebp)
  8011ef:	ff 75 0c             	pushl  0xc(%ebp)
  8011f2:	50                   	push   %eax
  8011f3:	ff d2                	call   *%edx
  8011f5:	89 c2                	mov    %eax,%edx
  8011f7:	83 c4 10             	add    $0x10,%esp
  8011fa:	eb 09                	jmp    801205 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011fc:	89 c2                	mov    %eax,%edx
  8011fe:	eb 05                	jmp    801205 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801200:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801205:	89 d0                	mov    %edx,%eax
  801207:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80120a:	c9                   	leave  
  80120b:	c3                   	ret    

0080120c <seek>:

int
seek(int fdnum, off_t offset)
{
  80120c:	55                   	push   %ebp
  80120d:	89 e5                	mov    %esp,%ebp
  80120f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801212:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801215:	50                   	push   %eax
  801216:	ff 75 08             	pushl  0x8(%ebp)
  801219:	e8 22 fc ff ff       	call   800e40 <fd_lookup>
  80121e:	83 c4 08             	add    $0x8,%esp
  801221:	85 c0                	test   %eax,%eax
  801223:	78 0e                	js     801233 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801225:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801228:	8b 55 0c             	mov    0xc(%ebp),%edx
  80122b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80122e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801233:	c9                   	leave  
  801234:	c3                   	ret    

00801235 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
  801238:	53                   	push   %ebx
  801239:	83 ec 14             	sub    $0x14,%esp
  80123c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80123f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801242:	50                   	push   %eax
  801243:	53                   	push   %ebx
  801244:	e8 f7 fb ff ff       	call   800e40 <fd_lookup>
  801249:	83 c4 08             	add    $0x8,%esp
  80124c:	89 c2                	mov    %eax,%edx
  80124e:	85 c0                	test   %eax,%eax
  801250:	78 65                	js     8012b7 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801252:	83 ec 08             	sub    $0x8,%esp
  801255:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801258:	50                   	push   %eax
  801259:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125c:	ff 30                	pushl  (%eax)
  80125e:	e8 33 fc ff ff       	call   800e96 <dev_lookup>
  801263:	83 c4 10             	add    $0x10,%esp
  801266:	85 c0                	test   %eax,%eax
  801268:	78 44                	js     8012ae <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80126a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801271:	75 21                	jne    801294 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801273:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801278:	8b 40 48             	mov    0x48(%eax),%eax
  80127b:	83 ec 04             	sub    $0x4,%esp
  80127e:	53                   	push   %ebx
  80127f:	50                   	push   %eax
  801280:	68 ac 26 80 00       	push   $0x8026ac
  801285:	e8 a8 ef ff ff       	call   800232 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80128a:	83 c4 10             	add    $0x10,%esp
  80128d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801292:	eb 23                	jmp    8012b7 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801294:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801297:	8b 52 18             	mov    0x18(%edx),%edx
  80129a:	85 d2                	test   %edx,%edx
  80129c:	74 14                	je     8012b2 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80129e:	83 ec 08             	sub    $0x8,%esp
  8012a1:	ff 75 0c             	pushl  0xc(%ebp)
  8012a4:	50                   	push   %eax
  8012a5:	ff d2                	call   *%edx
  8012a7:	89 c2                	mov    %eax,%edx
  8012a9:	83 c4 10             	add    $0x10,%esp
  8012ac:	eb 09                	jmp    8012b7 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ae:	89 c2                	mov    %eax,%edx
  8012b0:	eb 05                	jmp    8012b7 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012b2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012b7:	89 d0                	mov    %edx,%eax
  8012b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012bc:	c9                   	leave  
  8012bd:	c3                   	ret    

008012be <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012be:	55                   	push   %ebp
  8012bf:	89 e5                	mov    %esp,%ebp
  8012c1:	53                   	push   %ebx
  8012c2:	83 ec 14             	sub    $0x14,%esp
  8012c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012cb:	50                   	push   %eax
  8012cc:	ff 75 08             	pushl  0x8(%ebp)
  8012cf:	e8 6c fb ff ff       	call   800e40 <fd_lookup>
  8012d4:	83 c4 08             	add    $0x8,%esp
  8012d7:	89 c2                	mov    %eax,%edx
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	78 58                	js     801335 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012dd:	83 ec 08             	sub    $0x8,%esp
  8012e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e3:	50                   	push   %eax
  8012e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e7:	ff 30                	pushl  (%eax)
  8012e9:	e8 a8 fb ff ff       	call   800e96 <dev_lookup>
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	85 c0                	test   %eax,%eax
  8012f3:	78 37                	js     80132c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012fc:	74 32                	je     801330 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012fe:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801301:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801308:	00 00 00 
	stat->st_isdir = 0;
  80130b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801312:	00 00 00 
	stat->st_dev = dev;
  801315:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80131b:	83 ec 08             	sub    $0x8,%esp
  80131e:	53                   	push   %ebx
  80131f:	ff 75 f0             	pushl  -0x10(%ebp)
  801322:	ff 50 14             	call   *0x14(%eax)
  801325:	89 c2                	mov    %eax,%edx
  801327:	83 c4 10             	add    $0x10,%esp
  80132a:	eb 09                	jmp    801335 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80132c:	89 c2                	mov    %eax,%edx
  80132e:	eb 05                	jmp    801335 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801330:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801335:	89 d0                	mov    %edx,%eax
  801337:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80133a:	c9                   	leave  
  80133b:	c3                   	ret    

0080133c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
  80133f:	56                   	push   %esi
  801340:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801341:	83 ec 08             	sub    $0x8,%esp
  801344:	6a 00                	push   $0x0
  801346:	ff 75 08             	pushl  0x8(%ebp)
  801349:	e8 d6 01 00 00       	call   801524 <open>
  80134e:	89 c3                	mov    %eax,%ebx
  801350:	83 c4 10             	add    $0x10,%esp
  801353:	85 c0                	test   %eax,%eax
  801355:	78 1b                	js     801372 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801357:	83 ec 08             	sub    $0x8,%esp
  80135a:	ff 75 0c             	pushl  0xc(%ebp)
  80135d:	50                   	push   %eax
  80135e:	e8 5b ff ff ff       	call   8012be <fstat>
  801363:	89 c6                	mov    %eax,%esi
	close(fd);
  801365:	89 1c 24             	mov    %ebx,(%esp)
  801368:	e8 fd fb ff ff       	call   800f6a <close>
	return r;
  80136d:	83 c4 10             	add    $0x10,%esp
  801370:	89 f0                	mov    %esi,%eax
}
  801372:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801375:	5b                   	pop    %ebx
  801376:	5e                   	pop    %esi
  801377:	5d                   	pop    %ebp
  801378:	c3                   	ret    

00801379 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801379:	55                   	push   %ebp
  80137a:	89 e5                	mov    %esp,%ebp
  80137c:	56                   	push   %esi
  80137d:	53                   	push   %ebx
  80137e:	89 c6                	mov    %eax,%esi
  801380:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801382:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801389:	75 12                	jne    80139d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80138b:	83 ec 0c             	sub    $0xc,%esp
  80138e:	6a 01                	push   $0x1
  801390:	e8 34 0c 00 00       	call   801fc9 <ipc_find_env>
  801395:	a3 00 40 80 00       	mov    %eax,0x804000
  80139a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80139d:	6a 07                	push   $0x7
  80139f:	68 00 50 80 00       	push   $0x805000
  8013a4:	56                   	push   %esi
  8013a5:	ff 35 00 40 80 00    	pushl  0x804000
  8013ab:	e8 c5 0b 00 00       	call   801f75 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013b0:	83 c4 0c             	add    $0xc,%esp
  8013b3:	6a 00                	push   $0x0
  8013b5:	53                   	push   %ebx
  8013b6:	6a 00                	push   $0x0
  8013b8:	e8 51 0b 00 00       	call   801f0e <ipc_recv>
}
  8013bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c0:	5b                   	pop    %ebx
  8013c1:	5e                   	pop    %esi
  8013c2:	5d                   	pop    %ebp
  8013c3:	c3                   	ret    

008013c4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013c4:	55                   	push   %ebp
  8013c5:	89 e5                	mov    %esp,%ebp
  8013c7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8013cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8013d0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013d8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e2:	b8 02 00 00 00       	mov    $0x2,%eax
  8013e7:	e8 8d ff ff ff       	call   801379 <fsipc>
}
  8013ec:	c9                   	leave  
  8013ed:	c3                   	ret    

008013ee <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
  8013f1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8013fa:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801404:	b8 06 00 00 00       	mov    $0x6,%eax
  801409:	e8 6b ff ff ff       	call   801379 <fsipc>
}
  80140e:	c9                   	leave  
  80140f:	c3                   	ret    

00801410 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801410:	55                   	push   %ebp
  801411:	89 e5                	mov    %esp,%ebp
  801413:	53                   	push   %ebx
  801414:	83 ec 04             	sub    $0x4,%esp
  801417:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80141a:	8b 45 08             	mov    0x8(%ebp),%eax
  80141d:	8b 40 0c             	mov    0xc(%eax),%eax
  801420:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801425:	ba 00 00 00 00       	mov    $0x0,%edx
  80142a:	b8 05 00 00 00       	mov    $0x5,%eax
  80142f:	e8 45 ff ff ff       	call   801379 <fsipc>
  801434:	85 c0                	test   %eax,%eax
  801436:	78 2c                	js     801464 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801438:	83 ec 08             	sub    $0x8,%esp
  80143b:	68 00 50 80 00       	push   $0x805000
  801440:	53                   	push   %ebx
  801441:	e8 71 f3 ff ff       	call   8007b7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801446:	a1 80 50 80 00       	mov    0x805080,%eax
  80144b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801451:	a1 84 50 80 00       	mov    0x805084,%eax
  801456:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80145c:	83 c4 10             	add    $0x10,%esp
  80145f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801464:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801467:	c9                   	leave  
  801468:	c3                   	ret    

00801469 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801469:	55                   	push   %ebp
  80146a:	89 e5                	mov    %esp,%ebp
  80146c:	83 ec 0c             	sub    $0xc,%esp
  80146f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801472:	8b 55 08             	mov    0x8(%ebp),%edx
  801475:	8b 52 0c             	mov    0xc(%edx),%edx
  801478:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80147e:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801483:	50                   	push   %eax
  801484:	ff 75 0c             	pushl  0xc(%ebp)
  801487:	68 08 50 80 00       	push   $0x805008
  80148c:	e8 b8 f4 ff ff       	call   800949 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801491:	ba 00 00 00 00       	mov    $0x0,%edx
  801496:	b8 04 00 00 00       	mov    $0x4,%eax
  80149b:	e8 d9 fe ff ff       	call   801379 <fsipc>

}
  8014a0:	c9                   	leave  
  8014a1:	c3                   	ret    

008014a2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014a2:	55                   	push   %ebp
  8014a3:	89 e5                	mov    %esp,%ebp
  8014a5:	56                   	push   %esi
  8014a6:	53                   	push   %ebx
  8014a7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014b5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c0:	b8 03 00 00 00       	mov    $0x3,%eax
  8014c5:	e8 af fe ff ff       	call   801379 <fsipc>
  8014ca:	89 c3                	mov    %eax,%ebx
  8014cc:	85 c0                	test   %eax,%eax
  8014ce:	78 4b                	js     80151b <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014d0:	39 c6                	cmp    %eax,%esi
  8014d2:	73 16                	jae    8014ea <devfile_read+0x48>
  8014d4:	68 20 27 80 00       	push   $0x802720
  8014d9:	68 27 27 80 00       	push   $0x802727
  8014de:	6a 7c                	push   $0x7c
  8014e0:	68 3c 27 80 00       	push   $0x80273c
  8014e5:	e8 6f ec ff ff       	call   800159 <_panic>
	assert(r <= PGSIZE);
  8014ea:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014ef:	7e 16                	jle    801507 <devfile_read+0x65>
  8014f1:	68 47 27 80 00       	push   $0x802747
  8014f6:	68 27 27 80 00       	push   $0x802727
  8014fb:	6a 7d                	push   $0x7d
  8014fd:	68 3c 27 80 00       	push   $0x80273c
  801502:	e8 52 ec ff ff       	call   800159 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801507:	83 ec 04             	sub    $0x4,%esp
  80150a:	50                   	push   %eax
  80150b:	68 00 50 80 00       	push   $0x805000
  801510:	ff 75 0c             	pushl  0xc(%ebp)
  801513:	e8 31 f4 ff ff       	call   800949 <memmove>
	return r;
  801518:	83 c4 10             	add    $0x10,%esp
}
  80151b:	89 d8                	mov    %ebx,%eax
  80151d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801520:	5b                   	pop    %ebx
  801521:	5e                   	pop    %esi
  801522:	5d                   	pop    %ebp
  801523:	c3                   	ret    

00801524 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801524:	55                   	push   %ebp
  801525:	89 e5                	mov    %esp,%ebp
  801527:	53                   	push   %ebx
  801528:	83 ec 20             	sub    $0x20,%esp
  80152b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80152e:	53                   	push   %ebx
  80152f:	e8 4a f2 ff ff       	call   80077e <strlen>
  801534:	83 c4 10             	add    $0x10,%esp
  801537:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80153c:	7f 67                	jg     8015a5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80153e:	83 ec 0c             	sub    $0xc,%esp
  801541:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801544:	50                   	push   %eax
  801545:	e8 a7 f8 ff ff       	call   800df1 <fd_alloc>
  80154a:	83 c4 10             	add    $0x10,%esp
		return r;
  80154d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80154f:	85 c0                	test   %eax,%eax
  801551:	78 57                	js     8015aa <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801553:	83 ec 08             	sub    $0x8,%esp
  801556:	53                   	push   %ebx
  801557:	68 00 50 80 00       	push   $0x805000
  80155c:	e8 56 f2 ff ff       	call   8007b7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801561:	8b 45 0c             	mov    0xc(%ebp),%eax
  801564:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801569:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80156c:	b8 01 00 00 00       	mov    $0x1,%eax
  801571:	e8 03 fe ff ff       	call   801379 <fsipc>
  801576:	89 c3                	mov    %eax,%ebx
  801578:	83 c4 10             	add    $0x10,%esp
  80157b:	85 c0                	test   %eax,%eax
  80157d:	79 14                	jns    801593 <open+0x6f>
		fd_close(fd, 0);
  80157f:	83 ec 08             	sub    $0x8,%esp
  801582:	6a 00                	push   $0x0
  801584:	ff 75 f4             	pushl  -0xc(%ebp)
  801587:	e8 5d f9 ff ff       	call   800ee9 <fd_close>
		return r;
  80158c:	83 c4 10             	add    $0x10,%esp
  80158f:	89 da                	mov    %ebx,%edx
  801591:	eb 17                	jmp    8015aa <open+0x86>
	}

	return fd2num(fd);
  801593:	83 ec 0c             	sub    $0xc,%esp
  801596:	ff 75 f4             	pushl  -0xc(%ebp)
  801599:	e8 2c f8 ff ff       	call   800dca <fd2num>
  80159e:	89 c2                	mov    %eax,%edx
  8015a0:	83 c4 10             	add    $0x10,%esp
  8015a3:	eb 05                	jmp    8015aa <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015a5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015aa:	89 d0                	mov    %edx,%eax
  8015ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015af:	c9                   	leave  
  8015b0:	c3                   	ret    

008015b1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015b1:	55                   	push   %ebp
  8015b2:	89 e5                	mov    %esp,%ebp
  8015b4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8015bc:	b8 08 00 00 00       	mov    $0x8,%eax
  8015c1:	e8 b3 fd ff ff       	call   801379 <fsipc>
}
  8015c6:	c9                   	leave  
  8015c7:	c3                   	ret    

008015c8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8015c8:	55                   	push   %ebp
  8015c9:	89 e5                	mov    %esp,%ebp
  8015cb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8015ce:	68 53 27 80 00       	push   $0x802753
  8015d3:	ff 75 0c             	pushl  0xc(%ebp)
  8015d6:	e8 dc f1 ff ff       	call   8007b7 <strcpy>
	return 0;
}
  8015db:	b8 00 00 00 00       	mov    $0x0,%eax
  8015e0:	c9                   	leave  
  8015e1:	c3                   	ret    

008015e2 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	53                   	push   %ebx
  8015e6:	83 ec 10             	sub    $0x10,%esp
  8015e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8015ec:	53                   	push   %ebx
  8015ed:	e8 10 0a 00 00       	call   802002 <pageref>
  8015f2:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8015f5:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8015fa:	83 f8 01             	cmp    $0x1,%eax
  8015fd:	75 10                	jne    80160f <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8015ff:	83 ec 0c             	sub    $0xc,%esp
  801602:	ff 73 0c             	pushl  0xc(%ebx)
  801605:	e8 c0 02 00 00       	call   8018ca <nsipc_close>
  80160a:	89 c2                	mov    %eax,%edx
  80160c:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80160f:	89 d0                	mov    %edx,%eax
  801611:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801614:	c9                   	leave  
  801615:	c3                   	ret    

00801616 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80161c:	6a 00                	push   $0x0
  80161e:	ff 75 10             	pushl  0x10(%ebp)
  801621:	ff 75 0c             	pushl  0xc(%ebp)
  801624:	8b 45 08             	mov    0x8(%ebp),%eax
  801627:	ff 70 0c             	pushl  0xc(%eax)
  80162a:	e8 78 03 00 00       	call   8019a7 <nsipc_send>
}
  80162f:	c9                   	leave  
  801630:	c3                   	ret    

00801631 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801631:	55                   	push   %ebp
  801632:	89 e5                	mov    %esp,%ebp
  801634:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801637:	6a 00                	push   $0x0
  801639:	ff 75 10             	pushl  0x10(%ebp)
  80163c:	ff 75 0c             	pushl  0xc(%ebp)
  80163f:	8b 45 08             	mov    0x8(%ebp),%eax
  801642:	ff 70 0c             	pushl  0xc(%eax)
  801645:	e8 f1 02 00 00       	call   80193b <nsipc_recv>
}
  80164a:	c9                   	leave  
  80164b:	c3                   	ret    

0080164c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80164c:	55                   	push   %ebp
  80164d:	89 e5                	mov    %esp,%ebp
  80164f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801652:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801655:	52                   	push   %edx
  801656:	50                   	push   %eax
  801657:	e8 e4 f7 ff ff       	call   800e40 <fd_lookup>
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	85 c0                	test   %eax,%eax
  801661:	78 17                	js     80167a <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801663:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801666:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80166c:	39 08                	cmp    %ecx,(%eax)
  80166e:	75 05                	jne    801675 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801670:	8b 40 0c             	mov    0xc(%eax),%eax
  801673:	eb 05                	jmp    80167a <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801675:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80167a:	c9                   	leave  
  80167b:	c3                   	ret    

0080167c <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	56                   	push   %esi
  801680:	53                   	push   %ebx
  801681:	83 ec 1c             	sub    $0x1c,%esp
  801684:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801686:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801689:	50                   	push   %eax
  80168a:	e8 62 f7 ff ff       	call   800df1 <fd_alloc>
  80168f:	89 c3                	mov    %eax,%ebx
  801691:	83 c4 10             	add    $0x10,%esp
  801694:	85 c0                	test   %eax,%eax
  801696:	78 1b                	js     8016b3 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801698:	83 ec 04             	sub    $0x4,%esp
  80169b:	68 07 04 00 00       	push   $0x407
  8016a0:	ff 75 f4             	pushl  -0xc(%ebp)
  8016a3:	6a 00                	push   $0x0
  8016a5:	e8 10 f5 ff ff       	call   800bba <sys_page_alloc>
  8016aa:	89 c3                	mov    %eax,%ebx
  8016ac:	83 c4 10             	add    $0x10,%esp
  8016af:	85 c0                	test   %eax,%eax
  8016b1:	79 10                	jns    8016c3 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8016b3:	83 ec 0c             	sub    $0xc,%esp
  8016b6:	56                   	push   %esi
  8016b7:	e8 0e 02 00 00       	call   8018ca <nsipc_close>
		return r;
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	89 d8                	mov    %ebx,%eax
  8016c1:	eb 24                	jmp    8016e7 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8016c3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8016c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016cc:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8016ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8016d8:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8016db:	83 ec 0c             	sub    $0xc,%esp
  8016de:	50                   	push   %eax
  8016df:	e8 e6 f6 ff ff       	call   800dca <fd2num>
  8016e4:	83 c4 10             	add    $0x10,%esp
}
  8016e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ea:	5b                   	pop    %ebx
  8016eb:	5e                   	pop    %esi
  8016ec:	5d                   	pop    %ebp
  8016ed:	c3                   	ret    

008016ee <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8016ee:	55                   	push   %ebp
  8016ef:	89 e5                	mov    %esp,%ebp
  8016f1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f7:	e8 50 ff ff ff       	call   80164c <fd2sockid>
		return r;
  8016fc:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016fe:	85 c0                	test   %eax,%eax
  801700:	78 1f                	js     801721 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801702:	83 ec 04             	sub    $0x4,%esp
  801705:	ff 75 10             	pushl  0x10(%ebp)
  801708:	ff 75 0c             	pushl  0xc(%ebp)
  80170b:	50                   	push   %eax
  80170c:	e8 12 01 00 00       	call   801823 <nsipc_accept>
  801711:	83 c4 10             	add    $0x10,%esp
		return r;
  801714:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801716:	85 c0                	test   %eax,%eax
  801718:	78 07                	js     801721 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80171a:	e8 5d ff ff ff       	call   80167c <alloc_sockfd>
  80171f:	89 c1                	mov    %eax,%ecx
}
  801721:	89 c8                	mov    %ecx,%eax
  801723:	c9                   	leave  
  801724:	c3                   	ret    

00801725 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801725:	55                   	push   %ebp
  801726:	89 e5                	mov    %esp,%ebp
  801728:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80172b:	8b 45 08             	mov    0x8(%ebp),%eax
  80172e:	e8 19 ff ff ff       	call   80164c <fd2sockid>
  801733:	85 c0                	test   %eax,%eax
  801735:	78 12                	js     801749 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801737:	83 ec 04             	sub    $0x4,%esp
  80173a:	ff 75 10             	pushl  0x10(%ebp)
  80173d:	ff 75 0c             	pushl  0xc(%ebp)
  801740:	50                   	push   %eax
  801741:	e8 2d 01 00 00       	call   801873 <nsipc_bind>
  801746:	83 c4 10             	add    $0x10,%esp
}
  801749:	c9                   	leave  
  80174a:	c3                   	ret    

0080174b <shutdown>:

int
shutdown(int s, int how)
{
  80174b:	55                   	push   %ebp
  80174c:	89 e5                	mov    %esp,%ebp
  80174e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801751:	8b 45 08             	mov    0x8(%ebp),%eax
  801754:	e8 f3 fe ff ff       	call   80164c <fd2sockid>
  801759:	85 c0                	test   %eax,%eax
  80175b:	78 0f                	js     80176c <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80175d:	83 ec 08             	sub    $0x8,%esp
  801760:	ff 75 0c             	pushl  0xc(%ebp)
  801763:	50                   	push   %eax
  801764:	e8 3f 01 00 00       	call   8018a8 <nsipc_shutdown>
  801769:	83 c4 10             	add    $0x10,%esp
}
  80176c:	c9                   	leave  
  80176d:	c3                   	ret    

0080176e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80176e:	55                   	push   %ebp
  80176f:	89 e5                	mov    %esp,%ebp
  801771:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801774:	8b 45 08             	mov    0x8(%ebp),%eax
  801777:	e8 d0 fe ff ff       	call   80164c <fd2sockid>
  80177c:	85 c0                	test   %eax,%eax
  80177e:	78 12                	js     801792 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801780:	83 ec 04             	sub    $0x4,%esp
  801783:	ff 75 10             	pushl  0x10(%ebp)
  801786:	ff 75 0c             	pushl  0xc(%ebp)
  801789:	50                   	push   %eax
  80178a:	e8 55 01 00 00       	call   8018e4 <nsipc_connect>
  80178f:	83 c4 10             	add    $0x10,%esp
}
  801792:	c9                   	leave  
  801793:	c3                   	ret    

00801794 <listen>:

int
listen(int s, int backlog)
{
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80179a:	8b 45 08             	mov    0x8(%ebp),%eax
  80179d:	e8 aa fe ff ff       	call   80164c <fd2sockid>
  8017a2:	85 c0                	test   %eax,%eax
  8017a4:	78 0f                	js     8017b5 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8017a6:	83 ec 08             	sub    $0x8,%esp
  8017a9:	ff 75 0c             	pushl  0xc(%ebp)
  8017ac:	50                   	push   %eax
  8017ad:	e8 67 01 00 00       	call   801919 <nsipc_listen>
  8017b2:	83 c4 10             	add    $0x10,%esp
}
  8017b5:	c9                   	leave  
  8017b6:	c3                   	ret    

008017b7 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8017bd:	ff 75 10             	pushl  0x10(%ebp)
  8017c0:	ff 75 0c             	pushl  0xc(%ebp)
  8017c3:	ff 75 08             	pushl  0x8(%ebp)
  8017c6:	e8 3a 02 00 00       	call   801a05 <nsipc_socket>
  8017cb:	83 c4 10             	add    $0x10,%esp
  8017ce:	85 c0                	test   %eax,%eax
  8017d0:	78 05                	js     8017d7 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8017d2:	e8 a5 fe ff ff       	call   80167c <alloc_sockfd>
}
  8017d7:	c9                   	leave  
  8017d8:	c3                   	ret    

008017d9 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	53                   	push   %ebx
  8017dd:	83 ec 04             	sub    $0x4,%esp
  8017e0:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8017e2:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8017e9:	75 12                	jne    8017fd <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8017eb:	83 ec 0c             	sub    $0xc,%esp
  8017ee:	6a 02                	push   $0x2
  8017f0:	e8 d4 07 00 00       	call   801fc9 <ipc_find_env>
  8017f5:	a3 04 40 80 00       	mov    %eax,0x804004
  8017fa:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8017fd:	6a 07                	push   $0x7
  8017ff:	68 00 60 80 00       	push   $0x806000
  801804:	53                   	push   %ebx
  801805:	ff 35 04 40 80 00    	pushl  0x804004
  80180b:	e8 65 07 00 00       	call   801f75 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801810:	83 c4 0c             	add    $0xc,%esp
  801813:	6a 00                	push   $0x0
  801815:	6a 00                	push   $0x0
  801817:	6a 00                	push   $0x0
  801819:	e8 f0 06 00 00       	call   801f0e <ipc_recv>
}
  80181e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801821:	c9                   	leave  
  801822:	c3                   	ret    

00801823 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801823:	55                   	push   %ebp
  801824:	89 e5                	mov    %esp,%ebp
  801826:	56                   	push   %esi
  801827:	53                   	push   %ebx
  801828:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80182b:	8b 45 08             	mov    0x8(%ebp),%eax
  80182e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801833:	8b 06                	mov    (%esi),%eax
  801835:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80183a:	b8 01 00 00 00       	mov    $0x1,%eax
  80183f:	e8 95 ff ff ff       	call   8017d9 <nsipc>
  801844:	89 c3                	mov    %eax,%ebx
  801846:	85 c0                	test   %eax,%eax
  801848:	78 20                	js     80186a <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80184a:	83 ec 04             	sub    $0x4,%esp
  80184d:	ff 35 10 60 80 00    	pushl  0x806010
  801853:	68 00 60 80 00       	push   $0x806000
  801858:	ff 75 0c             	pushl  0xc(%ebp)
  80185b:	e8 e9 f0 ff ff       	call   800949 <memmove>
		*addrlen = ret->ret_addrlen;
  801860:	a1 10 60 80 00       	mov    0x806010,%eax
  801865:	89 06                	mov    %eax,(%esi)
  801867:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80186a:	89 d8                	mov    %ebx,%eax
  80186c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80186f:	5b                   	pop    %ebx
  801870:	5e                   	pop    %esi
  801871:	5d                   	pop    %ebp
  801872:	c3                   	ret    

00801873 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	53                   	push   %ebx
  801877:	83 ec 08             	sub    $0x8,%esp
  80187a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80187d:	8b 45 08             	mov    0x8(%ebp),%eax
  801880:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801885:	53                   	push   %ebx
  801886:	ff 75 0c             	pushl  0xc(%ebp)
  801889:	68 04 60 80 00       	push   $0x806004
  80188e:	e8 b6 f0 ff ff       	call   800949 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801893:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801899:	b8 02 00 00 00       	mov    $0x2,%eax
  80189e:	e8 36 ff ff ff       	call   8017d9 <nsipc>
}
  8018a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a6:	c9                   	leave  
  8018a7:	c3                   	ret    

008018a8 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8018a8:	55                   	push   %ebp
  8018a9:	89 e5                	mov    %esp,%ebp
  8018ab:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8018ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8018b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b9:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8018be:	b8 03 00 00 00       	mov    $0x3,%eax
  8018c3:	e8 11 ff ff ff       	call   8017d9 <nsipc>
}
  8018c8:	c9                   	leave  
  8018c9:	c3                   	ret    

008018ca <nsipc_close>:

int
nsipc_close(int s)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8018d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d3:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8018d8:	b8 04 00 00 00       	mov    $0x4,%eax
  8018dd:	e8 f7 fe ff ff       	call   8017d9 <nsipc>
}
  8018e2:	c9                   	leave  
  8018e3:	c3                   	ret    

008018e4 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
  8018e7:	53                   	push   %ebx
  8018e8:	83 ec 08             	sub    $0x8,%esp
  8018eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8018ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f1:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8018f6:	53                   	push   %ebx
  8018f7:	ff 75 0c             	pushl  0xc(%ebp)
  8018fa:	68 04 60 80 00       	push   $0x806004
  8018ff:	e8 45 f0 ff ff       	call   800949 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801904:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  80190a:	b8 05 00 00 00       	mov    $0x5,%eax
  80190f:	e8 c5 fe ff ff       	call   8017d9 <nsipc>
}
  801914:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801917:	c9                   	leave  
  801918:	c3                   	ret    

00801919 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801919:	55                   	push   %ebp
  80191a:	89 e5                	mov    %esp,%ebp
  80191c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80191f:	8b 45 08             	mov    0x8(%ebp),%eax
  801922:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801927:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80192f:	b8 06 00 00 00       	mov    $0x6,%eax
  801934:	e8 a0 fe ff ff       	call   8017d9 <nsipc>
}
  801939:	c9                   	leave  
  80193a:	c3                   	ret    

0080193b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80193b:	55                   	push   %ebp
  80193c:	89 e5                	mov    %esp,%ebp
  80193e:	56                   	push   %esi
  80193f:	53                   	push   %ebx
  801940:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801943:	8b 45 08             	mov    0x8(%ebp),%eax
  801946:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80194b:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801951:	8b 45 14             	mov    0x14(%ebp),%eax
  801954:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801959:	b8 07 00 00 00       	mov    $0x7,%eax
  80195e:	e8 76 fe ff ff       	call   8017d9 <nsipc>
  801963:	89 c3                	mov    %eax,%ebx
  801965:	85 c0                	test   %eax,%eax
  801967:	78 35                	js     80199e <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801969:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80196e:	7f 04                	jg     801974 <nsipc_recv+0x39>
  801970:	39 c6                	cmp    %eax,%esi
  801972:	7d 16                	jge    80198a <nsipc_recv+0x4f>
  801974:	68 5f 27 80 00       	push   $0x80275f
  801979:	68 27 27 80 00       	push   $0x802727
  80197e:	6a 62                	push   $0x62
  801980:	68 74 27 80 00       	push   $0x802774
  801985:	e8 cf e7 ff ff       	call   800159 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80198a:	83 ec 04             	sub    $0x4,%esp
  80198d:	50                   	push   %eax
  80198e:	68 00 60 80 00       	push   $0x806000
  801993:	ff 75 0c             	pushl  0xc(%ebp)
  801996:	e8 ae ef ff ff       	call   800949 <memmove>
  80199b:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80199e:	89 d8                	mov    %ebx,%eax
  8019a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a3:	5b                   	pop    %ebx
  8019a4:	5e                   	pop    %esi
  8019a5:	5d                   	pop    %ebp
  8019a6:	c3                   	ret    

008019a7 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8019a7:	55                   	push   %ebp
  8019a8:	89 e5                	mov    %esp,%ebp
  8019aa:	53                   	push   %ebx
  8019ab:	83 ec 04             	sub    $0x4,%esp
  8019ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8019b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b4:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8019b9:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8019bf:	7e 16                	jle    8019d7 <nsipc_send+0x30>
  8019c1:	68 80 27 80 00       	push   $0x802780
  8019c6:	68 27 27 80 00       	push   $0x802727
  8019cb:	6a 6d                	push   $0x6d
  8019cd:	68 74 27 80 00       	push   $0x802774
  8019d2:	e8 82 e7 ff ff       	call   800159 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8019d7:	83 ec 04             	sub    $0x4,%esp
  8019da:	53                   	push   %ebx
  8019db:	ff 75 0c             	pushl  0xc(%ebp)
  8019de:	68 0c 60 80 00       	push   $0x80600c
  8019e3:	e8 61 ef ff ff       	call   800949 <memmove>
	nsipcbuf.send.req_size = size;
  8019e8:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8019ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f1:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8019f6:	b8 08 00 00 00       	mov    $0x8,%eax
  8019fb:	e8 d9 fd ff ff       	call   8017d9 <nsipc>
}
  801a00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a03:	c9                   	leave  
  801a04:	c3                   	ret    

00801a05 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a05:	55                   	push   %ebp
  801a06:	89 e5                	mov    %esp,%ebp
  801a08:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801a13:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a16:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801a1b:	8b 45 10             	mov    0x10(%ebp),%eax
  801a1e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801a23:	b8 09 00 00 00       	mov    $0x9,%eax
  801a28:	e8 ac fd ff ff       	call   8017d9 <nsipc>
}
  801a2d:	c9                   	leave  
  801a2e:	c3                   	ret    

00801a2f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	56                   	push   %esi
  801a33:	53                   	push   %ebx
  801a34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a37:	83 ec 0c             	sub    $0xc,%esp
  801a3a:	ff 75 08             	pushl  0x8(%ebp)
  801a3d:	e8 98 f3 ff ff       	call   800dda <fd2data>
  801a42:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a44:	83 c4 08             	add    $0x8,%esp
  801a47:	68 8c 27 80 00       	push   $0x80278c
  801a4c:	53                   	push   %ebx
  801a4d:	e8 65 ed ff ff       	call   8007b7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a52:	8b 46 04             	mov    0x4(%esi),%eax
  801a55:	2b 06                	sub    (%esi),%eax
  801a57:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a5d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a64:	00 00 00 
	stat->st_dev = &devpipe;
  801a67:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a6e:	30 80 00 
	return 0;
}
  801a71:	b8 00 00 00 00       	mov    $0x0,%eax
  801a76:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a79:	5b                   	pop    %ebx
  801a7a:	5e                   	pop    %esi
  801a7b:	5d                   	pop    %ebp
  801a7c:	c3                   	ret    

00801a7d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a7d:	55                   	push   %ebp
  801a7e:	89 e5                	mov    %esp,%ebp
  801a80:	53                   	push   %ebx
  801a81:	83 ec 0c             	sub    $0xc,%esp
  801a84:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a87:	53                   	push   %ebx
  801a88:	6a 00                	push   $0x0
  801a8a:	e8 b0 f1 ff ff       	call   800c3f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a8f:	89 1c 24             	mov    %ebx,(%esp)
  801a92:	e8 43 f3 ff ff       	call   800dda <fd2data>
  801a97:	83 c4 08             	add    $0x8,%esp
  801a9a:	50                   	push   %eax
  801a9b:	6a 00                	push   $0x0
  801a9d:	e8 9d f1 ff ff       	call   800c3f <sys_page_unmap>
}
  801aa2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aa5:	c9                   	leave  
  801aa6:	c3                   	ret    

00801aa7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801aa7:	55                   	push   %ebp
  801aa8:	89 e5                	mov    %esp,%ebp
  801aaa:	57                   	push   %edi
  801aab:	56                   	push   %esi
  801aac:	53                   	push   %ebx
  801aad:	83 ec 1c             	sub    $0x1c,%esp
  801ab0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ab3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ab5:	a1 08 40 80 00       	mov    0x804008,%eax
  801aba:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801abd:	83 ec 0c             	sub    $0xc,%esp
  801ac0:	ff 75 e0             	pushl  -0x20(%ebp)
  801ac3:	e8 3a 05 00 00       	call   802002 <pageref>
  801ac8:	89 c3                	mov    %eax,%ebx
  801aca:	89 3c 24             	mov    %edi,(%esp)
  801acd:	e8 30 05 00 00       	call   802002 <pageref>
  801ad2:	83 c4 10             	add    $0x10,%esp
  801ad5:	39 c3                	cmp    %eax,%ebx
  801ad7:	0f 94 c1             	sete   %cl
  801ada:	0f b6 c9             	movzbl %cl,%ecx
  801add:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ae0:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ae6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ae9:	39 ce                	cmp    %ecx,%esi
  801aeb:	74 1b                	je     801b08 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801aed:	39 c3                	cmp    %eax,%ebx
  801aef:	75 c4                	jne    801ab5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801af1:	8b 42 58             	mov    0x58(%edx),%eax
  801af4:	ff 75 e4             	pushl  -0x1c(%ebp)
  801af7:	50                   	push   %eax
  801af8:	56                   	push   %esi
  801af9:	68 93 27 80 00       	push   $0x802793
  801afe:	e8 2f e7 ff ff       	call   800232 <cprintf>
  801b03:	83 c4 10             	add    $0x10,%esp
  801b06:	eb ad                	jmp    801ab5 <_pipeisclosed+0xe>
	}
}
  801b08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b0e:	5b                   	pop    %ebx
  801b0f:	5e                   	pop    %esi
  801b10:	5f                   	pop    %edi
  801b11:	5d                   	pop    %ebp
  801b12:	c3                   	ret    

00801b13 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	57                   	push   %edi
  801b17:	56                   	push   %esi
  801b18:	53                   	push   %ebx
  801b19:	83 ec 28             	sub    $0x28,%esp
  801b1c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b1f:	56                   	push   %esi
  801b20:	e8 b5 f2 ff ff       	call   800dda <fd2data>
  801b25:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b27:	83 c4 10             	add    $0x10,%esp
  801b2a:	bf 00 00 00 00       	mov    $0x0,%edi
  801b2f:	eb 4b                	jmp    801b7c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b31:	89 da                	mov    %ebx,%edx
  801b33:	89 f0                	mov    %esi,%eax
  801b35:	e8 6d ff ff ff       	call   801aa7 <_pipeisclosed>
  801b3a:	85 c0                	test   %eax,%eax
  801b3c:	75 48                	jne    801b86 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b3e:	e8 58 f0 ff ff       	call   800b9b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b43:	8b 43 04             	mov    0x4(%ebx),%eax
  801b46:	8b 0b                	mov    (%ebx),%ecx
  801b48:	8d 51 20             	lea    0x20(%ecx),%edx
  801b4b:	39 d0                	cmp    %edx,%eax
  801b4d:	73 e2                	jae    801b31 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b52:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b56:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b59:	89 c2                	mov    %eax,%edx
  801b5b:	c1 fa 1f             	sar    $0x1f,%edx
  801b5e:	89 d1                	mov    %edx,%ecx
  801b60:	c1 e9 1b             	shr    $0x1b,%ecx
  801b63:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b66:	83 e2 1f             	and    $0x1f,%edx
  801b69:	29 ca                	sub    %ecx,%edx
  801b6b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b6f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b73:	83 c0 01             	add    $0x1,%eax
  801b76:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b79:	83 c7 01             	add    $0x1,%edi
  801b7c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b7f:	75 c2                	jne    801b43 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b81:	8b 45 10             	mov    0x10(%ebp),%eax
  801b84:	eb 05                	jmp    801b8b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b86:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b8e:	5b                   	pop    %ebx
  801b8f:	5e                   	pop    %esi
  801b90:	5f                   	pop    %edi
  801b91:	5d                   	pop    %ebp
  801b92:	c3                   	ret    

00801b93 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	57                   	push   %edi
  801b97:	56                   	push   %esi
  801b98:	53                   	push   %ebx
  801b99:	83 ec 18             	sub    $0x18,%esp
  801b9c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b9f:	57                   	push   %edi
  801ba0:	e8 35 f2 ff ff       	call   800dda <fd2data>
  801ba5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba7:	83 c4 10             	add    $0x10,%esp
  801baa:	bb 00 00 00 00       	mov    $0x0,%ebx
  801baf:	eb 3d                	jmp    801bee <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bb1:	85 db                	test   %ebx,%ebx
  801bb3:	74 04                	je     801bb9 <devpipe_read+0x26>
				return i;
  801bb5:	89 d8                	mov    %ebx,%eax
  801bb7:	eb 44                	jmp    801bfd <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bb9:	89 f2                	mov    %esi,%edx
  801bbb:	89 f8                	mov    %edi,%eax
  801bbd:	e8 e5 fe ff ff       	call   801aa7 <_pipeisclosed>
  801bc2:	85 c0                	test   %eax,%eax
  801bc4:	75 32                	jne    801bf8 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bc6:	e8 d0 ef ff ff       	call   800b9b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bcb:	8b 06                	mov    (%esi),%eax
  801bcd:	3b 46 04             	cmp    0x4(%esi),%eax
  801bd0:	74 df                	je     801bb1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bd2:	99                   	cltd   
  801bd3:	c1 ea 1b             	shr    $0x1b,%edx
  801bd6:	01 d0                	add    %edx,%eax
  801bd8:	83 e0 1f             	and    $0x1f,%eax
  801bdb:	29 d0                	sub    %edx,%eax
  801bdd:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801be2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801be5:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801be8:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801beb:	83 c3 01             	add    $0x1,%ebx
  801bee:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bf1:	75 d8                	jne    801bcb <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bf3:	8b 45 10             	mov    0x10(%ebp),%eax
  801bf6:	eb 05                	jmp    801bfd <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bf8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c00:	5b                   	pop    %ebx
  801c01:	5e                   	pop    %esi
  801c02:	5f                   	pop    %edi
  801c03:	5d                   	pop    %ebp
  801c04:	c3                   	ret    

00801c05 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c05:	55                   	push   %ebp
  801c06:	89 e5                	mov    %esp,%ebp
  801c08:	56                   	push   %esi
  801c09:	53                   	push   %ebx
  801c0a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c10:	50                   	push   %eax
  801c11:	e8 db f1 ff ff       	call   800df1 <fd_alloc>
  801c16:	83 c4 10             	add    $0x10,%esp
  801c19:	89 c2                	mov    %eax,%edx
  801c1b:	85 c0                	test   %eax,%eax
  801c1d:	0f 88 2c 01 00 00    	js     801d4f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c23:	83 ec 04             	sub    $0x4,%esp
  801c26:	68 07 04 00 00       	push   $0x407
  801c2b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c2e:	6a 00                	push   $0x0
  801c30:	e8 85 ef ff ff       	call   800bba <sys_page_alloc>
  801c35:	83 c4 10             	add    $0x10,%esp
  801c38:	89 c2                	mov    %eax,%edx
  801c3a:	85 c0                	test   %eax,%eax
  801c3c:	0f 88 0d 01 00 00    	js     801d4f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c42:	83 ec 0c             	sub    $0xc,%esp
  801c45:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c48:	50                   	push   %eax
  801c49:	e8 a3 f1 ff ff       	call   800df1 <fd_alloc>
  801c4e:	89 c3                	mov    %eax,%ebx
  801c50:	83 c4 10             	add    $0x10,%esp
  801c53:	85 c0                	test   %eax,%eax
  801c55:	0f 88 e2 00 00 00    	js     801d3d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c5b:	83 ec 04             	sub    $0x4,%esp
  801c5e:	68 07 04 00 00       	push   $0x407
  801c63:	ff 75 f0             	pushl  -0x10(%ebp)
  801c66:	6a 00                	push   $0x0
  801c68:	e8 4d ef ff ff       	call   800bba <sys_page_alloc>
  801c6d:	89 c3                	mov    %eax,%ebx
  801c6f:	83 c4 10             	add    $0x10,%esp
  801c72:	85 c0                	test   %eax,%eax
  801c74:	0f 88 c3 00 00 00    	js     801d3d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c7a:	83 ec 0c             	sub    $0xc,%esp
  801c7d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c80:	e8 55 f1 ff ff       	call   800dda <fd2data>
  801c85:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c87:	83 c4 0c             	add    $0xc,%esp
  801c8a:	68 07 04 00 00       	push   $0x407
  801c8f:	50                   	push   %eax
  801c90:	6a 00                	push   $0x0
  801c92:	e8 23 ef ff ff       	call   800bba <sys_page_alloc>
  801c97:	89 c3                	mov    %eax,%ebx
  801c99:	83 c4 10             	add    $0x10,%esp
  801c9c:	85 c0                	test   %eax,%eax
  801c9e:	0f 88 89 00 00 00    	js     801d2d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ca4:	83 ec 0c             	sub    $0xc,%esp
  801ca7:	ff 75 f0             	pushl  -0x10(%ebp)
  801caa:	e8 2b f1 ff ff       	call   800dda <fd2data>
  801caf:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cb6:	50                   	push   %eax
  801cb7:	6a 00                	push   $0x0
  801cb9:	56                   	push   %esi
  801cba:	6a 00                	push   $0x0
  801cbc:	e8 3c ef ff ff       	call   800bfd <sys_page_map>
  801cc1:	89 c3                	mov    %eax,%ebx
  801cc3:	83 c4 20             	add    $0x20,%esp
  801cc6:	85 c0                	test   %eax,%eax
  801cc8:	78 55                	js     801d1f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cca:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cdf:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ce5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ce8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ced:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cf4:	83 ec 0c             	sub    $0xc,%esp
  801cf7:	ff 75 f4             	pushl  -0xc(%ebp)
  801cfa:	e8 cb f0 ff ff       	call   800dca <fd2num>
  801cff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d02:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d04:	83 c4 04             	add    $0x4,%esp
  801d07:	ff 75 f0             	pushl  -0x10(%ebp)
  801d0a:	e8 bb f0 ff ff       	call   800dca <fd2num>
  801d0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d12:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d15:	83 c4 10             	add    $0x10,%esp
  801d18:	ba 00 00 00 00       	mov    $0x0,%edx
  801d1d:	eb 30                	jmp    801d4f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d1f:	83 ec 08             	sub    $0x8,%esp
  801d22:	56                   	push   %esi
  801d23:	6a 00                	push   $0x0
  801d25:	e8 15 ef ff ff       	call   800c3f <sys_page_unmap>
  801d2a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d2d:	83 ec 08             	sub    $0x8,%esp
  801d30:	ff 75 f0             	pushl  -0x10(%ebp)
  801d33:	6a 00                	push   $0x0
  801d35:	e8 05 ef ff ff       	call   800c3f <sys_page_unmap>
  801d3a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d3d:	83 ec 08             	sub    $0x8,%esp
  801d40:	ff 75 f4             	pushl  -0xc(%ebp)
  801d43:	6a 00                	push   $0x0
  801d45:	e8 f5 ee ff ff       	call   800c3f <sys_page_unmap>
  801d4a:	83 c4 10             	add    $0x10,%esp
  801d4d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d4f:	89 d0                	mov    %edx,%eax
  801d51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d54:	5b                   	pop    %ebx
  801d55:	5e                   	pop    %esi
  801d56:	5d                   	pop    %ebp
  801d57:	c3                   	ret    

00801d58 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d58:	55                   	push   %ebp
  801d59:	89 e5                	mov    %esp,%ebp
  801d5b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d61:	50                   	push   %eax
  801d62:	ff 75 08             	pushl  0x8(%ebp)
  801d65:	e8 d6 f0 ff ff       	call   800e40 <fd_lookup>
  801d6a:	83 c4 10             	add    $0x10,%esp
  801d6d:	85 c0                	test   %eax,%eax
  801d6f:	78 18                	js     801d89 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d71:	83 ec 0c             	sub    $0xc,%esp
  801d74:	ff 75 f4             	pushl  -0xc(%ebp)
  801d77:	e8 5e f0 ff ff       	call   800dda <fd2data>
	return _pipeisclosed(fd, p);
  801d7c:	89 c2                	mov    %eax,%edx
  801d7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d81:	e8 21 fd ff ff       	call   801aa7 <_pipeisclosed>
  801d86:	83 c4 10             	add    $0x10,%esp
}
  801d89:	c9                   	leave  
  801d8a:	c3                   	ret    

00801d8b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d8b:	55                   	push   %ebp
  801d8c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d8e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d93:	5d                   	pop    %ebp
  801d94:	c3                   	ret    

00801d95 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d95:	55                   	push   %ebp
  801d96:	89 e5                	mov    %esp,%ebp
  801d98:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d9b:	68 ab 27 80 00       	push   $0x8027ab
  801da0:	ff 75 0c             	pushl  0xc(%ebp)
  801da3:	e8 0f ea ff ff       	call   8007b7 <strcpy>
	return 0;
}
  801da8:	b8 00 00 00 00       	mov    $0x0,%eax
  801dad:	c9                   	leave  
  801dae:	c3                   	ret    

00801daf <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801daf:	55                   	push   %ebp
  801db0:	89 e5                	mov    %esp,%ebp
  801db2:	57                   	push   %edi
  801db3:	56                   	push   %esi
  801db4:	53                   	push   %ebx
  801db5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dbb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dc0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dc6:	eb 2d                	jmp    801df5 <devcons_write+0x46>
		m = n - tot;
  801dc8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dcb:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dcd:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dd0:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801dd5:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dd8:	83 ec 04             	sub    $0x4,%esp
  801ddb:	53                   	push   %ebx
  801ddc:	03 45 0c             	add    0xc(%ebp),%eax
  801ddf:	50                   	push   %eax
  801de0:	57                   	push   %edi
  801de1:	e8 63 eb ff ff       	call   800949 <memmove>
		sys_cputs(buf, m);
  801de6:	83 c4 08             	add    $0x8,%esp
  801de9:	53                   	push   %ebx
  801dea:	57                   	push   %edi
  801deb:	e8 0e ed ff ff       	call   800afe <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801df0:	01 de                	add    %ebx,%esi
  801df2:	83 c4 10             	add    $0x10,%esp
  801df5:	89 f0                	mov    %esi,%eax
  801df7:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dfa:	72 cc                	jb     801dc8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dff:	5b                   	pop    %ebx
  801e00:	5e                   	pop    %esi
  801e01:	5f                   	pop    %edi
  801e02:	5d                   	pop    %ebp
  801e03:	c3                   	ret    

00801e04 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e04:	55                   	push   %ebp
  801e05:	89 e5                	mov    %esp,%ebp
  801e07:	83 ec 08             	sub    $0x8,%esp
  801e0a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e0f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e13:	74 2a                	je     801e3f <devcons_read+0x3b>
  801e15:	eb 05                	jmp    801e1c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e17:	e8 7f ed ff ff       	call   800b9b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e1c:	e8 fb ec ff ff       	call   800b1c <sys_cgetc>
  801e21:	85 c0                	test   %eax,%eax
  801e23:	74 f2                	je     801e17 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e25:	85 c0                	test   %eax,%eax
  801e27:	78 16                	js     801e3f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e29:	83 f8 04             	cmp    $0x4,%eax
  801e2c:	74 0c                	je     801e3a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e31:	88 02                	mov    %al,(%edx)
	return 1;
  801e33:	b8 01 00 00 00       	mov    $0x1,%eax
  801e38:	eb 05                	jmp    801e3f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e3a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e3f:	c9                   	leave  
  801e40:	c3                   	ret    

00801e41 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e41:	55                   	push   %ebp
  801e42:	89 e5                	mov    %esp,%ebp
  801e44:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e47:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e4d:	6a 01                	push   $0x1
  801e4f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e52:	50                   	push   %eax
  801e53:	e8 a6 ec ff ff       	call   800afe <sys_cputs>
}
  801e58:	83 c4 10             	add    $0x10,%esp
  801e5b:	c9                   	leave  
  801e5c:	c3                   	ret    

00801e5d <getchar>:

int
getchar(void)
{
  801e5d:	55                   	push   %ebp
  801e5e:	89 e5                	mov    %esp,%ebp
  801e60:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e63:	6a 01                	push   $0x1
  801e65:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e68:	50                   	push   %eax
  801e69:	6a 00                	push   $0x0
  801e6b:	e8 36 f2 ff ff       	call   8010a6 <read>
	if (r < 0)
  801e70:	83 c4 10             	add    $0x10,%esp
  801e73:	85 c0                	test   %eax,%eax
  801e75:	78 0f                	js     801e86 <getchar+0x29>
		return r;
	if (r < 1)
  801e77:	85 c0                	test   %eax,%eax
  801e79:	7e 06                	jle    801e81 <getchar+0x24>
		return -E_EOF;
	return c;
  801e7b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e7f:	eb 05                	jmp    801e86 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e81:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e86:	c9                   	leave  
  801e87:	c3                   	ret    

00801e88 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e88:	55                   	push   %ebp
  801e89:	89 e5                	mov    %esp,%ebp
  801e8b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e91:	50                   	push   %eax
  801e92:	ff 75 08             	pushl  0x8(%ebp)
  801e95:	e8 a6 ef ff ff       	call   800e40 <fd_lookup>
  801e9a:	83 c4 10             	add    $0x10,%esp
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	78 11                	js     801eb2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801eaa:	39 10                	cmp    %edx,(%eax)
  801eac:	0f 94 c0             	sete   %al
  801eaf:	0f b6 c0             	movzbl %al,%eax
}
  801eb2:	c9                   	leave  
  801eb3:	c3                   	ret    

00801eb4 <opencons>:

int
opencons(void)
{
  801eb4:	55                   	push   %ebp
  801eb5:	89 e5                	mov    %esp,%ebp
  801eb7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ebd:	50                   	push   %eax
  801ebe:	e8 2e ef ff ff       	call   800df1 <fd_alloc>
  801ec3:	83 c4 10             	add    $0x10,%esp
		return r;
  801ec6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ec8:	85 c0                	test   %eax,%eax
  801eca:	78 3e                	js     801f0a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ecc:	83 ec 04             	sub    $0x4,%esp
  801ecf:	68 07 04 00 00       	push   $0x407
  801ed4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ed7:	6a 00                	push   $0x0
  801ed9:	e8 dc ec ff ff       	call   800bba <sys_page_alloc>
  801ede:	83 c4 10             	add    $0x10,%esp
		return r;
  801ee1:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ee3:	85 c0                	test   %eax,%eax
  801ee5:	78 23                	js     801f0a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ee7:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801efc:	83 ec 0c             	sub    $0xc,%esp
  801eff:	50                   	push   %eax
  801f00:	e8 c5 ee ff ff       	call   800dca <fd2num>
  801f05:	89 c2                	mov    %eax,%edx
  801f07:	83 c4 10             	add    $0x10,%esp
}
  801f0a:	89 d0                	mov    %edx,%eax
  801f0c:	c9                   	leave  
  801f0d:	c3                   	ret    

00801f0e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f0e:	55                   	push   %ebp
  801f0f:	89 e5                	mov    %esp,%ebp
  801f11:	56                   	push   %esi
  801f12:	53                   	push   %ebx
  801f13:	8b 75 08             	mov    0x8(%ebp),%esi
  801f16:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f19:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801f1c:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801f1e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f23:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801f26:	83 ec 0c             	sub    $0xc,%esp
  801f29:	50                   	push   %eax
  801f2a:	e8 3b ee ff ff       	call   800d6a <sys_ipc_recv>

	if (from_env_store != NULL)
  801f2f:	83 c4 10             	add    $0x10,%esp
  801f32:	85 f6                	test   %esi,%esi
  801f34:	74 14                	je     801f4a <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801f36:	ba 00 00 00 00       	mov    $0x0,%edx
  801f3b:	85 c0                	test   %eax,%eax
  801f3d:	78 09                	js     801f48 <ipc_recv+0x3a>
  801f3f:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f45:	8b 52 74             	mov    0x74(%edx),%edx
  801f48:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801f4a:	85 db                	test   %ebx,%ebx
  801f4c:	74 14                	je     801f62 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801f4e:	ba 00 00 00 00       	mov    $0x0,%edx
  801f53:	85 c0                	test   %eax,%eax
  801f55:	78 09                	js     801f60 <ipc_recv+0x52>
  801f57:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f5d:	8b 52 78             	mov    0x78(%edx),%edx
  801f60:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801f62:	85 c0                	test   %eax,%eax
  801f64:	78 08                	js     801f6e <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801f66:	a1 08 40 80 00       	mov    0x804008,%eax
  801f6b:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f6e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f71:	5b                   	pop    %ebx
  801f72:	5e                   	pop    %esi
  801f73:	5d                   	pop    %ebp
  801f74:	c3                   	ret    

00801f75 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f75:	55                   	push   %ebp
  801f76:	89 e5                	mov    %esp,%ebp
  801f78:	57                   	push   %edi
  801f79:	56                   	push   %esi
  801f7a:	53                   	push   %ebx
  801f7b:	83 ec 0c             	sub    $0xc,%esp
  801f7e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f81:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f84:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f87:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f89:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f8e:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f91:	ff 75 14             	pushl  0x14(%ebp)
  801f94:	53                   	push   %ebx
  801f95:	56                   	push   %esi
  801f96:	57                   	push   %edi
  801f97:	e8 ab ed ff ff       	call   800d47 <sys_ipc_try_send>

		if (err < 0) {
  801f9c:	83 c4 10             	add    $0x10,%esp
  801f9f:	85 c0                	test   %eax,%eax
  801fa1:	79 1e                	jns    801fc1 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801fa3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fa6:	75 07                	jne    801faf <ipc_send+0x3a>
				sys_yield();
  801fa8:	e8 ee eb ff ff       	call   800b9b <sys_yield>
  801fad:	eb e2                	jmp    801f91 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801faf:	50                   	push   %eax
  801fb0:	68 b7 27 80 00       	push   $0x8027b7
  801fb5:	6a 49                	push   $0x49
  801fb7:	68 c4 27 80 00       	push   $0x8027c4
  801fbc:	e8 98 e1 ff ff       	call   800159 <_panic>
		}

	} while (err < 0);

}
  801fc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fc4:	5b                   	pop    %ebx
  801fc5:	5e                   	pop    %esi
  801fc6:	5f                   	pop    %edi
  801fc7:	5d                   	pop    %ebp
  801fc8:	c3                   	ret    

00801fc9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fc9:	55                   	push   %ebp
  801fca:	89 e5                	mov    %esp,%ebp
  801fcc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fcf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fd4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fd7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fdd:	8b 52 50             	mov    0x50(%edx),%edx
  801fe0:	39 ca                	cmp    %ecx,%edx
  801fe2:	75 0d                	jne    801ff1 <ipc_find_env+0x28>
			return envs[i].env_id;
  801fe4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fe7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fec:	8b 40 48             	mov    0x48(%eax),%eax
  801fef:	eb 0f                	jmp    802000 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ff1:	83 c0 01             	add    $0x1,%eax
  801ff4:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ff9:	75 d9                	jne    801fd4 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ffb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802000:	5d                   	pop    %ebp
  802001:	c3                   	ret    

00802002 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802002:	55                   	push   %ebp
  802003:	89 e5                	mov    %esp,%ebp
  802005:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802008:	89 d0                	mov    %edx,%eax
  80200a:	c1 e8 16             	shr    $0x16,%eax
  80200d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802014:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802019:	f6 c1 01             	test   $0x1,%cl
  80201c:	74 1d                	je     80203b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80201e:	c1 ea 0c             	shr    $0xc,%edx
  802021:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802028:	f6 c2 01             	test   $0x1,%dl
  80202b:	74 0e                	je     80203b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80202d:	c1 ea 0c             	shr    $0xc,%edx
  802030:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802037:	ef 
  802038:	0f b7 c0             	movzwl %ax,%eax
}
  80203b:	5d                   	pop    %ebp
  80203c:	c3                   	ret    
  80203d:	66 90                	xchg   %ax,%ax
  80203f:	90                   	nop

00802040 <__udivdi3>:
  802040:	55                   	push   %ebp
  802041:	57                   	push   %edi
  802042:	56                   	push   %esi
  802043:	53                   	push   %ebx
  802044:	83 ec 1c             	sub    $0x1c,%esp
  802047:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80204b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80204f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802053:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802057:	85 f6                	test   %esi,%esi
  802059:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80205d:	89 ca                	mov    %ecx,%edx
  80205f:	89 f8                	mov    %edi,%eax
  802061:	75 3d                	jne    8020a0 <__udivdi3+0x60>
  802063:	39 cf                	cmp    %ecx,%edi
  802065:	0f 87 c5 00 00 00    	ja     802130 <__udivdi3+0xf0>
  80206b:	85 ff                	test   %edi,%edi
  80206d:	89 fd                	mov    %edi,%ebp
  80206f:	75 0b                	jne    80207c <__udivdi3+0x3c>
  802071:	b8 01 00 00 00       	mov    $0x1,%eax
  802076:	31 d2                	xor    %edx,%edx
  802078:	f7 f7                	div    %edi
  80207a:	89 c5                	mov    %eax,%ebp
  80207c:	89 c8                	mov    %ecx,%eax
  80207e:	31 d2                	xor    %edx,%edx
  802080:	f7 f5                	div    %ebp
  802082:	89 c1                	mov    %eax,%ecx
  802084:	89 d8                	mov    %ebx,%eax
  802086:	89 cf                	mov    %ecx,%edi
  802088:	f7 f5                	div    %ebp
  80208a:	89 c3                	mov    %eax,%ebx
  80208c:	89 d8                	mov    %ebx,%eax
  80208e:	89 fa                	mov    %edi,%edx
  802090:	83 c4 1c             	add    $0x1c,%esp
  802093:	5b                   	pop    %ebx
  802094:	5e                   	pop    %esi
  802095:	5f                   	pop    %edi
  802096:	5d                   	pop    %ebp
  802097:	c3                   	ret    
  802098:	90                   	nop
  802099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	39 ce                	cmp    %ecx,%esi
  8020a2:	77 74                	ja     802118 <__udivdi3+0xd8>
  8020a4:	0f bd fe             	bsr    %esi,%edi
  8020a7:	83 f7 1f             	xor    $0x1f,%edi
  8020aa:	0f 84 98 00 00 00    	je     802148 <__udivdi3+0x108>
  8020b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020b5:	89 f9                	mov    %edi,%ecx
  8020b7:	89 c5                	mov    %eax,%ebp
  8020b9:	29 fb                	sub    %edi,%ebx
  8020bb:	d3 e6                	shl    %cl,%esi
  8020bd:	89 d9                	mov    %ebx,%ecx
  8020bf:	d3 ed                	shr    %cl,%ebp
  8020c1:	89 f9                	mov    %edi,%ecx
  8020c3:	d3 e0                	shl    %cl,%eax
  8020c5:	09 ee                	or     %ebp,%esi
  8020c7:	89 d9                	mov    %ebx,%ecx
  8020c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020cd:	89 d5                	mov    %edx,%ebp
  8020cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020d3:	d3 ed                	shr    %cl,%ebp
  8020d5:	89 f9                	mov    %edi,%ecx
  8020d7:	d3 e2                	shl    %cl,%edx
  8020d9:	89 d9                	mov    %ebx,%ecx
  8020db:	d3 e8                	shr    %cl,%eax
  8020dd:	09 c2                	or     %eax,%edx
  8020df:	89 d0                	mov    %edx,%eax
  8020e1:	89 ea                	mov    %ebp,%edx
  8020e3:	f7 f6                	div    %esi
  8020e5:	89 d5                	mov    %edx,%ebp
  8020e7:	89 c3                	mov    %eax,%ebx
  8020e9:	f7 64 24 0c          	mull   0xc(%esp)
  8020ed:	39 d5                	cmp    %edx,%ebp
  8020ef:	72 10                	jb     802101 <__udivdi3+0xc1>
  8020f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020f5:	89 f9                	mov    %edi,%ecx
  8020f7:	d3 e6                	shl    %cl,%esi
  8020f9:	39 c6                	cmp    %eax,%esi
  8020fb:	73 07                	jae    802104 <__udivdi3+0xc4>
  8020fd:	39 d5                	cmp    %edx,%ebp
  8020ff:	75 03                	jne    802104 <__udivdi3+0xc4>
  802101:	83 eb 01             	sub    $0x1,%ebx
  802104:	31 ff                	xor    %edi,%edi
  802106:	89 d8                	mov    %ebx,%eax
  802108:	89 fa                	mov    %edi,%edx
  80210a:	83 c4 1c             	add    $0x1c,%esp
  80210d:	5b                   	pop    %ebx
  80210e:	5e                   	pop    %esi
  80210f:	5f                   	pop    %edi
  802110:	5d                   	pop    %ebp
  802111:	c3                   	ret    
  802112:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802118:	31 ff                	xor    %edi,%edi
  80211a:	31 db                	xor    %ebx,%ebx
  80211c:	89 d8                	mov    %ebx,%eax
  80211e:	89 fa                	mov    %edi,%edx
  802120:	83 c4 1c             	add    $0x1c,%esp
  802123:	5b                   	pop    %ebx
  802124:	5e                   	pop    %esi
  802125:	5f                   	pop    %edi
  802126:	5d                   	pop    %ebp
  802127:	c3                   	ret    
  802128:	90                   	nop
  802129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802130:	89 d8                	mov    %ebx,%eax
  802132:	f7 f7                	div    %edi
  802134:	31 ff                	xor    %edi,%edi
  802136:	89 c3                	mov    %eax,%ebx
  802138:	89 d8                	mov    %ebx,%eax
  80213a:	89 fa                	mov    %edi,%edx
  80213c:	83 c4 1c             	add    $0x1c,%esp
  80213f:	5b                   	pop    %ebx
  802140:	5e                   	pop    %esi
  802141:	5f                   	pop    %edi
  802142:	5d                   	pop    %ebp
  802143:	c3                   	ret    
  802144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802148:	39 ce                	cmp    %ecx,%esi
  80214a:	72 0c                	jb     802158 <__udivdi3+0x118>
  80214c:	31 db                	xor    %ebx,%ebx
  80214e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802152:	0f 87 34 ff ff ff    	ja     80208c <__udivdi3+0x4c>
  802158:	bb 01 00 00 00       	mov    $0x1,%ebx
  80215d:	e9 2a ff ff ff       	jmp    80208c <__udivdi3+0x4c>
  802162:	66 90                	xchg   %ax,%ax
  802164:	66 90                	xchg   %ax,%ax
  802166:	66 90                	xchg   %ax,%ax
  802168:	66 90                	xchg   %ax,%ax
  80216a:	66 90                	xchg   %ax,%ax
  80216c:	66 90                	xchg   %ax,%ax
  80216e:	66 90                	xchg   %ax,%ax

00802170 <__umoddi3>:
  802170:	55                   	push   %ebp
  802171:	57                   	push   %edi
  802172:	56                   	push   %esi
  802173:	53                   	push   %ebx
  802174:	83 ec 1c             	sub    $0x1c,%esp
  802177:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80217b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80217f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802183:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802187:	85 d2                	test   %edx,%edx
  802189:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80218d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802191:	89 f3                	mov    %esi,%ebx
  802193:	89 3c 24             	mov    %edi,(%esp)
  802196:	89 74 24 04          	mov    %esi,0x4(%esp)
  80219a:	75 1c                	jne    8021b8 <__umoddi3+0x48>
  80219c:	39 f7                	cmp    %esi,%edi
  80219e:	76 50                	jbe    8021f0 <__umoddi3+0x80>
  8021a0:	89 c8                	mov    %ecx,%eax
  8021a2:	89 f2                	mov    %esi,%edx
  8021a4:	f7 f7                	div    %edi
  8021a6:	89 d0                	mov    %edx,%eax
  8021a8:	31 d2                	xor    %edx,%edx
  8021aa:	83 c4 1c             	add    $0x1c,%esp
  8021ad:	5b                   	pop    %ebx
  8021ae:	5e                   	pop    %esi
  8021af:	5f                   	pop    %edi
  8021b0:	5d                   	pop    %ebp
  8021b1:	c3                   	ret    
  8021b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021b8:	39 f2                	cmp    %esi,%edx
  8021ba:	89 d0                	mov    %edx,%eax
  8021bc:	77 52                	ja     802210 <__umoddi3+0xa0>
  8021be:	0f bd ea             	bsr    %edx,%ebp
  8021c1:	83 f5 1f             	xor    $0x1f,%ebp
  8021c4:	75 5a                	jne    802220 <__umoddi3+0xb0>
  8021c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021ca:	0f 82 e0 00 00 00    	jb     8022b0 <__umoddi3+0x140>
  8021d0:	39 0c 24             	cmp    %ecx,(%esp)
  8021d3:	0f 86 d7 00 00 00    	jbe    8022b0 <__umoddi3+0x140>
  8021d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021e1:	83 c4 1c             	add    $0x1c,%esp
  8021e4:	5b                   	pop    %ebx
  8021e5:	5e                   	pop    %esi
  8021e6:	5f                   	pop    %edi
  8021e7:	5d                   	pop    %ebp
  8021e8:	c3                   	ret    
  8021e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	85 ff                	test   %edi,%edi
  8021f2:	89 fd                	mov    %edi,%ebp
  8021f4:	75 0b                	jne    802201 <__umoddi3+0x91>
  8021f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021fb:	31 d2                	xor    %edx,%edx
  8021fd:	f7 f7                	div    %edi
  8021ff:	89 c5                	mov    %eax,%ebp
  802201:	89 f0                	mov    %esi,%eax
  802203:	31 d2                	xor    %edx,%edx
  802205:	f7 f5                	div    %ebp
  802207:	89 c8                	mov    %ecx,%eax
  802209:	f7 f5                	div    %ebp
  80220b:	89 d0                	mov    %edx,%eax
  80220d:	eb 99                	jmp    8021a8 <__umoddi3+0x38>
  80220f:	90                   	nop
  802210:	89 c8                	mov    %ecx,%eax
  802212:	89 f2                	mov    %esi,%edx
  802214:	83 c4 1c             	add    $0x1c,%esp
  802217:	5b                   	pop    %ebx
  802218:	5e                   	pop    %esi
  802219:	5f                   	pop    %edi
  80221a:	5d                   	pop    %ebp
  80221b:	c3                   	ret    
  80221c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802220:	8b 34 24             	mov    (%esp),%esi
  802223:	bf 20 00 00 00       	mov    $0x20,%edi
  802228:	89 e9                	mov    %ebp,%ecx
  80222a:	29 ef                	sub    %ebp,%edi
  80222c:	d3 e0                	shl    %cl,%eax
  80222e:	89 f9                	mov    %edi,%ecx
  802230:	89 f2                	mov    %esi,%edx
  802232:	d3 ea                	shr    %cl,%edx
  802234:	89 e9                	mov    %ebp,%ecx
  802236:	09 c2                	or     %eax,%edx
  802238:	89 d8                	mov    %ebx,%eax
  80223a:	89 14 24             	mov    %edx,(%esp)
  80223d:	89 f2                	mov    %esi,%edx
  80223f:	d3 e2                	shl    %cl,%edx
  802241:	89 f9                	mov    %edi,%ecx
  802243:	89 54 24 04          	mov    %edx,0x4(%esp)
  802247:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80224b:	d3 e8                	shr    %cl,%eax
  80224d:	89 e9                	mov    %ebp,%ecx
  80224f:	89 c6                	mov    %eax,%esi
  802251:	d3 e3                	shl    %cl,%ebx
  802253:	89 f9                	mov    %edi,%ecx
  802255:	89 d0                	mov    %edx,%eax
  802257:	d3 e8                	shr    %cl,%eax
  802259:	89 e9                	mov    %ebp,%ecx
  80225b:	09 d8                	or     %ebx,%eax
  80225d:	89 d3                	mov    %edx,%ebx
  80225f:	89 f2                	mov    %esi,%edx
  802261:	f7 34 24             	divl   (%esp)
  802264:	89 d6                	mov    %edx,%esi
  802266:	d3 e3                	shl    %cl,%ebx
  802268:	f7 64 24 04          	mull   0x4(%esp)
  80226c:	39 d6                	cmp    %edx,%esi
  80226e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802272:	89 d1                	mov    %edx,%ecx
  802274:	89 c3                	mov    %eax,%ebx
  802276:	72 08                	jb     802280 <__umoddi3+0x110>
  802278:	75 11                	jne    80228b <__umoddi3+0x11b>
  80227a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80227e:	73 0b                	jae    80228b <__umoddi3+0x11b>
  802280:	2b 44 24 04          	sub    0x4(%esp),%eax
  802284:	1b 14 24             	sbb    (%esp),%edx
  802287:	89 d1                	mov    %edx,%ecx
  802289:	89 c3                	mov    %eax,%ebx
  80228b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80228f:	29 da                	sub    %ebx,%edx
  802291:	19 ce                	sbb    %ecx,%esi
  802293:	89 f9                	mov    %edi,%ecx
  802295:	89 f0                	mov    %esi,%eax
  802297:	d3 e0                	shl    %cl,%eax
  802299:	89 e9                	mov    %ebp,%ecx
  80229b:	d3 ea                	shr    %cl,%edx
  80229d:	89 e9                	mov    %ebp,%ecx
  80229f:	d3 ee                	shr    %cl,%esi
  8022a1:	09 d0                	or     %edx,%eax
  8022a3:	89 f2                	mov    %esi,%edx
  8022a5:	83 c4 1c             	add    $0x1c,%esp
  8022a8:	5b                   	pop    %ebx
  8022a9:	5e                   	pop    %esi
  8022aa:	5f                   	pop    %edi
  8022ab:	5d                   	pop    %ebp
  8022ac:	c3                   	ret    
  8022ad:	8d 76 00             	lea    0x0(%esi),%esi
  8022b0:	29 f9                	sub    %edi,%ecx
  8022b2:	19 d6                	sbb    %edx,%esi
  8022b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022bc:	e9 18 ff ff ff       	jmp    8021d9 <__umoddi3+0x69>
