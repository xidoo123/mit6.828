
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
  80003c:	68 40 22 80 00       	push   $0x802240
  800041:	e8 c9 02 00 00       	call   80030f <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 9e 1a 00 00       	call   801aef <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x37>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 8e 22 80 00       	push   $0x80228e
  80005e:	6a 0d                	push   $0xd
  800060:	68 97 22 80 00       	push   $0x802297
  800065:	e8 cc 01 00 00       	call   800236 <_panic>
	if ((r = fork()) < 0)
  80006a:	e8 f2 0e 00 00       	call   800f61 <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x54>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 ac 22 80 00       	push   $0x8022ac
  80007b:	6a 0f                	push   $0xf
  80007d:	68 97 22 80 00       	push   $0x802297
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
  800091:	e8 25 12 00 00       	call   8012bb <close>
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
  8000be:	68 b5 22 80 00       	push   $0x8022b5
  8000c3:	e8 47 02 00 00       	call   80030f <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000cb:	83 ec 08             	sub    $0x8,%esp
  8000ce:	6a 0a                	push   $0xa
  8000d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000d3:	e8 33 12 00 00       	call   80130b <dup>
			sys_yield();
  8000d8:	e8 9b 0b 00 00       	call   800c78 <sys_yield>
			close(10);
  8000dd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000e4:	e8 d2 11 00 00       	call   8012bb <close>
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
  80011d:	e8 20 1b 00 00       	call   801c42 <pipeisclosed>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	74 28                	je     800151 <umain+0x11e>
			cprintf("\nRACE: pipe appears closed\n");
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	68 b9 22 80 00       	push   $0x8022b9
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
  80015c:	68 d5 22 80 00       	push   $0x8022d5
  800161:	e8 a9 01 00 00       	call   80030f <cprintf>
	if (pipeisclosed(p[0]))
  800166:	83 c4 04             	add    $0x4,%esp
  800169:	ff 75 e0             	pushl  -0x20(%ebp)
  80016c:	e8 d1 1a 00 00       	call   801c42 <pipeisclosed>
  800171:	83 c4 10             	add    $0x10,%esp
  800174:	85 c0                	test   %eax,%eax
  800176:	74 14                	je     80018c <umain+0x159>
		panic("somehow the other end of p[0] got closed!");
  800178:	83 ec 04             	sub    $0x4,%esp
  80017b:	68 64 22 80 00       	push   $0x802264
  800180:	6a 40                	push   $0x40
  800182:	68 97 22 80 00       	push   $0x802297
  800187:	e8 aa 00 00 00       	call   800236 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	ff 75 e0             	pushl  -0x20(%ebp)
  800196:	e8 f6 0f 00 00       	call   801191 <fd_lookup>
  80019b:	83 c4 10             	add    $0x10,%esp
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	79 12                	jns    8001b4 <umain+0x181>
		panic("cannot look up p[0]: %e", r);
  8001a2:	50                   	push   %eax
  8001a3:	68 eb 22 80 00       	push   $0x8022eb
  8001a8:	6a 42                	push   $0x42
  8001aa:	68 97 22 80 00       	push   $0x802297
  8001af:	e8 82 00 00 00       	call   800236 <_panic>
	(void) fd2data(fd);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ba:	e8 6c 0f 00 00       	call   80112b <fd2data>
	cprintf("race didn't happen\n");
  8001bf:	c7 04 24 03 23 80 00 	movl   $0x802303,(%esp)
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
  8001f3:	a3 04 40 80 00       	mov    %eax,0x804004

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
  800222:	e8 bf 10 00 00       	call   8012e6 <close_all>
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
  800254:	68 24 23 80 00       	push   $0x802324
  800259:	e8 b1 00 00 00       	call   80030f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025e:	83 c4 18             	add    $0x18,%esp
  800261:	53                   	push   %ebx
  800262:	ff 75 10             	pushl  0x10(%ebp)
  800265:	e8 54 00 00 00       	call   8002be <vcprintf>
	cprintf("\n");
  80026a:	c7 04 24 ff 27 80 00 	movl   $0x8027ff,(%esp)
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
  800372:	e8 29 1c 00 00       	call   801fa0 <__udivdi3>
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
  8003b5:	e8 16 1d 00 00       	call   8020d0 <__umoddi3>
  8003ba:	83 c4 14             	add    $0x14,%esp
  8003bd:	0f be 80 47 23 80 00 	movsbl 0x802347(%eax),%eax
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
  8004b9:	ff 24 85 80 24 80 00 	jmp    *0x802480(,%eax,4)
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
  80057d:	8b 14 85 e0 25 80 00 	mov    0x8025e0(,%eax,4),%edx
  800584:	85 d2                	test   %edx,%edx
  800586:	75 18                	jne    8005a0 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800588:	50                   	push   %eax
  800589:	68 5f 23 80 00       	push   $0x80235f
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
  8005a1:	68 cd 27 80 00       	push   $0x8027cd
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
  8005c5:	b8 58 23 80 00       	mov    $0x802358,%eax
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
  800c40:	68 3f 26 80 00       	push   $0x80263f
  800c45:	6a 23                	push   $0x23
  800c47:	68 5c 26 80 00       	push   $0x80265c
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
  800cc1:	68 3f 26 80 00       	push   $0x80263f
  800cc6:	6a 23                	push   $0x23
  800cc8:	68 5c 26 80 00       	push   $0x80265c
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
  800d03:	68 3f 26 80 00       	push   $0x80263f
  800d08:	6a 23                	push   $0x23
  800d0a:	68 5c 26 80 00       	push   $0x80265c
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
  800d45:	68 3f 26 80 00       	push   $0x80263f
  800d4a:	6a 23                	push   $0x23
  800d4c:	68 5c 26 80 00       	push   $0x80265c
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
  800d87:	68 3f 26 80 00       	push   $0x80263f
  800d8c:	6a 23                	push   $0x23
  800d8e:	68 5c 26 80 00       	push   $0x80265c
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
  800dc9:	68 3f 26 80 00       	push   $0x80263f
  800dce:	6a 23                	push   $0x23
  800dd0:	68 5c 26 80 00       	push   $0x80265c
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
  800e0b:	68 3f 26 80 00       	push   $0x80263f
  800e10:	6a 23                	push   $0x23
  800e12:	68 5c 26 80 00       	push   $0x80265c
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
  800e6f:	68 3f 26 80 00       	push   $0x80263f
  800e74:	6a 23                	push   $0x23
  800e76:	68 5c 26 80 00       	push   $0x80265c
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

00800e88 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	56                   	push   %esi
  800e8c:	53                   	push   %ebx
  800e8d:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e90:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800e92:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e96:	75 25                	jne    800ebd <pgfault+0x35>
  800e98:	89 d8                	mov    %ebx,%eax
  800e9a:	c1 e8 0c             	shr    $0xc,%eax
  800e9d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ea4:	f6 c4 08             	test   $0x8,%ah
  800ea7:	75 14                	jne    800ebd <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800ea9:	83 ec 04             	sub    $0x4,%esp
  800eac:	68 6c 26 80 00       	push   $0x80266c
  800eb1:	6a 1e                	push   $0x1e
  800eb3:	68 00 27 80 00       	push   $0x802700
  800eb8:	e8 79 f3 ff ff       	call   800236 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800ebd:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800ec3:	e8 91 fd ff ff       	call   800c59 <sys_getenvid>
  800ec8:	89 c6                	mov    %eax,%esi

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800eca:	83 ec 04             	sub    $0x4,%esp
  800ecd:	6a 07                	push   $0x7
  800ecf:	68 00 f0 7f 00       	push   $0x7ff000
  800ed4:	50                   	push   %eax
  800ed5:	e8 bd fd ff ff       	call   800c97 <sys_page_alloc>
	if (r < 0)
  800eda:	83 c4 10             	add    $0x10,%esp
  800edd:	85 c0                	test   %eax,%eax
  800edf:	79 12                	jns    800ef3 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800ee1:	50                   	push   %eax
  800ee2:	68 98 26 80 00       	push   $0x802698
  800ee7:	6a 31                	push   $0x31
  800ee9:	68 00 27 80 00       	push   $0x802700
  800eee:	e8 43 f3 ff ff       	call   800236 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800ef3:	83 ec 04             	sub    $0x4,%esp
  800ef6:	68 00 10 00 00       	push   $0x1000
  800efb:	53                   	push   %ebx
  800efc:	68 00 f0 7f 00       	push   $0x7ff000
  800f01:	e8 88 fb ff ff       	call   800a8e <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800f06:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f0d:	53                   	push   %ebx
  800f0e:	56                   	push   %esi
  800f0f:	68 00 f0 7f 00       	push   $0x7ff000
  800f14:	56                   	push   %esi
  800f15:	e8 c0 fd ff ff       	call   800cda <sys_page_map>
	if (r < 0)
  800f1a:	83 c4 20             	add    $0x20,%esp
  800f1d:	85 c0                	test   %eax,%eax
  800f1f:	79 12                	jns    800f33 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800f21:	50                   	push   %eax
  800f22:	68 bc 26 80 00       	push   $0x8026bc
  800f27:	6a 39                	push   $0x39
  800f29:	68 00 27 80 00       	push   $0x802700
  800f2e:	e8 03 f3 ff ff       	call   800236 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800f33:	83 ec 08             	sub    $0x8,%esp
  800f36:	68 00 f0 7f 00       	push   $0x7ff000
  800f3b:	56                   	push   %esi
  800f3c:	e8 db fd ff ff       	call   800d1c <sys_page_unmap>
	if (r < 0)
  800f41:	83 c4 10             	add    $0x10,%esp
  800f44:	85 c0                	test   %eax,%eax
  800f46:	79 12                	jns    800f5a <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800f48:	50                   	push   %eax
  800f49:	68 e0 26 80 00       	push   $0x8026e0
  800f4e:	6a 3e                	push   $0x3e
  800f50:	68 00 27 80 00       	push   $0x802700
  800f55:	e8 dc f2 ff ff       	call   800236 <_panic>
}
  800f5a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f5d:	5b                   	pop    %ebx
  800f5e:	5e                   	pop    %esi
  800f5f:	5d                   	pop    %ebp
  800f60:	c3                   	ret    

00800f61 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f61:	55                   	push   %ebp
  800f62:	89 e5                	mov    %esp,%ebp
  800f64:	57                   	push   %edi
  800f65:	56                   	push   %esi
  800f66:	53                   	push   %ebx
  800f67:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800f6a:	68 88 0e 80 00       	push   $0x800e88
  800f6f:	e8 84 0e 00 00       	call   801df8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f74:	b8 07 00 00 00       	mov    $0x7,%eax
  800f79:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800f7b:	83 c4 10             	add    $0x10,%esp
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	0f 88 67 01 00 00    	js     8010ed <fork+0x18c>
  800f86:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800f8b:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800f90:	85 c0                	test   %eax,%eax
  800f92:	75 21                	jne    800fb5 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f94:	e8 c0 fc ff ff       	call   800c59 <sys_getenvid>
  800f99:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f9e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fa1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fa6:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  800fab:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb0:	e9 42 01 00 00       	jmp    8010f7 <fork+0x196>
  800fb5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fb8:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800fba:	89 d8                	mov    %ebx,%eax
  800fbc:	c1 e8 16             	shr    $0x16,%eax
  800fbf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fc6:	a8 01                	test   $0x1,%al
  800fc8:	0f 84 c0 00 00 00    	je     80108e <fork+0x12d>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800fce:	89 d8                	mov    %ebx,%eax
  800fd0:	c1 e8 0c             	shr    $0xc,%eax
  800fd3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fda:	f6 c2 01             	test   $0x1,%dl
  800fdd:	0f 84 ab 00 00 00    	je     80108e <fork+0x12d>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
  800fe3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fea:	a9 02 08 00 00       	test   $0x802,%eax
  800fef:	0f 84 99 00 00 00    	je     80108e <fork+0x12d>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800ff5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ffc:	f6 c4 04             	test   $0x4,%ah
  800fff:	74 17                	je     801018 <fork+0xb7>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  801001:	83 ec 0c             	sub    $0xc,%esp
  801004:	68 07 0e 00 00       	push   $0xe07
  801009:	53                   	push   %ebx
  80100a:	57                   	push   %edi
  80100b:	53                   	push   %ebx
  80100c:	6a 00                	push   $0x0
  80100e:	e8 c7 fc ff ff       	call   800cda <sys_page_map>
  801013:	83 c4 20             	add    $0x20,%esp
  801016:	eb 76                	jmp    80108e <fork+0x12d>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801018:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80101f:	a8 02                	test   $0x2,%al
  801021:	75 0c                	jne    80102f <fork+0xce>
  801023:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80102a:	f6 c4 08             	test   $0x8,%ah
  80102d:	74 3f                	je     80106e <fork+0x10d>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  80102f:	83 ec 0c             	sub    $0xc,%esp
  801032:	68 05 08 00 00       	push   $0x805
  801037:	53                   	push   %ebx
  801038:	57                   	push   %edi
  801039:	53                   	push   %ebx
  80103a:	6a 00                	push   $0x0
  80103c:	e8 99 fc ff ff       	call   800cda <sys_page_map>
		if (r < 0)
  801041:	83 c4 20             	add    $0x20,%esp
  801044:	85 c0                	test   %eax,%eax
  801046:	0f 88 a5 00 00 00    	js     8010f1 <fork+0x190>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  80104c:	83 ec 0c             	sub    $0xc,%esp
  80104f:	68 05 08 00 00       	push   $0x805
  801054:	53                   	push   %ebx
  801055:	6a 00                	push   $0x0
  801057:	53                   	push   %ebx
  801058:	6a 00                	push   $0x0
  80105a:	e8 7b fc ff ff       	call   800cda <sys_page_map>
  80105f:	83 c4 20             	add    $0x20,%esp
  801062:	85 c0                	test   %eax,%eax
  801064:	b9 00 00 00 00       	mov    $0x0,%ecx
  801069:	0f 4f c1             	cmovg  %ecx,%eax
  80106c:	eb 1c                	jmp    80108a <fork+0x129>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  80106e:	83 ec 0c             	sub    $0xc,%esp
  801071:	6a 05                	push   $0x5
  801073:	53                   	push   %ebx
  801074:	57                   	push   %edi
  801075:	53                   	push   %ebx
  801076:	6a 00                	push   $0x0
  801078:	e8 5d fc ff ff       	call   800cda <sys_page_map>
  80107d:	83 c4 20             	add    $0x20,%esp
  801080:	85 c0                	test   %eax,%eax
  801082:	b9 00 00 00 00       	mov    $0x0,%ecx
  801087:	0f 4f c1             	cmovg  %ecx,%eax
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  80108a:	85 c0                	test   %eax,%eax
  80108c:	78 67                	js     8010f5 <fork+0x194>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  80108e:	83 c6 01             	add    $0x1,%esi
  801091:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801097:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  80109d:	0f 85 17 ff ff ff    	jne    800fba <fork+0x59>
  8010a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  8010a6:	83 ec 04             	sub    $0x4,%esp
  8010a9:	6a 07                	push   $0x7
  8010ab:	68 00 f0 bf ee       	push   $0xeebff000
  8010b0:	57                   	push   %edi
  8010b1:	e8 e1 fb ff ff       	call   800c97 <sys_page_alloc>
	if (r < 0)
  8010b6:	83 c4 10             	add    $0x10,%esp
		return r;
  8010b9:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  8010bb:	85 c0                	test   %eax,%eax
  8010bd:	78 38                	js     8010f7 <fork+0x196>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010bf:	83 ec 08             	sub    $0x8,%esp
  8010c2:	68 3f 1e 80 00       	push   $0x801e3f
  8010c7:	57                   	push   %edi
  8010c8:	e8 15 fd ff ff       	call   800de2 <sys_env_set_pgfault_upcall>
	if (r < 0)
  8010cd:	83 c4 10             	add    $0x10,%esp
		return r;
  8010d0:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  8010d2:	85 c0                	test   %eax,%eax
  8010d4:	78 21                	js     8010f7 <fork+0x196>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  8010d6:	83 ec 08             	sub    $0x8,%esp
  8010d9:	6a 02                	push   $0x2
  8010db:	57                   	push   %edi
  8010dc:	e8 7d fc ff ff       	call   800d5e <sys_env_set_status>
	if (r < 0)
  8010e1:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  8010e4:	85 c0                	test   %eax,%eax
  8010e6:	0f 48 f8             	cmovs  %eax,%edi
  8010e9:	89 fa                	mov    %edi,%edx
  8010eb:	eb 0a                	jmp    8010f7 <fork+0x196>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  8010ed:	89 c2                	mov    %eax,%edx
  8010ef:	eb 06                	jmp    8010f7 <fork+0x196>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  8010f1:	89 c2                	mov    %eax,%edx
  8010f3:	eb 02                	jmp    8010f7 <fork+0x196>
  8010f5:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  8010f7:	89 d0                	mov    %edx,%eax
  8010f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fc:	5b                   	pop    %ebx
  8010fd:	5e                   	pop    %esi
  8010fe:	5f                   	pop    %edi
  8010ff:	5d                   	pop    %ebp
  801100:	c3                   	ret    

00801101 <sfork>:

// Challenge!
int
sfork(void)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801107:	68 0b 27 80 00       	push   $0x80270b
  80110c:	68 c6 00 00 00       	push   $0xc6
  801111:	68 00 27 80 00       	push   $0x802700
  801116:	e8 1b f1 ff ff       	call   800236 <_panic>

0080111b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80111e:	8b 45 08             	mov    0x8(%ebp),%eax
  801121:	05 00 00 00 30       	add    $0x30000000,%eax
  801126:	c1 e8 0c             	shr    $0xc,%eax
}
  801129:	5d                   	pop    %ebp
  80112a:	c3                   	ret    

0080112b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80112e:	8b 45 08             	mov    0x8(%ebp),%eax
  801131:	05 00 00 00 30       	add    $0x30000000,%eax
  801136:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80113b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801140:	5d                   	pop    %ebp
  801141:	c3                   	ret    

00801142 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
  801145:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801148:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80114d:	89 c2                	mov    %eax,%edx
  80114f:	c1 ea 16             	shr    $0x16,%edx
  801152:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801159:	f6 c2 01             	test   $0x1,%dl
  80115c:	74 11                	je     80116f <fd_alloc+0x2d>
  80115e:	89 c2                	mov    %eax,%edx
  801160:	c1 ea 0c             	shr    $0xc,%edx
  801163:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80116a:	f6 c2 01             	test   $0x1,%dl
  80116d:	75 09                	jne    801178 <fd_alloc+0x36>
			*fd_store = fd;
  80116f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801171:	b8 00 00 00 00       	mov    $0x0,%eax
  801176:	eb 17                	jmp    80118f <fd_alloc+0x4d>
  801178:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80117d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801182:	75 c9                	jne    80114d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801184:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80118a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80118f:	5d                   	pop    %ebp
  801190:	c3                   	ret    

00801191 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801197:	83 f8 1f             	cmp    $0x1f,%eax
  80119a:	77 36                	ja     8011d2 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80119c:	c1 e0 0c             	shl    $0xc,%eax
  80119f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011a4:	89 c2                	mov    %eax,%edx
  8011a6:	c1 ea 16             	shr    $0x16,%edx
  8011a9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011b0:	f6 c2 01             	test   $0x1,%dl
  8011b3:	74 24                	je     8011d9 <fd_lookup+0x48>
  8011b5:	89 c2                	mov    %eax,%edx
  8011b7:	c1 ea 0c             	shr    $0xc,%edx
  8011ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011c1:	f6 c2 01             	test   $0x1,%dl
  8011c4:	74 1a                	je     8011e0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c9:	89 02                	mov    %eax,(%edx)
	return 0;
  8011cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d0:	eb 13                	jmp    8011e5 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d7:	eb 0c                	jmp    8011e5 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011de:	eb 05                	jmp    8011e5 <fd_lookup+0x54>
  8011e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
  8011ea:	83 ec 08             	sub    $0x8,%esp
  8011ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011f0:	ba a4 27 80 00       	mov    $0x8027a4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011f5:	eb 13                	jmp    80120a <dev_lookup+0x23>
  8011f7:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011fa:	39 08                	cmp    %ecx,(%eax)
  8011fc:	75 0c                	jne    80120a <dev_lookup+0x23>
			*dev = devtab[i];
  8011fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801201:	89 01                	mov    %eax,(%ecx)
			return 0;
  801203:	b8 00 00 00 00       	mov    $0x0,%eax
  801208:	eb 2e                	jmp    801238 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80120a:	8b 02                	mov    (%edx),%eax
  80120c:	85 c0                	test   %eax,%eax
  80120e:	75 e7                	jne    8011f7 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801210:	a1 04 40 80 00       	mov    0x804004,%eax
  801215:	8b 40 48             	mov    0x48(%eax),%eax
  801218:	83 ec 04             	sub    $0x4,%esp
  80121b:	51                   	push   %ecx
  80121c:	50                   	push   %eax
  80121d:	68 24 27 80 00       	push   $0x802724
  801222:	e8 e8 f0 ff ff       	call   80030f <cprintf>
	*dev = 0;
  801227:	8b 45 0c             	mov    0xc(%ebp),%eax
  80122a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801230:	83 c4 10             	add    $0x10,%esp
  801233:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801238:	c9                   	leave  
  801239:	c3                   	ret    

0080123a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80123a:	55                   	push   %ebp
  80123b:	89 e5                	mov    %esp,%ebp
  80123d:	56                   	push   %esi
  80123e:	53                   	push   %ebx
  80123f:	83 ec 10             	sub    $0x10,%esp
  801242:	8b 75 08             	mov    0x8(%ebp),%esi
  801245:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801248:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80124b:	50                   	push   %eax
  80124c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801252:	c1 e8 0c             	shr    $0xc,%eax
  801255:	50                   	push   %eax
  801256:	e8 36 ff ff ff       	call   801191 <fd_lookup>
  80125b:	83 c4 08             	add    $0x8,%esp
  80125e:	85 c0                	test   %eax,%eax
  801260:	78 05                	js     801267 <fd_close+0x2d>
	    || fd != fd2)
  801262:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801265:	74 0c                	je     801273 <fd_close+0x39>
		return (must_exist ? r : 0);
  801267:	84 db                	test   %bl,%bl
  801269:	ba 00 00 00 00       	mov    $0x0,%edx
  80126e:	0f 44 c2             	cmove  %edx,%eax
  801271:	eb 41                	jmp    8012b4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801273:	83 ec 08             	sub    $0x8,%esp
  801276:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801279:	50                   	push   %eax
  80127a:	ff 36                	pushl  (%esi)
  80127c:	e8 66 ff ff ff       	call   8011e7 <dev_lookup>
  801281:	89 c3                	mov    %eax,%ebx
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	85 c0                	test   %eax,%eax
  801288:	78 1a                	js     8012a4 <fd_close+0x6a>
		if (dev->dev_close)
  80128a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801290:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801295:	85 c0                	test   %eax,%eax
  801297:	74 0b                	je     8012a4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801299:	83 ec 0c             	sub    $0xc,%esp
  80129c:	56                   	push   %esi
  80129d:	ff d0                	call   *%eax
  80129f:	89 c3                	mov    %eax,%ebx
  8012a1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012a4:	83 ec 08             	sub    $0x8,%esp
  8012a7:	56                   	push   %esi
  8012a8:	6a 00                	push   $0x0
  8012aa:	e8 6d fa ff ff       	call   800d1c <sys_page_unmap>
	return r;
  8012af:	83 c4 10             	add    $0x10,%esp
  8012b2:	89 d8                	mov    %ebx,%eax
}
  8012b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b7:	5b                   	pop    %ebx
  8012b8:	5e                   	pop    %esi
  8012b9:	5d                   	pop    %ebp
  8012ba:	c3                   	ret    

008012bb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012bb:	55                   	push   %ebp
  8012bc:	89 e5                	mov    %esp,%ebp
  8012be:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c4:	50                   	push   %eax
  8012c5:	ff 75 08             	pushl  0x8(%ebp)
  8012c8:	e8 c4 fe ff ff       	call   801191 <fd_lookup>
  8012cd:	83 c4 08             	add    $0x8,%esp
  8012d0:	85 c0                	test   %eax,%eax
  8012d2:	78 10                	js     8012e4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012d4:	83 ec 08             	sub    $0x8,%esp
  8012d7:	6a 01                	push   $0x1
  8012d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8012dc:	e8 59 ff ff ff       	call   80123a <fd_close>
  8012e1:	83 c4 10             	add    $0x10,%esp
}
  8012e4:	c9                   	leave  
  8012e5:	c3                   	ret    

008012e6 <close_all>:

void
close_all(void)
{
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
  8012e9:	53                   	push   %ebx
  8012ea:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012ed:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012f2:	83 ec 0c             	sub    $0xc,%esp
  8012f5:	53                   	push   %ebx
  8012f6:	e8 c0 ff ff ff       	call   8012bb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012fb:	83 c3 01             	add    $0x1,%ebx
  8012fe:	83 c4 10             	add    $0x10,%esp
  801301:	83 fb 20             	cmp    $0x20,%ebx
  801304:	75 ec                	jne    8012f2 <close_all+0xc>
		close(i);
}
  801306:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801309:	c9                   	leave  
  80130a:	c3                   	ret    

0080130b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80130b:	55                   	push   %ebp
  80130c:	89 e5                	mov    %esp,%ebp
  80130e:	57                   	push   %edi
  80130f:	56                   	push   %esi
  801310:	53                   	push   %ebx
  801311:	83 ec 2c             	sub    $0x2c,%esp
  801314:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801317:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80131a:	50                   	push   %eax
  80131b:	ff 75 08             	pushl  0x8(%ebp)
  80131e:	e8 6e fe ff ff       	call   801191 <fd_lookup>
  801323:	83 c4 08             	add    $0x8,%esp
  801326:	85 c0                	test   %eax,%eax
  801328:	0f 88 c1 00 00 00    	js     8013ef <dup+0xe4>
		return r;
	close(newfdnum);
  80132e:	83 ec 0c             	sub    $0xc,%esp
  801331:	56                   	push   %esi
  801332:	e8 84 ff ff ff       	call   8012bb <close>

	newfd = INDEX2FD(newfdnum);
  801337:	89 f3                	mov    %esi,%ebx
  801339:	c1 e3 0c             	shl    $0xc,%ebx
  80133c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801342:	83 c4 04             	add    $0x4,%esp
  801345:	ff 75 e4             	pushl  -0x1c(%ebp)
  801348:	e8 de fd ff ff       	call   80112b <fd2data>
  80134d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80134f:	89 1c 24             	mov    %ebx,(%esp)
  801352:	e8 d4 fd ff ff       	call   80112b <fd2data>
  801357:	83 c4 10             	add    $0x10,%esp
  80135a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80135d:	89 f8                	mov    %edi,%eax
  80135f:	c1 e8 16             	shr    $0x16,%eax
  801362:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801369:	a8 01                	test   $0x1,%al
  80136b:	74 37                	je     8013a4 <dup+0x99>
  80136d:	89 f8                	mov    %edi,%eax
  80136f:	c1 e8 0c             	shr    $0xc,%eax
  801372:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801379:	f6 c2 01             	test   $0x1,%dl
  80137c:	74 26                	je     8013a4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80137e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801385:	83 ec 0c             	sub    $0xc,%esp
  801388:	25 07 0e 00 00       	and    $0xe07,%eax
  80138d:	50                   	push   %eax
  80138e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801391:	6a 00                	push   $0x0
  801393:	57                   	push   %edi
  801394:	6a 00                	push   $0x0
  801396:	e8 3f f9 ff ff       	call   800cda <sys_page_map>
  80139b:	89 c7                	mov    %eax,%edi
  80139d:	83 c4 20             	add    $0x20,%esp
  8013a0:	85 c0                	test   %eax,%eax
  8013a2:	78 2e                	js     8013d2 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013a7:	89 d0                	mov    %edx,%eax
  8013a9:	c1 e8 0c             	shr    $0xc,%eax
  8013ac:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013b3:	83 ec 0c             	sub    $0xc,%esp
  8013b6:	25 07 0e 00 00       	and    $0xe07,%eax
  8013bb:	50                   	push   %eax
  8013bc:	53                   	push   %ebx
  8013bd:	6a 00                	push   $0x0
  8013bf:	52                   	push   %edx
  8013c0:	6a 00                	push   $0x0
  8013c2:	e8 13 f9 ff ff       	call   800cda <sys_page_map>
  8013c7:	89 c7                	mov    %eax,%edi
  8013c9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013cc:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013ce:	85 ff                	test   %edi,%edi
  8013d0:	79 1d                	jns    8013ef <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013d2:	83 ec 08             	sub    $0x8,%esp
  8013d5:	53                   	push   %ebx
  8013d6:	6a 00                	push   $0x0
  8013d8:	e8 3f f9 ff ff       	call   800d1c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013dd:	83 c4 08             	add    $0x8,%esp
  8013e0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013e3:	6a 00                	push   $0x0
  8013e5:	e8 32 f9 ff ff       	call   800d1c <sys_page_unmap>
	return r;
  8013ea:	83 c4 10             	add    $0x10,%esp
  8013ed:	89 f8                	mov    %edi,%eax
}
  8013ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013f2:	5b                   	pop    %ebx
  8013f3:	5e                   	pop    %esi
  8013f4:	5f                   	pop    %edi
  8013f5:	5d                   	pop    %ebp
  8013f6:	c3                   	ret    

008013f7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013f7:	55                   	push   %ebp
  8013f8:	89 e5                	mov    %esp,%ebp
  8013fa:	53                   	push   %ebx
  8013fb:	83 ec 14             	sub    $0x14,%esp
  8013fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801401:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801404:	50                   	push   %eax
  801405:	53                   	push   %ebx
  801406:	e8 86 fd ff ff       	call   801191 <fd_lookup>
  80140b:	83 c4 08             	add    $0x8,%esp
  80140e:	89 c2                	mov    %eax,%edx
  801410:	85 c0                	test   %eax,%eax
  801412:	78 6d                	js     801481 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801414:	83 ec 08             	sub    $0x8,%esp
  801417:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80141a:	50                   	push   %eax
  80141b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141e:	ff 30                	pushl  (%eax)
  801420:	e8 c2 fd ff ff       	call   8011e7 <dev_lookup>
  801425:	83 c4 10             	add    $0x10,%esp
  801428:	85 c0                	test   %eax,%eax
  80142a:	78 4c                	js     801478 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80142c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80142f:	8b 42 08             	mov    0x8(%edx),%eax
  801432:	83 e0 03             	and    $0x3,%eax
  801435:	83 f8 01             	cmp    $0x1,%eax
  801438:	75 21                	jne    80145b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80143a:	a1 04 40 80 00       	mov    0x804004,%eax
  80143f:	8b 40 48             	mov    0x48(%eax),%eax
  801442:	83 ec 04             	sub    $0x4,%esp
  801445:	53                   	push   %ebx
  801446:	50                   	push   %eax
  801447:	68 68 27 80 00       	push   $0x802768
  80144c:	e8 be ee ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  801451:	83 c4 10             	add    $0x10,%esp
  801454:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801459:	eb 26                	jmp    801481 <read+0x8a>
	}
	if (!dev->dev_read)
  80145b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80145e:	8b 40 08             	mov    0x8(%eax),%eax
  801461:	85 c0                	test   %eax,%eax
  801463:	74 17                	je     80147c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801465:	83 ec 04             	sub    $0x4,%esp
  801468:	ff 75 10             	pushl  0x10(%ebp)
  80146b:	ff 75 0c             	pushl  0xc(%ebp)
  80146e:	52                   	push   %edx
  80146f:	ff d0                	call   *%eax
  801471:	89 c2                	mov    %eax,%edx
  801473:	83 c4 10             	add    $0x10,%esp
  801476:	eb 09                	jmp    801481 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801478:	89 c2                	mov    %eax,%edx
  80147a:	eb 05                	jmp    801481 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80147c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801481:	89 d0                	mov    %edx,%eax
  801483:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801486:	c9                   	leave  
  801487:	c3                   	ret    

00801488 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801488:	55                   	push   %ebp
  801489:	89 e5                	mov    %esp,%ebp
  80148b:	57                   	push   %edi
  80148c:	56                   	push   %esi
  80148d:	53                   	push   %ebx
  80148e:	83 ec 0c             	sub    $0xc,%esp
  801491:	8b 7d 08             	mov    0x8(%ebp),%edi
  801494:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801497:	bb 00 00 00 00       	mov    $0x0,%ebx
  80149c:	eb 21                	jmp    8014bf <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80149e:	83 ec 04             	sub    $0x4,%esp
  8014a1:	89 f0                	mov    %esi,%eax
  8014a3:	29 d8                	sub    %ebx,%eax
  8014a5:	50                   	push   %eax
  8014a6:	89 d8                	mov    %ebx,%eax
  8014a8:	03 45 0c             	add    0xc(%ebp),%eax
  8014ab:	50                   	push   %eax
  8014ac:	57                   	push   %edi
  8014ad:	e8 45 ff ff ff       	call   8013f7 <read>
		if (m < 0)
  8014b2:	83 c4 10             	add    $0x10,%esp
  8014b5:	85 c0                	test   %eax,%eax
  8014b7:	78 10                	js     8014c9 <readn+0x41>
			return m;
		if (m == 0)
  8014b9:	85 c0                	test   %eax,%eax
  8014bb:	74 0a                	je     8014c7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014bd:	01 c3                	add    %eax,%ebx
  8014bf:	39 f3                	cmp    %esi,%ebx
  8014c1:	72 db                	jb     80149e <readn+0x16>
  8014c3:	89 d8                	mov    %ebx,%eax
  8014c5:	eb 02                	jmp    8014c9 <readn+0x41>
  8014c7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014cc:	5b                   	pop    %ebx
  8014cd:	5e                   	pop    %esi
  8014ce:	5f                   	pop    %edi
  8014cf:	5d                   	pop    %ebp
  8014d0:	c3                   	ret    

008014d1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014d1:	55                   	push   %ebp
  8014d2:	89 e5                	mov    %esp,%ebp
  8014d4:	53                   	push   %ebx
  8014d5:	83 ec 14             	sub    $0x14,%esp
  8014d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014de:	50                   	push   %eax
  8014df:	53                   	push   %ebx
  8014e0:	e8 ac fc ff ff       	call   801191 <fd_lookup>
  8014e5:	83 c4 08             	add    $0x8,%esp
  8014e8:	89 c2                	mov    %eax,%edx
  8014ea:	85 c0                	test   %eax,%eax
  8014ec:	78 68                	js     801556 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ee:	83 ec 08             	sub    $0x8,%esp
  8014f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f4:	50                   	push   %eax
  8014f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f8:	ff 30                	pushl  (%eax)
  8014fa:	e8 e8 fc ff ff       	call   8011e7 <dev_lookup>
  8014ff:	83 c4 10             	add    $0x10,%esp
  801502:	85 c0                	test   %eax,%eax
  801504:	78 47                	js     80154d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801506:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801509:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80150d:	75 21                	jne    801530 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80150f:	a1 04 40 80 00       	mov    0x804004,%eax
  801514:	8b 40 48             	mov    0x48(%eax),%eax
  801517:	83 ec 04             	sub    $0x4,%esp
  80151a:	53                   	push   %ebx
  80151b:	50                   	push   %eax
  80151c:	68 84 27 80 00       	push   $0x802784
  801521:	e8 e9 ed ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  801526:	83 c4 10             	add    $0x10,%esp
  801529:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80152e:	eb 26                	jmp    801556 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801530:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801533:	8b 52 0c             	mov    0xc(%edx),%edx
  801536:	85 d2                	test   %edx,%edx
  801538:	74 17                	je     801551 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80153a:	83 ec 04             	sub    $0x4,%esp
  80153d:	ff 75 10             	pushl  0x10(%ebp)
  801540:	ff 75 0c             	pushl  0xc(%ebp)
  801543:	50                   	push   %eax
  801544:	ff d2                	call   *%edx
  801546:	89 c2                	mov    %eax,%edx
  801548:	83 c4 10             	add    $0x10,%esp
  80154b:	eb 09                	jmp    801556 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154d:	89 c2                	mov    %eax,%edx
  80154f:	eb 05                	jmp    801556 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801551:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801556:	89 d0                	mov    %edx,%eax
  801558:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80155b:	c9                   	leave  
  80155c:	c3                   	ret    

0080155d <seek>:

int
seek(int fdnum, off_t offset)
{
  80155d:	55                   	push   %ebp
  80155e:	89 e5                	mov    %esp,%ebp
  801560:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801563:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801566:	50                   	push   %eax
  801567:	ff 75 08             	pushl  0x8(%ebp)
  80156a:	e8 22 fc ff ff       	call   801191 <fd_lookup>
  80156f:	83 c4 08             	add    $0x8,%esp
  801572:	85 c0                	test   %eax,%eax
  801574:	78 0e                	js     801584 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801576:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801579:	8b 55 0c             	mov    0xc(%ebp),%edx
  80157c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80157f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801584:	c9                   	leave  
  801585:	c3                   	ret    

00801586 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801586:	55                   	push   %ebp
  801587:	89 e5                	mov    %esp,%ebp
  801589:	53                   	push   %ebx
  80158a:	83 ec 14             	sub    $0x14,%esp
  80158d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801590:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801593:	50                   	push   %eax
  801594:	53                   	push   %ebx
  801595:	e8 f7 fb ff ff       	call   801191 <fd_lookup>
  80159a:	83 c4 08             	add    $0x8,%esp
  80159d:	89 c2                	mov    %eax,%edx
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	78 65                	js     801608 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a3:	83 ec 08             	sub    $0x8,%esp
  8015a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a9:	50                   	push   %eax
  8015aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ad:	ff 30                	pushl  (%eax)
  8015af:	e8 33 fc ff ff       	call   8011e7 <dev_lookup>
  8015b4:	83 c4 10             	add    $0x10,%esp
  8015b7:	85 c0                	test   %eax,%eax
  8015b9:	78 44                	js     8015ff <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015be:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015c2:	75 21                	jne    8015e5 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015c4:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015c9:	8b 40 48             	mov    0x48(%eax),%eax
  8015cc:	83 ec 04             	sub    $0x4,%esp
  8015cf:	53                   	push   %ebx
  8015d0:	50                   	push   %eax
  8015d1:	68 44 27 80 00       	push   $0x802744
  8015d6:	e8 34 ed ff ff       	call   80030f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015db:	83 c4 10             	add    $0x10,%esp
  8015de:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015e3:	eb 23                	jmp    801608 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015e8:	8b 52 18             	mov    0x18(%edx),%edx
  8015eb:	85 d2                	test   %edx,%edx
  8015ed:	74 14                	je     801603 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015ef:	83 ec 08             	sub    $0x8,%esp
  8015f2:	ff 75 0c             	pushl  0xc(%ebp)
  8015f5:	50                   	push   %eax
  8015f6:	ff d2                	call   *%edx
  8015f8:	89 c2                	mov    %eax,%edx
  8015fa:	83 c4 10             	add    $0x10,%esp
  8015fd:	eb 09                	jmp    801608 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ff:	89 c2                	mov    %eax,%edx
  801601:	eb 05                	jmp    801608 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801603:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801608:	89 d0                	mov    %edx,%eax
  80160a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80160d:	c9                   	leave  
  80160e:	c3                   	ret    

0080160f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80160f:	55                   	push   %ebp
  801610:	89 e5                	mov    %esp,%ebp
  801612:	53                   	push   %ebx
  801613:	83 ec 14             	sub    $0x14,%esp
  801616:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801619:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80161c:	50                   	push   %eax
  80161d:	ff 75 08             	pushl  0x8(%ebp)
  801620:	e8 6c fb ff ff       	call   801191 <fd_lookup>
  801625:	83 c4 08             	add    $0x8,%esp
  801628:	89 c2                	mov    %eax,%edx
  80162a:	85 c0                	test   %eax,%eax
  80162c:	78 58                	js     801686 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162e:	83 ec 08             	sub    $0x8,%esp
  801631:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801634:	50                   	push   %eax
  801635:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801638:	ff 30                	pushl  (%eax)
  80163a:	e8 a8 fb ff ff       	call   8011e7 <dev_lookup>
  80163f:	83 c4 10             	add    $0x10,%esp
  801642:	85 c0                	test   %eax,%eax
  801644:	78 37                	js     80167d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801646:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801649:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80164d:	74 32                	je     801681 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80164f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801652:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801659:	00 00 00 
	stat->st_isdir = 0;
  80165c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801663:	00 00 00 
	stat->st_dev = dev;
  801666:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80166c:	83 ec 08             	sub    $0x8,%esp
  80166f:	53                   	push   %ebx
  801670:	ff 75 f0             	pushl  -0x10(%ebp)
  801673:	ff 50 14             	call   *0x14(%eax)
  801676:	89 c2                	mov    %eax,%edx
  801678:	83 c4 10             	add    $0x10,%esp
  80167b:	eb 09                	jmp    801686 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167d:	89 c2                	mov    %eax,%edx
  80167f:	eb 05                	jmp    801686 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801681:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801686:	89 d0                	mov    %edx,%eax
  801688:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80168b:	c9                   	leave  
  80168c:	c3                   	ret    

0080168d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80168d:	55                   	push   %ebp
  80168e:	89 e5                	mov    %esp,%ebp
  801690:	56                   	push   %esi
  801691:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801692:	83 ec 08             	sub    $0x8,%esp
  801695:	6a 00                	push   $0x0
  801697:	ff 75 08             	pushl  0x8(%ebp)
  80169a:	e8 d6 01 00 00       	call   801875 <open>
  80169f:	89 c3                	mov    %eax,%ebx
  8016a1:	83 c4 10             	add    $0x10,%esp
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	78 1b                	js     8016c3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016a8:	83 ec 08             	sub    $0x8,%esp
  8016ab:	ff 75 0c             	pushl  0xc(%ebp)
  8016ae:	50                   	push   %eax
  8016af:	e8 5b ff ff ff       	call   80160f <fstat>
  8016b4:	89 c6                	mov    %eax,%esi
	close(fd);
  8016b6:	89 1c 24             	mov    %ebx,(%esp)
  8016b9:	e8 fd fb ff ff       	call   8012bb <close>
	return r;
  8016be:	83 c4 10             	add    $0x10,%esp
  8016c1:	89 f0                	mov    %esi,%eax
}
  8016c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c6:	5b                   	pop    %ebx
  8016c7:	5e                   	pop    %esi
  8016c8:	5d                   	pop    %ebp
  8016c9:	c3                   	ret    

008016ca <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	56                   	push   %esi
  8016ce:	53                   	push   %ebx
  8016cf:	89 c6                	mov    %eax,%esi
  8016d1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016d3:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016da:	75 12                	jne    8016ee <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016dc:	83 ec 0c             	sub    $0xc,%esp
  8016df:	6a 01                	push   $0x1
  8016e1:	e8 38 08 00 00       	call   801f1e <ipc_find_env>
  8016e6:	a3 00 40 80 00       	mov    %eax,0x804000
  8016eb:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016ee:	6a 07                	push   $0x7
  8016f0:	68 00 50 80 00       	push   $0x805000
  8016f5:	56                   	push   %esi
  8016f6:	ff 35 00 40 80 00    	pushl  0x804000
  8016fc:	e8 c9 07 00 00       	call   801eca <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801701:	83 c4 0c             	add    $0xc,%esp
  801704:	6a 00                	push   $0x0
  801706:	53                   	push   %ebx
  801707:	6a 00                	push   $0x0
  801709:	e8 55 07 00 00       	call   801e63 <ipc_recv>
}
  80170e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801711:	5b                   	pop    %ebx
  801712:	5e                   	pop    %esi
  801713:	5d                   	pop    %ebp
  801714:	c3                   	ret    

00801715 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80171b:	8b 45 08             	mov    0x8(%ebp),%eax
  80171e:	8b 40 0c             	mov    0xc(%eax),%eax
  801721:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801726:	8b 45 0c             	mov    0xc(%ebp),%eax
  801729:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80172e:	ba 00 00 00 00       	mov    $0x0,%edx
  801733:	b8 02 00 00 00       	mov    $0x2,%eax
  801738:	e8 8d ff ff ff       	call   8016ca <fsipc>
}
  80173d:	c9                   	leave  
  80173e:	c3                   	ret    

0080173f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80173f:	55                   	push   %ebp
  801740:	89 e5                	mov    %esp,%ebp
  801742:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801745:	8b 45 08             	mov    0x8(%ebp),%eax
  801748:	8b 40 0c             	mov    0xc(%eax),%eax
  80174b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801750:	ba 00 00 00 00       	mov    $0x0,%edx
  801755:	b8 06 00 00 00       	mov    $0x6,%eax
  80175a:	e8 6b ff ff ff       	call   8016ca <fsipc>
}
  80175f:	c9                   	leave  
  801760:	c3                   	ret    

00801761 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	53                   	push   %ebx
  801765:	83 ec 04             	sub    $0x4,%esp
  801768:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80176b:	8b 45 08             	mov    0x8(%ebp),%eax
  80176e:	8b 40 0c             	mov    0xc(%eax),%eax
  801771:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801776:	ba 00 00 00 00       	mov    $0x0,%edx
  80177b:	b8 05 00 00 00       	mov    $0x5,%eax
  801780:	e8 45 ff ff ff       	call   8016ca <fsipc>
  801785:	85 c0                	test   %eax,%eax
  801787:	78 2c                	js     8017b5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801789:	83 ec 08             	sub    $0x8,%esp
  80178c:	68 00 50 80 00       	push   $0x805000
  801791:	53                   	push   %ebx
  801792:	e8 fd f0 ff ff       	call   800894 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801797:	a1 80 50 80 00       	mov    0x805080,%eax
  80179c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017a2:	a1 84 50 80 00       	mov    0x805084,%eax
  8017a7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017ad:	83 c4 10             	add    $0x10,%esp
  8017b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b8:	c9                   	leave  
  8017b9:	c3                   	ret    

008017ba <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017ba:	55                   	push   %ebp
  8017bb:	89 e5                	mov    %esp,%ebp
  8017bd:	83 ec 0c             	sub    $0xc,%esp
  8017c0:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8017c6:	8b 52 0c             	mov    0xc(%edx),%edx
  8017c9:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017cf:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017d4:	50                   	push   %eax
  8017d5:	ff 75 0c             	pushl  0xc(%ebp)
  8017d8:	68 08 50 80 00       	push   $0x805008
  8017dd:	e8 44 f2 ff ff       	call   800a26 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8017e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e7:	b8 04 00 00 00       	mov    $0x4,%eax
  8017ec:	e8 d9 fe ff ff       	call   8016ca <fsipc>

}
  8017f1:	c9                   	leave  
  8017f2:	c3                   	ret    

008017f3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017f3:	55                   	push   %ebp
  8017f4:	89 e5                	mov    %esp,%ebp
  8017f6:	56                   	push   %esi
  8017f7:	53                   	push   %ebx
  8017f8:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fe:	8b 40 0c             	mov    0xc(%eax),%eax
  801801:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801806:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80180c:	ba 00 00 00 00       	mov    $0x0,%edx
  801811:	b8 03 00 00 00       	mov    $0x3,%eax
  801816:	e8 af fe ff ff       	call   8016ca <fsipc>
  80181b:	89 c3                	mov    %eax,%ebx
  80181d:	85 c0                	test   %eax,%eax
  80181f:	78 4b                	js     80186c <devfile_read+0x79>
		return r;
	assert(r <= n);
  801821:	39 c6                	cmp    %eax,%esi
  801823:	73 16                	jae    80183b <devfile_read+0x48>
  801825:	68 b4 27 80 00       	push   $0x8027b4
  80182a:	68 bb 27 80 00       	push   $0x8027bb
  80182f:	6a 7c                	push   $0x7c
  801831:	68 d0 27 80 00       	push   $0x8027d0
  801836:	e8 fb e9 ff ff       	call   800236 <_panic>
	assert(r <= PGSIZE);
  80183b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801840:	7e 16                	jle    801858 <devfile_read+0x65>
  801842:	68 db 27 80 00       	push   $0x8027db
  801847:	68 bb 27 80 00       	push   $0x8027bb
  80184c:	6a 7d                	push   $0x7d
  80184e:	68 d0 27 80 00       	push   $0x8027d0
  801853:	e8 de e9 ff ff       	call   800236 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801858:	83 ec 04             	sub    $0x4,%esp
  80185b:	50                   	push   %eax
  80185c:	68 00 50 80 00       	push   $0x805000
  801861:	ff 75 0c             	pushl  0xc(%ebp)
  801864:	e8 bd f1 ff ff       	call   800a26 <memmove>
	return r;
  801869:	83 c4 10             	add    $0x10,%esp
}
  80186c:	89 d8                	mov    %ebx,%eax
  80186e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801871:	5b                   	pop    %ebx
  801872:	5e                   	pop    %esi
  801873:	5d                   	pop    %ebp
  801874:	c3                   	ret    

00801875 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801875:	55                   	push   %ebp
  801876:	89 e5                	mov    %esp,%ebp
  801878:	53                   	push   %ebx
  801879:	83 ec 20             	sub    $0x20,%esp
  80187c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80187f:	53                   	push   %ebx
  801880:	e8 d6 ef ff ff       	call   80085b <strlen>
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80188d:	7f 67                	jg     8018f6 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80188f:	83 ec 0c             	sub    $0xc,%esp
  801892:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801895:	50                   	push   %eax
  801896:	e8 a7 f8 ff ff       	call   801142 <fd_alloc>
  80189b:	83 c4 10             	add    $0x10,%esp
		return r;
  80189e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018a0:	85 c0                	test   %eax,%eax
  8018a2:	78 57                	js     8018fb <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018a4:	83 ec 08             	sub    $0x8,%esp
  8018a7:	53                   	push   %ebx
  8018a8:	68 00 50 80 00       	push   $0x805000
  8018ad:	e8 e2 ef ff ff       	call   800894 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b5:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8018c2:	e8 03 fe ff ff       	call   8016ca <fsipc>
  8018c7:	89 c3                	mov    %eax,%ebx
  8018c9:	83 c4 10             	add    $0x10,%esp
  8018cc:	85 c0                	test   %eax,%eax
  8018ce:	79 14                	jns    8018e4 <open+0x6f>
		fd_close(fd, 0);
  8018d0:	83 ec 08             	sub    $0x8,%esp
  8018d3:	6a 00                	push   $0x0
  8018d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8018d8:	e8 5d f9 ff ff       	call   80123a <fd_close>
		return r;
  8018dd:	83 c4 10             	add    $0x10,%esp
  8018e0:	89 da                	mov    %ebx,%edx
  8018e2:	eb 17                	jmp    8018fb <open+0x86>
	}

	return fd2num(fd);
  8018e4:	83 ec 0c             	sub    $0xc,%esp
  8018e7:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ea:	e8 2c f8 ff ff       	call   80111b <fd2num>
  8018ef:	89 c2                	mov    %eax,%edx
  8018f1:	83 c4 10             	add    $0x10,%esp
  8018f4:	eb 05                	jmp    8018fb <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018f6:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018fb:	89 d0                	mov    %edx,%eax
  8018fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801900:	c9                   	leave  
  801901:	c3                   	ret    

00801902 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801908:	ba 00 00 00 00       	mov    $0x0,%edx
  80190d:	b8 08 00 00 00       	mov    $0x8,%eax
  801912:	e8 b3 fd ff ff       	call   8016ca <fsipc>
}
  801917:	c9                   	leave  
  801918:	c3                   	ret    

00801919 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801919:	55                   	push   %ebp
  80191a:	89 e5                	mov    %esp,%ebp
  80191c:	56                   	push   %esi
  80191d:	53                   	push   %ebx
  80191e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801921:	83 ec 0c             	sub    $0xc,%esp
  801924:	ff 75 08             	pushl  0x8(%ebp)
  801927:	e8 ff f7 ff ff       	call   80112b <fd2data>
  80192c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80192e:	83 c4 08             	add    $0x8,%esp
  801931:	68 e7 27 80 00       	push   $0x8027e7
  801936:	53                   	push   %ebx
  801937:	e8 58 ef ff ff       	call   800894 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80193c:	8b 46 04             	mov    0x4(%esi),%eax
  80193f:	2b 06                	sub    (%esi),%eax
  801941:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801947:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80194e:	00 00 00 
	stat->st_dev = &devpipe;
  801951:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801958:	30 80 00 
	return 0;
}
  80195b:	b8 00 00 00 00       	mov    $0x0,%eax
  801960:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801963:	5b                   	pop    %ebx
  801964:	5e                   	pop    %esi
  801965:	5d                   	pop    %ebp
  801966:	c3                   	ret    

00801967 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801967:	55                   	push   %ebp
  801968:	89 e5                	mov    %esp,%ebp
  80196a:	53                   	push   %ebx
  80196b:	83 ec 0c             	sub    $0xc,%esp
  80196e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801971:	53                   	push   %ebx
  801972:	6a 00                	push   $0x0
  801974:	e8 a3 f3 ff ff       	call   800d1c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801979:	89 1c 24             	mov    %ebx,(%esp)
  80197c:	e8 aa f7 ff ff       	call   80112b <fd2data>
  801981:	83 c4 08             	add    $0x8,%esp
  801984:	50                   	push   %eax
  801985:	6a 00                	push   $0x0
  801987:	e8 90 f3 ff ff       	call   800d1c <sys_page_unmap>
}
  80198c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198f:	c9                   	leave  
  801990:	c3                   	ret    

00801991 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801991:	55                   	push   %ebp
  801992:	89 e5                	mov    %esp,%ebp
  801994:	57                   	push   %edi
  801995:	56                   	push   %esi
  801996:	53                   	push   %ebx
  801997:	83 ec 1c             	sub    $0x1c,%esp
  80199a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80199d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80199f:	a1 04 40 80 00       	mov    0x804004,%eax
  8019a4:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019a7:	83 ec 0c             	sub    $0xc,%esp
  8019aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8019ad:	e8 a5 05 00 00       	call   801f57 <pageref>
  8019b2:	89 c3                	mov    %eax,%ebx
  8019b4:	89 3c 24             	mov    %edi,(%esp)
  8019b7:	e8 9b 05 00 00       	call   801f57 <pageref>
  8019bc:	83 c4 10             	add    $0x10,%esp
  8019bf:	39 c3                	cmp    %eax,%ebx
  8019c1:	0f 94 c1             	sete   %cl
  8019c4:	0f b6 c9             	movzbl %cl,%ecx
  8019c7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019ca:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019d0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019d3:	39 ce                	cmp    %ecx,%esi
  8019d5:	74 1b                	je     8019f2 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8019d7:	39 c3                	cmp    %eax,%ebx
  8019d9:	75 c4                	jne    80199f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019db:	8b 42 58             	mov    0x58(%edx),%eax
  8019de:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019e1:	50                   	push   %eax
  8019e2:	56                   	push   %esi
  8019e3:	68 ee 27 80 00       	push   $0x8027ee
  8019e8:	e8 22 e9 ff ff       	call   80030f <cprintf>
  8019ed:	83 c4 10             	add    $0x10,%esp
  8019f0:	eb ad                	jmp    80199f <_pipeisclosed+0xe>
	}
}
  8019f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019f8:	5b                   	pop    %ebx
  8019f9:	5e                   	pop    %esi
  8019fa:	5f                   	pop    %edi
  8019fb:	5d                   	pop    %ebp
  8019fc:	c3                   	ret    

008019fd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019fd:	55                   	push   %ebp
  8019fe:	89 e5                	mov    %esp,%ebp
  801a00:	57                   	push   %edi
  801a01:	56                   	push   %esi
  801a02:	53                   	push   %ebx
  801a03:	83 ec 28             	sub    $0x28,%esp
  801a06:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a09:	56                   	push   %esi
  801a0a:	e8 1c f7 ff ff       	call   80112b <fd2data>
  801a0f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a11:	83 c4 10             	add    $0x10,%esp
  801a14:	bf 00 00 00 00       	mov    $0x0,%edi
  801a19:	eb 4b                	jmp    801a66 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a1b:	89 da                	mov    %ebx,%edx
  801a1d:	89 f0                	mov    %esi,%eax
  801a1f:	e8 6d ff ff ff       	call   801991 <_pipeisclosed>
  801a24:	85 c0                	test   %eax,%eax
  801a26:	75 48                	jne    801a70 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a28:	e8 4b f2 ff ff       	call   800c78 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a2d:	8b 43 04             	mov    0x4(%ebx),%eax
  801a30:	8b 0b                	mov    (%ebx),%ecx
  801a32:	8d 51 20             	lea    0x20(%ecx),%edx
  801a35:	39 d0                	cmp    %edx,%eax
  801a37:	73 e2                	jae    801a1b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a3c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a40:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a43:	89 c2                	mov    %eax,%edx
  801a45:	c1 fa 1f             	sar    $0x1f,%edx
  801a48:	89 d1                	mov    %edx,%ecx
  801a4a:	c1 e9 1b             	shr    $0x1b,%ecx
  801a4d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a50:	83 e2 1f             	and    $0x1f,%edx
  801a53:	29 ca                	sub    %ecx,%edx
  801a55:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a59:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a5d:	83 c0 01             	add    $0x1,%eax
  801a60:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a63:	83 c7 01             	add    $0x1,%edi
  801a66:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a69:	75 c2                	jne    801a2d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a6b:	8b 45 10             	mov    0x10(%ebp),%eax
  801a6e:	eb 05                	jmp    801a75 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a70:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a78:	5b                   	pop    %ebx
  801a79:	5e                   	pop    %esi
  801a7a:	5f                   	pop    %edi
  801a7b:	5d                   	pop    %ebp
  801a7c:	c3                   	ret    

00801a7d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a7d:	55                   	push   %ebp
  801a7e:	89 e5                	mov    %esp,%ebp
  801a80:	57                   	push   %edi
  801a81:	56                   	push   %esi
  801a82:	53                   	push   %ebx
  801a83:	83 ec 18             	sub    $0x18,%esp
  801a86:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a89:	57                   	push   %edi
  801a8a:	e8 9c f6 ff ff       	call   80112b <fd2data>
  801a8f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a91:	83 c4 10             	add    $0x10,%esp
  801a94:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a99:	eb 3d                	jmp    801ad8 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a9b:	85 db                	test   %ebx,%ebx
  801a9d:	74 04                	je     801aa3 <devpipe_read+0x26>
				return i;
  801a9f:	89 d8                	mov    %ebx,%eax
  801aa1:	eb 44                	jmp    801ae7 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801aa3:	89 f2                	mov    %esi,%edx
  801aa5:	89 f8                	mov    %edi,%eax
  801aa7:	e8 e5 fe ff ff       	call   801991 <_pipeisclosed>
  801aac:	85 c0                	test   %eax,%eax
  801aae:	75 32                	jne    801ae2 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ab0:	e8 c3 f1 ff ff       	call   800c78 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ab5:	8b 06                	mov    (%esi),%eax
  801ab7:	3b 46 04             	cmp    0x4(%esi),%eax
  801aba:	74 df                	je     801a9b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801abc:	99                   	cltd   
  801abd:	c1 ea 1b             	shr    $0x1b,%edx
  801ac0:	01 d0                	add    %edx,%eax
  801ac2:	83 e0 1f             	and    $0x1f,%eax
  801ac5:	29 d0                	sub    %edx,%eax
  801ac7:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801acc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801acf:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ad2:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ad5:	83 c3 01             	add    $0x1,%ebx
  801ad8:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801adb:	75 d8                	jne    801ab5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801add:	8b 45 10             	mov    0x10(%ebp),%eax
  801ae0:	eb 05                	jmp    801ae7 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ae2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ae7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aea:	5b                   	pop    %ebx
  801aeb:	5e                   	pop    %esi
  801aec:	5f                   	pop    %edi
  801aed:	5d                   	pop    %ebp
  801aee:	c3                   	ret    

00801aef <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801aef:	55                   	push   %ebp
  801af0:	89 e5                	mov    %esp,%ebp
  801af2:	56                   	push   %esi
  801af3:	53                   	push   %ebx
  801af4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801af7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801afa:	50                   	push   %eax
  801afb:	e8 42 f6 ff ff       	call   801142 <fd_alloc>
  801b00:	83 c4 10             	add    $0x10,%esp
  801b03:	89 c2                	mov    %eax,%edx
  801b05:	85 c0                	test   %eax,%eax
  801b07:	0f 88 2c 01 00 00    	js     801c39 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b0d:	83 ec 04             	sub    $0x4,%esp
  801b10:	68 07 04 00 00       	push   $0x407
  801b15:	ff 75 f4             	pushl  -0xc(%ebp)
  801b18:	6a 00                	push   $0x0
  801b1a:	e8 78 f1 ff ff       	call   800c97 <sys_page_alloc>
  801b1f:	83 c4 10             	add    $0x10,%esp
  801b22:	89 c2                	mov    %eax,%edx
  801b24:	85 c0                	test   %eax,%eax
  801b26:	0f 88 0d 01 00 00    	js     801c39 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b2c:	83 ec 0c             	sub    $0xc,%esp
  801b2f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b32:	50                   	push   %eax
  801b33:	e8 0a f6 ff ff       	call   801142 <fd_alloc>
  801b38:	89 c3                	mov    %eax,%ebx
  801b3a:	83 c4 10             	add    $0x10,%esp
  801b3d:	85 c0                	test   %eax,%eax
  801b3f:	0f 88 e2 00 00 00    	js     801c27 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b45:	83 ec 04             	sub    $0x4,%esp
  801b48:	68 07 04 00 00       	push   $0x407
  801b4d:	ff 75 f0             	pushl  -0x10(%ebp)
  801b50:	6a 00                	push   $0x0
  801b52:	e8 40 f1 ff ff       	call   800c97 <sys_page_alloc>
  801b57:	89 c3                	mov    %eax,%ebx
  801b59:	83 c4 10             	add    $0x10,%esp
  801b5c:	85 c0                	test   %eax,%eax
  801b5e:	0f 88 c3 00 00 00    	js     801c27 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b64:	83 ec 0c             	sub    $0xc,%esp
  801b67:	ff 75 f4             	pushl  -0xc(%ebp)
  801b6a:	e8 bc f5 ff ff       	call   80112b <fd2data>
  801b6f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b71:	83 c4 0c             	add    $0xc,%esp
  801b74:	68 07 04 00 00       	push   $0x407
  801b79:	50                   	push   %eax
  801b7a:	6a 00                	push   $0x0
  801b7c:	e8 16 f1 ff ff       	call   800c97 <sys_page_alloc>
  801b81:	89 c3                	mov    %eax,%ebx
  801b83:	83 c4 10             	add    $0x10,%esp
  801b86:	85 c0                	test   %eax,%eax
  801b88:	0f 88 89 00 00 00    	js     801c17 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b8e:	83 ec 0c             	sub    $0xc,%esp
  801b91:	ff 75 f0             	pushl  -0x10(%ebp)
  801b94:	e8 92 f5 ff ff       	call   80112b <fd2data>
  801b99:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ba0:	50                   	push   %eax
  801ba1:	6a 00                	push   $0x0
  801ba3:	56                   	push   %esi
  801ba4:	6a 00                	push   $0x0
  801ba6:	e8 2f f1 ff ff       	call   800cda <sys_page_map>
  801bab:	89 c3                	mov    %eax,%ebx
  801bad:	83 c4 20             	add    $0x20,%esp
  801bb0:	85 c0                	test   %eax,%eax
  801bb2:	78 55                	js     801c09 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bb4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bbd:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bc9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bd2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bd7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bde:	83 ec 0c             	sub    $0xc,%esp
  801be1:	ff 75 f4             	pushl  -0xc(%ebp)
  801be4:	e8 32 f5 ff ff       	call   80111b <fd2num>
  801be9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bec:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bee:	83 c4 04             	add    $0x4,%esp
  801bf1:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf4:	e8 22 f5 ff ff       	call   80111b <fd2num>
  801bf9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bfc:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801bff:	83 c4 10             	add    $0x10,%esp
  801c02:	ba 00 00 00 00       	mov    $0x0,%edx
  801c07:	eb 30                	jmp    801c39 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c09:	83 ec 08             	sub    $0x8,%esp
  801c0c:	56                   	push   %esi
  801c0d:	6a 00                	push   $0x0
  801c0f:	e8 08 f1 ff ff       	call   800d1c <sys_page_unmap>
  801c14:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c17:	83 ec 08             	sub    $0x8,%esp
  801c1a:	ff 75 f0             	pushl  -0x10(%ebp)
  801c1d:	6a 00                	push   $0x0
  801c1f:	e8 f8 f0 ff ff       	call   800d1c <sys_page_unmap>
  801c24:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c27:	83 ec 08             	sub    $0x8,%esp
  801c2a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c2d:	6a 00                	push   $0x0
  801c2f:	e8 e8 f0 ff ff       	call   800d1c <sys_page_unmap>
  801c34:	83 c4 10             	add    $0x10,%esp
  801c37:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c39:	89 d0                	mov    %edx,%eax
  801c3b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c3e:	5b                   	pop    %ebx
  801c3f:	5e                   	pop    %esi
  801c40:	5d                   	pop    %ebp
  801c41:	c3                   	ret    

00801c42 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c48:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c4b:	50                   	push   %eax
  801c4c:	ff 75 08             	pushl  0x8(%ebp)
  801c4f:	e8 3d f5 ff ff       	call   801191 <fd_lookup>
  801c54:	83 c4 10             	add    $0x10,%esp
  801c57:	85 c0                	test   %eax,%eax
  801c59:	78 18                	js     801c73 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c5b:	83 ec 0c             	sub    $0xc,%esp
  801c5e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c61:	e8 c5 f4 ff ff       	call   80112b <fd2data>
	return _pipeisclosed(fd, p);
  801c66:	89 c2                	mov    %eax,%edx
  801c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6b:	e8 21 fd ff ff       	call   801991 <_pipeisclosed>
  801c70:	83 c4 10             	add    $0x10,%esp
}
  801c73:	c9                   	leave  
  801c74:	c3                   	ret    

00801c75 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c75:	55                   	push   %ebp
  801c76:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c78:	b8 00 00 00 00       	mov    $0x0,%eax
  801c7d:	5d                   	pop    %ebp
  801c7e:	c3                   	ret    

00801c7f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c7f:	55                   	push   %ebp
  801c80:	89 e5                	mov    %esp,%ebp
  801c82:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c85:	68 06 28 80 00       	push   $0x802806
  801c8a:	ff 75 0c             	pushl  0xc(%ebp)
  801c8d:	e8 02 ec ff ff       	call   800894 <strcpy>
	return 0;
}
  801c92:	b8 00 00 00 00       	mov    $0x0,%eax
  801c97:	c9                   	leave  
  801c98:	c3                   	ret    

00801c99 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c99:	55                   	push   %ebp
  801c9a:	89 e5                	mov    %esp,%ebp
  801c9c:	57                   	push   %edi
  801c9d:	56                   	push   %esi
  801c9e:	53                   	push   %ebx
  801c9f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ca5:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801caa:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cb0:	eb 2d                	jmp    801cdf <devcons_write+0x46>
		m = n - tot;
  801cb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cb5:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801cb7:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801cba:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801cbf:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cc2:	83 ec 04             	sub    $0x4,%esp
  801cc5:	53                   	push   %ebx
  801cc6:	03 45 0c             	add    0xc(%ebp),%eax
  801cc9:	50                   	push   %eax
  801cca:	57                   	push   %edi
  801ccb:	e8 56 ed ff ff       	call   800a26 <memmove>
		sys_cputs(buf, m);
  801cd0:	83 c4 08             	add    $0x8,%esp
  801cd3:	53                   	push   %ebx
  801cd4:	57                   	push   %edi
  801cd5:	e8 01 ef ff ff       	call   800bdb <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cda:	01 de                	add    %ebx,%esi
  801cdc:	83 c4 10             	add    $0x10,%esp
  801cdf:	89 f0                	mov    %esi,%eax
  801ce1:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ce4:	72 cc                	jb     801cb2 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ce6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ce9:	5b                   	pop    %ebx
  801cea:	5e                   	pop    %esi
  801ceb:	5f                   	pop    %edi
  801cec:	5d                   	pop    %ebp
  801ced:	c3                   	ret    

00801cee <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cee:	55                   	push   %ebp
  801cef:	89 e5                	mov    %esp,%ebp
  801cf1:	83 ec 08             	sub    $0x8,%esp
  801cf4:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801cf9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cfd:	74 2a                	je     801d29 <devcons_read+0x3b>
  801cff:	eb 05                	jmp    801d06 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d01:	e8 72 ef ff ff       	call   800c78 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d06:	e8 ee ee ff ff       	call   800bf9 <sys_cgetc>
  801d0b:	85 c0                	test   %eax,%eax
  801d0d:	74 f2                	je     801d01 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d0f:	85 c0                	test   %eax,%eax
  801d11:	78 16                	js     801d29 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d13:	83 f8 04             	cmp    $0x4,%eax
  801d16:	74 0c                	je     801d24 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d18:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d1b:	88 02                	mov    %al,(%edx)
	return 1;
  801d1d:	b8 01 00 00 00       	mov    $0x1,%eax
  801d22:	eb 05                	jmp    801d29 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d24:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d29:	c9                   	leave  
  801d2a:	c3                   	ret    

00801d2b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d2b:	55                   	push   %ebp
  801d2c:	89 e5                	mov    %esp,%ebp
  801d2e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d31:	8b 45 08             	mov    0x8(%ebp),%eax
  801d34:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d37:	6a 01                	push   $0x1
  801d39:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d3c:	50                   	push   %eax
  801d3d:	e8 99 ee ff ff       	call   800bdb <sys_cputs>
}
  801d42:	83 c4 10             	add    $0x10,%esp
  801d45:	c9                   	leave  
  801d46:	c3                   	ret    

00801d47 <getchar>:

int
getchar(void)
{
  801d47:	55                   	push   %ebp
  801d48:	89 e5                	mov    %esp,%ebp
  801d4a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d4d:	6a 01                	push   $0x1
  801d4f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d52:	50                   	push   %eax
  801d53:	6a 00                	push   $0x0
  801d55:	e8 9d f6 ff ff       	call   8013f7 <read>
	if (r < 0)
  801d5a:	83 c4 10             	add    $0x10,%esp
  801d5d:	85 c0                	test   %eax,%eax
  801d5f:	78 0f                	js     801d70 <getchar+0x29>
		return r;
	if (r < 1)
  801d61:	85 c0                	test   %eax,%eax
  801d63:	7e 06                	jle    801d6b <getchar+0x24>
		return -E_EOF;
	return c;
  801d65:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d69:	eb 05                	jmp    801d70 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d6b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d70:	c9                   	leave  
  801d71:	c3                   	ret    

00801d72 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d72:	55                   	push   %ebp
  801d73:	89 e5                	mov    %esp,%ebp
  801d75:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d7b:	50                   	push   %eax
  801d7c:	ff 75 08             	pushl  0x8(%ebp)
  801d7f:	e8 0d f4 ff ff       	call   801191 <fd_lookup>
  801d84:	83 c4 10             	add    $0x10,%esp
  801d87:	85 c0                	test   %eax,%eax
  801d89:	78 11                	js     801d9c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d8e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d94:	39 10                	cmp    %edx,(%eax)
  801d96:	0f 94 c0             	sete   %al
  801d99:	0f b6 c0             	movzbl %al,%eax
}
  801d9c:	c9                   	leave  
  801d9d:	c3                   	ret    

00801d9e <opencons>:

int
opencons(void)
{
  801d9e:	55                   	push   %ebp
  801d9f:	89 e5                	mov    %esp,%ebp
  801da1:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801da4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da7:	50                   	push   %eax
  801da8:	e8 95 f3 ff ff       	call   801142 <fd_alloc>
  801dad:	83 c4 10             	add    $0x10,%esp
		return r;
  801db0:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801db2:	85 c0                	test   %eax,%eax
  801db4:	78 3e                	js     801df4 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801db6:	83 ec 04             	sub    $0x4,%esp
  801db9:	68 07 04 00 00       	push   $0x407
  801dbe:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc1:	6a 00                	push   $0x0
  801dc3:	e8 cf ee ff ff       	call   800c97 <sys_page_alloc>
  801dc8:	83 c4 10             	add    $0x10,%esp
		return r;
  801dcb:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dcd:	85 c0                	test   %eax,%eax
  801dcf:	78 23                	js     801df4 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801dd1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dda:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ddc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ddf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801de6:	83 ec 0c             	sub    $0xc,%esp
  801de9:	50                   	push   %eax
  801dea:	e8 2c f3 ff ff       	call   80111b <fd2num>
  801def:	89 c2                	mov    %eax,%edx
  801df1:	83 c4 10             	add    $0x10,%esp
}
  801df4:	89 d0                	mov    %edx,%eax
  801df6:	c9                   	leave  
  801df7:	c3                   	ret    

00801df8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801df8:	55                   	push   %ebp
  801df9:	89 e5                	mov    %esp,%ebp
  801dfb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801dfe:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e05:	75 2e                	jne    801e35 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801e07:	e8 4d ee ff ff       	call   800c59 <sys_getenvid>
  801e0c:	83 ec 04             	sub    $0x4,%esp
  801e0f:	68 07 0e 00 00       	push   $0xe07
  801e14:	68 00 f0 bf ee       	push   $0xeebff000
  801e19:	50                   	push   %eax
  801e1a:	e8 78 ee ff ff       	call   800c97 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801e1f:	e8 35 ee ff ff       	call   800c59 <sys_getenvid>
  801e24:	83 c4 08             	add    $0x8,%esp
  801e27:	68 3f 1e 80 00       	push   $0x801e3f
  801e2c:	50                   	push   %eax
  801e2d:	e8 b0 ef ff ff       	call   800de2 <sys_env_set_pgfault_upcall>
  801e32:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e35:	8b 45 08             	mov    0x8(%ebp),%eax
  801e38:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e3d:	c9                   	leave  
  801e3e:	c3                   	ret    

00801e3f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e3f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e40:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e45:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e47:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  801e4a:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  801e4e:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  801e52:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  801e55:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  801e58:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  801e59:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  801e5c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  801e5d:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  801e5e:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801e62:	c3                   	ret    

00801e63 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e63:	55                   	push   %ebp
  801e64:	89 e5                	mov    %esp,%ebp
  801e66:	56                   	push   %esi
  801e67:	53                   	push   %ebx
  801e68:	8b 75 08             	mov    0x8(%ebp),%esi
  801e6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801e71:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801e73:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801e78:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801e7b:	83 ec 0c             	sub    $0xc,%esp
  801e7e:	50                   	push   %eax
  801e7f:	e8 c3 ef ff ff       	call   800e47 <sys_ipc_recv>

	if (from_env_store != NULL)
  801e84:	83 c4 10             	add    $0x10,%esp
  801e87:	85 f6                	test   %esi,%esi
  801e89:	74 14                	je     801e9f <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801e8b:	ba 00 00 00 00       	mov    $0x0,%edx
  801e90:	85 c0                	test   %eax,%eax
  801e92:	78 09                	js     801e9d <ipc_recv+0x3a>
  801e94:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801e9a:	8b 52 74             	mov    0x74(%edx),%edx
  801e9d:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801e9f:	85 db                	test   %ebx,%ebx
  801ea1:	74 14                	je     801eb7 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801ea3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ea8:	85 c0                	test   %eax,%eax
  801eaa:	78 09                	js     801eb5 <ipc_recv+0x52>
  801eac:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801eb2:	8b 52 78             	mov    0x78(%edx),%edx
  801eb5:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801eb7:	85 c0                	test   %eax,%eax
  801eb9:	78 08                	js     801ec3 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801ebb:	a1 04 40 80 00       	mov    0x804004,%eax
  801ec0:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ec3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ec6:	5b                   	pop    %ebx
  801ec7:	5e                   	pop    %esi
  801ec8:	5d                   	pop    %ebp
  801ec9:	c3                   	ret    

00801eca <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801eca:	55                   	push   %ebp
  801ecb:	89 e5                	mov    %esp,%ebp
  801ecd:	57                   	push   %edi
  801ece:	56                   	push   %esi
  801ecf:	53                   	push   %ebx
  801ed0:	83 ec 0c             	sub    $0xc,%esp
  801ed3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ed6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ed9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801edc:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801ede:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ee3:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801ee6:	ff 75 14             	pushl  0x14(%ebp)
  801ee9:	53                   	push   %ebx
  801eea:	56                   	push   %esi
  801eeb:	57                   	push   %edi
  801eec:	e8 33 ef ff ff       	call   800e24 <sys_ipc_try_send>

		if (err < 0) {
  801ef1:	83 c4 10             	add    $0x10,%esp
  801ef4:	85 c0                	test   %eax,%eax
  801ef6:	79 1e                	jns    801f16 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801ef8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801efb:	75 07                	jne    801f04 <ipc_send+0x3a>
				sys_yield();
  801efd:	e8 76 ed ff ff       	call   800c78 <sys_yield>
  801f02:	eb e2                	jmp    801ee6 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f04:	50                   	push   %eax
  801f05:	68 12 28 80 00       	push   $0x802812
  801f0a:	6a 49                	push   $0x49
  801f0c:	68 1f 28 80 00       	push   $0x80281f
  801f11:	e8 20 e3 ff ff       	call   800236 <_panic>
		}

	} while (err < 0);

}
  801f16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f19:	5b                   	pop    %ebx
  801f1a:	5e                   	pop    %esi
  801f1b:	5f                   	pop    %edi
  801f1c:	5d                   	pop    %ebp
  801f1d:	c3                   	ret    

00801f1e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f1e:	55                   	push   %ebp
  801f1f:	89 e5                	mov    %esp,%ebp
  801f21:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f24:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f29:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f2c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f32:	8b 52 50             	mov    0x50(%edx),%edx
  801f35:	39 ca                	cmp    %ecx,%edx
  801f37:	75 0d                	jne    801f46 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f39:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f3c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f41:	8b 40 48             	mov    0x48(%eax),%eax
  801f44:	eb 0f                	jmp    801f55 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f46:	83 c0 01             	add    $0x1,%eax
  801f49:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f4e:	75 d9                	jne    801f29 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f55:	5d                   	pop    %ebp
  801f56:	c3                   	ret    

00801f57 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f57:	55                   	push   %ebp
  801f58:	89 e5                	mov    %esp,%ebp
  801f5a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f5d:	89 d0                	mov    %edx,%eax
  801f5f:	c1 e8 16             	shr    $0x16,%eax
  801f62:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f69:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f6e:	f6 c1 01             	test   $0x1,%cl
  801f71:	74 1d                	je     801f90 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f73:	c1 ea 0c             	shr    $0xc,%edx
  801f76:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f7d:	f6 c2 01             	test   $0x1,%dl
  801f80:	74 0e                	je     801f90 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f82:	c1 ea 0c             	shr    $0xc,%edx
  801f85:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f8c:	ef 
  801f8d:	0f b7 c0             	movzwl %ax,%eax
}
  801f90:	5d                   	pop    %ebp
  801f91:	c3                   	ret    
  801f92:	66 90                	xchg   %ax,%ax
  801f94:	66 90                	xchg   %ax,%ax
  801f96:	66 90                	xchg   %ax,%ax
  801f98:	66 90                	xchg   %ax,%ax
  801f9a:	66 90                	xchg   %ax,%ax
  801f9c:	66 90                	xchg   %ax,%ax
  801f9e:	66 90                	xchg   %ax,%ax

00801fa0 <__udivdi3>:
  801fa0:	55                   	push   %ebp
  801fa1:	57                   	push   %edi
  801fa2:	56                   	push   %esi
  801fa3:	53                   	push   %ebx
  801fa4:	83 ec 1c             	sub    $0x1c,%esp
  801fa7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801faf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fb7:	85 f6                	test   %esi,%esi
  801fb9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fbd:	89 ca                	mov    %ecx,%edx
  801fbf:	89 f8                	mov    %edi,%eax
  801fc1:	75 3d                	jne    802000 <__udivdi3+0x60>
  801fc3:	39 cf                	cmp    %ecx,%edi
  801fc5:	0f 87 c5 00 00 00    	ja     802090 <__udivdi3+0xf0>
  801fcb:	85 ff                	test   %edi,%edi
  801fcd:	89 fd                	mov    %edi,%ebp
  801fcf:	75 0b                	jne    801fdc <__udivdi3+0x3c>
  801fd1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fd6:	31 d2                	xor    %edx,%edx
  801fd8:	f7 f7                	div    %edi
  801fda:	89 c5                	mov    %eax,%ebp
  801fdc:	89 c8                	mov    %ecx,%eax
  801fde:	31 d2                	xor    %edx,%edx
  801fe0:	f7 f5                	div    %ebp
  801fe2:	89 c1                	mov    %eax,%ecx
  801fe4:	89 d8                	mov    %ebx,%eax
  801fe6:	89 cf                	mov    %ecx,%edi
  801fe8:	f7 f5                	div    %ebp
  801fea:	89 c3                	mov    %eax,%ebx
  801fec:	89 d8                	mov    %ebx,%eax
  801fee:	89 fa                	mov    %edi,%edx
  801ff0:	83 c4 1c             	add    $0x1c,%esp
  801ff3:	5b                   	pop    %ebx
  801ff4:	5e                   	pop    %esi
  801ff5:	5f                   	pop    %edi
  801ff6:	5d                   	pop    %ebp
  801ff7:	c3                   	ret    
  801ff8:	90                   	nop
  801ff9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802000:	39 ce                	cmp    %ecx,%esi
  802002:	77 74                	ja     802078 <__udivdi3+0xd8>
  802004:	0f bd fe             	bsr    %esi,%edi
  802007:	83 f7 1f             	xor    $0x1f,%edi
  80200a:	0f 84 98 00 00 00    	je     8020a8 <__udivdi3+0x108>
  802010:	bb 20 00 00 00       	mov    $0x20,%ebx
  802015:	89 f9                	mov    %edi,%ecx
  802017:	89 c5                	mov    %eax,%ebp
  802019:	29 fb                	sub    %edi,%ebx
  80201b:	d3 e6                	shl    %cl,%esi
  80201d:	89 d9                	mov    %ebx,%ecx
  80201f:	d3 ed                	shr    %cl,%ebp
  802021:	89 f9                	mov    %edi,%ecx
  802023:	d3 e0                	shl    %cl,%eax
  802025:	09 ee                	or     %ebp,%esi
  802027:	89 d9                	mov    %ebx,%ecx
  802029:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80202d:	89 d5                	mov    %edx,%ebp
  80202f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802033:	d3 ed                	shr    %cl,%ebp
  802035:	89 f9                	mov    %edi,%ecx
  802037:	d3 e2                	shl    %cl,%edx
  802039:	89 d9                	mov    %ebx,%ecx
  80203b:	d3 e8                	shr    %cl,%eax
  80203d:	09 c2                	or     %eax,%edx
  80203f:	89 d0                	mov    %edx,%eax
  802041:	89 ea                	mov    %ebp,%edx
  802043:	f7 f6                	div    %esi
  802045:	89 d5                	mov    %edx,%ebp
  802047:	89 c3                	mov    %eax,%ebx
  802049:	f7 64 24 0c          	mull   0xc(%esp)
  80204d:	39 d5                	cmp    %edx,%ebp
  80204f:	72 10                	jb     802061 <__udivdi3+0xc1>
  802051:	8b 74 24 08          	mov    0x8(%esp),%esi
  802055:	89 f9                	mov    %edi,%ecx
  802057:	d3 e6                	shl    %cl,%esi
  802059:	39 c6                	cmp    %eax,%esi
  80205b:	73 07                	jae    802064 <__udivdi3+0xc4>
  80205d:	39 d5                	cmp    %edx,%ebp
  80205f:	75 03                	jne    802064 <__udivdi3+0xc4>
  802061:	83 eb 01             	sub    $0x1,%ebx
  802064:	31 ff                	xor    %edi,%edi
  802066:	89 d8                	mov    %ebx,%eax
  802068:	89 fa                	mov    %edi,%edx
  80206a:	83 c4 1c             	add    $0x1c,%esp
  80206d:	5b                   	pop    %ebx
  80206e:	5e                   	pop    %esi
  80206f:	5f                   	pop    %edi
  802070:	5d                   	pop    %ebp
  802071:	c3                   	ret    
  802072:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802078:	31 ff                	xor    %edi,%edi
  80207a:	31 db                	xor    %ebx,%ebx
  80207c:	89 d8                	mov    %ebx,%eax
  80207e:	89 fa                	mov    %edi,%edx
  802080:	83 c4 1c             	add    $0x1c,%esp
  802083:	5b                   	pop    %ebx
  802084:	5e                   	pop    %esi
  802085:	5f                   	pop    %edi
  802086:	5d                   	pop    %ebp
  802087:	c3                   	ret    
  802088:	90                   	nop
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	89 d8                	mov    %ebx,%eax
  802092:	f7 f7                	div    %edi
  802094:	31 ff                	xor    %edi,%edi
  802096:	89 c3                	mov    %eax,%ebx
  802098:	89 d8                	mov    %ebx,%eax
  80209a:	89 fa                	mov    %edi,%edx
  80209c:	83 c4 1c             	add    $0x1c,%esp
  80209f:	5b                   	pop    %ebx
  8020a0:	5e                   	pop    %esi
  8020a1:	5f                   	pop    %edi
  8020a2:	5d                   	pop    %ebp
  8020a3:	c3                   	ret    
  8020a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020a8:	39 ce                	cmp    %ecx,%esi
  8020aa:	72 0c                	jb     8020b8 <__udivdi3+0x118>
  8020ac:	31 db                	xor    %ebx,%ebx
  8020ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020b2:	0f 87 34 ff ff ff    	ja     801fec <__udivdi3+0x4c>
  8020b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020bd:	e9 2a ff ff ff       	jmp    801fec <__udivdi3+0x4c>
  8020c2:	66 90                	xchg   %ax,%ax
  8020c4:	66 90                	xchg   %ax,%ax
  8020c6:	66 90                	xchg   %ax,%ax
  8020c8:	66 90                	xchg   %ax,%ax
  8020ca:	66 90                	xchg   %ax,%ax
  8020cc:	66 90                	xchg   %ax,%ax
  8020ce:	66 90                	xchg   %ax,%ax

008020d0 <__umoddi3>:
  8020d0:	55                   	push   %ebp
  8020d1:	57                   	push   %edi
  8020d2:	56                   	push   %esi
  8020d3:	53                   	push   %ebx
  8020d4:	83 ec 1c             	sub    $0x1c,%esp
  8020d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020e7:	85 d2                	test   %edx,%edx
  8020e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020f1:	89 f3                	mov    %esi,%ebx
  8020f3:	89 3c 24             	mov    %edi,(%esp)
  8020f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020fa:	75 1c                	jne    802118 <__umoddi3+0x48>
  8020fc:	39 f7                	cmp    %esi,%edi
  8020fe:	76 50                	jbe    802150 <__umoddi3+0x80>
  802100:	89 c8                	mov    %ecx,%eax
  802102:	89 f2                	mov    %esi,%edx
  802104:	f7 f7                	div    %edi
  802106:	89 d0                	mov    %edx,%eax
  802108:	31 d2                	xor    %edx,%edx
  80210a:	83 c4 1c             	add    $0x1c,%esp
  80210d:	5b                   	pop    %ebx
  80210e:	5e                   	pop    %esi
  80210f:	5f                   	pop    %edi
  802110:	5d                   	pop    %ebp
  802111:	c3                   	ret    
  802112:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802118:	39 f2                	cmp    %esi,%edx
  80211a:	89 d0                	mov    %edx,%eax
  80211c:	77 52                	ja     802170 <__umoddi3+0xa0>
  80211e:	0f bd ea             	bsr    %edx,%ebp
  802121:	83 f5 1f             	xor    $0x1f,%ebp
  802124:	75 5a                	jne    802180 <__umoddi3+0xb0>
  802126:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80212a:	0f 82 e0 00 00 00    	jb     802210 <__umoddi3+0x140>
  802130:	39 0c 24             	cmp    %ecx,(%esp)
  802133:	0f 86 d7 00 00 00    	jbe    802210 <__umoddi3+0x140>
  802139:	8b 44 24 08          	mov    0x8(%esp),%eax
  80213d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802141:	83 c4 1c             	add    $0x1c,%esp
  802144:	5b                   	pop    %ebx
  802145:	5e                   	pop    %esi
  802146:	5f                   	pop    %edi
  802147:	5d                   	pop    %ebp
  802148:	c3                   	ret    
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802150:	85 ff                	test   %edi,%edi
  802152:	89 fd                	mov    %edi,%ebp
  802154:	75 0b                	jne    802161 <__umoddi3+0x91>
  802156:	b8 01 00 00 00       	mov    $0x1,%eax
  80215b:	31 d2                	xor    %edx,%edx
  80215d:	f7 f7                	div    %edi
  80215f:	89 c5                	mov    %eax,%ebp
  802161:	89 f0                	mov    %esi,%eax
  802163:	31 d2                	xor    %edx,%edx
  802165:	f7 f5                	div    %ebp
  802167:	89 c8                	mov    %ecx,%eax
  802169:	f7 f5                	div    %ebp
  80216b:	89 d0                	mov    %edx,%eax
  80216d:	eb 99                	jmp    802108 <__umoddi3+0x38>
  80216f:	90                   	nop
  802170:	89 c8                	mov    %ecx,%eax
  802172:	89 f2                	mov    %esi,%edx
  802174:	83 c4 1c             	add    $0x1c,%esp
  802177:	5b                   	pop    %ebx
  802178:	5e                   	pop    %esi
  802179:	5f                   	pop    %edi
  80217a:	5d                   	pop    %ebp
  80217b:	c3                   	ret    
  80217c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802180:	8b 34 24             	mov    (%esp),%esi
  802183:	bf 20 00 00 00       	mov    $0x20,%edi
  802188:	89 e9                	mov    %ebp,%ecx
  80218a:	29 ef                	sub    %ebp,%edi
  80218c:	d3 e0                	shl    %cl,%eax
  80218e:	89 f9                	mov    %edi,%ecx
  802190:	89 f2                	mov    %esi,%edx
  802192:	d3 ea                	shr    %cl,%edx
  802194:	89 e9                	mov    %ebp,%ecx
  802196:	09 c2                	or     %eax,%edx
  802198:	89 d8                	mov    %ebx,%eax
  80219a:	89 14 24             	mov    %edx,(%esp)
  80219d:	89 f2                	mov    %esi,%edx
  80219f:	d3 e2                	shl    %cl,%edx
  8021a1:	89 f9                	mov    %edi,%ecx
  8021a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021ab:	d3 e8                	shr    %cl,%eax
  8021ad:	89 e9                	mov    %ebp,%ecx
  8021af:	89 c6                	mov    %eax,%esi
  8021b1:	d3 e3                	shl    %cl,%ebx
  8021b3:	89 f9                	mov    %edi,%ecx
  8021b5:	89 d0                	mov    %edx,%eax
  8021b7:	d3 e8                	shr    %cl,%eax
  8021b9:	89 e9                	mov    %ebp,%ecx
  8021bb:	09 d8                	or     %ebx,%eax
  8021bd:	89 d3                	mov    %edx,%ebx
  8021bf:	89 f2                	mov    %esi,%edx
  8021c1:	f7 34 24             	divl   (%esp)
  8021c4:	89 d6                	mov    %edx,%esi
  8021c6:	d3 e3                	shl    %cl,%ebx
  8021c8:	f7 64 24 04          	mull   0x4(%esp)
  8021cc:	39 d6                	cmp    %edx,%esi
  8021ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021d2:	89 d1                	mov    %edx,%ecx
  8021d4:	89 c3                	mov    %eax,%ebx
  8021d6:	72 08                	jb     8021e0 <__umoddi3+0x110>
  8021d8:	75 11                	jne    8021eb <__umoddi3+0x11b>
  8021da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021de:	73 0b                	jae    8021eb <__umoddi3+0x11b>
  8021e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021e4:	1b 14 24             	sbb    (%esp),%edx
  8021e7:	89 d1                	mov    %edx,%ecx
  8021e9:	89 c3                	mov    %eax,%ebx
  8021eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021ef:	29 da                	sub    %ebx,%edx
  8021f1:	19 ce                	sbb    %ecx,%esi
  8021f3:	89 f9                	mov    %edi,%ecx
  8021f5:	89 f0                	mov    %esi,%eax
  8021f7:	d3 e0                	shl    %cl,%eax
  8021f9:	89 e9                	mov    %ebp,%ecx
  8021fb:	d3 ea                	shr    %cl,%edx
  8021fd:	89 e9                	mov    %ebp,%ecx
  8021ff:	d3 ee                	shr    %cl,%esi
  802201:	09 d0                	or     %edx,%eax
  802203:	89 f2                	mov    %esi,%edx
  802205:	83 c4 1c             	add    $0x1c,%esp
  802208:	5b                   	pop    %ebx
  802209:	5e                   	pop    %esi
  80220a:	5f                   	pop    %edi
  80220b:	5d                   	pop    %ebp
  80220c:	c3                   	ret    
  80220d:	8d 76 00             	lea    0x0(%esi),%esi
  802210:	29 f9                	sub    %edi,%ecx
  802212:	19 d6                	sbb    %edx,%esi
  802214:	89 74 24 04          	mov    %esi,0x4(%esp)
  802218:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80221c:	e9 18 ff ff ff       	jmp    802139 <__umoddi3+0x69>
