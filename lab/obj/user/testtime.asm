
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
  800057:	68 60 23 80 00       	push   $0x802360
  80005c:	6a 0b                	push   $0xb
  80005e:	68 72 23 80 00       	push   $0x802372
  800063:	e8 f1 00 00 00       	call   800159 <_panic>
	if (end < now)
  800068:	39 d8                	cmp    %ebx,%eax
  80006a:	76 19                	jbe    800085 <sleep+0x52>
		panic("sleep: wrap");
  80006c:	83 ec 04             	sub    $0x4,%esp
  80006f:	68 82 23 80 00       	push   $0x802382
  800074:	6a 0d                	push   $0xd
  800076:	68 72 23 80 00       	push   $0x802372
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
  8000ac:	68 8e 23 80 00       	push   $0x80238e
  8000b1:	e8 7c 01 00 00       	call   800232 <cprintf>
  8000b6:	83 c4 10             	add    $0x10,%esp
	for (i = 5; i >= 0; i--) {
  8000b9:	bb 05 00 00 00       	mov    $0x5,%ebx
		cprintf("%d ", i);
  8000be:	83 ec 08             	sub    $0x8,%esp
  8000c1:	53                   	push   %ebx
  8000c2:	68 a4 23 80 00       	push   $0x8023a4
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
  8000e6:	68 24 28 80 00       	push   $0x802824
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
  800145:	e8 cf 0e 00 00       	call   801019 <close_all>
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
  800177:	68 b4 23 80 00       	push   $0x8023b4
  80017c:	e8 b1 00 00 00       	call   800232 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800181:	83 c4 18             	add    $0x18,%esp
  800184:	53                   	push   %ebx
  800185:	ff 75 10             	pushl  0x10(%ebp)
  800188:	e8 54 00 00 00       	call   8001e1 <vcprintf>
	cprintf("\n");
  80018d:	c7 04 24 24 28 80 00 	movl   $0x802824,(%esp)
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
  800295:	e8 36 1e 00 00       	call   8020d0 <__udivdi3>
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
  8002d8:	e8 23 1f 00 00       	call   802200 <__umoddi3>
  8002dd:	83 c4 14             	add    $0x14,%esp
  8002e0:	0f be 80 d7 23 80 00 	movsbl 0x8023d7(%eax),%eax
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
  8003dc:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
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
  8004a0:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  8004a7:	85 d2                	test   %edx,%edx
  8004a9:	75 18                	jne    8004c3 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004ab:	50                   	push   %eax
  8004ac:	68 ef 23 80 00       	push   $0x8023ef
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
  8004c4:	68 b9 27 80 00       	push   $0x8027b9
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
  8004e8:	b8 e8 23 80 00       	mov    $0x8023e8,%eax
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
  800b63:	68 df 26 80 00       	push   $0x8026df
  800b68:	6a 23                	push   $0x23
  800b6a:	68 fc 26 80 00       	push   $0x8026fc
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
  800be4:	68 df 26 80 00       	push   $0x8026df
  800be9:	6a 23                	push   $0x23
  800beb:	68 fc 26 80 00       	push   $0x8026fc
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
  800c26:	68 df 26 80 00       	push   $0x8026df
  800c2b:	6a 23                	push   $0x23
  800c2d:	68 fc 26 80 00       	push   $0x8026fc
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
  800c68:	68 df 26 80 00       	push   $0x8026df
  800c6d:	6a 23                	push   $0x23
  800c6f:	68 fc 26 80 00       	push   $0x8026fc
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
  800caa:	68 df 26 80 00       	push   $0x8026df
  800caf:	6a 23                	push   $0x23
  800cb1:	68 fc 26 80 00       	push   $0x8026fc
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
  800cec:	68 df 26 80 00       	push   $0x8026df
  800cf1:	6a 23                	push   $0x23
  800cf3:	68 fc 26 80 00       	push   $0x8026fc
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
  800d2e:	68 df 26 80 00       	push   $0x8026df
  800d33:	6a 23                	push   $0x23
  800d35:	68 fc 26 80 00       	push   $0x8026fc
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
  800d92:	68 df 26 80 00       	push   $0x8026df
  800d97:	6a 23                	push   $0x23
  800d99:	68 fc 26 80 00       	push   $0x8026fc
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
  800df3:	68 df 26 80 00       	push   $0x8026df
  800df8:	6a 23                	push   $0x23
  800dfa:	68 fc 26 80 00       	push   $0x8026fc
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

00800e0c <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	57                   	push   %edi
  800e10:	56                   	push   %esi
  800e11:	53                   	push   %ebx
  800e12:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e15:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1a:	b8 10 00 00 00       	mov    $0x10,%eax
  800e1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e22:	8b 55 08             	mov    0x8(%ebp),%edx
  800e25:	89 df                	mov    %ebx,%edi
  800e27:	89 de                	mov    %ebx,%esi
  800e29:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e2b:	85 c0                	test   %eax,%eax
  800e2d:	7e 17                	jle    800e46 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2f:	83 ec 0c             	sub    $0xc,%esp
  800e32:	50                   	push   %eax
  800e33:	6a 10                	push   $0x10
  800e35:	68 df 26 80 00       	push   $0x8026df
  800e3a:	6a 23                	push   $0x23
  800e3c:	68 fc 26 80 00       	push   $0x8026fc
  800e41:	e8 13 f3 ff ff       	call   800159 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  800e46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e49:	5b                   	pop    %ebx
  800e4a:	5e                   	pop    %esi
  800e4b:	5f                   	pop    %edi
  800e4c:	5d                   	pop    %ebp
  800e4d:	c3                   	ret    

00800e4e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e51:	8b 45 08             	mov    0x8(%ebp),%eax
  800e54:	05 00 00 00 30       	add    $0x30000000,%eax
  800e59:	c1 e8 0c             	shr    $0xc,%eax
}
  800e5c:	5d                   	pop    %ebp
  800e5d:	c3                   	ret    

00800e5e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e61:	8b 45 08             	mov    0x8(%ebp),%eax
  800e64:	05 00 00 00 30       	add    $0x30000000,%eax
  800e69:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e6e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    

00800e75 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e80:	89 c2                	mov    %eax,%edx
  800e82:	c1 ea 16             	shr    $0x16,%edx
  800e85:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e8c:	f6 c2 01             	test   $0x1,%dl
  800e8f:	74 11                	je     800ea2 <fd_alloc+0x2d>
  800e91:	89 c2                	mov    %eax,%edx
  800e93:	c1 ea 0c             	shr    $0xc,%edx
  800e96:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e9d:	f6 c2 01             	test   $0x1,%dl
  800ea0:	75 09                	jne    800eab <fd_alloc+0x36>
			*fd_store = fd;
  800ea2:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ea4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea9:	eb 17                	jmp    800ec2 <fd_alloc+0x4d>
  800eab:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800eb0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800eb5:	75 c9                	jne    800e80 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800eb7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ebd:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    

00800ec4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800eca:	83 f8 1f             	cmp    $0x1f,%eax
  800ecd:	77 36                	ja     800f05 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ecf:	c1 e0 0c             	shl    $0xc,%eax
  800ed2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ed7:	89 c2                	mov    %eax,%edx
  800ed9:	c1 ea 16             	shr    $0x16,%edx
  800edc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ee3:	f6 c2 01             	test   $0x1,%dl
  800ee6:	74 24                	je     800f0c <fd_lookup+0x48>
  800ee8:	89 c2                	mov    %eax,%edx
  800eea:	c1 ea 0c             	shr    $0xc,%edx
  800eed:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ef4:	f6 c2 01             	test   $0x1,%dl
  800ef7:	74 1a                	je     800f13 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ef9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800efc:	89 02                	mov    %eax,(%edx)
	return 0;
  800efe:	b8 00 00 00 00       	mov    $0x0,%eax
  800f03:	eb 13                	jmp    800f18 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f05:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f0a:	eb 0c                	jmp    800f18 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f0c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f11:	eb 05                	jmp    800f18 <fd_lookup+0x54>
  800f13:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    

00800f1a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	83 ec 08             	sub    $0x8,%esp
  800f20:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f23:	ba 8c 27 80 00       	mov    $0x80278c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f28:	eb 13                	jmp    800f3d <dev_lookup+0x23>
  800f2a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f2d:	39 08                	cmp    %ecx,(%eax)
  800f2f:	75 0c                	jne    800f3d <dev_lookup+0x23>
			*dev = devtab[i];
  800f31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f34:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f36:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3b:	eb 2e                	jmp    800f6b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f3d:	8b 02                	mov    (%edx),%eax
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	75 e7                	jne    800f2a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f43:	a1 08 40 80 00       	mov    0x804008,%eax
  800f48:	8b 40 48             	mov    0x48(%eax),%eax
  800f4b:	83 ec 04             	sub    $0x4,%esp
  800f4e:	51                   	push   %ecx
  800f4f:	50                   	push   %eax
  800f50:	68 0c 27 80 00       	push   $0x80270c
  800f55:	e8 d8 f2 ff ff       	call   800232 <cprintf>
	*dev = 0;
  800f5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f5d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f63:	83 c4 10             	add    $0x10,%esp
  800f66:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f6b:	c9                   	leave  
  800f6c:	c3                   	ret    

00800f6d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	56                   	push   %esi
  800f71:	53                   	push   %ebx
  800f72:	83 ec 10             	sub    $0x10,%esp
  800f75:	8b 75 08             	mov    0x8(%ebp),%esi
  800f78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f7e:	50                   	push   %eax
  800f7f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f85:	c1 e8 0c             	shr    $0xc,%eax
  800f88:	50                   	push   %eax
  800f89:	e8 36 ff ff ff       	call   800ec4 <fd_lookup>
  800f8e:	83 c4 08             	add    $0x8,%esp
  800f91:	85 c0                	test   %eax,%eax
  800f93:	78 05                	js     800f9a <fd_close+0x2d>
	    || fd != fd2)
  800f95:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f98:	74 0c                	je     800fa6 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f9a:	84 db                	test   %bl,%bl
  800f9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa1:	0f 44 c2             	cmove  %edx,%eax
  800fa4:	eb 41                	jmp    800fe7 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fa6:	83 ec 08             	sub    $0x8,%esp
  800fa9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fac:	50                   	push   %eax
  800fad:	ff 36                	pushl  (%esi)
  800faf:	e8 66 ff ff ff       	call   800f1a <dev_lookup>
  800fb4:	89 c3                	mov    %eax,%ebx
  800fb6:	83 c4 10             	add    $0x10,%esp
  800fb9:	85 c0                	test   %eax,%eax
  800fbb:	78 1a                	js     800fd7 <fd_close+0x6a>
		if (dev->dev_close)
  800fbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fc0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fc3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fc8:	85 c0                	test   %eax,%eax
  800fca:	74 0b                	je     800fd7 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fcc:	83 ec 0c             	sub    $0xc,%esp
  800fcf:	56                   	push   %esi
  800fd0:	ff d0                	call   *%eax
  800fd2:	89 c3                	mov    %eax,%ebx
  800fd4:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fd7:	83 ec 08             	sub    $0x8,%esp
  800fda:	56                   	push   %esi
  800fdb:	6a 00                	push   $0x0
  800fdd:	e8 5d fc ff ff       	call   800c3f <sys_page_unmap>
	return r;
  800fe2:	83 c4 10             	add    $0x10,%esp
  800fe5:	89 d8                	mov    %ebx,%eax
}
  800fe7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fea:	5b                   	pop    %ebx
  800feb:	5e                   	pop    %esi
  800fec:	5d                   	pop    %ebp
  800fed:	c3                   	ret    

00800fee <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fee:	55                   	push   %ebp
  800fef:	89 e5                	mov    %esp,%ebp
  800ff1:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ff4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff7:	50                   	push   %eax
  800ff8:	ff 75 08             	pushl  0x8(%ebp)
  800ffb:	e8 c4 fe ff ff       	call   800ec4 <fd_lookup>
  801000:	83 c4 08             	add    $0x8,%esp
  801003:	85 c0                	test   %eax,%eax
  801005:	78 10                	js     801017 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801007:	83 ec 08             	sub    $0x8,%esp
  80100a:	6a 01                	push   $0x1
  80100c:	ff 75 f4             	pushl  -0xc(%ebp)
  80100f:	e8 59 ff ff ff       	call   800f6d <fd_close>
  801014:	83 c4 10             	add    $0x10,%esp
}
  801017:	c9                   	leave  
  801018:	c3                   	ret    

00801019 <close_all>:

void
close_all(void)
{
  801019:	55                   	push   %ebp
  80101a:	89 e5                	mov    %esp,%ebp
  80101c:	53                   	push   %ebx
  80101d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801020:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801025:	83 ec 0c             	sub    $0xc,%esp
  801028:	53                   	push   %ebx
  801029:	e8 c0 ff ff ff       	call   800fee <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80102e:	83 c3 01             	add    $0x1,%ebx
  801031:	83 c4 10             	add    $0x10,%esp
  801034:	83 fb 20             	cmp    $0x20,%ebx
  801037:	75 ec                	jne    801025 <close_all+0xc>
		close(i);
}
  801039:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80103c:	c9                   	leave  
  80103d:	c3                   	ret    

0080103e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80103e:	55                   	push   %ebp
  80103f:	89 e5                	mov    %esp,%ebp
  801041:	57                   	push   %edi
  801042:	56                   	push   %esi
  801043:	53                   	push   %ebx
  801044:	83 ec 2c             	sub    $0x2c,%esp
  801047:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80104a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80104d:	50                   	push   %eax
  80104e:	ff 75 08             	pushl  0x8(%ebp)
  801051:	e8 6e fe ff ff       	call   800ec4 <fd_lookup>
  801056:	83 c4 08             	add    $0x8,%esp
  801059:	85 c0                	test   %eax,%eax
  80105b:	0f 88 c1 00 00 00    	js     801122 <dup+0xe4>
		return r;
	close(newfdnum);
  801061:	83 ec 0c             	sub    $0xc,%esp
  801064:	56                   	push   %esi
  801065:	e8 84 ff ff ff       	call   800fee <close>

	newfd = INDEX2FD(newfdnum);
  80106a:	89 f3                	mov    %esi,%ebx
  80106c:	c1 e3 0c             	shl    $0xc,%ebx
  80106f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801075:	83 c4 04             	add    $0x4,%esp
  801078:	ff 75 e4             	pushl  -0x1c(%ebp)
  80107b:	e8 de fd ff ff       	call   800e5e <fd2data>
  801080:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801082:	89 1c 24             	mov    %ebx,(%esp)
  801085:	e8 d4 fd ff ff       	call   800e5e <fd2data>
  80108a:	83 c4 10             	add    $0x10,%esp
  80108d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801090:	89 f8                	mov    %edi,%eax
  801092:	c1 e8 16             	shr    $0x16,%eax
  801095:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80109c:	a8 01                	test   $0x1,%al
  80109e:	74 37                	je     8010d7 <dup+0x99>
  8010a0:	89 f8                	mov    %edi,%eax
  8010a2:	c1 e8 0c             	shr    $0xc,%eax
  8010a5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010ac:	f6 c2 01             	test   $0x1,%dl
  8010af:	74 26                	je     8010d7 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010b1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010b8:	83 ec 0c             	sub    $0xc,%esp
  8010bb:	25 07 0e 00 00       	and    $0xe07,%eax
  8010c0:	50                   	push   %eax
  8010c1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010c4:	6a 00                	push   $0x0
  8010c6:	57                   	push   %edi
  8010c7:	6a 00                	push   $0x0
  8010c9:	e8 2f fb ff ff       	call   800bfd <sys_page_map>
  8010ce:	89 c7                	mov    %eax,%edi
  8010d0:	83 c4 20             	add    $0x20,%esp
  8010d3:	85 c0                	test   %eax,%eax
  8010d5:	78 2e                	js     801105 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010d7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010da:	89 d0                	mov    %edx,%eax
  8010dc:	c1 e8 0c             	shr    $0xc,%eax
  8010df:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010e6:	83 ec 0c             	sub    $0xc,%esp
  8010e9:	25 07 0e 00 00       	and    $0xe07,%eax
  8010ee:	50                   	push   %eax
  8010ef:	53                   	push   %ebx
  8010f0:	6a 00                	push   $0x0
  8010f2:	52                   	push   %edx
  8010f3:	6a 00                	push   $0x0
  8010f5:	e8 03 fb ff ff       	call   800bfd <sys_page_map>
  8010fa:	89 c7                	mov    %eax,%edi
  8010fc:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010ff:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801101:	85 ff                	test   %edi,%edi
  801103:	79 1d                	jns    801122 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801105:	83 ec 08             	sub    $0x8,%esp
  801108:	53                   	push   %ebx
  801109:	6a 00                	push   $0x0
  80110b:	e8 2f fb ff ff       	call   800c3f <sys_page_unmap>
	sys_page_unmap(0, nva);
  801110:	83 c4 08             	add    $0x8,%esp
  801113:	ff 75 d4             	pushl  -0x2c(%ebp)
  801116:	6a 00                	push   $0x0
  801118:	e8 22 fb ff ff       	call   800c3f <sys_page_unmap>
	return r;
  80111d:	83 c4 10             	add    $0x10,%esp
  801120:	89 f8                	mov    %edi,%eax
}
  801122:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801125:	5b                   	pop    %ebx
  801126:	5e                   	pop    %esi
  801127:	5f                   	pop    %edi
  801128:	5d                   	pop    %ebp
  801129:	c3                   	ret    

0080112a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80112a:	55                   	push   %ebp
  80112b:	89 e5                	mov    %esp,%ebp
  80112d:	53                   	push   %ebx
  80112e:	83 ec 14             	sub    $0x14,%esp
  801131:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801134:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801137:	50                   	push   %eax
  801138:	53                   	push   %ebx
  801139:	e8 86 fd ff ff       	call   800ec4 <fd_lookup>
  80113e:	83 c4 08             	add    $0x8,%esp
  801141:	89 c2                	mov    %eax,%edx
  801143:	85 c0                	test   %eax,%eax
  801145:	78 6d                	js     8011b4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801147:	83 ec 08             	sub    $0x8,%esp
  80114a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80114d:	50                   	push   %eax
  80114e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801151:	ff 30                	pushl  (%eax)
  801153:	e8 c2 fd ff ff       	call   800f1a <dev_lookup>
  801158:	83 c4 10             	add    $0x10,%esp
  80115b:	85 c0                	test   %eax,%eax
  80115d:	78 4c                	js     8011ab <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80115f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801162:	8b 42 08             	mov    0x8(%edx),%eax
  801165:	83 e0 03             	and    $0x3,%eax
  801168:	83 f8 01             	cmp    $0x1,%eax
  80116b:	75 21                	jne    80118e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80116d:	a1 08 40 80 00       	mov    0x804008,%eax
  801172:	8b 40 48             	mov    0x48(%eax),%eax
  801175:	83 ec 04             	sub    $0x4,%esp
  801178:	53                   	push   %ebx
  801179:	50                   	push   %eax
  80117a:	68 50 27 80 00       	push   $0x802750
  80117f:	e8 ae f0 ff ff       	call   800232 <cprintf>
		return -E_INVAL;
  801184:	83 c4 10             	add    $0x10,%esp
  801187:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80118c:	eb 26                	jmp    8011b4 <read+0x8a>
	}
	if (!dev->dev_read)
  80118e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801191:	8b 40 08             	mov    0x8(%eax),%eax
  801194:	85 c0                	test   %eax,%eax
  801196:	74 17                	je     8011af <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801198:	83 ec 04             	sub    $0x4,%esp
  80119b:	ff 75 10             	pushl  0x10(%ebp)
  80119e:	ff 75 0c             	pushl  0xc(%ebp)
  8011a1:	52                   	push   %edx
  8011a2:	ff d0                	call   *%eax
  8011a4:	89 c2                	mov    %eax,%edx
  8011a6:	83 c4 10             	add    $0x10,%esp
  8011a9:	eb 09                	jmp    8011b4 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ab:	89 c2                	mov    %eax,%edx
  8011ad:	eb 05                	jmp    8011b4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011af:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011b4:	89 d0                	mov    %edx,%eax
  8011b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b9:	c9                   	leave  
  8011ba:	c3                   	ret    

008011bb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011bb:	55                   	push   %ebp
  8011bc:	89 e5                	mov    %esp,%ebp
  8011be:	57                   	push   %edi
  8011bf:	56                   	push   %esi
  8011c0:	53                   	push   %ebx
  8011c1:	83 ec 0c             	sub    $0xc,%esp
  8011c4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011c7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011ca:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011cf:	eb 21                	jmp    8011f2 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011d1:	83 ec 04             	sub    $0x4,%esp
  8011d4:	89 f0                	mov    %esi,%eax
  8011d6:	29 d8                	sub    %ebx,%eax
  8011d8:	50                   	push   %eax
  8011d9:	89 d8                	mov    %ebx,%eax
  8011db:	03 45 0c             	add    0xc(%ebp),%eax
  8011de:	50                   	push   %eax
  8011df:	57                   	push   %edi
  8011e0:	e8 45 ff ff ff       	call   80112a <read>
		if (m < 0)
  8011e5:	83 c4 10             	add    $0x10,%esp
  8011e8:	85 c0                	test   %eax,%eax
  8011ea:	78 10                	js     8011fc <readn+0x41>
			return m;
		if (m == 0)
  8011ec:	85 c0                	test   %eax,%eax
  8011ee:	74 0a                	je     8011fa <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011f0:	01 c3                	add    %eax,%ebx
  8011f2:	39 f3                	cmp    %esi,%ebx
  8011f4:	72 db                	jb     8011d1 <readn+0x16>
  8011f6:	89 d8                	mov    %ebx,%eax
  8011f8:	eb 02                	jmp    8011fc <readn+0x41>
  8011fa:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ff:	5b                   	pop    %ebx
  801200:	5e                   	pop    %esi
  801201:	5f                   	pop    %edi
  801202:	5d                   	pop    %ebp
  801203:	c3                   	ret    

00801204 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801204:	55                   	push   %ebp
  801205:	89 e5                	mov    %esp,%ebp
  801207:	53                   	push   %ebx
  801208:	83 ec 14             	sub    $0x14,%esp
  80120b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80120e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801211:	50                   	push   %eax
  801212:	53                   	push   %ebx
  801213:	e8 ac fc ff ff       	call   800ec4 <fd_lookup>
  801218:	83 c4 08             	add    $0x8,%esp
  80121b:	89 c2                	mov    %eax,%edx
  80121d:	85 c0                	test   %eax,%eax
  80121f:	78 68                	js     801289 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801221:	83 ec 08             	sub    $0x8,%esp
  801224:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801227:	50                   	push   %eax
  801228:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122b:	ff 30                	pushl  (%eax)
  80122d:	e8 e8 fc ff ff       	call   800f1a <dev_lookup>
  801232:	83 c4 10             	add    $0x10,%esp
  801235:	85 c0                	test   %eax,%eax
  801237:	78 47                	js     801280 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801239:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801240:	75 21                	jne    801263 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801242:	a1 08 40 80 00       	mov    0x804008,%eax
  801247:	8b 40 48             	mov    0x48(%eax),%eax
  80124a:	83 ec 04             	sub    $0x4,%esp
  80124d:	53                   	push   %ebx
  80124e:	50                   	push   %eax
  80124f:	68 6c 27 80 00       	push   $0x80276c
  801254:	e8 d9 ef ff ff       	call   800232 <cprintf>
		return -E_INVAL;
  801259:	83 c4 10             	add    $0x10,%esp
  80125c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801261:	eb 26                	jmp    801289 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801263:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801266:	8b 52 0c             	mov    0xc(%edx),%edx
  801269:	85 d2                	test   %edx,%edx
  80126b:	74 17                	je     801284 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80126d:	83 ec 04             	sub    $0x4,%esp
  801270:	ff 75 10             	pushl  0x10(%ebp)
  801273:	ff 75 0c             	pushl  0xc(%ebp)
  801276:	50                   	push   %eax
  801277:	ff d2                	call   *%edx
  801279:	89 c2                	mov    %eax,%edx
  80127b:	83 c4 10             	add    $0x10,%esp
  80127e:	eb 09                	jmp    801289 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801280:	89 c2                	mov    %eax,%edx
  801282:	eb 05                	jmp    801289 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801284:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801289:	89 d0                	mov    %edx,%eax
  80128b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80128e:	c9                   	leave  
  80128f:	c3                   	ret    

00801290 <seek>:

int
seek(int fdnum, off_t offset)
{
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
  801293:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801296:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801299:	50                   	push   %eax
  80129a:	ff 75 08             	pushl  0x8(%ebp)
  80129d:	e8 22 fc ff ff       	call   800ec4 <fd_lookup>
  8012a2:	83 c4 08             	add    $0x8,%esp
  8012a5:	85 c0                	test   %eax,%eax
  8012a7:	78 0e                	js     8012b7 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012af:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012b7:	c9                   	leave  
  8012b8:	c3                   	ret    

008012b9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012b9:	55                   	push   %ebp
  8012ba:	89 e5                	mov    %esp,%ebp
  8012bc:	53                   	push   %ebx
  8012bd:	83 ec 14             	sub    $0x14,%esp
  8012c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012c6:	50                   	push   %eax
  8012c7:	53                   	push   %ebx
  8012c8:	e8 f7 fb ff ff       	call   800ec4 <fd_lookup>
  8012cd:	83 c4 08             	add    $0x8,%esp
  8012d0:	89 c2                	mov    %eax,%edx
  8012d2:	85 c0                	test   %eax,%eax
  8012d4:	78 65                	js     80133b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d6:	83 ec 08             	sub    $0x8,%esp
  8012d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012dc:	50                   	push   %eax
  8012dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e0:	ff 30                	pushl  (%eax)
  8012e2:	e8 33 fc ff ff       	call   800f1a <dev_lookup>
  8012e7:	83 c4 10             	add    $0x10,%esp
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	78 44                	js     801332 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012f5:	75 21                	jne    801318 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012f7:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012fc:	8b 40 48             	mov    0x48(%eax),%eax
  8012ff:	83 ec 04             	sub    $0x4,%esp
  801302:	53                   	push   %ebx
  801303:	50                   	push   %eax
  801304:	68 2c 27 80 00       	push   $0x80272c
  801309:	e8 24 ef ff ff       	call   800232 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80130e:	83 c4 10             	add    $0x10,%esp
  801311:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801316:	eb 23                	jmp    80133b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801318:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80131b:	8b 52 18             	mov    0x18(%edx),%edx
  80131e:	85 d2                	test   %edx,%edx
  801320:	74 14                	je     801336 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801322:	83 ec 08             	sub    $0x8,%esp
  801325:	ff 75 0c             	pushl  0xc(%ebp)
  801328:	50                   	push   %eax
  801329:	ff d2                	call   *%edx
  80132b:	89 c2                	mov    %eax,%edx
  80132d:	83 c4 10             	add    $0x10,%esp
  801330:	eb 09                	jmp    80133b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801332:	89 c2                	mov    %eax,%edx
  801334:	eb 05                	jmp    80133b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801336:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80133b:	89 d0                	mov    %edx,%eax
  80133d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801340:	c9                   	leave  
  801341:	c3                   	ret    

00801342 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801342:	55                   	push   %ebp
  801343:	89 e5                	mov    %esp,%ebp
  801345:	53                   	push   %ebx
  801346:	83 ec 14             	sub    $0x14,%esp
  801349:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80134c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80134f:	50                   	push   %eax
  801350:	ff 75 08             	pushl  0x8(%ebp)
  801353:	e8 6c fb ff ff       	call   800ec4 <fd_lookup>
  801358:	83 c4 08             	add    $0x8,%esp
  80135b:	89 c2                	mov    %eax,%edx
  80135d:	85 c0                	test   %eax,%eax
  80135f:	78 58                	js     8013b9 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801361:	83 ec 08             	sub    $0x8,%esp
  801364:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801367:	50                   	push   %eax
  801368:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136b:	ff 30                	pushl  (%eax)
  80136d:	e8 a8 fb ff ff       	call   800f1a <dev_lookup>
  801372:	83 c4 10             	add    $0x10,%esp
  801375:	85 c0                	test   %eax,%eax
  801377:	78 37                	js     8013b0 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801379:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80137c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801380:	74 32                	je     8013b4 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801382:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801385:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80138c:	00 00 00 
	stat->st_isdir = 0;
  80138f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801396:	00 00 00 
	stat->st_dev = dev;
  801399:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80139f:	83 ec 08             	sub    $0x8,%esp
  8013a2:	53                   	push   %ebx
  8013a3:	ff 75 f0             	pushl  -0x10(%ebp)
  8013a6:	ff 50 14             	call   *0x14(%eax)
  8013a9:	89 c2                	mov    %eax,%edx
  8013ab:	83 c4 10             	add    $0x10,%esp
  8013ae:	eb 09                	jmp    8013b9 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b0:	89 c2                	mov    %eax,%edx
  8013b2:	eb 05                	jmp    8013b9 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013b4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013b9:	89 d0                	mov    %edx,%eax
  8013bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013be:	c9                   	leave  
  8013bf:	c3                   	ret    

008013c0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
  8013c3:	56                   	push   %esi
  8013c4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013c5:	83 ec 08             	sub    $0x8,%esp
  8013c8:	6a 00                	push   $0x0
  8013ca:	ff 75 08             	pushl  0x8(%ebp)
  8013cd:	e8 d6 01 00 00       	call   8015a8 <open>
  8013d2:	89 c3                	mov    %eax,%ebx
  8013d4:	83 c4 10             	add    $0x10,%esp
  8013d7:	85 c0                	test   %eax,%eax
  8013d9:	78 1b                	js     8013f6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013db:	83 ec 08             	sub    $0x8,%esp
  8013de:	ff 75 0c             	pushl  0xc(%ebp)
  8013e1:	50                   	push   %eax
  8013e2:	e8 5b ff ff ff       	call   801342 <fstat>
  8013e7:	89 c6                	mov    %eax,%esi
	close(fd);
  8013e9:	89 1c 24             	mov    %ebx,(%esp)
  8013ec:	e8 fd fb ff ff       	call   800fee <close>
	return r;
  8013f1:	83 c4 10             	add    $0x10,%esp
  8013f4:	89 f0                	mov    %esi,%eax
}
  8013f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f9:	5b                   	pop    %ebx
  8013fa:	5e                   	pop    %esi
  8013fb:	5d                   	pop    %ebp
  8013fc:	c3                   	ret    

008013fd <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013fd:	55                   	push   %ebp
  8013fe:	89 e5                	mov    %esp,%ebp
  801400:	56                   	push   %esi
  801401:	53                   	push   %ebx
  801402:	89 c6                	mov    %eax,%esi
  801404:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801406:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80140d:	75 12                	jne    801421 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80140f:	83 ec 0c             	sub    $0xc,%esp
  801412:	6a 01                	push   $0x1
  801414:	e8 34 0c 00 00       	call   80204d <ipc_find_env>
  801419:	a3 00 40 80 00       	mov    %eax,0x804000
  80141e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801421:	6a 07                	push   $0x7
  801423:	68 00 50 80 00       	push   $0x805000
  801428:	56                   	push   %esi
  801429:	ff 35 00 40 80 00    	pushl  0x804000
  80142f:	e8 c5 0b 00 00       	call   801ff9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801434:	83 c4 0c             	add    $0xc,%esp
  801437:	6a 00                	push   $0x0
  801439:	53                   	push   %ebx
  80143a:	6a 00                	push   $0x0
  80143c:	e8 51 0b 00 00       	call   801f92 <ipc_recv>
}
  801441:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801444:	5b                   	pop    %ebx
  801445:	5e                   	pop    %esi
  801446:	5d                   	pop    %ebp
  801447:	c3                   	ret    

00801448 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80144e:	8b 45 08             	mov    0x8(%ebp),%eax
  801451:	8b 40 0c             	mov    0xc(%eax),%eax
  801454:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801459:	8b 45 0c             	mov    0xc(%ebp),%eax
  80145c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801461:	ba 00 00 00 00       	mov    $0x0,%edx
  801466:	b8 02 00 00 00       	mov    $0x2,%eax
  80146b:	e8 8d ff ff ff       	call   8013fd <fsipc>
}
  801470:	c9                   	leave  
  801471:	c3                   	ret    

00801472 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801472:	55                   	push   %ebp
  801473:	89 e5                	mov    %esp,%ebp
  801475:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801478:	8b 45 08             	mov    0x8(%ebp),%eax
  80147b:	8b 40 0c             	mov    0xc(%eax),%eax
  80147e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801483:	ba 00 00 00 00       	mov    $0x0,%edx
  801488:	b8 06 00 00 00       	mov    $0x6,%eax
  80148d:	e8 6b ff ff ff       	call   8013fd <fsipc>
}
  801492:	c9                   	leave  
  801493:	c3                   	ret    

00801494 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801494:	55                   	push   %ebp
  801495:	89 e5                	mov    %esp,%ebp
  801497:	53                   	push   %ebx
  801498:	83 ec 04             	sub    $0x4,%esp
  80149b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80149e:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a1:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a4:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ae:	b8 05 00 00 00       	mov    $0x5,%eax
  8014b3:	e8 45 ff ff ff       	call   8013fd <fsipc>
  8014b8:	85 c0                	test   %eax,%eax
  8014ba:	78 2c                	js     8014e8 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014bc:	83 ec 08             	sub    $0x8,%esp
  8014bf:	68 00 50 80 00       	push   $0x805000
  8014c4:	53                   	push   %ebx
  8014c5:	e8 ed f2 ff ff       	call   8007b7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014ca:	a1 80 50 80 00       	mov    0x805080,%eax
  8014cf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014d5:	a1 84 50 80 00       	mov    0x805084,%eax
  8014da:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014e0:	83 c4 10             	add    $0x10,%esp
  8014e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014eb:	c9                   	leave  
  8014ec:	c3                   	ret    

008014ed <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014ed:	55                   	push   %ebp
  8014ee:	89 e5                	mov    %esp,%ebp
  8014f0:	83 ec 0c             	sub    $0xc,%esp
  8014f3:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8014f9:	8b 52 0c             	mov    0xc(%edx),%edx
  8014fc:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801502:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801507:	50                   	push   %eax
  801508:	ff 75 0c             	pushl  0xc(%ebp)
  80150b:	68 08 50 80 00       	push   $0x805008
  801510:	e8 34 f4 ff ff       	call   800949 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801515:	ba 00 00 00 00       	mov    $0x0,%edx
  80151a:	b8 04 00 00 00       	mov    $0x4,%eax
  80151f:	e8 d9 fe ff ff       	call   8013fd <fsipc>

}
  801524:	c9                   	leave  
  801525:	c3                   	ret    

00801526 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801526:	55                   	push   %ebp
  801527:	89 e5                	mov    %esp,%ebp
  801529:	56                   	push   %esi
  80152a:	53                   	push   %ebx
  80152b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80152e:	8b 45 08             	mov    0x8(%ebp),%eax
  801531:	8b 40 0c             	mov    0xc(%eax),%eax
  801534:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801539:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80153f:	ba 00 00 00 00       	mov    $0x0,%edx
  801544:	b8 03 00 00 00       	mov    $0x3,%eax
  801549:	e8 af fe ff ff       	call   8013fd <fsipc>
  80154e:	89 c3                	mov    %eax,%ebx
  801550:	85 c0                	test   %eax,%eax
  801552:	78 4b                	js     80159f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801554:	39 c6                	cmp    %eax,%esi
  801556:	73 16                	jae    80156e <devfile_read+0x48>
  801558:	68 a0 27 80 00       	push   $0x8027a0
  80155d:	68 a7 27 80 00       	push   $0x8027a7
  801562:	6a 7c                	push   $0x7c
  801564:	68 bc 27 80 00       	push   $0x8027bc
  801569:	e8 eb eb ff ff       	call   800159 <_panic>
	assert(r <= PGSIZE);
  80156e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801573:	7e 16                	jle    80158b <devfile_read+0x65>
  801575:	68 c7 27 80 00       	push   $0x8027c7
  80157a:	68 a7 27 80 00       	push   $0x8027a7
  80157f:	6a 7d                	push   $0x7d
  801581:	68 bc 27 80 00       	push   $0x8027bc
  801586:	e8 ce eb ff ff       	call   800159 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80158b:	83 ec 04             	sub    $0x4,%esp
  80158e:	50                   	push   %eax
  80158f:	68 00 50 80 00       	push   $0x805000
  801594:	ff 75 0c             	pushl  0xc(%ebp)
  801597:	e8 ad f3 ff ff       	call   800949 <memmove>
	return r;
  80159c:	83 c4 10             	add    $0x10,%esp
}
  80159f:	89 d8                	mov    %ebx,%eax
  8015a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a4:	5b                   	pop    %ebx
  8015a5:	5e                   	pop    %esi
  8015a6:	5d                   	pop    %ebp
  8015a7:	c3                   	ret    

008015a8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015a8:	55                   	push   %ebp
  8015a9:	89 e5                	mov    %esp,%ebp
  8015ab:	53                   	push   %ebx
  8015ac:	83 ec 20             	sub    $0x20,%esp
  8015af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015b2:	53                   	push   %ebx
  8015b3:	e8 c6 f1 ff ff       	call   80077e <strlen>
  8015b8:	83 c4 10             	add    $0x10,%esp
  8015bb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015c0:	7f 67                	jg     801629 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015c2:	83 ec 0c             	sub    $0xc,%esp
  8015c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c8:	50                   	push   %eax
  8015c9:	e8 a7 f8 ff ff       	call   800e75 <fd_alloc>
  8015ce:	83 c4 10             	add    $0x10,%esp
		return r;
  8015d1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	78 57                	js     80162e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015d7:	83 ec 08             	sub    $0x8,%esp
  8015da:	53                   	push   %ebx
  8015db:	68 00 50 80 00       	push   $0x805000
  8015e0:	e8 d2 f1 ff ff       	call   8007b7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015e8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8015f5:	e8 03 fe ff ff       	call   8013fd <fsipc>
  8015fa:	89 c3                	mov    %eax,%ebx
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	85 c0                	test   %eax,%eax
  801601:	79 14                	jns    801617 <open+0x6f>
		fd_close(fd, 0);
  801603:	83 ec 08             	sub    $0x8,%esp
  801606:	6a 00                	push   $0x0
  801608:	ff 75 f4             	pushl  -0xc(%ebp)
  80160b:	e8 5d f9 ff ff       	call   800f6d <fd_close>
		return r;
  801610:	83 c4 10             	add    $0x10,%esp
  801613:	89 da                	mov    %ebx,%edx
  801615:	eb 17                	jmp    80162e <open+0x86>
	}

	return fd2num(fd);
  801617:	83 ec 0c             	sub    $0xc,%esp
  80161a:	ff 75 f4             	pushl  -0xc(%ebp)
  80161d:	e8 2c f8 ff ff       	call   800e4e <fd2num>
  801622:	89 c2                	mov    %eax,%edx
  801624:	83 c4 10             	add    $0x10,%esp
  801627:	eb 05                	jmp    80162e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801629:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80162e:	89 d0                	mov    %edx,%eax
  801630:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801633:	c9                   	leave  
  801634:	c3                   	ret    

00801635 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801635:	55                   	push   %ebp
  801636:	89 e5                	mov    %esp,%ebp
  801638:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80163b:	ba 00 00 00 00       	mov    $0x0,%edx
  801640:	b8 08 00 00 00       	mov    $0x8,%eax
  801645:	e8 b3 fd ff ff       	call   8013fd <fsipc>
}
  80164a:	c9                   	leave  
  80164b:	c3                   	ret    

0080164c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80164c:	55                   	push   %ebp
  80164d:	89 e5                	mov    %esp,%ebp
  80164f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801652:	68 d3 27 80 00       	push   $0x8027d3
  801657:	ff 75 0c             	pushl  0xc(%ebp)
  80165a:	e8 58 f1 ff ff       	call   8007b7 <strcpy>
	return 0;
}
  80165f:	b8 00 00 00 00       	mov    $0x0,%eax
  801664:	c9                   	leave  
  801665:	c3                   	ret    

00801666 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801666:	55                   	push   %ebp
  801667:	89 e5                	mov    %esp,%ebp
  801669:	53                   	push   %ebx
  80166a:	83 ec 10             	sub    $0x10,%esp
  80166d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801670:	53                   	push   %ebx
  801671:	e8 10 0a 00 00       	call   802086 <pageref>
  801676:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801679:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80167e:	83 f8 01             	cmp    $0x1,%eax
  801681:	75 10                	jne    801693 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801683:	83 ec 0c             	sub    $0xc,%esp
  801686:	ff 73 0c             	pushl  0xc(%ebx)
  801689:	e8 c0 02 00 00       	call   80194e <nsipc_close>
  80168e:	89 c2                	mov    %eax,%edx
  801690:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801693:	89 d0                	mov    %edx,%eax
  801695:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801698:	c9                   	leave  
  801699:	c3                   	ret    

0080169a <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8016a0:	6a 00                	push   $0x0
  8016a2:	ff 75 10             	pushl  0x10(%ebp)
  8016a5:	ff 75 0c             	pushl  0xc(%ebp)
  8016a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ab:	ff 70 0c             	pushl  0xc(%eax)
  8016ae:	e8 78 03 00 00       	call   801a2b <nsipc_send>
}
  8016b3:	c9                   	leave  
  8016b4:	c3                   	ret    

008016b5 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8016bb:	6a 00                	push   $0x0
  8016bd:	ff 75 10             	pushl  0x10(%ebp)
  8016c0:	ff 75 0c             	pushl  0xc(%ebp)
  8016c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c6:	ff 70 0c             	pushl  0xc(%eax)
  8016c9:	e8 f1 02 00 00       	call   8019bf <nsipc_recv>
}
  8016ce:	c9                   	leave  
  8016cf:	c3                   	ret    

008016d0 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
  8016d3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8016d6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8016d9:	52                   	push   %edx
  8016da:	50                   	push   %eax
  8016db:	e8 e4 f7 ff ff       	call   800ec4 <fd_lookup>
  8016e0:	83 c4 10             	add    $0x10,%esp
  8016e3:	85 c0                	test   %eax,%eax
  8016e5:	78 17                	js     8016fe <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8016e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ea:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8016f0:	39 08                	cmp    %ecx,(%eax)
  8016f2:	75 05                	jne    8016f9 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8016f4:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f7:	eb 05                	jmp    8016fe <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8016f9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8016fe:	c9                   	leave  
  8016ff:	c3                   	ret    

00801700 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
  801703:	56                   	push   %esi
  801704:	53                   	push   %ebx
  801705:	83 ec 1c             	sub    $0x1c,%esp
  801708:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80170a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80170d:	50                   	push   %eax
  80170e:	e8 62 f7 ff ff       	call   800e75 <fd_alloc>
  801713:	89 c3                	mov    %eax,%ebx
  801715:	83 c4 10             	add    $0x10,%esp
  801718:	85 c0                	test   %eax,%eax
  80171a:	78 1b                	js     801737 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80171c:	83 ec 04             	sub    $0x4,%esp
  80171f:	68 07 04 00 00       	push   $0x407
  801724:	ff 75 f4             	pushl  -0xc(%ebp)
  801727:	6a 00                	push   $0x0
  801729:	e8 8c f4 ff ff       	call   800bba <sys_page_alloc>
  80172e:	89 c3                	mov    %eax,%ebx
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	85 c0                	test   %eax,%eax
  801735:	79 10                	jns    801747 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801737:	83 ec 0c             	sub    $0xc,%esp
  80173a:	56                   	push   %esi
  80173b:	e8 0e 02 00 00       	call   80194e <nsipc_close>
		return r;
  801740:	83 c4 10             	add    $0x10,%esp
  801743:	89 d8                	mov    %ebx,%eax
  801745:	eb 24                	jmp    80176b <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801747:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80174d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801750:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801752:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801755:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80175c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80175f:	83 ec 0c             	sub    $0xc,%esp
  801762:	50                   	push   %eax
  801763:	e8 e6 f6 ff ff       	call   800e4e <fd2num>
  801768:	83 c4 10             	add    $0x10,%esp
}
  80176b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80176e:	5b                   	pop    %ebx
  80176f:	5e                   	pop    %esi
  801770:	5d                   	pop    %ebp
  801771:	c3                   	ret    

00801772 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801772:	55                   	push   %ebp
  801773:	89 e5                	mov    %esp,%ebp
  801775:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801778:	8b 45 08             	mov    0x8(%ebp),%eax
  80177b:	e8 50 ff ff ff       	call   8016d0 <fd2sockid>
		return r;
  801780:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801782:	85 c0                	test   %eax,%eax
  801784:	78 1f                	js     8017a5 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801786:	83 ec 04             	sub    $0x4,%esp
  801789:	ff 75 10             	pushl  0x10(%ebp)
  80178c:	ff 75 0c             	pushl  0xc(%ebp)
  80178f:	50                   	push   %eax
  801790:	e8 12 01 00 00       	call   8018a7 <nsipc_accept>
  801795:	83 c4 10             	add    $0x10,%esp
		return r;
  801798:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80179a:	85 c0                	test   %eax,%eax
  80179c:	78 07                	js     8017a5 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80179e:	e8 5d ff ff ff       	call   801700 <alloc_sockfd>
  8017a3:	89 c1                	mov    %eax,%ecx
}
  8017a5:	89 c8                	mov    %ecx,%eax
  8017a7:	c9                   	leave  
  8017a8:	c3                   	ret    

008017a9 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8017a9:	55                   	push   %ebp
  8017aa:	89 e5                	mov    %esp,%ebp
  8017ac:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017af:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b2:	e8 19 ff ff ff       	call   8016d0 <fd2sockid>
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	78 12                	js     8017cd <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8017bb:	83 ec 04             	sub    $0x4,%esp
  8017be:	ff 75 10             	pushl  0x10(%ebp)
  8017c1:	ff 75 0c             	pushl  0xc(%ebp)
  8017c4:	50                   	push   %eax
  8017c5:	e8 2d 01 00 00       	call   8018f7 <nsipc_bind>
  8017ca:	83 c4 10             	add    $0x10,%esp
}
  8017cd:	c9                   	leave  
  8017ce:	c3                   	ret    

008017cf <shutdown>:

int
shutdown(int s, int how)
{
  8017cf:	55                   	push   %ebp
  8017d0:	89 e5                	mov    %esp,%ebp
  8017d2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d8:	e8 f3 fe ff ff       	call   8016d0 <fd2sockid>
  8017dd:	85 c0                	test   %eax,%eax
  8017df:	78 0f                	js     8017f0 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8017e1:	83 ec 08             	sub    $0x8,%esp
  8017e4:	ff 75 0c             	pushl  0xc(%ebp)
  8017e7:	50                   	push   %eax
  8017e8:	e8 3f 01 00 00       	call   80192c <nsipc_shutdown>
  8017ed:	83 c4 10             	add    $0x10,%esp
}
  8017f0:	c9                   	leave  
  8017f1:	c3                   	ret    

008017f2 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fb:	e8 d0 fe ff ff       	call   8016d0 <fd2sockid>
  801800:	85 c0                	test   %eax,%eax
  801802:	78 12                	js     801816 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801804:	83 ec 04             	sub    $0x4,%esp
  801807:	ff 75 10             	pushl  0x10(%ebp)
  80180a:	ff 75 0c             	pushl  0xc(%ebp)
  80180d:	50                   	push   %eax
  80180e:	e8 55 01 00 00       	call   801968 <nsipc_connect>
  801813:	83 c4 10             	add    $0x10,%esp
}
  801816:	c9                   	leave  
  801817:	c3                   	ret    

00801818 <listen>:

int
listen(int s, int backlog)
{
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
  80181b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80181e:	8b 45 08             	mov    0x8(%ebp),%eax
  801821:	e8 aa fe ff ff       	call   8016d0 <fd2sockid>
  801826:	85 c0                	test   %eax,%eax
  801828:	78 0f                	js     801839 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80182a:	83 ec 08             	sub    $0x8,%esp
  80182d:	ff 75 0c             	pushl  0xc(%ebp)
  801830:	50                   	push   %eax
  801831:	e8 67 01 00 00       	call   80199d <nsipc_listen>
  801836:	83 c4 10             	add    $0x10,%esp
}
  801839:	c9                   	leave  
  80183a:	c3                   	ret    

0080183b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80183b:	55                   	push   %ebp
  80183c:	89 e5                	mov    %esp,%ebp
  80183e:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801841:	ff 75 10             	pushl  0x10(%ebp)
  801844:	ff 75 0c             	pushl  0xc(%ebp)
  801847:	ff 75 08             	pushl  0x8(%ebp)
  80184a:	e8 3a 02 00 00       	call   801a89 <nsipc_socket>
  80184f:	83 c4 10             	add    $0x10,%esp
  801852:	85 c0                	test   %eax,%eax
  801854:	78 05                	js     80185b <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801856:	e8 a5 fe ff ff       	call   801700 <alloc_sockfd>
}
  80185b:	c9                   	leave  
  80185c:	c3                   	ret    

0080185d <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80185d:	55                   	push   %ebp
  80185e:	89 e5                	mov    %esp,%ebp
  801860:	53                   	push   %ebx
  801861:	83 ec 04             	sub    $0x4,%esp
  801864:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801866:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80186d:	75 12                	jne    801881 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80186f:	83 ec 0c             	sub    $0xc,%esp
  801872:	6a 02                	push   $0x2
  801874:	e8 d4 07 00 00       	call   80204d <ipc_find_env>
  801879:	a3 04 40 80 00       	mov    %eax,0x804004
  80187e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801881:	6a 07                	push   $0x7
  801883:	68 00 60 80 00       	push   $0x806000
  801888:	53                   	push   %ebx
  801889:	ff 35 04 40 80 00    	pushl  0x804004
  80188f:	e8 65 07 00 00       	call   801ff9 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801894:	83 c4 0c             	add    $0xc,%esp
  801897:	6a 00                	push   $0x0
  801899:	6a 00                	push   $0x0
  80189b:	6a 00                	push   $0x0
  80189d:	e8 f0 06 00 00       	call   801f92 <ipc_recv>
}
  8018a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a5:	c9                   	leave  
  8018a6:	c3                   	ret    

008018a7 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	56                   	push   %esi
  8018ab:	53                   	push   %ebx
  8018ac:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8018af:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8018b7:	8b 06                	mov    (%esi),%eax
  8018b9:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8018be:	b8 01 00 00 00       	mov    $0x1,%eax
  8018c3:	e8 95 ff ff ff       	call   80185d <nsipc>
  8018c8:	89 c3                	mov    %eax,%ebx
  8018ca:	85 c0                	test   %eax,%eax
  8018cc:	78 20                	js     8018ee <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8018ce:	83 ec 04             	sub    $0x4,%esp
  8018d1:	ff 35 10 60 80 00    	pushl  0x806010
  8018d7:	68 00 60 80 00       	push   $0x806000
  8018dc:	ff 75 0c             	pushl  0xc(%ebp)
  8018df:	e8 65 f0 ff ff       	call   800949 <memmove>
		*addrlen = ret->ret_addrlen;
  8018e4:	a1 10 60 80 00       	mov    0x806010,%eax
  8018e9:	89 06                	mov    %eax,(%esi)
  8018eb:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8018ee:	89 d8                	mov    %ebx,%eax
  8018f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f3:	5b                   	pop    %ebx
  8018f4:	5e                   	pop    %esi
  8018f5:	5d                   	pop    %ebp
  8018f6:	c3                   	ret    

008018f7 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	53                   	push   %ebx
  8018fb:	83 ec 08             	sub    $0x8,%esp
  8018fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801901:	8b 45 08             	mov    0x8(%ebp),%eax
  801904:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801909:	53                   	push   %ebx
  80190a:	ff 75 0c             	pushl  0xc(%ebp)
  80190d:	68 04 60 80 00       	push   $0x806004
  801912:	e8 32 f0 ff ff       	call   800949 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801917:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80191d:	b8 02 00 00 00       	mov    $0x2,%eax
  801922:	e8 36 ff ff ff       	call   80185d <nsipc>
}
  801927:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80192a:	c9                   	leave  
  80192b:	c3                   	ret    

0080192c <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80192c:	55                   	push   %ebp
  80192d:	89 e5                	mov    %esp,%ebp
  80192f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801932:	8b 45 08             	mov    0x8(%ebp),%eax
  801935:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  80193a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80193d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801942:	b8 03 00 00 00       	mov    $0x3,%eax
  801947:	e8 11 ff ff ff       	call   80185d <nsipc>
}
  80194c:	c9                   	leave  
  80194d:	c3                   	ret    

0080194e <nsipc_close>:

int
nsipc_close(int s)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801954:	8b 45 08             	mov    0x8(%ebp),%eax
  801957:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  80195c:	b8 04 00 00 00       	mov    $0x4,%eax
  801961:	e8 f7 fe ff ff       	call   80185d <nsipc>
}
  801966:	c9                   	leave  
  801967:	c3                   	ret    

00801968 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801968:	55                   	push   %ebp
  801969:	89 e5                	mov    %esp,%ebp
  80196b:	53                   	push   %ebx
  80196c:	83 ec 08             	sub    $0x8,%esp
  80196f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801972:	8b 45 08             	mov    0x8(%ebp),%eax
  801975:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80197a:	53                   	push   %ebx
  80197b:	ff 75 0c             	pushl  0xc(%ebp)
  80197e:	68 04 60 80 00       	push   $0x806004
  801983:	e8 c1 ef ff ff       	call   800949 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801988:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  80198e:	b8 05 00 00 00       	mov    $0x5,%eax
  801993:	e8 c5 fe ff ff       	call   80185d <nsipc>
}
  801998:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80199b:	c9                   	leave  
  80199c:	c3                   	ret    

0080199d <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80199d:	55                   	push   %ebp
  80199e:	89 e5                	mov    %esp,%ebp
  8019a0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8019a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8019ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ae:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8019b3:	b8 06 00 00 00       	mov    $0x6,%eax
  8019b8:	e8 a0 fe ff ff       	call   80185d <nsipc>
}
  8019bd:	c9                   	leave  
  8019be:	c3                   	ret    

008019bf <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8019bf:	55                   	push   %ebp
  8019c0:	89 e5                	mov    %esp,%ebp
  8019c2:	56                   	push   %esi
  8019c3:	53                   	push   %ebx
  8019c4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8019c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ca:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8019cf:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8019d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8019d8:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8019dd:	b8 07 00 00 00       	mov    $0x7,%eax
  8019e2:	e8 76 fe ff ff       	call   80185d <nsipc>
  8019e7:	89 c3                	mov    %eax,%ebx
  8019e9:	85 c0                	test   %eax,%eax
  8019eb:	78 35                	js     801a22 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8019ed:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8019f2:	7f 04                	jg     8019f8 <nsipc_recv+0x39>
  8019f4:	39 c6                	cmp    %eax,%esi
  8019f6:	7d 16                	jge    801a0e <nsipc_recv+0x4f>
  8019f8:	68 df 27 80 00       	push   $0x8027df
  8019fd:	68 a7 27 80 00       	push   $0x8027a7
  801a02:	6a 62                	push   $0x62
  801a04:	68 f4 27 80 00       	push   $0x8027f4
  801a09:	e8 4b e7 ff ff       	call   800159 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801a0e:	83 ec 04             	sub    $0x4,%esp
  801a11:	50                   	push   %eax
  801a12:	68 00 60 80 00       	push   $0x806000
  801a17:	ff 75 0c             	pushl  0xc(%ebp)
  801a1a:	e8 2a ef ff ff       	call   800949 <memmove>
  801a1f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a22:	89 d8                	mov    %ebx,%eax
  801a24:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a27:	5b                   	pop    %ebx
  801a28:	5e                   	pop    %esi
  801a29:	5d                   	pop    %ebp
  801a2a:	c3                   	ret    

00801a2b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	53                   	push   %ebx
  801a2f:	83 ec 04             	sub    $0x4,%esp
  801a32:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a35:	8b 45 08             	mov    0x8(%ebp),%eax
  801a38:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801a3d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a43:	7e 16                	jle    801a5b <nsipc_send+0x30>
  801a45:	68 00 28 80 00       	push   $0x802800
  801a4a:	68 a7 27 80 00       	push   $0x8027a7
  801a4f:	6a 6d                	push   $0x6d
  801a51:	68 f4 27 80 00       	push   $0x8027f4
  801a56:	e8 fe e6 ff ff       	call   800159 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a5b:	83 ec 04             	sub    $0x4,%esp
  801a5e:	53                   	push   %ebx
  801a5f:	ff 75 0c             	pushl  0xc(%ebp)
  801a62:	68 0c 60 80 00       	push   $0x80600c
  801a67:	e8 dd ee ff ff       	call   800949 <memmove>
	nsipcbuf.send.req_size = size;
  801a6c:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801a72:	8b 45 14             	mov    0x14(%ebp),%eax
  801a75:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801a7a:	b8 08 00 00 00       	mov    $0x8,%eax
  801a7f:	e8 d9 fd ff ff       	call   80185d <nsipc>
}
  801a84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a87:	c9                   	leave  
  801a88:	c3                   	ret    

00801a89 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a92:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801a97:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9a:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801a9f:	8b 45 10             	mov    0x10(%ebp),%eax
  801aa2:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801aa7:	b8 09 00 00 00       	mov    $0x9,%eax
  801aac:	e8 ac fd ff ff       	call   80185d <nsipc>
}
  801ab1:	c9                   	leave  
  801ab2:	c3                   	ret    

00801ab3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ab3:	55                   	push   %ebp
  801ab4:	89 e5                	mov    %esp,%ebp
  801ab6:	56                   	push   %esi
  801ab7:	53                   	push   %ebx
  801ab8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801abb:	83 ec 0c             	sub    $0xc,%esp
  801abe:	ff 75 08             	pushl  0x8(%ebp)
  801ac1:	e8 98 f3 ff ff       	call   800e5e <fd2data>
  801ac6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ac8:	83 c4 08             	add    $0x8,%esp
  801acb:	68 0c 28 80 00       	push   $0x80280c
  801ad0:	53                   	push   %ebx
  801ad1:	e8 e1 ec ff ff       	call   8007b7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ad6:	8b 46 04             	mov    0x4(%esi),%eax
  801ad9:	2b 06                	sub    (%esi),%eax
  801adb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ae1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ae8:	00 00 00 
	stat->st_dev = &devpipe;
  801aeb:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801af2:	30 80 00 
	return 0;
}
  801af5:	b8 00 00 00 00       	mov    $0x0,%eax
  801afa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801afd:	5b                   	pop    %ebx
  801afe:	5e                   	pop    %esi
  801aff:	5d                   	pop    %ebp
  801b00:	c3                   	ret    

00801b01 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b01:	55                   	push   %ebp
  801b02:	89 e5                	mov    %esp,%ebp
  801b04:	53                   	push   %ebx
  801b05:	83 ec 0c             	sub    $0xc,%esp
  801b08:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b0b:	53                   	push   %ebx
  801b0c:	6a 00                	push   $0x0
  801b0e:	e8 2c f1 ff ff       	call   800c3f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b13:	89 1c 24             	mov    %ebx,(%esp)
  801b16:	e8 43 f3 ff ff       	call   800e5e <fd2data>
  801b1b:	83 c4 08             	add    $0x8,%esp
  801b1e:	50                   	push   %eax
  801b1f:	6a 00                	push   $0x0
  801b21:	e8 19 f1 ff ff       	call   800c3f <sys_page_unmap>
}
  801b26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b29:	c9                   	leave  
  801b2a:	c3                   	ret    

00801b2b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	57                   	push   %edi
  801b2f:	56                   	push   %esi
  801b30:	53                   	push   %ebx
  801b31:	83 ec 1c             	sub    $0x1c,%esp
  801b34:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b37:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b39:	a1 08 40 80 00       	mov    0x804008,%eax
  801b3e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b41:	83 ec 0c             	sub    $0xc,%esp
  801b44:	ff 75 e0             	pushl  -0x20(%ebp)
  801b47:	e8 3a 05 00 00       	call   802086 <pageref>
  801b4c:	89 c3                	mov    %eax,%ebx
  801b4e:	89 3c 24             	mov    %edi,(%esp)
  801b51:	e8 30 05 00 00       	call   802086 <pageref>
  801b56:	83 c4 10             	add    $0x10,%esp
  801b59:	39 c3                	cmp    %eax,%ebx
  801b5b:	0f 94 c1             	sete   %cl
  801b5e:	0f b6 c9             	movzbl %cl,%ecx
  801b61:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b64:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b6a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b6d:	39 ce                	cmp    %ecx,%esi
  801b6f:	74 1b                	je     801b8c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b71:	39 c3                	cmp    %eax,%ebx
  801b73:	75 c4                	jne    801b39 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b75:	8b 42 58             	mov    0x58(%edx),%eax
  801b78:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b7b:	50                   	push   %eax
  801b7c:	56                   	push   %esi
  801b7d:	68 13 28 80 00       	push   $0x802813
  801b82:	e8 ab e6 ff ff       	call   800232 <cprintf>
  801b87:	83 c4 10             	add    $0x10,%esp
  801b8a:	eb ad                	jmp    801b39 <_pipeisclosed+0xe>
	}
}
  801b8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b92:	5b                   	pop    %ebx
  801b93:	5e                   	pop    %esi
  801b94:	5f                   	pop    %edi
  801b95:	5d                   	pop    %ebp
  801b96:	c3                   	ret    

00801b97 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b97:	55                   	push   %ebp
  801b98:	89 e5                	mov    %esp,%ebp
  801b9a:	57                   	push   %edi
  801b9b:	56                   	push   %esi
  801b9c:	53                   	push   %ebx
  801b9d:	83 ec 28             	sub    $0x28,%esp
  801ba0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ba3:	56                   	push   %esi
  801ba4:	e8 b5 f2 ff ff       	call   800e5e <fd2data>
  801ba9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bab:	83 c4 10             	add    $0x10,%esp
  801bae:	bf 00 00 00 00       	mov    $0x0,%edi
  801bb3:	eb 4b                	jmp    801c00 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bb5:	89 da                	mov    %ebx,%edx
  801bb7:	89 f0                	mov    %esi,%eax
  801bb9:	e8 6d ff ff ff       	call   801b2b <_pipeisclosed>
  801bbe:	85 c0                	test   %eax,%eax
  801bc0:	75 48                	jne    801c0a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bc2:	e8 d4 ef ff ff       	call   800b9b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bc7:	8b 43 04             	mov    0x4(%ebx),%eax
  801bca:	8b 0b                	mov    (%ebx),%ecx
  801bcc:	8d 51 20             	lea    0x20(%ecx),%edx
  801bcf:	39 d0                	cmp    %edx,%eax
  801bd1:	73 e2                	jae    801bb5 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bda:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bdd:	89 c2                	mov    %eax,%edx
  801bdf:	c1 fa 1f             	sar    $0x1f,%edx
  801be2:	89 d1                	mov    %edx,%ecx
  801be4:	c1 e9 1b             	shr    $0x1b,%ecx
  801be7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bea:	83 e2 1f             	and    $0x1f,%edx
  801bed:	29 ca                	sub    %ecx,%edx
  801bef:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bf3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bf7:	83 c0 01             	add    $0x1,%eax
  801bfa:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bfd:	83 c7 01             	add    $0x1,%edi
  801c00:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c03:	75 c2                	jne    801bc7 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c05:	8b 45 10             	mov    0x10(%ebp),%eax
  801c08:	eb 05                	jmp    801c0f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c0a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c12:	5b                   	pop    %ebx
  801c13:	5e                   	pop    %esi
  801c14:	5f                   	pop    %edi
  801c15:	5d                   	pop    %ebp
  801c16:	c3                   	ret    

00801c17 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c17:	55                   	push   %ebp
  801c18:	89 e5                	mov    %esp,%ebp
  801c1a:	57                   	push   %edi
  801c1b:	56                   	push   %esi
  801c1c:	53                   	push   %ebx
  801c1d:	83 ec 18             	sub    $0x18,%esp
  801c20:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c23:	57                   	push   %edi
  801c24:	e8 35 f2 ff ff       	call   800e5e <fd2data>
  801c29:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c2b:	83 c4 10             	add    $0x10,%esp
  801c2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c33:	eb 3d                	jmp    801c72 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c35:	85 db                	test   %ebx,%ebx
  801c37:	74 04                	je     801c3d <devpipe_read+0x26>
				return i;
  801c39:	89 d8                	mov    %ebx,%eax
  801c3b:	eb 44                	jmp    801c81 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c3d:	89 f2                	mov    %esi,%edx
  801c3f:	89 f8                	mov    %edi,%eax
  801c41:	e8 e5 fe ff ff       	call   801b2b <_pipeisclosed>
  801c46:	85 c0                	test   %eax,%eax
  801c48:	75 32                	jne    801c7c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c4a:	e8 4c ef ff ff       	call   800b9b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c4f:	8b 06                	mov    (%esi),%eax
  801c51:	3b 46 04             	cmp    0x4(%esi),%eax
  801c54:	74 df                	je     801c35 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c56:	99                   	cltd   
  801c57:	c1 ea 1b             	shr    $0x1b,%edx
  801c5a:	01 d0                	add    %edx,%eax
  801c5c:	83 e0 1f             	and    $0x1f,%eax
  801c5f:	29 d0                	sub    %edx,%eax
  801c61:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c69:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c6c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c6f:	83 c3 01             	add    $0x1,%ebx
  801c72:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c75:	75 d8                	jne    801c4f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c77:	8b 45 10             	mov    0x10(%ebp),%eax
  801c7a:	eb 05                	jmp    801c81 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c7c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c84:	5b                   	pop    %ebx
  801c85:	5e                   	pop    %esi
  801c86:	5f                   	pop    %edi
  801c87:	5d                   	pop    %ebp
  801c88:	c3                   	ret    

00801c89 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c89:	55                   	push   %ebp
  801c8a:	89 e5                	mov    %esp,%ebp
  801c8c:	56                   	push   %esi
  801c8d:	53                   	push   %ebx
  801c8e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c94:	50                   	push   %eax
  801c95:	e8 db f1 ff ff       	call   800e75 <fd_alloc>
  801c9a:	83 c4 10             	add    $0x10,%esp
  801c9d:	89 c2                	mov    %eax,%edx
  801c9f:	85 c0                	test   %eax,%eax
  801ca1:	0f 88 2c 01 00 00    	js     801dd3 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ca7:	83 ec 04             	sub    $0x4,%esp
  801caa:	68 07 04 00 00       	push   $0x407
  801caf:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb2:	6a 00                	push   $0x0
  801cb4:	e8 01 ef ff ff       	call   800bba <sys_page_alloc>
  801cb9:	83 c4 10             	add    $0x10,%esp
  801cbc:	89 c2                	mov    %eax,%edx
  801cbe:	85 c0                	test   %eax,%eax
  801cc0:	0f 88 0d 01 00 00    	js     801dd3 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cc6:	83 ec 0c             	sub    $0xc,%esp
  801cc9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ccc:	50                   	push   %eax
  801ccd:	e8 a3 f1 ff ff       	call   800e75 <fd_alloc>
  801cd2:	89 c3                	mov    %eax,%ebx
  801cd4:	83 c4 10             	add    $0x10,%esp
  801cd7:	85 c0                	test   %eax,%eax
  801cd9:	0f 88 e2 00 00 00    	js     801dc1 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cdf:	83 ec 04             	sub    $0x4,%esp
  801ce2:	68 07 04 00 00       	push   $0x407
  801ce7:	ff 75 f0             	pushl  -0x10(%ebp)
  801cea:	6a 00                	push   $0x0
  801cec:	e8 c9 ee ff ff       	call   800bba <sys_page_alloc>
  801cf1:	89 c3                	mov    %eax,%ebx
  801cf3:	83 c4 10             	add    $0x10,%esp
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	0f 88 c3 00 00 00    	js     801dc1 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cfe:	83 ec 0c             	sub    $0xc,%esp
  801d01:	ff 75 f4             	pushl  -0xc(%ebp)
  801d04:	e8 55 f1 ff ff       	call   800e5e <fd2data>
  801d09:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d0b:	83 c4 0c             	add    $0xc,%esp
  801d0e:	68 07 04 00 00       	push   $0x407
  801d13:	50                   	push   %eax
  801d14:	6a 00                	push   $0x0
  801d16:	e8 9f ee ff ff       	call   800bba <sys_page_alloc>
  801d1b:	89 c3                	mov    %eax,%ebx
  801d1d:	83 c4 10             	add    $0x10,%esp
  801d20:	85 c0                	test   %eax,%eax
  801d22:	0f 88 89 00 00 00    	js     801db1 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d28:	83 ec 0c             	sub    $0xc,%esp
  801d2b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d2e:	e8 2b f1 ff ff       	call   800e5e <fd2data>
  801d33:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d3a:	50                   	push   %eax
  801d3b:	6a 00                	push   $0x0
  801d3d:	56                   	push   %esi
  801d3e:	6a 00                	push   $0x0
  801d40:	e8 b8 ee ff ff       	call   800bfd <sys_page_map>
  801d45:	89 c3                	mov    %eax,%ebx
  801d47:	83 c4 20             	add    $0x20,%esp
  801d4a:	85 c0                	test   %eax,%eax
  801d4c:	78 55                	js     801da3 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d4e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d57:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d5c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d63:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d6c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d71:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d78:	83 ec 0c             	sub    $0xc,%esp
  801d7b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d7e:	e8 cb f0 ff ff       	call   800e4e <fd2num>
  801d83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d86:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d88:	83 c4 04             	add    $0x4,%esp
  801d8b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d8e:	e8 bb f0 ff ff       	call   800e4e <fd2num>
  801d93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d96:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d99:	83 c4 10             	add    $0x10,%esp
  801d9c:	ba 00 00 00 00       	mov    $0x0,%edx
  801da1:	eb 30                	jmp    801dd3 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801da3:	83 ec 08             	sub    $0x8,%esp
  801da6:	56                   	push   %esi
  801da7:	6a 00                	push   $0x0
  801da9:	e8 91 ee ff ff       	call   800c3f <sys_page_unmap>
  801dae:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801db1:	83 ec 08             	sub    $0x8,%esp
  801db4:	ff 75 f0             	pushl  -0x10(%ebp)
  801db7:	6a 00                	push   $0x0
  801db9:	e8 81 ee ff ff       	call   800c3f <sys_page_unmap>
  801dbe:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801dc1:	83 ec 08             	sub    $0x8,%esp
  801dc4:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc7:	6a 00                	push   $0x0
  801dc9:	e8 71 ee ff ff       	call   800c3f <sys_page_unmap>
  801dce:	83 c4 10             	add    $0x10,%esp
  801dd1:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801dd3:	89 d0                	mov    %edx,%eax
  801dd5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dd8:	5b                   	pop    %ebx
  801dd9:	5e                   	pop    %esi
  801dda:	5d                   	pop    %ebp
  801ddb:	c3                   	ret    

00801ddc <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ddc:	55                   	push   %ebp
  801ddd:	89 e5                	mov    %esp,%ebp
  801ddf:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801de2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de5:	50                   	push   %eax
  801de6:	ff 75 08             	pushl  0x8(%ebp)
  801de9:	e8 d6 f0 ff ff       	call   800ec4 <fd_lookup>
  801dee:	83 c4 10             	add    $0x10,%esp
  801df1:	85 c0                	test   %eax,%eax
  801df3:	78 18                	js     801e0d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801df5:	83 ec 0c             	sub    $0xc,%esp
  801df8:	ff 75 f4             	pushl  -0xc(%ebp)
  801dfb:	e8 5e f0 ff ff       	call   800e5e <fd2data>
	return _pipeisclosed(fd, p);
  801e00:	89 c2                	mov    %eax,%edx
  801e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e05:	e8 21 fd ff ff       	call   801b2b <_pipeisclosed>
  801e0a:	83 c4 10             	add    $0x10,%esp
}
  801e0d:	c9                   	leave  
  801e0e:	c3                   	ret    

00801e0f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e0f:	55                   	push   %ebp
  801e10:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e12:	b8 00 00 00 00       	mov    $0x0,%eax
  801e17:	5d                   	pop    %ebp
  801e18:	c3                   	ret    

00801e19 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e19:	55                   	push   %ebp
  801e1a:	89 e5                	mov    %esp,%ebp
  801e1c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e1f:	68 2b 28 80 00       	push   $0x80282b
  801e24:	ff 75 0c             	pushl  0xc(%ebp)
  801e27:	e8 8b e9 ff ff       	call   8007b7 <strcpy>
	return 0;
}
  801e2c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e31:	c9                   	leave  
  801e32:	c3                   	ret    

00801e33 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e33:	55                   	push   %ebp
  801e34:	89 e5                	mov    %esp,%ebp
  801e36:	57                   	push   %edi
  801e37:	56                   	push   %esi
  801e38:	53                   	push   %ebx
  801e39:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e3f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e44:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e4a:	eb 2d                	jmp    801e79 <devcons_write+0x46>
		m = n - tot;
  801e4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e4f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e51:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e54:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e59:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e5c:	83 ec 04             	sub    $0x4,%esp
  801e5f:	53                   	push   %ebx
  801e60:	03 45 0c             	add    0xc(%ebp),%eax
  801e63:	50                   	push   %eax
  801e64:	57                   	push   %edi
  801e65:	e8 df ea ff ff       	call   800949 <memmove>
		sys_cputs(buf, m);
  801e6a:	83 c4 08             	add    $0x8,%esp
  801e6d:	53                   	push   %ebx
  801e6e:	57                   	push   %edi
  801e6f:	e8 8a ec ff ff       	call   800afe <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e74:	01 de                	add    %ebx,%esi
  801e76:	83 c4 10             	add    $0x10,%esp
  801e79:	89 f0                	mov    %esi,%eax
  801e7b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e7e:	72 cc                	jb     801e4c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e83:	5b                   	pop    %ebx
  801e84:	5e                   	pop    %esi
  801e85:	5f                   	pop    %edi
  801e86:	5d                   	pop    %ebp
  801e87:	c3                   	ret    

00801e88 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e88:	55                   	push   %ebp
  801e89:	89 e5                	mov    %esp,%ebp
  801e8b:	83 ec 08             	sub    $0x8,%esp
  801e8e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e93:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e97:	74 2a                	je     801ec3 <devcons_read+0x3b>
  801e99:	eb 05                	jmp    801ea0 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e9b:	e8 fb ec ff ff       	call   800b9b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ea0:	e8 77 ec ff ff       	call   800b1c <sys_cgetc>
  801ea5:	85 c0                	test   %eax,%eax
  801ea7:	74 f2                	je     801e9b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ea9:	85 c0                	test   %eax,%eax
  801eab:	78 16                	js     801ec3 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ead:	83 f8 04             	cmp    $0x4,%eax
  801eb0:	74 0c                	je     801ebe <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801eb2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eb5:	88 02                	mov    %al,(%edx)
	return 1;
  801eb7:	b8 01 00 00 00       	mov    $0x1,%eax
  801ebc:	eb 05                	jmp    801ec3 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ebe:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ec3:	c9                   	leave  
  801ec4:	c3                   	ret    

00801ec5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ec5:	55                   	push   %ebp
  801ec6:	89 e5                	mov    %esp,%ebp
  801ec8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ecb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ece:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ed1:	6a 01                	push   $0x1
  801ed3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ed6:	50                   	push   %eax
  801ed7:	e8 22 ec ff ff       	call   800afe <sys_cputs>
}
  801edc:	83 c4 10             	add    $0x10,%esp
  801edf:	c9                   	leave  
  801ee0:	c3                   	ret    

00801ee1 <getchar>:

int
getchar(void)
{
  801ee1:	55                   	push   %ebp
  801ee2:	89 e5                	mov    %esp,%ebp
  801ee4:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ee7:	6a 01                	push   $0x1
  801ee9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eec:	50                   	push   %eax
  801eed:	6a 00                	push   $0x0
  801eef:	e8 36 f2 ff ff       	call   80112a <read>
	if (r < 0)
  801ef4:	83 c4 10             	add    $0x10,%esp
  801ef7:	85 c0                	test   %eax,%eax
  801ef9:	78 0f                	js     801f0a <getchar+0x29>
		return r;
	if (r < 1)
  801efb:	85 c0                	test   %eax,%eax
  801efd:	7e 06                	jle    801f05 <getchar+0x24>
		return -E_EOF;
	return c;
  801eff:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f03:	eb 05                	jmp    801f0a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f05:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f0a:	c9                   	leave  
  801f0b:	c3                   	ret    

00801f0c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f15:	50                   	push   %eax
  801f16:	ff 75 08             	pushl  0x8(%ebp)
  801f19:	e8 a6 ef ff ff       	call   800ec4 <fd_lookup>
  801f1e:	83 c4 10             	add    $0x10,%esp
  801f21:	85 c0                	test   %eax,%eax
  801f23:	78 11                	js     801f36 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f28:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f2e:	39 10                	cmp    %edx,(%eax)
  801f30:	0f 94 c0             	sete   %al
  801f33:	0f b6 c0             	movzbl %al,%eax
}
  801f36:	c9                   	leave  
  801f37:	c3                   	ret    

00801f38 <opencons>:

int
opencons(void)
{
  801f38:	55                   	push   %ebp
  801f39:	89 e5                	mov    %esp,%ebp
  801f3b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f41:	50                   	push   %eax
  801f42:	e8 2e ef ff ff       	call   800e75 <fd_alloc>
  801f47:	83 c4 10             	add    $0x10,%esp
		return r;
  801f4a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f4c:	85 c0                	test   %eax,%eax
  801f4e:	78 3e                	js     801f8e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f50:	83 ec 04             	sub    $0x4,%esp
  801f53:	68 07 04 00 00       	push   $0x407
  801f58:	ff 75 f4             	pushl  -0xc(%ebp)
  801f5b:	6a 00                	push   $0x0
  801f5d:	e8 58 ec ff ff       	call   800bba <sys_page_alloc>
  801f62:	83 c4 10             	add    $0x10,%esp
		return r;
  801f65:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f67:	85 c0                	test   %eax,%eax
  801f69:	78 23                	js     801f8e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f6b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f74:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f79:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f80:	83 ec 0c             	sub    $0xc,%esp
  801f83:	50                   	push   %eax
  801f84:	e8 c5 ee ff ff       	call   800e4e <fd2num>
  801f89:	89 c2                	mov    %eax,%edx
  801f8b:	83 c4 10             	add    $0x10,%esp
}
  801f8e:	89 d0                	mov    %edx,%eax
  801f90:	c9                   	leave  
  801f91:	c3                   	ret    

00801f92 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f92:	55                   	push   %ebp
  801f93:	89 e5                	mov    %esp,%ebp
  801f95:	56                   	push   %esi
  801f96:	53                   	push   %ebx
  801f97:	8b 75 08             	mov    0x8(%ebp),%esi
  801f9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801fa0:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801fa2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fa7:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801faa:	83 ec 0c             	sub    $0xc,%esp
  801fad:	50                   	push   %eax
  801fae:	e8 b7 ed ff ff       	call   800d6a <sys_ipc_recv>

	if (from_env_store != NULL)
  801fb3:	83 c4 10             	add    $0x10,%esp
  801fb6:	85 f6                	test   %esi,%esi
  801fb8:	74 14                	je     801fce <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801fba:	ba 00 00 00 00       	mov    $0x0,%edx
  801fbf:	85 c0                	test   %eax,%eax
  801fc1:	78 09                	js     801fcc <ipc_recv+0x3a>
  801fc3:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801fc9:	8b 52 74             	mov    0x74(%edx),%edx
  801fcc:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801fce:	85 db                	test   %ebx,%ebx
  801fd0:	74 14                	je     801fe6 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801fd2:	ba 00 00 00 00       	mov    $0x0,%edx
  801fd7:	85 c0                	test   %eax,%eax
  801fd9:	78 09                	js     801fe4 <ipc_recv+0x52>
  801fdb:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801fe1:	8b 52 78             	mov    0x78(%edx),%edx
  801fe4:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801fe6:	85 c0                	test   %eax,%eax
  801fe8:	78 08                	js     801ff2 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801fea:	a1 08 40 80 00       	mov    0x804008,%eax
  801fef:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ff2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ff5:	5b                   	pop    %ebx
  801ff6:	5e                   	pop    %esi
  801ff7:	5d                   	pop    %ebp
  801ff8:	c3                   	ret    

00801ff9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ff9:	55                   	push   %ebp
  801ffa:	89 e5                	mov    %esp,%ebp
  801ffc:	57                   	push   %edi
  801ffd:	56                   	push   %esi
  801ffe:	53                   	push   %ebx
  801fff:	83 ec 0c             	sub    $0xc,%esp
  802002:	8b 7d 08             	mov    0x8(%ebp),%edi
  802005:	8b 75 0c             	mov    0xc(%ebp),%esi
  802008:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  80200b:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  80200d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802012:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  802015:	ff 75 14             	pushl  0x14(%ebp)
  802018:	53                   	push   %ebx
  802019:	56                   	push   %esi
  80201a:	57                   	push   %edi
  80201b:	e8 27 ed ff ff       	call   800d47 <sys_ipc_try_send>

		if (err < 0) {
  802020:	83 c4 10             	add    $0x10,%esp
  802023:	85 c0                	test   %eax,%eax
  802025:	79 1e                	jns    802045 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802027:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80202a:	75 07                	jne    802033 <ipc_send+0x3a>
				sys_yield();
  80202c:	e8 6a eb ff ff       	call   800b9b <sys_yield>
  802031:	eb e2                	jmp    802015 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802033:	50                   	push   %eax
  802034:	68 37 28 80 00       	push   $0x802837
  802039:	6a 49                	push   $0x49
  80203b:	68 44 28 80 00       	push   $0x802844
  802040:	e8 14 e1 ff ff       	call   800159 <_panic>
		}

	} while (err < 0);

}
  802045:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802048:	5b                   	pop    %ebx
  802049:	5e                   	pop    %esi
  80204a:	5f                   	pop    %edi
  80204b:	5d                   	pop    %ebp
  80204c:	c3                   	ret    

0080204d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80204d:	55                   	push   %ebp
  80204e:	89 e5                	mov    %esp,%ebp
  802050:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802053:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802058:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80205b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802061:	8b 52 50             	mov    0x50(%edx),%edx
  802064:	39 ca                	cmp    %ecx,%edx
  802066:	75 0d                	jne    802075 <ipc_find_env+0x28>
			return envs[i].env_id;
  802068:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80206b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802070:	8b 40 48             	mov    0x48(%eax),%eax
  802073:	eb 0f                	jmp    802084 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802075:	83 c0 01             	add    $0x1,%eax
  802078:	3d 00 04 00 00       	cmp    $0x400,%eax
  80207d:	75 d9                	jne    802058 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80207f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802084:	5d                   	pop    %ebp
  802085:	c3                   	ret    

00802086 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802086:	55                   	push   %ebp
  802087:	89 e5                	mov    %esp,%ebp
  802089:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80208c:	89 d0                	mov    %edx,%eax
  80208e:	c1 e8 16             	shr    $0x16,%eax
  802091:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802098:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80209d:	f6 c1 01             	test   $0x1,%cl
  8020a0:	74 1d                	je     8020bf <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020a2:	c1 ea 0c             	shr    $0xc,%edx
  8020a5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020ac:	f6 c2 01             	test   $0x1,%dl
  8020af:	74 0e                	je     8020bf <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020b1:	c1 ea 0c             	shr    $0xc,%edx
  8020b4:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020bb:	ef 
  8020bc:	0f b7 c0             	movzwl %ax,%eax
}
  8020bf:	5d                   	pop    %ebp
  8020c0:	c3                   	ret    
  8020c1:	66 90                	xchg   %ax,%ax
  8020c3:	66 90                	xchg   %ax,%ax
  8020c5:	66 90                	xchg   %ax,%ax
  8020c7:	66 90                	xchg   %ax,%ax
  8020c9:	66 90                	xchg   %ax,%ax
  8020cb:	66 90                	xchg   %ax,%ax
  8020cd:	66 90                	xchg   %ax,%ax
  8020cf:	90                   	nop

008020d0 <__udivdi3>:
  8020d0:	55                   	push   %ebp
  8020d1:	57                   	push   %edi
  8020d2:	56                   	push   %esi
  8020d3:	53                   	push   %ebx
  8020d4:	83 ec 1c             	sub    $0x1c,%esp
  8020d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020e7:	85 f6                	test   %esi,%esi
  8020e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020ed:	89 ca                	mov    %ecx,%edx
  8020ef:	89 f8                	mov    %edi,%eax
  8020f1:	75 3d                	jne    802130 <__udivdi3+0x60>
  8020f3:	39 cf                	cmp    %ecx,%edi
  8020f5:	0f 87 c5 00 00 00    	ja     8021c0 <__udivdi3+0xf0>
  8020fb:	85 ff                	test   %edi,%edi
  8020fd:	89 fd                	mov    %edi,%ebp
  8020ff:	75 0b                	jne    80210c <__udivdi3+0x3c>
  802101:	b8 01 00 00 00       	mov    $0x1,%eax
  802106:	31 d2                	xor    %edx,%edx
  802108:	f7 f7                	div    %edi
  80210a:	89 c5                	mov    %eax,%ebp
  80210c:	89 c8                	mov    %ecx,%eax
  80210e:	31 d2                	xor    %edx,%edx
  802110:	f7 f5                	div    %ebp
  802112:	89 c1                	mov    %eax,%ecx
  802114:	89 d8                	mov    %ebx,%eax
  802116:	89 cf                	mov    %ecx,%edi
  802118:	f7 f5                	div    %ebp
  80211a:	89 c3                	mov    %eax,%ebx
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
  802130:	39 ce                	cmp    %ecx,%esi
  802132:	77 74                	ja     8021a8 <__udivdi3+0xd8>
  802134:	0f bd fe             	bsr    %esi,%edi
  802137:	83 f7 1f             	xor    $0x1f,%edi
  80213a:	0f 84 98 00 00 00    	je     8021d8 <__udivdi3+0x108>
  802140:	bb 20 00 00 00       	mov    $0x20,%ebx
  802145:	89 f9                	mov    %edi,%ecx
  802147:	89 c5                	mov    %eax,%ebp
  802149:	29 fb                	sub    %edi,%ebx
  80214b:	d3 e6                	shl    %cl,%esi
  80214d:	89 d9                	mov    %ebx,%ecx
  80214f:	d3 ed                	shr    %cl,%ebp
  802151:	89 f9                	mov    %edi,%ecx
  802153:	d3 e0                	shl    %cl,%eax
  802155:	09 ee                	or     %ebp,%esi
  802157:	89 d9                	mov    %ebx,%ecx
  802159:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80215d:	89 d5                	mov    %edx,%ebp
  80215f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802163:	d3 ed                	shr    %cl,%ebp
  802165:	89 f9                	mov    %edi,%ecx
  802167:	d3 e2                	shl    %cl,%edx
  802169:	89 d9                	mov    %ebx,%ecx
  80216b:	d3 e8                	shr    %cl,%eax
  80216d:	09 c2                	or     %eax,%edx
  80216f:	89 d0                	mov    %edx,%eax
  802171:	89 ea                	mov    %ebp,%edx
  802173:	f7 f6                	div    %esi
  802175:	89 d5                	mov    %edx,%ebp
  802177:	89 c3                	mov    %eax,%ebx
  802179:	f7 64 24 0c          	mull   0xc(%esp)
  80217d:	39 d5                	cmp    %edx,%ebp
  80217f:	72 10                	jb     802191 <__udivdi3+0xc1>
  802181:	8b 74 24 08          	mov    0x8(%esp),%esi
  802185:	89 f9                	mov    %edi,%ecx
  802187:	d3 e6                	shl    %cl,%esi
  802189:	39 c6                	cmp    %eax,%esi
  80218b:	73 07                	jae    802194 <__udivdi3+0xc4>
  80218d:	39 d5                	cmp    %edx,%ebp
  80218f:	75 03                	jne    802194 <__udivdi3+0xc4>
  802191:	83 eb 01             	sub    $0x1,%ebx
  802194:	31 ff                	xor    %edi,%edi
  802196:	89 d8                	mov    %ebx,%eax
  802198:	89 fa                	mov    %edi,%edx
  80219a:	83 c4 1c             	add    $0x1c,%esp
  80219d:	5b                   	pop    %ebx
  80219e:	5e                   	pop    %esi
  80219f:	5f                   	pop    %edi
  8021a0:	5d                   	pop    %ebp
  8021a1:	c3                   	ret    
  8021a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021a8:	31 ff                	xor    %edi,%edi
  8021aa:	31 db                	xor    %ebx,%ebx
  8021ac:	89 d8                	mov    %ebx,%eax
  8021ae:	89 fa                	mov    %edi,%edx
  8021b0:	83 c4 1c             	add    $0x1c,%esp
  8021b3:	5b                   	pop    %ebx
  8021b4:	5e                   	pop    %esi
  8021b5:	5f                   	pop    %edi
  8021b6:	5d                   	pop    %ebp
  8021b7:	c3                   	ret    
  8021b8:	90                   	nop
  8021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	89 d8                	mov    %ebx,%eax
  8021c2:	f7 f7                	div    %edi
  8021c4:	31 ff                	xor    %edi,%edi
  8021c6:	89 c3                	mov    %eax,%ebx
  8021c8:	89 d8                	mov    %ebx,%eax
  8021ca:	89 fa                	mov    %edi,%edx
  8021cc:	83 c4 1c             	add    $0x1c,%esp
  8021cf:	5b                   	pop    %ebx
  8021d0:	5e                   	pop    %esi
  8021d1:	5f                   	pop    %edi
  8021d2:	5d                   	pop    %ebp
  8021d3:	c3                   	ret    
  8021d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d8:	39 ce                	cmp    %ecx,%esi
  8021da:	72 0c                	jb     8021e8 <__udivdi3+0x118>
  8021dc:	31 db                	xor    %ebx,%ebx
  8021de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021e2:	0f 87 34 ff ff ff    	ja     80211c <__udivdi3+0x4c>
  8021e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021ed:	e9 2a ff ff ff       	jmp    80211c <__udivdi3+0x4c>
  8021f2:	66 90                	xchg   %ax,%ax
  8021f4:	66 90                	xchg   %ax,%ax
  8021f6:	66 90                	xchg   %ax,%ax
  8021f8:	66 90                	xchg   %ax,%ax
  8021fa:	66 90                	xchg   %ax,%ax
  8021fc:	66 90                	xchg   %ax,%ax
  8021fe:	66 90                	xchg   %ax,%ax

00802200 <__umoddi3>:
  802200:	55                   	push   %ebp
  802201:	57                   	push   %edi
  802202:	56                   	push   %esi
  802203:	53                   	push   %ebx
  802204:	83 ec 1c             	sub    $0x1c,%esp
  802207:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80220b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80220f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802213:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802217:	85 d2                	test   %edx,%edx
  802219:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80221d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802221:	89 f3                	mov    %esi,%ebx
  802223:	89 3c 24             	mov    %edi,(%esp)
  802226:	89 74 24 04          	mov    %esi,0x4(%esp)
  80222a:	75 1c                	jne    802248 <__umoddi3+0x48>
  80222c:	39 f7                	cmp    %esi,%edi
  80222e:	76 50                	jbe    802280 <__umoddi3+0x80>
  802230:	89 c8                	mov    %ecx,%eax
  802232:	89 f2                	mov    %esi,%edx
  802234:	f7 f7                	div    %edi
  802236:	89 d0                	mov    %edx,%eax
  802238:	31 d2                	xor    %edx,%edx
  80223a:	83 c4 1c             	add    $0x1c,%esp
  80223d:	5b                   	pop    %ebx
  80223e:	5e                   	pop    %esi
  80223f:	5f                   	pop    %edi
  802240:	5d                   	pop    %ebp
  802241:	c3                   	ret    
  802242:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802248:	39 f2                	cmp    %esi,%edx
  80224a:	89 d0                	mov    %edx,%eax
  80224c:	77 52                	ja     8022a0 <__umoddi3+0xa0>
  80224e:	0f bd ea             	bsr    %edx,%ebp
  802251:	83 f5 1f             	xor    $0x1f,%ebp
  802254:	75 5a                	jne    8022b0 <__umoddi3+0xb0>
  802256:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80225a:	0f 82 e0 00 00 00    	jb     802340 <__umoddi3+0x140>
  802260:	39 0c 24             	cmp    %ecx,(%esp)
  802263:	0f 86 d7 00 00 00    	jbe    802340 <__umoddi3+0x140>
  802269:	8b 44 24 08          	mov    0x8(%esp),%eax
  80226d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802271:	83 c4 1c             	add    $0x1c,%esp
  802274:	5b                   	pop    %ebx
  802275:	5e                   	pop    %esi
  802276:	5f                   	pop    %edi
  802277:	5d                   	pop    %ebp
  802278:	c3                   	ret    
  802279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802280:	85 ff                	test   %edi,%edi
  802282:	89 fd                	mov    %edi,%ebp
  802284:	75 0b                	jne    802291 <__umoddi3+0x91>
  802286:	b8 01 00 00 00       	mov    $0x1,%eax
  80228b:	31 d2                	xor    %edx,%edx
  80228d:	f7 f7                	div    %edi
  80228f:	89 c5                	mov    %eax,%ebp
  802291:	89 f0                	mov    %esi,%eax
  802293:	31 d2                	xor    %edx,%edx
  802295:	f7 f5                	div    %ebp
  802297:	89 c8                	mov    %ecx,%eax
  802299:	f7 f5                	div    %ebp
  80229b:	89 d0                	mov    %edx,%eax
  80229d:	eb 99                	jmp    802238 <__umoddi3+0x38>
  80229f:	90                   	nop
  8022a0:	89 c8                	mov    %ecx,%eax
  8022a2:	89 f2                	mov    %esi,%edx
  8022a4:	83 c4 1c             	add    $0x1c,%esp
  8022a7:	5b                   	pop    %ebx
  8022a8:	5e                   	pop    %esi
  8022a9:	5f                   	pop    %edi
  8022aa:	5d                   	pop    %ebp
  8022ab:	c3                   	ret    
  8022ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022b0:	8b 34 24             	mov    (%esp),%esi
  8022b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022b8:	89 e9                	mov    %ebp,%ecx
  8022ba:	29 ef                	sub    %ebp,%edi
  8022bc:	d3 e0                	shl    %cl,%eax
  8022be:	89 f9                	mov    %edi,%ecx
  8022c0:	89 f2                	mov    %esi,%edx
  8022c2:	d3 ea                	shr    %cl,%edx
  8022c4:	89 e9                	mov    %ebp,%ecx
  8022c6:	09 c2                	or     %eax,%edx
  8022c8:	89 d8                	mov    %ebx,%eax
  8022ca:	89 14 24             	mov    %edx,(%esp)
  8022cd:	89 f2                	mov    %esi,%edx
  8022cf:	d3 e2                	shl    %cl,%edx
  8022d1:	89 f9                	mov    %edi,%ecx
  8022d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022db:	d3 e8                	shr    %cl,%eax
  8022dd:	89 e9                	mov    %ebp,%ecx
  8022df:	89 c6                	mov    %eax,%esi
  8022e1:	d3 e3                	shl    %cl,%ebx
  8022e3:	89 f9                	mov    %edi,%ecx
  8022e5:	89 d0                	mov    %edx,%eax
  8022e7:	d3 e8                	shr    %cl,%eax
  8022e9:	89 e9                	mov    %ebp,%ecx
  8022eb:	09 d8                	or     %ebx,%eax
  8022ed:	89 d3                	mov    %edx,%ebx
  8022ef:	89 f2                	mov    %esi,%edx
  8022f1:	f7 34 24             	divl   (%esp)
  8022f4:	89 d6                	mov    %edx,%esi
  8022f6:	d3 e3                	shl    %cl,%ebx
  8022f8:	f7 64 24 04          	mull   0x4(%esp)
  8022fc:	39 d6                	cmp    %edx,%esi
  8022fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802302:	89 d1                	mov    %edx,%ecx
  802304:	89 c3                	mov    %eax,%ebx
  802306:	72 08                	jb     802310 <__umoddi3+0x110>
  802308:	75 11                	jne    80231b <__umoddi3+0x11b>
  80230a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80230e:	73 0b                	jae    80231b <__umoddi3+0x11b>
  802310:	2b 44 24 04          	sub    0x4(%esp),%eax
  802314:	1b 14 24             	sbb    (%esp),%edx
  802317:	89 d1                	mov    %edx,%ecx
  802319:	89 c3                	mov    %eax,%ebx
  80231b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80231f:	29 da                	sub    %ebx,%edx
  802321:	19 ce                	sbb    %ecx,%esi
  802323:	89 f9                	mov    %edi,%ecx
  802325:	89 f0                	mov    %esi,%eax
  802327:	d3 e0                	shl    %cl,%eax
  802329:	89 e9                	mov    %ebp,%ecx
  80232b:	d3 ea                	shr    %cl,%edx
  80232d:	89 e9                	mov    %ebp,%ecx
  80232f:	d3 ee                	shr    %cl,%esi
  802331:	09 d0                	or     %edx,%eax
  802333:	89 f2                	mov    %esi,%edx
  802335:	83 c4 1c             	add    $0x1c,%esp
  802338:	5b                   	pop    %ebx
  802339:	5e                   	pop    %esi
  80233a:	5f                   	pop    %edi
  80233b:	5d                   	pop    %ebp
  80233c:	c3                   	ret    
  80233d:	8d 76 00             	lea    0x0(%esi),%esi
  802340:	29 f9                	sub    %edi,%ecx
  802342:	19 d6                	sbb    %edx,%esi
  802344:	89 74 24 04          	mov    %esi,0x4(%esp)
  802348:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80234c:	e9 18 ff ff ff       	jmp    802269 <__umoddi3+0x69>
