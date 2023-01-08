
obj/user/testpiperace2.debug:     file format elf32-i386


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
  80002c:	e8 a5 01 00 00       	call   8001d6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 38             	sub    $0x38,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003c:	68 c0 26 80 00       	push   $0x8026c0
  800041:	e8 c9 02 00 00       	call   80030f <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 ba 1a 00 00       	call   801b0b <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x37>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 0e 27 80 00       	push   $0x80270e
  80005e:	6a 0d                	push   $0xd
  800060:	68 17 27 80 00       	push   $0x802717
  800065:	e8 cc 01 00 00       	call   800236 <_panic>
	if ((r = fork()) < 0)
  80006a:	e8 11 0f 00 00       	call   800f80 <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x54>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 2c 27 80 00       	push   $0x80272c
  80007b:	6a 0f                	push   $0xf
  80007d:	68 17 27 80 00       	push   $0x802717
  800082:	e8 af 01 00 00       	call   800236 <_panic>
	if (r == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 76                	jne    800101 <umain+0xce>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800091:	e8 41 12 00 00       	call   8012d7 <close>
  800096:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 200; i++) {
  800099:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (i % 10 == 0)
  80009e:	bf 67 66 66 66       	mov    $0x66666667,%edi
  8000a3:	89 d8                	mov    %ebx,%eax
  8000a5:	f7 ef                	imul   %edi
  8000a7:	c1 fa 02             	sar    $0x2,%edx
  8000aa:	89 d8                	mov    %ebx,%eax
  8000ac:	c1 f8 1f             	sar    $0x1f,%eax
  8000af:	29 c2                	sub    %eax,%edx
  8000b1:	8d 04 92             	lea    (%edx,%edx,4),%eax
  8000b4:	01 c0                	add    %eax,%eax
  8000b6:	39 c3                	cmp    %eax,%ebx
  8000b8:	75 11                	jne    8000cb <umain+0x98>
				cprintf("%d.", i);
  8000ba:	83 ec 08             	sub    $0x8,%esp
  8000bd:	53                   	push   %ebx
  8000be:	68 35 27 80 00       	push   $0x802735
  8000c3:	e8 47 02 00 00       	call   80030f <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000cb:	83 ec 08             	sub    $0x8,%esp
  8000ce:	6a 0a                	push   $0xa
  8000d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000d3:	e8 4f 12 00 00       	call   801327 <dup>
			sys_yield();
  8000d8:	e8 9b 0b 00 00       	call   800c78 <sys_yield>
			close(10);
  8000dd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000e4:	e8 ee 11 00 00       	call   8012d7 <close>
			sys_yield();
  8000e9:	e8 8a 0b 00 00       	call   800c78 <sys_yield>
	if (r == 0) {
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
		for (i = 0; i < 200; i++) {
  8000ee:	83 c3 01             	add    $0x1,%ebx
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  8000fa:	75 a7                	jne    8000a3 <umain+0x70>
			dup(p[0], 10);
			sys_yield();
			close(10);
			sys_yield();
		}
		exit();
  8000fc:	e8 1b 01 00 00       	call   80021c <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800101:	89 f0                	mov    %esi,%eax
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (kid->env_status == ENV_RUNNABLE)
  800108:	8d 3c 85 00 00 00 00 	lea    0x0(,%eax,4),%edi
  80010f:	c1 e0 07             	shl    $0x7,%eax
  800112:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800115:	eb 2f                	jmp    800146 <umain+0x113>
		if (pipeisclosed(p[0]) != 0) {
  800117:	83 ec 0c             	sub    $0xc,%esp
  80011a:	ff 75 e0             	pushl  -0x20(%ebp)
  80011d:	e8 3c 1b 00 00       	call   801c5e <pipeisclosed>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	74 28                	je     800151 <umain+0x11e>
			cprintf("\nRACE: pipe appears closed\n");
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	68 39 27 80 00       	push   $0x802739
  800131:	e8 d9 01 00 00       	call   80030f <cprintf>
			sys_env_destroy(r);
  800136:	89 34 24             	mov    %esi,(%esp)
  800139:	e8 da 0a 00 00       	call   800c18 <sys_env_destroy>
			exit();
  80013e:	e8 d9 00 00 00       	call   80021c <exit>
  800143:	83 c4 10             	add    $0x10,%esp
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800146:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800149:	29 fb                	sub    %edi,%ebx
  80014b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800151:	8b 43 54             	mov    0x54(%ebx),%eax
  800154:	83 f8 02             	cmp    $0x2,%eax
  800157:	74 be                	je     800117 <umain+0xe4>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  800159:	83 ec 0c             	sub    $0xc,%esp
  80015c:	68 55 27 80 00       	push   $0x802755
  800161:	e8 a9 01 00 00       	call   80030f <cprintf>
	if (pipeisclosed(p[0]))
  800166:	83 c4 04             	add    $0x4,%esp
  800169:	ff 75 e0             	pushl  -0x20(%ebp)
  80016c:	e8 ed 1a 00 00       	call   801c5e <pipeisclosed>
  800171:	83 c4 10             	add    $0x10,%esp
  800174:	85 c0                	test   %eax,%eax
  800176:	74 14                	je     80018c <umain+0x159>
		panic("somehow the other end of p[0] got closed!");
  800178:	83 ec 04             	sub    $0x4,%esp
  80017b:	68 e4 26 80 00       	push   $0x8026e4
  800180:	6a 40                	push   $0x40
  800182:	68 17 27 80 00       	push   $0x802717
  800187:	e8 aa 00 00 00       	call   800236 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	ff 75 e0             	pushl  -0x20(%ebp)
  800196:	e8 12 10 00 00       	call   8011ad <fd_lookup>
  80019b:	83 c4 10             	add    $0x10,%esp
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	79 12                	jns    8001b4 <umain+0x181>
		panic("cannot look up p[0]: %e", r);
  8001a2:	50                   	push   %eax
  8001a3:	68 6b 27 80 00       	push   $0x80276b
  8001a8:	6a 42                	push   $0x42
  8001aa:	68 17 27 80 00       	push   $0x802717
  8001af:	e8 82 00 00 00       	call   800236 <_panic>
	(void) fd2data(fd);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ba:	e8 88 0f 00 00       	call   801147 <fd2data>
	cprintf("race didn't happen\n");
  8001bf:	c7 04 24 83 27 80 00 	movl   $0x802783,(%esp)
  8001c6:	e8 44 01 00 00       	call   80030f <cprintf>
}
  8001cb:	83 c4 10             	add    $0x10,%esp
  8001ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5f                   	pop    %edi
  8001d4:	5d                   	pop    %ebp
  8001d5:	c3                   	ret    

008001d6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	56                   	push   %esi
  8001da:	53                   	push   %ebx
  8001db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001de:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001e1:	e8 73 0a 00 00       	call   800c59 <sys_getenvid>
  8001e6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001eb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001ee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f3:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f8:	85 db                	test   %ebx,%ebx
  8001fa:	7e 07                	jle    800203 <libmain+0x2d>
		binaryname = argv[0];
  8001fc:	8b 06                	mov    (%esi),%eax
  8001fe:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800203:	83 ec 08             	sub    $0x8,%esp
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	e8 26 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80020d:	e8 0a 00 00 00       	call   80021c <exit>
}
  800212:	83 c4 10             	add    $0x10,%esp
  800215:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800222:	e8 db 10 00 00       	call   801302 <close_all>
	sys_env_destroy(0);
  800227:	83 ec 0c             	sub    $0xc,%esp
  80022a:	6a 00                	push   $0x0
  80022c:	e8 e7 09 00 00       	call   800c18 <sys_env_destroy>
}
  800231:	83 c4 10             	add    $0x10,%esp
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	56                   	push   %esi
  80023a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80023b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800244:	e8 10 0a 00 00       	call   800c59 <sys_getenvid>
  800249:	83 ec 0c             	sub    $0xc,%esp
  80024c:	ff 75 0c             	pushl  0xc(%ebp)
  80024f:	ff 75 08             	pushl  0x8(%ebp)
  800252:	56                   	push   %esi
  800253:	50                   	push   %eax
  800254:	68 a4 27 80 00       	push   $0x8027a4
  800259:	e8 b1 00 00 00       	call   80030f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025e:	83 c4 18             	add    $0x18,%esp
  800261:	53                   	push   %ebx
  800262:	ff 75 10             	pushl  0x10(%ebp)
  800265:	e8 54 00 00 00       	call   8002be <vcprintf>
	cprintf("\n");
  80026a:	c7 04 24 83 2c 80 00 	movl   $0x802c83,(%esp)
  800271:	e8 99 00 00 00       	call   80030f <cprintf>
  800276:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800279:	cc                   	int3   
  80027a:	eb fd                	jmp    800279 <_panic+0x43>

0080027c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	53                   	push   %ebx
  800280:	83 ec 04             	sub    $0x4,%esp
  800283:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800286:	8b 13                	mov    (%ebx),%edx
  800288:	8d 42 01             	lea    0x1(%edx),%eax
  80028b:	89 03                	mov    %eax,(%ebx)
  80028d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800290:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800294:	3d ff 00 00 00       	cmp    $0xff,%eax
  800299:	75 1a                	jne    8002b5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80029b:	83 ec 08             	sub    $0x8,%esp
  80029e:	68 ff 00 00 00       	push   $0xff
  8002a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a6:	50                   	push   %eax
  8002a7:	e8 2f 09 00 00       	call   800bdb <sys_cputs>
		b->idx = 0;
  8002ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ce:	00 00 00 
	b.cnt = 0;
  8002d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e7:	50                   	push   %eax
  8002e8:	68 7c 02 80 00       	push   $0x80027c
  8002ed:	e8 54 01 00 00       	call   800446 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f2:	83 c4 08             	add    $0x8,%esp
  8002f5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800301:	50                   	push   %eax
  800302:	e8 d4 08 00 00       	call   800bdb <sys_cputs>

	return b.cnt;
}
  800307:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800315:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800318:	50                   	push   %eax
  800319:	ff 75 08             	pushl  0x8(%ebp)
  80031c:	e8 9d ff ff ff       	call   8002be <vcprintf>
	va_end(ap);

	return cnt;
}
  800321:	c9                   	leave  
  800322:	c3                   	ret    

00800323 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	57                   	push   %edi
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	83 ec 1c             	sub    $0x1c,%esp
  80032c:	89 c7                	mov    %eax,%edi
  80032e:	89 d6                	mov    %edx,%esi
  800330:	8b 45 08             	mov    0x8(%ebp),%eax
  800333:	8b 55 0c             	mov    0xc(%ebp),%edx
  800336:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800339:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80033c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80033f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800344:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800347:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80034a:	39 d3                	cmp    %edx,%ebx
  80034c:	72 05                	jb     800353 <printnum+0x30>
  80034e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800351:	77 45                	ja     800398 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	ff 75 18             	pushl  0x18(%ebp)
  800359:	8b 45 14             	mov    0x14(%ebp),%eax
  80035c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80035f:	53                   	push   %ebx
  800360:	ff 75 10             	pushl  0x10(%ebp)
  800363:	83 ec 08             	sub    $0x8,%esp
  800366:	ff 75 e4             	pushl  -0x1c(%ebp)
  800369:	ff 75 e0             	pushl  -0x20(%ebp)
  80036c:	ff 75 dc             	pushl  -0x24(%ebp)
  80036f:	ff 75 d8             	pushl  -0x28(%ebp)
  800372:	e8 a9 20 00 00       	call   802420 <__udivdi3>
  800377:	83 c4 18             	add    $0x18,%esp
  80037a:	52                   	push   %edx
  80037b:	50                   	push   %eax
  80037c:	89 f2                	mov    %esi,%edx
  80037e:	89 f8                	mov    %edi,%eax
  800380:	e8 9e ff ff ff       	call   800323 <printnum>
  800385:	83 c4 20             	add    $0x20,%esp
  800388:	eb 18                	jmp    8003a2 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038a:	83 ec 08             	sub    $0x8,%esp
  80038d:	56                   	push   %esi
  80038e:	ff 75 18             	pushl  0x18(%ebp)
  800391:	ff d7                	call   *%edi
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb 03                	jmp    80039b <printnum+0x78>
  800398:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80039b:	83 eb 01             	sub    $0x1,%ebx
  80039e:	85 db                	test   %ebx,%ebx
  8003a0:	7f e8                	jg     80038a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a2:	83 ec 08             	sub    $0x8,%esp
  8003a5:	56                   	push   %esi
  8003a6:	83 ec 04             	sub    $0x4,%esp
  8003a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8003af:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8003b5:	e8 96 21 00 00       	call   802550 <__umoddi3>
  8003ba:	83 c4 14             	add    $0x14,%esp
  8003bd:	0f be 80 c7 27 80 00 	movsbl 0x8027c7(%eax),%eax
  8003c4:	50                   	push   %eax
  8003c5:	ff d7                	call   *%edi
}
  8003c7:	83 c4 10             	add    $0x10,%esp
  8003ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003cd:	5b                   	pop    %ebx
  8003ce:	5e                   	pop    %esi
  8003cf:	5f                   	pop    %edi
  8003d0:	5d                   	pop    %ebp
  8003d1:	c3                   	ret    

008003d2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d5:	83 fa 01             	cmp    $0x1,%edx
  8003d8:	7e 0e                	jle    8003e8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003da:	8b 10                	mov    (%eax),%edx
  8003dc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003df:	89 08                	mov    %ecx,(%eax)
  8003e1:	8b 02                	mov    (%edx),%eax
  8003e3:	8b 52 04             	mov    0x4(%edx),%edx
  8003e6:	eb 22                	jmp    80040a <getuint+0x38>
	else if (lflag)
  8003e8:	85 d2                	test   %edx,%edx
  8003ea:	74 10                	je     8003fc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ec:	8b 10                	mov    (%eax),%edx
  8003ee:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f1:	89 08                	mov    %ecx,(%eax)
  8003f3:	8b 02                	mov    (%edx),%eax
  8003f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fa:	eb 0e                	jmp    80040a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003fc:	8b 10                	mov    (%eax),%edx
  8003fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800401:	89 08                	mov    %ecx,(%eax)
  800403:	8b 02                	mov    (%edx),%eax
  800405:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800412:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800416:	8b 10                	mov    (%eax),%edx
  800418:	3b 50 04             	cmp    0x4(%eax),%edx
  80041b:	73 0a                	jae    800427 <sprintputch+0x1b>
		*b->buf++ = ch;
  80041d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800420:	89 08                	mov    %ecx,(%eax)
  800422:	8b 45 08             	mov    0x8(%ebp),%eax
  800425:	88 02                	mov    %al,(%edx)
}
  800427:	5d                   	pop    %ebp
  800428:	c3                   	ret    

00800429 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800429:	55                   	push   %ebp
  80042a:	89 e5                	mov    %esp,%ebp
  80042c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80042f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800432:	50                   	push   %eax
  800433:	ff 75 10             	pushl  0x10(%ebp)
  800436:	ff 75 0c             	pushl  0xc(%ebp)
  800439:	ff 75 08             	pushl  0x8(%ebp)
  80043c:	e8 05 00 00 00       	call   800446 <vprintfmt>
	va_end(ap);
}
  800441:	83 c4 10             	add    $0x10,%esp
  800444:	c9                   	leave  
  800445:	c3                   	ret    

00800446 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	57                   	push   %edi
  80044a:	56                   	push   %esi
  80044b:	53                   	push   %ebx
  80044c:	83 ec 2c             	sub    $0x2c,%esp
  80044f:	8b 75 08             	mov    0x8(%ebp),%esi
  800452:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800455:	8b 7d 10             	mov    0x10(%ebp),%edi
  800458:	eb 12                	jmp    80046c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80045a:	85 c0                	test   %eax,%eax
  80045c:	0f 84 89 03 00 00    	je     8007eb <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800462:	83 ec 08             	sub    $0x8,%esp
  800465:	53                   	push   %ebx
  800466:	50                   	push   %eax
  800467:	ff d6                	call   *%esi
  800469:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80046c:	83 c7 01             	add    $0x1,%edi
  80046f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800473:	83 f8 25             	cmp    $0x25,%eax
  800476:	75 e2                	jne    80045a <vprintfmt+0x14>
  800478:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80047c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800483:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80048a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800491:	ba 00 00 00 00       	mov    $0x0,%edx
  800496:	eb 07                	jmp    80049f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800498:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80049b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8d 47 01             	lea    0x1(%edi),%eax
  8004a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a5:	0f b6 07             	movzbl (%edi),%eax
  8004a8:	0f b6 c8             	movzbl %al,%ecx
  8004ab:	83 e8 23             	sub    $0x23,%eax
  8004ae:	3c 55                	cmp    $0x55,%al
  8004b0:	0f 87 1a 03 00 00    	ja     8007d0 <vprintfmt+0x38a>
  8004b6:	0f b6 c0             	movzbl %al,%eax
  8004b9:	ff 24 85 00 29 80 00 	jmp    *0x802900(,%eax,4)
  8004c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c3:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004c7:	eb d6                	jmp    80049f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004d4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004d7:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004db:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004de:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004e1:	83 fa 09             	cmp    $0x9,%edx
  8004e4:	77 39                	ja     80051f <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004e6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004e9:	eb e9                	jmp    8004d4 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ee:	8d 48 04             	lea    0x4(%eax),%ecx
  8004f1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004f4:	8b 00                	mov    (%eax),%eax
  8004f6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004fc:	eb 27                	jmp    800525 <vprintfmt+0xdf>
  8004fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800501:	85 c0                	test   %eax,%eax
  800503:	b9 00 00 00 00       	mov    $0x0,%ecx
  800508:	0f 49 c8             	cmovns %eax,%ecx
  80050b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800511:	eb 8c                	jmp    80049f <vprintfmt+0x59>
  800513:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800516:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80051d:	eb 80                	jmp    80049f <vprintfmt+0x59>
  80051f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800522:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800525:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800529:	0f 89 70 ff ff ff    	jns    80049f <vprintfmt+0x59>
				width = precision, precision = -1;
  80052f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800532:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800535:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80053c:	e9 5e ff ff ff       	jmp    80049f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800541:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800544:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800547:	e9 53 ff ff ff       	jmp    80049f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8d 50 04             	lea    0x4(%eax),%edx
  800552:	89 55 14             	mov    %edx,0x14(%ebp)
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	53                   	push   %ebx
  800559:	ff 30                	pushl  (%eax)
  80055b:	ff d6                	call   *%esi
			break;
  80055d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800560:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800563:	e9 04 ff ff ff       	jmp    80046c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 50 04             	lea    0x4(%eax),%edx
  80056e:	89 55 14             	mov    %edx,0x14(%ebp)
  800571:	8b 00                	mov    (%eax),%eax
  800573:	99                   	cltd   
  800574:	31 d0                	xor    %edx,%eax
  800576:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800578:	83 f8 0f             	cmp    $0xf,%eax
  80057b:	7f 0b                	jg     800588 <vprintfmt+0x142>
  80057d:	8b 14 85 60 2a 80 00 	mov    0x802a60(,%eax,4),%edx
  800584:	85 d2                	test   %edx,%edx
  800586:	75 18                	jne    8005a0 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800588:	50                   	push   %eax
  800589:	68 df 27 80 00       	push   $0x8027df
  80058e:	53                   	push   %ebx
  80058f:	56                   	push   %esi
  800590:	e8 94 fe ff ff       	call   800429 <printfmt>
  800595:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800598:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80059b:	e9 cc fe ff ff       	jmp    80046c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005a0:	52                   	push   %edx
  8005a1:	68 51 2c 80 00       	push   $0x802c51
  8005a6:	53                   	push   %ebx
  8005a7:	56                   	push   %esi
  8005a8:	e8 7c fe ff ff       	call   800429 <printfmt>
  8005ad:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b3:	e9 b4 fe ff ff       	jmp    80046c <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 50 04             	lea    0x4(%eax),%edx
  8005be:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005c3:	85 ff                	test   %edi,%edi
  8005c5:	b8 d8 27 80 00       	mov    $0x8027d8,%eax
  8005ca:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d1:	0f 8e 94 00 00 00    	jle    80066b <vprintfmt+0x225>
  8005d7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005db:	0f 84 98 00 00 00    	je     800679 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e1:	83 ec 08             	sub    $0x8,%esp
  8005e4:	ff 75 d0             	pushl  -0x30(%ebp)
  8005e7:	57                   	push   %edi
  8005e8:	e8 86 02 00 00       	call   800873 <strnlen>
  8005ed:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005f0:	29 c1                	sub    %eax,%ecx
  8005f2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005f5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005f8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ff:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800602:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800604:	eb 0f                	jmp    800615 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	ff 75 e0             	pushl  -0x20(%ebp)
  80060d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060f:	83 ef 01             	sub    $0x1,%edi
  800612:	83 c4 10             	add    $0x10,%esp
  800615:	85 ff                	test   %edi,%edi
  800617:	7f ed                	jg     800606 <vprintfmt+0x1c0>
  800619:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80061c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80061f:	85 c9                	test   %ecx,%ecx
  800621:	b8 00 00 00 00       	mov    $0x0,%eax
  800626:	0f 49 c1             	cmovns %ecx,%eax
  800629:	29 c1                	sub    %eax,%ecx
  80062b:	89 75 08             	mov    %esi,0x8(%ebp)
  80062e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800631:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800634:	89 cb                	mov    %ecx,%ebx
  800636:	eb 4d                	jmp    800685 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800638:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80063c:	74 1b                	je     800659 <vprintfmt+0x213>
  80063e:	0f be c0             	movsbl %al,%eax
  800641:	83 e8 20             	sub    $0x20,%eax
  800644:	83 f8 5e             	cmp    $0x5e,%eax
  800647:	76 10                	jbe    800659 <vprintfmt+0x213>
					putch('?', putdat);
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	ff 75 0c             	pushl  0xc(%ebp)
  80064f:	6a 3f                	push   $0x3f
  800651:	ff 55 08             	call   *0x8(%ebp)
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	eb 0d                	jmp    800666 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	ff 75 0c             	pushl  0xc(%ebp)
  80065f:	52                   	push   %edx
  800660:	ff 55 08             	call   *0x8(%ebp)
  800663:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800666:	83 eb 01             	sub    $0x1,%ebx
  800669:	eb 1a                	jmp    800685 <vprintfmt+0x23f>
  80066b:	89 75 08             	mov    %esi,0x8(%ebp)
  80066e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800671:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800674:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800677:	eb 0c                	jmp    800685 <vprintfmt+0x23f>
  800679:	89 75 08             	mov    %esi,0x8(%ebp)
  80067c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80067f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800682:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800685:	83 c7 01             	add    $0x1,%edi
  800688:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80068c:	0f be d0             	movsbl %al,%edx
  80068f:	85 d2                	test   %edx,%edx
  800691:	74 23                	je     8006b6 <vprintfmt+0x270>
  800693:	85 f6                	test   %esi,%esi
  800695:	78 a1                	js     800638 <vprintfmt+0x1f2>
  800697:	83 ee 01             	sub    $0x1,%esi
  80069a:	79 9c                	jns    800638 <vprintfmt+0x1f2>
  80069c:	89 df                	mov    %ebx,%edi
  80069e:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a4:	eb 18                	jmp    8006be <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006a6:	83 ec 08             	sub    $0x8,%esp
  8006a9:	53                   	push   %ebx
  8006aa:	6a 20                	push   $0x20
  8006ac:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ae:	83 ef 01             	sub    $0x1,%edi
  8006b1:	83 c4 10             	add    $0x10,%esp
  8006b4:	eb 08                	jmp    8006be <vprintfmt+0x278>
  8006b6:	89 df                	mov    %ebx,%edi
  8006b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8006bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006be:	85 ff                	test   %edi,%edi
  8006c0:	7f e4                	jg     8006a6 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c5:	e9 a2 fd ff ff       	jmp    80046c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ca:	83 fa 01             	cmp    $0x1,%edx
  8006cd:	7e 16                	jle    8006e5 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d2:	8d 50 08             	lea    0x8(%eax),%edx
  8006d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d8:	8b 50 04             	mov    0x4(%eax),%edx
  8006db:	8b 00                	mov    (%eax),%eax
  8006dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006e3:	eb 32                	jmp    800717 <vprintfmt+0x2d1>
	else if (lflag)
  8006e5:	85 d2                	test   %edx,%edx
  8006e7:	74 18                	je     800701 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ec:	8d 50 04             	lea    0x4(%eax),%edx
  8006ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f2:	8b 00                	mov    (%eax),%eax
  8006f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f7:	89 c1                	mov    %eax,%ecx
  8006f9:	c1 f9 1f             	sar    $0x1f,%ecx
  8006fc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006ff:	eb 16                	jmp    800717 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800701:	8b 45 14             	mov    0x14(%ebp),%eax
  800704:	8d 50 04             	lea    0x4(%eax),%edx
  800707:	89 55 14             	mov    %edx,0x14(%ebp)
  80070a:	8b 00                	mov    (%eax),%eax
  80070c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80070f:	89 c1                	mov    %eax,%ecx
  800711:	c1 f9 1f             	sar    $0x1f,%ecx
  800714:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800717:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80071a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80071d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800722:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800726:	79 74                	jns    80079c <vprintfmt+0x356>
				putch('-', putdat);
  800728:	83 ec 08             	sub    $0x8,%esp
  80072b:	53                   	push   %ebx
  80072c:	6a 2d                	push   $0x2d
  80072e:	ff d6                	call   *%esi
				num = -(long long) num;
  800730:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800733:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800736:	f7 d8                	neg    %eax
  800738:	83 d2 00             	adc    $0x0,%edx
  80073b:	f7 da                	neg    %edx
  80073d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800740:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800745:	eb 55                	jmp    80079c <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800747:	8d 45 14             	lea    0x14(%ebp),%eax
  80074a:	e8 83 fc ff ff       	call   8003d2 <getuint>
			base = 10;
  80074f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800754:	eb 46                	jmp    80079c <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800756:	8d 45 14             	lea    0x14(%ebp),%eax
  800759:	e8 74 fc ff ff       	call   8003d2 <getuint>
			base = 8;
  80075e:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800763:	eb 37                	jmp    80079c <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800765:	83 ec 08             	sub    $0x8,%esp
  800768:	53                   	push   %ebx
  800769:	6a 30                	push   $0x30
  80076b:	ff d6                	call   *%esi
			putch('x', putdat);
  80076d:	83 c4 08             	add    $0x8,%esp
  800770:	53                   	push   %ebx
  800771:	6a 78                	push   $0x78
  800773:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800775:	8b 45 14             	mov    0x14(%ebp),%eax
  800778:	8d 50 04             	lea    0x4(%eax),%edx
  80077b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80077e:	8b 00                	mov    (%eax),%eax
  800780:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800785:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800788:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80078d:	eb 0d                	jmp    80079c <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80078f:	8d 45 14             	lea    0x14(%ebp),%eax
  800792:	e8 3b fc ff ff       	call   8003d2 <getuint>
			base = 16;
  800797:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80079c:	83 ec 0c             	sub    $0xc,%esp
  80079f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007a3:	57                   	push   %edi
  8007a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8007a7:	51                   	push   %ecx
  8007a8:	52                   	push   %edx
  8007a9:	50                   	push   %eax
  8007aa:	89 da                	mov    %ebx,%edx
  8007ac:	89 f0                	mov    %esi,%eax
  8007ae:	e8 70 fb ff ff       	call   800323 <printnum>
			break;
  8007b3:	83 c4 20             	add    $0x20,%esp
  8007b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b9:	e9 ae fc ff ff       	jmp    80046c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007be:	83 ec 08             	sub    $0x8,%esp
  8007c1:	53                   	push   %ebx
  8007c2:	51                   	push   %ecx
  8007c3:	ff d6                	call   *%esi
			break;
  8007c5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007cb:	e9 9c fc ff ff       	jmp    80046c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007d0:	83 ec 08             	sub    $0x8,%esp
  8007d3:	53                   	push   %ebx
  8007d4:	6a 25                	push   $0x25
  8007d6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d8:	83 c4 10             	add    $0x10,%esp
  8007db:	eb 03                	jmp    8007e0 <vprintfmt+0x39a>
  8007dd:	83 ef 01             	sub    $0x1,%edi
  8007e0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007e4:	75 f7                	jne    8007dd <vprintfmt+0x397>
  8007e6:	e9 81 fc ff ff       	jmp    80046c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ee:	5b                   	pop    %ebx
  8007ef:	5e                   	pop    %esi
  8007f0:	5f                   	pop    %edi
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	83 ec 18             	sub    $0x18,%esp
  8007f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800802:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800806:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800809:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800810:	85 c0                	test   %eax,%eax
  800812:	74 26                	je     80083a <vsnprintf+0x47>
  800814:	85 d2                	test   %edx,%edx
  800816:	7e 22                	jle    80083a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800818:	ff 75 14             	pushl  0x14(%ebp)
  80081b:	ff 75 10             	pushl  0x10(%ebp)
  80081e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800821:	50                   	push   %eax
  800822:	68 0c 04 80 00       	push   $0x80040c
  800827:	e8 1a fc ff ff       	call   800446 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80082c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80082f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800832:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800835:	83 c4 10             	add    $0x10,%esp
  800838:	eb 05                	jmp    80083f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80083a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80083f:	c9                   	leave  
  800840:	c3                   	ret    

00800841 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800847:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80084a:	50                   	push   %eax
  80084b:	ff 75 10             	pushl  0x10(%ebp)
  80084e:	ff 75 0c             	pushl  0xc(%ebp)
  800851:	ff 75 08             	pushl  0x8(%ebp)
  800854:	e8 9a ff ff ff       	call   8007f3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800859:	c9                   	leave  
  80085a:	c3                   	ret    

0080085b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800861:	b8 00 00 00 00       	mov    $0x0,%eax
  800866:	eb 03                	jmp    80086b <strlen+0x10>
		n++;
  800868:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80086b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80086f:	75 f7                	jne    800868 <strlen+0xd>
		n++;
	return n;
}
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800879:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087c:	ba 00 00 00 00       	mov    $0x0,%edx
  800881:	eb 03                	jmp    800886 <strnlen+0x13>
		n++;
  800883:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800886:	39 c2                	cmp    %eax,%edx
  800888:	74 08                	je     800892 <strnlen+0x1f>
  80088a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80088e:	75 f3                	jne    800883 <strnlen+0x10>
  800890:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	53                   	push   %ebx
  800898:	8b 45 08             	mov    0x8(%ebp),%eax
  80089b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80089e:	89 c2                	mov    %eax,%edx
  8008a0:	83 c2 01             	add    $0x1,%edx
  8008a3:	83 c1 01             	add    $0x1,%ecx
  8008a6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008aa:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008ad:	84 db                	test   %bl,%bl
  8008af:	75 ef                	jne    8008a0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008b1:	5b                   	pop    %ebx
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	53                   	push   %ebx
  8008b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008bb:	53                   	push   %ebx
  8008bc:	e8 9a ff ff ff       	call   80085b <strlen>
  8008c1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008c4:	ff 75 0c             	pushl  0xc(%ebp)
  8008c7:	01 d8                	add    %ebx,%eax
  8008c9:	50                   	push   %eax
  8008ca:	e8 c5 ff ff ff       	call   800894 <strcpy>
	return dst;
}
  8008cf:	89 d8                	mov    %ebx,%eax
  8008d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d4:	c9                   	leave  
  8008d5:	c3                   	ret    

008008d6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	56                   	push   %esi
  8008da:	53                   	push   %ebx
  8008db:	8b 75 08             	mov    0x8(%ebp),%esi
  8008de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e1:	89 f3                	mov    %esi,%ebx
  8008e3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e6:	89 f2                	mov    %esi,%edx
  8008e8:	eb 0f                	jmp    8008f9 <strncpy+0x23>
		*dst++ = *src;
  8008ea:	83 c2 01             	add    $0x1,%edx
  8008ed:	0f b6 01             	movzbl (%ecx),%eax
  8008f0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f3:	80 39 01             	cmpb   $0x1,(%ecx)
  8008f6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f9:	39 da                	cmp    %ebx,%edx
  8008fb:	75 ed                	jne    8008ea <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008fd:	89 f0                	mov    %esi,%eax
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	8b 75 08             	mov    0x8(%ebp),%esi
  80090b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090e:	8b 55 10             	mov    0x10(%ebp),%edx
  800911:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800913:	85 d2                	test   %edx,%edx
  800915:	74 21                	je     800938 <strlcpy+0x35>
  800917:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80091b:	89 f2                	mov    %esi,%edx
  80091d:	eb 09                	jmp    800928 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80091f:	83 c2 01             	add    $0x1,%edx
  800922:	83 c1 01             	add    $0x1,%ecx
  800925:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800928:	39 c2                	cmp    %eax,%edx
  80092a:	74 09                	je     800935 <strlcpy+0x32>
  80092c:	0f b6 19             	movzbl (%ecx),%ebx
  80092f:	84 db                	test   %bl,%bl
  800931:	75 ec                	jne    80091f <strlcpy+0x1c>
  800933:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800935:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800938:	29 f0                	sub    %esi,%eax
}
  80093a:	5b                   	pop    %ebx
  80093b:	5e                   	pop    %esi
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800944:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800947:	eb 06                	jmp    80094f <strcmp+0x11>
		p++, q++;
  800949:	83 c1 01             	add    $0x1,%ecx
  80094c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80094f:	0f b6 01             	movzbl (%ecx),%eax
  800952:	84 c0                	test   %al,%al
  800954:	74 04                	je     80095a <strcmp+0x1c>
  800956:	3a 02                	cmp    (%edx),%al
  800958:	74 ef                	je     800949 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80095a:	0f b6 c0             	movzbl %al,%eax
  80095d:	0f b6 12             	movzbl (%edx),%edx
  800960:	29 d0                	sub    %edx,%eax
}
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	53                   	push   %ebx
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096e:	89 c3                	mov    %eax,%ebx
  800970:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800973:	eb 06                	jmp    80097b <strncmp+0x17>
		n--, p++, q++;
  800975:	83 c0 01             	add    $0x1,%eax
  800978:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80097b:	39 d8                	cmp    %ebx,%eax
  80097d:	74 15                	je     800994 <strncmp+0x30>
  80097f:	0f b6 08             	movzbl (%eax),%ecx
  800982:	84 c9                	test   %cl,%cl
  800984:	74 04                	je     80098a <strncmp+0x26>
  800986:	3a 0a                	cmp    (%edx),%cl
  800988:	74 eb                	je     800975 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80098a:	0f b6 00             	movzbl (%eax),%eax
  80098d:	0f b6 12             	movzbl (%edx),%edx
  800990:	29 d0                	sub    %edx,%eax
  800992:	eb 05                	jmp    800999 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800994:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800999:	5b                   	pop    %ebx
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a6:	eb 07                	jmp    8009af <strchr+0x13>
		if (*s == c)
  8009a8:	38 ca                	cmp    %cl,%dl
  8009aa:	74 0f                	je     8009bb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ac:	83 c0 01             	add    $0x1,%eax
  8009af:	0f b6 10             	movzbl (%eax),%edx
  8009b2:	84 d2                	test   %dl,%dl
  8009b4:	75 f2                	jne    8009a8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c7:	eb 03                	jmp    8009cc <strfind+0xf>
  8009c9:	83 c0 01             	add    $0x1,%eax
  8009cc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009cf:	38 ca                	cmp    %cl,%dl
  8009d1:	74 04                	je     8009d7 <strfind+0x1a>
  8009d3:	84 d2                	test   %dl,%dl
  8009d5:	75 f2                	jne    8009c9 <strfind+0xc>
			break;
	return (char *) s;
}
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    

008009d9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	57                   	push   %edi
  8009dd:	56                   	push   %esi
  8009de:	53                   	push   %ebx
  8009df:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009e5:	85 c9                	test   %ecx,%ecx
  8009e7:	74 36                	je     800a1f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009e9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ef:	75 28                	jne    800a19 <memset+0x40>
  8009f1:	f6 c1 03             	test   $0x3,%cl
  8009f4:	75 23                	jne    800a19 <memset+0x40>
		c &= 0xFF;
  8009f6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009fa:	89 d3                	mov    %edx,%ebx
  8009fc:	c1 e3 08             	shl    $0x8,%ebx
  8009ff:	89 d6                	mov    %edx,%esi
  800a01:	c1 e6 18             	shl    $0x18,%esi
  800a04:	89 d0                	mov    %edx,%eax
  800a06:	c1 e0 10             	shl    $0x10,%eax
  800a09:	09 f0                	or     %esi,%eax
  800a0b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a0d:	89 d8                	mov    %ebx,%eax
  800a0f:	09 d0                	or     %edx,%eax
  800a11:	c1 e9 02             	shr    $0x2,%ecx
  800a14:	fc                   	cld    
  800a15:	f3 ab                	rep stos %eax,%es:(%edi)
  800a17:	eb 06                	jmp    800a1f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1c:	fc                   	cld    
  800a1d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a1f:	89 f8                	mov    %edi,%eax
  800a21:	5b                   	pop    %ebx
  800a22:	5e                   	pop    %esi
  800a23:	5f                   	pop    %edi
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	57                   	push   %edi
  800a2a:	56                   	push   %esi
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a31:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a34:	39 c6                	cmp    %eax,%esi
  800a36:	73 35                	jae    800a6d <memmove+0x47>
  800a38:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a3b:	39 d0                	cmp    %edx,%eax
  800a3d:	73 2e                	jae    800a6d <memmove+0x47>
		s += n;
		d += n;
  800a3f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a42:	89 d6                	mov    %edx,%esi
  800a44:	09 fe                	or     %edi,%esi
  800a46:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a4c:	75 13                	jne    800a61 <memmove+0x3b>
  800a4e:	f6 c1 03             	test   $0x3,%cl
  800a51:	75 0e                	jne    800a61 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a53:	83 ef 04             	sub    $0x4,%edi
  800a56:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a59:	c1 e9 02             	shr    $0x2,%ecx
  800a5c:	fd                   	std    
  800a5d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5f:	eb 09                	jmp    800a6a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a61:	83 ef 01             	sub    $0x1,%edi
  800a64:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a67:	fd                   	std    
  800a68:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6a:	fc                   	cld    
  800a6b:	eb 1d                	jmp    800a8a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6d:	89 f2                	mov    %esi,%edx
  800a6f:	09 c2                	or     %eax,%edx
  800a71:	f6 c2 03             	test   $0x3,%dl
  800a74:	75 0f                	jne    800a85 <memmove+0x5f>
  800a76:	f6 c1 03             	test   $0x3,%cl
  800a79:	75 0a                	jne    800a85 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a7b:	c1 e9 02             	shr    $0x2,%ecx
  800a7e:	89 c7                	mov    %eax,%edi
  800a80:	fc                   	cld    
  800a81:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a83:	eb 05                	jmp    800a8a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a85:	89 c7                	mov    %eax,%edi
  800a87:	fc                   	cld    
  800a88:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a8a:	5e                   	pop    %esi
  800a8b:	5f                   	pop    %edi
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    

00800a8e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a91:	ff 75 10             	pushl  0x10(%ebp)
  800a94:	ff 75 0c             	pushl  0xc(%ebp)
  800a97:	ff 75 08             	pushl  0x8(%ebp)
  800a9a:	e8 87 ff ff ff       	call   800a26 <memmove>
}
  800a9f:	c9                   	leave  
  800aa0:	c3                   	ret    

00800aa1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
  800aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aac:	89 c6                	mov    %eax,%esi
  800aae:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab1:	eb 1a                	jmp    800acd <memcmp+0x2c>
		if (*s1 != *s2)
  800ab3:	0f b6 08             	movzbl (%eax),%ecx
  800ab6:	0f b6 1a             	movzbl (%edx),%ebx
  800ab9:	38 d9                	cmp    %bl,%cl
  800abb:	74 0a                	je     800ac7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800abd:	0f b6 c1             	movzbl %cl,%eax
  800ac0:	0f b6 db             	movzbl %bl,%ebx
  800ac3:	29 d8                	sub    %ebx,%eax
  800ac5:	eb 0f                	jmp    800ad6 <memcmp+0x35>
		s1++, s2++;
  800ac7:	83 c0 01             	add    $0x1,%eax
  800aca:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acd:	39 f0                	cmp    %esi,%eax
  800acf:	75 e2                	jne    800ab3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	53                   	push   %ebx
  800ade:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ae1:	89 c1                	mov    %eax,%ecx
  800ae3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aea:	eb 0a                	jmp    800af6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aec:	0f b6 10             	movzbl (%eax),%edx
  800aef:	39 da                	cmp    %ebx,%edx
  800af1:	74 07                	je     800afa <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af3:	83 c0 01             	add    $0x1,%eax
  800af6:	39 c8                	cmp    %ecx,%eax
  800af8:	72 f2                	jb     800aec <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800afa:	5b                   	pop    %ebx
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
  800b03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b06:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b09:	eb 03                	jmp    800b0e <strtol+0x11>
		s++;
  800b0b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0e:	0f b6 01             	movzbl (%ecx),%eax
  800b11:	3c 20                	cmp    $0x20,%al
  800b13:	74 f6                	je     800b0b <strtol+0xe>
  800b15:	3c 09                	cmp    $0x9,%al
  800b17:	74 f2                	je     800b0b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b19:	3c 2b                	cmp    $0x2b,%al
  800b1b:	75 0a                	jne    800b27 <strtol+0x2a>
		s++;
  800b1d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b20:	bf 00 00 00 00       	mov    $0x0,%edi
  800b25:	eb 11                	jmp    800b38 <strtol+0x3b>
  800b27:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b2c:	3c 2d                	cmp    $0x2d,%al
  800b2e:	75 08                	jne    800b38 <strtol+0x3b>
		s++, neg = 1;
  800b30:	83 c1 01             	add    $0x1,%ecx
  800b33:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b38:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b3e:	75 15                	jne    800b55 <strtol+0x58>
  800b40:	80 39 30             	cmpb   $0x30,(%ecx)
  800b43:	75 10                	jne    800b55 <strtol+0x58>
  800b45:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b49:	75 7c                	jne    800bc7 <strtol+0xca>
		s += 2, base = 16;
  800b4b:	83 c1 02             	add    $0x2,%ecx
  800b4e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b53:	eb 16                	jmp    800b6b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b55:	85 db                	test   %ebx,%ebx
  800b57:	75 12                	jne    800b6b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b59:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b5e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b61:	75 08                	jne    800b6b <strtol+0x6e>
		s++, base = 8;
  800b63:	83 c1 01             	add    $0x1,%ecx
  800b66:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b70:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b73:	0f b6 11             	movzbl (%ecx),%edx
  800b76:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b79:	89 f3                	mov    %esi,%ebx
  800b7b:	80 fb 09             	cmp    $0x9,%bl
  800b7e:	77 08                	ja     800b88 <strtol+0x8b>
			dig = *s - '0';
  800b80:	0f be d2             	movsbl %dl,%edx
  800b83:	83 ea 30             	sub    $0x30,%edx
  800b86:	eb 22                	jmp    800baa <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b88:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b8b:	89 f3                	mov    %esi,%ebx
  800b8d:	80 fb 19             	cmp    $0x19,%bl
  800b90:	77 08                	ja     800b9a <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b92:	0f be d2             	movsbl %dl,%edx
  800b95:	83 ea 57             	sub    $0x57,%edx
  800b98:	eb 10                	jmp    800baa <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b9a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b9d:	89 f3                	mov    %esi,%ebx
  800b9f:	80 fb 19             	cmp    $0x19,%bl
  800ba2:	77 16                	ja     800bba <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ba4:	0f be d2             	movsbl %dl,%edx
  800ba7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800baa:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bad:	7d 0b                	jge    800bba <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800baf:	83 c1 01             	add    $0x1,%ecx
  800bb2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bb6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bb8:	eb b9                	jmp    800b73 <strtol+0x76>

	if (endptr)
  800bba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bbe:	74 0d                	je     800bcd <strtol+0xd0>
		*endptr = (char *) s;
  800bc0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc3:	89 0e                	mov    %ecx,(%esi)
  800bc5:	eb 06                	jmp    800bcd <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc7:	85 db                	test   %ebx,%ebx
  800bc9:	74 98                	je     800b63 <strtol+0x66>
  800bcb:	eb 9e                	jmp    800b6b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bcd:	89 c2                	mov    %eax,%edx
  800bcf:	f7 da                	neg    %edx
  800bd1:	85 ff                	test   %edi,%edi
  800bd3:	0f 45 c2             	cmovne %edx,%eax
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be1:	b8 00 00 00 00       	mov    $0x0,%eax
  800be6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bec:	89 c3                	mov    %eax,%ebx
  800bee:	89 c7                	mov    %eax,%edi
  800bf0:	89 c6                	mov    %eax,%esi
  800bf2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bff:	ba 00 00 00 00       	mov    $0x0,%edx
  800c04:	b8 01 00 00 00       	mov    $0x1,%eax
  800c09:	89 d1                	mov    %edx,%ecx
  800c0b:	89 d3                	mov    %edx,%ebx
  800c0d:	89 d7                	mov    %edx,%edi
  800c0f:	89 d6                	mov    %edx,%esi
  800c11:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5f                   	pop    %edi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	57                   	push   %edi
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
  800c1e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c21:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c26:	b8 03 00 00 00       	mov    $0x3,%eax
  800c2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2e:	89 cb                	mov    %ecx,%ebx
  800c30:	89 cf                	mov    %ecx,%edi
  800c32:	89 ce                	mov    %ecx,%esi
  800c34:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c36:	85 c0                	test   %eax,%eax
  800c38:	7e 17                	jle    800c51 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3a:	83 ec 0c             	sub    $0xc,%esp
  800c3d:	50                   	push   %eax
  800c3e:	6a 03                	push   $0x3
  800c40:	68 bf 2a 80 00       	push   $0x802abf
  800c45:	6a 23                	push   $0x23
  800c47:	68 dc 2a 80 00       	push   $0x802adc
  800c4c:	e8 e5 f5 ff ff       	call   800236 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c54:	5b                   	pop    %ebx
  800c55:	5e                   	pop    %esi
  800c56:	5f                   	pop    %edi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	57                   	push   %edi
  800c5d:	56                   	push   %esi
  800c5e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c64:	b8 02 00 00 00       	mov    $0x2,%eax
  800c69:	89 d1                	mov    %edx,%ecx
  800c6b:	89 d3                	mov    %edx,%ebx
  800c6d:	89 d7                	mov    %edx,%edi
  800c6f:	89 d6                	mov    %edx,%esi
  800c71:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c73:	5b                   	pop    %ebx
  800c74:	5e                   	pop    %esi
  800c75:	5f                   	pop    %edi
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    

00800c78 <sys_yield>:

void
sys_yield(void)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	57                   	push   %edi
  800c7c:	56                   	push   %esi
  800c7d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c83:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c88:	89 d1                	mov    %edx,%ecx
  800c8a:	89 d3                	mov    %edx,%ebx
  800c8c:	89 d7                	mov    %edx,%edi
  800c8e:	89 d6                	mov    %edx,%esi
  800c90:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca0:	be 00 00 00 00       	mov    $0x0,%esi
  800ca5:	b8 04 00 00 00       	mov    $0x4,%eax
  800caa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cad:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb3:	89 f7                	mov    %esi,%edi
  800cb5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb7:	85 c0                	test   %eax,%eax
  800cb9:	7e 17                	jle    800cd2 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbb:	83 ec 0c             	sub    $0xc,%esp
  800cbe:	50                   	push   %eax
  800cbf:	6a 04                	push   $0x4
  800cc1:	68 bf 2a 80 00       	push   $0x802abf
  800cc6:	6a 23                	push   $0x23
  800cc8:	68 dc 2a 80 00       	push   $0x802adc
  800ccd:	e8 64 f5 ff ff       	call   800236 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
  800ce0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce3:	b8 05 00 00 00       	mov    $0x5,%eax
  800ce8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ceb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf4:	8b 75 18             	mov    0x18(%ebp),%esi
  800cf7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	7e 17                	jle    800d14 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfd:	83 ec 0c             	sub    $0xc,%esp
  800d00:	50                   	push   %eax
  800d01:	6a 05                	push   $0x5
  800d03:	68 bf 2a 80 00       	push   $0x802abf
  800d08:	6a 23                	push   $0x23
  800d0a:	68 dc 2a 80 00       	push   $0x802adc
  800d0f:	e8 22 f5 ff ff       	call   800236 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d17:	5b                   	pop    %ebx
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	57                   	push   %edi
  800d20:	56                   	push   %esi
  800d21:	53                   	push   %ebx
  800d22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d32:	8b 55 08             	mov    0x8(%ebp),%edx
  800d35:	89 df                	mov    %ebx,%edi
  800d37:	89 de                	mov    %ebx,%esi
  800d39:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	7e 17                	jle    800d56 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3f:	83 ec 0c             	sub    $0xc,%esp
  800d42:	50                   	push   %eax
  800d43:	6a 06                	push   $0x6
  800d45:	68 bf 2a 80 00       	push   $0x802abf
  800d4a:	6a 23                	push   $0x23
  800d4c:	68 dc 2a 80 00       	push   $0x802adc
  800d51:	e8 e0 f4 ff ff       	call   800236 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6c:	b8 08 00 00 00       	mov    $0x8,%eax
  800d71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d74:	8b 55 08             	mov    0x8(%ebp),%edx
  800d77:	89 df                	mov    %ebx,%edi
  800d79:	89 de                	mov    %ebx,%esi
  800d7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	7e 17                	jle    800d98 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	50                   	push   %eax
  800d85:	6a 08                	push   $0x8
  800d87:	68 bf 2a 80 00       	push   $0x802abf
  800d8c:	6a 23                	push   $0x23
  800d8e:	68 dc 2a 80 00       	push   $0x802adc
  800d93:	e8 9e f4 ff ff       	call   800236 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
  800da6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dae:	b8 09 00 00 00       	mov    $0x9,%eax
  800db3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db6:	8b 55 08             	mov    0x8(%ebp),%edx
  800db9:	89 df                	mov    %ebx,%edi
  800dbb:	89 de                	mov    %ebx,%esi
  800dbd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	7e 17                	jle    800dda <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc3:	83 ec 0c             	sub    $0xc,%esp
  800dc6:	50                   	push   %eax
  800dc7:	6a 09                	push   $0x9
  800dc9:	68 bf 2a 80 00       	push   $0x802abf
  800dce:	6a 23                	push   $0x23
  800dd0:	68 dc 2a 80 00       	push   $0x802adc
  800dd5:	e8 5c f4 ff ff       	call   800236 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
  800de8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800deb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800df5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfb:	89 df                	mov    %ebx,%edi
  800dfd:	89 de                	mov    %ebx,%esi
  800dff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e01:	85 c0                	test   %eax,%eax
  800e03:	7e 17                	jle    800e1c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e05:	83 ec 0c             	sub    $0xc,%esp
  800e08:	50                   	push   %eax
  800e09:	6a 0a                	push   $0xa
  800e0b:	68 bf 2a 80 00       	push   $0x802abf
  800e10:	6a 23                	push   $0x23
  800e12:	68 dc 2a 80 00       	push   $0x802adc
  800e17:	e8 1a f4 ff ff       	call   800236 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	57                   	push   %edi
  800e28:	56                   	push   %esi
  800e29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2a:	be 00 00 00 00       	mov    $0x0,%esi
  800e2f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e37:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e3d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e40:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e42:	5b                   	pop    %ebx
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	57                   	push   %edi
  800e4b:	56                   	push   %esi
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e50:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e55:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5d:	89 cb                	mov    %ecx,%ebx
  800e5f:	89 cf                	mov    %ecx,%edi
  800e61:	89 ce                	mov    %ecx,%esi
  800e63:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e65:	85 c0                	test   %eax,%eax
  800e67:	7e 17                	jle    800e80 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e69:	83 ec 0c             	sub    $0xc,%esp
  800e6c:	50                   	push   %eax
  800e6d:	6a 0d                	push   $0xd
  800e6f:	68 bf 2a 80 00       	push   $0x802abf
  800e74:	6a 23                	push   $0x23
  800e76:	68 dc 2a 80 00       	push   $0x802adc
  800e7b:	e8 b6 f3 ff ff       	call   800236 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e83:	5b                   	pop    %ebx
  800e84:	5e                   	pop    %esi
  800e85:	5f                   	pop    %edi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    

00800e88 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	57                   	push   %edi
  800e8c:	56                   	push   %esi
  800e8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e93:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e98:	89 d1                	mov    %edx,%ecx
  800e9a:	89 d3                	mov    %edx,%ebx
  800e9c:	89 d7                	mov    %edx,%edi
  800e9e:	89 d6                	mov    %edx,%esi
  800ea0:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5f                   	pop    %edi
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	56                   	push   %esi
  800eab:	53                   	push   %ebx
  800eac:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800eaf:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800eb1:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800eb5:	75 25                	jne    800edc <pgfault+0x35>
  800eb7:	89 d8                	mov    %ebx,%eax
  800eb9:	c1 e8 0c             	shr    $0xc,%eax
  800ebc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ec3:	f6 c4 08             	test   $0x8,%ah
  800ec6:	75 14                	jne    800edc <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800ec8:	83 ec 04             	sub    $0x4,%esp
  800ecb:	68 ec 2a 80 00       	push   $0x802aec
  800ed0:	6a 1e                	push   $0x1e
  800ed2:	68 80 2b 80 00       	push   $0x802b80
  800ed7:	e8 5a f3 ff ff       	call   800236 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800edc:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800ee2:	e8 72 fd ff ff       	call   800c59 <sys_getenvid>
  800ee7:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800ee9:	83 ec 04             	sub    $0x4,%esp
  800eec:	6a 07                	push   $0x7
  800eee:	68 00 f0 7f 00       	push   $0x7ff000
  800ef3:	50                   	push   %eax
  800ef4:	e8 9e fd ff ff       	call   800c97 <sys_page_alloc>
	if (r < 0)
  800ef9:	83 c4 10             	add    $0x10,%esp
  800efc:	85 c0                	test   %eax,%eax
  800efe:	79 12                	jns    800f12 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800f00:	50                   	push   %eax
  800f01:	68 18 2b 80 00       	push   $0x802b18
  800f06:	6a 33                	push   $0x33
  800f08:	68 80 2b 80 00       	push   $0x802b80
  800f0d:	e8 24 f3 ff ff       	call   800236 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800f12:	83 ec 04             	sub    $0x4,%esp
  800f15:	68 00 10 00 00       	push   $0x1000
  800f1a:	53                   	push   %ebx
  800f1b:	68 00 f0 7f 00       	push   $0x7ff000
  800f20:	e8 69 fb ff ff       	call   800a8e <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800f25:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f2c:	53                   	push   %ebx
  800f2d:	56                   	push   %esi
  800f2e:	68 00 f0 7f 00       	push   $0x7ff000
  800f33:	56                   	push   %esi
  800f34:	e8 a1 fd ff ff       	call   800cda <sys_page_map>
	if (r < 0)
  800f39:	83 c4 20             	add    $0x20,%esp
  800f3c:	85 c0                	test   %eax,%eax
  800f3e:	79 12                	jns    800f52 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800f40:	50                   	push   %eax
  800f41:	68 3c 2b 80 00       	push   $0x802b3c
  800f46:	6a 3b                	push   $0x3b
  800f48:	68 80 2b 80 00       	push   $0x802b80
  800f4d:	e8 e4 f2 ff ff       	call   800236 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800f52:	83 ec 08             	sub    $0x8,%esp
  800f55:	68 00 f0 7f 00       	push   $0x7ff000
  800f5a:	56                   	push   %esi
  800f5b:	e8 bc fd ff ff       	call   800d1c <sys_page_unmap>
	if (r < 0)
  800f60:	83 c4 10             	add    $0x10,%esp
  800f63:	85 c0                	test   %eax,%eax
  800f65:	79 12                	jns    800f79 <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800f67:	50                   	push   %eax
  800f68:	68 60 2b 80 00       	push   $0x802b60
  800f6d:	6a 40                	push   $0x40
  800f6f:	68 80 2b 80 00       	push   $0x802b80
  800f74:	e8 bd f2 ff ff       	call   800236 <_panic>
}
  800f79:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f7c:	5b                   	pop    %ebx
  800f7d:	5e                   	pop    %esi
  800f7e:	5d                   	pop    %ebp
  800f7f:	c3                   	ret    

00800f80 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	57                   	push   %edi
  800f84:	56                   	push   %esi
  800f85:	53                   	push   %ebx
  800f86:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800f89:	68 a7 0e 80 00       	push   $0x800ea7
  800f8e:	e8 e8 12 00 00       	call   80227b <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f93:	b8 07 00 00 00       	mov    $0x7,%eax
  800f98:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800f9a:	83 c4 10             	add    $0x10,%esp
  800f9d:	85 c0                	test   %eax,%eax
  800f9f:	0f 88 64 01 00 00    	js     801109 <fork+0x189>
  800fa5:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800faa:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	75 21                	jne    800fd4 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fb3:	e8 a1 fc ff ff       	call   800c59 <sys_getenvid>
  800fb8:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fbd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fc0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fc5:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  800fca:	ba 00 00 00 00       	mov    $0x0,%edx
  800fcf:	e9 3f 01 00 00       	jmp    801113 <fork+0x193>
  800fd4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fd7:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800fd9:	89 d8                	mov    %ebx,%eax
  800fdb:	c1 e8 16             	shr    $0x16,%eax
  800fde:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fe5:	a8 01                	test   $0x1,%al
  800fe7:	0f 84 bd 00 00 00    	je     8010aa <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800fed:	89 d8                	mov    %ebx,%eax
  800fef:	c1 e8 0c             	shr    $0xc,%eax
  800ff2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ff9:	f6 c2 01             	test   $0x1,%dl
  800ffc:	0f 84 a8 00 00 00    	je     8010aa <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  801002:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801009:	a8 04                	test   $0x4,%al
  80100b:	0f 84 99 00 00 00    	je     8010aa <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  801011:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801018:	f6 c4 04             	test   $0x4,%ah
  80101b:	74 17                	je     801034 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  80101d:	83 ec 0c             	sub    $0xc,%esp
  801020:	68 07 0e 00 00       	push   $0xe07
  801025:	53                   	push   %ebx
  801026:	57                   	push   %edi
  801027:	53                   	push   %ebx
  801028:	6a 00                	push   $0x0
  80102a:	e8 ab fc ff ff       	call   800cda <sys_page_map>
  80102f:	83 c4 20             	add    $0x20,%esp
  801032:	eb 76                	jmp    8010aa <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801034:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80103b:	a8 02                	test   $0x2,%al
  80103d:	75 0c                	jne    80104b <fork+0xcb>
  80103f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801046:	f6 c4 08             	test   $0x8,%ah
  801049:	74 3f                	je     80108a <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  80104b:	83 ec 0c             	sub    $0xc,%esp
  80104e:	68 05 08 00 00       	push   $0x805
  801053:	53                   	push   %ebx
  801054:	57                   	push   %edi
  801055:	53                   	push   %ebx
  801056:	6a 00                	push   $0x0
  801058:	e8 7d fc ff ff       	call   800cda <sys_page_map>
		if (r < 0)
  80105d:	83 c4 20             	add    $0x20,%esp
  801060:	85 c0                	test   %eax,%eax
  801062:	0f 88 a5 00 00 00    	js     80110d <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  801068:	83 ec 0c             	sub    $0xc,%esp
  80106b:	68 05 08 00 00       	push   $0x805
  801070:	53                   	push   %ebx
  801071:	6a 00                	push   $0x0
  801073:	53                   	push   %ebx
  801074:	6a 00                	push   $0x0
  801076:	e8 5f fc ff ff       	call   800cda <sys_page_map>
  80107b:	83 c4 20             	add    $0x20,%esp
  80107e:	85 c0                	test   %eax,%eax
  801080:	b9 00 00 00 00       	mov    $0x0,%ecx
  801085:	0f 4f c1             	cmovg  %ecx,%eax
  801088:	eb 1c                	jmp    8010a6 <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  80108a:	83 ec 0c             	sub    $0xc,%esp
  80108d:	6a 05                	push   $0x5
  80108f:	53                   	push   %ebx
  801090:	57                   	push   %edi
  801091:	53                   	push   %ebx
  801092:	6a 00                	push   $0x0
  801094:	e8 41 fc ff ff       	call   800cda <sys_page_map>
  801099:	83 c4 20             	add    $0x20,%esp
  80109c:	85 c0                	test   %eax,%eax
  80109e:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010a3:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	78 67                	js     801111 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  8010aa:	83 c6 01             	add    $0x1,%esi
  8010ad:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010b3:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  8010b9:	0f 85 1a ff ff ff    	jne    800fd9 <fork+0x59>
  8010bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  8010c2:	83 ec 04             	sub    $0x4,%esp
  8010c5:	6a 07                	push   $0x7
  8010c7:	68 00 f0 bf ee       	push   $0xeebff000
  8010cc:	57                   	push   %edi
  8010cd:	e8 c5 fb ff ff       	call   800c97 <sys_page_alloc>
	if (r < 0)
  8010d2:	83 c4 10             	add    $0x10,%esp
		return r;
  8010d5:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	78 38                	js     801113 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010db:	83 ec 08             	sub    $0x8,%esp
  8010de:	68 c2 22 80 00       	push   $0x8022c2
  8010e3:	57                   	push   %edi
  8010e4:	e8 f9 fc ff ff       	call   800de2 <sys_env_set_pgfault_upcall>
	if (r < 0)
  8010e9:	83 c4 10             	add    $0x10,%esp
		return r;
  8010ec:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  8010ee:	85 c0                	test   %eax,%eax
  8010f0:	78 21                	js     801113 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  8010f2:	83 ec 08             	sub    $0x8,%esp
  8010f5:	6a 02                	push   $0x2
  8010f7:	57                   	push   %edi
  8010f8:	e8 61 fc ff ff       	call   800d5e <sys_env_set_status>
	if (r < 0)
  8010fd:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801100:	85 c0                	test   %eax,%eax
  801102:	0f 48 f8             	cmovs  %eax,%edi
  801105:	89 fa                	mov    %edi,%edx
  801107:	eb 0a                	jmp    801113 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  801109:	89 c2                	mov    %eax,%edx
  80110b:	eb 06                	jmp    801113 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  80110d:	89 c2                	mov    %eax,%edx
  80110f:	eb 02                	jmp    801113 <fork+0x193>
  801111:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  801113:	89 d0                	mov    %edx,%eax
  801115:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801118:	5b                   	pop    %ebx
  801119:	5e                   	pop    %esi
  80111a:	5f                   	pop    %edi
  80111b:	5d                   	pop    %ebp
  80111c:	c3                   	ret    

0080111d <sfork>:

// Challenge!
int
sfork(void)
{
  80111d:	55                   	push   %ebp
  80111e:	89 e5                	mov    %esp,%ebp
  801120:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801123:	68 8b 2b 80 00       	push   $0x802b8b
  801128:	68 c9 00 00 00       	push   $0xc9
  80112d:	68 80 2b 80 00       	push   $0x802b80
  801132:	e8 ff f0 ff ff       	call   800236 <_panic>

00801137 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80113a:	8b 45 08             	mov    0x8(%ebp),%eax
  80113d:	05 00 00 00 30       	add    $0x30000000,%eax
  801142:	c1 e8 0c             	shr    $0xc,%eax
}
  801145:	5d                   	pop    %ebp
  801146:	c3                   	ret    

00801147 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801147:	55                   	push   %ebp
  801148:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80114a:	8b 45 08             	mov    0x8(%ebp),%eax
  80114d:	05 00 00 00 30       	add    $0x30000000,%eax
  801152:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801157:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80115c:	5d                   	pop    %ebp
  80115d:	c3                   	ret    

0080115e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80115e:	55                   	push   %ebp
  80115f:	89 e5                	mov    %esp,%ebp
  801161:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801164:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801169:	89 c2                	mov    %eax,%edx
  80116b:	c1 ea 16             	shr    $0x16,%edx
  80116e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801175:	f6 c2 01             	test   $0x1,%dl
  801178:	74 11                	je     80118b <fd_alloc+0x2d>
  80117a:	89 c2                	mov    %eax,%edx
  80117c:	c1 ea 0c             	shr    $0xc,%edx
  80117f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801186:	f6 c2 01             	test   $0x1,%dl
  801189:	75 09                	jne    801194 <fd_alloc+0x36>
			*fd_store = fd;
  80118b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80118d:	b8 00 00 00 00       	mov    $0x0,%eax
  801192:	eb 17                	jmp    8011ab <fd_alloc+0x4d>
  801194:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801199:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80119e:	75 c9                	jne    801169 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011a0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011a6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011ab:	5d                   	pop    %ebp
  8011ac:	c3                   	ret    

008011ad <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011ad:	55                   	push   %ebp
  8011ae:	89 e5                	mov    %esp,%ebp
  8011b0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011b3:	83 f8 1f             	cmp    $0x1f,%eax
  8011b6:	77 36                	ja     8011ee <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011b8:	c1 e0 0c             	shl    $0xc,%eax
  8011bb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011c0:	89 c2                	mov    %eax,%edx
  8011c2:	c1 ea 16             	shr    $0x16,%edx
  8011c5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011cc:	f6 c2 01             	test   $0x1,%dl
  8011cf:	74 24                	je     8011f5 <fd_lookup+0x48>
  8011d1:	89 c2                	mov    %eax,%edx
  8011d3:	c1 ea 0c             	shr    $0xc,%edx
  8011d6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011dd:	f6 c2 01             	test   $0x1,%dl
  8011e0:	74 1a                	je     8011fc <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e5:	89 02                	mov    %eax,(%edx)
	return 0;
  8011e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ec:	eb 13                	jmp    801201 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f3:	eb 0c                	jmp    801201 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011fa:	eb 05                	jmp    801201 <fd_lookup+0x54>
  8011fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801201:	5d                   	pop    %ebp
  801202:	c3                   	ret    

00801203 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
  801206:	83 ec 08             	sub    $0x8,%esp
  801209:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80120c:	ba 24 2c 80 00       	mov    $0x802c24,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801211:	eb 13                	jmp    801226 <dev_lookup+0x23>
  801213:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801216:	39 08                	cmp    %ecx,(%eax)
  801218:	75 0c                	jne    801226 <dev_lookup+0x23>
			*dev = devtab[i];
  80121a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80121d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80121f:	b8 00 00 00 00       	mov    $0x0,%eax
  801224:	eb 2e                	jmp    801254 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801226:	8b 02                	mov    (%edx),%eax
  801228:	85 c0                	test   %eax,%eax
  80122a:	75 e7                	jne    801213 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80122c:	a1 08 40 80 00       	mov    0x804008,%eax
  801231:	8b 40 48             	mov    0x48(%eax),%eax
  801234:	83 ec 04             	sub    $0x4,%esp
  801237:	51                   	push   %ecx
  801238:	50                   	push   %eax
  801239:	68 a4 2b 80 00       	push   $0x802ba4
  80123e:	e8 cc f0 ff ff       	call   80030f <cprintf>
	*dev = 0;
  801243:	8b 45 0c             	mov    0xc(%ebp),%eax
  801246:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80124c:	83 c4 10             	add    $0x10,%esp
  80124f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801254:	c9                   	leave  
  801255:	c3                   	ret    

00801256 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
  801259:	56                   	push   %esi
  80125a:	53                   	push   %ebx
  80125b:	83 ec 10             	sub    $0x10,%esp
  80125e:	8b 75 08             	mov    0x8(%ebp),%esi
  801261:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801264:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801267:	50                   	push   %eax
  801268:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80126e:	c1 e8 0c             	shr    $0xc,%eax
  801271:	50                   	push   %eax
  801272:	e8 36 ff ff ff       	call   8011ad <fd_lookup>
  801277:	83 c4 08             	add    $0x8,%esp
  80127a:	85 c0                	test   %eax,%eax
  80127c:	78 05                	js     801283 <fd_close+0x2d>
	    || fd != fd2)
  80127e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801281:	74 0c                	je     80128f <fd_close+0x39>
		return (must_exist ? r : 0);
  801283:	84 db                	test   %bl,%bl
  801285:	ba 00 00 00 00       	mov    $0x0,%edx
  80128a:	0f 44 c2             	cmove  %edx,%eax
  80128d:	eb 41                	jmp    8012d0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80128f:	83 ec 08             	sub    $0x8,%esp
  801292:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801295:	50                   	push   %eax
  801296:	ff 36                	pushl  (%esi)
  801298:	e8 66 ff ff ff       	call   801203 <dev_lookup>
  80129d:	89 c3                	mov    %eax,%ebx
  80129f:	83 c4 10             	add    $0x10,%esp
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	78 1a                	js     8012c0 <fd_close+0x6a>
		if (dev->dev_close)
  8012a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012ac:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	74 0b                	je     8012c0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012b5:	83 ec 0c             	sub    $0xc,%esp
  8012b8:	56                   	push   %esi
  8012b9:	ff d0                	call   *%eax
  8012bb:	89 c3                	mov    %eax,%ebx
  8012bd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012c0:	83 ec 08             	sub    $0x8,%esp
  8012c3:	56                   	push   %esi
  8012c4:	6a 00                	push   $0x0
  8012c6:	e8 51 fa ff ff       	call   800d1c <sys_page_unmap>
	return r;
  8012cb:	83 c4 10             	add    $0x10,%esp
  8012ce:	89 d8                	mov    %ebx,%eax
}
  8012d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d3:	5b                   	pop    %ebx
  8012d4:	5e                   	pop    %esi
  8012d5:	5d                   	pop    %ebp
  8012d6:	c3                   	ret    

008012d7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012d7:	55                   	push   %ebp
  8012d8:	89 e5                	mov    %esp,%ebp
  8012da:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e0:	50                   	push   %eax
  8012e1:	ff 75 08             	pushl  0x8(%ebp)
  8012e4:	e8 c4 fe ff ff       	call   8011ad <fd_lookup>
  8012e9:	83 c4 08             	add    $0x8,%esp
  8012ec:	85 c0                	test   %eax,%eax
  8012ee:	78 10                	js     801300 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012f0:	83 ec 08             	sub    $0x8,%esp
  8012f3:	6a 01                	push   $0x1
  8012f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8012f8:	e8 59 ff ff ff       	call   801256 <fd_close>
  8012fd:	83 c4 10             	add    $0x10,%esp
}
  801300:	c9                   	leave  
  801301:	c3                   	ret    

00801302 <close_all>:

void
close_all(void)
{
  801302:	55                   	push   %ebp
  801303:	89 e5                	mov    %esp,%ebp
  801305:	53                   	push   %ebx
  801306:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801309:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80130e:	83 ec 0c             	sub    $0xc,%esp
  801311:	53                   	push   %ebx
  801312:	e8 c0 ff ff ff       	call   8012d7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801317:	83 c3 01             	add    $0x1,%ebx
  80131a:	83 c4 10             	add    $0x10,%esp
  80131d:	83 fb 20             	cmp    $0x20,%ebx
  801320:	75 ec                	jne    80130e <close_all+0xc>
		close(i);
}
  801322:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801325:	c9                   	leave  
  801326:	c3                   	ret    

00801327 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801327:	55                   	push   %ebp
  801328:	89 e5                	mov    %esp,%ebp
  80132a:	57                   	push   %edi
  80132b:	56                   	push   %esi
  80132c:	53                   	push   %ebx
  80132d:	83 ec 2c             	sub    $0x2c,%esp
  801330:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801333:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801336:	50                   	push   %eax
  801337:	ff 75 08             	pushl  0x8(%ebp)
  80133a:	e8 6e fe ff ff       	call   8011ad <fd_lookup>
  80133f:	83 c4 08             	add    $0x8,%esp
  801342:	85 c0                	test   %eax,%eax
  801344:	0f 88 c1 00 00 00    	js     80140b <dup+0xe4>
		return r;
	close(newfdnum);
  80134a:	83 ec 0c             	sub    $0xc,%esp
  80134d:	56                   	push   %esi
  80134e:	e8 84 ff ff ff       	call   8012d7 <close>

	newfd = INDEX2FD(newfdnum);
  801353:	89 f3                	mov    %esi,%ebx
  801355:	c1 e3 0c             	shl    $0xc,%ebx
  801358:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80135e:	83 c4 04             	add    $0x4,%esp
  801361:	ff 75 e4             	pushl  -0x1c(%ebp)
  801364:	e8 de fd ff ff       	call   801147 <fd2data>
  801369:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80136b:	89 1c 24             	mov    %ebx,(%esp)
  80136e:	e8 d4 fd ff ff       	call   801147 <fd2data>
  801373:	83 c4 10             	add    $0x10,%esp
  801376:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801379:	89 f8                	mov    %edi,%eax
  80137b:	c1 e8 16             	shr    $0x16,%eax
  80137e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801385:	a8 01                	test   $0x1,%al
  801387:	74 37                	je     8013c0 <dup+0x99>
  801389:	89 f8                	mov    %edi,%eax
  80138b:	c1 e8 0c             	shr    $0xc,%eax
  80138e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801395:	f6 c2 01             	test   $0x1,%dl
  801398:	74 26                	je     8013c0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80139a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013a1:	83 ec 0c             	sub    $0xc,%esp
  8013a4:	25 07 0e 00 00       	and    $0xe07,%eax
  8013a9:	50                   	push   %eax
  8013aa:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013ad:	6a 00                	push   $0x0
  8013af:	57                   	push   %edi
  8013b0:	6a 00                	push   $0x0
  8013b2:	e8 23 f9 ff ff       	call   800cda <sys_page_map>
  8013b7:	89 c7                	mov    %eax,%edi
  8013b9:	83 c4 20             	add    $0x20,%esp
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	78 2e                	js     8013ee <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013c3:	89 d0                	mov    %edx,%eax
  8013c5:	c1 e8 0c             	shr    $0xc,%eax
  8013c8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013cf:	83 ec 0c             	sub    $0xc,%esp
  8013d2:	25 07 0e 00 00       	and    $0xe07,%eax
  8013d7:	50                   	push   %eax
  8013d8:	53                   	push   %ebx
  8013d9:	6a 00                	push   $0x0
  8013db:	52                   	push   %edx
  8013dc:	6a 00                	push   $0x0
  8013de:	e8 f7 f8 ff ff       	call   800cda <sys_page_map>
  8013e3:	89 c7                	mov    %eax,%edi
  8013e5:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013e8:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013ea:	85 ff                	test   %edi,%edi
  8013ec:	79 1d                	jns    80140b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013ee:	83 ec 08             	sub    $0x8,%esp
  8013f1:	53                   	push   %ebx
  8013f2:	6a 00                	push   $0x0
  8013f4:	e8 23 f9 ff ff       	call   800d1c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013f9:	83 c4 08             	add    $0x8,%esp
  8013fc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013ff:	6a 00                	push   $0x0
  801401:	e8 16 f9 ff ff       	call   800d1c <sys_page_unmap>
	return r;
  801406:	83 c4 10             	add    $0x10,%esp
  801409:	89 f8                	mov    %edi,%eax
}
  80140b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80140e:	5b                   	pop    %ebx
  80140f:	5e                   	pop    %esi
  801410:	5f                   	pop    %edi
  801411:	5d                   	pop    %ebp
  801412:	c3                   	ret    

00801413 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801413:	55                   	push   %ebp
  801414:	89 e5                	mov    %esp,%ebp
  801416:	53                   	push   %ebx
  801417:	83 ec 14             	sub    $0x14,%esp
  80141a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80141d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801420:	50                   	push   %eax
  801421:	53                   	push   %ebx
  801422:	e8 86 fd ff ff       	call   8011ad <fd_lookup>
  801427:	83 c4 08             	add    $0x8,%esp
  80142a:	89 c2                	mov    %eax,%edx
  80142c:	85 c0                	test   %eax,%eax
  80142e:	78 6d                	js     80149d <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801430:	83 ec 08             	sub    $0x8,%esp
  801433:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801436:	50                   	push   %eax
  801437:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143a:	ff 30                	pushl  (%eax)
  80143c:	e8 c2 fd ff ff       	call   801203 <dev_lookup>
  801441:	83 c4 10             	add    $0x10,%esp
  801444:	85 c0                	test   %eax,%eax
  801446:	78 4c                	js     801494 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801448:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80144b:	8b 42 08             	mov    0x8(%edx),%eax
  80144e:	83 e0 03             	and    $0x3,%eax
  801451:	83 f8 01             	cmp    $0x1,%eax
  801454:	75 21                	jne    801477 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801456:	a1 08 40 80 00       	mov    0x804008,%eax
  80145b:	8b 40 48             	mov    0x48(%eax),%eax
  80145e:	83 ec 04             	sub    $0x4,%esp
  801461:	53                   	push   %ebx
  801462:	50                   	push   %eax
  801463:	68 e8 2b 80 00       	push   $0x802be8
  801468:	e8 a2 ee ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  80146d:	83 c4 10             	add    $0x10,%esp
  801470:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801475:	eb 26                	jmp    80149d <read+0x8a>
	}
	if (!dev->dev_read)
  801477:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147a:	8b 40 08             	mov    0x8(%eax),%eax
  80147d:	85 c0                	test   %eax,%eax
  80147f:	74 17                	je     801498 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801481:	83 ec 04             	sub    $0x4,%esp
  801484:	ff 75 10             	pushl  0x10(%ebp)
  801487:	ff 75 0c             	pushl  0xc(%ebp)
  80148a:	52                   	push   %edx
  80148b:	ff d0                	call   *%eax
  80148d:	89 c2                	mov    %eax,%edx
  80148f:	83 c4 10             	add    $0x10,%esp
  801492:	eb 09                	jmp    80149d <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801494:	89 c2                	mov    %eax,%edx
  801496:	eb 05                	jmp    80149d <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801498:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80149d:	89 d0                	mov    %edx,%eax
  80149f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a2:	c9                   	leave  
  8014a3:	c3                   	ret    

008014a4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014a4:	55                   	push   %ebp
  8014a5:	89 e5                	mov    %esp,%ebp
  8014a7:	57                   	push   %edi
  8014a8:	56                   	push   %esi
  8014a9:	53                   	push   %ebx
  8014aa:	83 ec 0c             	sub    $0xc,%esp
  8014ad:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014b0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014b8:	eb 21                	jmp    8014db <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014ba:	83 ec 04             	sub    $0x4,%esp
  8014bd:	89 f0                	mov    %esi,%eax
  8014bf:	29 d8                	sub    %ebx,%eax
  8014c1:	50                   	push   %eax
  8014c2:	89 d8                	mov    %ebx,%eax
  8014c4:	03 45 0c             	add    0xc(%ebp),%eax
  8014c7:	50                   	push   %eax
  8014c8:	57                   	push   %edi
  8014c9:	e8 45 ff ff ff       	call   801413 <read>
		if (m < 0)
  8014ce:	83 c4 10             	add    $0x10,%esp
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	78 10                	js     8014e5 <readn+0x41>
			return m;
		if (m == 0)
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	74 0a                	je     8014e3 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014d9:	01 c3                	add    %eax,%ebx
  8014db:	39 f3                	cmp    %esi,%ebx
  8014dd:	72 db                	jb     8014ba <readn+0x16>
  8014df:	89 d8                	mov    %ebx,%eax
  8014e1:	eb 02                	jmp    8014e5 <readn+0x41>
  8014e3:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014e8:	5b                   	pop    %ebx
  8014e9:	5e                   	pop    %esi
  8014ea:	5f                   	pop    %edi
  8014eb:	5d                   	pop    %ebp
  8014ec:	c3                   	ret    

008014ed <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014ed:	55                   	push   %ebp
  8014ee:	89 e5                	mov    %esp,%ebp
  8014f0:	53                   	push   %ebx
  8014f1:	83 ec 14             	sub    $0x14,%esp
  8014f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014fa:	50                   	push   %eax
  8014fb:	53                   	push   %ebx
  8014fc:	e8 ac fc ff ff       	call   8011ad <fd_lookup>
  801501:	83 c4 08             	add    $0x8,%esp
  801504:	89 c2                	mov    %eax,%edx
  801506:	85 c0                	test   %eax,%eax
  801508:	78 68                	js     801572 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150a:	83 ec 08             	sub    $0x8,%esp
  80150d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801510:	50                   	push   %eax
  801511:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801514:	ff 30                	pushl  (%eax)
  801516:	e8 e8 fc ff ff       	call   801203 <dev_lookup>
  80151b:	83 c4 10             	add    $0x10,%esp
  80151e:	85 c0                	test   %eax,%eax
  801520:	78 47                	js     801569 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801522:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801525:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801529:	75 21                	jne    80154c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80152b:	a1 08 40 80 00       	mov    0x804008,%eax
  801530:	8b 40 48             	mov    0x48(%eax),%eax
  801533:	83 ec 04             	sub    $0x4,%esp
  801536:	53                   	push   %ebx
  801537:	50                   	push   %eax
  801538:	68 04 2c 80 00       	push   $0x802c04
  80153d:	e8 cd ed ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  801542:	83 c4 10             	add    $0x10,%esp
  801545:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80154a:	eb 26                	jmp    801572 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80154c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80154f:	8b 52 0c             	mov    0xc(%edx),%edx
  801552:	85 d2                	test   %edx,%edx
  801554:	74 17                	je     80156d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801556:	83 ec 04             	sub    $0x4,%esp
  801559:	ff 75 10             	pushl  0x10(%ebp)
  80155c:	ff 75 0c             	pushl  0xc(%ebp)
  80155f:	50                   	push   %eax
  801560:	ff d2                	call   *%edx
  801562:	89 c2                	mov    %eax,%edx
  801564:	83 c4 10             	add    $0x10,%esp
  801567:	eb 09                	jmp    801572 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801569:	89 c2                	mov    %eax,%edx
  80156b:	eb 05                	jmp    801572 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80156d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801572:	89 d0                	mov    %edx,%eax
  801574:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801577:	c9                   	leave  
  801578:	c3                   	ret    

00801579 <seek>:

int
seek(int fdnum, off_t offset)
{
  801579:	55                   	push   %ebp
  80157a:	89 e5                	mov    %esp,%ebp
  80157c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80157f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801582:	50                   	push   %eax
  801583:	ff 75 08             	pushl  0x8(%ebp)
  801586:	e8 22 fc ff ff       	call   8011ad <fd_lookup>
  80158b:	83 c4 08             	add    $0x8,%esp
  80158e:	85 c0                	test   %eax,%eax
  801590:	78 0e                	js     8015a0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801592:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801595:	8b 55 0c             	mov    0xc(%ebp),%edx
  801598:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80159b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015a0:	c9                   	leave  
  8015a1:	c3                   	ret    

008015a2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015a2:	55                   	push   %ebp
  8015a3:	89 e5                	mov    %esp,%ebp
  8015a5:	53                   	push   %ebx
  8015a6:	83 ec 14             	sub    $0x14,%esp
  8015a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015af:	50                   	push   %eax
  8015b0:	53                   	push   %ebx
  8015b1:	e8 f7 fb ff ff       	call   8011ad <fd_lookup>
  8015b6:	83 c4 08             	add    $0x8,%esp
  8015b9:	89 c2                	mov    %eax,%edx
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	78 65                	js     801624 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015bf:	83 ec 08             	sub    $0x8,%esp
  8015c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c5:	50                   	push   %eax
  8015c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c9:	ff 30                	pushl  (%eax)
  8015cb:	e8 33 fc ff ff       	call   801203 <dev_lookup>
  8015d0:	83 c4 10             	add    $0x10,%esp
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	78 44                	js     80161b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015da:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015de:	75 21                	jne    801601 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015e0:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015e5:	8b 40 48             	mov    0x48(%eax),%eax
  8015e8:	83 ec 04             	sub    $0x4,%esp
  8015eb:	53                   	push   %ebx
  8015ec:	50                   	push   %eax
  8015ed:	68 c4 2b 80 00       	push   $0x802bc4
  8015f2:	e8 18 ed ff ff       	call   80030f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015ff:	eb 23                	jmp    801624 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801601:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801604:	8b 52 18             	mov    0x18(%edx),%edx
  801607:	85 d2                	test   %edx,%edx
  801609:	74 14                	je     80161f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80160b:	83 ec 08             	sub    $0x8,%esp
  80160e:	ff 75 0c             	pushl  0xc(%ebp)
  801611:	50                   	push   %eax
  801612:	ff d2                	call   *%edx
  801614:	89 c2                	mov    %eax,%edx
  801616:	83 c4 10             	add    $0x10,%esp
  801619:	eb 09                	jmp    801624 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161b:	89 c2                	mov    %eax,%edx
  80161d:	eb 05                	jmp    801624 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80161f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801624:	89 d0                	mov    %edx,%eax
  801626:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801629:	c9                   	leave  
  80162a:	c3                   	ret    

0080162b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80162b:	55                   	push   %ebp
  80162c:	89 e5                	mov    %esp,%ebp
  80162e:	53                   	push   %ebx
  80162f:	83 ec 14             	sub    $0x14,%esp
  801632:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801635:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801638:	50                   	push   %eax
  801639:	ff 75 08             	pushl  0x8(%ebp)
  80163c:	e8 6c fb ff ff       	call   8011ad <fd_lookup>
  801641:	83 c4 08             	add    $0x8,%esp
  801644:	89 c2                	mov    %eax,%edx
  801646:	85 c0                	test   %eax,%eax
  801648:	78 58                	js     8016a2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164a:	83 ec 08             	sub    $0x8,%esp
  80164d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801650:	50                   	push   %eax
  801651:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801654:	ff 30                	pushl  (%eax)
  801656:	e8 a8 fb ff ff       	call   801203 <dev_lookup>
  80165b:	83 c4 10             	add    $0x10,%esp
  80165e:	85 c0                	test   %eax,%eax
  801660:	78 37                	js     801699 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801662:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801665:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801669:	74 32                	je     80169d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80166b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80166e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801675:	00 00 00 
	stat->st_isdir = 0;
  801678:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80167f:	00 00 00 
	stat->st_dev = dev;
  801682:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801688:	83 ec 08             	sub    $0x8,%esp
  80168b:	53                   	push   %ebx
  80168c:	ff 75 f0             	pushl  -0x10(%ebp)
  80168f:	ff 50 14             	call   *0x14(%eax)
  801692:	89 c2                	mov    %eax,%edx
  801694:	83 c4 10             	add    $0x10,%esp
  801697:	eb 09                	jmp    8016a2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801699:	89 c2                	mov    %eax,%edx
  80169b:	eb 05                	jmp    8016a2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80169d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016a2:	89 d0                	mov    %edx,%eax
  8016a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a7:	c9                   	leave  
  8016a8:	c3                   	ret    

008016a9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016a9:	55                   	push   %ebp
  8016aa:	89 e5                	mov    %esp,%ebp
  8016ac:	56                   	push   %esi
  8016ad:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016ae:	83 ec 08             	sub    $0x8,%esp
  8016b1:	6a 00                	push   $0x0
  8016b3:	ff 75 08             	pushl  0x8(%ebp)
  8016b6:	e8 d6 01 00 00       	call   801891 <open>
  8016bb:	89 c3                	mov    %eax,%ebx
  8016bd:	83 c4 10             	add    $0x10,%esp
  8016c0:	85 c0                	test   %eax,%eax
  8016c2:	78 1b                	js     8016df <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016c4:	83 ec 08             	sub    $0x8,%esp
  8016c7:	ff 75 0c             	pushl  0xc(%ebp)
  8016ca:	50                   	push   %eax
  8016cb:	e8 5b ff ff ff       	call   80162b <fstat>
  8016d0:	89 c6                	mov    %eax,%esi
	close(fd);
  8016d2:	89 1c 24             	mov    %ebx,(%esp)
  8016d5:	e8 fd fb ff ff       	call   8012d7 <close>
	return r;
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	89 f0                	mov    %esi,%eax
}
  8016df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e2:	5b                   	pop    %ebx
  8016e3:	5e                   	pop    %esi
  8016e4:	5d                   	pop    %ebp
  8016e5:	c3                   	ret    

008016e6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	56                   	push   %esi
  8016ea:	53                   	push   %ebx
  8016eb:	89 c6                	mov    %eax,%esi
  8016ed:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016ef:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016f6:	75 12                	jne    80170a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016f8:	83 ec 0c             	sub    $0xc,%esp
  8016fb:	6a 01                	push   $0x1
  8016fd:	e8 9f 0c 00 00       	call   8023a1 <ipc_find_env>
  801702:	a3 00 40 80 00       	mov    %eax,0x804000
  801707:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80170a:	6a 07                	push   $0x7
  80170c:	68 00 50 80 00       	push   $0x805000
  801711:	56                   	push   %esi
  801712:	ff 35 00 40 80 00    	pushl  0x804000
  801718:	e8 30 0c 00 00       	call   80234d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80171d:	83 c4 0c             	add    $0xc,%esp
  801720:	6a 00                	push   $0x0
  801722:	53                   	push   %ebx
  801723:	6a 00                	push   $0x0
  801725:	e8 bc 0b 00 00       	call   8022e6 <ipc_recv>
}
  80172a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80172d:	5b                   	pop    %ebx
  80172e:	5e                   	pop    %esi
  80172f:	5d                   	pop    %ebp
  801730:	c3                   	ret    

00801731 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801731:	55                   	push   %ebp
  801732:	89 e5                	mov    %esp,%ebp
  801734:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801737:	8b 45 08             	mov    0x8(%ebp),%eax
  80173a:	8b 40 0c             	mov    0xc(%eax),%eax
  80173d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801742:	8b 45 0c             	mov    0xc(%ebp),%eax
  801745:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80174a:	ba 00 00 00 00       	mov    $0x0,%edx
  80174f:	b8 02 00 00 00       	mov    $0x2,%eax
  801754:	e8 8d ff ff ff       	call   8016e6 <fsipc>
}
  801759:	c9                   	leave  
  80175a:	c3                   	ret    

0080175b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80175b:	55                   	push   %ebp
  80175c:	89 e5                	mov    %esp,%ebp
  80175e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801761:	8b 45 08             	mov    0x8(%ebp),%eax
  801764:	8b 40 0c             	mov    0xc(%eax),%eax
  801767:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80176c:	ba 00 00 00 00       	mov    $0x0,%edx
  801771:	b8 06 00 00 00       	mov    $0x6,%eax
  801776:	e8 6b ff ff ff       	call   8016e6 <fsipc>
}
  80177b:	c9                   	leave  
  80177c:	c3                   	ret    

0080177d <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80177d:	55                   	push   %ebp
  80177e:	89 e5                	mov    %esp,%ebp
  801780:	53                   	push   %ebx
  801781:	83 ec 04             	sub    $0x4,%esp
  801784:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801787:	8b 45 08             	mov    0x8(%ebp),%eax
  80178a:	8b 40 0c             	mov    0xc(%eax),%eax
  80178d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801792:	ba 00 00 00 00       	mov    $0x0,%edx
  801797:	b8 05 00 00 00       	mov    $0x5,%eax
  80179c:	e8 45 ff ff ff       	call   8016e6 <fsipc>
  8017a1:	85 c0                	test   %eax,%eax
  8017a3:	78 2c                	js     8017d1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017a5:	83 ec 08             	sub    $0x8,%esp
  8017a8:	68 00 50 80 00       	push   $0x805000
  8017ad:	53                   	push   %ebx
  8017ae:	e8 e1 f0 ff ff       	call   800894 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017b3:	a1 80 50 80 00       	mov    0x805080,%eax
  8017b8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017be:	a1 84 50 80 00       	mov    0x805084,%eax
  8017c3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017c9:	83 c4 10             	add    $0x10,%esp
  8017cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d4:	c9                   	leave  
  8017d5:	c3                   	ret    

008017d6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	83 ec 0c             	sub    $0xc,%esp
  8017dc:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017df:	8b 55 08             	mov    0x8(%ebp),%edx
  8017e2:	8b 52 0c             	mov    0xc(%edx),%edx
  8017e5:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017eb:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017f0:	50                   	push   %eax
  8017f1:	ff 75 0c             	pushl  0xc(%ebp)
  8017f4:	68 08 50 80 00       	push   $0x805008
  8017f9:	e8 28 f2 ff ff       	call   800a26 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8017fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801803:	b8 04 00 00 00       	mov    $0x4,%eax
  801808:	e8 d9 fe ff ff       	call   8016e6 <fsipc>

}
  80180d:	c9                   	leave  
  80180e:	c3                   	ret    

0080180f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80180f:	55                   	push   %ebp
  801810:	89 e5                	mov    %esp,%ebp
  801812:	56                   	push   %esi
  801813:	53                   	push   %ebx
  801814:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801817:	8b 45 08             	mov    0x8(%ebp),%eax
  80181a:	8b 40 0c             	mov    0xc(%eax),%eax
  80181d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801822:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801828:	ba 00 00 00 00       	mov    $0x0,%edx
  80182d:	b8 03 00 00 00       	mov    $0x3,%eax
  801832:	e8 af fe ff ff       	call   8016e6 <fsipc>
  801837:	89 c3                	mov    %eax,%ebx
  801839:	85 c0                	test   %eax,%eax
  80183b:	78 4b                	js     801888 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80183d:	39 c6                	cmp    %eax,%esi
  80183f:	73 16                	jae    801857 <devfile_read+0x48>
  801841:	68 38 2c 80 00       	push   $0x802c38
  801846:	68 3f 2c 80 00       	push   $0x802c3f
  80184b:	6a 7c                	push   $0x7c
  80184d:	68 54 2c 80 00       	push   $0x802c54
  801852:	e8 df e9 ff ff       	call   800236 <_panic>
	assert(r <= PGSIZE);
  801857:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80185c:	7e 16                	jle    801874 <devfile_read+0x65>
  80185e:	68 5f 2c 80 00       	push   $0x802c5f
  801863:	68 3f 2c 80 00       	push   $0x802c3f
  801868:	6a 7d                	push   $0x7d
  80186a:	68 54 2c 80 00       	push   $0x802c54
  80186f:	e8 c2 e9 ff ff       	call   800236 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801874:	83 ec 04             	sub    $0x4,%esp
  801877:	50                   	push   %eax
  801878:	68 00 50 80 00       	push   $0x805000
  80187d:	ff 75 0c             	pushl  0xc(%ebp)
  801880:	e8 a1 f1 ff ff       	call   800a26 <memmove>
	return r;
  801885:	83 c4 10             	add    $0x10,%esp
}
  801888:	89 d8                	mov    %ebx,%eax
  80188a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80188d:	5b                   	pop    %ebx
  80188e:	5e                   	pop    %esi
  80188f:	5d                   	pop    %ebp
  801890:	c3                   	ret    

00801891 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801891:	55                   	push   %ebp
  801892:	89 e5                	mov    %esp,%ebp
  801894:	53                   	push   %ebx
  801895:	83 ec 20             	sub    $0x20,%esp
  801898:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80189b:	53                   	push   %ebx
  80189c:	e8 ba ef ff ff       	call   80085b <strlen>
  8018a1:	83 c4 10             	add    $0x10,%esp
  8018a4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018a9:	7f 67                	jg     801912 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018ab:	83 ec 0c             	sub    $0xc,%esp
  8018ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b1:	50                   	push   %eax
  8018b2:	e8 a7 f8 ff ff       	call   80115e <fd_alloc>
  8018b7:	83 c4 10             	add    $0x10,%esp
		return r;
  8018ba:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018bc:	85 c0                	test   %eax,%eax
  8018be:	78 57                	js     801917 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018c0:	83 ec 08             	sub    $0x8,%esp
  8018c3:	53                   	push   %ebx
  8018c4:	68 00 50 80 00       	push   $0x805000
  8018c9:	e8 c6 ef ff ff       	call   800894 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8018de:	e8 03 fe ff ff       	call   8016e6 <fsipc>
  8018e3:	89 c3                	mov    %eax,%ebx
  8018e5:	83 c4 10             	add    $0x10,%esp
  8018e8:	85 c0                	test   %eax,%eax
  8018ea:	79 14                	jns    801900 <open+0x6f>
		fd_close(fd, 0);
  8018ec:	83 ec 08             	sub    $0x8,%esp
  8018ef:	6a 00                	push   $0x0
  8018f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f4:	e8 5d f9 ff ff       	call   801256 <fd_close>
		return r;
  8018f9:	83 c4 10             	add    $0x10,%esp
  8018fc:	89 da                	mov    %ebx,%edx
  8018fe:	eb 17                	jmp    801917 <open+0x86>
	}

	return fd2num(fd);
  801900:	83 ec 0c             	sub    $0xc,%esp
  801903:	ff 75 f4             	pushl  -0xc(%ebp)
  801906:	e8 2c f8 ff ff       	call   801137 <fd2num>
  80190b:	89 c2                	mov    %eax,%edx
  80190d:	83 c4 10             	add    $0x10,%esp
  801910:	eb 05                	jmp    801917 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801912:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801917:	89 d0                	mov    %edx,%eax
  801919:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80191c:	c9                   	leave  
  80191d:	c3                   	ret    

0080191e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801924:	ba 00 00 00 00       	mov    $0x0,%edx
  801929:	b8 08 00 00 00       	mov    $0x8,%eax
  80192e:	e8 b3 fd ff ff       	call   8016e6 <fsipc>
}
  801933:	c9                   	leave  
  801934:	c3                   	ret    

00801935 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801935:	55                   	push   %ebp
  801936:	89 e5                	mov    %esp,%ebp
  801938:	56                   	push   %esi
  801939:	53                   	push   %ebx
  80193a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80193d:	83 ec 0c             	sub    $0xc,%esp
  801940:	ff 75 08             	pushl  0x8(%ebp)
  801943:	e8 ff f7 ff ff       	call   801147 <fd2data>
  801948:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80194a:	83 c4 08             	add    $0x8,%esp
  80194d:	68 6b 2c 80 00       	push   $0x802c6b
  801952:	53                   	push   %ebx
  801953:	e8 3c ef ff ff       	call   800894 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801958:	8b 46 04             	mov    0x4(%esi),%eax
  80195b:	2b 06                	sub    (%esi),%eax
  80195d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801963:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80196a:	00 00 00 
	stat->st_dev = &devpipe;
  80196d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801974:	30 80 00 
	return 0;
}
  801977:	b8 00 00 00 00       	mov    $0x0,%eax
  80197c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80197f:	5b                   	pop    %ebx
  801980:	5e                   	pop    %esi
  801981:	5d                   	pop    %ebp
  801982:	c3                   	ret    

00801983 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801983:	55                   	push   %ebp
  801984:	89 e5                	mov    %esp,%ebp
  801986:	53                   	push   %ebx
  801987:	83 ec 0c             	sub    $0xc,%esp
  80198a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80198d:	53                   	push   %ebx
  80198e:	6a 00                	push   $0x0
  801990:	e8 87 f3 ff ff       	call   800d1c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801995:	89 1c 24             	mov    %ebx,(%esp)
  801998:	e8 aa f7 ff ff       	call   801147 <fd2data>
  80199d:	83 c4 08             	add    $0x8,%esp
  8019a0:	50                   	push   %eax
  8019a1:	6a 00                	push   $0x0
  8019a3:	e8 74 f3 ff ff       	call   800d1c <sys_page_unmap>
}
  8019a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ab:	c9                   	leave  
  8019ac:	c3                   	ret    

008019ad <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019ad:	55                   	push   %ebp
  8019ae:	89 e5                	mov    %esp,%ebp
  8019b0:	57                   	push   %edi
  8019b1:	56                   	push   %esi
  8019b2:	53                   	push   %ebx
  8019b3:	83 ec 1c             	sub    $0x1c,%esp
  8019b6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019b9:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019bb:	a1 08 40 80 00       	mov    0x804008,%eax
  8019c0:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019c3:	83 ec 0c             	sub    $0xc,%esp
  8019c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8019c9:	e8 0c 0a 00 00       	call   8023da <pageref>
  8019ce:	89 c3                	mov    %eax,%ebx
  8019d0:	89 3c 24             	mov    %edi,(%esp)
  8019d3:	e8 02 0a 00 00       	call   8023da <pageref>
  8019d8:	83 c4 10             	add    $0x10,%esp
  8019db:	39 c3                	cmp    %eax,%ebx
  8019dd:	0f 94 c1             	sete   %cl
  8019e0:	0f b6 c9             	movzbl %cl,%ecx
  8019e3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019e6:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8019ec:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019ef:	39 ce                	cmp    %ecx,%esi
  8019f1:	74 1b                	je     801a0e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8019f3:	39 c3                	cmp    %eax,%ebx
  8019f5:	75 c4                	jne    8019bb <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019f7:	8b 42 58             	mov    0x58(%edx),%eax
  8019fa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019fd:	50                   	push   %eax
  8019fe:	56                   	push   %esi
  8019ff:	68 72 2c 80 00       	push   $0x802c72
  801a04:	e8 06 e9 ff ff       	call   80030f <cprintf>
  801a09:	83 c4 10             	add    $0x10,%esp
  801a0c:	eb ad                	jmp    8019bb <_pipeisclosed+0xe>
	}
}
  801a0e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a14:	5b                   	pop    %ebx
  801a15:	5e                   	pop    %esi
  801a16:	5f                   	pop    %edi
  801a17:	5d                   	pop    %ebp
  801a18:	c3                   	ret    

00801a19 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a19:	55                   	push   %ebp
  801a1a:	89 e5                	mov    %esp,%ebp
  801a1c:	57                   	push   %edi
  801a1d:	56                   	push   %esi
  801a1e:	53                   	push   %ebx
  801a1f:	83 ec 28             	sub    $0x28,%esp
  801a22:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a25:	56                   	push   %esi
  801a26:	e8 1c f7 ff ff       	call   801147 <fd2data>
  801a2b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a2d:	83 c4 10             	add    $0x10,%esp
  801a30:	bf 00 00 00 00       	mov    $0x0,%edi
  801a35:	eb 4b                	jmp    801a82 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a37:	89 da                	mov    %ebx,%edx
  801a39:	89 f0                	mov    %esi,%eax
  801a3b:	e8 6d ff ff ff       	call   8019ad <_pipeisclosed>
  801a40:	85 c0                	test   %eax,%eax
  801a42:	75 48                	jne    801a8c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a44:	e8 2f f2 ff ff       	call   800c78 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a49:	8b 43 04             	mov    0x4(%ebx),%eax
  801a4c:	8b 0b                	mov    (%ebx),%ecx
  801a4e:	8d 51 20             	lea    0x20(%ecx),%edx
  801a51:	39 d0                	cmp    %edx,%eax
  801a53:	73 e2                	jae    801a37 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a58:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a5c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a5f:	89 c2                	mov    %eax,%edx
  801a61:	c1 fa 1f             	sar    $0x1f,%edx
  801a64:	89 d1                	mov    %edx,%ecx
  801a66:	c1 e9 1b             	shr    $0x1b,%ecx
  801a69:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a6c:	83 e2 1f             	and    $0x1f,%edx
  801a6f:	29 ca                	sub    %ecx,%edx
  801a71:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a75:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a79:	83 c0 01             	add    $0x1,%eax
  801a7c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a7f:	83 c7 01             	add    $0x1,%edi
  801a82:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a85:	75 c2                	jne    801a49 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a87:	8b 45 10             	mov    0x10(%ebp),%eax
  801a8a:	eb 05                	jmp    801a91 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a8c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a94:	5b                   	pop    %ebx
  801a95:	5e                   	pop    %esi
  801a96:	5f                   	pop    %edi
  801a97:	5d                   	pop    %ebp
  801a98:	c3                   	ret    

00801a99 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a99:	55                   	push   %ebp
  801a9a:	89 e5                	mov    %esp,%ebp
  801a9c:	57                   	push   %edi
  801a9d:	56                   	push   %esi
  801a9e:	53                   	push   %ebx
  801a9f:	83 ec 18             	sub    $0x18,%esp
  801aa2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801aa5:	57                   	push   %edi
  801aa6:	e8 9c f6 ff ff       	call   801147 <fd2data>
  801aab:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aad:	83 c4 10             	add    $0x10,%esp
  801ab0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ab5:	eb 3d                	jmp    801af4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ab7:	85 db                	test   %ebx,%ebx
  801ab9:	74 04                	je     801abf <devpipe_read+0x26>
				return i;
  801abb:	89 d8                	mov    %ebx,%eax
  801abd:	eb 44                	jmp    801b03 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801abf:	89 f2                	mov    %esi,%edx
  801ac1:	89 f8                	mov    %edi,%eax
  801ac3:	e8 e5 fe ff ff       	call   8019ad <_pipeisclosed>
  801ac8:	85 c0                	test   %eax,%eax
  801aca:	75 32                	jne    801afe <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801acc:	e8 a7 f1 ff ff       	call   800c78 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ad1:	8b 06                	mov    (%esi),%eax
  801ad3:	3b 46 04             	cmp    0x4(%esi),%eax
  801ad6:	74 df                	je     801ab7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ad8:	99                   	cltd   
  801ad9:	c1 ea 1b             	shr    $0x1b,%edx
  801adc:	01 d0                	add    %edx,%eax
  801ade:	83 e0 1f             	and    $0x1f,%eax
  801ae1:	29 d0                	sub    %edx,%eax
  801ae3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ae8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aeb:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801aee:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801af1:	83 c3 01             	add    $0x1,%ebx
  801af4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801af7:	75 d8                	jne    801ad1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801af9:	8b 45 10             	mov    0x10(%ebp),%eax
  801afc:	eb 05                	jmp    801b03 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801afe:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b06:	5b                   	pop    %ebx
  801b07:	5e                   	pop    %esi
  801b08:	5f                   	pop    %edi
  801b09:	5d                   	pop    %ebp
  801b0a:	c3                   	ret    

00801b0b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	56                   	push   %esi
  801b0f:	53                   	push   %ebx
  801b10:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b16:	50                   	push   %eax
  801b17:	e8 42 f6 ff ff       	call   80115e <fd_alloc>
  801b1c:	83 c4 10             	add    $0x10,%esp
  801b1f:	89 c2                	mov    %eax,%edx
  801b21:	85 c0                	test   %eax,%eax
  801b23:	0f 88 2c 01 00 00    	js     801c55 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b29:	83 ec 04             	sub    $0x4,%esp
  801b2c:	68 07 04 00 00       	push   $0x407
  801b31:	ff 75 f4             	pushl  -0xc(%ebp)
  801b34:	6a 00                	push   $0x0
  801b36:	e8 5c f1 ff ff       	call   800c97 <sys_page_alloc>
  801b3b:	83 c4 10             	add    $0x10,%esp
  801b3e:	89 c2                	mov    %eax,%edx
  801b40:	85 c0                	test   %eax,%eax
  801b42:	0f 88 0d 01 00 00    	js     801c55 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b48:	83 ec 0c             	sub    $0xc,%esp
  801b4b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b4e:	50                   	push   %eax
  801b4f:	e8 0a f6 ff ff       	call   80115e <fd_alloc>
  801b54:	89 c3                	mov    %eax,%ebx
  801b56:	83 c4 10             	add    $0x10,%esp
  801b59:	85 c0                	test   %eax,%eax
  801b5b:	0f 88 e2 00 00 00    	js     801c43 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b61:	83 ec 04             	sub    $0x4,%esp
  801b64:	68 07 04 00 00       	push   $0x407
  801b69:	ff 75 f0             	pushl  -0x10(%ebp)
  801b6c:	6a 00                	push   $0x0
  801b6e:	e8 24 f1 ff ff       	call   800c97 <sys_page_alloc>
  801b73:	89 c3                	mov    %eax,%ebx
  801b75:	83 c4 10             	add    $0x10,%esp
  801b78:	85 c0                	test   %eax,%eax
  801b7a:	0f 88 c3 00 00 00    	js     801c43 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b80:	83 ec 0c             	sub    $0xc,%esp
  801b83:	ff 75 f4             	pushl  -0xc(%ebp)
  801b86:	e8 bc f5 ff ff       	call   801147 <fd2data>
  801b8b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b8d:	83 c4 0c             	add    $0xc,%esp
  801b90:	68 07 04 00 00       	push   $0x407
  801b95:	50                   	push   %eax
  801b96:	6a 00                	push   $0x0
  801b98:	e8 fa f0 ff ff       	call   800c97 <sys_page_alloc>
  801b9d:	89 c3                	mov    %eax,%ebx
  801b9f:	83 c4 10             	add    $0x10,%esp
  801ba2:	85 c0                	test   %eax,%eax
  801ba4:	0f 88 89 00 00 00    	js     801c33 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801baa:	83 ec 0c             	sub    $0xc,%esp
  801bad:	ff 75 f0             	pushl  -0x10(%ebp)
  801bb0:	e8 92 f5 ff ff       	call   801147 <fd2data>
  801bb5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bbc:	50                   	push   %eax
  801bbd:	6a 00                	push   $0x0
  801bbf:	56                   	push   %esi
  801bc0:	6a 00                	push   $0x0
  801bc2:	e8 13 f1 ff ff       	call   800cda <sys_page_map>
  801bc7:	89 c3                	mov    %eax,%ebx
  801bc9:	83 c4 20             	add    $0x20,%esp
  801bcc:	85 c0                	test   %eax,%eax
  801bce:	78 55                	js     801c25 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bd0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bde:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801be5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801beb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bee:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bf0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bf3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bfa:	83 ec 0c             	sub    $0xc,%esp
  801bfd:	ff 75 f4             	pushl  -0xc(%ebp)
  801c00:	e8 32 f5 ff ff       	call   801137 <fd2num>
  801c05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c08:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c0a:	83 c4 04             	add    $0x4,%esp
  801c0d:	ff 75 f0             	pushl  -0x10(%ebp)
  801c10:	e8 22 f5 ff ff       	call   801137 <fd2num>
  801c15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c18:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c1b:	83 c4 10             	add    $0x10,%esp
  801c1e:	ba 00 00 00 00       	mov    $0x0,%edx
  801c23:	eb 30                	jmp    801c55 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c25:	83 ec 08             	sub    $0x8,%esp
  801c28:	56                   	push   %esi
  801c29:	6a 00                	push   $0x0
  801c2b:	e8 ec f0 ff ff       	call   800d1c <sys_page_unmap>
  801c30:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c33:	83 ec 08             	sub    $0x8,%esp
  801c36:	ff 75 f0             	pushl  -0x10(%ebp)
  801c39:	6a 00                	push   $0x0
  801c3b:	e8 dc f0 ff ff       	call   800d1c <sys_page_unmap>
  801c40:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c43:	83 ec 08             	sub    $0x8,%esp
  801c46:	ff 75 f4             	pushl  -0xc(%ebp)
  801c49:	6a 00                	push   $0x0
  801c4b:	e8 cc f0 ff ff       	call   800d1c <sys_page_unmap>
  801c50:	83 c4 10             	add    $0x10,%esp
  801c53:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c55:	89 d0                	mov    %edx,%eax
  801c57:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c5a:	5b                   	pop    %ebx
  801c5b:	5e                   	pop    %esi
  801c5c:	5d                   	pop    %ebp
  801c5d:	c3                   	ret    

00801c5e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c5e:	55                   	push   %ebp
  801c5f:	89 e5                	mov    %esp,%ebp
  801c61:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c67:	50                   	push   %eax
  801c68:	ff 75 08             	pushl  0x8(%ebp)
  801c6b:	e8 3d f5 ff ff       	call   8011ad <fd_lookup>
  801c70:	83 c4 10             	add    $0x10,%esp
  801c73:	85 c0                	test   %eax,%eax
  801c75:	78 18                	js     801c8f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c77:	83 ec 0c             	sub    $0xc,%esp
  801c7a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c7d:	e8 c5 f4 ff ff       	call   801147 <fd2data>
	return _pipeisclosed(fd, p);
  801c82:	89 c2                	mov    %eax,%edx
  801c84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c87:	e8 21 fd ff ff       	call   8019ad <_pipeisclosed>
  801c8c:	83 c4 10             	add    $0x10,%esp
}
  801c8f:	c9                   	leave  
  801c90:	c3                   	ret    

00801c91 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c91:	55                   	push   %ebp
  801c92:	89 e5                	mov    %esp,%ebp
  801c94:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801c97:	68 8a 2c 80 00       	push   $0x802c8a
  801c9c:	ff 75 0c             	pushl  0xc(%ebp)
  801c9f:	e8 f0 eb ff ff       	call   800894 <strcpy>
	return 0;
}
  801ca4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca9:	c9                   	leave  
  801caa:	c3                   	ret    

00801cab <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801cab:	55                   	push   %ebp
  801cac:	89 e5                	mov    %esp,%ebp
  801cae:	53                   	push   %ebx
  801caf:	83 ec 10             	sub    $0x10,%esp
  801cb2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801cb5:	53                   	push   %ebx
  801cb6:	e8 1f 07 00 00       	call   8023da <pageref>
  801cbb:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801cbe:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801cc3:	83 f8 01             	cmp    $0x1,%eax
  801cc6:	75 10                	jne    801cd8 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801cc8:	83 ec 0c             	sub    $0xc,%esp
  801ccb:	ff 73 0c             	pushl  0xc(%ebx)
  801cce:	e8 c0 02 00 00       	call   801f93 <nsipc_close>
  801cd3:	89 c2                	mov    %eax,%edx
  801cd5:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801cd8:	89 d0                	mov    %edx,%eax
  801cda:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cdd:	c9                   	leave  
  801cde:	c3                   	ret    

00801cdf <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801cdf:	55                   	push   %ebp
  801ce0:	89 e5                	mov    %esp,%ebp
  801ce2:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801ce5:	6a 00                	push   $0x0
  801ce7:	ff 75 10             	pushl  0x10(%ebp)
  801cea:	ff 75 0c             	pushl  0xc(%ebp)
  801ced:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf0:	ff 70 0c             	pushl  0xc(%eax)
  801cf3:	e8 78 03 00 00       	call   802070 <nsipc_send>
}
  801cf8:	c9                   	leave  
  801cf9:	c3                   	ret    

00801cfa <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801cfa:	55                   	push   %ebp
  801cfb:	89 e5                	mov    %esp,%ebp
  801cfd:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d00:	6a 00                	push   $0x0
  801d02:	ff 75 10             	pushl  0x10(%ebp)
  801d05:	ff 75 0c             	pushl  0xc(%ebp)
  801d08:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0b:	ff 70 0c             	pushl  0xc(%eax)
  801d0e:	e8 f1 02 00 00       	call   802004 <nsipc_recv>
}
  801d13:	c9                   	leave  
  801d14:	c3                   	ret    

00801d15 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801d15:	55                   	push   %ebp
  801d16:	89 e5                	mov    %esp,%ebp
  801d18:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d1b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d1e:	52                   	push   %edx
  801d1f:	50                   	push   %eax
  801d20:	e8 88 f4 ff ff       	call   8011ad <fd_lookup>
  801d25:	83 c4 10             	add    $0x10,%esp
  801d28:	85 c0                	test   %eax,%eax
  801d2a:	78 17                	js     801d43 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2f:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801d35:	39 08                	cmp    %ecx,(%eax)
  801d37:	75 05                	jne    801d3e <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d39:	8b 40 0c             	mov    0xc(%eax),%eax
  801d3c:	eb 05                	jmp    801d43 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801d3e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801d43:	c9                   	leave  
  801d44:	c3                   	ret    

00801d45 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801d45:	55                   	push   %ebp
  801d46:	89 e5                	mov    %esp,%ebp
  801d48:	56                   	push   %esi
  801d49:	53                   	push   %ebx
  801d4a:	83 ec 1c             	sub    $0x1c,%esp
  801d4d:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801d4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d52:	50                   	push   %eax
  801d53:	e8 06 f4 ff ff       	call   80115e <fd_alloc>
  801d58:	89 c3                	mov    %eax,%ebx
  801d5a:	83 c4 10             	add    $0x10,%esp
  801d5d:	85 c0                	test   %eax,%eax
  801d5f:	78 1b                	js     801d7c <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d61:	83 ec 04             	sub    $0x4,%esp
  801d64:	68 07 04 00 00       	push   $0x407
  801d69:	ff 75 f4             	pushl  -0xc(%ebp)
  801d6c:	6a 00                	push   $0x0
  801d6e:	e8 24 ef ff ff       	call   800c97 <sys_page_alloc>
  801d73:	89 c3                	mov    %eax,%ebx
  801d75:	83 c4 10             	add    $0x10,%esp
  801d78:	85 c0                	test   %eax,%eax
  801d7a:	79 10                	jns    801d8c <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801d7c:	83 ec 0c             	sub    $0xc,%esp
  801d7f:	56                   	push   %esi
  801d80:	e8 0e 02 00 00       	call   801f93 <nsipc_close>
		return r;
  801d85:	83 c4 10             	add    $0x10,%esp
  801d88:	89 d8                	mov    %ebx,%eax
  801d8a:	eb 24                	jmp    801db0 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801d8c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d95:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801da1:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801da4:	83 ec 0c             	sub    $0xc,%esp
  801da7:	50                   	push   %eax
  801da8:	e8 8a f3 ff ff       	call   801137 <fd2num>
  801dad:	83 c4 10             	add    $0x10,%esp
}
  801db0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801db3:	5b                   	pop    %ebx
  801db4:	5e                   	pop    %esi
  801db5:	5d                   	pop    %ebp
  801db6:	c3                   	ret    

00801db7 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801db7:	55                   	push   %ebp
  801db8:	89 e5                	mov    %esp,%ebp
  801dba:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dbd:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc0:	e8 50 ff ff ff       	call   801d15 <fd2sockid>
		return r;
  801dc5:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dc7:	85 c0                	test   %eax,%eax
  801dc9:	78 1f                	js     801dea <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801dcb:	83 ec 04             	sub    $0x4,%esp
  801dce:	ff 75 10             	pushl  0x10(%ebp)
  801dd1:	ff 75 0c             	pushl  0xc(%ebp)
  801dd4:	50                   	push   %eax
  801dd5:	e8 12 01 00 00       	call   801eec <nsipc_accept>
  801dda:	83 c4 10             	add    $0x10,%esp
		return r;
  801ddd:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ddf:	85 c0                	test   %eax,%eax
  801de1:	78 07                	js     801dea <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801de3:	e8 5d ff ff ff       	call   801d45 <alloc_sockfd>
  801de8:	89 c1                	mov    %eax,%ecx
}
  801dea:	89 c8                	mov    %ecx,%eax
  801dec:	c9                   	leave  
  801ded:	c3                   	ret    

00801dee <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801dee:	55                   	push   %ebp
  801def:	89 e5                	mov    %esp,%ebp
  801df1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801df4:	8b 45 08             	mov    0x8(%ebp),%eax
  801df7:	e8 19 ff ff ff       	call   801d15 <fd2sockid>
  801dfc:	85 c0                	test   %eax,%eax
  801dfe:	78 12                	js     801e12 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801e00:	83 ec 04             	sub    $0x4,%esp
  801e03:	ff 75 10             	pushl  0x10(%ebp)
  801e06:	ff 75 0c             	pushl  0xc(%ebp)
  801e09:	50                   	push   %eax
  801e0a:	e8 2d 01 00 00       	call   801f3c <nsipc_bind>
  801e0f:	83 c4 10             	add    $0x10,%esp
}
  801e12:	c9                   	leave  
  801e13:	c3                   	ret    

00801e14 <shutdown>:

int
shutdown(int s, int how)
{
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
  801e17:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1d:	e8 f3 fe ff ff       	call   801d15 <fd2sockid>
  801e22:	85 c0                	test   %eax,%eax
  801e24:	78 0f                	js     801e35 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801e26:	83 ec 08             	sub    $0x8,%esp
  801e29:	ff 75 0c             	pushl  0xc(%ebp)
  801e2c:	50                   	push   %eax
  801e2d:	e8 3f 01 00 00       	call   801f71 <nsipc_shutdown>
  801e32:	83 c4 10             	add    $0x10,%esp
}
  801e35:	c9                   	leave  
  801e36:	c3                   	ret    

00801e37 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e37:	55                   	push   %ebp
  801e38:	89 e5                	mov    %esp,%ebp
  801e3a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e40:	e8 d0 fe ff ff       	call   801d15 <fd2sockid>
  801e45:	85 c0                	test   %eax,%eax
  801e47:	78 12                	js     801e5b <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801e49:	83 ec 04             	sub    $0x4,%esp
  801e4c:	ff 75 10             	pushl  0x10(%ebp)
  801e4f:	ff 75 0c             	pushl  0xc(%ebp)
  801e52:	50                   	push   %eax
  801e53:	e8 55 01 00 00       	call   801fad <nsipc_connect>
  801e58:	83 c4 10             	add    $0x10,%esp
}
  801e5b:	c9                   	leave  
  801e5c:	c3                   	ret    

00801e5d <listen>:

int
listen(int s, int backlog)
{
  801e5d:	55                   	push   %ebp
  801e5e:	89 e5                	mov    %esp,%ebp
  801e60:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e63:	8b 45 08             	mov    0x8(%ebp),%eax
  801e66:	e8 aa fe ff ff       	call   801d15 <fd2sockid>
  801e6b:	85 c0                	test   %eax,%eax
  801e6d:	78 0f                	js     801e7e <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801e6f:	83 ec 08             	sub    $0x8,%esp
  801e72:	ff 75 0c             	pushl  0xc(%ebp)
  801e75:	50                   	push   %eax
  801e76:	e8 67 01 00 00       	call   801fe2 <nsipc_listen>
  801e7b:	83 c4 10             	add    $0x10,%esp
}
  801e7e:	c9                   	leave  
  801e7f:	c3                   	ret    

00801e80 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e86:	ff 75 10             	pushl  0x10(%ebp)
  801e89:	ff 75 0c             	pushl  0xc(%ebp)
  801e8c:	ff 75 08             	pushl  0x8(%ebp)
  801e8f:	e8 3a 02 00 00       	call   8020ce <nsipc_socket>
  801e94:	83 c4 10             	add    $0x10,%esp
  801e97:	85 c0                	test   %eax,%eax
  801e99:	78 05                	js     801ea0 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801e9b:	e8 a5 fe ff ff       	call   801d45 <alloc_sockfd>
}
  801ea0:	c9                   	leave  
  801ea1:	c3                   	ret    

00801ea2 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ea2:	55                   	push   %ebp
  801ea3:	89 e5                	mov    %esp,%ebp
  801ea5:	53                   	push   %ebx
  801ea6:	83 ec 04             	sub    $0x4,%esp
  801ea9:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801eab:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801eb2:	75 12                	jne    801ec6 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801eb4:	83 ec 0c             	sub    $0xc,%esp
  801eb7:	6a 02                	push   $0x2
  801eb9:	e8 e3 04 00 00       	call   8023a1 <ipc_find_env>
  801ebe:	a3 04 40 80 00       	mov    %eax,0x804004
  801ec3:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ec6:	6a 07                	push   $0x7
  801ec8:	68 00 60 80 00       	push   $0x806000
  801ecd:	53                   	push   %ebx
  801ece:	ff 35 04 40 80 00    	pushl  0x804004
  801ed4:	e8 74 04 00 00       	call   80234d <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ed9:	83 c4 0c             	add    $0xc,%esp
  801edc:	6a 00                	push   $0x0
  801ede:	6a 00                	push   $0x0
  801ee0:	6a 00                	push   $0x0
  801ee2:	e8 ff 03 00 00       	call   8022e6 <ipc_recv>
}
  801ee7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eea:	c9                   	leave  
  801eeb:	c3                   	ret    

00801eec <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801eec:	55                   	push   %ebp
  801eed:	89 e5                	mov    %esp,%ebp
  801eef:	56                   	push   %esi
  801ef0:	53                   	push   %ebx
  801ef1:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801ef4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801efc:	8b 06                	mov    (%esi),%eax
  801efe:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f03:	b8 01 00 00 00       	mov    $0x1,%eax
  801f08:	e8 95 ff ff ff       	call   801ea2 <nsipc>
  801f0d:	89 c3                	mov    %eax,%ebx
  801f0f:	85 c0                	test   %eax,%eax
  801f11:	78 20                	js     801f33 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f13:	83 ec 04             	sub    $0x4,%esp
  801f16:	ff 35 10 60 80 00    	pushl  0x806010
  801f1c:	68 00 60 80 00       	push   $0x806000
  801f21:	ff 75 0c             	pushl  0xc(%ebp)
  801f24:	e8 fd ea ff ff       	call   800a26 <memmove>
		*addrlen = ret->ret_addrlen;
  801f29:	a1 10 60 80 00       	mov    0x806010,%eax
  801f2e:	89 06                	mov    %eax,(%esi)
  801f30:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801f33:	89 d8                	mov    %ebx,%eax
  801f35:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f38:	5b                   	pop    %ebx
  801f39:	5e                   	pop    %esi
  801f3a:	5d                   	pop    %ebp
  801f3b:	c3                   	ret    

00801f3c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f3c:	55                   	push   %ebp
  801f3d:	89 e5                	mov    %esp,%ebp
  801f3f:	53                   	push   %ebx
  801f40:	83 ec 08             	sub    $0x8,%esp
  801f43:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f46:	8b 45 08             	mov    0x8(%ebp),%eax
  801f49:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f4e:	53                   	push   %ebx
  801f4f:	ff 75 0c             	pushl  0xc(%ebp)
  801f52:	68 04 60 80 00       	push   $0x806004
  801f57:	e8 ca ea ff ff       	call   800a26 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f5c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801f62:	b8 02 00 00 00       	mov    $0x2,%eax
  801f67:	e8 36 ff ff ff       	call   801ea2 <nsipc>
}
  801f6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f6f:	c9                   	leave  
  801f70:	c3                   	ret    

00801f71 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f71:	55                   	push   %ebp
  801f72:	89 e5                	mov    %esp,%ebp
  801f74:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f77:	8b 45 08             	mov    0x8(%ebp),%eax
  801f7a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801f7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f82:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801f87:	b8 03 00 00 00       	mov    $0x3,%eax
  801f8c:	e8 11 ff ff ff       	call   801ea2 <nsipc>
}
  801f91:	c9                   	leave  
  801f92:	c3                   	ret    

00801f93 <nsipc_close>:

int
nsipc_close(int s)
{
  801f93:	55                   	push   %ebp
  801f94:	89 e5                	mov    %esp,%ebp
  801f96:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801f99:	8b 45 08             	mov    0x8(%ebp),%eax
  801f9c:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801fa1:	b8 04 00 00 00       	mov    $0x4,%eax
  801fa6:	e8 f7 fe ff ff       	call   801ea2 <nsipc>
}
  801fab:	c9                   	leave  
  801fac:	c3                   	ret    

00801fad <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801fad:	55                   	push   %ebp
  801fae:	89 e5                	mov    %esp,%ebp
  801fb0:	53                   	push   %ebx
  801fb1:	83 ec 08             	sub    $0x8,%esp
  801fb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801fb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801fba:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801fbf:	53                   	push   %ebx
  801fc0:	ff 75 0c             	pushl  0xc(%ebp)
  801fc3:	68 04 60 80 00       	push   $0x806004
  801fc8:	e8 59 ea ff ff       	call   800a26 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801fcd:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801fd3:	b8 05 00 00 00       	mov    $0x5,%eax
  801fd8:	e8 c5 fe ff ff       	call   801ea2 <nsipc>
}
  801fdd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fe0:	c9                   	leave  
  801fe1:	c3                   	ret    

00801fe2 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801fe2:	55                   	push   %ebp
  801fe3:	89 e5                	mov    %esp,%ebp
  801fe5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801fe8:	8b 45 08             	mov    0x8(%ebp),%eax
  801feb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801ff0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff3:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801ff8:	b8 06 00 00 00       	mov    $0x6,%eax
  801ffd:	e8 a0 fe ff ff       	call   801ea2 <nsipc>
}
  802002:	c9                   	leave  
  802003:	c3                   	ret    

00802004 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802004:	55                   	push   %ebp
  802005:	89 e5                	mov    %esp,%ebp
  802007:	56                   	push   %esi
  802008:	53                   	push   %ebx
  802009:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80200c:	8b 45 08             	mov    0x8(%ebp),%eax
  80200f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  802014:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80201a:	8b 45 14             	mov    0x14(%ebp),%eax
  80201d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802022:	b8 07 00 00 00       	mov    $0x7,%eax
  802027:	e8 76 fe ff ff       	call   801ea2 <nsipc>
  80202c:	89 c3                	mov    %eax,%ebx
  80202e:	85 c0                	test   %eax,%eax
  802030:	78 35                	js     802067 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802032:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802037:	7f 04                	jg     80203d <nsipc_recv+0x39>
  802039:	39 c6                	cmp    %eax,%esi
  80203b:	7d 16                	jge    802053 <nsipc_recv+0x4f>
  80203d:	68 96 2c 80 00       	push   $0x802c96
  802042:	68 3f 2c 80 00       	push   $0x802c3f
  802047:	6a 62                	push   $0x62
  802049:	68 ab 2c 80 00       	push   $0x802cab
  80204e:	e8 e3 e1 ff ff       	call   800236 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802053:	83 ec 04             	sub    $0x4,%esp
  802056:	50                   	push   %eax
  802057:	68 00 60 80 00       	push   $0x806000
  80205c:	ff 75 0c             	pushl  0xc(%ebp)
  80205f:	e8 c2 e9 ff ff       	call   800a26 <memmove>
  802064:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802067:	89 d8                	mov    %ebx,%eax
  802069:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80206c:	5b                   	pop    %ebx
  80206d:	5e                   	pop    %esi
  80206e:	5d                   	pop    %ebp
  80206f:	c3                   	ret    

00802070 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
  802073:	53                   	push   %ebx
  802074:	83 ec 04             	sub    $0x4,%esp
  802077:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80207a:	8b 45 08             	mov    0x8(%ebp),%eax
  80207d:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  802082:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802088:	7e 16                	jle    8020a0 <nsipc_send+0x30>
  80208a:	68 b7 2c 80 00       	push   $0x802cb7
  80208f:	68 3f 2c 80 00       	push   $0x802c3f
  802094:	6a 6d                	push   $0x6d
  802096:	68 ab 2c 80 00       	push   $0x802cab
  80209b:	e8 96 e1 ff ff       	call   800236 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8020a0:	83 ec 04             	sub    $0x4,%esp
  8020a3:	53                   	push   %ebx
  8020a4:	ff 75 0c             	pushl  0xc(%ebp)
  8020a7:	68 0c 60 80 00       	push   $0x80600c
  8020ac:	e8 75 e9 ff ff       	call   800a26 <memmove>
	nsipcbuf.send.req_size = size;
  8020b1:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8020b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8020ba:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8020bf:	b8 08 00 00 00       	mov    $0x8,%eax
  8020c4:	e8 d9 fd ff ff       	call   801ea2 <nsipc>
}
  8020c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020cc:	c9                   	leave  
  8020cd:	c3                   	ret    

008020ce <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8020ce:	55                   	push   %ebp
  8020cf:	89 e5                	mov    %esp,%ebp
  8020d1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8020d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8020dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020df:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8020e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8020e7:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8020ec:	b8 09 00 00 00       	mov    $0x9,%eax
  8020f1:	e8 ac fd ff ff       	call   801ea2 <nsipc>
}
  8020f6:	c9                   	leave  
  8020f7:	c3                   	ret    

008020f8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020f8:	55                   	push   %ebp
  8020f9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8020fb:	b8 00 00 00 00       	mov    $0x0,%eax
  802100:	5d                   	pop    %ebp
  802101:	c3                   	ret    

00802102 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802102:	55                   	push   %ebp
  802103:	89 e5                	mov    %esp,%ebp
  802105:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802108:	68 c3 2c 80 00       	push   $0x802cc3
  80210d:	ff 75 0c             	pushl  0xc(%ebp)
  802110:	e8 7f e7 ff ff       	call   800894 <strcpy>
	return 0;
}
  802115:	b8 00 00 00 00       	mov    $0x0,%eax
  80211a:	c9                   	leave  
  80211b:	c3                   	ret    

0080211c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80211c:	55                   	push   %ebp
  80211d:	89 e5                	mov    %esp,%ebp
  80211f:	57                   	push   %edi
  802120:	56                   	push   %esi
  802121:	53                   	push   %ebx
  802122:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802128:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80212d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802133:	eb 2d                	jmp    802162 <devcons_write+0x46>
		m = n - tot;
  802135:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802138:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80213a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80213d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802142:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802145:	83 ec 04             	sub    $0x4,%esp
  802148:	53                   	push   %ebx
  802149:	03 45 0c             	add    0xc(%ebp),%eax
  80214c:	50                   	push   %eax
  80214d:	57                   	push   %edi
  80214e:	e8 d3 e8 ff ff       	call   800a26 <memmove>
		sys_cputs(buf, m);
  802153:	83 c4 08             	add    $0x8,%esp
  802156:	53                   	push   %ebx
  802157:	57                   	push   %edi
  802158:	e8 7e ea ff ff       	call   800bdb <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80215d:	01 de                	add    %ebx,%esi
  80215f:	83 c4 10             	add    $0x10,%esp
  802162:	89 f0                	mov    %esi,%eax
  802164:	3b 75 10             	cmp    0x10(%ebp),%esi
  802167:	72 cc                	jb     802135 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802169:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80216c:	5b                   	pop    %ebx
  80216d:	5e                   	pop    %esi
  80216e:	5f                   	pop    %edi
  80216f:	5d                   	pop    %ebp
  802170:	c3                   	ret    

00802171 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802171:	55                   	push   %ebp
  802172:	89 e5                	mov    %esp,%ebp
  802174:	83 ec 08             	sub    $0x8,%esp
  802177:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80217c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802180:	74 2a                	je     8021ac <devcons_read+0x3b>
  802182:	eb 05                	jmp    802189 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802184:	e8 ef ea ff ff       	call   800c78 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802189:	e8 6b ea ff ff       	call   800bf9 <sys_cgetc>
  80218e:	85 c0                	test   %eax,%eax
  802190:	74 f2                	je     802184 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802192:	85 c0                	test   %eax,%eax
  802194:	78 16                	js     8021ac <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802196:	83 f8 04             	cmp    $0x4,%eax
  802199:	74 0c                	je     8021a7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80219b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80219e:	88 02                	mov    %al,(%edx)
	return 1;
  8021a0:	b8 01 00 00 00       	mov    $0x1,%eax
  8021a5:	eb 05                	jmp    8021ac <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021a7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021ac:	c9                   	leave  
  8021ad:	c3                   	ret    

008021ae <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8021ae:	55                   	push   %ebp
  8021af:	89 e5                	mov    %esp,%ebp
  8021b1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8021b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8021ba:	6a 01                	push   $0x1
  8021bc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021bf:	50                   	push   %eax
  8021c0:	e8 16 ea ff ff       	call   800bdb <sys_cputs>
}
  8021c5:	83 c4 10             	add    $0x10,%esp
  8021c8:	c9                   	leave  
  8021c9:	c3                   	ret    

008021ca <getchar>:

int
getchar(void)
{
  8021ca:	55                   	push   %ebp
  8021cb:	89 e5                	mov    %esp,%ebp
  8021cd:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8021d0:	6a 01                	push   $0x1
  8021d2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021d5:	50                   	push   %eax
  8021d6:	6a 00                	push   $0x0
  8021d8:	e8 36 f2 ff ff       	call   801413 <read>
	if (r < 0)
  8021dd:	83 c4 10             	add    $0x10,%esp
  8021e0:	85 c0                	test   %eax,%eax
  8021e2:	78 0f                	js     8021f3 <getchar+0x29>
		return r;
	if (r < 1)
  8021e4:	85 c0                	test   %eax,%eax
  8021e6:	7e 06                	jle    8021ee <getchar+0x24>
		return -E_EOF;
	return c;
  8021e8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8021ec:	eb 05                	jmp    8021f3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8021ee:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8021f3:	c9                   	leave  
  8021f4:	c3                   	ret    

008021f5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8021f5:	55                   	push   %ebp
  8021f6:	89 e5                	mov    %esp,%ebp
  8021f8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021fe:	50                   	push   %eax
  8021ff:	ff 75 08             	pushl  0x8(%ebp)
  802202:	e8 a6 ef ff ff       	call   8011ad <fd_lookup>
  802207:	83 c4 10             	add    $0x10,%esp
  80220a:	85 c0                	test   %eax,%eax
  80220c:	78 11                	js     80221f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80220e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802211:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802217:	39 10                	cmp    %edx,(%eax)
  802219:	0f 94 c0             	sete   %al
  80221c:	0f b6 c0             	movzbl %al,%eax
}
  80221f:	c9                   	leave  
  802220:	c3                   	ret    

00802221 <opencons>:

int
opencons(void)
{
  802221:	55                   	push   %ebp
  802222:	89 e5                	mov    %esp,%ebp
  802224:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802227:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80222a:	50                   	push   %eax
  80222b:	e8 2e ef ff ff       	call   80115e <fd_alloc>
  802230:	83 c4 10             	add    $0x10,%esp
		return r;
  802233:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802235:	85 c0                	test   %eax,%eax
  802237:	78 3e                	js     802277 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802239:	83 ec 04             	sub    $0x4,%esp
  80223c:	68 07 04 00 00       	push   $0x407
  802241:	ff 75 f4             	pushl  -0xc(%ebp)
  802244:	6a 00                	push   $0x0
  802246:	e8 4c ea ff ff       	call   800c97 <sys_page_alloc>
  80224b:	83 c4 10             	add    $0x10,%esp
		return r;
  80224e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802250:	85 c0                	test   %eax,%eax
  802252:	78 23                	js     802277 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802254:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80225a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80225d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80225f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802262:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802269:	83 ec 0c             	sub    $0xc,%esp
  80226c:	50                   	push   %eax
  80226d:	e8 c5 ee ff ff       	call   801137 <fd2num>
  802272:	89 c2                	mov    %eax,%edx
  802274:	83 c4 10             	add    $0x10,%esp
}
  802277:	89 d0                	mov    %edx,%eax
  802279:	c9                   	leave  
  80227a:	c3                   	ret    

0080227b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80227b:	55                   	push   %ebp
  80227c:	89 e5                	mov    %esp,%ebp
  80227e:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802281:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802288:	75 2e                	jne    8022b8 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  80228a:	e8 ca e9 ff ff       	call   800c59 <sys_getenvid>
  80228f:	83 ec 04             	sub    $0x4,%esp
  802292:	68 07 0e 00 00       	push   $0xe07
  802297:	68 00 f0 bf ee       	push   $0xeebff000
  80229c:	50                   	push   %eax
  80229d:	e8 f5 e9 ff ff       	call   800c97 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8022a2:	e8 b2 e9 ff ff       	call   800c59 <sys_getenvid>
  8022a7:	83 c4 08             	add    $0x8,%esp
  8022aa:	68 c2 22 80 00       	push   $0x8022c2
  8022af:	50                   	push   %eax
  8022b0:	e8 2d eb ff ff       	call   800de2 <sys_env_set_pgfault_upcall>
  8022b5:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8022b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022bb:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8022c0:	c9                   	leave  
  8022c1:	c3                   	ret    

008022c2 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8022c2:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8022c3:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8022c8:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8022ca:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  8022cd:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  8022d1:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  8022d5:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  8022d8:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  8022db:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  8022dc:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  8022df:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  8022e0:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  8022e1:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  8022e5:	c3                   	ret    

008022e6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022e6:	55                   	push   %ebp
  8022e7:	89 e5                	mov    %esp,%ebp
  8022e9:	56                   	push   %esi
  8022ea:	53                   	push   %ebx
  8022eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8022ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8022f4:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8022f6:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8022fb:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8022fe:	83 ec 0c             	sub    $0xc,%esp
  802301:	50                   	push   %eax
  802302:	e8 40 eb ff ff       	call   800e47 <sys_ipc_recv>

	if (from_env_store != NULL)
  802307:	83 c4 10             	add    $0x10,%esp
  80230a:	85 f6                	test   %esi,%esi
  80230c:	74 14                	je     802322 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  80230e:	ba 00 00 00 00       	mov    $0x0,%edx
  802313:	85 c0                	test   %eax,%eax
  802315:	78 09                	js     802320 <ipc_recv+0x3a>
  802317:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80231d:	8b 52 74             	mov    0x74(%edx),%edx
  802320:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802322:	85 db                	test   %ebx,%ebx
  802324:	74 14                	je     80233a <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802326:	ba 00 00 00 00       	mov    $0x0,%edx
  80232b:	85 c0                	test   %eax,%eax
  80232d:	78 09                	js     802338 <ipc_recv+0x52>
  80232f:	8b 15 08 40 80 00    	mov    0x804008,%edx
  802335:	8b 52 78             	mov    0x78(%edx),%edx
  802338:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80233a:	85 c0                	test   %eax,%eax
  80233c:	78 08                	js     802346 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  80233e:	a1 08 40 80 00       	mov    0x804008,%eax
  802343:	8b 40 70             	mov    0x70(%eax),%eax
}
  802346:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802349:	5b                   	pop    %ebx
  80234a:	5e                   	pop    %esi
  80234b:	5d                   	pop    %ebp
  80234c:	c3                   	ret    

0080234d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80234d:	55                   	push   %ebp
  80234e:	89 e5                	mov    %esp,%ebp
  802350:	57                   	push   %edi
  802351:	56                   	push   %esi
  802352:	53                   	push   %ebx
  802353:	83 ec 0c             	sub    $0xc,%esp
  802356:	8b 7d 08             	mov    0x8(%ebp),%edi
  802359:	8b 75 0c             	mov    0xc(%ebp),%esi
  80235c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  80235f:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802361:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802366:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  802369:	ff 75 14             	pushl  0x14(%ebp)
  80236c:	53                   	push   %ebx
  80236d:	56                   	push   %esi
  80236e:	57                   	push   %edi
  80236f:	e8 b0 ea ff ff       	call   800e24 <sys_ipc_try_send>

		if (err < 0) {
  802374:	83 c4 10             	add    $0x10,%esp
  802377:	85 c0                	test   %eax,%eax
  802379:	79 1e                	jns    802399 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  80237b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80237e:	75 07                	jne    802387 <ipc_send+0x3a>
				sys_yield();
  802380:	e8 f3 e8 ff ff       	call   800c78 <sys_yield>
  802385:	eb e2                	jmp    802369 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802387:	50                   	push   %eax
  802388:	68 cf 2c 80 00       	push   $0x802ccf
  80238d:	6a 49                	push   $0x49
  80238f:	68 dc 2c 80 00       	push   $0x802cdc
  802394:	e8 9d de ff ff       	call   800236 <_panic>
		}

	} while (err < 0);

}
  802399:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80239c:	5b                   	pop    %ebx
  80239d:	5e                   	pop    %esi
  80239e:	5f                   	pop    %edi
  80239f:	5d                   	pop    %ebp
  8023a0:	c3                   	ret    

008023a1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023a1:	55                   	push   %ebp
  8023a2:	89 e5                	mov    %esp,%ebp
  8023a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8023a7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8023ac:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8023af:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023b5:	8b 52 50             	mov    0x50(%edx),%edx
  8023b8:	39 ca                	cmp    %ecx,%edx
  8023ba:	75 0d                	jne    8023c9 <ipc_find_env+0x28>
			return envs[i].env_id;
  8023bc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8023bf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8023c4:	8b 40 48             	mov    0x48(%eax),%eax
  8023c7:	eb 0f                	jmp    8023d8 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023c9:	83 c0 01             	add    $0x1,%eax
  8023cc:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023d1:	75 d9                	jne    8023ac <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8023d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023d8:	5d                   	pop    %ebp
  8023d9:	c3                   	ret    

008023da <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023da:	55                   	push   %ebp
  8023db:	89 e5                	mov    %esp,%ebp
  8023dd:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023e0:	89 d0                	mov    %edx,%eax
  8023e2:	c1 e8 16             	shr    $0x16,%eax
  8023e5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023ec:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023f1:	f6 c1 01             	test   $0x1,%cl
  8023f4:	74 1d                	je     802413 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023f6:	c1 ea 0c             	shr    $0xc,%edx
  8023f9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802400:	f6 c2 01             	test   $0x1,%dl
  802403:	74 0e                	je     802413 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802405:	c1 ea 0c             	shr    $0xc,%edx
  802408:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80240f:	ef 
  802410:	0f b7 c0             	movzwl %ax,%eax
}
  802413:	5d                   	pop    %ebp
  802414:	c3                   	ret    
  802415:	66 90                	xchg   %ax,%ax
  802417:	66 90                	xchg   %ax,%ax
  802419:	66 90                	xchg   %ax,%ax
  80241b:	66 90                	xchg   %ax,%ax
  80241d:	66 90                	xchg   %ax,%ax
  80241f:	90                   	nop

00802420 <__udivdi3>:
  802420:	55                   	push   %ebp
  802421:	57                   	push   %edi
  802422:	56                   	push   %esi
  802423:	53                   	push   %ebx
  802424:	83 ec 1c             	sub    $0x1c,%esp
  802427:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80242b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80242f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802433:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802437:	85 f6                	test   %esi,%esi
  802439:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80243d:	89 ca                	mov    %ecx,%edx
  80243f:	89 f8                	mov    %edi,%eax
  802441:	75 3d                	jne    802480 <__udivdi3+0x60>
  802443:	39 cf                	cmp    %ecx,%edi
  802445:	0f 87 c5 00 00 00    	ja     802510 <__udivdi3+0xf0>
  80244b:	85 ff                	test   %edi,%edi
  80244d:	89 fd                	mov    %edi,%ebp
  80244f:	75 0b                	jne    80245c <__udivdi3+0x3c>
  802451:	b8 01 00 00 00       	mov    $0x1,%eax
  802456:	31 d2                	xor    %edx,%edx
  802458:	f7 f7                	div    %edi
  80245a:	89 c5                	mov    %eax,%ebp
  80245c:	89 c8                	mov    %ecx,%eax
  80245e:	31 d2                	xor    %edx,%edx
  802460:	f7 f5                	div    %ebp
  802462:	89 c1                	mov    %eax,%ecx
  802464:	89 d8                	mov    %ebx,%eax
  802466:	89 cf                	mov    %ecx,%edi
  802468:	f7 f5                	div    %ebp
  80246a:	89 c3                	mov    %eax,%ebx
  80246c:	89 d8                	mov    %ebx,%eax
  80246e:	89 fa                	mov    %edi,%edx
  802470:	83 c4 1c             	add    $0x1c,%esp
  802473:	5b                   	pop    %ebx
  802474:	5e                   	pop    %esi
  802475:	5f                   	pop    %edi
  802476:	5d                   	pop    %ebp
  802477:	c3                   	ret    
  802478:	90                   	nop
  802479:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802480:	39 ce                	cmp    %ecx,%esi
  802482:	77 74                	ja     8024f8 <__udivdi3+0xd8>
  802484:	0f bd fe             	bsr    %esi,%edi
  802487:	83 f7 1f             	xor    $0x1f,%edi
  80248a:	0f 84 98 00 00 00    	je     802528 <__udivdi3+0x108>
  802490:	bb 20 00 00 00       	mov    $0x20,%ebx
  802495:	89 f9                	mov    %edi,%ecx
  802497:	89 c5                	mov    %eax,%ebp
  802499:	29 fb                	sub    %edi,%ebx
  80249b:	d3 e6                	shl    %cl,%esi
  80249d:	89 d9                	mov    %ebx,%ecx
  80249f:	d3 ed                	shr    %cl,%ebp
  8024a1:	89 f9                	mov    %edi,%ecx
  8024a3:	d3 e0                	shl    %cl,%eax
  8024a5:	09 ee                	or     %ebp,%esi
  8024a7:	89 d9                	mov    %ebx,%ecx
  8024a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024ad:	89 d5                	mov    %edx,%ebp
  8024af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024b3:	d3 ed                	shr    %cl,%ebp
  8024b5:	89 f9                	mov    %edi,%ecx
  8024b7:	d3 e2                	shl    %cl,%edx
  8024b9:	89 d9                	mov    %ebx,%ecx
  8024bb:	d3 e8                	shr    %cl,%eax
  8024bd:	09 c2                	or     %eax,%edx
  8024bf:	89 d0                	mov    %edx,%eax
  8024c1:	89 ea                	mov    %ebp,%edx
  8024c3:	f7 f6                	div    %esi
  8024c5:	89 d5                	mov    %edx,%ebp
  8024c7:	89 c3                	mov    %eax,%ebx
  8024c9:	f7 64 24 0c          	mull   0xc(%esp)
  8024cd:	39 d5                	cmp    %edx,%ebp
  8024cf:	72 10                	jb     8024e1 <__udivdi3+0xc1>
  8024d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8024d5:	89 f9                	mov    %edi,%ecx
  8024d7:	d3 e6                	shl    %cl,%esi
  8024d9:	39 c6                	cmp    %eax,%esi
  8024db:	73 07                	jae    8024e4 <__udivdi3+0xc4>
  8024dd:	39 d5                	cmp    %edx,%ebp
  8024df:	75 03                	jne    8024e4 <__udivdi3+0xc4>
  8024e1:	83 eb 01             	sub    $0x1,%ebx
  8024e4:	31 ff                	xor    %edi,%edi
  8024e6:	89 d8                	mov    %ebx,%eax
  8024e8:	89 fa                	mov    %edi,%edx
  8024ea:	83 c4 1c             	add    $0x1c,%esp
  8024ed:	5b                   	pop    %ebx
  8024ee:	5e                   	pop    %esi
  8024ef:	5f                   	pop    %edi
  8024f0:	5d                   	pop    %ebp
  8024f1:	c3                   	ret    
  8024f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024f8:	31 ff                	xor    %edi,%edi
  8024fa:	31 db                	xor    %ebx,%ebx
  8024fc:	89 d8                	mov    %ebx,%eax
  8024fe:	89 fa                	mov    %edi,%edx
  802500:	83 c4 1c             	add    $0x1c,%esp
  802503:	5b                   	pop    %ebx
  802504:	5e                   	pop    %esi
  802505:	5f                   	pop    %edi
  802506:	5d                   	pop    %ebp
  802507:	c3                   	ret    
  802508:	90                   	nop
  802509:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802510:	89 d8                	mov    %ebx,%eax
  802512:	f7 f7                	div    %edi
  802514:	31 ff                	xor    %edi,%edi
  802516:	89 c3                	mov    %eax,%ebx
  802518:	89 d8                	mov    %ebx,%eax
  80251a:	89 fa                	mov    %edi,%edx
  80251c:	83 c4 1c             	add    $0x1c,%esp
  80251f:	5b                   	pop    %ebx
  802520:	5e                   	pop    %esi
  802521:	5f                   	pop    %edi
  802522:	5d                   	pop    %ebp
  802523:	c3                   	ret    
  802524:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802528:	39 ce                	cmp    %ecx,%esi
  80252a:	72 0c                	jb     802538 <__udivdi3+0x118>
  80252c:	31 db                	xor    %ebx,%ebx
  80252e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802532:	0f 87 34 ff ff ff    	ja     80246c <__udivdi3+0x4c>
  802538:	bb 01 00 00 00       	mov    $0x1,%ebx
  80253d:	e9 2a ff ff ff       	jmp    80246c <__udivdi3+0x4c>
  802542:	66 90                	xchg   %ax,%ax
  802544:	66 90                	xchg   %ax,%ax
  802546:	66 90                	xchg   %ax,%ax
  802548:	66 90                	xchg   %ax,%ax
  80254a:	66 90                	xchg   %ax,%ax
  80254c:	66 90                	xchg   %ax,%ax
  80254e:	66 90                	xchg   %ax,%ax

00802550 <__umoddi3>:
  802550:	55                   	push   %ebp
  802551:	57                   	push   %edi
  802552:	56                   	push   %esi
  802553:	53                   	push   %ebx
  802554:	83 ec 1c             	sub    $0x1c,%esp
  802557:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80255b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80255f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802563:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802567:	85 d2                	test   %edx,%edx
  802569:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80256d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802571:	89 f3                	mov    %esi,%ebx
  802573:	89 3c 24             	mov    %edi,(%esp)
  802576:	89 74 24 04          	mov    %esi,0x4(%esp)
  80257a:	75 1c                	jne    802598 <__umoddi3+0x48>
  80257c:	39 f7                	cmp    %esi,%edi
  80257e:	76 50                	jbe    8025d0 <__umoddi3+0x80>
  802580:	89 c8                	mov    %ecx,%eax
  802582:	89 f2                	mov    %esi,%edx
  802584:	f7 f7                	div    %edi
  802586:	89 d0                	mov    %edx,%eax
  802588:	31 d2                	xor    %edx,%edx
  80258a:	83 c4 1c             	add    $0x1c,%esp
  80258d:	5b                   	pop    %ebx
  80258e:	5e                   	pop    %esi
  80258f:	5f                   	pop    %edi
  802590:	5d                   	pop    %ebp
  802591:	c3                   	ret    
  802592:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802598:	39 f2                	cmp    %esi,%edx
  80259a:	89 d0                	mov    %edx,%eax
  80259c:	77 52                	ja     8025f0 <__umoddi3+0xa0>
  80259e:	0f bd ea             	bsr    %edx,%ebp
  8025a1:	83 f5 1f             	xor    $0x1f,%ebp
  8025a4:	75 5a                	jne    802600 <__umoddi3+0xb0>
  8025a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8025aa:	0f 82 e0 00 00 00    	jb     802690 <__umoddi3+0x140>
  8025b0:	39 0c 24             	cmp    %ecx,(%esp)
  8025b3:	0f 86 d7 00 00 00    	jbe    802690 <__umoddi3+0x140>
  8025b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025c1:	83 c4 1c             	add    $0x1c,%esp
  8025c4:	5b                   	pop    %ebx
  8025c5:	5e                   	pop    %esi
  8025c6:	5f                   	pop    %edi
  8025c7:	5d                   	pop    %ebp
  8025c8:	c3                   	ret    
  8025c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025d0:	85 ff                	test   %edi,%edi
  8025d2:	89 fd                	mov    %edi,%ebp
  8025d4:	75 0b                	jne    8025e1 <__umoddi3+0x91>
  8025d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025db:	31 d2                	xor    %edx,%edx
  8025dd:	f7 f7                	div    %edi
  8025df:	89 c5                	mov    %eax,%ebp
  8025e1:	89 f0                	mov    %esi,%eax
  8025e3:	31 d2                	xor    %edx,%edx
  8025e5:	f7 f5                	div    %ebp
  8025e7:	89 c8                	mov    %ecx,%eax
  8025e9:	f7 f5                	div    %ebp
  8025eb:	89 d0                	mov    %edx,%eax
  8025ed:	eb 99                	jmp    802588 <__umoddi3+0x38>
  8025ef:	90                   	nop
  8025f0:	89 c8                	mov    %ecx,%eax
  8025f2:	89 f2                	mov    %esi,%edx
  8025f4:	83 c4 1c             	add    $0x1c,%esp
  8025f7:	5b                   	pop    %ebx
  8025f8:	5e                   	pop    %esi
  8025f9:	5f                   	pop    %edi
  8025fa:	5d                   	pop    %ebp
  8025fb:	c3                   	ret    
  8025fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802600:	8b 34 24             	mov    (%esp),%esi
  802603:	bf 20 00 00 00       	mov    $0x20,%edi
  802608:	89 e9                	mov    %ebp,%ecx
  80260a:	29 ef                	sub    %ebp,%edi
  80260c:	d3 e0                	shl    %cl,%eax
  80260e:	89 f9                	mov    %edi,%ecx
  802610:	89 f2                	mov    %esi,%edx
  802612:	d3 ea                	shr    %cl,%edx
  802614:	89 e9                	mov    %ebp,%ecx
  802616:	09 c2                	or     %eax,%edx
  802618:	89 d8                	mov    %ebx,%eax
  80261a:	89 14 24             	mov    %edx,(%esp)
  80261d:	89 f2                	mov    %esi,%edx
  80261f:	d3 e2                	shl    %cl,%edx
  802621:	89 f9                	mov    %edi,%ecx
  802623:	89 54 24 04          	mov    %edx,0x4(%esp)
  802627:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80262b:	d3 e8                	shr    %cl,%eax
  80262d:	89 e9                	mov    %ebp,%ecx
  80262f:	89 c6                	mov    %eax,%esi
  802631:	d3 e3                	shl    %cl,%ebx
  802633:	89 f9                	mov    %edi,%ecx
  802635:	89 d0                	mov    %edx,%eax
  802637:	d3 e8                	shr    %cl,%eax
  802639:	89 e9                	mov    %ebp,%ecx
  80263b:	09 d8                	or     %ebx,%eax
  80263d:	89 d3                	mov    %edx,%ebx
  80263f:	89 f2                	mov    %esi,%edx
  802641:	f7 34 24             	divl   (%esp)
  802644:	89 d6                	mov    %edx,%esi
  802646:	d3 e3                	shl    %cl,%ebx
  802648:	f7 64 24 04          	mull   0x4(%esp)
  80264c:	39 d6                	cmp    %edx,%esi
  80264e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802652:	89 d1                	mov    %edx,%ecx
  802654:	89 c3                	mov    %eax,%ebx
  802656:	72 08                	jb     802660 <__umoddi3+0x110>
  802658:	75 11                	jne    80266b <__umoddi3+0x11b>
  80265a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80265e:	73 0b                	jae    80266b <__umoddi3+0x11b>
  802660:	2b 44 24 04          	sub    0x4(%esp),%eax
  802664:	1b 14 24             	sbb    (%esp),%edx
  802667:	89 d1                	mov    %edx,%ecx
  802669:	89 c3                	mov    %eax,%ebx
  80266b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80266f:	29 da                	sub    %ebx,%edx
  802671:	19 ce                	sbb    %ecx,%esi
  802673:	89 f9                	mov    %edi,%ecx
  802675:	89 f0                	mov    %esi,%eax
  802677:	d3 e0                	shl    %cl,%eax
  802679:	89 e9                	mov    %ebp,%ecx
  80267b:	d3 ea                	shr    %cl,%edx
  80267d:	89 e9                	mov    %ebp,%ecx
  80267f:	d3 ee                	shr    %cl,%esi
  802681:	09 d0                	or     %edx,%eax
  802683:	89 f2                	mov    %esi,%edx
  802685:	83 c4 1c             	add    $0x1c,%esp
  802688:	5b                   	pop    %ebx
  802689:	5e                   	pop    %esi
  80268a:	5f                   	pop    %edi
  80268b:	5d                   	pop    %ebp
  80268c:	c3                   	ret    
  80268d:	8d 76 00             	lea    0x0(%esi),%esi
  802690:	29 f9                	sub    %edi,%ecx
  802692:	19 d6                	sbb    %edx,%esi
  802694:	89 74 24 04          	mov    %esi,0x4(%esp)
  802698:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80269c:	e9 18 ff ff ff       	jmp    8025b9 <__umoddi3+0x69>
