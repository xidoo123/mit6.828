
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 87 01 00 00       	call   8001b8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 14             	sub    $0x14,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003c:	6a 00                	push   $0x0
  80003e:	68 e0 26 80 00       	push   $0x8026e0
  800043:	e8 2b 18 00 00       	call   801873 <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 e5 26 80 00       	push   $0x8026e5
  800057:	6a 0c                	push   $0xc
  800059:	68 f3 26 80 00       	push   $0x8026f3
  80005e:	e8 b5 01 00 00       	call   800218 <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 ed 14 00 00       	call   80155b <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 20 42 80 00       	push   $0x804220
  80007b:	53                   	push   %ebx
  80007c:	e8 05 14 00 00       	call   801486 <readn>
  800081:	89 c6                	mov    %eax,%esi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 08 27 80 00       	push   $0x802708
  800090:	6a 0f                	push   $0xf
  800092:	68 f3 26 80 00       	push   $0x8026f3
  800097:	e8 7c 01 00 00       	call   800218 <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 c1 0e 00 00       	call   800f62 <fork>
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 12 27 80 00       	push   $0x802712
  8000ad:	6a 12                	push   $0x12
  8000af:	68 f3 26 80 00       	push   $0x8026f3
  8000b4:	e8 5f 01 00 00       	call   800218 <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 8f 14 00 00       	call   80155b <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 50 27 80 00 	movl   $0x802750,(%esp)
  8000d3:	e8 19 02 00 00       	call   8002f1 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 20 40 80 00       	push   $0x804020
  8000e5:	53                   	push   %ebx
  8000e6:	e8 9b 13 00 00       	call   801486 <readn>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	39 c6                	cmp    %eax,%esi
  8000f0:	74 16                	je     800108 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	56                   	push   %esi
  8000f7:	68 94 27 80 00       	push   $0x802794
  8000fc:	6a 17                	push   $0x17
  8000fe:	68 f3 26 80 00       	push   $0x8026f3
  800103:	e8 10 01 00 00       	call   800218 <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800108:	83 ec 04             	sub    $0x4,%esp
  80010b:	56                   	push   %esi
  80010c:	68 20 40 80 00       	push   $0x804020
  800111:	68 20 42 80 00       	push   $0x804220
  800116:	e8 68 09 00 00       	call   800a83 <memcmp>
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	85 c0                	test   %eax,%eax
  800120:	74 14                	je     800136 <umain+0x103>
			panic("read in parent got different bytes from read in child");
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	68 c0 27 80 00       	push   $0x8027c0
  80012a:	6a 19                	push   $0x19
  80012c:	68 f3 26 80 00       	push   $0x8026f3
  800131:	e8 e2 00 00 00       	call   800218 <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 1b 27 80 00       	push   $0x80271b
  80013e:	e8 ae 01 00 00       	call   8002f1 <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 0d 14 00 00       	call   80155b <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 63 11 00 00       	call   8012b9 <close>
		exit();
  800156:	e8 a3 00 00 00       	call   8001fe <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	57                   	push   %edi
  800162:	e8 0c 1b 00 00       	call   801c73 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 20 40 80 00       	push   $0x804020
  800174:	53                   	push   %ebx
  800175:	e8 0c 13 00 00       	call   801486 <readn>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	39 c6                	cmp    %eax,%esi
  80017f:	74 16                	je     800197 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	56                   	push   %esi
  800186:	68 f8 27 80 00       	push   $0x8027f8
  80018b:	6a 21                	push   $0x21
  80018d:	68 f3 26 80 00       	push   $0x8026f3
  800192:	e8 81 00 00 00       	call   800218 <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 34 27 80 00       	push   $0x802734
  80019f:	e8 4d 01 00 00       	call   8002f1 <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 0d 11 00 00       	call   8012b9 <close>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8001ac:	cc                   	int3   

	breakpoint();
}
  8001ad:	83 c4 10             	add    $0x10,%esp
  8001b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b3:	5b                   	pop    %ebx
  8001b4:	5e                   	pop    %esi
  8001b5:	5f                   	pop    %edi
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001c0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001c3:	e8 73 0a 00 00       	call   800c3b <sys_getenvid>
  8001c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001cd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001d5:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001da:	85 db                	test   %ebx,%ebx
  8001dc:	7e 07                	jle    8001e5 <libmain+0x2d>
		binaryname = argv[0];
  8001de:	8b 06                	mov    (%esi),%eax
  8001e0:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001e5:	83 ec 08             	sub    $0x8,%esp
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	e8 44 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001ef:	e8 0a 00 00 00       	call   8001fe <exit>
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001fa:	5b                   	pop    %ebx
  8001fb:	5e                   	pop    %esi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    

008001fe <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800204:	e8 db 10 00 00       	call   8012e4 <close_all>
	sys_env_destroy(0);
  800209:	83 ec 0c             	sub    $0xc,%esp
  80020c:	6a 00                	push   $0x0
  80020e:	e8 e7 09 00 00       	call   800bfa <sys_env_destroy>
}
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80021d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800220:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800226:	e8 10 0a 00 00       	call   800c3b <sys_getenvid>
  80022b:	83 ec 0c             	sub    $0xc,%esp
  80022e:	ff 75 0c             	pushl  0xc(%ebp)
  800231:	ff 75 08             	pushl  0x8(%ebp)
  800234:	56                   	push   %esi
  800235:	50                   	push   %eax
  800236:	68 28 28 80 00       	push   $0x802828
  80023b:	e8 b1 00 00 00       	call   8002f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800240:	83 c4 18             	add    $0x18,%esp
  800243:	53                   	push   %ebx
  800244:	ff 75 10             	pushl  0x10(%ebp)
  800247:	e8 54 00 00 00       	call   8002a0 <vcprintf>
	cprintf("\n");
  80024c:	c7 04 24 32 27 80 00 	movl   $0x802732,(%esp)
  800253:	e8 99 00 00 00       	call   8002f1 <cprintf>
  800258:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80025b:	cc                   	int3   
  80025c:	eb fd                	jmp    80025b <_panic+0x43>

0080025e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	53                   	push   %ebx
  800262:	83 ec 04             	sub    $0x4,%esp
  800265:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800268:	8b 13                	mov    (%ebx),%edx
  80026a:	8d 42 01             	lea    0x1(%edx),%eax
  80026d:	89 03                	mov    %eax,(%ebx)
  80026f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800272:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800276:	3d ff 00 00 00       	cmp    $0xff,%eax
  80027b:	75 1a                	jne    800297 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	68 ff 00 00 00       	push   $0xff
  800285:	8d 43 08             	lea    0x8(%ebx),%eax
  800288:	50                   	push   %eax
  800289:	e8 2f 09 00 00       	call   800bbd <sys_cputs>
		b->idx = 0;
  80028e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800294:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800297:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80029b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002b0:	00 00 00 
	b.cnt = 0;
  8002b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002bd:	ff 75 0c             	pushl  0xc(%ebp)
  8002c0:	ff 75 08             	pushl  0x8(%ebp)
  8002c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002c9:	50                   	push   %eax
  8002ca:	68 5e 02 80 00       	push   $0x80025e
  8002cf:	e8 54 01 00 00       	call   800428 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002d4:	83 c4 08             	add    $0x8,%esp
  8002d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	e8 d4 08 00 00       	call   800bbd <sys_cputs>

	return b.cnt;
}
  8002e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ef:	c9                   	leave  
  8002f0:	c3                   	ret    

008002f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002fa:	50                   	push   %eax
  8002fb:	ff 75 08             	pushl  0x8(%ebp)
  8002fe:	e8 9d ff ff ff       	call   8002a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800303:	c9                   	leave  
  800304:	c3                   	ret    

00800305 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 1c             	sub    $0x1c,%esp
  80030e:	89 c7                	mov    %eax,%edi
  800310:	89 d6                	mov    %edx,%esi
  800312:	8b 45 08             	mov    0x8(%ebp),%eax
  800315:	8b 55 0c             	mov    0xc(%ebp),%edx
  800318:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80031b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80031e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800321:	bb 00 00 00 00       	mov    $0x0,%ebx
  800326:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800329:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80032c:	39 d3                	cmp    %edx,%ebx
  80032e:	72 05                	jb     800335 <printnum+0x30>
  800330:	39 45 10             	cmp    %eax,0x10(%ebp)
  800333:	77 45                	ja     80037a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	ff 75 18             	pushl  0x18(%ebp)
  80033b:	8b 45 14             	mov    0x14(%ebp),%eax
  80033e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800341:	53                   	push   %ebx
  800342:	ff 75 10             	pushl  0x10(%ebp)
  800345:	83 ec 08             	sub    $0x8,%esp
  800348:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034b:	ff 75 e0             	pushl  -0x20(%ebp)
  80034e:	ff 75 dc             	pushl  -0x24(%ebp)
  800351:	ff 75 d8             	pushl  -0x28(%ebp)
  800354:	e8 f7 20 00 00       	call   802450 <__udivdi3>
  800359:	83 c4 18             	add    $0x18,%esp
  80035c:	52                   	push   %edx
  80035d:	50                   	push   %eax
  80035e:	89 f2                	mov    %esi,%edx
  800360:	89 f8                	mov    %edi,%eax
  800362:	e8 9e ff ff ff       	call   800305 <printnum>
  800367:	83 c4 20             	add    $0x20,%esp
  80036a:	eb 18                	jmp    800384 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80036c:	83 ec 08             	sub    $0x8,%esp
  80036f:	56                   	push   %esi
  800370:	ff 75 18             	pushl  0x18(%ebp)
  800373:	ff d7                	call   *%edi
  800375:	83 c4 10             	add    $0x10,%esp
  800378:	eb 03                	jmp    80037d <printnum+0x78>
  80037a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80037d:	83 eb 01             	sub    $0x1,%ebx
  800380:	85 db                	test   %ebx,%ebx
  800382:	7f e8                	jg     80036c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800384:	83 ec 08             	sub    $0x8,%esp
  800387:	56                   	push   %esi
  800388:	83 ec 04             	sub    $0x4,%esp
  80038b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80038e:	ff 75 e0             	pushl  -0x20(%ebp)
  800391:	ff 75 dc             	pushl  -0x24(%ebp)
  800394:	ff 75 d8             	pushl  -0x28(%ebp)
  800397:	e8 e4 21 00 00       	call   802580 <__umoddi3>
  80039c:	83 c4 14             	add    $0x14,%esp
  80039f:	0f be 80 4b 28 80 00 	movsbl 0x80284b(%eax),%eax
  8003a6:	50                   	push   %eax
  8003a7:	ff d7                	call   *%edi
}
  8003a9:	83 c4 10             	add    $0x10,%esp
  8003ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003af:	5b                   	pop    %ebx
  8003b0:	5e                   	pop    %esi
  8003b1:	5f                   	pop    %edi
  8003b2:	5d                   	pop    %ebp
  8003b3:	c3                   	ret    

008003b4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b7:	83 fa 01             	cmp    $0x1,%edx
  8003ba:	7e 0e                	jle    8003ca <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003bc:	8b 10                	mov    (%eax),%edx
  8003be:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003c1:	89 08                	mov    %ecx,(%eax)
  8003c3:	8b 02                	mov    (%edx),%eax
  8003c5:	8b 52 04             	mov    0x4(%edx),%edx
  8003c8:	eb 22                	jmp    8003ec <getuint+0x38>
	else if (lflag)
  8003ca:	85 d2                	test   %edx,%edx
  8003cc:	74 10                	je     8003de <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ce:	8b 10                	mov    (%eax),%edx
  8003d0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d3:	89 08                	mov    %ecx,(%eax)
  8003d5:	8b 02                	mov    (%edx),%eax
  8003d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003dc:	eb 0e                	jmp    8003ec <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003de:	8b 10                	mov    (%eax),%edx
  8003e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e3:	89 08                	mov    %ecx,(%eax)
  8003e5:	8b 02                	mov    (%edx),%eax
  8003e7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ec:	5d                   	pop    %ebp
  8003ed:	c3                   	ret    

008003ee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f8:	8b 10                	mov    (%eax),%edx
  8003fa:	3b 50 04             	cmp    0x4(%eax),%edx
  8003fd:	73 0a                	jae    800409 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ff:	8d 4a 01             	lea    0x1(%edx),%ecx
  800402:	89 08                	mov    %ecx,(%eax)
  800404:	8b 45 08             	mov    0x8(%ebp),%eax
  800407:	88 02                	mov    %al,(%edx)
}
  800409:	5d                   	pop    %ebp
  80040a:	c3                   	ret    

0080040b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80040b:	55                   	push   %ebp
  80040c:	89 e5                	mov    %esp,%ebp
  80040e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800411:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800414:	50                   	push   %eax
  800415:	ff 75 10             	pushl  0x10(%ebp)
  800418:	ff 75 0c             	pushl  0xc(%ebp)
  80041b:	ff 75 08             	pushl  0x8(%ebp)
  80041e:	e8 05 00 00 00       	call   800428 <vprintfmt>
	va_end(ap);
}
  800423:	83 c4 10             	add    $0x10,%esp
  800426:	c9                   	leave  
  800427:	c3                   	ret    

00800428 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	57                   	push   %edi
  80042c:	56                   	push   %esi
  80042d:	53                   	push   %ebx
  80042e:	83 ec 2c             	sub    $0x2c,%esp
  800431:	8b 75 08             	mov    0x8(%ebp),%esi
  800434:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800437:	8b 7d 10             	mov    0x10(%ebp),%edi
  80043a:	eb 12                	jmp    80044e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80043c:	85 c0                	test   %eax,%eax
  80043e:	0f 84 89 03 00 00    	je     8007cd <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800444:	83 ec 08             	sub    $0x8,%esp
  800447:	53                   	push   %ebx
  800448:	50                   	push   %eax
  800449:	ff d6                	call   *%esi
  80044b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80044e:	83 c7 01             	add    $0x1,%edi
  800451:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800455:	83 f8 25             	cmp    $0x25,%eax
  800458:	75 e2                	jne    80043c <vprintfmt+0x14>
  80045a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80045e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800465:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80046c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800473:	ba 00 00 00 00       	mov    $0x0,%edx
  800478:	eb 07                	jmp    800481 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80047d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8d 47 01             	lea    0x1(%edi),%eax
  800484:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800487:	0f b6 07             	movzbl (%edi),%eax
  80048a:	0f b6 c8             	movzbl %al,%ecx
  80048d:	83 e8 23             	sub    $0x23,%eax
  800490:	3c 55                	cmp    $0x55,%al
  800492:	0f 87 1a 03 00 00    	ja     8007b2 <vprintfmt+0x38a>
  800498:	0f b6 c0             	movzbl %al,%eax
  80049b:	ff 24 85 80 29 80 00 	jmp    *0x802980(,%eax,4)
  8004a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004a5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004a9:	eb d6                	jmp    800481 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004b6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004b9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004bd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004c0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004c3:	83 fa 09             	cmp    $0x9,%edx
  8004c6:	77 39                	ja     800501 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004cb:	eb e9                	jmp    8004b6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d0:	8d 48 04             	lea    0x4(%eax),%ecx
  8004d3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004d6:	8b 00                	mov    (%eax),%eax
  8004d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004de:	eb 27                	jmp    800507 <vprintfmt+0xdf>
  8004e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e3:	85 c0                	test   %eax,%eax
  8004e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004ea:	0f 49 c8             	cmovns %eax,%ecx
  8004ed:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f3:	eb 8c                	jmp    800481 <vprintfmt+0x59>
  8004f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004f8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004ff:	eb 80                	jmp    800481 <vprintfmt+0x59>
  800501:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800504:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800507:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80050b:	0f 89 70 ff ff ff    	jns    800481 <vprintfmt+0x59>
				width = precision, precision = -1;
  800511:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800514:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800517:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80051e:	e9 5e ff ff ff       	jmp    800481 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800523:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800529:	e9 53 ff ff ff       	jmp    800481 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8d 50 04             	lea    0x4(%eax),%edx
  800534:	89 55 14             	mov    %edx,0x14(%ebp)
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	53                   	push   %ebx
  80053b:	ff 30                	pushl  (%eax)
  80053d:	ff d6                	call   *%esi
			break;
  80053f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800542:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800545:	e9 04 ff ff ff       	jmp    80044e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80054a:	8b 45 14             	mov    0x14(%ebp),%eax
  80054d:	8d 50 04             	lea    0x4(%eax),%edx
  800550:	89 55 14             	mov    %edx,0x14(%ebp)
  800553:	8b 00                	mov    (%eax),%eax
  800555:	99                   	cltd   
  800556:	31 d0                	xor    %edx,%eax
  800558:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80055a:	83 f8 0f             	cmp    $0xf,%eax
  80055d:	7f 0b                	jg     80056a <vprintfmt+0x142>
  80055f:	8b 14 85 e0 2a 80 00 	mov    0x802ae0(,%eax,4),%edx
  800566:	85 d2                	test   %edx,%edx
  800568:	75 18                	jne    800582 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80056a:	50                   	push   %eax
  80056b:	68 63 28 80 00       	push   $0x802863
  800570:	53                   	push   %ebx
  800571:	56                   	push   %esi
  800572:	e8 94 fe ff ff       	call   80040b <printfmt>
  800577:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80057d:	e9 cc fe ff ff       	jmp    80044e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800582:	52                   	push   %edx
  800583:	68 d1 2c 80 00       	push   $0x802cd1
  800588:	53                   	push   %ebx
  800589:	56                   	push   %esi
  80058a:	e8 7c fe ff ff       	call   80040b <printfmt>
  80058f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800592:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800595:	e9 b4 fe ff ff       	jmp    80044e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 50 04             	lea    0x4(%eax),%edx
  8005a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005a5:	85 ff                	test   %edi,%edi
  8005a7:	b8 5c 28 80 00       	mov    $0x80285c,%eax
  8005ac:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b3:	0f 8e 94 00 00 00    	jle    80064d <vprintfmt+0x225>
  8005b9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005bd:	0f 84 98 00 00 00    	je     80065b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	ff 75 d0             	pushl  -0x30(%ebp)
  8005c9:	57                   	push   %edi
  8005ca:	e8 86 02 00 00       	call   800855 <strnlen>
  8005cf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005d2:	29 c1                	sub    %eax,%ecx
  8005d4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005d7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005da:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005e4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e6:	eb 0f                	jmp    8005f7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005e8:	83 ec 08             	sub    $0x8,%esp
  8005eb:	53                   	push   %ebx
  8005ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ef:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f1:	83 ef 01             	sub    $0x1,%edi
  8005f4:	83 c4 10             	add    $0x10,%esp
  8005f7:	85 ff                	test   %edi,%edi
  8005f9:	7f ed                	jg     8005e8 <vprintfmt+0x1c0>
  8005fb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005fe:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800601:	85 c9                	test   %ecx,%ecx
  800603:	b8 00 00 00 00       	mov    $0x0,%eax
  800608:	0f 49 c1             	cmovns %ecx,%eax
  80060b:	29 c1                	sub    %eax,%ecx
  80060d:	89 75 08             	mov    %esi,0x8(%ebp)
  800610:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800613:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800616:	89 cb                	mov    %ecx,%ebx
  800618:	eb 4d                	jmp    800667 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80061a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80061e:	74 1b                	je     80063b <vprintfmt+0x213>
  800620:	0f be c0             	movsbl %al,%eax
  800623:	83 e8 20             	sub    $0x20,%eax
  800626:	83 f8 5e             	cmp    $0x5e,%eax
  800629:	76 10                	jbe    80063b <vprintfmt+0x213>
					putch('?', putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	ff 75 0c             	pushl  0xc(%ebp)
  800631:	6a 3f                	push   $0x3f
  800633:	ff 55 08             	call   *0x8(%ebp)
  800636:	83 c4 10             	add    $0x10,%esp
  800639:	eb 0d                	jmp    800648 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80063b:	83 ec 08             	sub    $0x8,%esp
  80063e:	ff 75 0c             	pushl  0xc(%ebp)
  800641:	52                   	push   %edx
  800642:	ff 55 08             	call   *0x8(%ebp)
  800645:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800648:	83 eb 01             	sub    $0x1,%ebx
  80064b:	eb 1a                	jmp    800667 <vprintfmt+0x23f>
  80064d:	89 75 08             	mov    %esi,0x8(%ebp)
  800650:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800653:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800656:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800659:	eb 0c                	jmp    800667 <vprintfmt+0x23f>
  80065b:	89 75 08             	mov    %esi,0x8(%ebp)
  80065e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800661:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800664:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800667:	83 c7 01             	add    $0x1,%edi
  80066a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80066e:	0f be d0             	movsbl %al,%edx
  800671:	85 d2                	test   %edx,%edx
  800673:	74 23                	je     800698 <vprintfmt+0x270>
  800675:	85 f6                	test   %esi,%esi
  800677:	78 a1                	js     80061a <vprintfmt+0x1f2>
  800679:	83 ee 01             	sub    $0x1,%esi
  80067c:	79 9c                	jns    80061a <vprintfmt+0x1f2>
  80067e:	89 df                	mov    %ebx,%edi
  800680:	8b 75 08             	mov    0x8(%ebp),%esi
  800683:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800686:	eb 18                	jmp    8006a0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800688:	83 ec 08             	sub    $0x8,%esp
  80068b:	53                   	push   %ebx
  80068c:	6a 20                	push   $0x20
  80068e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800690:	83 ef 01             	sub    $0x1,%edi
  800693:	83 c4 10             	add    $0x10,%esp
  800696:	eb 08                	jmp    8006a0 <vprintfmt+0x278>
  800698:	89 df                	mov    %ebx,%edi
  80069a:	8b 75 08             	mov    0x8(%ebp),%esi
  80069d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a0:	85 ff                	test   %edi,%edi
  8006a2:	7f e4                	jg     800688 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a7:	e9 a2 fd ff ff       	jmp    80044e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ac:	83 fa 01             	cmp    $0x1,%edx
  8006af:	7e 16                	jle    8006c7 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8d 50 08             	lea    0x8(%eax),%edx
  8006b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ba:	8b 50 04             	mov    0x4(%eax),%edx
  8006bd:	8b 00                	mov    (%eax),%eax
  8006bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006c5:	eb 32                	jmp    8006f9 <vprintfmt+0x2d1>
	else if (lflag)
  8006c7:	85 d2                	test   %edx,%edx
  8006c9:	74 18                	je     8006e3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	8d 50 04             	lea    0x4(%eax),%edx
  8006d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d4:	8b 00                	mov    (%eax),%eax
  8006d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d9:	89 c1                	mov    %eax,%ecx
  8006db:	c1 f9 1f             	sar    $0x1f,%ecx
  8006de:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006e1:	eb 16                	jmp    8006f9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	8d 50 04             	lea    0x4(%eax),%edx
  8006e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ec:	8b 00                	mov    (%eax),%eax
  8006ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f1:	89 c1                	mov    %eax,%ecx
  8006f3:	c1 f9 1f             	sar    $0x1f,%ecx
  8006f6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006ff:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800704:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800708:	79 74                	jns    80077e <vprintfmt+0x356>
				putch('-', putdat);
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	53                   	push   %ebx
  80070e:	6a 2d                	push   $0x2d
  800710:	ff d6                	call   *%esi
				num = -(long long) num;
  800712:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800715:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800718:	f7 d8                	neg    %eax
  80071a:	83 d2 00             	adc    $0x0,%edx
  80071d:	f7 da                	neg    %edx
  80071f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800722:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800727:	eb 55                	jmp    80077e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800729:	8d 45 14             	lea    0x14(%ebp),%eax
  80072c:	e8 83 fc ff ff       	call   8003b4 <getuint>
			base = 10;
  800731:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800736:	eb 46                	jmp    80077e <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800738:	8d 45 14             	lea    0x14(%ebp),%eax
  80073b:	e8 74 fc ff ff       	call   8003b4 <getuint>
			base = 8;
  800740:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800745:	eb 37                	jmp    80077e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800747:	83 ec 08             	sub    $0x8,%esp
  80074a:	53                   	push   %ebx
  80074b:	6a 30                	push   $0x30
  80074d:	ff d6                	call   *%esi
			putch('x', putdat);
  80074f:	83 c4 08             	add    $0x8,%esp
  800752:	53                   	push   %ebx
  800753:	6a 78                	push   $0x78
  800755:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800757:	8b 45 14             	mov    0x14(%ebp),%eax
  80075a:	8d 50 04             	lea    0x4(%eax),%edx
  80075d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800760:	8b 00                	mov    (%eax),%eax
  800762:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800767:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80076a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80076f:	eb 0d                	jmp    80077e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800771:	8d 45 14             	lea    0x14(%ebp),%eax
  800774:	e8 3b fc ff ff       	call   8003b4 <getuint>
			base = 16;
  800779:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80077e:	83 ec 0c             	sub    $0xc,%esp
  800781:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800785:	57                   	push   %edi
  800786:	ff 75 e0             	pushl  -0x20(%ebp)
  800789:	51                   	push   %ecx
  80078a:	52                   	push   %edx
  80078b:	50                   	push   %eax
  80078c:	89 da                	mov    %ebx,%edx
  80078e:	89 f0                	mov    %esi,%eax
  800790:	e8 70 fb ff ff       	call   800305 <printnum>
			break;
  800795:	83 c4 20             	add    $0x20,%esp
  800798:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80079b:	e9 ae fc ff ff       	jmp    80044e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007a0:	83 ec 08             	sub    $0x8,%esp
  8007a3:	53                   	push   %ebx
  8007a4:	51                   	push   %ecx
  8007a5:	ff d6                	call   *%esi
			break;
  8007a7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ad:	e9 9c fc ff ff       	jmp    80044e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007b2:	83 ec 08             	sub    $0x8,%esp
  8007b5:	53                   	push   %ebx
  8007b6:	6a 25                	push   $0x25
  8007b8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007ba:	83 c4 10             	add    $0x10,%esp
  8007bd:	eb 03                	jmp    8007c2 <vprintfmt+0x39a>
  8007bf:	83 ef 01             	sub    $0x1,%edi
  8007c2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007c6:	75 f7                	jne    8007bf <vprintfmt+0x397>
  8007c8:	e9 81 fc ff ff       	jmp    80044e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007d0:	5b                   	pop    %ebx
  8007d1:	5e                   	pop    %esi
  8007d2:	5f                   	pop    %edi
  8007d3:	5d                   	pop    %ebp
  8007d4:	c3                   	ret    

008007d5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	83 ec 18             	sub    $0x18,%esp
  8007db:	8b 45 08             	mov    0x8(%ebp),%eax
  8007de:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007e4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007e8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007f2:	85 c0                	test   %eax,%eax
  8007f4:	74 26                	je     80081c <vsnprintf+0x47>
  8007f6:	85 d2                	test   %edx,%edx
  8007f8:	7e 22                	jle    80081c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007fa:	ff 75 14             	pushl  0x14(%ebp)
  8007fd:	ff 75 10             	pushl  0x10(%ebp)
  800800:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800803:	50                   	push   %eax
  800804:	68 ee 03 80 00       	push   $0x8003ee
  800809:	e8 1a fc ff ff       	call   800428 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80080e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800811:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800814:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800817:	83 c4 10             	add    $0x10,%esp
  80081a:	eb 05                	jmp    800821 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80081c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800821:	c9                   	leave  
  800822:	c3                   	ret    

00800823 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800829:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80082c:	50                   	push   %eax
  80082d:	ff 75 10             	pushl  0x10(%ebp)
  800830:	ff 75 0c             	pushl  0xc(%ebp)
  800833:	ff 75 08             	pushl  0x8(%ebp)
  800836:	e8 9a ff ff ff       	call   8007d5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80083b:	c9                   	leave  
  80083c:	c3                   	ret    

0080083d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800843:	b8 00 00 00 00       	mov    $0x0,%eax
  800848:	eb 03                	jmp    80084d <strlen+0x10>
		n++;
  80084a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80084d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800851:	75 f7                	jne    80084a <strlen+0xd>
		n++;
	return n;
}
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085e:	ba 00 00 00 00       	mov    $0x0,%edx
  800863:	eb 03                	jmp    800868 <strnlen+0x13>
		n++;
  800865:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800868:	39 c2                	cmp    %eax,%edx
  80086a:	74 08                	je     800874 <strnlen+0x1f>
  80086c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800870:	75 f3                	jne    800865 <strnlen+0x10>
  800872:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	53                   	push   %ebx
  80087a:	8b 45 08             	mov    0x8(%ebp),%eax
  80087d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800880:	89 c2                	mov    %eax,%edx
  800882:	83 c2 01             	add    $0x1,%edx
  800885:	83 c1 01             	add    $0x1,%ecx
  800888:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80088c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80088f:	84 db                	test   %bl,%bl
  800891:	75 ef                	jne    800882 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800893:	5b                   	pop    %ebx
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	53                   	push   %ebx
  80089a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80089d:	53                   	push   %ebx
  80089e:	e8 9a ff ff ff       	call   80083d <strlen>
  8008a3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008a6:	ff 75 0c             	pushl  0xc(%ebp)
  8008a9:	01 d8                	add    %ebx,%eax
  8008ab:	50                   	push   %eax
  8008ac:	e8 c5 ff ff ff       	call   800876 <strcpy>
	return dst;
}
  8008b1:	89 d8                	mov    %ebx,%eax
  8008b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b6:	c9                   	leave  
  8008b7:	c3                   	ret    

008008b8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	56                   	push   %esi
  8008bc:	53                   	push   %ebx
  8008bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c3:	89 f3                	mov    %esi,%ebx
  8008c5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c8:	89 f2                	mov    %esi,%edx
  8008ca:	eb 0f                	jmp    8008db <strncpy+0x23>
		*dst++ = *src;
  8008cc:	83 c2 01             	add    $0x1,%edx
  8008cf:	0f b6 01             	movzbl (%ecx),%eax
  8008d2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d5:	80 39 01             	cmpb   $0x1,(%ecx)
  8008d8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008db:	39 da                	cmp    %ebx,%edx
  8008dd:	75 ed                	jne    8008cc <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008df:	89 f0                	mov    %esi,%eax
  8008e1:	5b                   	pop    %ebx
  8008e2:	5e                   	pop    %esi
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	56                   	push   %esi
  8008e9:	53                   	push   %ebx
  8008ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f0:	8b 55 10             	mov    0x10(%ebp),%edx
  8008f3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f5:	85 d2                	test   %edx,%edx
  8008f7:	74 21                	je     80091a <strlcpy+0x35>
  8008f9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008fd:	89 f2                	mov    %esi,%edx
  8008ff:	eb 09                	jmp    80090a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800901:	83 c2 01             	add    $0x1,%edx
  800904:	83 c1 01             	add    $0x1,%ecx
  800907:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80090a:	39 c2                	cmp    %eax,%edx
  80090c:	74 09                	je     800917 <strlcpy+0x32>
  80090e:	0f b6 19             	movzbl (%ecx),%ebx
  800911:	84 db                	test   %bl,%bl
  800913:	75 ec                	jne    800901 <strlcpy+0x1c>
  800915:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800917:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80091a:	29 f0                	sub    %esi,%eax
}
  80091c:	5b                   	pop    %ebx
  80091d:	5e                   	pop    %esi
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800926:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800929:	eb 06                	jmp    800931 <strcmp+0x11>
		p++, q++;
  80092b:	83 c1 01             	add    $0x1,%ecx
  80092e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800931:	0f b6 01             	movzbl (%ecx),%eax
  800934:	84 c0                	test   %al,%al
  800936:	74 04                	je     80093c <strcmp+0x1c>
  800938:	3a 02                	cmp    (%edx),%al
  80093a:	74 ef                	je     80092b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80093c:	0f b6 c0             	movzbl %al,%eax
  80093f:	0f b6 12             	movzbl (%edx),%edx
  800942:	29 d0                	sub    %edx,%eax
}
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	53                   	push   %ebx
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
  80094d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800950:	89 c3                	mov    %eax,%ebx
  800952:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800955:	eb 06                	jmp    80095d <strncmp+0x17>
		n--, p++, q++;
  800957:	83 c0 01             	add    $0x1,%eax
  80095a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80095d:	39 d8                	cmp    %ebx,%eax
  80095f:	74 15                	je     800976 <strncmp+0x30>
  800961:	0f b6 08             	movzbl (%eax),%ecx
  800964:	84 c9                	test   %cl,%cl
  800966:	74 04                	je     80096c <strncmp+0x26>
  800968:	3a 0a                	cmp    (%edx),%cl
  80096a:	74 eb                	je     800957 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80096c:	0f b6 00             	movzbl (%eax),%eax
  80096f:	0f b6 12             	movzbl (%edx),%edx
  800972:	29 d0                	sub    %edx,%eax
  800974:	eb 05                	jmp    80097b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800976:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80097b:	5b                   	pop    %ebx
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800988:	eb 07                	jmp    800991 <strchr+0x13>
		if (*s == c)
  80098a:	38 ca                	cmp    %cl,%dl
  80098c:	74 0f                	je     80099d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80098e:	83 c0 01             	add    $0x1,%eax
  800991:	0f b6 10             	movzbl (%eax),%edx
  800994:	84 d2                	test   %dl,%dl
  800996:	75 f2                	jne    80098a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800998:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a9:	eb 03                	jmp    8009ae <strfind+0xf>
  8009ab:	83 c0 01             	add    $0x1,%eax
  8009ae:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009b1:	38 ca                	cmp    %cl,%dl
  8009b3:	74 04                	je     8009b9 <strfind+0x1a>
  8009b5:	84 d2                	test   %dl,%dl
  8009b7:	75 f2                	jne    8009ab <strfind+0xc>
			break;
	return (char *) s;
}
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	57                   	push   %edi
  8009bf:	56                   	push   %esi
  8009c0:	53                   	push   %ebx
  8009c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009c7:	85 c9                	test   %ecx,%ecx
  8009c9:	74 36                	je     800a01 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009cb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009d1:	75 28                	jne    8009fb <memset+0x40>
  8009d3:	f6 c1 03             	test   $0x3,%cl
  8009d6:	75 23                	jne    8009fb <memset+0x40>
		c &= 0xFF;
  8009d8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009dc:	89 d3                	mov    %edx,%ebx
  8009de:	c1 e3 08             	shl    $0x8,%ebx
  8009e1:	89 d6                	mov    %edx,%esi
  8009e3:	c1 e6 18             	shl    $0x18,%esi
  8009e6:	89 d0                	mov    %edx,%eax
  8009e8:	c1 e0 10             	shl    $0x10,%eax
  8009eb:	09 f0                	or     %esi,%eax
  8009ed:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009ef:	89 d8                	mov    %ebx,%eax
  8009f1:	09 d0                	or     %edx,%eax
  8009f3:	c1 e9 02             	shr    $0x2,%ecx
  8009f6:	fc                   	cld    
  8009f7:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f9:	eb 06                	jmp    800a01 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fe:	fc                   	cld    
  8009ff:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a01:	89 f8                	mov    %edi,%eax
  800a03:	5b                   	pop    %ebx
  800a04:	5e                   	pop    %esi
  800a05:	5f                   	pop    %edi
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	57                   	push   %edi
  800a0c:	56                   	push   %esi
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a13:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a16:	39 c6                	cmp    %eax,%esi
  800a18:	73 35                	jae    800a4f <memmove+0x47>
  800a1a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a1d:	39 d0                	cmp    %edx,%eax
  800a1f:	73 2e                	jae    800a4f <memmove+0x47>
		s += n;
		d += n;
  800a21:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a24:	89 d6                	mov    %edx,%esi
  800a26:	09 fe                	or     %edi,%esi
  800a28:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a2e:	75 13                	jne    800a43 <memmove+0x3b>
  800a30:	f6 c1 03             	test   $0x3,%cl
  800a33:	75 0e                	jne    800a43 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a35:	83 ef 04             	sub    $0x4,%edi
  800a38:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a3b:	c1 e9 02             	shr    $0x2,%ecx
  800a3e:	fd                   	std    
  800a3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a41:	eb 09                	jmp    800a4c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a43:	83 ef 01             	sub    $0x1,%edi
  800a46:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a49:	fd                   	std    
  800a4a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a4c:	fc                   	cld    
  800a4d:	eb 1d                	jmp    800a6c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4f:	89 f2                	mov    %esi,%edx
  800a51:	09 c2                	or     %eax,%edx
  800a53:	f6 c2 03             	test   $0x3,%dl
  800a56:	75 0f                	jne    800a67 <memmove+0x5f>
  800a58:	f6 c1 03             	test   $0x3,%cl
  800a5b:	75 0a                	jne    800a67 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a5d:	c1 e9 02             	shr    $0x2,%ecx
  800a60:	89 c7                	mov    %eax,%edi
  800a62:	fc                   	cld    
  800a63:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a65:	eb 05                	jmp    800a6c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a67:	89 c7                	mov    %eax,%edi
  800a69:	fc                   	cld    
  800a6a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a6c:	5e                   	pop    %esi
  800a6d:	5f                   	pop    %edi
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a73:	ff 75 10             	pushl  0x10(%ebp)
  800a76:	ff 75 0c             	pushl  0xc(%ebp)
  800a79:	ff 75 08             	pushl  0x8(%ebp)
  800a7c:	e8 87 ff ff ff       	call   800a08 <memmove>
}
  800a81:	c9                   	leave  
  800a82:	c3                   	ret    

00800a83 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8e:	89 c6                	mov    %eax,%esi
  800a90:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a93:	eb 1a                	jmp    800aaf <memcmp+0x2c>
		if (*s1 != *s2)
  800a95:	0f b6 08             	movzbl (%eax),%ecx
  800a98:	0f b6 1a             	movzbl (%edx),%ebx
  800a9b:	38 d9                	cmp    %bl,%cl
  800a9d:	74 0a                	je     800aa9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a9f:	0f b6 c1             	movzbl %cl,%eax
  800aa2:	0f b6 db             	movzbl %bl,%ebx
  800aa5:	29 d8                	sub    %ebx,%eax
  800aa7:	eb 0f                	jmp    800ab8 <memcmp+0x35>
		s1++, s2++;
  800aa9:	83 c0 01             	add    $0x1,%eax
  800aac:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aaf:	39 f0                	cmp    %esi,%eax
  800ab1:	75 e2                	jne    800a95 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ab3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	53                   	push   %ebx
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ac3:	89 c1                	mov    %eax,%ecx
  800ac5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800acc:	eb 0a                	jmp    800ad8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ace:	0f b6 10             	movzbl (%eax),%edx
  800ad1:	39 da                	cmp    %ebx,%edx
  800ad3:	74 07                	je     800adc <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ad5:	83 c0 01             	add    $0x1,%eax
  800ad8:	39 c8                	cmp    %ecx,%eax
  800ada:	72 f2                	jb     800ace <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800adc:	5b                   	pop    %ebx
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	57                   	push   %edi
  800ae3:	56                   	push   %esi
  800ae4:	53                   	push   %ebx
  800ae5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aeb:	eb 03                	jmp    800af0 <strtol+0x11>
		s++;
  800aed:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af0:	0f b6 01             	movzbl (%ecx),%eax
  800af3:	3c 20                	cmp    $0x20,%al
  800af5:	74 f6                	je     800aed <strtol+0xe>
  800af7:	3c 09                	cmp    $0x9,%al
  800af9:	74 f2                	je     800aed <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800afb:	3c 2b                	cmp    $0x2b,%al
  800afd:	75 0a                	jne    800b09 <strtol+0x2a>
		s++;
  800aff:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b02:	bf 00 00 00 00       	mov    $0x0,%edi
  800b07:	eb 11                	jmp    800b1a <strtol+0x3b>
  800b09:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b0e:	3c 2d                	cmp    $0x2d,%al
  800b10:	75 08                	jne    800b1a <strtol+0x3b>
		s++, neg = 1;
  800b12:	83 c1 01             	add    $0x1,%ecx
  800b15:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b1a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b20:	75 15                	jne    800b37 <strtol+0x58>
  800b22:	80 39 30             	cmpb   $0x30,(%ecx)
  800b25:	75 10                	jne    800b37 <strtol+0x58>
  800b27:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b2b:	75 7c                	jne    800ba9 <strtol+0xca>
		s += 2, base = 16;
  800b2d:	83 c1 02             	add    $0x2,%ecx
  800b30:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b35:	eb 16                	jmp    800b4d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b37:	85 db                	test   %ebx,%ebx
  800b39:	75 12                	jne    800b4d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b3b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b40:	80 39 30             	cmpb   $0x30,(%ecx)
  800b43:	75 08                	jne    800b4d <strtol+0x6e>
		s++, base = 8;
  800b45:	83 c1 01             	add    $0x1,%ecx
  800b48:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b52:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b55:	0f b6 11             	movzbl (%ecx),%edx
  800b58:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b5b:	89 f3                	mov    %esi,%ebx
  800b5d:	80 fb 09             	cmp    $0x9,%bl
  800b60:	77 08                	ja     800b6a <strtol+0x8b>
			dig = *s - '0';
  800b62:	0f be d2             	movsbl %dl,%edx
  800b65:	83 ea 30             	sub    $0x30,%edx
  800b68:	eb 22                	jmp    800b8c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b6a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b6d:	89 f3                	mov    %esi,%ebx
  800b6f:	80 fb 19             	cmp    $0x19,%bl
  800b72:	77 08                	ja     800b7c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b74:	0f be d2             	movsbl %dl,%edx
  800b77:	83 ea 57             	sub    $0x57,%edx
  800b7a:	eb 10                	jmp    800b8c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b7c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b7f:	89 f3                	mov    %esi,%ebx
  800b81:	80 fb 19             	cmp    $0x19,%bl
  800b84:	77 16                	ja     800b9c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b86:	0f be d2             	movsbl %dl,%edx
  800b89:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b8c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b8f:	7d 0b                	jge    800b9c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b91:	83 c1 01             	add    $0x1,%ecx
  800b94:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b98:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b9a:	eb b9                	jmp    800b55 <strtol+0x76>

	if (endptr)
  800b9c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba0:	74 0d                	je     800baf <strtol+0xd0>
		*endptr = (char *) s;
  800ba2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba5:	89 0e                	mov    %ecx,(%esi)
  800ba7:	eb 06                	jmp    800baf <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ba9:	85 db                	test   %ebx,%ebx
  800bab:	74 98                	je     800b45 <strtol+0x66>
  800bad:	eb 9e                	jmp    800b4d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800baf:	89 c2                	mov    %eax,%edx
  800bb1:	f7 da                	neg    %edx
  800bb3:	85 ff                	test   %edi,%edi
  800bb5:	0f 45 c2             	cmovne %edx,%eax
}
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc3:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bce:	89 c3                	mov    %eax,%ebx
  800bd0:	89 c7                	mov    %eax,%edi
  800bd2:	89 c6                	mov    %eax,%esi
  800bd4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <sys_cgetc>:

int
sys_cgetc(void)
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
  800be1:	ba 00 00 00 00       	mov    $0x0,%edx
  800be6:	b8 01 00 00 00       	mov    $0x1,%eax
  800beb:	89 d1                	mov    %edx,%ecx
  800bed:	89 d3                	mov    %edx,%ebx
  800bef:	89 d7                	mov    %edx,%edi
  800bf1:	89 d6                	mov    %edx,%esi
  800bf3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	57                   	push   %edi
  800bfe:	56                   	push   %esi
  800bff:	53                   	push   %ebx
  800c00:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c03:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c08:	b8 03 00 00 00       	mov    $0x3,%eax
  800c0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c10:	89 cb                	mov    %ecx,%ebx
  800c12:	89 cf                	mov    %ecx,%edi
  800c14:	89 ce                	mov    %ecx,%esi
  800c16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c18:	85 c0                	test   %eax,%eax
  800c1a:	7e 17                	jle    800c33 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1c:	83 ec 0c             	sub    $0xc,%esp
  800c1f:	50                   	push   %eax
  800c20:	6a 03                	push   $0x3
  800c22:	68 3f 2b 80 00       	push   $0x802b3f
  800c27:	6a 23                	push   $0x23
  800c29:	68 5c 2b 80 00       	push   $0x802b5c
  800c2e:	e8 e5 f5 ff ff       	call   800218 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c41:	ba 00 00 00 00       	mov    $0x0,%edx
  800c46:	b8 02 00 00 00       	mov    $0x2,%eax
  800c4b:	89 d1                	mov    %edx,%ecx
  800c4d:	89 d3                	mov    %edx,%ebx
  800c4f:	89 d7                	mov    %edx,%edi
  800c51:	89 d6                	mov    %edx,%esi
  800c53:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <sys_yield>:

void
sys_yield(void)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c60:	ba 00 00 00 00       	mov    $0x0,%edx
  800c65:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c6a:	89 d1                	mov    %edx,%ecx
  800c6c:	89 d3                	mov    %edx,%ebx
  800c6e:	89 d7                	mov    %edx,%edi
  800c70:	89 d6                	mov    %edx,%esi
  800c72:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	57                   	push   %edi
  800c7d:	56                   	push   %esi
  800c7e:	53                   	push   %ebx
  800c7f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c82:	be 00 00 00 00       	mov    $0x0,%esi
  800c87:	b8 04 00 00 00       	mov    $0x4,%eax
  800c8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c92:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c95:	89 f7                	mov    %esi,%edi
  800c97:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c99:	85 c0                	test   %eax,%eax
  800c9b:	7e 17                	jle    800cb4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9d:	83 ec 0c             	sub    $0xc,%esp
  800ca0:	50                   	push   %eax
  800ca1:	6a 04                	push   $0x4
  800ca3:	68 3f 2b 80 00       	push   $0x802b3f
  800ca8:	6a 23                	push   $0x23
  800caa:	68 5c 2b 80 00       	push   $0x802b5c
  800caf:	e8 64 f5 ff ff       	call   800218 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc5:	b8 05 00 00 00       	mov    $0x5,%eax
  800cca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd6:	8b 75 18             	mov    0x18(%ebp),%esi
  800cd9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	7e 17                	jle    800cf6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdf:	83 ec 0c             	sub    $0xc,%esp
  800ce2:	50                   	push   %eax
  800ce3:	6a 05                	push   $0x5
  800ce5:	68 3f 2b 80 00       	push   $0x802b3f
  800cea:	6a 23                	push   $0x23
  800cec:	68 5c 2b 80 00       	push   $0x802b5c
  800cf1:	e8 22 f5 ff ff       	call   800218 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d07:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0c:	b8 06 00 00 00       	mov    $0x6,%eax
  800d11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
  800d17:	89 df                	mov    %ebx,%edi
  800d19:	89 de                	mov    %ebx,%esi
  800d1b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1d:	85 c0                	test   %eax,%eax
  800d1f:	7e 17                	jle    800d38 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d21:	83 ec 0c             	sub    $0xc,%esp
  800d24:	50                   	push   %eax
  800d25:	6a 06                	push   $0x6
  800d27:	68 3f 2b 80 00       	push   $0x802b3f
  800d2c:	6a 23                	push   $0x23
  800d2e:	68 5c 2b 80 00       	push   $0x802b5c
  800d33:	e8 e0 f4 ff ff       	call   800218 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	57                   	push   %edi
  800d44:	56                   	push   %esi
  800d45:	53                   	push   %ebx
  800d46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4e:	b8 08 00 00 00       	mov    $0x8,%eax
  800d53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	89 df                	mov    %ebx,%edi
  800d5b:	89 de                	mov    %ebx,%esi
  800d5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5f:	85 c0                	test   %eax,%eax
  800d61:	7e 17                	jle    800d7a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d63:	83 ec 0c             	sub    $0xc,%esp
  800d66:	50                   	push   %eax
  800d67:	6a 08                	push   $0x8
  800d69:	68 3f 2b 80 00       	push   $0x802b3f
  800d6e:	6a 23                	push   $0x23
  800d70:	68 5c 2b 80 00       	push   $0x802b5c
  800d75:	e8 9e f4 ff ff       	call   800218 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	57                   	push   %edi
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
  800d88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d90:	b8 09 00 00 00       	mov    $0x9,%eax
  800d95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d98:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9b:	89 df                	mov    %ebx,%edi
  800d9d:	89 de                	mov    %ebx,%esi
  800d9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da1:	85 c0                	test   %eax,%eax
  800da3:	7e 17                	jle    800dbc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da5:	83 ec 0c             	sub    $0xc,%esp
  800da8:	50                   	push   %eax
  800da9:	6a 09                	push   $0x9
  800dab:	68 3f 2b 80 00       	push   $0x802b3f
  800db0:	6a 23                	push   $0x23
  800db2:	68 5c 2b 80 00       	push   $0x802b5c
  800db7:	e8 5c f4 ff ff       	call   800218 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	57                   	push   %edi
  800dc8:	56                   	push   %esi
  800dc9:	53                   	push   %ebx
  800dca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dda:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddd:	89 df                	mov    %ebx,%edi
  800ddf:	89 de                	mov    %ebx,%esi
  800de1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de3:	85 c0                	test   %eax,%eax
  800de5:	7e 17                	jle    800dfe <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de7:	83 ec 0c             	sub    $0xc,%esp
  800dea:	50                   	push   %eax
  800deb:	6a 0a                	push   $0xa
  800ded:	68 3f 2b 80 00       	push   $0x802b3f
  800df2:	6a 23                	push   $0x23
  800df4:	68 5c 2b 80 00       	push   $0x802b5c
  800df9:	e8 1a f4 ff ff       	call   800218 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5f                   	pop    %edi
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    

00800e06 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	57                   	push   %edi
  800e0a:	56                   	push   %esi
  800e0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0c:	be 00 00 00 00       	mov    $0x0,%esi
  800e11:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e19:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e1f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e22:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e37:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3f:	89 cb                	mov    %ecx,%ebx
  800e41:	89 cf                	mov    %ecx,%edi
  800e43:	89 ce                	mov    %ecx,%esi
  800e45:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e47:	85 c0                	test   %eax,%eax
  800e49:	7e 17                	jle    800e62 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4b:	83 ec 0c             	sub    $0xc,%esp
  800e4e:	50                   	push   %eax
  800e4f:	6a 0d                	push   $0xd
  800e51:	68 3f 2b 80 00       	push   $0x802b3f
  800e56:	6a 23                	push   $0x23
  800e58:	68 5c 2b 80 00       	push   $0x802b5c
  800e5d:	e8 b6 f3 ff ff       	call   800218 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e65:	5b                   	pop    %ebx
  800e66:	5e                   	pop    %esi
  800e67:	5f                   	pop    %edi
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    

00800e6a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	57                   	push   %edi
  800e6e:	56                   	push   %esi
  800e6f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e70:	ba 00 00 00 00       	mov    $0x0,%edx
  800e75:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e7a:	89 d1                	mov    %edx,%ecx
  800e7c:	89 d3                	mov    %edx,%ebx
  800e7e:	89 d7                	mov    %edx,%edi
  800e80:	89 d6                	mov    %edx,%esi
  800e82:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	56                   	push   %esi
  800e8d:	53                   	push   %ebx
  800e8e:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e91:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800e93:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e97:	75 25                	jne    800ebe <pgfault+0x35>
  800e99:	89 d8                	mov    %ebx,%eax
  800e9b:	c1 e8 0c             	shr    $0xc,%eax
  800e9e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ea5:	f6 c4 08             	test   $0x8,%ah
  800ea8:	75 14                	jne    800ebe <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800eaa:	83 ec 04             	sub    $0x4,%esp
  800ead:	68 6c 2b 80 00       	push   $0x802b6c
  800eb2:	6a 1e                	push   $0x1e
  800eb4:	68 00 2c 80 00       	push   $0x802c00
  800eb9:	e8 5a f3 ff ff       	call   800218 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800ebe:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800ec4:	e8 72 fd ff ff       	call   800c3b <sys_getenvid>
  800ec9:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800ecb:	83 ec 04             	sub    $0x4,%esp
  800ece:	6a 07                	push   $0x7
  800ed0:	68 00 f0 7f 00       	push   $0x7ff000
  800ed5:	50                   	push   %eax
  800ed6:	e8 9e fd ff ff       	call   800c79 <sys_page_alloc>
	if (r < 0)
  800edb:	83 c4 10             	add    $0x10,%esp
  800ede:	85 c0                	test   %eax,%eax
  800ee0:	79 12                	jns    800ef4 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800ee2:	50                   	push   %eax
  800ee3:	68 98 2b 80 00       	push   $0x802b98
  800ee8:	6a 33                	push   $0x33
  800eea:	68 00 2c 80 00       	push   $0x802c00
  800eef:	e8 24 f3 ff ff       	call   800218 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800ef4:	83 ec 04             	sub    $0x4,%esp
  800ef7:	68 00 10 00 00       	push   $0x1000
  800efc:	53                   	push   %ebx
  800efd:	68 00 f0 7f 00       	push   $0x7ff000
  800f02:	e8 69 fb ff ff       	call   800a70 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800f07:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f0e:	53                   	push   %ebx
  800f0f:	56                   	push   %esi
  800f10:	68 00 f0 7f 00       	push   $0x7ff000
  800f15:	56                   	push   %esi
  800f16:	e8 a1 fd ff ff       	call   800cbc <sys_page_map>
	if (r < 0)
  800f1b:	83 c4 20             	add    $0x20,%esp
  800f1e:	85 c0                	test   %eax,%eax
  800f20:	79 12                	jns    800f34 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800f22:	50                   	push   %eax
  800f23:	68 bc 2b 80 00       	push   $0x802bbc
  800f28:	6a 3b                	push   $0x3b
  800f2a:	68 00 2c 80 00       	push   $0x802c00
  800f2f:	e8 e4 f2 ff ff       	call   800218 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800f34:	83 ec 08             	sub    $0x8,%esp
  800f37:	68 00 f0 7f 00       	push   $0x7ff000
  800f3c:	56                   	push   %esi
  800f3d:	e8 bc fd ff ff       	call   800cfe <sys_page_unmap>
	if (r < 0)
  800f42:	83 c4 10             	add    $0x10,%esp
  800f45:	85 c0                	test   %eax,%eax
  800f47:	79 12                	jns    800f5b <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800f49:	50                   	push   %eax
  800f4a:	68 e0 2b 80 00       	push   $0x802be0
  800f4f:	6a 40                	push   $0x40
  800f51:	68 00 2c 80 00       	push   $0x802c00
  800f56:	e8 bd f2 ff ff       	call   800218 <_panic>
}
  800f5b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f5e:	5b                   	pop    %ebx
  800f5f:	5e                   	pop    %esi
  800f60:	5d                   	pop    %ebp
  800f61:	c3                   	ret    

00800f62 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f62:	55                   	push   %ebp
  800f63:	89 e5                	mov    %esp,%ebp
  800f65:	57                   	push   %edi
  800f66:	56                   	push   %esi
  800f67:	53                   	push   %ebx
  800f68:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800f6b:	68 89 0e 80 00       	push   $0x800e89
  800f70:	e8 37 13 00 00       	call   8022ac <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f75:	b8 07 00 00 00       	mov    $0x7,%eax
  800f7a:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800f7c:	83 c4 10             	add    $0x10,%esp
  800f7f:	85 c0                	test   %eax,%eax
  800f81:	0f 88 64 01 00 00    	js     8010eb <fork+0x189>
  800f87:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800f8c:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800f91:	85 c0                	test   %eax,%eax
  800f93:	75 21                	jne    800fb6 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f95:	e8 a1 fc ff ff       	call   800c3b <sys_getenvid>
  800f9a:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f9f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fa2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fa7:	a3 20 44 80 00       	mov    %eax,0x804420
        return 0;
  800fac:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb1:	e9 3f 01 00 00       	jmp    8010f5 <fork+0x193>
  800fb6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fb9:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800fbb:	89 d8                	mov    %ebx,%eax
  800fbd:	c1 e8 16             	shr    $0x16,%eax
  800fc0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fc7:	a8 01                	test   $0x1,%al
  800fc9:	0f 84 bd 00 00 00    	je     80108c <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800fcf:	89 d8                	mov    %ebx,%eax
  800fd1:	c1 e8 0c             	shr    $0xc,%eax
  800fd4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fdb:	f6 c2 01             	test   $0x1,%dl
  800fde:	0f 84 a8 00 00 00    	je     80108c <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  800fe4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800feb:	a8 04                	test   $0x4,%al
  800fed:	0f 84 99 00 00 00    	je     80108c <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800ff3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ffa:	f6 c4 04             	test   $0x4,%ah
  800ffd:	74 17                	je     801016 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800fff:	83 ec 0c             	sub    $0xc,%esp
  801002:	68 07 0e 00 00       	push   $0xe07
  801007:	53                   	push   %ebx
  801008:	57                   	push   %edi
  801009:	53                   	push   %ebx
  80100a:	6a 00                	push   $0x0
  80100c:	e8 ab fc ff ff       	call   800cbc <sys_page_map>
  801011:	83 c4 20             	add    $0x20,%esp
  801014:	eb 76                	jmp    80108c <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801016:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80101d:	a8 02                	test   $0x2,%al
  80101f:	75 0c                	jne    80102d <fork+0xcb>
  801021:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801028:	f6 c4 08             	test   $0x8,%ah
  80102b:	74 3f                	je     80106c <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  80102d:	83 ec 0c             	sub    $0xc,%esp
  801030:	68 05 08 00 00       	push   $0x805
  801035:	53                   	push   %ebx
  801036:	57                   	push   %edi
  801037:	53                   	push   %ebx
  801038:	6a 00                	push   $0x0
  80103a:	e8 7d fc ff ff       	call   800cbc <sys_page_map>
		if (r < 0)
  80103f:	83 c4 20             	add    $0x20,%esp
  801042:	85 c0                	test   %eax,%eax
  801044:	0f 88 a5 00 00 00    	js     8010ef <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  80104a:	83 ec 0c             	sub    $0xc,%esp
  80104d:	68 05 08 00 00       	push   $0x805
  801052:	53                   	push   %ebx
  801053:	6a 00                	push   $0x0
  801055:	53                   	push   %ebx
  801056:	6a 00                	push   $0x0
  801058:	e8 5f fc ff ff       	call   800cbc <sys_page_map>
  80105d:	83 c4 20             	add    $0x20,%esp
  801060:	85 c0                	test   %eax,%eax
  801062:	b9 00 00 00 00       	mov    $0x0,%ecx
  801067:	0f 4f c1             	cmovg  %ecx,%eax
  80106a:	eb 1c                	jmp    801088 <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  80106c:	83 ec 0c             	sub    $0xc,%esp
  80106f:	6a 05                	push   $0x5
  801071:	53                   	push   %ebx
  801072:	57                   	push   %edi
  801073:	53                   	push   %ebx
  801074:	6a 00                	push   $0x0
  801076:	e8 41 fc ff ff       	call   800cbc <sys_page_map>
  80107b:	83 c4 20             	add    $0x20,%esp
  80107e:	85 c0                	test   %eax,%eax
  801080:	b9 00 00 00 00       	mov    $0x0,%ecx
  801085:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  801088:	85 c0                	test   %eax,%eax
  80108a:	78 67                	js     8010f3 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  80108c:	83 c6 01             	add    $0x1,%esi
  80108f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801095:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  80109b:	0f 85 1a ff ff ff    	jne    800fbb <fork+0x59>
  8010a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  8010a4:	83 ec 04             	sub    $0x4,%esp
  8010a7:	6a 07                	push   $0x7
  8010a9:	68 00 f0 bf ee       	push   $0xeebff000
  8010ae:	57                   	push   %edi
  8010af:	e8 c5 fb ff ff       	call   800c79 <sys_page_alloc>
	if (r < 0)
  8010b4:	83 c4 10             	add    $0x10,%esp
		return r;
  8010b7:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  8010b9:	85 c0                	test   %eax,%eax
  8010bb:	78 38                	js     8010f5 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010bd:	83 ec 08             	sub    $0x8,%esp
  8010c0:	68 f3 22 80 00       	push   $0x8022f3
  8010c5:	57                   	push   %edi
  8010c6:	e8 f9 fc ff ff       	call   800dc4 <sys_env_set_pgfault_upcall>
	if (r < 0)
  8010cb:	83 c4 10             	add    $0x10,%esp
		return r;
  8010ce:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  8010d0:	85 c0                	test   %eax,%eax
  8010d2:	78 21                	js     8010f5 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  8010d4:	83 ec 08             	sub    $0x8,%esp
  8010d7:	6a 02                	push   $0x2
  8010d9:	57                   	push   %edi
  8010da:	e8 61 fc ff ff       	call   800d40 <sys_env_set_status>
	if (r < 0)
  8010df:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  8010e2:	85 c0                	test   %eax,%eax
  8010e4:	0f 48 f8             	cmovs  %eax,%edi
  8010e7:	89 fa                	mov    %edi,%edx
  8010e9:	eb 0a                	jmp    8010f5 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  8010eb:	89 c2                	mov    %eax,%edx
  8010ed:	eb 06                	jmp    8010f5 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  8010ef:	89 c2                	mov    %eax,%edx
  8010f1:	eb 02                	jmp    8010f5 <fork+0x193>
  8010f3:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  8010f5:	89 d0                	mov    %edx,%eax
  8010f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fa:	5b                   	pop    %ebx
  8010fb:	5e                   	pop    %esi
  8010fc:	5f                   	pop    %edi
  8010fd:	5d                   	pop    %ebp
  8010fe:	c3                   	ret    

008010ff <sfork>:

// Challenge!
int
sfork(void)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801105:	68 0b 2c 80 00       	push   $0x802c0b
  80110a:	68 c9 00 00 00       	push   $0xc9
  80110f:	68 00 2c 80 00       	push   $0x802c00
  801114:	e8 ff f0 ff ff       	call   800218 <_panic>

00801119 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80111c:	8b 45 08             	mov    0x8(%ebp),%eax
  80111f:	05 00 00 00 30       	add    $0x30000000,%eax
  801124:	c1 e8 0c             	shr    $0xc,%eax
}
  801127:	5d                   	pop    %ebp
  801128:	c3                   	ret    

00801129 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801129:	55                   	push   %ebp
  80112a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80112c:	8b 45 08             	mov    0x8(%ebp),%eax
  80112f:	05 00 00 00 30       	add    $0x30000000,%eax
  801134:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801139:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80113e:	5d                   	pop    %ebp
  80113f:	c3                   	ret    

00801140 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801146:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80114b:	89 c2                	mov    %eax,%edx
  80114d:	c1 ea 16             	shr    $0x16,%edx
  801150:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801157:	f6 c2 01             	test   $0x1,%dl
  80115a:	74 11                	je     80116d <fd_alloc+0x2d>
  80115c:	89 c2                	mov    %eax,%edx
  80115e:	c1 ea 0c             	shr    $0xc,%edx
  801161:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801168:	f6 c2 01             	test   $0x1,%dl
  80116b:	75 09                	jne    801176 <fd_alloc+0x36>
			*fd_store = fd;
  80116d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80116f:	b8 00 00 00 00       	mov    $0x0,%eax
  801174:	eb 17                	jmp    80118d <fd_alloc+0x4d>
  801176:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80117b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801180:	75 c9                	jne    80114b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801182:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801188:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80118d:	5d                   	pop    %ebp
  80118e:	c3                   	ret    

0080118f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80118f:	55                   	push   %ebp
  801190:	89 e5                	mov    %esp,%ebp
  801192:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801195:	83 f8 1f             	cmp    $0x1f,%eax
  801198:	77 36                	ja     8011d0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80119a:	c1 e0 0c             	shl    $0xc,%eax
  80119d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011a2:	89 c2                	mov    %eax,%edx
  8011a4:	c1 ea 16             	shr    $0x16,%edx
  8011a7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011ae:	f6 c2 01             	test   $0x1,%dl
  8011b1:	74 24                	je     8011d7 <fd_lookup+0x48>
  8011b3:	89 c2                	mov    %eax,%edx
  8011b5:	c1 ea 0c             	shr    $0xc,%edx
  8011b8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011bf:	f6 c2 01             	test   $0x1,%dl
  8011c2:	74 1a                	je     8011de <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c7:	89 02                	mov    %eax,(%edx)
	return 0;
  8011c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ce:	eb 13                	jmp    8011e3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d5:	eb 0c                	jmp    8011e3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011dc:	eb 05                	jmp    8011e3 <fd_lookup+0x54>
  8011de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    

008011e5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	83 ec 08             	sub    $0x8,%esp
  8011eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ee:	ba a4 2c 80 00       	mov    $0x802ca4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011f3:	eb 13                	jmp    801208 <dev_lookup+0x23>
  8011f5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011f8:	39 08                	cmp    %ecx,(%eax)
  8011fa:	75 0c                	jne    801208 <dev_lookup+0x23>
			*dev = devtab[i];
  8011fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ff:	89 01                	mov    %eax,(%ecx)
			return 0;
  801201:	b8 00 00 00 00       	mov    $0x0,%eax
  801206:	eb 2e                	jmp    801236 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801208:	8b 02                	mov    (%edx),%eax
  80120a:	85 c0                	test   %eax,%eax
  80120c:	75 e7                	jne    8011f5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80120e:	a1 20 44 80 00       	mov    0x804420,%eax
  801213:	8b 40 48             	mov    0x48(%eax),%eax
  801216:	83 ec 04             	sub    $0x4,%esp
  801219:	51                   	push   %ecx
  80121a:	50                   	push   %eax
  80121b:	68 24 2c 80 00       	push   $0x802c24
  801220:	e8 cc f0 ff ff       	call   8002f1 <cprintf>
	*dev = 0;
  801225:	8b 45 0c             	mov    0xc(%ebp),%eax
  801228:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80122e:	83 c4 10             	add    $0x10,%esp
  801231:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801236:	c9                   	leave  
  801237:	c3                   	ret    

00801238 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	56                   	push   %esi
  80123c:	53                   	push   %ebx
  80123d:	83 ec 10             	sub    $0x10,%esp
  801240:	8b 75 08             	mov    0x8(%ebp),%esi
  801243:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801246:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801249:	50                   	push   %eax
  80124a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801250:	c1 e8 0c             	shr    $0xc,%eax
  801253:	50                   	push   %eax
  801254:	e8 36 ff ff ff       	call   80118f <fd_lookup>
  801259:	83 c4 08             	add    $0x8,%esp
  80125c:	85 c0                	test   %eax,%eax
  80125e:	78 05                	js     801265 <fd_close+0x2d>
	    || fd != fd2)
  801260:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801263:	74 0c                	je     801271 <fd_close+0x39>
		return (must_exist ? r : 0);
  801265:	84 db                	test   %bl,%bl
  801267:	ba 00 00 00 00       	mov    $0x0,%edx
  80126c:	0f 44 c2             	cmove  %edx,%eax
  80126f:	eb 41                	jmp    8012b2 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801271:	83 ec 08             	sub    $0x8,%esp
  801274:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801277:	50                   	push   %eax
  801278:	ff 36                	pushl  (%esi)
  80127a:	e8 66 ff ff ff       	call   8011e5 <dev_lookup>
  80127f:	89 c3                	mov    %eax,%ebx
  801281:	83 c4 10             	add    $0x10,%esp
  801284:	85 c0                	test   %eax,%eax
  801286:	78 1a                	js     8012a2 <fd_close+0x6a>
		if (dev->dev_close)
  801288:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80128e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801293:	85 c0                	test   %eax,%eax
  801295:	74 0b                	je     8012a2 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801297:	83 ec 0c             	sub    $0xc,%esp
  80129a:	56                   	push   %esi
  80129b:	ff d0                	call   *%eax
  80129d:	89 c3                	mov    %eax,%ebx
  80129f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012a2:	83 ec 08             	sub    $0x8,%esp
  8012a5:	56                   	push   %esi
  8012a6:	6a 00                	push   $0x0
  8012a8:	e8 51 fa ff ff       	call   800cfe <sys_page_unmap>
	return r;
  8012ad:	83 c4 10             	add    $0x10,%esp
  8012b0:	89 d8                	mov    %ebx,%eax
}
  8012b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b5:	5b                   	pop    %ebx
  8012b6:	5e                   	pop    %esi
  8012b7:	5d                   	pop    %ebp
  8012b8:	c3                   	ret    

008012b9 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012b9:	55                   	push   %ebp
  8012ba:	89 e5                	mov    %esp,%ebp
  8012bc:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c2:	50                   	push   %eax
  8012c3:	ff 75 08             	pushl  0x8(%ebp)
  8012c6:	e8 c4 fe ff ff       	call   80118f <fd_lookup>
  8012cb:	83 c4 08             	add    $0x8,%esp
  8012ce:	85 c0                	test   %eax,%eax
  8012d0:	78 10                	js     8012e2 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012d2:	83 ec 08             	sub    $0x8,%esp
  8012d5:	6a 01                	push   $0x1
  8012d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8012da:	e8 59 ff ff ff       	call   801238 <fd_close>
  8012df:	83 c4 10             	add    $0x10,%esp
}
  8012e2:	c9                   	leave  
  8012e3:	c3                   	ret    

008012e4 <close_all>:

void
close_all(void)
{
  8012e4:	55                   	push   %ebp
  8012e5:	89 e5                	mov    %esp,%ebp
  8012e7:	53                   	push   %ebx
  8012e8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012eb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012f0:	83 ec 0c             	sub    $0xc,%esp
  8012f3:	53                   	push   %ebx
  8012f4:	e8 c0 ff ff ff       	call   8012b9 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012f9:	83 c3 01             	add    $0x1,%ebx
  8012fc:	83 c4 10             	add    $0x10,%esp
  8012ff:	83 fb 20             	cmp    $0x20,%ebx
  801302:	75 ec                	jne    8012f0 <close_all+0xc>
		close(i);
}
  801304:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801307:	c9                   	leave  
  801308:	c3                   	ret    

00801309 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801309:	55                   	push   %ebp
  80130a:	89 e5                	mov    %esp,%ebp
  80130c:	57                   	push   %edi
  80130d:	56                   	push   %esi
  80130e:	53                   	push   %ebx
  80130f:	83 ec 2c             	sub    $0x2c,%esp
  801312:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801315:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801318:	50                   	push   %eax
  801319:	ff 75 08             	pushl  0x8(%ebp)
  80131c:	e8 6e fe ff ff       	call   80118f <fd_lookup>
  801321:	83 c4 08             	add    $0x8,%esp
  801324:	85 c0                	test   %eax,%eax
  801326:	0f 88 c1 00 00 00    	js     8013ed <dup+0xe4>
		return r;
	close(newfdnum);
  80132c:	83 ec 0c             	sub    $0xc,%esp
  80132f:	56                   	push   %esi
  801330:	e8 84 ff ff ff       	call   8012b9 <close>

	newfd = INDEX2FD(newfdnum);
  801335:	89 f3                	mov    %esi,%ebx
  801337:	c1 e3 0c             	shl    $0xc,%ebx
  80133a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801340:	83 c4 04             	add    $0x4,%esp
  801343:	ff 75 e4             	pushl  -0x1c(%ebp)
  801346:	e8 de fd ff ff       	call   801129 <fd2data>
  80134b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80134d:	89 1c 24             	mov    %ebx,(%esp)
  801350:	e8 d4 fd ff ff       	call   801129 <fd2data>
  801355:	83 c4 10             	add    $0x10,%esp
  801358:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80135b:	89 f8                	mov    %edi,%eax
  80135d:	c1 e8 16             	shr    $0x16,%eax
  801360:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801367:	a8 01                	test   $0x1,%al
  801369:	74 37                	je     8013a2 <dup+0x99>
  80136b:	89 f8                	mov    %edi,%eax
  80136d:	c1 e8 0c             	shr    $0xc,%eax
  801370:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801377:	f6 c2 01             	test   $0x1,%dl
  80137a:	74 26                	je     8013a2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80137c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801383:	83 ec 0c             	sub    $0xc,%esp
  801386:	25 07 0e 00 00       	and    $0xe07,%eax
  80138b:	50                   	push   %eax
  80138c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80138f:	6a 00                	push   $0x0
  801391:	57                   	push   %edi
  801392:	6a 00                	push   $0x0
  801394:	e8 23 f9 ff ff       	call   800cbc <sys_page_map>
  801399:	89 c7                	mov    %eax,%edi
  80139b:	83 c4 20             	add    $0x20,%esp
  80139e:	85 c0                	test   %eax,%eax
  8013a0:	78 2e                	js     8013d0 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013a2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013a5:	89 d0                	mov    %edx,%eax
  8013a7:	c1 e8 0c             	shr    $0xc,%eax
  8013aa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013b1:	83 ec 0c             	sub    $0xc,%esp
  8013b4:	25 07 0e 00 00       	and    $0xe07,%eax
  8013b9:	50                   	push   %eax
  8013ba:	53                   	push   %ebx
  8013bb:	6a 00                	push   $0x0
  8013bd:	52                   	push   %edx
  8013be:	6a 00                	push   $0x0
  8013c0:	e8 f7 f8 ff ff       	call   800cbc <sys_page_map>
  8013c5:	89 c7                	mov    %eax,%edi
  8013c7:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013ca:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013cc:	85 ff                	test   %edi,%edi
  8013ce:	79 1d                	jns    8013ed <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013d0:	83 ec 08             	sub    $0x8,%esp
  8013d3:	53                   	push   %ebx
  8013d4:	6a 00                	push   $0x0
  8013d6:	e8 23 f9 ff ff       	call   800cfe <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013db:	83 c4 08             	add    $0x8,%esp
  8013de:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013e1:	6a 00                	push   $0x0
  8013e3:	e8 16 f9 ff ff       	call   800cfe <sys_page_unmap>
	return r;
  8013e8:	83 c4 10             	add    $0x10,%esp
  8013eb:	89 f8                	mov    %edi,%eax
}
  8013ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013f0:	5b                   	pop    %ebx
  8013f1:	5e                   	pop    %esi
  8013f2:	5f                   	pop    %edi
  8013f3:	5d                   	pop    %ebp
  8013f4:	c3                   	ret    

008013f5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013f5:	55                   	push   %ebp
  8013f6:	89 e5                	mov    %esp,%ebp
  8013f8:	53                   	push   %ebx
  8013f9:	83 ec 14             	sub    $0x14,%esp
  8013fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801402:	50                   	push   %eax
  801403:	53                   	push   %ebx
  801404:	e8 86 fd ff ff       	call   80118f <fd_lookup>
  801409:	83 c4 08             	add    $0x8,%esp
  80140c:	89 c2                	mov    %eax,%edx
  80140e:	85 c0                	test   %eax,%eax
  801410:	78 6d                	js     80147f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801412:	83 ec 08             	sub    $0x8,%esp
  801415:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801418:	50                   	push   %eax
  801419:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141c:	ff 30                	pushl  (%eax)
  80141e:	e8 c2 fd ff ff       	call   8011e5 <dev_lookup>
  801423:	83 c4 10             	add    $0x10,%esp
  801426:	85 c0                	test   %eax,%eax
  801428:	78 4c                	js     801476 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80142a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80142d:	8b 42 08             	mov    0x8(%edx),%eax
  801430:	83 e0 03             	and    $0x3,%eax
  801433:	83 f8 01             	cmp    $0x1,%eax
  801436:	75 21                	jne    801459 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801438:	a1 20 44 80 00       	mov    0x804420,%eax
  80143d:	8b 40 48             	mov    0x48(%eax),%eax
  801440:	83 ec 04             	sub    $0x4,%esp
  801443:	53                   	push   %ebx
  801444:	50                   	push   %eax
  801445:	68 68 2c 80 00       	push   $0x802c68
  80144a:	e8 a2 ee ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801457:	eb 26                	jmp    80147f <read+0x8a>
	}
	if (!dev->dev_read)
  801459:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80145c:	8b 40 08             	mov    0x8(%eax),%eax
  80145f:	85 c0                	test   %eax,%eax
  801461:	74 17                	je     80147a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801463:	83 ec 04             	sub    $0x4,%esp
  801466:	ff 75 10             	pushl  0x10(%ebp)
  801469:	ff 75 0c             	pushl  0xc(%ebp)
  80146c:	52                   	push   %edx
  80146d:	ff d0                	call   *%eax
  80146f:	89 c2                	mov    %eax,%edx
  801471:	83 c4 10             	add    $0x10,%esp
  801474:	eb 09                	jmp    80147f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801476:	89 c2                	mov    %eax,%edx
  801478:	eb 05                	jmp    80147f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80147a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80147f:	89 d0                	mov    %edx,%eax
  801481:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801484:	c9                   	leave  
  801485:	c3                   	ret    

00801486 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801486:	55                   	push   %ebp
  801487:	89 e5                	mov    %esp,%ebp
  801489:	57                   	push   %edi
  80148a:	56                   	push   %esi
  80148b:	53                   	push   %ebx
  80148c:	83 ec 0c             	sub    $0xc,%esp
  80148f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801492:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801495:	bb 00 00 00 00       	mov    $0x0,%ebx
  80149a:	eb 21                	jmp    8014bd <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80149c:	83 ec 04             	sub    $0x4,%esp
  80149f:	89 f0                	mov    %esi,%eax
  8014a1:	29 d8                	sub    %ebx,%eax
  8014a3:	50                   	push   %eax
  8014a4:	89 d8                	mov    %ebx,%eax
  8014a6:	03 45 0c             	add    0xc(%ebp),%eax
  8014a9:	50                   	push   %eax
  8014aa:	57                   	push   %edi
  8014ab:	e8 45 ff ff ff       	call   8013f5 <read>
		if (m < 0)
  8014b0:	83 c4 10             	add    $0x10,%esp
  8014b3:	85 c0                	test   %eax,%eax
  8014b5:	78 10                	js     8014c7 <readn+0x41>
			return m;
		if (m == 0)
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	74 0a                	je     8014c5 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014bb:	01 c3                	add    %eax,%ebx
  8014bd:	39 f3                	cmp    %esi,%ebx
  8014bf:	72 db                	jb     80149c <readn+0x16>
  8014c1:	89 d8                	mov    %ebx,%eax
  8014c3:	eb 02                	jmp    8014c7 <readn+0x41>
  8014c5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ca:	5b                   	pop    %ebx
  8014cb:	5e                   	pop    %esi
  8014cc:	5f                   	pop    %edi
  8014cd:	5d                   	pop    %ebp
  8014ce:	c3                   	ret    

008014cf <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014cf:	55                   	push   %ebp
  8014d0:	89 e5                	mov    %esp,%ebp
  8014d2:	53                   	push   %ebx
  8014d3:	83 ec 14             	sub    $0x14,%esp
  8014d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014dc:	50                   	push   %eax
  8014dd:	53                   	push   %ebx
  8014de:	e8 ac fc ff ff       	call   80118f <fd_lookup>
  8014e3:	83 c4 08             	add    $0x8,%esp
  8014e6:	89 c2                	mov    %eax,%edx
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	78 68                	js     801554 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ec:	83 ec 08             	sub    $0x8,%esp
  8014ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f2:	50                   	push   %eax
  8014f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f6:	ff 30                	pushl  (%eax)
  8014f8:	e8 e8 fc ff ff       	call   8011e5 <dev_lookup>
  8014fd:	83 c4 10             	add    $0x10,%esp
  801500:	85 c0                	test   %eax,%eax
  801502:	78 47                	js     80154b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801504:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801507:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80150b:	75 21                	jne    80152e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80150d:	a1 20 44 80 00       	mov    0x804420,%eax
  801512:	8b 40 48             	mov    0x48(%eax),%eax
  801515:	83 ec 04             	sub    $0x4,%esp
  801518:	53                   	push   %ebx
  801519:	50                   	push   %eax
  80151a:	68 84 2c 80 00       	push   $0x802c84
  80151f:	e8 cd ed ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80152c:	eb 26                	jmp    801554 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80152e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801531:	8b 52 0c             	mov    0xc(%edx),%edx
  801534:	85 d2                	test   %edx,%edx
  801536:	74 17                	je     80154f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801538:	83 ec 04             	sub    $0x4,%esp
  80153b:	ff 75 10             	pushl  0x10(%ebp)
  80153e:	ff 75 0c             	pushl  0xc(%ebp)
  801541:	50                   	push   %eax
  801542:	ff d2                	call   *%edx
  801544:	89 c2                	mov    %eax,%edx
  801546:	83 c4 10             	add    $0x10,%esp
  801549:	eb 09                	jmp    801554 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154b:	89 c2                	mov    %eax,%edx
  80154d:	eb 05                	jmp    801554 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80154f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801554:	89 d0                	mov    %edx,%eax
  801556:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801559:	c9                   	leave  
  80155a:	c3                   	ret    

0080155b <seek>:

int
seek(int fdnum, off_t offset)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801561:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801564:	50                   	push   %eax
  801565:	ff 75 08             	pushl  0x8(%ebp)
  801568:	e8 22 fc ff ff       	call   80118f <fd_lookup>
  80156d:	83 c4 08             	add    $0x8,%esp
  801570:	85 c0                	test   %eax,%eax
  801572:	78 0e                	js     801582 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801574:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801577:	8b 55 0c             	mov    0xc(%ebp),%edx
  80157a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80157d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801582:	c9                   	leave  
  801583:	c3                   	ret    

00801584 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801584:	55                   	push   %ebp
  801585:	89 e5                	mov    %esp,%ebp
  801587:	53                   	push   %ebx
  801588:	83 ec 14             	sub    $0x14,%esp
  80158b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80158e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801591:	50                   	push   %eax
  801592:	53                   	push   %ebx
  801593:	e8 f7 fb ff ff       	call   80118f <fd_lookup>
  801598:	83 c4 08             	add    $0x8,%esp
  80159b:	89 c2                	mov    %eax,%edx
  80159d:	85 c0                	test   %eax,%eax
  80159f:	78 65                	js     801606 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a1:	83 ec 08             	sub    $0x8,%esp
  8015a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a7:	50                   	push   %eax
  8015a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ab:	ff 30                	pushl  (%eax)
  8015ad:	e8 33 fc ff ff       	call   8011e5 <dev_lookup>
  8015b2:	83 c4 10             	add    $0x10,%esp
  8015b5:	85 c0                	test   %eax,%eax
  8015b7:	78 44                	js     8015fd <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015bc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015c0:	75 21                	jne    8015e3 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015c2:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015c7:	8b 40 48             	mov    0x48(%eax),%eax
  8015ca:	83 ec 04             	sub    $0x4,%esp
  8015cd:	53                   	push   %ebx
  8015ce:	50                   	push   %eax
  8015cf:	68 44 2c 80 00       	push   $0x802c44
  8015d4:	e8 18 ed ff ff       	call   8002f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015d9:	83 c4 10             	add    $0x10,%esp
  8015dc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015e1:	eb 23                	jmp    801606 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015e6:	8b 52 18             	mov    0x18(%edx),%edx
  8015e9:	85 d2                	test   %edx,%edx
  8015eb:	74 14                	je     801601 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015ed:	83 ec 08             	sub    $0x8,%esp
  8015f0:	ff 75 0c             	pushl  0xc(%ebp)
  8015f3:	50                   	push   %eax
  8015f4:	ff d2                	call   *%edx
  8015f6:	89 c2                	mov    %eax,%edx
  8015f8:	83 c4 10             	add    $0x10,%esp
  8015fb:	eb 09                	jmp    801606 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015fd:	89 c2                	mov    %eax,%edx
  8015ff:	eb 05                	jmp    801606 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801601:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801606:	89 d0                	mov    %edx,%eax
  801608:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80160b:	c9                   	leave  
  80160c:	c3                   	ret    

0080160d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80160d:	55                   	push   %ebp
  80160e:	89 e5                	mov    %esp,%ebp
  801610:	53                   	push   %ebx
  801611:	83 ec 14             	sub    $0x14,%esp
  801614:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801617:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80161a:	50                   	push   %eax
  80161b:	ff 75 08             	pushl  0x8(%ebp)
  80161e:	e8 6c fb ff ff       	call   80118f <fd_lookup>
  801623:	83 c4 08             	add    $0x8,%esp
  801626:	89 c2                	mov    %eax,%edx
  801628:	85 c0                	test   %eax,%eax
  80162a:	78 58                	js     801684 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162c:	83 ec 08             	sub    $0x8,%esp
  80162f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801632:	50                   	push   %eax
  801633:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801636:	ff 30                	pushl  (%eax)
  801638:	e8 a8 fb ff ff       	call   8011e5 <dev_lookup>
  80163d:	83 c4 10             	add    $0x10,%esp
  801640:	85 c0                	test   %eax,%eax
  801642:	78 37                	js     80167b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801644:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801647:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80164b:	74 32                	je     80167f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80164d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801650:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801657:	00 00 00 
	stat->st_isdir = 0;
  80165a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801661:	00 00 00 
	stat->st_dev = dev;
  801664:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80166a:	83 ec 08             	sub    $0x8,%esp
  80166d:	53                   	push   %ebx
  80166e:	ff 75 f0             	pushl  -0x10(%ebp)
  801671:	ff 50 14             	call   *0x14(%eax)
  801674:	89 c2                	mov    %eax,%edx
  801676:	83 c4 10             	add    $0x10,%esp
  801679:	eb 09                	jmp    801684 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167b:	89 c2                	mov    %eax,%edx
  80167d:	eb 05                	jmp    801684 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80167f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801684:	89 d0                	mov    %edx,%eax
  801686:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801689:	c9                   	leave  
  80168a:	c3                   	ret    

0080168b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	56                   	push   %esi
  80168f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801690:	83 ec 08             	sub    $0x8,%esp
  801693:	6a 00                	push   $0x0
  801695:	ff 75 08             	pushl  0x8(%ebp)
  801698:	e8 d6 01 00 00       	call   801873 <open>
  80169d:	89 c3                	mov    %eax,%ebx
  80169f:	83 c4 10             	add    $0x10,%esp
  8016a2:	85 c0                	test   %eax,%eax
  8016a4:	78 1b                	js     8016c1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016a6:	83 ec 08             	sub    $0x8,%esp
  8016a9:	ff 75 0c             	pushl  0xc(%ebp)
  8016ac:	50                   	push   %eax
  8016ad:	e8 5b ff ff ff       	call   80160d <fstat>
  8016b2:	89 c6                	mov    %eax,%esi
	close(fd);
  8016b4:	89 1c 24             	mov    %ebx,(%esp)
  8016b7:	e8 fd fb ff ff       	call   8012b9 <close>
	return r;
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	89 f0                	mov    %esi,%eax
}
  8016c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c4:	5b                   	pop    %ebx
  8016c5:	5e                   	pop    %esi
  8016c6:	5d                   	pop    %ebp
  8016c7:	c3                   	ret    

008016c8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	56                   	push   %esi
  8016cc:	53                   	push   %ebx
  8016cd:	89 c6                	mov    %eax,%esi
  8016cf:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016d1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016d8:	75 12                	jne    8016ec <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016da:	83 ec 0c             	sub    $0xc,%esp
  8016dd:	6a 01                	push   $0x1
  8016df:	e8 ee 0c 00 00       	call   8023d2 <ipc_find_env>
  8016e4:	a3 00 40 80 00       	mov    %eax,0x804000
  8016e9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016ec:	6a 07                	push   $0x7
  8016ee:	68 00 50 80 00       	push   $0x805000
  8016f3:	56                   	push   %esi
  8016f4:	ff 35 00 40 80 00    	pushl  0x804000
  8016fa:	e8 7f 0c 00 00       	call   80237e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016ff:	83 c4 0c             	add    $0xc,%esp
  801702:	6a 00                	push   $0x0
  801704:	53                   	push   %ebx
  801705:	6a 00                	push   $0x0
  801707:	e8 0b 0c 00 00       	call   802317 <ipc_recv>
}
  80170c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80170f:	5b                   	pop    %ebx
  801710:	5e                   	pop    %esi
  801711:	5d                   	pop    %ebp
  801712:	c3                   	ret    

00801713 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801719:	8b 45 08             	mov    0x8(%ebp),%eax
  80171c:	8b 40 0c             	mov    0xc(%eax),%eax
  80171f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801724:	8b 45 0c             	mov    0xc(%ebp),%eax
  801727:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80172c:	ba 00 00 00 00       	mov    $0x0,%edx
  801731:	b8 02 00 00 00       	mov    $0x2,%eax
  801736:	e8 8d ff ff ff       	call   8016c8 <fsipc>
}
  80173b:	c9                   	leave  
  80173c:	c3                   	ret    

0080173d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80173d:	55                   	push   %ebp
  80173e:	89 e5                	mov    %esp,%ebp
  801740:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801743:	8b 45 08             	mov    0x8(%ebp),%eax
  801746:	8b 40 0c             	mov    0xc(%eax),%eax
  801749:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80174e:	ba 00 00 00 00       	mov    $0x0,%edx
  801753:	b8 06 00 00 00       	mov    $0x6,%eax
  801758:	e8 6b ff ff ff       	call   8016c8 <fsipc>
}
  80175d:	c9                   	leave  
  80175e:	c3                   	ret    

0080175f <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80175f:	55                   	push   %ebp
  801760:	89 e5                	mov    %esp,%ebp
  801762:	53                   	push   %ebx
  801763:	83 ec 04             	sub    $0x4,%esp
  801766:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801769:	8b 45 08             	mov    0x8(%ebp),%eax
  80176c:	8b 40 0c             	mov    0xc(%eax),%eax
  80176f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801774:	ba 00 00 00 00       	mov    $0x0,%edx
  801779:	b8 05 00 00 00       	mov    $0x5,%eax
  80177e:	e8 45 ff ff ff       	call   8016c8 <fsipc>
  801783:	85 c0                	test   %eax,%eax
  801785:	78 2c                	js     8017b3 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801787:	83 ec 08             	sub    $0x8,%esp
  80178a:	68 00 50 80 00       	push   $0x805000
  80178f:	53                   	push   %ebx
  801790:	e8 e1 f0 ff ff       	call   800876 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801795:	a1 80 50 80 00       	mov    0x805080,%eax
  80179a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017a0:	a1 84 50 80 00       	mov    0x805084,%eax
  8017a5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017ab:	83 c4 10             	add    $0x10,%esp
  8017ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b6:	c9                   	leave  
  8017b7:	c3                   	ret    

008017b8 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017b8:	55                   	push   %ebp
  8017b9:	89 e5                	mov    %esp,%ebp
  8017bb:	83 ec 0c             	sub    $0xc,%esp
  8017be:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8017c4:	8b 52 0c             	mov    0xc(%edx),%edx
  8017c7:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017cd:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017d2:	50                   	push   %eax
  8017d3:	ff 75 0c             	pushl  0xc(%ebp)
  8017d6:	68 08 50 80 00       	push   $0x805008
  8017db:	e8 28 f2 ff ff       	call   800a08 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8017e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e5:	b8 04 00 00 00       	mov    $0x4,%eax
  8017ea:	e8 d9 fe ff ff       	call   8016c8 <fsipc>

}
  8017ef:	c9                   	leave  
  8017f0:	c3                   	ret    

008017f1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017f1:	55                   	push   %ebp
  8017f2:	89 e5                	mov    %esp,%ebp
  8017f4:	56                   	push   %esi
  8017f5:	53                   	push   %ebx
  8017f6:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fc:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ff:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801804:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80180a:	ba 00 00 00 00       	mov    $0x0,%edx
  80180f:	b8 03 00 00 00       	mov    $0x3,%eax
  801814:	e8 af fe ff ff       	call   8016c8 <fsipc>
  801819:	89 c3                	mov    %eax,%ebx
  80181b:	85 c0                	test   %eax,%eax
  80181d:	78 4b                	js     80186a <devfile_read+0x79>
		return r;
	assert(r <= n);
  80181f:	39 c6                	cmp    %eax,%esi
  801821:	73 16                	jae    801839 <devfile_read+0x48>
  801823:	68 b8 2c 80 00       	push   $0x802cb8
  801828:	68 bf 2c 80 00       	push   $0x802cbf
  80182d:	6a 7c                	push   $0x7c
  80182f:	68 d4 2c 80 00       	push   $0x802cd4
  801834:	e8 df e9 ff ff       	call   800218 <_panic>
	assert(r <= PGSIZE);
  801839:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80183e:	7e 16                	jle    801856 <devfile_read+0x65>
  801840:	68 df 2c 80 00       	push   $0x802cdf
  801845:	68 bf 2c 80 00       	push   $0x802cbf
  80184a:	6a 7d                	push   $0x7d
  80184c:	68 d4 2c 80 00       	push   $0x802cd4
  801851:	e8 c2 e9 ff ff       	call   800218 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801856:	83 ec 04             	sub    $0x4,%esp
  801859:	50                   	push   %eax
  80185a:	68 00 50 80 00       	push   $0x805000
  80185f:	ff 75 0c             	pushl  0xc(%ebp)
  801862:	e8 a1 f1 ff ff       	call   800a08 <memmove>
	return r;
  801867:	83 c4 10             	add    $0x10,%esp
}
  80186a:	89 d8                	mov    %ebx,%eax
  80186c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80186f:	5b                   	pop    %ebx
  801870:	5e                   	pop    %esi
  801871:	5d                   	pop    %ebp
  801872:	c3                   	ret    

00801873 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	53                   	push   %ebx
  801877:	83 ec 20             	sub    $0x20,%esp
  80187a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80187d:	53                   	push   %ebx
  80187e:	e8 ba ef ff ff       	call   80083d <strlen>
  801883:	83 c4 10             	add    $0x10,%esp
  801886:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80188b:	7f 67                	jg     8018f4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80188d:	83 ec 0c             	sub    $0xc,%esp
  801890:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801893:	50                   	push   %eax
  801894:	e8 a7 f8 ff ff       	call   801140 <fd_alloc>
  801899:	83 c4 10             	add    $0x10,%esp
		return r;
  80189c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80189e:	85 c0                	test   %eax,%eax
  8018a0:	78 57                	js     8018f9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018a2:	83 ec 08             	sub    $0x8,%esp
  8018a5:	53                   	push   %ebx
  8018a6:	68 00 50 80 00       	push   $0x805000
  8018ab:	e8 c6 ef ff ff       	call   800876 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018bb:	b8 01 00 00 00       	mov    $0x1,%eax
  8018c0:	e8 03 fe ff ff       	call   8016c8 <fsipc>
  8018c5:	89 c3                	mov    %eax,%ebx
  8018c7:	83 c4 10             	add    $0x10,%esp
  8018ca:	85 c0                	test   %eax,%eax
  8018cc:	79 14                	jns    8018e2 <open+0x6f>
		fd_close(fd, 0);
  8018ce:	83 ec 08             	sub    $0x8,%esp
  8018d1:	6a 00                	push   $0x0
  8018d3:	ff 75 f4             	pushl  -0xc(%ebp)
  8018d6:	e8 5d f9 ff ff       	call   801238 <fd_close>
		return r;
  8018db:	83 c4 10             	add    $0x10,%esp
  8018de:	89 da                	mov    %ebx,%edx
  8018e0:	eb 17                	jmp    8018f9 <open+0x86>
	}

	return fd2num(fd);
  8018e2:	83 ec 0c             	sub    $0xc,%esp
  8018e5:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e8:	e8 2c f8 ff ff       	call   801119 <fd2num>
  8018ed:	89 c2                	mov    %eax,%edx
  8018ef:	83 c4 10             	add    $0x10,%esp
  8018f2:	eb 05                	jmp    8018f9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018f4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018f9:	89 d0                	mov    %edx,%eax
  8018fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018fe:	c9                   	leave  
  8018ff:	c3                   	ret    

00801900 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801900:	55                   	push   %ebp
  801901:	89 e5                	mov    %esp,%ebp
  801903:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801906:	ba 00 00 00 00       	mov    $0x0,%edx
  80190b:	b8 08 00 00 00       	mov    $0x8,%eax
  801910:	e8 b3 fd ff ff       	call   8016c8 <fsipc>
}
  801915:	c9                   	leave  
  801916:	c3                   	ret    

00801917 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801917:	55                   	push   %ebp
  801918:	89 e5                	mov    %esp,%ebp
  80191a:	56                   	push   %esi
  80191b:	53                   	push   %ebx
  80191c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80191f:	83 ec 0c             	sub    $0xc,%esp
  801922:	ff 75 08             	pushl  0x8(%ebp)
  801925:	e8 ff f7 ff ff       	call   801129 <fd2data>
  80192a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80192c:	83 c4 08             	add    $0x8,%esp
  80192f:	68 eb 2c 80 00       	push   $0x802ceb
  801934:	53                   	push   %ebx
  801935:	e8 3c ef ff ff       	call   800876 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80193a:	8b 46 04             	mov    0x4(%esi),%eax
  80193d:	2b 06                	sub    (%esi),%eax
  80193f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801945:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80194c:	00 00 00 
	stat->st_dev = &devpipe;
  80194f:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801956:	30 80 00 
	return 0;
}
  801959:	b8 00 00 00 00       	mov    $0x0,%eax
  80195e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801961:	5b                   	pop    %ebx
  801962:	5e                   	pop    %esi
  801963:	5d                   	pop    %ebp
  801964:	c3                   	ret    

00801965 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801965:	55                   	push   %ebp
  801966:	89 e5                	mov    %esp,%ebp
  801968:	53                   	push   %ebx
  801969:	83 ec 0c             	sub    $0xc,%esp
  80196c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80196f:	53                   	push   %ebx
  801970:	6a 00                	push   $0x0
  801972:	e8 87 f3 ff ff       	call   800cfe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801977:	89 1c 24             	mov    %ebx,(%esp)
  80197a:	e8 aa f7 ff ff       	call   801129 <fd2data>
  80197f:	83 c4 08             	add    $0x8,%esp
  801982:	50                   	push   %eax
  801983:	6a 00                	push   $0x0
  801985:	e8 74 f3 ff ff       	call   800cfe <sys_page_unmap>
}
  80198a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198d:	c9                   	leave  
  80198e:	c3                   	ret    

0080198f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80198f:	55                   	push   %ebp
  801990:	89 e5                	mov    %esp,%ebp
  801992:	57                   	push   %edi
  801993:	56                   	push   %esi
  801994:	53                   	push   %ebx
  801995:	83 ec 1c             	sub    $0x1c,%esp
  801998:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80199b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80199d:	a1 20 44 80 00       	mov    0x804420,%eax
  8019a2:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019a5:	83 ec 0c             	sub    $0xc,%esp
  8019a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8019ab:	e8 5b 0a 00 00       	call   80240b <pageref>
  8019b0:	89 c3                	mov    %eax,%ebx
  8019b2:	89 3c 24             	mov    %edi,(%esp)
  8019b5:	e8 51 0a 00 00       	call   80240b <pageref>
  8019ba:	83 c4 10             	add    $0x10,%esp
  8019bd:	39 c3                	cmp    %eax,%ebx
  8019bf:	0f 94 c1             	sete   %cl
  8019c2:	0f b6 c9             	movzbl %cl,%ecx
  8019c5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019c8:	8b 15 20 44 80 00    	mov    0x804420,%edx
  8019ce:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019d1:	39 ce                	cmp    %ecx,%esi
  8019d3:	74 1b                	je     8019f0 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8019d5:	39 c3                	cmp    %eax,%ebx
  8019d7:	75 c4                	jne    80199d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019d9:	8b 42 58             	mov    0x58(%edx),%eax
  8019dc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019df:	50                   	push   %eax
  8019e0:	56                   	push   %esi
  8019e1:	68 f2 2c 80 00       	push   $0x802cf2
  8019e6:	e8 06 e9 ff ff       	call   8002f1 <cprintf>
  8019eb:	83 c4 10             	add    $0x10,%esp
  8019ee:	eb ad                	jmp    80199d <_pipeisclosed+0xe>
	}
}
  8019f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019f6:	5b                   	pop    %ebx
  8019f7:	5e                   	pop    %esi
  8019f8:	5f                   	pop    %edi
  8019f9:	5d                   	pop    %ebp
  8019fa:	c3                   	ret    

008019fb <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019fb:	55                   	push   %ebp
  8019fc:	89 e5                	mov    %esp,%ebp
  8019fe:	57                   	push   %edi
  8019ff:	56                   	push   %esi
  801a00:	53                   	push   %ebx
  801a01:	83 ec 28             	sub    $0x28,%esp
  801a04:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a07:	56                   	push   %esi
  801a08:	e8 1c f7 ff ff       	call   801129 <fd2data>
  801a0d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a0f:	83 c4 10             	add    $0x10,%esp
  801a12:	bf 00 00 00 00       	mov    $0x0,%edi
  801a17:	eb 4b                	jmp    801a64 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a19:	89 da                	mov    %ebx,%edx
  801a1b:	89 f0                	mov    %esi,%eax
  801a1d:	e8 6d ff ff ff       	call   80198f <_pipeisclosed>
  801a22:	85 c0                	test   %eax,%eax
  801a24:	75 48                	jne    801a6e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a26:	e8 2f f2 ff ff       	call   800c5a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a2b:	8b 43 04             	mov    0x4(%ebx),%eax
  801a2e:	8b 0b                	mov    (%ebx),%ecx
  801a30:	8d 51 20             	lea    0x20(%ecx),%edx
  801a33:	39 d0                	cmp    %edx,%eax
  801a35:	73 e2                	jae    801a19 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a3a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a3e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a41:	89 c2                	mov    %eax,%edx
  801a43:	c1 fa 1f             	sar    $0x1f,%edx
  801a46:	89 d1                	mov    %edx,%ecx
  801a48:	c1 e9 1b             	shr    $0x1b,%ecx
  801a4b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a4e:	83 e2 1f             	and    $0x1f,%edx
  801a51:	29 ca                	sub    %ecx,%edx
  801a53:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a57:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a5b:	83 c0 01             	add    $0x1,%eax
  801a5e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a61:	83 c7 01             	add    $0x1,%edi
  801a64:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a67:	75 c2                	jne    801a2b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a69:	8b 45 10             	mov    0x10(%ebp),%eax
  801a6c:	eb 05                	jmp    801a73 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a6e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a76:	5b                   	pop    %ebx
  801a77:	5e                   	pop    %esi
  801a78:	5f                   	pop    %edi
  801a79:	5d                   	pop    %ebp
  801a7a:	c3                   	ret    

00801a7b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	57                   	push   %edi
  801a7f:	56                   	push   %esi
  801a80:	53                   	push   %ebx
  801a81:	83 ec 18             	sub    $0x18,%esp
  801a84:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a87:	57                   	push   %edi
  801a88:	e8 9c f6 ff ff       	call   801129 <fd2data>
  801a8d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a8f:	83 c4 10             	add    $0x10,%esp
  801a92:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a97:	eb 3d                	jmp    801ad6 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a99:	85 db                	test   %ebx,%ebx
  801a9b:	74 04                	je     801aa1 <devpipe_read+0x26>
				return i;
  801a9d:	89 d8                	mov    %ebx,%eax
  801a9f:	eb 44                	jmp    801ae5 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801aa1:	89 f2                	mov    %esi,%edx
  801aa3:	89 f8                	mov    %edi,%eax
  801aa5:	e8 e5 fe ff ff       	call   80198f <_pipeisclosed>
  801aaa:	85 c0                	test   %eax,%eax
  801aac:	75 32                	jne    801ae0 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801aae:	e8 a7 f1 ff ff       	call   800c5a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ab3:	8b 06                	mov    (%esi),%eax
  801ab5:	3b 46 04             	cmp    0x4(%esi),%eax
  801ab8:	74 df                	je     801a99 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801aba:	99                   	cltd   
  801abb:	c1 ea 1b             	shr    $0x1b,%edx
  801abe:	01 d0                	add    %edx,%eax
  801ac0:	83 e0 1f             	and    $0x1f,%eax
  801ac3:	29 d0                	sub    %edx,%eax
  801ac5:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801aca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801acd:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ad0:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ad3:	83 c3 01             	add    $0x1,%ebx
  801ad6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ad9:	75 d8                	jne    801ab3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801adb:	8b 45 10             	mov    0x10(%ebp),%eax
  801ade:	eb 05                	jmp    801ae5 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ae0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ae5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae8:	5b                   	pop    %ebx
  801ae9:	5e                   	pop    %esi
  801aea:	5f                   	pop    %edi
  801aeb:	5d                   	pop    %ebp
  801aec:	c3                   	ret    

00801aed <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801aed:	55                   	push   %ebp
  801aee:	89 e5                	mov    %esp,%ebp
  801af0:	56                   	push   %esi
  801af1:	53                   	push   %ebx
  801af2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801af5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801af8:	50                   	push   %eax
  801af9:	e8 42 f6 ff ff       	call   801140 <fd_alloc>
  801afe:	83 c4 10             	add    $0x10,%esp
  801b01:	89 c2                	mov    %eax,%edx
  801b03:	85 c0                	test   %eax,%eax
  801b05:	0f 88 2c 01 00 00    	js     801c37 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b0b:	83 ec 04             	sub    $0x4,%esp
  801b0e:	68 07 04 00 00       	push   $0x407
  801b13:	ff 75 f4             	pushl  -0xc(%ebp)
  801b16:	6a 00                	push   $0x0
  801b18:	e8 5c f1 ff ff       	call   800c79 <sys_page_alloc>
  801b1d:	83 c4 10             	add    $0x10,%esp
  801b20:	89 c2                	mov    %eax,%edx
  801b22:	85 c0                	test   %eax,%eax
  801b24:	0f 88 0d 01 00 00    	js     801c37 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b2a:	83 ec 0c             	sub    $0xc,%esp
  801b2d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b30:	50                   	push   %eax
  801b31:	e8 0a f6 ff ff       	call   801140 <fd_alloc>
  801b36:	89 c3                	mov    %eax,%ebx
  801b38:	83 c4 10             	add    $0x10,%esp
  801b3b:	85 c0                	test   %eax,%eax
  801b3d:	0f 88 e2 00 00 00    	js     801c25 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b43:	83 ec 04             	sub    $0x4,%esp
  801b46:	68 07 04 00 00       	push   $0x407
  801b4b:	ff 75 f0             	pushl  -0x10(%ebp)
  801b4e:	6a 00                	push   $0x0
  801b50:	e8 24 f1 ff ff       	call   800c79 <sys_page_alloc>
  801b55:	89 c3                	mov    %eax,%ebx
  801b57:	83 c4 10             	add    $0x10,%esp
  801b5a:	85 c0                	test   %eax,%eax
  801b5c:	0f 88 c3 00 00 00    	js     801c25 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b62:	83 ec 0c             	sub    $0xc,%esp
  801b65:	ff 75 f4             	pushl  -0xc(%ebp)
  801b68:	e8 bc f5 ff ff       	call   801129 <fd2data>
  801b6d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b6f:	83 c4 0c             	add    $0xc,%esp
  801b72:	68 07 04 00 00       	push   $0x407
  801b77:	50                   	push   %eax
  801b78:	6a 00                	push   $0x0
  801b7a:	e8 fa f0 ff ff       	call   800c79 <sys_page_alloc>
  801b7f:	89 c3                	mov    %eax,%ebx
  801b81:	83 c4 10             	add    $0x10,%esp
  801b84:	85 c0                	test   %eax,%eax
  801b86:	0f 88 89 00 00 00    	js     801c15 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b8c:	83 ec 0c             	sub    $0xc,%esp
  801b8f:	ff 75 f0             	pushl  -0x10(%ebp)
  801b92:	e8 92 f5 ff ff       	call   801129 <fd2data>
  801b97:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b9e:	50                   	push   %eax
  801b9f:	6a 00                	push   $0x0
  801ba1:	56                   	push   %esi
  801ba2:	6a 00                	push   $0x0
  801ba4:	e8 13 f1 ff ff       	call   800cbc <sys_page_map>
  801ba9:	89 c3                	mov    %eax,%ebx
  801bab:	83 c4 20             	add    $0x20,%esp
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	78 55                	js     801c07 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bb2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bbb:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bc7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bd0:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bd5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bdc:	83 ec 0c             	sub    $0xc,%esp
  801bdf:	ff 75 f4             	pushl  -0xc(%ebp)
  801be2:	e8 32 f5 ff ff       	call   801119 <fd2num>
  801be7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bea:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bec:	83 c4 04             	add    $0x4,%esp
  801bef:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf2:	e8 22 f5 ff ff       	call   801119 <fd2num>
  801bf7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bfa:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801bfd:	83 c4 10             	add    $0x10,%esp
  801c00:	ba 00 00 00 00       	mov    $0x0,%edx
  801c05:	eb 30                	jmp    801c37 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c07:	83 ec 08             	sub    $0x8,%esp
  801c0a:	56                   	push   %esi
  801c0b:	6a 00                	push   $0x0
  801c0d:	e8 ec f0 ff ff       	call   800cfe <sys_page_unmap>
  801c12:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c15:	83 ec 08             	sub    $0x8,%esp
  801c18:	ff 75 f0             	pushl  -0x10(%ebp)
  801c1b:	6a 00                	push   $0x0
  801c1d:	e8 dc f0 ff ff       	call   800cfe <sys_page_unmap>
  801c22:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c25:	83 ec 08             	sub    $0x8,%esp
  801c28:	ff 75 f4             	pushl  -0xc(%ebp)
  801c2b:	6a 00                	push   $0x0
  801c2d:	e8 cc f0 ff ff       	call   800cfe <sys_page_unmap>
  801c32:	83 c4 10             	add    $0x10,%esp
  801c35:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c37:	89 d0                	mov    %edx,%eax
  801c39:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c3c:	5b                   	pop    %ebx
  801c3d:	5e                   	pop    %esi
  801c3e:	5d                   	pop    %ebp
  801c3f:	c3                   	ret    

00801c40 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c46:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c49:	50                   	push   %eax
  801c4a:	ff 75 08             	pushl  0x8(%ebp)
  801c4d:	e8 3d f5 ff ff       	call   80118f <fd_lookup>
  801c52:	83 c4 10             	add    $0x10,%esp
  801c55:	85 c0                	test   %eax,%eax
  801c57:	78 18                	js     801c71 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c59:	83 ec 0c             	sub    $0xc,%esp
  801c5c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5f:	e8 c5 f4 ff ff       	call   801129 <fd2data>
	return _pipeisclosed(fd, p);
  801c64:	89 c2                	mov    %eax,%edx
  801c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c69:	e8 21 fd ff ff       	call   80198f <_pipeisclosed>
  801c6e:	83 c4 10             	add    $0x10,%esp
}
  801c71:	c9                   	leave  
  801c72:	c3                   	ret    

00801c73 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801c73:	55                   	push   %ebp
  801c74:	89 e5                	mov    %esp,%ebp
  801c76:	56                   	push   %esi
  801c77:	53                   	push   %ebx
  801c78:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801c7b:	85 f6                	test   %esi,%esi
  801c7d:	75 16                	jne    801c95 <wait+0x22>
  801c7f:	68 0a 2d 80 00       	push   $0x802d0a
  801c84:	68 bf 2c 80 00       	push   $0x802cbf
  801c89:	6a 09                	push   $0x9
  801c8b:	68 15 2d 80 00       	push   $0x802d15
  801c90:	e8 83 e5 ff ff       	call   800218 <_panic>
	e = &envs[ENVX(envid)];
  801c95:	89 f3                	mov    %esi,%ebx
  801c97:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801c9d:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801ca0:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801ca6:	eb 05                	jmp    801cad <wait+0x3a>
		sys_yield();
  801ca8:	e8 ad ef ff ff       	call   800c5a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801cad:	8b 43 48             	mov    0x48(%ebx),%eax
  801cb0:	39 c6                	cmp    %eax,%esi
  801cb2:	75 07                	jne    801cbb <wait+0x48>
  801cb4:	8b 43 54             	mov    0x54(%ebx),%eax
  801cb7:	85 c0                	test   %eax,%eax
  801cb9:	75 ed                	jne    801ca8 <wait+0x35>
		sys_yield();
}
  801cbb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cbe:	5b                   	pop    %ebx
  801cbf:	5e                   	pop    %esi
  801cc0:	5d                   	pop    %ebp
  801cc1:	c3                   	ret    

00801cc2 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801cc2:	55                   	push   %ebp
  801cc3:	89 e5                	mov    %esp,%ebp
  801cc5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801cc8:	68 20 2d 80 00       	push   $0x802d20
  801ccd:	ff 75 0c             	pushl  0xc(%ebp)
  801cd0:	e8 a1 eb ff ff       	call   800876 <strcpy>
	return 0;
}
  801cd5:	b8 00 00 00 00       	mov    $0x0,%eax
  801cda:	c9                   	leave  
  801cdb:	c3                   	ret    

00801cdc <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801cdc:	55                   	push   %ebp
  801cdd:	89 e5                	mov    %esp,%ebp
  801cdf:	53                   	push   %ebx
  801ce0:	83 ec 10             	sub    $0x10,%esp
  801ce3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801ce6:	53                   	push   %ebx
  801ce7:	e8 1f 07 00 00       	call   80240b <pageref>
  801cec:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801cef:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801cf4:	83 f8 01             	cmp    $0x1,%eax
  801cf7:	75 10                	jne    801d09 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801cf9:	83 ec 0c             	sub    $0xc,%esp
  801cfc:	ff 73 0c             	pushl  0xc(%ebx)
  801cff:	e8 c0 02 00 00       	call   801fc4 <nsipc_close>
  801d04:	89 c2                	mov    %eax,%edx
  801d06:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801d09:	89 d0                	mov    %edx,%eax
  801d0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d0e:	c9                   	leave  
  801d0f:	c3                   	ret    

00801d10 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801d10:	55                   	push   %ebp
  801d11:	89 e5                	mov    %esp,%ebp
  801d13:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801d16:	6a 00                	push   $0x0
  801d18:	ff 75 10             	pushl  0x10(%ebp)
  801d1b:	ff 75 0c             	pushl  0xc(%ebp)
  801d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d21:	ff 70 0c             	pushl  0xc(%eax)
  801d24:	e8 78 03 00 00       	call   8020a1 <nsipc_send>
}
  801d29:	c9                   	leave  
  801d2a:	c3                   	ret    

00801d2b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801d2b:	55                   	push   %ebp
  801d2c:	89 e5                	mov    %esp,%ebp
  801d2e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d31:	6a 00                	push   $0x0
  801d33:	ff 75 10             	pushl  0x10(%ebp)
  801d36:	ff 75 0c             	pushl  0xc(%ebp)
  801d39:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3c:	ff 70 0c             	pushl  0xc(%eax)
  801d3f:	e8 f1 02 00 00       	call   802035 <nsipc_recv>
}
  801d44:	c9                   	leave  
  801d45:	c3                   	ret    

00801d46 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801d46:	55                   	push   %ebp
  801d47:	89 e5                	mov    %esp,%ebp
  801d49:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d4c:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d4f:	52                   	push   %edx
  801d50:	50                   	push   %eax
  801d51:	e8 39 f4 ff ff       	call   80118f <fd_lookup>
  801d56:	83 c4 10             	add    $0x10,%esp
  801d59:	85 c0                	test   %eax,%eax
  801d5b:	78 17                	js     801d74 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d60:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801d66:	39 08                	cmp    %ecx,(%eax)
  801d68:	75 05                	jne    801d6f <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d6a:	8b 40 0c             	mov    0xc(%eax),%eax
  801d6d:	eb 05                	jmp    801d74 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801d6f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801d74:	c9                   	leave  
  801d75:	c3                   	ret    

00801d76 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801d76:	55                   	push   %ebp
  801d77:	89 e5                	mov    %esp,%ebp
  801d79:	56                   	push   %esi
  801d7a:	53                   	push   %ebx
  801d7b:	83 ec 1c             	sub    $0x1c,%esp
  801d7e:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801d80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d83:	50                   	push   %eax
  801d84:	e8 b7 f3 ff ff       	call   801140 <fd_alloc>
  801d89:	89 c3                	mov    %eax,%ebx
  801d8b:	83 c4 10             	add    $0x10,%esp
  801d8e:	85 c0                	test   %eax,%eax
  801d90:	78 1b                	js     801dad <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d92:	83 ec 04             	sub    $0x4,%esp
  801d95:	68 07 04 00 00       	push   $0x407
  801d9a:	ff 75 f4             	pushl  -0xc(%ebp)
  801d9d:	6a 00                	push   $0x0
  801d9f:	e8 d5 ee ff ff       	call   800c79 <sys_page_alloc>
  801da4:	89 c3                	mov    %eax,%ebx
  801da6:	83 c4 10             	add    $0x10,%esp
  801da9:	85 c0                	test   %eax,%eax
  801dab:	79 10                	jns    801dbd <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801dad:	83 ec 0c             	sub    $0xc,%esp
  801db0:	56                   	push   %esi
  801db1:	e8 0e 02 00 00       	call   801fc4 <nsipc_close>
		return r;
  801db6:	83 c4 10             	add    $0x10,%esp
  801db9:	89 d8                	mov    %ebx,%eax
  801dbb:	eb 24                	jmp    801de1 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801dbd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801dc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dcb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801dd2:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801dd5:	83 ec 0c             	sub    $0xc,%esp
  801dd8:	50                   	push   %eax
  801dd9:	e8 3b f3 ff ff       	call   801119 <fd2num>
  801dde:	83 c4 10             	add    $0x10,%esp
}
  801de1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801de4:	5b                   	pop    %ebx
  801de5:	5e                   	pop    %esi
  801de6:	5d                   	pop    %ebp
  801de7:	c3                   	ret    

00801de8 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801de8:	55                   	push   %ebp
  801de9:	89 e5                	mov    %esp,%ebp
  801deb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dee:	8b 45 08             	mov    0x8(%ebp),%eax
  801df1:	e8 50 ff ff ff       	call   801d46 <fd2sockid>
		return r;
  801df6:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801df8:	85 c0                	test   %eax,%eax
  801dfa:	78 1f                	js     801e1b <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801dfc:	83 ec 04             	sub    $0x4,%esp
  801dff:	ff 75 10             	pushl  0x10(%ebp)
  801e02:	ff 75 0c             	pushl  0xc(%ebp)
  801e05:	50                   	push   %eax
  801e06:	e8 12 01 00 00       	call   801f1d <nsipc_accept>
  801e0b:	83 c4 10             	add    $0x10,%esp
		return r;
  801e0e:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e10:	85 c0                	test   %eax,%eax
  801e12:	78 07                	js     801e1b <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801e14:	e8 5d ff ff ff       	call   801d76 <alloc_sockfd>
  801e19:	89 c1                	mov    %eax,%ecx
}
  801e1b:	89 c8                	mov    %ecx,%eax
  801e1d:	c9                   	leave  
  801e1e:	c3                   	ret    

00801e1f <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e1f:	55                   	push   %ebp
  801e20:	89 e5                	mov    %esp,%ebp
  801e22:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e25:	8b 45 08             	mov    0x8(%ebp),%eax
  801e28:	e8 19 ff ff ff       	call   801d46 <fd2sockid>
  801e2d:	85 c0                	test   %eax,%eax
  801e2f:	78 12                	js     801e43 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801e31:	83 ec 04             	sub    $0x4,%esp
  801e34:	ff 75 10             	pushl  0x10(%ebp)
  801e37:	ff 75 0c             	pushl  0xc(%ebp)
  801e3a:	50                   	push   %eax
  801e3b:	e8 2d 01 00 00       	call   801f6d <nsipc_bind>
  801e40:	83 c4 10             	add    $0x10,%esp
}
  801e43:	c9                   	leave  
  801e44:	c3                   	ret    

00801e45 <shutdown>:

int
shutdown(int s, int how)
{
  801e45:	55                   	push   %ebp
  801e46:	89 e5                	mov    %esp,%ebp
  801e48:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4e:	e8 f3 fe ff ff       	call   801d46 <fd2sockid>
  801e53:	85 c0                	test   %eax,%eax
  801e55:	78 0f                	js     801e66 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801e57:	83 ec 08             	sub    $0x8,%esp
  801e5a:	ff 75 0c             	pushl  0xc(%ebp)
  801e5d:	50                   	push   %eax
  801e5e:	e8 3f 01 00 00       	call   801fa2 <nsipc_shutdown>
  801e63:	83 c4 10             	add    $0x10,%esp
}
  801e66:	c9                   	leave  
  801e67:	c3                   	ret    

00801e68 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e68:	55                   	push   %ebp
  801e69:	89 e5                	mov    %esp,%ebp
  801e6b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e71:	e8 d0 fe ff ff       	call   801d46 <fd2sockid>
  801e76:	85 c0                	test   %eax,%eax
  801e78:	78 12                	js     801e8c <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801e7a:	83 ec 04             	sub    $0x4,%esp
  801e7d:	ff 75 10             	pushl  0x10(%ebp)
  801e80:	ff 75 0c             	pushl  0xc(%ebp)
  801e83:	50                   	push   %eax
  801e84:	e8 55 01 00 00       	call   801fde <nsipc_connect>
  801e89:	83 c4 10             	add    $0x10,%esp
}
  801e8c:	c9                   	leave  
  801e8d:	c3                   	ret    

00801e8e <listen>:

int
listen(int s, int backlog)
{
  801e8e:	55                   	push   %ebp
  801e8f:	89 e5                	mov    %esp,%ebp
  801e91:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e94:	8b 45 08             	mov    0x8(%ebp),%eax
  801e97:	e8 aa fe ff ff       	call   801d46 <fd2sockid>
  801e9c:	85 c0                	test   %eax,%eax
  801e9e:	78 0f                	js     801eaf <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801ea0:	83 ec 08             	sub    $0x8,%esp
  801ea3:	ff 75 0c             	pushl  0xc(%ebp)
  801ea6:	50                   	push   %eax
  801ea7:	e8 67 01 00 00       	call   802013 <nsipc_listen>
  801eac:	83 c4 10             	add    $0x10,%esp
}
  801eaf:	c9                   	leave  
  801eb0:	c3                   	ret    

00801eb1 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801eb7:	ff 75 10             	pushl  0x10(%ebp)
  801eba:	ff 75 0c             	pushl  0xc(%ebp)
  801ebd:	ff 75 08             	pushl  0x8(%ebp)
  801ec0:	e8 3a 02 00 00       	call   8020ff <nsipc_socket>
  801ec5:	83 c4 10             	add    $0x10,%esp
  801ec8:	85 c0                	test   %eax,%eax
  801eca:	78 05                	js     801ed1 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801ecc:	e8 a5 fe ff ff       	call   801d76 <alloc_sockfd>
}
  801ed1:	c9                   	leave  
  801ed2:	c3                   	ret    

00801ed3 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ed3:	55                   	push   %ebp
  801ed4:	89 e5                	mov    %esp,%ebp
  801ed6:	53                   	push   %ebx
  801ed7:	83 ec 04             	sub    $0x4,%esp
  801eda:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801edc:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801ee3:	75 12                	jne    801ef7 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801ee5:	83 ec 0c             	sub    $0xc,%esp
  801ee8:	6a 02                	push   $0x2
  801eea:	e8 e3 04 00 00       	call   8023d2 <ipc_find_env>
  801eef:	a3 04 40 80 00       	mov    %eax,0x804004
  801ef4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ef7:	6a 07                	push   $0x7
  801ef9:	68 00 60 80 00       	push   $0x806000
  801efe:	53                   	push   %ebx
  801eff:	ff 35 04 40 80 00    	pushl  0x804004
  801f05:	e8 74 04 00 00       	call   80237e <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801f0a:	83 c4 0c             	add    $0xc,%esp
  801f0d:	6a 00                	push   $0x0
  801f0f:	6a 00                	push   $0x0
  801f11:	6a 00                	push   $0x0
  801f13:	e8 ff 03 00 00       	call   802317 <ipc_recv>
}
  801f18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f1b:	c9                   	leave  
  801f1c:	c3                   	ret    

00801f1d <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f1d:	55                   	push   %ebp
  801f1e:	89 e5                	mov    %esp,%ebp
  801f20:	56                   	push   %esi
  801f21:	53                   	push   %ebx
  801f22:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801f25:	8b 45 08             	mov    0x8(%ebp),%eax
  801f28:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801f2d:	8b 06                	mov    (%esi),%eax
  801f2f:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f34:	b8 01 00 00 00       	mov    $0x1,%eax
  801f39:	e8 95 ff ff ff       	call   801ed3 <nsipc>
  801f3e:	89 c3                	mov    %eax,%ebx
  801f40:	85 c0                	test   %eax,%eax
  801f42:	78 20                	js     801f64 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f44:	83 ec 04             	sub    $0x4,%esp
  801f47:	ff 35 10 60 80 00    	pushl  0x806010
  801f4d:	68 00 60 80 00       	push   $0x806000
  801f52:	ff 75 0c             	pushl  0xc(%ebp)
  801f55:	e8 ae ea ff ff       	call   800a08 <memmove>
		*addrlen = ret->ret_addrlen;
  801f5a:	a1 10 60 80 00       	mov    0x806010,%eax
  801f5f:	89 06                	mov    %eax,(%esi)
  801f61:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801f64:	89 d8                	mov    %ebx,%eax
  801f66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f69:	5b                   	pop    %ebx
  801f6a:	5e                   	pop    %esi
  801f6b:	5d                   	pop    %ebp
  801f6c:	c3                   	ret    

00801f6d <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f6d:	55                   	push   %ebp
  801f6e:	89 e5                	mov    %esp,%ebp
  801f70:	53                   	push   %ebx
  801f71:	83 ec 08             	sub    $0x8,%esp
  801f74:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f77:	8b 45 08             	mov    0x8(%ebp),%eax
  801f7a:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f7f:	53                   	push   %ebx
  801f80:	ff 75 0c             	pushl  0xc(%ebp)
  801f83:	68 04 60 80 00       	push   $0x806004
  801f88:	e8 7b ea ff ff       	call   800a08 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f8d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801f93:	b8 02 00 00 00       	mov    $0x2,%eax
  801f98:	e8 36 ff ff ff       	call   801ed3 <nsipc>
}
  801f9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fa0:	c9                   	leave  
  801fa1:	c3                   	ret    

00801fa2 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801fa2:	55                   	push   %ebp
  801fa3:	89 e5                	mov    %esp,%ebp
  801fa5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801fa8:	8b 45 08             	mov    0x8(%ebp),%eax
  801fab:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801fb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fb3:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801fb8:	b8 03 00 00 00       	mov    $0x3,%eax
  801fbd:	e8 11 ff ff ff       	call   801ed3 <nsipc>
}
  801fc2:	c9                   	leave  
  801fc3:	c3                   	ret    

00801fc4 <nsipc_close>:

int
nsipc_close(int s)
{
  801fc4:	55                   	push   %ebp
  801fc5:	89 e5                	mov    %esp,%ebp
  801fc7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801fca:	8b 45 08             	mov    0x8(%ebp),%eax
  801fcd:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801fd2:	b8 04 00 00 00       	mov    $0x4,%eax
  801fd7:	e8 f7 fe ff ff       	call   801ed3 <nsipc>
}
  801fdc:	c9                   	leave  
  801fdd:	c3                   	ret    

00801fde <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	53                   	push   %ebx
  801fe2:	83 ec 08             	sub    $0x8,%esp
  801fe5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801fe8:	8b 45 08             	mov    0x8(%ebp),%eax
  801feb:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ff0:	53                   	push   %ebx
  801ff1:	ff 75 0c             	pushl  0xc(%ebp)
  801ff4:	68 04 60 80 00       	push   $0x806004
  801ff9:	e8 0a ea ff ff       	call   800a08 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ffe:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  802004:	b8 05 00 00 00       	mov    $0x5,%eax
  802009:	e8 c5 fe ff ff       	call   801ed3 <nsipc>
}
  80200e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802011:	c9                   	leave  
  802012:	c3                   	ret    

00802013 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802013:	55                   	push   %ebp
  802014:	89 e5                	mov    %esp,%ebp
  802016:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802019:	8b 45 08             	mov    0x8(%ebp),%eax
  80201c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  802021:	8b 45 0c             	mov    0xc(%ebp),%eax
  802024:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  802029:	b8 06 00 00 00       	mov    $0x6,%eax
  80202e:	e8 a0 fe ff ff       	call   801ed3 <nsipc>
}
  802033:	c9                   	leave  
  802034:	c3                   	ret    

00802035 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802035:	55                   	push   %ebp
  802036:	89 e5                	mov    %esp,%ebp
  802038:	56                   	push   %esi
  802039:	53                   	push   %ebx
  80203a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80203d:	8b 45 08             	mov    0x8(%ebp),%eax
  802040:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  802045:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80204b:	8b 45 14             	mov    0x14(%ebp),%eax
  80204e:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802053:	b8 07 00 00 00       	mov    $0x7,%eax
  802058:	e8 76 fe ff ff       	call   801ed3 <nsipc>
  80205d:	89 c3                	mov    %eax,%ebx
  80205f:	85 c0                	test   %eax,%eax
  802061:	78 35                	js     802098 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802063:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802068:	7f 04                	jg     80206e <nsipc_recv+0x39>
  80206a:	39 c6                	cmp    %eax,%esi
  80206c:	7d 16                	jge    802084 <nsipc_recv+0x4f>
  80206e:	68 2c 2d 80 00       	push   $0x802d2c
  802073:	68 bf 2c 80 00       	push   $0x802cbf
  802078:	6a 62                	push   $0x62
  80207a:	68 41 2d 80 00       	push   $0x802d41
  80207f:	e8 94 e1 ff ff       	call   800218 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802084:	83 ec 04             	sub    $0x4,%esp
  802087:	50                   	push   %eax
  802088:	68 00 60 80 00       	push   $0x806000
  80208d:	ff 75 0c             	pushl  0xc(%ebp)
  802090:	e8 73 e9 ff ff       	call   800a08 <memmove>
  802095:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802098:	89 d8                	mov    %ebx,%eax
  80209a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5d                   	pop    %ebp
  8020a0:	c3                   	ret    

008020a1 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8020a1:	55                   	push   %ebp
  8020a2:	89 e5                	mov    %esp,%ebp
  8020a4:	53                   	push   %ebx
  8020a5:	83 ec 04             	sub    $0x4,%esp
  8020a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8020ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ae:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8020b3:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8020b9:	7e 16                	jle    8020d1 <nsipc_send+0x30>
  8020bb:	68 4d 2d 80 00       	push   $0x802d4d
  8020c0:	68 bf 2c 80 00       	push   $0x802cbf
  8020c5:	6a 6d                	push   $0x6d
  8020c7:	68 41 2d 80 00       	push   $0x802d41
  8020cc:	e8 47 e1 ff ff       	call   800218 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8020d1:	83 ec 04             	sub    $0x4,%esp
  8020d4:	53                   	push   %ebx
  8020d5:	ff 75 0c             	pushl  0xc(%ebp)
  8020d8:	68 0c 60 80 00       	push   $0x80600c
  8020dd:	e8 26 e9 ff ff       	call   800a08 <memmove>
	nsipcbuf.send.req_size = size;
  8020e2:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8020e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8020eb:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8020f0:	b8 08 00 00 00       	mov    $0x8,%eax
  8020f5:	e8 d9 fd ff ff       	call   801ed3 <nsipc>
}
  8020fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020fd:	c9                   	leave  
  8020fe:	c3                   	ret    

008020ff <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8020ff:	55                   	push   %ebp
  802100:	89 e5                	mov    %esp,%ebp
  802102:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802105:	8b 45 08             	mov    0x8(%ebp),%eax
  802108:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80210d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802110:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802115:	8b 45 10             	mov    0x10(%ebp),%eax
  802118:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80211d:	b8 09 00 00 00       	mov    $0x9,%eax
  802122:	e8 ac fd ff ff       	call   801ed3 <nsipc>
}
  802127:	c9                   	leave  
  802128:	c3                   	ret    

00802129 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802129:	55                   	push   %ebp
  80212a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80212c:	b8 00 00 00 00       	mov    $0x0,%eax
  802131:	5d                   	pop    %ebp
  802132:	c3                   	ret    

00802133 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802133:	55                   	push   %ebp
  802134:	89 e5                	mov    %esp,%ebp
  802136:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802139:	68 59 2d 80 00       	push   $0x802d59
  80213e:	ff 75 0c             	pushl  0xc(%ebp)
  802141:	e8 30 e7 ff ff       	call   800876 <strcpy>
	return 0;
}
  802146:	b8 00 00 00 00       	mov    $0x0,%eax
  80214b:	c9                   	leave  
  80214c:	c3                   	ret    

0080214d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80214d:	55                   	push   %ebp
  80214e:	89 e5                	mov    %esp,%ebp
  802150:	57                   	push   %edi
  802151:	56                   	push   %esi
  802152:	53                   	push   %ebx
  802153:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802159:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80215e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802164:	eb 2d                	jmp    802193 <devcons_write+0x46>
		m = n - tot;
  802166:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802169:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80216b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80216e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802173:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802176:	83 ec 04             	sub    $0x4,%esp
  802179:	53                   	push   %ebx
  80217a:	03 45 0c             	add    0xc(%ebp),%eax
  80217d:	50                   	push   %eax
  80217e:	57                   	push   %edi
  80217f:	e8 84 e8 ff ff       	call   800a08 <memmove>
		sys_cputs(buf, m);
  802184:	83 c4 08             	add    $0x8,%esp
  802187:	53                   	push   %ebx
  802188:	57                   	push   %edi
  802189:	e8 2f ea ff ff       	call   800bbd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80218e:	01 de                	add    %ebx,%esi
  802190:	83 c4 10             	add    $0x10,%esp
  802193:	89 f0                	mov    %esi,%eax
  802195:	3b 75 10             	cmp    0x10(%ebp),%esi
  802198:	72 cc                	jb     802166 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80219a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80219d:	5b                   	pop    %ebx
  80219e:	5e                   	pop    %esi
  80219f:	5f                   	pop    %edi
  8021a0:	5d                   	pop    %ebp
  8021a1:	c3                   	ret    

008021a2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021a2:	55                   	push   %ebp
  8021a3:	89 e5                	mov    %esp,%ebp
  8021a5:	83 ec 08             	sub    $0x8,%esp
  8021a8:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8021ad:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021b1:	74 2a                	je     8021dd <devcons_read+0x3b>
  8021b3:	eb 05                	jmp    8021ba <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021b5:	e8 a0 ea ff ff       	call   800c5a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021ba:	e8 1c ea ff ff       	call   800bdb <sys_cgetc>
  8021bf:	85 c0                	test   %eax,%eax
  8021c1:	74 f2                	je     8021b5 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8021c3:	85 c0                	test   %eax,%eax
  8021c5:	78 16                	js     8021dd <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021c7:	83 f8 04             	cmp    $0x4,%eax
  8021ca:	74 0c                	je     8021d8 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8021cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021cf:	88 02                	mov    %al,(%edx)
	return 1;
  8021d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021d6:	eb 05                	jmp    8021dd <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021d8:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021dd:	c9                   	leave  
  8021de:	c3                   	ret    

008021df <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8021df:	55                   	push   %ebp
  8021e0:	89 e5                	mov    %esp,%ebp
  8021e2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8021e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8021eb:	6a 01                	push   $0x1
  8021ed:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021f0:	50                   	push   %eax
  8021f1:	e8 c7 e9 ff ff       	call   800bbd <sys_cputs>
}
  8021f6:	83 c4 10             	add    $0x10,%esp
  8021f9:	c9                   	leave  
  8021fa:	c3                   	ret    

008021fb <getchar>:

int
getchar(void)
{
  8021fb:	55                   	push   %ebp
  8021fc:	89 e5                	mov    %esp,%ebp
  8021fe:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802201:	6a 01                	push   $0x1
  802203:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802206:	50                   	push   %eax
  802207:	6a 00                	push   $0x0
  802209:	e8 e7 f1 ff ff       	call   8013f5 <read>
	if (r < 0)
  80220e:	83 c4 10             	add    $0x10,%esp
  802211:	85 c0                	test   %eax,%eax
  802213:	78 0f                	js     802224 <getchar+0x29>
		return r;
	if (r < 1)
  802215:	85 c0                	test   %eax,%eax
  802217:	7e 06                	jle    80221f <getchar+0x24>
		return -E_EOF;
	return c;
  802219:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80221d:	eb 05                	jmp    802224 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80221f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802224:	c9                   	leave  
  802225:	c3                   	ret    

00802226 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802226:	55                   	push   %ebp
  802227:	89 e5                	mov    %esp,%ebp
  802229:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80222c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80222f:	50                   	push   %eax
  802230:	ff 75 08             	pushl  0x8(%ebp)
  802233:	e8 57 ef ff ff       	call   80118f <fd_lookup>
  802238:	83 c4 10             	add    $0x10,%esp
  80223b:	85 c0                	test   %eax,%eax
  80223d:	78 11                	js     802250 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80223f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802242:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802248:	39 10                	cmp    %edx,(%eax)
  80224a:	0f 94 c0             	sete   %al
  80224d:	0f b6 c0             	movzbl %al,%eax
}
  802250:	c9                   	leave  
  802251:	c3                   	ret    

00802252 <opencons>:

int
opencons(void)
{
  802252:	55                   	push   %ebp
  802253:	89 e5                	mov    %esp,%ebp
  802255:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802258:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80225b:	50                   	push   %eax
  80225c:	e8 df ee ff ff       	call   801140 <fd_alloc>
  802261:	83 c4 10             	add    $0x10,%esp
		return r;
  802264:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802266:	85 c0                	test   %eax,%eax
  802268:	78 3e                	js     8022a8 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80226a:	83 ec 04             	sub    $0x4,%esp
  80226d:	68 07 04 00 00       	push   $0x407
  802272:	ff 75 f4             	pushl  -0xc(%ebp)
  802275:	6a 00                	push   $0x0
  802277:	e8 fd e9 ff ff       	call   800c79 <sys_page_alloc>
  80227c:	83 c4 10             	add    $0x10,%esp
		return r;
  80227f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802281:	85 c0                	test   %eax,%eax
  802283:	78 23                	js     8022a8 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802285:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80228b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80228e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802290:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802293:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80229a:	83 ec 0c             	sub    $0xc,%esp
  80229d:	50                   	push   %eax
  80229e:	e8 76 ee ff ff       	call   801119 <fd2num>
  8022a3:	89 c2                	mov    %eax,%edx
  8022a5:	83 c4 10             	add    $0x10,%esp
}
  8022a8:	89 d0                	mov    %edx,%eax
  8022aa:	c9                   	leave  
  8022ab:	c3                   	ret    

008022ac <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022ac:	55                   	push   %ebp
  8022ad:	89 e5                	mov    %esp,%ebp
  8022af:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8022b2:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8022b9:	75 2e                	jne    8022e9 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8022bb:	e8 7b e9 ff ff       	call   800c3b <sys_getenvid>
  8022c0:	83 ec 04             	sub    $0x4,%esp
  8022c3:	68 07 0e 00 00       	push   $0xe07
  8022c8:	68 00 f0 bf ee       	push   $0xeebff000
  8022cd:	50                   	push   %eax
  8022ce:	e8 a6 e9 ff ff       	call   800c79 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8022d3:	e8 63 e9 ff ff       	call   800c3b <sys_getenvid>
  8022d8:	83 c4 08             	add    $0x8,%esp
  8022db:	68 f3 22 80 00       	push   $0x8022f3
  8022e0:	50                   	push   %eax
  8022e1:	e8 de ea ff ff       	call   800dc4 <sys_env_set_pgfault_upcall>
  8022e6:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8022e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ec:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8022f1:	c9                   	leave  
  8022f2:	c3                   	ret    

008022f3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8022f3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8022f4:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8022f9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8022fb:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  8022fe:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  802302:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802306:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  802309:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  80230c:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  80230d:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  802310:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  802311:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  802312:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802316:	c3                   	ret    

00802317 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802317:	55                   	push   %ebp
  802318:	89 e5                	mov    %esp,%ebp
  80231a:	56                   	push   %esi
  80231b:	53                   	push   %ebx
  80231c:	8b 75 08             	mov    0x8(%ebp),%esi
  80231f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802322:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802325:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802327:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80232c:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  80232f:	83 ec 0c             	sub    $0xc,%esp
  802332:	50                   	push   %eax
  802333:	e8 f1 ea ff ff       	call   800e29 <sys_ipc_recv>

	if (from_env_store != NULL)
  802338:	83 c4 10             	add    $0x10,%esp
  80233b:	85 f6                	test   %esi,%esi
  80233d:	74 14                	je     802353 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  80233f:	ba 00 00 00 00       	mov    $0x0,%edx
  802344:	85 c0                	test   %eax,%eax
  802346:	78 09                	js     802351 <ipc_recv+0x3a>
  802348:	8b 15 20 44 80 00    	mov    0x804420,%edx
  80234e:	8b 52 74             	mov    0x74(%edx),%edx
  802351:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802353:	85 db                	test   %ebx,%ebx
  802355:	74 14                	je     80236b <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802357:	ba 00 00 00 00       	mov    $0x0,%edx
  80235c:	85 c0                	test   %eax,%eax
  80235e:	78 09                	js     802369 <ipc_recv+0x52>
  802360:	8b 15 20 44 80 00    	mov    0x804420,%edx
  802366:	8b 52 78             	mov    0x78(%edx),%edx
  802369:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80236b:	85 c0                	test   %eax,%eax
  80236d:	78 08                	js     802377 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  80236f:	a1 20 44 80 00       	mov    0x804420,%eax
  802374:	8b 40 70             	mov    0x70(%eax),%eax
}
  802377:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80237a:	5b                   	pop    %ebx
  80237b:	5e                   	pop    %esi
  80237c:	5d                   	pop    %ebp
  80237d:	c3                   	ret    

0080237e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80237e:	55                   	push   %ebp
  80237f:	89 e5                	mov    %esp,%ebp
  802381:	57                   	push   %edi
  802382:	56                   	push   %esi
  802383:	53                   	push   %ebx
  802384:	83 ec 0c             	sub    $0xc,%esp
  802387:	8b 7d 08             	mov    0x8(%ebp),%edi
  80238a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80238d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  802390:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802392:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802397:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80239a:	ff 75 14             	pushl  0x14(%ebp)
  80239d:	53                   	push   %ebx
  80239e:	56                   	push   %esi
  80239f:	57                   	push   %edi
  8023a0:	e8 61 ea ff ff       	call   800e06 <sys_ipc_try_send>

		if (err < 0) {
  8023a5:	83 c4 10             	add    $0x10,%esp
  8023a8:	85 c0                	test   %eax,%eax
  8023aa:	79 1e                	jns    8023ca <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8023ac:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023af:	75 07                	jne    8023b8 <ipc_send+0x3a>
				sys_yield();
  8023b1:	e8 a4 e8 ff ff       	call   800c5a <sys_yield>
  8023b6:	eb e2                	jmp    80239a <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8023b8:	50                   	push   %eax
  8023b9:	68 65 2d 80 00       	push   $0x802d65
  8023be:	6a 49                	push   $0x49
  8023c0:	68 72 2d 80 00       	push   $0x802d72
  8023c5:	e8 4e de ff ff       	call   800218 <_panic>
		}

	} while (err < 0);

}
  8023ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023cd:	5b                   	pop    %ebx
  8023ce:	5e                   	pop    %esi
  8023cf:	5f                   	pop    %edi
  8023d0:	5d                   	pop    %ebp
  8023d1:	c3                   	ret    

008023d2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023d2:	55                   	push   %ebp
  8023d3:	89 e5                	mov    %esp,%ebp
  8023d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8023d8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8023dd:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8023e0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023e6:	8b 52 50             	mov    0x50(%edx),%edx
  8023e9:	39 ca                	cmp    %ecx,%edx
  8023eb:	75 0d                	jne    8023fa <ipc_find_env+0x28>
			return envs[i].env_id;
  8023ed:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8023f0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8023f5:	8b 40 48             	mov    0x48(%eax),%eax
  8023f8:	eb 0f                	jmp    802409 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023fa:	83 c0 01             	add    $0x1,%eax
  8023fd:	3d 00 04 00 00       	cmp    $0x400,%eax
  802402:	75 d9                	jne    8023dd <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802404:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802409:	5d                   	pop    %ebp
  80240a:	c3                   	ret    

0080240b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80240b:	55                   	push   %ebp
  80240c:	89 e5                	mov    %esp,%ebp
  80240e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802411:	89 d0                	mov    %edx,%eax
  802413:	c1 e8 16             	shr    $0x16,%eax
  802416:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80241d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802422:	f6 c1 01             	test   $0x1,%cl
  802425:	74 1d                	je     802444 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802427:	c1 ea 0c             	shr    $0xc,%edx
  80242a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802431:	f6 c2 01             	test   $0x1,%dl
  802434:	74 0e                	je     802444 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802436:	c1 ea 0c             	shr    $0xc,%edx
  802439:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802440:	ef 
  802441:	0f b7 c0             	movzwl %ax,%eax
}
  802444:	5d                   	pop    %ebp
  802445:	c3                   	ret    
  802446:	66 90                	xchg   %ax,%ax
  802448:	66 90                	xchg   %ax,%ax
  80244a:	66 90                	xchg   %ax,%ax
  80244c:	66 90                	xchg   %ax,%ax
  80244e:	66 90                	xchg   %ax,%ax

00802450 <__udivdi3>:
  802450:	55                   	push   %ebp
  802451:	57                   	push   %edi
  802452:	56                   	push   %esi
  802453:	53                   	push   %ebx
  802454:	83 ec 1c             	sub    $0x1c,%esp
  802457:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80245b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80245f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802463:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802467:	85 f6                	test   %esi,%esi
  802469:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80246d:	89 ca                	mov    %ecx,%edx
  80246f:	89 f8                	mov    %edi,%eax
  802471:	75 3d                	jne    8024b0 <__udivdi3+0x60>
  802473:	39 cf                	cmp    %ecx,%edi
  802475:	0f 87 c5 00 00 00    	ja     802540 <__udivdi3+0xf0>
  80247b:	85 ff                	test   %edi,%edi
  80247d:	89 fd                	mov    %edi,%ebp
  80247f:	75 0b                	jne    80248c <__udivdi3+0x3c>
  802481:	b8 01 00 00 00       	mov    $0x1,%eax
  802486:	31 d2                	xor    %edx,%edx
  802488:	f7 f7                	div    %edi
  80248a:	89 c5                	mov    %eax,%ebp
  80248c:	89 c8                	mov    %ecx,%eax
  80248e:	31 d2                	xor    %edx,%edx
  802490:	f7 f5                	div    %ebp
  802492:	89 c1                	mov    %eax,%ecx
  802494:	89 d8                	mov    %ebx,%eax
  802496:	89 cf                	mov    %ecx,%edi
  802498:	f7 f5                	div    %ebp
  80249a:	89 c3                	mov    %eax,%ebx
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
  8024b0:	39 ce                	cmp    %ecx,%esi
  8024b2:	77 74                	ja     802528 <__udivdi3+0xd8>
  8024b4:	0f bd fe             	bsr    %esi,%edi
  8024b7:	83 f7 1f             	xor    $0x1f,%edi
  8024ba:	0f 84 98 00 00 00    	je     802558 <__udivdi3+0x108>
  8024c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8024c5:	89 f9                	mov    %edi,%ecx
  8024c7:	89 c5                	mov    %eax,%ebp
  8024c9:	29 fb                	sub    %edi,%ebx
  8024cb:	d3 e6                	shl    %cl,%esi
  8024cd:	89 d9                	mov    %ebx,%ecx
  8024cf:	d3 ed                	shr    %cl,%ebp
  8024d1:	89 f9                	mov    %edi,%ecx
  8024d3:	d3 e0                	shl    %cl,%eax
  8024d5:	09 ee                	or     %ebp,%esi
  8024d7:	89 d9                	mov    %ebx,%ecx
  8024d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024dd:	89 d5                	mov    %edx,%ebp
  8024df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024e3:	d3 ed                	shr    %cl,%ebp
  8024e5:	89 f9                	mov    %edi,%ecx
  8024e7:	d3 e2                	shl    %cl,%edx
  8024e9:	89 d9                	mov    %ebx,%ecx
  8024eb:	d3 e8                	shr    %cl,%eax
  8024ed:	09 c2                	or     %eax,%edx
  8024ef:	89 d0                	mov    %edx,%eax
  8024f1:	89 ea                	mov    %ebp,%edx
  8024f3:	f7 f6                	div    %esi
  8024f5:	89 d5                	mov    %edx,%ebp
  8024f7:	89 c3                	mov    %eax,%ebx
  8024f9:	f7 64 24 0c          	mull   0xc(%esp)
  8024fd:	39 d5                	cmp    %edx,%ebp
  8024ff:	72 10                	jb     802511 <__udivdi3+0xc1>
  802501:	8b 74 24 08          	mov    0x8(%esp),%esi
  802505:	89 f9                	mov    %edi,%ecx
  802507:	d3 e6                	shl    %cl,%esi
  802509:	39 c6                	cmp    %eax,%esi
  80250b:	73 07                	jae    802514 <__udivdi3+0xc4>
  80250d:	39 d5                	cmp    %edx,%ebp
  80250f:	75 03                	jne    802514 <__udivdi3+0xc4>
  802511:	83 eb 01             	sub    $0x1,%ebx
  802514:	31 ff                	xor    %edi,%edi
  802516:	89 d8                	mov    %ebx,%eax
  802518:	89 fa                	mov    %edi,%edx
  80251a:	83 c4 1c             	add    $0x1c,%esp
  80251d:	5b                   	pop    %ebx
  80251e:	5e                   	pop    %esi
  80251f:	5f                   	pop    %edi
  802520:	5d                   	pop    %ebp
  802521:	c3                   	ret    
  802522:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802528:	31 ff                	xor    %edi,%edi
  80252a:	31 db                	xor    %ebx,%ebx
  80252c:	89 d8                	mov    %ebx,%eax
  80252e:	89 fa                	mov    %edi,%edx
  802530:	83 c4 1c             	add    $0x1c,%esp
  802533:	5b                   	pop    %ebx
  802534:	5e                   	pop    %esi
  802535:	5f                   	pop    %edi
  802536:	5d                   	pop    %ebp
  802537:	c3                   	ret    
  802538:	90                   	nop
  802539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802540:	89 d8                	mov    %ebx,%eax
  802542:	f7 f7                	div    %edi
  802544:	31 ff                	xor    %edi,%edi
  802546:	89 c3                	mov    %eax,%ebx
  802548:	89 d8                	mov    %ebx,%eax
  80254a:	89 fa                	mov    %edi,%edx
  80254c:	83 c4 1c             	add    $0x1c,%esp
  80254f:	5b                   	pop    %ebx
  802550:	5e                   	pop    %esi
  802551:	5f                   	pop    %edi
  802552:	5d                   	pop    %ebp
  802553:	c3                   	ret    
  802554:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802558:	39 ce                	cmp    %ecx,%esi
  80255a:	72 0c                	jb     802568 <__udivdi3+0x118>
  80255c:	31 db                	xor    %ebx,%ebx
  80255e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802562:	0f 87 34 ff ff ff    	ja     80249c <__udivdi3+0x4c>
  802568:	bb 01 00 00 00       	mov    $0x1,%ebx
  80256d:	e9 2a ff ff ff       	jmp    80249c <__udivdi3+0x4c>
  802572:	66 90                	xchg   %ax,%ax
  802574:	66 90                	xchg   %ax,%ax
  802576:	66 90                	xchg   %ax,%ax
  802578:	66 90                	xchg   %ax,%ax
  80257a:	66 90                	xchg   %ax,%ax
  80257c:	66 90                	xchg   %ax,%ax
  80257e:	66 90                	xchg   %ax,%ax

00802580 <__umoddi3>:
  802580:	55                   	push   %ebp
  802581:	57                   	push   %edi
  802582:	56                   	push   %esi
  802583:	53                   	push   %ebx
  802584:	83 ec 1c             	sub    $0x1c,%esp
  802587:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80258b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80258f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802593:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802597:	85 d2                	test   %edx,%edx
  802599:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80259d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025a1:	89 f3                	mov    %esi,%ebx
  8025a3:	89 3c 24             	mov    %edi,(%esp)
  8025a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025aa:	75 1c                	jne    8025c8 <__umoddi3+0x48>
  8025ac:	39 f7                	cmp    %esi,%edi
  8025ae:	76 50                	jbe    802600 <__umoddi3+0x80>
  8025b0:	89 c8                	mov    %ecx,%eax
  8025b2:	89 f2                	mov    %esi,%edx
  8025b4:	f7 f7                	div    %edi
  8025b6:	89 d0                	mov    %edx,%eax
  8025b8:	31 d2                	xor    %edx,%edx
  8025ba:	83 c4 1c             	add    $0x1c,%esp
  8025bd:	5b                   	pop    %ebx
  8025be:	5e                   	pop    %esi
  8025bf:	5f                   	pop    %edi
  8025c0:	5d                   	pop    %ebp
  8025c1:	c3                   	ret    
  8025c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025c8:	39 f2                	cmp    %esi,%edx
  8025ca:	89 d0                	mov    %edx,%eax
  8025cc:	77 52                	ja     802620 <__umoddi3+0xa0>
  8025ce:	0f bd ea             	bsr    %edx,%ebp
  8025d1:	83 f5 1f             	xor    $0x1f,%ebp
  8025d4:	75 5a                	jne    802630 <__umoddi3+0xb0>
  8025d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8025da:	0f 82 e0 00 00 00    	jb     8026c0 <__umoddi3+0x140>
  8025e0:	39 0c 24             	cmp    %ecx,(%esp)
  8025e3:	0f 86 d7 00 00 00    	jbe    8026c0 <__umoddi3+0x140>
  8025e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025f1:	83 c4 1c             	add    $0x1c,%esp
  8025f4:	5b                   	pop    %ebx
  8025f5:	5e                   	pop    %esi
  8025f6:	5f                   	pop    %edi
  8025f7:	5d                   	pop    %ebp
  8025f8:	c3                   	ret    
  8025f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802600:	85 ff                	test   %edi,%edi
  802602:	89 fd                	mov    %edi,%ebp
  802604:	75 0b                	jne    802611 <__umoddi3+0x91>
  802606:	b8 01 00 00 00       	mov    $0x1,%eax
  80260b:	31 d2                	xor    %edx,%edx
  80260d:	f7 f7                	div    %edi
  80260f:	89 c5                	mov    %eax,%ebp
  802611:	89 f0                	mov    %esi,%eax
  802613:	31 d2                	xor    %edx,%edx
  802615:	f7 f5                	div    %ebp
  802617:	89 c8                	mov    %ecx,%eax
  802619:	f7 f5                	div    %ebp
  80261b:	89 d0                	mov    %edx,%eax
  80261d:	eb 99                	jmp    8025b8 <__umoddi3+0x38>
  80261f:	90                   	nop
  802620:	89 c8                	mov    %ecx,%eax
  802622:	89 f2                	mov    %esi,%edx
  802624:	83 c4 1c             	add    $0x1c,%esp
  802627:	5b                   	pop    %ebx
  802628:	5e                   	pop    %esi
  802629:	5f                   	pop    %edi
  80262a:	5d                   	pop    %ebp
  80262b:	c3                   	ret    
  80262c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802630:	8b 34 24             	mov    (%esp),%esi
  802633:	bf 20 00 00 00       	mov    $0x20,%edi
  802638:	89 e9                	mov    %ebp,%ecx
  80263a:	29 ef                	sub    %ebp,%edi
  80263c:	d3 e0                	shl    %cl,%eax
  80263e:	89 f9                	mov    %edi,%ecx
  802640:	89 f2                	mov    %esi,%edx
  802642:	d3 ea                	shr    %cl,%edx
  802644:	89 e9                	mov    %ebp,%ecx
  802646:	09 c2                	or     %eax,%edx
  802648:	89 d8                	mov    %ebx,%eax
  80264a:	89 14 24             	mov    %edx,(%esp)
  80264d:	89 f2                	mov    %esi,%edx
  80264f:	d3 e2                	shl    %cl,%edx
  802651:	89 f9                	mov    %edi,%ecx
  802653:	89 54 24 04          	mov    %edx,0x4(%esp)
  802657:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80265b:	d3 e8                	shr    %cl,%eax
  80265d:	89 e9                	mov    %ebp,%ecx
  80265f:	89 c6                	mov    %eax,%esi
  802661:	d3 e3                	shl    %cl,%ebx
  802663:	89 f9                	mov    %edi,%ecx
  802665:	89 d0                	mov    %edx,%eax
  802667:	d3 e8                	shr    %cl,%eax
  802669:	89 e9                	mov    %ebp,%ecx
  80266b:	09 d8                	or     %ebx,%eax
  80266d:	89 d3                	mov    %edx,%ebx
  80266f:	89 f2                	mov    %esi,%edx
  802671:	f7 34 24             	divl   (%esp)
  802674:	89 d6                	mov    %edx,%esi
  802676:	d3 e3                	shl    %cl,%ebx
  802678:	f7 64 24 04          	mull   0x4(%esp)
  80267c:	39 d6                	cmp    %edx,%esi
  80267e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802682:	89 d1                	mov    %edx,%ecx
  802684:	89 c3                	mov    %eax,%ebx
  802686:	72 08                	jb     802690 <__umoddi3+0x110>
  802688:	75 11                	jne    80269b <__umoddi3+0x11b>
  80268a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80268e:	73 0b                	jae    80269b <__umoddi3+0x11b>
  802690:	2b 44 24 04          	sub    0x4(%esp),%eax
  802694:	1b 14 24             	sbb    (%esp),%edx
  802697:	89 d1                	mov    %edx,%ecx
  802699:	89 c3                	mov    %eax,%ebx
  80269b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80269f:	29 da                	sub    %ebx,%edx
  8026a1:	19 ce                	sbb    %ecx,%esi
  8026a3:	89 f9                	mov    %edi,%ecx
  8026a5:	89 f0                	mov    %esi,%eax
  8026a7:	d3 e0                	shl    %cl,%eax
  8026a9:	89 e9                	mov    %ebp,%ecx
  8026ab:	d3 ea                	shr    %cl,%edx
  8026ad:	89 e9                	mov    %ebp,%ecx
  8026af:	d3 ee                	shr    %cl,%esi
  8026b1:	09 d0                	or     %edx,%eax
  8026b3:	89 f2                	mov    %esi,%edx
  8026b5:	83 c4 1c             	add    $0x1c,%esp
  8026b8:	5b                   	pop    %ebx
  8026b9:	5e                   	pop    %esi
  8026ba:	5f                   	pop    %edi
  8026bb:	5d                   	pop    %ebp
  8026bc:	c3                   	ret    
  8026bd:	8d 76 00             	lea    0x0(%esi),%esi
  8026c0:	29 f9                	sub    %edi,%ecx
  8026c2:	19 d6                	sbb    %edx,%esi
  8026c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026cc:	e9 18 ff ff ff       	jmp    8025e9 <__umoddi3+0x69>
