
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
  80003e:	68 60 22 80 00       	push   $0x802260
  800043:	e8 0f 18 00 00       	call   801857 <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 65 22 80 00       	push   $0x802265
  800057:	6a 0c                	push   $0xc
  800059:	68 73 22 80 00       	push   $0x802273
  80005e:	e8 b5 01 00 00       	call   800218 <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 d1 14 00 00       	call   80153f <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 20 42 80 00       	push   $0x804220
  80007b:	53                   	push   %ebx
  80007c:	e8 e9 13 00 00       	call   80146a <readn>
  800081:	89 c6                	mov    %eax,%esi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 88 22 80 00       	push   $0x802288
  800090:	6a 0f                	push   $0xf
  800092:	68 73 22 80 00       	push   $0x802273
  800097:	e8 7c 01 00 00       	call   800218 <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 a2 0e 00 00       	call   800f43 <fork>
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 92 22 80 00       	push   $0x802292
  8000ad:	6a 12                	push   $0x12
  8000af:	68 73 22 80 00       	push   $0x802273
  8000b4:	e8 5f 01 00 00       	call   800218 <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 73 14 00 00       	call   80153f <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 d0 22 80 00 	movl   $0x8022d0,(%esp)
  8000d3:	e8 19 02 00 00       	call   8002f1 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 20 40 80 00       	push   $0x804020
  8000e5:	53                   	push   %ebx
  8000e6:	e8 7f 13 00 00       	call   80146a <readn>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	39 c6                	cmp    %eax,%esi
  8000f0:	74 16                	je     800108 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	56                   	push   %esi
  8000f7:	68 14 23 80 00       	push   $0x802314
  8000fc:	6a 17                	push   $0x17
  8000fe:	68 73 22 80 00       	push   $0x802273
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
  800125:	68 40 23 80 00       	push   $0x802340
  80012a:	6a 19                	push   $0x19
  80012c:	68 73 22 80 00       	push   $0x802273
  800131:	e8 e2 00 00 00       	call   800218 <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 9b 22 80 00       	push   $0x80229b
  80013e:	e8 ae 01 00 00       	call   8002f1 <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 f1 13 00 00       	call   80153f <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 47 11 00 00       	call   80129d <close>
		exit();
  800156:	e8 a3 00 00 00       	call   8001fe <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	57                   	push   %edi
  800162:	e8 f0 1a 00 00       	call   801c57 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 20 40 80 00       	push   $0x804020
  800174:	53                   	push   %ebx
  800175:	e8 f0 12 00 00       	call   80146a <readn>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	39 c6                	cmp    %eax,%esi
  80017f:	74 16                	je     800197 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	56                   	push   %esi
  800186:	68 78 23 80 00       	push   $0x802378
  80018b:	6a 21                	push   $0x21
  80018d:	68 73 22 80 00       	push   $0x802273
  800192:	e8 81 00 00 00       	call   800218 <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 b4 22 80 00       	push   $0x8022b4
  80019f:	e8 4d 01 00 00       	call   8002f1 <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 f1 10 00 00       	call   80129d <close>
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
  800204:	e8 bf 10 00 00       	call   8012c8 <close_all>
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
  800236:	68 a8 23 80 00       	push   $0x8023a8
  80023b:	e8 b1 00 00 00       	call   8002f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800240:	83 c4 18             	add    $0x18,%esp
  800243:	53                   	push   %ebx
  800244:	ff 75 10             	pushl  0x10(%ebp)
  800247:	e8 54 00 00 00       	call   8002a0 <vcprintf>
	cprintf("\n");
  80024c:	c7 04 24 b2 22 80 00 	movl   $0x8022b2,(%esp)
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
  800354:	e8 77 1c 00 00       	call   801fd0 <__udivdi3>
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
  800397:	e8 64 1d 00 00       	call   802100 <__umoddi3>
  80039c:	83 c4 14             	add    $0x14,%esp
  80039f:	0f be 80 cb 23 80 00 	movsbl 0x8023cb(%eax),%eax
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
  80049b:	ff 24 85 00 25 80 00 	jmp    *0x802500(,%eax,4)
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
  80055f:	8b 14 85 60 26 80 00 	mov    0x802660(,%eax,4),%edx
  800566:	85 d2                	test   %edx,%edx
  800568:	75 18                	jne    800582 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80056a:	50                   	push   %eax
  80056b:	68 e3 23 80 00       	push   $0x8023e3
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
  800583:	68 4d 28 80 00       	push   $0x80284d
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
  8005a7:	b8 dc 23 80 00       	mov    $0x8023dc,%eax
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
  800c22:	68 bf 26 80 00       	push   $0x8026bf
  800c27:	6a 23                	push   $0x23
  800c29:	68 dc 26 80 00       	push   $0x8026dc
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
  800ca3:	68 bf 26 80 00       	push   $0x8026bf
  800ca8:	6a 23                	push   $0x23
  800caa:	68 dc 26 80 00       	push   $0x8026dc
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
  800ce5:	68 bf 26 80 00       	push   $0x8026bf
  800cea:	6a 23                	push   $0x23
  800cec:	68 dc 26 80 00       	push   $0x8026dc
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
  800d27:	68 bf 26 80 00       	push   $0x8026bf
  800d2c:	6a 23                	push   $0x23
  800d2e:	68 dc 26 80 00       	push   $0x8026dc
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
  800d69:	68 bf 26 80 00       	push   $0x8026bf
  800d6e:	6a 23                	push   $0x23
  800d70:	68 dc 26 80 00       	push   $0x8026dc
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
  800dab:	68 bf 26 80 00       	push   $0x8026bf
  800db0:	6a 23                	push   $0x23
  800db2:	68 dc 26 80 00       	push   $0x8026dc
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
  800ded:	68 bf 26 80 00       	push   $0x8026bf
  800df2:	6a 23                	push   $0x23
  800df4:	68 dc 26 80 00       	push   $0x8026dc
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
  800e51:	68 bf 26 80 00       	push   $0x8026bf
  800e56:	6a 23                	push   $0x23
  800e58:	68 dc 26 80 00       	push   $0x8026dc
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

00800e6a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	56                   	push   %esi
  800e6e:	53                   	push   %ebx
  800e6f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e72:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800e74:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e78:	75 25                	jne    800e9f <pgfault+0x35>
  800e7a:	89 d8                	mov    %ebx,%eax
  800e7c:	c1 e8 0c             	shr    $0xc,%eax
  800e7f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e86:	f6 c4 08             	test   $0x8,%ah
  800e89:	75 14                	jne    800e9f <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800e8b:	83 ec 04             	sub    $0x4,%esp
  800e8e:	68 ec 26 80 00       	push   $0x8026ec
  800e93:	6a 1e                	push   $0x1e
  800e95:	68 80 27 80 00       	push   $0x802780
  800e9a:	e8 79 f3 ff ff       	call   800218 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800e9f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800ea5:	e8 91 fd ff ff       	call   800c3b <sys_getenvid>
  800eaa:	89 c6                	mov    %eax,%esi

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800eac:	83 ec 04             	sub    $0x4,%esp
  800eaf:	6a 07                	push   $0x7
  800eb1:	68 00 f0 7f 00       	push   $0x7ff000
  800eb6:	50                   	push   %eax
  800eb7:	e8 bd fd ff ff       	call   800c79 <sys_page_alloc>
	if (r < 0)
  800ebc:	83 c4 10             	add    $0x10,%esp
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	79 12                	jns    800ed5 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800ec3:	50                   	push   %eax
  800ec4:	68 18 27 80 00       	push   $0x802718
  800ec9:	6a 31                	push   $0x31
  800ecb:	68 80 27 80 00       	push   $0x802780
  800ed0:	e8 43 f3 ff ff       	call   800218 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800ed5:	83 ec 04             	sub    $0x4,%esp
  800ed8:	68 00 10 00 00       	push   $0x1000
  800edd:	53                   	push   %ebx
  800ede:	68 00 f0 7f 00       	push   $0x7ff000
  800ee3:	e8 88 fb ff ff       	call   800a70 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800ee8:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800eef:	53                   	push   %ebx
  800ef0:	56                   	push   %esi
  800ef1:	68 00 f0 7f 00       	push   $0x7ff000
  800ef6:	56                   	push   %esi
  800ef7:	e8 c0 fd ff ff       	call   800cbc <sys_page_map>
	if (r < 0)
  800efc:	83 c4 20             	add    $0x20,%esp
  800eff:	85 c0                	test   %eax,%eax
  800f01:	79 12                	jns    800f15 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800f03:	50                   	push   %eax
  800f04:	68 3c 27 80 00       	push   $0x80273c
  800f09:	6a 39                	push   $0x39
  800f0b:	68 80 27 80 00       	push   $0x802780
  800f10:	e8 03 f3 ff ff       	call   800218 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800f15:	83 ec 08             	sub    $0x8,%esp
  800f18:	68 00 f0 7f 00       	push   $0x7ff000
  800f1d:	56                   	push   %esi
  800f1e:	e8 db fd ff ff       	call   800cfe <sys_page_unmap>
	if (r < 0)
  800f23:	83 c4 10             	add    $0x10,%esp
  800f26:	85 c0                	test   %eax,%eax
  800f28:	79 12                	jns    800f3c <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800f2a:	50                   	push   %eax
  800f2b:	68 60 27 80 00       	push   $0x802760
  800f30:	6a 3e                	push   $0x3e
  800f32:	68 80 27 80 00       	push   $0x802780
  800f37:	e8 dc f2 ff ff       	call   800218 <_panic>
}
  800f3c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f3f:	5b                   	pop    %ebx
  800f40:	5e                   	pop    %esi
  800f41:	5d                   	pop    %ebp
  800f42:	c3                   	ret    

00800f43 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	57                   	push   %edi
  800f47:	56                   	push   %esi
  800f48:	53                   	push   %ebx
  800f49:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800f4c:	68 6a 0e 80 00       	push   $0x800e6a
  800f51:	e8 d3 0e 00 00       	call   801e29 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f56:	b8 07 00 00 00       	mov    $0x7,%eax
  800f5b:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800f5d:	83 c4 10             	add    $0x10,%esp
  800f60:	85 c0                	test   %eax,%eax
  800f62:	0f 88 67 01 00 00    	js     8010cf <fork+0x18c>
  800f68:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800f6d:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800f72:	85 c0                	test   %eax,%eax
  800f74:	75 21                	jne    800f97 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f76:	e8 c0 fc ff ff       	call   800c3b <sys_getenvid>
  800f7b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f80:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f83:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f88:	a3 20 44 80 00       	mov    %eax,0x804420
        return 0;
  800f8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f92:	e9 42 01 00 00       	jmp    8010d9 <fork+0x196>
  800f97:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f9a:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800f9c:	89 d8                	mov    %ebx,%eax
  800f9e:	c1 e8 16             	shr    $0x16,%eax
  800fa1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fa8:	a8 01                	test   $0x1,%al
  800faa:	0f 84 c0 00 00 00    	je     801070 <fork+0x12d>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800fb0:	89 d8                	mov    %ebx,%eax
  800fb2:	c1 e8 0c             	shr    $0xc,%eax
  800fb5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fbc:	f6 c2 01             	test   $0x1,%dl
  800fbf:	0f 84 ab 00 00 00    	je     801070 <fork+0x12d>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
  800fc5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fcc:	a9 02 08 00 00       	test   $0x802,%eax
  800fd1:	0f 84 99 00 00 00    	je     801070 <fork+0x12d>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800fd7:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fde:	f6 c4 04             	test   $0x4,%ah
  800fe1:	74 17                	je     800ffa <fork+0xb7>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800fe3:	83 ec 0c             	sub    $0xc,%esp
  800fe6:	68 07 0e 00 00       	push   $0xe07
  800feb:	53                   	push   %ebx
  800fec:	57                   	push   %edi
  800fed:	53                   	push   %ebx
  800fee:	6a 00                	push   $0x0
  800ff0:	e8 c7 fc ff ff       	call   800cbc <sys_page_map>
  800ff5:	83 c4 20             	add    $0x20,%esp
  800ff8:	eb 76                	jmp    801070 <fork+0x12d>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800ffa:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801001:	a8 02                	test   $0x2,%al
  801003:	75 0c                	jne    801011 <fork+0xce>
  801005:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80100c:	f6 c4 08             	test   $0x8,%ah
  80100f:	74 3f                	je     801050 <fork+0x10d>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801011:	83 ec 0c             	sub    $0xc,%esp
  801014:	68 05 08 00 00       	push   $0x805
  801019:	53                   	push   %ebx
  80101a:	57                   	push   %edi
  80101b:	53                   	push   %ebx
  80101c:	6a 00                	push   $0x0
  80101e:	e8 99 fc ff ff       	call   800cbc <sys_page_map>
		if (r < 0)
  801023:	83 c4 20             	add    $0x20,%esp
  801026:	85 c0                	test   %eax,%eax
  801028:	0f 88 a5 00 00 00    	js     8010d3 <fork+0x190>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  80102e:	83 ec 0c             	sub    $0xc,%esp
  801031:	68 05 08 00 00       	push   $0x805
  801036:	53                   	push   %ebx
  801037:	6a 00                	push   $0x0
  801039:	53                   	push   %ebx
  80103a:	6a 00                	push   $0x0
  80103c:	e8 7b fc ff ff       	call   800cbc <sys_page_map>
  801041:	83 c4 20             	add    $0x20,%esp
  801044:	85 c0                	test   %eax,%eax
  801046:	b9 00 00 00 00       	mov    $0x0,%ecx
  80104b:	0f 4f c1             	cmovg  %ecx,%eax
  80104e:	eb 1c                	jmp    80106c <fork+0x129>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  801050:	83 ec 0c             	sub    $0xc,%esp
  801053:	6a 05                	push   $0x5
  801055:	53                   	push   %ebx
  801056:	57                   	push   %edi
  801057:	53                   	push   %ebx
  801058:	6a 00                	push   $0x0
  80105a:	e8 5d fc ff ff       	call   800cbc <sys_page_map>
  80105f:	83 c4 20             	add    $0x20,%esp
  801062:	85 c0                	test   %eax,%eax
  801064:	b9 00 00 00 00       	mov    $0x0,%ecx
  801069:	0f 4f c1             	cmovg  %ecx,%eax
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  80106c:	85 c0                	test   %eax,%eax
  80106e:	78 67                	js     8010d7 <fork+0x194>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801070:	83 c6 01             	add    $0x1,%esi
  801073:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801079:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  80107f:	0f 85 17 ff ff ff    	jne    800f9c <fork+0x59>
  801085:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  801088:	83 ec 04             	sub    $0x4,%esp
  80108b:	6a 07                	push   $0x7
  80108d:	68 00 f0 bf ee       	push   $0xeebff000
  801092:	57                   	push   %edi
  801093:	e8 e1 fb ff ff       	call   800c79 <sys_page_alloc>
	if (r < 0)
  801098:	83 c4 10             	add    $0x10,%esp
		return r;
  80109b:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  80109d:	85 c0                	test   %eax,%eax
  80109f:	78 38                	js     8010d9 <fork+0x196>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010a1:	83 ec 08             	sub    $0x8,%esp
  8010a4:	68 70 1e 80 00       	push   $0x801e70
  8010a9:	57                   	push   %edi
  8010aa:	e8 15 fd ff ff       	call   800dc4 <sys_env_set_pgfault_upcall>
	if (r < 0)
  8010af:	83 c4 10             	add    $0x10,%esp
		return r;
  8010b2:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  8010b4:	85 c0                	test   %eax,%eax
  8010b6:	78 21                	js     8010d9 <fork+0x196>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  8010b8:	83 ec 08             	sub    $0x8,%esp
  8010bb:	6a 02                	push   $0x2
  8010bd:	57                   	push   %edi
  8010be:	e8 7d fc ff ff       	call   800d40 <sys_env_set_status>
	if (r < 0)
  8010c3:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  8010c6:	85 c0                	test   %eax,%eax
  8010c8:	0f 48 f8             	cmovs  %eax,%edi
  8010cb:	89 fa                	mov    %edi,%edx
  8010cd:	eb 0a                	jmp    8010d9 <fork+0x196>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  8010cf:	89 c2                	mov    %eax,%edx
  8010d1:	eb 06                	jmp    8010d9 <fork+0x196>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  8010d3:	89 c2                	mov    %eax,%edx
  8010d5:	eb 02                	jmp    8010d9 <fork+0x196>
  8010d7:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  8010d9:	89 d0                	mov    %edx,%eax
  8010db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010de:	5b                   	pop    %ebx
  8010df:	5e                   	pop    %esi
  8010e0:	5f                   	pop    %edi
  8010e1:	5d                   	pop    %ebp
  8010e2:	c3                   	ret    

008010e3 <sfork>:

// Challenge!
int
sfork(void)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010e9:	68 8b 27 80 00       	push   $0x80278b
  8010ee:	68 c6 00 00 00       	push   $0xc6
  8010f3:	68 80 27 80 00       	push   $0x802780
  8010f8:	e8 1b f1 ff ff       	call   800218 <_panic>

008010fd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010fd:	55                   	push   %ebp
  8010fe:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801100:	8b 45 08             	mov    0x8(%ebp),%eax
  801103:	05 00 00 00 30       	add    $0x30000000,%eax
  801108:	c1 e8 0c             	shr    $0xc,%eax
}
  80110b:	5d                   	pop    %ebp
  80110c:	c3                   	ret    

0080110d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80110d:	55                   	push   %ebp
  80110e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801110:	8b 45 08             	mov    0x8(%ebp),%eax
  801113:	05 00 00 00 30       	add    $0x30000000,%eax
  801118:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80111d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801122:	5d                   	pop    %ebp
  801123:	c3                   	ret    

00801124 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80112a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80112f:	89 c2                	mov    %eax,%edx
  801131:	c1 ea 16             	shr    $0x16,%edx
  801134:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80113b:	f6 c2 01             	test   $0x1,%dl
  80113e:	74 11                	je     801151 <fd_alloc+0x2d>
  801140:	89 c2                	mov    %eax,%edx
  801142:	c1 ea 0c             	shr    $0xc,%edx
  801145:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80114c:	f6 c2 01             	test   $0x1,%dl
  80114f:	75 09                	jne    80115a <fd_alloc+0x36>
			*fd_store = fd;
  801151:	89 01                	mov    %eax,(%ecx)
			return 0;
  801153:	b8 00 00 00 00       	mov    $0x0,%eax
  801158:	eb 17                	jmp    801171 <fd_alloc+0x4d>
  80115a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80115f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801164:	75 c9                	jne    80112f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801166:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80116c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801171:	5d                   	pop    %ebp
  801172:	c3                   	ret    

00801173 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801173:	55                   	push   %ebp
  801174:	89 e5                	mov    %esp,%ebp
  801176:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801179:	83 f8 1f             	cmp    $0x1f,%eax
  80117c:	77 36                	ja     8011b4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80117e:	c1 e0 0c             	shl    $0xc,%eax
  801181:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801186:	89 c2                	mov    %eax,%edx
  801188:	c1 ea 16             	shr    $0x16,%edx
  80118b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801192:	f6 c2 01             	test   $0x1,%dl
  801195:	74 24                	je     8011bb <fd_lookup+0x48>
  801197:	89 c2                	mov    %eax,%edx
  801199:	c1 ea 0c             	shr    $0xc,%edx
  80119c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011a3:	f6 c2 01             	test   $0x1,%dl
  8011a6:	74 1a                	je     8011c2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ab:	89 02                	mov    %eax,(%edx)
	return 0;
  8011ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b2:	eb 13                	jmp    8011c7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b9:	eb 0c                	jmp    8011c7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011c0:	eb 05                	jmp    8011c7 <fd_lookup+0x54>
  8011c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011c7:	5d                   	pop    %ebp
  8011c8:	c3                   	ret    

008011c9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011c9:	55                   	push   %ebp
  8011ca:	89 e5                	mov    %esp,%ebp
  8011cc:	83 ec 08             	sub    $0x8,%esp
  8011cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d2:	ba 24 28 80 00       	mov    $0x802824,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011d7:	eb 13                	jmp    8011ec <dev_lookup+0x23>
  8011d9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011dc:	39 08                	cmp    %ecx,(%eax)
  8011de:	75 0c                	jne    8011ec <dev_lookup+0x23>
			*dev = devtab[i];
  8011e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ea:	eb 2e                	jmp    80121a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011ec:	8b 02                	mov    (%edx),%eax
  8011ee:	85 c0                	test   %eax,%eax
  8011f0:	75 e7                	jne    8011d9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011f2:	a1 20 44 80 00       	mov    0x804420,%eax
  8011f7:	8b 40 48             	mov    0x48(%eax),%eax
  8011fa:	83 ec 04             	sub    $0x4,%esp
  8011fd:	51                   	push   %ecx
  8011fe:	50                   	push   %eax
  8011ff:	68 a4 27 80 00       	push   $0x8027a4
  801204:	e8 e8 f0 ff ff       	call   8002f1 <cprintf>
	*dev = 0;
  801209:	8b 45 0c             	mov    0xc(%ebp),%eax
  80120c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801212:	83 c4 10             	add    $0x10,%esp
  801215:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80121a:	c9                   	leave  
  80121b:	c3                   	ret    

0080121c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80121c:	55                   	push   %ebp
  80121d:	89 e5                	mov    %esp,%ebp
  80121f:	56                   	push   %esi
  801220:	53                   	push   %ebx
  801221:	83 ec 10             	sub    $0x10,%esp
  801224:	8b 75 08             	mov    0x8(%ebp),%esi
  801227:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80122a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122d:	50                   	push   %eax
  80122e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801234:	c1 e8 0c             	shr    $0xc,%eax
  801237:	50                   	push   %eax
  801238:	e8 36 ff ff ff       	call   801173 <fd_lookup>
  80123d:	83 c4 08             	add    $0x8,%esp
  801240:	85 c0                	test   %eax,%eax
  801242:	78 05                	js     801249 <fd_close+0x2d>
	    || fd != fd2)
  801244:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801247:	74 0c                	je     801255 <fd_close+0x39>
		return (must_exist ? r : 0);
  801249:	84 db                	test   %bl,%bl
  80124b:	ba 00 00 00 00       	mov    $0x0,%edx
  801250:	0f 44 c2             	cmove  %edx,%eax
  801253:	eb 41                	jmp    801296 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801255:	83 ec 08             	sub    $0x8,%esp
  801258:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80125b:	50                   	push   %eax
  80125c:	ff 36                	pushl  (%esi)
  80125e:	e8 66 ff ff ff       	call   8011c9 <dev_lookup>
  801263:	89 c3                	mov    %eax,%ebx
  801265:	83 c4 10             	add    $0x10,%esp
  801268:	85 c0                	test   %eax,%eax
  80126a:	78 1a                	js     801286 <fd_close+0x6a>
		if (dev->dev_close)
  80126c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801272:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801277:	85 c0                	test   %eax,%eax
  801279:	74 0b                	je     801286 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80127b:	83 ec 0c             	sub    $0xc,%esp
  80127e:	56                   	push   %esi
  80127f:	ff d0                	call   *%eax
  801281:	89 c3                	mov    %eax,%ebx
  801283:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801286:	83 ec 08             	sub    $0x8,%esp
  801289:	56                   	push   %esi
  80128a:	6a 00                	push   $0x0
  80128c:	e8 6d fa ff ff       	call   800cfe <sys_page_unmap>
	return r;
  801291:	83 c4 10             	add    $0x10,%esp
  801294:	89 d8                	mov    %ebx,%eax
}
  801296:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801299:	5b                   	pop    %ebx
  80129a:	5e                   	pop    %esi
  80129b:	5d                   	pop    %ebp
  80129c:	c3                   	ret    

0080129d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a6:	50                   	push   %eax
  8012a7:	ff 75 08             	pushl  0x8(%ebp)
  8012aa:	e8 c4 fe ff ff       	call   801173 <fd_lookup>
  8012af:	83 c4 08             	add    $0x8,%esp
  8012b2:	85 c0                	test   %eax,%eax
  8012b4:	78 10                	js     8012c6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012b6:	83 ec 08             	sub    $0x8,%esp
  8012b9:	6a 01                	push   $0x1
  8012bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8012be:	e8 59 ff ff ff       	call   80121c <fd_close>
  8012c3:	83 c4 10             	add    $0x10,%esp
}
  8012c6:	c9                   	leave  
  8012c7:	c3                   	ret    

008012c8 <close_all>:

void
close_all(void)
{
  8012c8:	55                   	push   %ebp
  8012c9:	89 e5                	mov    %esp,%ebp
  8012cb:	53                   	push   %ebx
  8012cc:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012cf:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012d4:	83 ec 0c             	sub    $0xc,%esp
  8012d7:	53                   	push   %ebx
  8012d8:	e8 c0 ff ff ff       	call   80129d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012dd:	83 c3 01             	add    $0x1,%ebx
  8012e0:	83 c4 10             	add    $0x10,%esp
  8012e3:	83 fb 20             	cmp    $0x20,%ebx
  8012e6:	75 ec                	jne    8012d4 <close_all+0xc>
		close(i);
}
  8012e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012eb:	c9                   	leave  
  8012ec:	c3                   	ret    

008012ed <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012ed:	55                   	push   %ebp
  8012ee:	89 e5                	mov    %esp,%ebp
  8012f0:	57                   	push   %edi
  8012f1:	56                   	push   %esi
  8012f2:	53                   	push   %ebx
  8012f3:	83 ec 2c             	sub    $0x2c,%esp
  8012f6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012f9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012fc:	50                   	push   %eax
  8012fd:	ff 75 08             	pushl  0x8(%ebp)
  801300:	e8 6e fe ff ff       	call   801173 <fd_lookup>
  801305:	83 c4 08             	add    $0x8,%esp
  801308:	85 c0                	test   %eax,%eax
  80130a:	0f 88 c1 00 00 00    	js     8013d1 <dup+0xe4>
		return r;
	close(newfdnum);
  801310:	83 ec 0c             	sub    $0xc,%esp
  801313:	56                   	push   %esi
  801314:	e8 84 ff ff ff       	call   80129d <close>

	newfd = INDEX2FD(newfdnum);
  801319:	89 f3                	mov    %esi,%ebx
  80131b:	c1 e3 0c             	shl    $0xc,%ebx
  80131e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801324:	83 c4 04             	add    $0x4,%esp
  801327:	ff 75 e4             	pushl  -0x1c(%ebp)
  80132a:	e8 de fd ff ff       	call   80110d <fd2data>
  80132f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801331:	89 1c 24             	mov    %ebx,(%esp)
  801334:	e8 d4 fd ff ff       	call   80110d <fd2data>
  801339:	83 c4 10             	add    $0x10,%esp
  80133c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80133f:	89 f8                	mov    %edi,%eax
  801341:	c1 e8 16             	shr    $0x16,%eax
  801344:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80134b:	a8 01                	test   $0x1,%al
  80134d:	74 37                	je     801386 <dup+0x99>
  80134f:	89 f8                	mov    %edi,%eax
  801351:	c1 e8 0c             	shr    $0xc,%eax
  801354:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80135b:	f6 c2 01             	test   $0x1,%dl
  80135e:	74 26                	je     801386 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801360:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801367:	83 ec 0c             	sub    $0xc,%esp
  80136a:	25 07 0e 00 00       	and    $0xe07,%eax
  80136f:	50                   	push   %eax
  801370:	ff 75 d4             	pushl  -0x2c(%ebp)
  801373:	6a 00                	push   $0x0
  801375:	57                   	push   %edi
  801376:	6a 00                	push   $0x0
  801378:	e8 3f f9 ff ff       	call   800cbc <sys_page_map>
  80137d:	89 c7                	mov    %eax,%edi
  80137f:	83 c4 20             	add    $0x20,%esp
  801382:	85 c0                	test   %eax,%eax
  801384:	78 2e                	js     8013b4 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801386:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801389:	89 d0                	mov    %edx,%eax
  80138b:	c1 e8 0c             	shr    $0xc,%eax
  80138e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801395:	83 ec 0c             	sub    $0xc,%esp
  801398:	25 07 0e 00 00       	and    $0xe07,%eax
  80139d:	50                   	push   %eax
  80139e:	53                   	push   %ebx
  80139f:	6a 00                	push   $0x0
  8013a1:	52                   	push   %edx
  8013a2:	6a 00                	push   $0x0
  8013a4:	e8 13 f9 ff ff       	call   800cbc <sys_page_map>
  8013a9:	89 c7                	mov    %eax,%edi
  8013ab:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013ae:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013b0:	85 ff                	test   %edi,%edi
  8013b2:	79 1d                	jns    8013d1 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013b4:	83 ec 08             	sub    $0x8,%esp
  8013b7:	53                   	push   %ebx
  8013b8:	6a 00                	push   $0x0
  8013ba:	e8 3f f9 ff ff       	call   800cfe <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013bf:	83 c4 08             	add    $0x8,%esp
  8013c2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013c5:	6a 00                	push   $0x0
  8013c7:	e8 32 f9 ff ff       	call   800cfe <sys_page_unmap>
	return r;
  8013cc:	83 c4 10             	add    $0x10,%esp
  8013cf:	89 f8                	mov    %edi,%eax
}
  8013d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d4:	5b                   	pop    %ebx
  8013d5:	5e                   	pop    %esi
  8013d6:	5f                   	pop    %edi
  8013d7:	5d                   	pop    %ebp
  8013d8:	c3                   	ret    

008013d9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013d9:	55                   	push   %ebp
  8013da:	89 e5                	mov    %esp,%ebp
  8013dc:	53                   	push   %ebx
  8013dd:	83 ec 14             	sub    $0x14,%esp
  8013e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e6:	50                   	push   %eax
  8013e7:	53                   	push   %ebx
  8013e8:	e8 86 fd ff ff       	call   801173 <fd_lookup>
  8013ed:	83 c4 08             	add    $0x8,%esp
  8013f0:	89 c2                	mov    %eax,%edx
  8013f2:	85 c0                	test   %eax,%eax
  8013f4:	78 6d                	js     801463 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f6:	83 ec 08             	sub    $0x8,%esp
  8013f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fc:	50                   	push   %eax
  8013fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801400:	ff 30                	pushl  (%eax)
  801402:	e8 c2 fd ff ff       	call   8011c9 <dev_lookup>
  801407:	83 c4 10             	add    $0x10,%esp
  80140a:	85 c0                	test   %eax,%eax
  80140c:	78 4c                	js     80145a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80140e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801411:	8b 42 08             	mov    0x8(%edx),%eax
  801414:	83 e0 03             	and    $0x3,%eax
  801417:	83 f8 01             	cmp    $0x1,%eax
  80141a:	75 21                	jne    80143d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80141c:	a1 20 44 80 00       	mov    0x804420,%eax
  801421:	8b 40 48             	mov    0x48(%eax),%eax
  801424:	83 ec 04             	sub    $0x4,%esp
  801427:	53                   	push   %ebx
  801428:	50                   	push   %eax
  801429:	68 e8 27 80 00       	push   $0x8027e8
  80142e:	e8 be ee ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  801433:	83 c4 10             	add    $0x10,%esp
  801436:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80143b:	eb 26                	jmp    801463 <read+0x8a>
	}
	if (!dev->dev_read)
  80143d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801440:	8b 40 08             	mov    0x8(%eax),%eax
  801443:	85 c0                	test   %eax,%eax
  801445:	74 17                	je     80145e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801447:	83 ec 04             	sub    $0x4,%esp
  80144a:	ff 75 10             	pushl  0x10(%ebp)
  80144d:	ff 75 0c             	pushl  0xc(%ebp)
  801450:	52                   	push   %edx
  801451:	ff d0                	call   *%eax
  801453:	89 c2                	mov    %eax,%edx
  801455:	83 c4 10             	add    $0x10,%esp
  801458:	eb 09                	jmp    801463 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80145a:	89 c2                	mov    %eax,%edx
  80145c:	eb 05                	jmp    801463 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80145e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801463:	89 d0                	mov    %edx,%eax
  801465:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801468:	c9                   	leave  
  801469:	c3                   	ret    

0080146a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80146a:	55                   	push   %ebp
  80146b:	89 e5                	mov    %esp,%ebp
  80146d:	57                   	push   %edi
  80146e:	56                   	push   %esi
  80146f:	53                   	push   %ebx
  801470:	83 ec 0c             	sub    $0xc,%esp
  801473:	8b 7d 08             	mov    0x8(%ebp),%edi
  801476:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801479:	bb 00 00 00 00       	mov    $0x0,%ebx
  80147e:	eb 21                	jmp    8014a1 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801480:	83 ec 04             	sub    $0x4,%esp
  801483:	89 f0                	mov    %esi,%eax
  801485:	29 d8                	sub    %ebx,%eax
  801487:	50                   	push   %eax
  801488:	89 d8                	mov    %ebx,%eax
  80148a:	03 45 0c             	add    0xc(%ebp),%eax
  80148d:	50                   	push   %eax
  80148e:	57                   	push   %edi
  80148f:	e8 45 ff ff ff       	call   8013d9 <read>
		if (m < 0)
  801494:	83 c4 10             	add    $0x10,%esp
  801497:	85 c0                	test   %eax,%eax
  801499:	78 10                	js     8014ab <readn+0x41>
			return m;
		if (m == 0)
  80149b:	85 c0                	test   %eax,%eax
  80149d:	74 0a                	je     8014a9 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80149f:	01 c3                	add    %eax,%ebx
  8014a1:	39 f3                	cmp    %esi,%ebx
  8014a3:	72 db                	jb     801480 <readn+0x16>
  8014a5:	89 d8                	mov    %ebx,%eax
  8014a7:	eb 02                	jmp    8014ab <readn+0x41>
  8014a9:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ae:	5b                   	pop    %ebx
  8014af:	5e                   	pop    %esi
  8014b0:	5f                   	pop    %edi
  8014b1:	5d                   	pop    %ebp
  8014b2:	c3                   	ret    

008014b3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014b3:	55                   	push   %ebp
  8014b4:	89 e5                	mov    %esp,%ebp
  8014b6:	53                   	push   %ebx
  8014b7:	83 ec 14             	sub    $0x14,%esp
  8014ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c0:	50                   	push   %eax
  8014c1:	53                   	push   %ebx
  8014c2:	e8 ac fc ff ff       	call   801173 <fd_lookup>
  8014c7:	83 c4 08             	add    $0x8,%esp
  8014ca:	89 c2                	mov    %eax,%edx
  8014cc:	85 c0                	test   %eax,%eax
  8014ce:	78 68                	js     801538 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d0:	83 ec 08             	sub    $0x8,%esp
  8014d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d6:	50                   	push   %eax
  8014d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014da:	ff 30                	pushl  (%eax)
  8014dc:	e8 e8 fc ff ff       	call   8011c9 <dev_lookup>
  8014e1:	83 c4 10             	add    $0x10,%esp
  8014e4:	85 c0                	test   %eax,%eax
  8014e6:	78 47                	js     80152f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014eb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014ef:	75 21                	jne    801512 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f1:	a1 20 44 80 00       	mov    0x804420,%eax
  8014f6:	8b 40 48             	mov    0x48(%eax),%eax
  8014f9:	83 ec 04             	sub    $0x4,%esp
  8014fc:	53                   	push   %ebx
  8014fd:	50                   	push   %eax
  8014fe:	68 04 28 80 00       	push   $0x802804
  801503:	e8 e9 ed ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801510:	eb 26                	jmp    801538 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801512:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801515:	8b 52 0c             	mov    0xc(%edx),%edx
  801518:	85 d2                	test   %edx,%edx
  80151a:	74 17                	je     801533 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80151c:	83 ec 04             	sub    $0x4,%esp
  80151f:	ff 75 10             	pushl  0x10(%ebp)
  801522:	ff 75 0c             	pushl  0xc(%ebp)
  801525:	50                   	push   %eax
  801526:	ff d2                	call   *%edx
  801528:	89 c2                	mov    %eax,%edx
  80152a:	83 c4 10             	add    $0x10,%esp
  80152d:	eb 09                	jmp    801538 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152f:	89 c2                	mov    %eax,%edx
  801531:	eb 05                	jmp    801538 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801533:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801538:	89 d0                	mov    %edx,%eax
  80153a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153d:	c9                   	leave  
  80153e:	c3                   	ret    

0080153f <seek>:

int
seek(int fdnum, off_t offset)
{
  80153f:	55                   	push   %ebp
  801540:	89 e5                	mov    %esp,%ebp
  801542:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801545:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801548:	50                   	push   %eax
  801549:	ff 75 08             	pushl  0x8(%ebp)
  80154c:	e8 22 fc ff ff       	call   801173 <fd_lookup>
  801551:	83 c4 08             	add    $0x8,%esp
  801554:	85 c0                	test   %eax,%eax
  801556:	78 0e                	js     801566 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801558:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80155b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80155e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801561:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801566:	c9                   	leave  
  801567:	c3                   	ret    

00801568 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801568:	55                   	push   %ebp
  801569:	89 e5                	mov    %esp,%ebp
  80156b:	53                   	push   %ebx
  80156c:	83 ec 14             	sub    $0x14,%esp
  80156f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801572:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801575:	50                   	push   %eax
  801576:	53                   	push   %ebx
  801577:	e8 f7 fb ff ff       	call   801173 <fd_lookup>
  80157c:	83 c4 08             	add    $0x8,%esp
  80157f:	89 c2                	mov    %eax,%edx
  801581:	85 c0                	test   %eax,%eax
  801583:	78 65                	js     8015ea <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801585:	83 ec 08             	sub    $0x8,%esp
  801588:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158b:	50                   	push   %eax
  80158c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158f:	ff 30                	pushl  (%eax)
  801591:	e8 33 fc ff ff       	call   8011c9 <dev_lookup>
  801596:	83 c4 10             	add    $0x10,%esp
  801599:	85 c0                	test   %eax,%eax
  80159b:	78 44                	js     8015e1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80159d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015a4:	75 21                	jne    8015c7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015a6:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015ab:	8b 40 48             	mov    0x48(%eax),%eax
  8015ae:	83 ec 04             	sub    $0x4,%esp
  8015b1:	53                   	push   %ebx
  8015b2:	50                   	push   %eax
  8015b3:	68 c4 27 80 00       	push   $0x8027c4
  8015b8:	e8 34 ed ff ff       	call   8002f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015bd:	83 c4 10             	add    $0x10,%esp
  8015c0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015c5:	eb 23                	jmp    8015ea <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ca:	8b 52 18             	mov    0x18(%edx),%edx
  8015cd:	85 d2                	test   %edx,%edx
  8015cf:	74 14                	je     8015e5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015d1:	83 ec 08             	sub    $0x8,%esp
  8015d4:	ff 75 0c             	pushl  0xc(%ebp)
  8015d7:	50                   	push   %eax
  8015d8:	ff d2                	call   *%edx
  8015da:	89 c2                	mov    %eax,%edx
  8015dc:	83 c4 10             	add    $0x10,%esp
  8015df:	eb 09                	jmp    8015ea <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e1:	89 c2                	mov    %eax,%edx
  8015e3:	eb 05                	jmp    8015ea <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015e5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015ea:	89 d0                	mov    %edx,%eax
  8015ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ef:	c9                   	leave  
  8015f0:	c3                   	ret    

008015f1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015f1:	55                   	push   %ebp
  8015f2:	89 e5                	mov    %esp,%ebp
  8015f4:	53                   	push   %ebx
  8015f5:	83 ec 14             	sub    $0x14,%esp
  8015f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015fe:	50                   	push   %eax
  8015ff:	ff 75 08             	pushl  0x8(%ebp)
  801602:	e8 6c fb ff ff       	call   801173 <fd_lookup>
  801607:	83 c4 08             	add    $0x8,%esp
  80160a:	89 c2                	mov    %eax,%edx
  80160c:	85 c0                	test   %eax,%eax
  80160e:	78 58                	js     801668 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801610:	83 ec 08             	sub    $0x8,%esp
  801613:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801616:	50                   	push   %eax
  801617:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161a:	ff 30                	pushl  (%eax)
  80161c:	e8 a8 fb ff ff       	call   8011c9 <dev_lookup>
  801621:	83 c4 10             	add    $0x10,%esp
  801624:	85 c0                	test   %eax,%eax
  801626:	78 37                	js     80165f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801628:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80162f:	74 32                	je     801663 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801631:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801634:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80163b:	00 00 00 
	stat->st_isdir = 0;
  80163e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801645:	00 00 00 
	stat->st_dev = dev;
  801648:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80164e:	83 ec 08             	sub    $0x8,%esp
  801651:	53                   	push   %ebx
  801652:	ff 75 f0             	pushl  -0x10(%ebp)
  801655:	ff 50 14             	call   *0x14(%eax)
  801658:	89 c2                	mov    %eax,%edx
  80165a:	83 c4 10             	add    $0x10,%esp
  80165d:	eb 09                	jmp    801668 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165f:	89 c2                	mov    %eax,%edx
  801661:	eb 05                	jmp    801668 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801663:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801668:	89 d0                	mov    %edx,%eax
  80166a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166d:	c9                   	leave  
  80166e:	c3                   	ret    

0080166f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80166f:	55                   	push   %ebp
  801670:	89 e5                	mov    %esp,%ebp
  801672:	56                   	push   %esi
  801673:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801674:	83 ec 08             	sub    $0x8,%esp
  801677:	6a 00                	push   $0x0
  801679:	ff 75 08             	pushl  0x8(%ebp)
  80167c:	e8 d6 01 00 00       	call   801857 <open>
  801681:	89 c3                	mov    %eax,%ebx
  801683:	83 c4 10             	add    $0x10,%esp
  801686:	85 c0                	test   %eax,%eax
  801688:	78 1b                	js     8016a5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80168a:	83 ec 08             	sub    $0x8,%esp
  80168d:	ff 75 0c             	pushl  0xc(%ebp)
  801690:	50                   	push   %eax
  801691:	e8 5b ff ff ff       	call   8015f1 <fstat>
  801696:	89 c6                	mov    %eax,%esi
	close(fd);
  801698:	89 1c 24             	mov    %ebx,(%esp)
  80169b:	e8 fd fb ff ff       	call   80129d <close>
	return r;
  8016a0:	83 c4 10             	add    $0x10,%esp
  8016a3:	89 f0                	mov    %esi,%eax
}
  8016a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a8:	5b                   	pop    %ebx
  8016a9:	5e                   	pop    %esi
  8016aa:	5d                   	pop    %ebp
  8016ab:	c3                   	ret    

008016ac <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	56                   	push   %esi
  8016b0:	53                   	push   %ebx
  8016b1:	89 c6                	mov    %eax,%esi
  8016b3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016b5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016bc:	75 12                	jne    8016d0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016be:	83 ec 0c             	sub    $0xc,%esp
  8016c1:	6a 01                	push   $0x1
  8016c3:	e8 87 08 00 00       	call   801f4f <ipc_find_env>
  8016c8:	a3 00 40 80 00       	mov    %eax,0x804000
  8016cd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016d0:	6a 07                	push   $0x7
  8016d2:	68 00 50 80 00       	push   $0x805000
  8016d7:	56                   	push   %esi
  8016d8:	ff 35 00 40 80 00    	pushl  0x804000
  8016de:	e8 18 08 00 00       	call   801efb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016e3:	83 c4 0c             	add    $0xc,%esp
  8016e6:	6a 00                	push   $0x0
  8016e8:	53                   	push   %ebx
  8016e9:	6a 00                	push   $0x0
  8016eb:	e8 a4 07 00 00       	call   801e94 <ipc_recv>
}
  8016f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f3:	5b                   	pop    %ebx
  8016f4:	5e                   	pop    %esi
  8016f5:	5d                   	pop    %ebp
  8016f6:	c3                   	ret    

008016f7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801700:	8b 40 0c             	mov    0xc(%eax),%eax
  801703:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801708:	8b 45 0c             	mov    0xc(%ebp),%eax
  80170b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801710:	ba 00 00 00 00       	mov    $0x0,%edx
  801715:	b8 02 00 00 00       	mov    $0x2,%eax
  80171a:	e8 8d ff ff ff       	call   8016ac <fsipc>
}
  80171f:	c9                   	leave  
  801720:	c3                   	ret    

00801721 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801721:	55                   	push   %ebp
  801722:	89 e5                	mov    %esp,%ebp
  801724:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801727:	8b 45 08             	mov    0x8(%ebp),%eax
  80172a:	8b 40 0c             	mov    0xc(%eax),%eax
  80172d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801732:	ba 00 00 00 00       	mov    $0x0,%edx
  801737:	b8 06 00 00 00       	mov    $0x6,%eax
  80173c:	e8 6b ff ff ff       	call   8016ac <fsipc>
}
  801741:	c9                   	leave  
  801742:	c3                   	ret    

00801743 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801743:	55                   	push   %ebp
  801744:	89 e5                	mov    %esp,%ebp
  801746:	53                   	push   %ebx
  801747:	83 ec 04             	sub    $0x4,%esp
  80174a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80174d:	8b 45 08             	mov    0x8(%ebp),%eax
  801750:	8b 40 0c             	mov    0xc(%eax),%eax
  801753:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801758:	ba 00 00 00 00       	mov    $0x0,%edx
  80175d:	b8 05 00 00 00       	mov    $0x5,%eax
  801762:	e8 45 ff ff ff       	call   8016ac <fsipc>
  801767:	85 c0                	test   %eax,%eax
  801769:	78 2c                	js     801797 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80176b:	83 ec 08             	sub    $0x8,%esp
  80176e:	68 00 50 80 00       	push   $0x805000
  801773:	53                   	push   %ebx
  801774:	e8 fd f0 ff ff       	call   800876 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801779:	a1 80 50 80 00       	mov    0x805080,%eax
  80177e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801784:	a1 84 50 80 00       	mov    0x805084,%eax
  801789:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80178f:	83 c4 10             	add    $0x10,%esp
  801792:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801797:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179a:	c9                   	leave  
  80179b:	c3                   	ret    

0080179c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80179c:	55                   	push   %ebp
  80179d:	89 e5                	mov    %esp,%ebp
  80179f:	83 ec 0c             	sub    $0xc,%esp
  8017a2:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8017a8:	8b 52 0c             	mov    0xc(%edx),%edx
  8017ab:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017b1:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017b6:	50                   	push   %eax
  8017b7:	ff 75 0c             	pushl  0xc(%ebp)
  8017ba:	68 08 50 80 00       	push   $0x805008
  8017bf:	e8 44 f2 ff ff       	call   800a08 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8017c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c9:	b8 04 00 00 00       	mov    $0x4,%eax
  8017ce:	e8 d9 fe ff ff       	call   8016ac <fsipc>

}
  8017d3:	c9                   	leave  
  8017d4:	c3                   	ret    

008017d5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	56                   	push   %esi
  8017d9:	53                   	push   %ebx
  8017da:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017e8:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f3:	b8 03 00 00 00       	mov    $0x3,%eax
  8017f8:	e8 af fe ff ff       	call   8016ac <fsipc>
  8017fd:	89 c3                	mov    %eax,%ebx
  8017ff:	85 c0                	test   %eax,%eax
  801801:	78 4b                	js     80184e <devfile_read+0x79>
		return r;
	assert(r <= n);
  801803:	39 c6                	cmp    %eax,%esi
  801805:	73 16                	jae    80181d <devfile_read+0x48>
  801807:	68 34 28 80 00       	push   $0x802834
  80180c:	68 3b 28 80 00       	push   $0x80283b
  801811:	6a 7c                	push   $0x7c
  801813:	68 50 28 80 00       	push   $0x802850
  801818:	e8 fb e9 ff ff       	call   800218 <_panic>
	assert(r <= PGSIZE);
  80181d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801822:	7e 16                	jle    80183a <devfile_read+0x65>
  801824:	68 5b 28 80 00       	push   $0x80285b
  801829:	68 3b 28 80 00       	push   $0x80283b
  80182e:	6a 7d                	push   $0x7d
  801830:	68 50 28 80 00       	push   $0x802850
  801835:	e8 de e9 ff ff       	call   800218 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80183a:	83 ec 04             	sub    $0x4,%esp
  80183d:	50                   	push   %eax
  80183e:	68 00 50 80 00       	push   $0x805000
  801843:	ff 75 0c             	pushl  0xc(%ebp)
  801846:	e8 bd f1 ff ff       	call   800a08 <memmove>
	return r;
  80184b:	83 c4 10             	add    $0x10,%esp
}
  80184e:	89 d8                	mov    %ebx,%eax
  801850:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801853:	5b                   	pop    %ebx
  801854:	5e                   	pop    %esi
  801855:	5d                   	pop    %ebp
  801856:	c3                   	ret    

00801857 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	53                   	push   %ebx
  80185b:	83 ec 20             	sub    $0x20,%esp
  80185e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801861:	53                   	push   %ebx
  801862:	e8 d6 ef ff ff       	call   80083d <strlen>
  801867:	83 c4 10             	add    $0x10,%esp
  80186a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80186f:	7f 67                	jg     8018d8 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801871:	83 ec 0c             	sub    $0xc,%esp
  801874:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801877:	50                   	push   %eax
  801878:	e8 a7 f8 ff ff       	call   801124 <fd_alloc>
  80187d:	83 c4 10             	add    $0x10,%esp
		return r;
  801880:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801882:	85 c0                	test   %eax,%eax
  801884:	78 57                	js     8018dd <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801886:	83 ec 08             	sub    $0x8,%esp
  801889:	53                   	push   %ebx
  80188a:	68 00 50 80 00       	push   $0x805000
  80188f:	e8 e2 ef ff ff       	call   800876 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801894:	8b 45 0c             	mov    0xc(%ebp),%eax
  801897:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80189c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80189f:	b8 01 00 00 00       	mov    $0x1,%eax
  8018a4:	e8 03 fe ff ff       	call   8016ac <fsipc>
  8018a9:	89 c3                	mov    %eax,%ebx
  8018ab:	83 c4 10             	add    $0x10,%esp
  8018ae:	85 c0                	test   %eax,%eax
  8018b0:	79 14                	jns    8018c6 <open+0x6f>
		fd_close(fd, 0);
  8018b2:	83 ec 08             	sub    $0x8,%esp
  8018b5:	6a 00                	push   $0x0
  8018b7:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ba:	e8 5d f9 ff ff       	call   80121c <fd_close>
		return r;
  8018bf:	83 c4 10             	add    $0x10,%esp
  8018c2:	89 da                	mov    %ebx,%edx
  8018c4:	eb 17                	jmp    8018dd <open+0x86>
	}

	return fd2num(fd);
  8018c6:	83 ec 0c             	sub    $0xc,%esp
  8018c9:	ff 75 f4             	pushl  -0xc(%ebp)
  8018cc:	e8 2c f8 ff ff       	call   8010fd <fd2num>
  8018d1:	89 c2                	mov    %eax,%edx
  8018d3:	83 c4 10             	add    $0x10,%esp
  8018d6:	eb 05                	jmp    8018dd <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018d8:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018dd:	89 d0                	mov    %edx,%eax
  8018df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e2:	c9                   	leave  
  8018e3:	c3                   	ret    

008018e4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
  8018e7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ef:	b8 08 00 00 00       	mov    $0x8,%eax
  8018f4:	e8 b3 fd ff ff       	call   8016ac <fsipc>
}
  8018f9:	c9                   	leave  
  8018fa:	c3                   	ret    

008018fb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018fb:	55                   	push   %ebp
  8018fc:	89 e5                	mov    %esp,%ebp
  8018fe:	56                   	push   %esi
  8018ff:	53                   	push   %ebx
  801900:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801903:	83 ec 0c             	sub    $0xc,%esp
  801906:	ff 75 08             	pushl  0x8(%ebp)
  801909:	e8 ff f7 ff ff       	call   80110d <fd2data>
  80190e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801910:	83 c4 08             	add    $0x8,%esp
  801913:	68 67 28 80 00       	push   $0x802867
  801918:	53                   	push   %ebx
  801919:	e8 58 ef ff ff       	call   800876 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80191e:	8b 46 04             	mov    0x4(%esi),%eax
  801921:	2b 06                	sub    (%esi),%eax
  801923:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801929:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801930:	00 00 00 
	stat->st_dev = &devpipe;
  801933:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80193a:	30 80 00 
	return 0;
}
  80193d:	b8 00 00 00 00       	mov    $0x0,%eax
  801942:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801945:	5b                   	pop    %ebx
  801946:	5e                   	pop    %esi
  801947:	5d                   	pop    %ebp
  801948:	c3                   	ret    

00801949 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801949:	55                   	push   %ebp
  80194a:	89 e5                	mov    %esp,%ebp
  80194c:	53                   	push   %ebx
  80194d:	83 ec 0c             	sub    $0xc,%esp
  801950:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801953:	53                   	push   %ebx
  801954:	6a 00                	push   $0x0
  801956:	e8 a3 f3 ff ff       	call   800cfe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80195b:	89 1c 24             	mov    %ebx,(%esp)
  80195e:	e8 aa f7 ff ff       	call   80110d <fd2data>
  801963:	83 c4 08             	add    $0x8,%esp
  801966:	50                   	push   %eax
  801967:	6a 00                	push   $0x0
  801969:	e8 90 f3 ff ff       	call   800cfe <sys_page_unmap>
}
  80196e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801971:	c9                   	leave  
  801972:	c3                   	ret    

00801973 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	57                   	push   %edi
  801977:	56                   	push   %esi
  801978:	53                   	push   %ebx
  801979:	83 ec 1c             	sub    $0x1c,%esp
  80197c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80197f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801981:	a1 20 44 80 00       	mov    0x804420,%eax
  801986:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801989:	83 ec 0c             	sub    $0xc,%esp
  80198c:	ff 75 e0             	pushl  -0x20(%ebp)
  80198f:	e8 f4 05 00 00       	call   801f88 <pageref>
  801994:	89 c3                	mov    %eax,%ebx
  801996:	89 3c 24             	mov    %edi,(%esp)
  801999:	e8 ea 05 00 00       	call   801f88 <pageref>
  80199e:	83 c4 10             	add    $0x10,%esp
  8019a1:	39 c3                	cmp    %eax,%ebx
  8019a3:	0f 94 c1             	sete   %cl
  8019a6:	0f b6 c9             	movzbl %cl,%ecx
  8019a9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019ac:	8b 15 20 44 80 00    	mov    0x804420,%edx
  8019b2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019b5:	39 ce                	cmp    %ecx,%esi
  8019b7:	74 1b                	je     8019d4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8019b9:	39 c3                	cmp    %eax,%ebx
  8019bb:	75 c4                	jne    801981 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019bd:	8b 42 58             	mov    0x58(%edx),%eax
  8019c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019c3:	50                   	push   %eax
  8019c4:	56                   	push   %esi
  8019c5:	68 6e 28 80 00       	push   $0x80286e
  8019ca:	e8 22 e9 ff ff       	call   8002f1 <cprintf>
  8019cf:	83 c4 10             	add    $0x10,%esp
  8019d2:	eb ad                	jmp    801981 <_pipeisclosed+0xe>
	}
}
  8019d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019da:	5b                   	pop    %ebx
  8019db:	5e                   	pop    %esi
  8019dc:	5f                   	pop    %edi
  8019dd:	5d                   	pop    %ebp
  8019de:	c3                   	ret    

008019df <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019df:	55                   	push   %ebp
  8019e0:	89 e5                	mov    %esp,%ebp
  8019e2:	57                   	push   %edi
  8019e3:	56                   	push   %esi
  8019e4:	53                   	push   %ebx
  8019e5:	83 ec 28             	sub    $0x28,%esp
  8019e8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019eb:	56                   	push   %esi
  8019ec:	e8 1c f7 ff ff       	call   80110d <fd2data>
  8019f1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019f3:	83 c4 10             	add    $0x10,%esp
  8019f6:	bf 00 00 00 00       	mov    $0x0,%edi
  8019fb:	eb 4b                	jmp    801a48 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019fd:	89 da                	mov    %ebx,%edx
  8019ff:	89 f0                	mov    %esi,%eax
  801a01:	e8 6d ff ff ff       	call   801973 <_pipeisclosed>
  801a06:	85 c0                	test   %eax,%eax
  801a08:	75 48                	jne    801a52 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a0a:	e8 4b f2 ff ff       	call   800c5a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a0f:	8b 43 04             	mov    0x4(%ebx),%eax
  801a12:	8b 0b                	mov    (%ebx),%ecx
  801a14:	8d 51 20             	lea    0x20(%ecx),%edx
  801a17:	39 d0                	cmp    %edx,%eax
  801a19:	73 e2                	jae    8019fd <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a1e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a22:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a25:	89 c2                	mov    %eax,%edx
  801a27:	c1 fa 1f             	sar    $0x1f,%edx
  801a2a:	89 d1                	mov    %edx,%ecx
  801a2c:	c1 e9 1b             	shr    $0x1b,%ecx
  801a2f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a32:	83 e2 1f             	and    $0x1f,%edx
  801a35:	29 ca                	sub    %ecx,%edx
  801a37:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a3b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a3f:	83 c0 01             	add    $0x1,%eax
  801a42:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a45:	83 c7 01             	add    $0x1,%edi
  801a48:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a4b:	75 c2                	jne    801a0f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a4d:	8b 45 10             	mov    0x10(%ebp),%eax
  801a50:	eb 05                	jmp    801a57 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a52:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a5a:	5b                   	pop    %ebx
  801a5b:	5e                   	pop    %esi
  801a5c:	5f                   	pop    %edi
  801a5d:	5d                   	pop    %ebp
  801a5e:	c3                   	ret    

00801a5f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	57                   	push   %edi
  801a63:	56                   	push   %esi
  801a64:	53                   	push   %ebx
  801a65:	83 ec 18             	sub    $0x18,%esp
  801a68:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a6b:	57                   	push   %edi
  801a6c:	e8 9c f6 ff ff       	call   80110d <fd2data>
  801a71:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a73:	83 c4 10             	add    $0x10,%esp
  801a76:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a7b:	eb 3d                	jmp    801aba <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a7d:	85 db                	test   %ebx,%ebx
  801a7f:	74 04                	je     801a85 <devpipe_read+0x26>
				return i;
  801a81:	89 d8                	mov    %ebx,%eax
  801a83:	eb 44                	jmp    801ac9 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a85:	89 f2                	mov    %esi,%edx
  801a87:	89 f8                	mov    %edi,%eax
  801a89:	e8 e5 fe ff ff       	call   801973 <_pipeisclosed>
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	75 32                	jne    801ac4 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a92:	e8 c3 f1 ff ff       	call   800c5a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a97:	8b 06                	mov    (%esi),%eax
  801a99:	3b 46 04             	cmp    0x4(%esi),%eax
  801a9c:	74 df                	je     801a7d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a9e:	99                   	cltd   
  801a9f:	c1 ea 1b             	shr    $0x1b,%edx
  801aa2:	01 d0                	add    %edx,%eax
  801aa4:	83 e0 1f             	and    $0x1f,%eax
  801aa7:	29 d0                	sub    %edx,%eax
  801aa9:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801aae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ab1:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ab4:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ab7:	83 c3 01             	add    $0x1,%ebx
  801aba:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801abd:	75 d8                	jne    801a97 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801abf:	8b 45 10             	mov    0x10(%ebp),%eax
  801ac2:	eb 05                	jmp    801ac9 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ac4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ac9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801acc:	5b                   	pop    %ebx
  801acd:	5e                   	pop    %esi
  801ace:	5f                   	pop    %edi
  801acf:	5d                   	pop    %ebp
  801ad0:	c3                   	ret    

00801ad1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ad1:	55                   	push   %ebp
  801ad2:	89 e5                	mov    %esp,%ebp
  801ad4:	56                   	push   %esi
  801ad5:	53                   	push   %ebx
  801ad6:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ad9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801adc:	50                   	push   %eax
  801add:	e8 42 f6 ff ff       	call   801124 <fd_alloc>
  801ae2:	83 c4 10             	add    $0x10,%esp
  801ae5:	89 c2                	mov    %eax,%edx
  801ae7:	85 c0                	test   %eax,%eax
  801ae9:	0f 88 2c 01 00 00    	js     801c1b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aef:	83 ec 04             	sub    $0x4,%esp
  801af2:	68 07 04 00 00       	push   $0x407
  801af7:	ff 75 f4             	pushl  -0xc(%ebp)
  801afa:	6a 00                	push   $0x0
  801afc:	e8 78 f1 ff ff       	call   800c79 <sys_page_alloc>
  801b01:	83 c4 10             	add    $0x10,%esp
  801b04:	89 c2                	mov    %eax,%edx
  801b06:	85 c0                	test   %eax,%eax
  801b08:	0f 88 0d 01 00 00    	js     801c1b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b0e:	83 ec 0c             	sub    $0xc,%esp
  801b11:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b14:	50                   	push   %eax
  801b15:	e8 0a f6 ff ff       	call   801124 <fd_alloc>
  801b1a:	89 c3                	mov    %eax,%ebx
  801b1c:	83 c4 10             	add    $0x10,%esp
  801b1f:	85 c0                	test   %eax,%eax
  801b21:	0f 88 e2 00 00 00    	js     801c09 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b27:	83 ec 04             	sub    $0x4,%esp
  801b2a:	68 07 04 00 00       	push   $0x407
  801b2f:	ff 75 f0             	pushl  -0x10(%ebp)
  801b32:	6a 00                	push   $0x0
  801b34:	e8 40 f1 ff ff       	call   800c79 <sys_page_alloc>
  801b39:	89 c3                	mov    %eax,%ebx
  801b3b:	83 c4 10             	add    $0x10,%esp
  801b3e:	85 c0                	test   %eax,%eax
  801b40:	0f 88 c3 00 00 00    	js     801c09 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b46:	83 ec 0c             	sub    $0xc,%esp
  801b49:	ff 75 f4             	pushl  -0xc(%ebp)
  801b4c:	e8 bc f5 ff ff       	call   80110d <fd2data>
  801b51:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b53:	83 c4 0c             	add    $0xc,%esp
  801b56:	68 07 04 00 00       	push   $0x407
  801b5b:	50                   	push   %eax
  801b5c:	6a 00                	push   $0x0
  801b5e:	e8 16 f1 ff ff       	call   800c79 <sys_page_alloc>
  801b63:	89 c3                	mov    %eax,%ebx
  801b65:	83 c4 10             	add    $0x10,%esp
  801b68:	85 c0                	test   %eax,%eax
  801b6a:	0f 88 89 00 00 00    	js     801bf9 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b70:	83 ec 0c             	sub    $0xc,%esp
  801b73:	ff 75 f0             	pushl  -0x10(%ebp)
  801b76:	e8 92 f5 ff ff       	call   80110d <fd2data>
  801b7b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b82:	50                   	push   %eax
  801b83:	6a 00                	push   $0x0
  801b85:	56                   	push   %esi
  801b86:	6a 00                	push   $0x0
  801b88:	e8 2f f1 ff ff       	call   800cbc <sys_page_map>
  801b8d:	89 c3                	mov    %eax,%ebx
  801b8f:	83 c4 20             	add    $0x20,%esp
  801b92:	85 c0                	test   %eax,%eax
  801b94:	78 55                	js     801beb <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b96:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b9f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bab:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bb4:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bb9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bc0:	83 ec 0c             	sub    $0xc,%esp
  801bc3:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc6:	e8 32 f5 ff ff       	call   8010fd <fd2num>
  801bcb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bce:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bd0:	83 c4 04             	add    $0x4,%esp
  801bd3:	ff 75 f0             	pushl  -0x10(%ebp)
  801bd6:	e8 22 f5 ff ff       	call   8010fd <fd2num>
  801bdb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bde:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801be1:	83 c4 10             	add    $0x10,%esp
  801be4:	ba 00 00 00 00       	mov    $0x0,%edx
  801be9:	eb 30                	jmp    801c1b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801beb:	83 ec 08             	sub    $0x8,%esp
  801bee:	56                   	push   %esi
  801bef:	6a 00                	push   $0x0
  801bf1:	e8 08 f1 ff ff       	call   800cfe <sys_page_unmap>
  801bf6:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bf9:	83 ec 08             	sub    $0x8,%esp
  801bfc:	ff 75 f0             	pushl  -0x10(%ebp)
  801bff:	6a 00                	push   $0x0
  801c01:	e8 f8 f0 ff ff       	call   800cfe <sys_page_unmap>
  801c06:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c09:	83 ec 08             	sub    $0x8,%esp
  801c0c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c0f:	6a 00                	push   $0x0
  801c11:	e8 e8 f0 ff ff       	call   800cfe <sys_page_unmap>
  801c16:	83 c4 10             	add    $0x10,%esp
  801c19:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c1b:	89 d0                	mov    %edx,%eax
  801c1d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c20:	5b                   	pop    %ebx
  801c21:	5e                   	pop    %esi
  801c22:	5d                   	pop    %ebp
  801c23:	c3                   	ret    

00801c24 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c24:	55                   	push   %ebp
  801c25:	89 e5                	mov    %esp,%ebp
  801c27:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c2d:	50                   	push   %eax
  801c2e:	ff 75 08             	pushl  0x8(%ebp)
  801c31:	e8 3d f5 ff ff       	call   801173 <fd_lookup>
  801c36:	83 c4 10             	add    $0x10,%esp
  801c39:	85 c0                	test   %eax,%eax
  801c3b:	78 18                	js     801c55 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c3d:	83 ec 0c             	sub    $0xc,%esp
  801c40:	ff 75 f4             	pushl  -0xc(%ebp)
  801c43:	e8 c5 f4 ff ff       	call   80110d <fd2data>
	return _pipeisclosed(fd, p);
  801c48:	89 c2                	mov    %eax,%edx
  801c4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4d:	e8 21 fd ff ff       	call   801973 <_pipeisclosed>
  801c52:	83 c4 10             	add    $0x10,%esp
}
  801c55:	c9                   	leave  
  801c56:	c3                   	ret    

00801c57 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801c57:	55                   	push   %ebp
  801c58:	89 e5                	mov    %esp,%ebp
  801c5a:	56                   	push   %esi
  801c5b:	53                   	push   %ebx
  801c5c:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801c5f:	85 f6                	test   %esi,%esi
  801c61:	75 16                	jne    801c79 <wait+0x22>
  801c63:	68 86 28 80 00       	push   $0x802886
  801c68:	68 3b 28 80 00       	push   $0x80283b
  801c6d:	6a 09                	push   $0x9
  801c6f:	68 91 28 80 00       	push   $0x802891
  801c74:	e8 9f e5 ff ff       	call   800218 <_panic>
	e = &envs[ENVX(envid)];
  801c79:	89 f3                	mov    %esi,%ebx
  801c7b:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801c81:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801c84:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801c8a:	eb 05                	jmp    801c91 <wait+0x3a>
		sys_yield();
  801c8c:	e8 c9 ef ff ff       	call   800c5a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801c91:	8b 43 48             	mov    0x48(%ebx),%eax
  801c94:	39 c6                	cmp    %eax,%esi
  801c96:	75 07                	jne    801c9f <wait+0x48>
  801c98:	8b 43 54             	mov    0x54(%ebx),%eax
  801c9b:	85 c0                	test   %eax,%eax
  801c9d:	75 ed                	jne    801c8c <wait+0x35>
		sys_yield();
}
  801c9f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ca2:	5b                   	pop    %ebx
  801ca3:	5e                   	pop    %esi
  801ca4:	5d                   	pop    %ebp
  801ca5:	c3                   	ret    

00801ca6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ca6:	55                   	push   %ebp
  801ca7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ca9:	b8 00 00 00 00       	mov    $0x0,%eax
  801cae:	5d                   	pop    %ebp
  801caf:	c3                   	ret    

00801cb0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cb6:	68 9c 28 80 00       	push   $0x80289c
  801cbb:	ff 75 0c             	pushl  0xc(%ebp)
  801cbe:	e8 b3 eb ff ff       	call   800876 <strcpy>
	return 0;
}
  801cc3:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc8:	c9                   	leave  
  801cc9:	c3                   	ret    

00801cca <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cca:	55                   	push   %ebp
  801ccb:	89 e5                	mov    %esp,%ebp
  801ccd:	57                   	push   %edi
  801cce:	56                   	push   %esi
  801ccf:	53                   	push   %ebx
  801cd0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cd6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cdb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ce1:	eb 2d                	jmp    801d10 <devcons_write+0x46>
		m = n - tot;
  801ce3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ce6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ce8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ceb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801cf0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cf3:	83 ec 04             	sub    $0x4,%esp
  801cf6:	53                   	push   %ebx
  801cf7:	03 45 0c             	add    0xc(%ebp),%eax
  801cfa:	50                   	push   %eax
  801cfb:	57                   	push   %edi
  801cfc:	e8 07 ed ff ff       	call   800a08 <memmove>
		sys_cputs(buf, m);
  801d01:	83 c4 08             	add    $0x8,%esp
  801d04:	53                   	push   %ebx
  801d05:	57                   	push   %edi
  801d06:	e8 b2 ee ff ff       	call   800bbd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d0b:	01 de                	add    %ebx,%esi
  801d0d:	83 c4 10             	add    $0x10,%esp
  801d10:	89 f0                	mov    %esi,%eax
  801d12:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d15:	72 cc                	jb     801ce3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d1a:	5b                   	pop    %ebx
  801d1b:	5e                   	pop    %esi
  801d1c:	5f                   	pop    %edi
  801d1d:	5d                   	pop    %ebp
  801d1e:	c3                   	ret    

00801d1f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d1f:	55                   	push   %ebp
  801d20:	89 e5                	mov    %esp,%ebp
  801d22:	83 ec 08             	sub    $0x8,%esp
  801d25:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d2a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d2e:	74 2a                	je     801d5a <devcons_read+0x3b>
  801d30:	eb 05                	jmp    801d37 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d32:	e8 23 ef ff ff       	call   800c5a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d37:	e8 9f ee ff ff       	call   800bdb <sys_cgetc>
  801d3c:	85 c0                	test   %eax,%eax
  801d3e:	74 f2                	je     801d32 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d40:	85 c0                	test   %eax,%eax
  801d42:	78 16                	js     801d5a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d44:	83 f8 04             	cmp    $0x4,%eax
  801d47:	74 0c                	je     801d55 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d49:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d4c:	88 02                	mov    %al,(%edx)
	return 1;
  801d4e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d53:	eb 05                	jmp    801d5a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d55:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d5a:	c9                   	leave  
  801d5b:	c3                   	ret    

00801d5c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d5c:	55                   	push   %ebp
  801d5d:	89 e5                	mov    %esp,%ebp
  801d5f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d62:	8b 45 08             	mov    0x8(%ebp),%eax
  801d65:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d68:	6a 01                	push   $0x1
  801d6a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d6d:	50                   	push   %eax
  801d6e:	e8 4a ee ff ff       	call   800bbd <sys_cputs>
}
  801d73:	83 c4 10             	add    $0x10,%esp
  801d76:	c9                   	leave  
  801d77:	c3                   	ret    

00801d78 <getchar>:

int
getchar(void)
{
  801d78:	55                   	push   %ebp
  801d79:	89 e5                	mov    %esp,%ebp
  801d7b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d7e:	6a 01                	push   $0x1
  801d80:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d83:	50                   	push   %eax
  801d84:	6a 00                	push   $0x0
  801d86:	e8 4e f6 ff ff       	call   8013d9 <read>
	if (r < 0)
  801d8b:	83 c4 10             	add    $0x10,%esp
  801d8e:	85 c0                	test   %eax,%eax
  801d90:	78 0f                	js     801da1 <getchar+0x29>
		return r;
	if (r < 1)
  801d92:	85 c0                	test   %eax,%eax
  801d94:	7e 06                	jle    801d9c <getchar+0x24>
		return -E_EOF;
	return c;
  801d96:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d9a:	eb 05                	jmp    801da1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d9c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801da1:	c9                   	leave  
  801da2:	c3                   	ret    

00801da3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801da3:	55                   	push   %ebp
  801da4:	89 e5                	mov    %esp,%ebp
  801da6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801da9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dac:	50                   	push   %eax
  801dad:	ff 75 08             	pushl  0x8(%ebp)
  801db0:	e8 be f3 ff ff       	call   801173 <fd_lookup>
  801db5:	83 c4 10             	add    $0x10,%esp
  801db8:	85 c0                	test   %eax,%eax
  801dba:	78 11                	js     801dcd <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801dbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dbf:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dc5:	39 10                	cmp    %edx,(%eax)
  801dc7:	0f 94 c0             	sete   %al
  801dca:	0f b6 c0             	movzbl %al,%eax
}
  801dcd:	c9                   	leave  
  801dce:	c3                   	ret    

00801dcf <opencons>:

int
opencons(void)
{
  801dcf:	55                   	push   %ebp
  801dd0:	89 e5                	mov    %esp,%ebp
  801dd2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dd5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dd8:	50                   	push   %eax
  801dd9:	e8 46 f3 ff ff       	call   801124 <fd_alloc>
  801dde:	83 c4 10             	add    $0x10,%esp
		return r;
  801de1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801de3:	85 c0                	test   %eax,%eax
  801de5:	78 3e                	js     801e25 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801de7:	83 ec 04             	sub    $0x4,%esp
  801dea:	68 07 04 00 00       	push   $0x407
  801def:	ff 75 f4             	pushl  -0xc(%ebp)
  801df2:	6a 00                	push   $0x0
  801df4:	e8 80 ee ff ff       	call   800c79 <sys_page_alloc>
  801df9:	83 c4 10             	add    $0x10,%esp
		return r;
  801dfc:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dfe:	85 c0                	test   %eax,%eax
  801e00:	78 23                	js     801e25 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e02:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e10:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e17:	83 ec 0c             	sub    $0xc,%esp
  801e1a:	50                   	push   %eax
  801e1b:	e8 dd f2 ff ff       	call   8010fd <fd2num>
  801e20:	89 c2                	mov    %eax,%edx
  801e22:	83 c4 10             	add    $0x10,%esp
}
  801e25:	89 d0                	mov    %edx,%eax
  801e27:	c9                   	leave  
  801e28:	c3                   	ret    

00801e29 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e29:	55                   	push   %ebp
  801e2a:	89 e5                	mov    %esp,%ebp
  801e2c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e2f:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e36:	75 2e                	jne    801e66 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801e38:	e8 fe ed ff ff       	call   800c3b <sys_getenvid>
  801e3d:	83 ec 04             	sub    $0x4,%esp
  801e40:	68 07 0e 00 00       	push   $0xe07
  801e45:	68 00 f0 bf ee       	push   $0xeebff000
  801e4a:	50                   	push   %eax
  801e4b:	e8 29 ee ff ff       	call   800c79 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801e50:	e8 e6 ed ff ff       	call   800c3b <sys_getenvid>
  801e55:	83 c4 08             	add    $0x8,%esp
  801e58:	68 70 1e 80 00       	push   $0x801e70
  801e5d:	50                   	push   %eax
  801e5e:	e8 61 ef ff ff       	call   800dc4 <sys_env_set_pgfault_upcall>
  801e63:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e66:	8b 45 08             	mov    0x8(%ebp),%eax
  801e69:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e6e:	c9                   	leave  
  801e6f:	c3                   	ret    

00801e70 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e70:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e71:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e76:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e78:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  801e7b:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  801e7f:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  801e83:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  801e86:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  801e89:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  801e8a:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  801e8d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  801e8e:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  801e8f:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801e93:	c3                   	ret    

00801e94 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e94:	55                   	push   %ebp
  801e95:	89 e5                	mov    %esp,%ebp
  801e97:	56                   	push   %esi
  801e98:	53                   	push   %ebx
  801e99:	8b 75 08             	mov    0x8(%ebp),%esi
  801e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801ea2:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801ea4:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ea9:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801eac:	83 ec 0c             	sub    $0xc,%esp
  801eaf:	50                   	push   %eax
  801eb0:	e8 74 ef ff ff       	call   800e29 <sys_ipc_recv>

	if (from_env_store != NULL)
  801eb5:	83 c4 10             	add    $0x10,%esp
  801eb8:	85 f6                	test   %esi,%esi
  801eba:	74 14                	je     801ed0 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801ebc:	ba 00 00 00 00       	mov    $0x0,%edx
  801ec1:	85 c0                	test   %eax,%eax
  801ec3:	78 09                	js     801ece <ipc_recv+0x3a>
  801ec5:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801ecb:	8b 52 74             	mov    0x74(%edx),%edx
  801ece:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801ed0:	85 db                	test   %ebx,%ebx
  801ed2:	74 14                	je     801ee8 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801ed4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ed9:	85 c0                	test   %eax,%eax
  801edb:	78 09                	js     801ee6 <ipc_recv+0x52>
  801edd:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801ee3:	8b 52 78             	mov    0x78(%edx),%edx
  801ee6:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801ee8:	85 c0                	test   %eax,%eax
  801eea:	78 08                	js     801ef4 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801eec:	a1 20 44 80 00       	mov    0x804420,%eax
  801ef1:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ef4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ef7:	5b                   	pop    %ebx
  801ef8:	5e                   	pop    %esi
  801ef9:	5d                   	pop    %ebp
  801efa:	c3                   	ret    

00801efb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801efb:	55                   	push   %ebp
  801efc:	89 e5                	mov    %esp,%ebp
  801efe:	57                   	push   %edi
  801eff:	56                   	push   %esi
  801f00:	53                   	push   %ebx
  801f01:	83 ec 0c             	sub    $0xc,%esp
  801f04:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f07:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f0d:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f0f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f14:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f17:	ff 75 14             	pushl  0x14(%ebp)
  801f1a:	53                   	push   %ebx
  801f1b:	56                   	push   %esi
  801f1c:	57                   	push   %edi
  801f1d:	e8 e4 ee ff ff       	call   800e06 <sys_ipc_try_send>

		if (err < 0) {
  801f22:	83 c4 10             	add    $0x10,%esp
  801f25:	85 c0                	test   %eax,%eax
  801f27:	79 1e                	jns    801f47 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801f29:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f2c:	75 07                	jne    801f35 <ipc_send+0x3a>
				sys_yield();
  801f2e:	e8 27 ed ff ff       	call   800c5a <sys_yield>
  801f33:	eb e2                	jmp    801f17 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f35:	50                   	push   %eax
  801f36:	68 a8 28 80 00       	push   $0x8028a8
  801f3b:	6a 49                	push   $0x49
  801f3d:	68 b5 28 80 00       	push   $0x8028b5
  801f42:	e8 d1 e2 ff ff       	call   800218 <_panic>
		}

	} while (err < 0);

}
  801f47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f4a:	5b                   	pop    %ebx
  801f4b:	5e                   	pop    %esi
  801f4c:	5f                   	pop    %edi
  801f4d:	5d                   	pop    %ebp
  801f4e:	c3                   	ret    

00801f4f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f4f:	55                   	push   %ebp
  801f50:	89 e5                	mov    %esp,%ebp
  801f52:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f55:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f5a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f5d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f63:	8b 52 50             	mov    0x50(%edx),%edx
  801f66:	39 ca                	cmp    %ecx,%edx
  801f68:	75 0d                	jne    801f77 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f6a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f6d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f72:	8b 40 48             	mov    0x48(%eax),%eax
  801f75:	eb 0f                	jmp    801f86 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f77:	83 c0 01             	add    $0x1,%eax
  801f7a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f7f:	75 d9                	jne    801f5a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f81:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f86:	5d                   	pop    %ebp
  801f87:	c3                   	ret    

00801f88 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f88:	55                   	push   %ebp
  801f89:	89 e5                	mov    %esp,%ebp
  801f8b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f8e:	89 d0                	mov    %edx,%eax
  801f90:	c1 e8 16             	shr    $0x16,%eax
  801f93:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f9a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f9f:	f6 c1 01             	test   $0x1,%cl
  801fa2:	74 1d                	je     801fc1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fa4:	c1 ea 0c             	shr    $0xc,%edx
  801fa7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fae:	f6 c2 01             	test   $0x1,%dl
  801fb1:	74 0e                	je     801fc1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fb3:	c1 ea 0c             	shr    $0xc,%edx
  801fb6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fbd:	ef 
  801fbe:	0f b7 c0             	movzwl %ax,%eax
}
  801fc1:	5d                   	pop    %ebp
  801fc2:	c3                   	ret    
  801fc3:	66 90                	xchg   %ax,%ax
  801fc5:	66 90                	xchg   %ax,%ax
  801fc7:	66 90                	xchg   %ax,%ax
  801fc9:	66 90                	xchg   %ax,%ax
  801fcb:	66 90                	xchg   %ax,%ax
  801fcd:	66 90                	xchg   %ax,%ax
  801fcf:	90                   	nop

00801fd0 <__udivdi3>:
  801fd0:	55                   	push   %ebp
  801fd1:	57                   	push   %edi
  801fd2:	56                   	push   %esi
  801fd3:	53                   	push   %ebx
  801fd4:	83 ec 1c             	sub    $0x1c,%esp
  801fd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fe3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fe7:	85 f6                	test   %esi,%esi
  801fe9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fed:	89 ca                	mov    %ecx,%edx
  801fef:	89 f8                	mov    %edi,%eax
  801ff1:	75 3d                	jne    802030 <__udivdi3+0x60>
  801ff3:	39 cf                	cmp    %ecx,%edi
  801ff5:	0f 87 c5 00 00 00    	ja     8020c0 <__udivdi3+0xf0>
  801ffb:	85 ff                	test   %edi,%edi
  801ffd:	89 fd                	mov    %edi,%ebp
  801fff:	75 0b                	jne    80200c <__udivdi3+0x3c>
  802001:	b8 01 00 00 00       	mov    $0x1,%eax
  802006:	31 d2                	xor    %edx,%edx
  802008:	f7 f7                	div    %edi
  80200a:	89 c5                	mov    %eax,%ebp
  80200c:	89 c8                	mov    %ecx,%eax
  80200e:	31 d2                	xor    %edx,%edx
  802010:	f7 f5                	div    %ebp
  802012:	89 c1                	mov    %eax,%ecx
  802014:	89 d8                	mov    %ebx,%eax
  802016:	89 cf                	mov    %ecx,%edi
  802018:	f7 f5                	div    %ebp
  80201a:	89 c3                	mov    %eax,%ebx
  80201c:	89 d8                	mov    %ebx,%eax
  80201e:	89 fa                	mov    %edi,%edx
  802020:	83 c4 1c             	add    $0x1c,%esp
  802023:	5b                   	pop    %ebx
  802024:	5e                   	pop    %esi
  802025:	5f                   	pop    %edi
  802026:	5d                   	pop    %ebp
  802027:	c3                   	ret    
  802028:	90                   	nop
  802029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802030:	39 ce                	cmp    %ecx,%esi
  802032:	77 74                	ja     8020a8 <__udivdi3+0xd8>
  802034:	0f bd fe             	bsr    %esi,%edi
  802037:	83 f7 1f             	xor    $0x1f,%edi
  80203a:	0f 84 98 00 00 00    	je     8020d8 <__udivdi3+0x108>
  802040:	bb 20 00 00 00       	mov    $0x20,%ebx
  802045:	89 f9                	mov    %edi,%ecx
  802047:	89 c5                	mov    %eax,%ebp
  802049:	29 fb                	sub    %edi,%ebx
  80204b:	d3 e6                	shl    %cl,%esi
  80204d:	89 d9                	mov    %ebx,%ecx
  80204f:	d3 ed                	shr    %cl,%ebp
  802051:	89 f9                	mov    %edi,%ecx
  802053:	d3 e0                	shl    %cl,%eax
  802055:	09 ee                	or     %ebp,%esi
  802057:	89 d9                	mov    %ebx,%ecx
  802059:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80205d:	89 d5                	mov    %edx,%ebp
  80205f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802063:	d3 ed                	shr    %cl,%ebp
  802065:	89 f9                	mov    %edi,%ecx
  802067:	d3 e2                	shl    %cl,%edx
  802069:	89 d9                	mov    %ebx,%ecx
  80206b:	d3 e8                	shr    %cl,%eax
  80206d:	09 c2                	or     %eax,%edx
  80206f:	89 d0                	mov    %edx,%eax
  802071:	89 ea                	mov    %ebp,%edx
  802073:	f7 f6                	div    %esi
  802075:	89 d5                	mov    %edx,%ebp
  802077:	89 c3                	mov    %eax,%ebx
  802079:	f7 64 24 0c          	mull   0xc(%esp)
  80207d:	39 d5                	cmp    %edx,%ebp
  80207f:	72 10                	jb     802091 <__udivdi3+0xc1>
  802081:	8b 74 24 08          	mov    0x8(%esp),%esi
  802085:	89 f9                	mov    %edi,%ecx
  802087:	d3 e6                	shl    %cl,%esi
  802089:	39 c6                	cmp    %eax,%esi
  80208b:	73 07                	jae    802094 <__udivdi3+0xc4>
  80208d:	39 d5                	cmp    %edx,%ebp
  80208f:	75 03                	jne    802094 <__udivdi3+0xc4>
  802091:	83 eb 01             	sub    $0x1,%ebx
  802094:	31 ff                	xor    %edi,%edi
  802096:	89 d8                	mov    %ebx,%eax
  802098:	89 fa                	mov    %edi,%edx
  80209a:	83 c4 1c             	add    $0x1c,%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5f                   	pop    %edi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    
  8020a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020a8:	31 ff                	xor    %edi,%edi
  8020aa:	31 db                	xor    %ebx,%ebx
  8020ac:	89 d8                	mov    %ebx,%eax
  8020ae:	89 fa                	mov    %edi,%edx
  8020b0:	83 c4 1c             	add    $0x1c,%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    
  8020b8:	90                   	nop
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	89 d8                	mov    %ebx,%eax
  8020c2:	f7 f7                	div    %edi
  8020c4:	31 ff                	xor    %edi,%edi
  8020c6:	89 c3                	mov    %eax,%ebx
  8020c8:	89 d8                	mov    %ebx,%eax
  8020ca:	89 fa                	mov    %edi,%edx
  8020cc:	83 c4 1c             	add    $0x1c,%esp
  8020cf:	5b                   	pop    %ebx
  8020d0:	5e                   	pop    %esi
  8020d1:	5f                   	pop    %edi
  8020d2:	5d                   	pop    %ebp
  8020d3:	c3                   	ret    
  8020d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020d8:	39 ce                	cmp    %ecx,%esi
  8020da:	72 0c                	jb     8020e8 <__udivdi3+0x118>
  8020dc:	31 db                	xor    %ebx,%ebx
  8020de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020e2:	0f 87 34 ff ff ff    	ja     80201c <__udivdi3+0x4c>
  8020e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020ed:	e9 2a ff ff ff       	jmp    80201c <__udivdi3+0x4c>
  8020f2:	66 90                	xchg   %ax,%ax
  8020f4:	66 90                	xchg   %ax,%ax
  8020f6:	66 90                	xchg   %ax,%ax
  8020f8:	66 90                	xchg   %ax,%ax
  8020fa:	66 90                	xchg   %ax,%ax
  8020fc:	66 90                	xchg   %ax,%ax
  8020fe:	66 90                	xchg   %ax,%ax

00802100 <__umoddi3>:
  802100:	55                   	push   %ebp
  802101:	57                   	push   %edi
  802102:	56                   	push   %esi
  802103:	53                   	push   %ebx
  802104:	83 ec 1c             	sub    $0x1c,%esp
  802107:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80210b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80210f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802113:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802117:	85 d2                	test   %edx,%edx
  802119:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80211d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802121:	89 f3                	mov    %esi,%ebx
  802123:	89 3c 24             	mov    %edi,(%esp)
  802126:	89 74 24 04          	mov    %esi,0x4(%esp)
  80212a:	75 1c                	jne    802148 <__umoddi3+0x48>
  80212c:	39 f7                	cmp    %esi,%edi
  80212e:	76 50                	jbe    802180 <__umoddi3+0x80>
  802130:	89 c8                	mov    %ecx,%eax
  802132:	89 f2                	mov    %esi,%edx
  802134:	f7 f7                	div    %edi
  802136:	89 d0                	mov    %edx,%eax
  802138:	31 d2                	xor    %edx,%edx
  80213a:	83 c4 1c             	add    $0x1c,%esp
  80213d:	5b                   	pop    %ebx
  80213e:	5e                   	pop    %esi
  80213f:	5f                   	pop    %edi
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    
  802142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802148:	39 f2                	cmp    %esi,%edx
  80214a:	89 d0                	mov    %edx,%eax
  80214c:	77 52                	ja     8021a0 <__umoddi3+0xa0>
  80214e:	0f bd ea             	bsr    %edx,%ebp
  802151:	83 f5 1f             	xor    $0x1f,%ebp
  802154:	75 5a                	jne    8021b0 <__umoddi3+0xb0>
  802156:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80215a:	0f 82 e0 00 00 00    	jb     802240 <__umoddi3+0x140>
  802160:	39 0c 24             	cmp    %ecx,(%esp)
  802163:	0f 86 d7 00 00 00    	jbe    802240 <__umoddi3+0x140>
  802169:	8b 44 24 08          	mov    0x8(%esp),%eax
  80216d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802171:	83 c4 1c             	add    $0x1c,%esp
  802174:	5b                   	pop    %ebx
  802175:	5e                   	pop    %esi
  802176:	5f                   	pop    %edi
  802177:	5d                   	pop    %ebp
  802178:	c3                   	ret    
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	85 ff                	test   %edi,%edi
  802182:	89 fd                	mov    %edi,%ebp
  802184:	75 0b                	jne    802191 <__umoddi3+0x91>
  802186:	b8 01 00 00 00       	mov    $0x1,%eax
  80218b:	31 d2                	xor    %edx,%edx
  80218d:	f7 f7                	div    %edi
  80218f:	89 c5                	mov    %eax,%ebp
  802191:	89 f0                	mov    %esi,%eax
  802193:	31 d2                	xor    %edx,%edx
  802195:	f7 f5                	div    %ebp
  802197:	89 c8                	mov    %ecx,%eax
  802199:	f7 f5                	div    %ebp
  80219b:	89 d0                	mov    %edx,%eax
  80219d:	eb 99                	jmp    802138 <__umoddi3+0x38>
  80219f:	90                   	nop
  8021a0:	89 c8                	mov    %ecx,%eax
  8021a2:	89 f2                	mov    %esi,%edx
  8021a4:	83 c4 1c             	add    $0x1c,%esp
  8021a7:	5b                   	pop    %ebx
  8021a8:	5e                   	pop    %esi
  8021a9:	5f                   	pop    %edi
  8021aa:	5d                   	pop    %ebp
  8021ab:	c3                   	ret    
  8021ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	8b 34 24             	mov    (%esp),%esi
  8021b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021b8:	89 e9                	mov    %ebp,%ecx
  8021ba:	29 ef                	sub    %ebp,%edi
  8021bc:	d3 e0                	shl    %cl,%eax
  8021be:	89 f9                	mov    %edi,%ecx
  8021c0:	89 f2                	mov    %esi,%edx
  8021c2:	d3 ea                	shr    %cl,%edx
  8021c4:	89 e9                	mov    %ebp,%ecx
  8021c6:	09 c2                	or     %eax,%edx
  8021c8:	89 d8                	mov    %ebx,%eax
  8021ca:	89 14 24             	mov    %edx,(%esp)
  8021cd:	89 f2                	mov    %esi,%edx
  8021cf:	d3 e2                	shl    %cl,%edx
  8021d1:	89 f9                	mov    %edi,%ecx
  8021d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021db:	d3 e8                	shr    %cl,%eax
  8021dd:	89 e9                	mov    %ebp,%ecx
  8021df:	89 c6                	mov    %eax,%esi
  8021e1:	d3 e3                	shl    %cl,%ebx
  8021e3:	89 f9                	mov    %edi,%ecx
  8021e5:	89 d0                	mov    %edx,%eax
  8021e7:	d3 e8                	shr    %cl,%eax
  8021e9:	89 e9                	mov    %ebp,%ecx
  8021eb:	09 d8                	or     %ebx,%eax
  8021ed:	89 d3                	mov    %edx,%ebx
  8021ef:	89 f2                	mov    %esi,%edx
  8021f1:	f7 34 24             	divl   (%esp)
  8021f4:	89 d6                	mov    %edx,%esi
  8021f6:	d3 e3                	shl    %cl,%ebx
  8021f8:	f7 64 24 04          	mull   0x4(%esp)
  8021fc:	39 d6                	cmp    %edx,%esi
  8021fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802202:	89 d1                	mov    %edx,%ecx
  802204:	89 c3                	mov    %eax,%ebx
  802206:	72 08                	jb     802210 <__umoddi3+0x110>
  802208:	75 11                	jne    80221b <__umoddi3+0x11b>
  80220a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80220e:	73 0b                	jae    80221b <__umoddi3+0x11b>
  802210:	2b 44 24 04          	sub    0x4(%esp),%eax
  802214:	1b 14 24             	sbb    (%esp),%edx
  802217:	89 d1                	mov    %edx,%ecx
  802219:	89 c3                	mov    %eax,%ebx
  80221b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80221f:	29 da                	sub    %ebx,%edx
  802221:	19 ce                	sbb    %ecx,%esi
  802223:	89 f9                	mov    %edi,%ecx
  802225:	89 f0                	mov    %esi,%eax
  802227:	d3 e0                	shl    %cl,%eax
  802229:	89 e9                	mov    %ebp,%ecx
  80222b:	d3 ea                	shr    %cl,%edx
  80222d:	89 e9                	mov    %ebp,%ecx
  80222f:	d3 ee                	shr    %cl,%esi
  802231:	09 d0                	or     %edx,%eax
  802233:	89 f2                	mov    %esi,%edx
  802235:	83 c4 1c             	add    $0x1c,%esp
  802238:	5b                   	pop    %ebx
  802239:	5e                   	pop    %esi
  80223a:	5f                   	pop    %edi
  80223b:	5d                   	pop    %ebp
  80223c:	c3                   	ret    
  80223d:	8d 76 00             	lea    0x0(%esi),%esi
  802240:	29 f9                	sub    %edi,%ecx
  802242:	19 d6                	sbb    %edx,%esi
  802244:	89 74 24 04          	mov    %esi,0x4(%esp)
  802248:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80224c:	e9 18 ff ff ff       	jmp    802169 <__umoddi3+0x69>
