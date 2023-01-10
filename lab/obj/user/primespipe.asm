
obj/user/primespipe.debug:     file format elf32-i386


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
  80002c:	e8 07 02 00 00       	call   800238 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  80003f:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800042:	8d 7d d8             	lea    -0x28(%ebp),%edi
{
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800045:	83 ec 04             	sub    $0x4,%esp
  800048:	6a 04                	push   $0x4
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	e8 f7 14 00 00       	call   801548 <readn>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	83 f8 04             	cmp    $0x4,%eax
  800057:	74 20                	je     800079 <primeproc+0x46>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  800059:	83 ec 0c             	sub    $0xc,%esp
  80005c:	85 c0                	test   %eax,%eax
  80005e:	ba 00 00 00 00       	mov    $0x0,%edx
  800063:	0f 4e d0             	cmovle %eax,%edx
  800066:	52                   	push   %edx
  800067:	50                   	push   %eax
  800068:	68 60 27 80 00       	push   $0x802760
  80006d:	6a 15                	push   $0x15
  80006f:	68 8f 27 80 00       	push   $0x80278f
  800074:	e8 1f 02 00 00       	call   800298 <_panic>

	cprintf("%d\n", p);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	ff 75 e0             	pushl  -0x20(%ebp)
  80007f:	68 a1 27 80 00       	push   $0x8027a1
  800084:	e8 e8 02 00 00       	call   800371 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800089:	89 3c 24             	mov    %edi,(%esp)
  80008c:	e8 85 1f 00 00       	call   802016 <pipe>
  800091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	85 c0                	test   %eax,%eax
  800099:	79 12                	jns    8000ad <primeproc+0x7a>
		panic("pipe: %e", i);
  80009b:	50                   	push   %eax
  80009c:	68 a5 27 80 00       	push   $0x8027a5
  8000a1:	6a 1b                	push   $0x1b
  8000a3:	68 8f 27 80 00       	push   $0x80278f
  8000a8:	e8 eb 01 00 00       	call   800298 <_panic>
	if ((id = fork()) < 0)
  8000ad:	e8 72 0f 00 00       	call   801024 <fork>
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	79 12                	jns    8000c8 <primeproc+0x95>
		panic("fork: %e", id);
  8000b6:	50                   	push   %eax
  8000b7:	68 ae 27 80 00       	push   $0x8027ae
  8000bc:	6a 1d                	push   $0x1d
  8000be:	68 8f 27 80 00       	push   $0x80278f
  8000c3:	e8 d0 01 00 00       	call   800298 <_panic>
	if (id == 0) {
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	75 1f                	jne    8000eb <primeproc+0xb8>
		close(fd);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	53                   	push   %ebx
  8000d0:	e8 a6 12 00 00       	call   80137b <close>
		close(pfd[1]);
  8000d5:	83 c4 04             	add    $0x4,%esp
  8000d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000db:	e8 9b 12 00 00       	call   80137b <close>
		fd = pfd[0];
  8000e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	e9 5a ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f1:	e8 85 12 00 00       	call   80137b <close>
	wfd = pfd[1];
  8000f6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8000f9:	83 c4 10             	add    $0x10,%esp

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  8000fc:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000ff:	83 ec 04             	sub    $0x4,%esp
  800102:	6a 04                	push   $0x4
  800104:	56                   	push   %esi
  800105:	53                   	push   %ebx
  800106:	e8 3d 14 00 00       	call   801548 <readn>
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	83 f8 04             	cmp    $0x4,%eax
  800111:	74 24                	je     800137 <primeproc+0x104>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800113:	83 ec 04             	sub    $0x4,%esp
  800116:	85 c0                	test   %eax,%eax
  800118:	ba 00 00 00 00       	mov    $0x0,%edx
  80011d:	0f 4e d0             	cmovle %eax,%edx
  800120:	52                   	push   %edx
  800121:	50                   	push   %eax
  800122:	53                   	push   %ebx
  800123:	ff 75 e0             	pushl  -0x20(%ebp)
  800126:	68 b7 27 80 00       	push   $0x8027b7
  80012b:	6a 2b                	push   $0x2b
  80012d:	68 8f 27 80 00       	push   $0x80278f
  800132:	e8 61 01 00 00       	call   800298 <_panic>
		if (i%p)
  800137:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80013a:	99                   	cltd   
  80013b:	f7 7d e0             	idivl  -0x20(%ebp)
  80013e:	85 d2                	test   %edx,%edx
  800140:	74 bd                	je     8000ff <primeproc+0xcc>
			if ((r=write(wfd, &i, 4)) != 4)
  800142:	83 ec 04             	sub    $0x4,%esp
  800145:	6a 04                	push   $0x4
  800147:	56                   	push   %esi
  800148:	57                   	push   %edi
  800149:	e8 43 14 00 00       	call   801591 <write>
  80014e:	83 c4 10             	add    $0x10,%esp
  800151:	83 f8 04             	cmp    $0x4,%eax
  800154:	74 a9                	je     8000ff <primeproc+0xcc>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  800156:	83 ec 08             	sub    $0x8,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	ba 00 00 00 00       	mov    $0x0,%edx
  800160:	0f 4e d0             	cmovle %eax,%edx
  800163:	52                   	push   %edx
  800164:	50                   	push   %eax
  800165:	ff 75 e0             	pushl  -0x20(%ebp)
  800168:	68 d3 27 80 00       	push   $0x8027d3
  80016d:	6a 2e                	push   $0x2e
  80016f:	68 8f 27 80 00       	push   $0x80278f
  800174:	e8 1f 01 00 00       	call   800298 <_panic>

00800179 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	53                   	push   %ebx
  80017d:	83 ec 20             	sub    $0x20,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  800180:	c7 05 00 30 80 00 ed 	movl   $0x8027ed,0x803000
  800187:	27 80 00 

	if ((i=pipe(p)) < 0)
  80018a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	e8 83 1e 00 00       	call   802016 <pipe>
  800193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	85 c0                	test   %eax,%eax
  80019b:	79 12                	jns    8001af <umain+0x36>
		panic("pipe: %e", i);
  80019d:	50                   	push   %eax
  80019e:	68 a5 27 80 00       	push   $0x8027a5
  8001a3:	6a 3a                	push   $0x3a
  8001a5:	68 8f 27 80 00       	push   $0x80278f
  8001aa:	e8 e9 00 00 00       	call   800298 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001af:	e8 70 0e 00 00       	call   801024 <fork>
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	79 12                	jns    8001ca <umain+0x51>
		panic("fork: %e", id);
  8001b8:	50                   	push   %eax
  8001b9:	68 ae 27 80 00       	push   $0x8027ae
  8001be:	6a 3e                	push   $0x3e
  8001c0:	68 8f 27 80 00       	push   $0x80278f
  8001c5:	e8 ce 00 00 00       	call   800298 <_panic>

	if (id == 0) {
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	75 16                	jne    8001e4 <umain+0x6b>
		close(p[1]);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d4:	e8 a2 11 00 00       	call   80137b <close>
		primeproc(p[0]);
  8001d9:	83 c4 04             	add    $0x4,%esp
  8001dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8001df:	e8 4f fe ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ea:	e8 8c 11 00 00       	call   80137b <close>

	// feed all the integers through
	for (i=2;; i++)
  8001ef:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
  8001f6:	83 c4 10             	add    $0x10,%esp
		if ((r=write(p[1], &i, 4)) != 4)
  8001f9:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  8001fc:	83 ec 04             	sub    $0x4,%esp
  8001ff:	6a 04                	push   $0x4
  800201:	53                   	push   %ebx
  800202:	ff 75 f0             	pushl  -0x10(%ebp)
  800205:	e8 87 13 00 00       	call   801591 <write>
  80020a:	83 c4 10             	add    $0x10,%esp
  80020d:	83 f8 04             	cmp    $0x4,%eax
  800210:	74 20                	je     800232 <umain+0xb9>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	85 c0                	test   %eax,%eax
  800217:	ba 00 00 00 00       	mov    $0x0,%edx
  80021c:	0f 4e d0             	cmovle %eax,%edx
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	68 f8 27 80 00       	push   $0x8027f8
  800226:	6a 4a                	push   $0x4a
  800228:	68 8f 27 80 00       	push   $0x80278f
  80022d:	e8 66 00 00 00       	call   800298 <_panic>
	}

	close(p[0]);

	// feed all the integers through
	for (i=2;; i++)
  800232:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
}
  800236:	eb c4                	jmp    8001fc <umain+0x83>

00800238 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800240:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800243:	e8 73 0a 00 00       	call   800cbb <sys_getenvid>
  800248:	25 ff 03 00 00       	and    $0x3ff,%eax
  80024d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800250:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800255:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80025a:	85 db                	test   %ebx,%ebx
  80025c:	7e 07                	jle    800265 <libmain+0x2d>
		binaryname = argv[0];
  80025e:	8b 06                	mov    (%esi),%eax
  800260:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	e8 0a ff ff ff       	call   800179 <umain>

	// exit gracefully
	exit();
  80026f:	e8 0a 00 00 00       	call   80027e <exit>
}
  800274:	83 c4 10             	add    $0x10,%esp
  800277:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80027a:	5b                   	pop    %ebx
  80027b:	5e                   	pop    %esi
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    

0080027e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800284:	e8 1d 11 00 00       	call   8013a6 <close_all>
	sys_env_destroy(0);
  800289:	83 ec 0c             	sub    $0xc,%esp
  80028c:	6a 00                	push   $0x0
  80028e:	e8 e7 09 00 00       	call   800c7a <sys_env_destroy>
}
  800293:	83 c4 10             	add    $0x10,%esp
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	56                   	push   %esi
  80029c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80029d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002a0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002a6:	e8 10 0a 00 00       	call   800cbb <sys_getenvid>
  8002ab:	83 ec 0c             	sub    $0xc,%esp
  8002ae:	ff 75 0c             	pushl  0xc(%ebp)
  8002b1:	ff 75 08             	pushl  0x8(%ebp)
  8002b4:	56                   	push   %esi
  8002b5:	50                   	push   %eax
  8002b6:	68 1c 28 80 00       	push   $0x80281c
  8002bb:	e8 b1 00 00 00       	call   800371 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002c0:	83 c4 18             	add    $0x18,%esp
  8002c3:	53                   	push   %ebx
  8002c4:	ff 75 10             	pushl  0x10(%ebp)
  8002c7:	e8 54 00 00 00       	call   800320 <vcprintf>
	cprintf("\n");
  8002cc:	c7 04 24 a3 27 80 00 	movl   $0x8027a3,(%esp)
  8002d3:	e8 99 00 00 00       	call   800371 <cprintf>
  8002d8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002db:	cc                   	int3   
  8002dc:	eb fd                	jmp    8002db <_panic+0x43>

008002de <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	53                   	push   %ebx
  8002e2:	83 ec 04             	sub    $0x4,%esp
  8002e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e8:	8b 13                	mov    (%ebx),%edx
  8002ea:	8d 42 01             	lea    0x1(%edx),%eax
  8002ed:	89 03                	mov    %eax,(%ebx)
  8002ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002f6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002fb:	75 1a                	jne    800317 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002fd:	83 ec 08             	sub    $0x8,%esp
  800300:	68 ff 00 00 00       	push   $0xff
  800305:	8d 43 08             	lea    0x8(%ebx),%eax
  800308:	50                   	push   %eax
  800309:	e8 2f 09 00 00       	call   800c3d <sys_cputs>
		b->idx = 0;
  80030e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800314:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800317:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80031b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800329:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800330:	00 00 00 
	b.cnt = 0;
  800333:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80033a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80033d:	ff 75 0c             	pushl  0xc(%ebp)
  800340:	ff 75 08             	pushl  0x8(%ebp)
  800343:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800349:	50                   	push   %eax
  80034a:	68 de 02 80 00       	push   $0x8002de
  80034f:	e8 54 01 00 00       	call   8004a8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800354:	83 c4 08             	add    $0x8,%esp
  800357:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80035d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800363:	50                   	push   %eax
  800364:	e8 d4 08 00 00       	call   800c3d <sys_cputs>

	return b.cnt;
}
  800369:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80036f:	c9                   	leave  
  800370:	c3                   	ret    

00800371 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800377:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80037a:	50                   	push   %eax
  80037b:	ff 75 08             	pushl  0x8(%ebp)
  80037e:	e8 9d ff ff ff       	call   800320 <vcprintf>
	va_end(ap);

	return cnt;
}
  800383:	c9                   	leave  
  800384:	c3                   	ret    

00800385 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	57                   	push   %edi
  800389:	56                   	push   %esi
  80038a:	53                   	push   %ebx
  80038b:	83 ec 1c             	sub    $0x1c,%esp
  80038e:	89 c7                	mov    %eax,%edi
  800390:	89 d6                	mov    %edx,%esi
  800392:	8b 45 08             	mov    0x8(%ebp),%eax
  800395:	8b 55 0c             	mov    0xc(%ebp),%edx
  800398:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80039e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003a9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003ac:	39 d3                	cmp    %edx,%ebx
  8003ae:	72 05                	jb     8003b5 <printnum+0x30>
  8003b0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003b3:	77 45                	ja     8003fa <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003b5:	83 ec 0c             	sub    $0xc,%esp
  8003b8:	ff 75 18             	pushl  0x18(%ebp)
  8003bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003be:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003c1:	53                   	push   %ebx
  8003c2:	ff 75 10             	pushl  0x10(%ebp)
  8003c5:	83 ec 08             	sub    $0x8,%esp
  8003c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8003d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d4:	e8 e7 20 00 00       	call   8024c0 <__udivdi3>
  8003d9:	83 c4 18             	add    $0x18,%esp
  8003dc:	52                   	push   %edx
  8003dd:	50                   	push   %eax
  8003de:	89 f2                	mov    %esi,%edx
  8003e0:	89 f8                	mov    %edi,%eax
  8003e2:	e8 9e ff ff ff       	call   800385 <printnum>
  8003e7:	83 c4 20             	add    $0x20,%esp
  8003ea:	eb 18                	jmp    800404 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003ec:	83 ec 08             	sub    $0x8,%esp
  8003ef:	56                   	push   %esi
  8003f0:	ff 75 18             	pushl  0x18(%ebp)
  8003f3:	ff d7                	call   *%edi
  8003f5:	83 c4 10             	add    $0x10,%esp
  8003f8:	eb 03                	jmp    8003fd <printnum+0x78>
  8003fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003fd:	83 eb 01             	sub    $0x1,%ebx
  800400:	85 db                	test   %ebx,%ebx
  800402:	7f e8                	jg     8003ec <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	56                   	push   %esi
  800408:	83 ec 04             	sub    $0x4,%esp
  80040b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80040e:	ff 75 e0             	pushl  -0x20(%ebp)
  800411:	ff 75 dc             	pushl  -0x24(%ebp)
  800414:	ff 75 d8             	pushl  -0x28(%ebp)
  800417:	e8 d4 21 00 00       	call   8025f0 <__umoddi3>
  80041c:	83 c4 14             	add    $0x14,%esp
  80041f:	0f be 80 3f 28 80 00 	movsbl 0x80283f(%eax),%eax
  800426:	50                   	push   %eax
  800427:	ff d7                	call   *%edi
}
  800429:	83 c4 10             	add    $0x10,%esp
  80042c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80042f:	5b                   	pop    %ebx
  800430:	5e                   	pop    %esi
  800431:	5f                   	pop    %edi
  800432:	5d                   	pop    %ebp
  800433:	c3                   	ret    

00800434 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800437:	83 fa 01             	cmp    $0x1,%edx
  80043a:	7e 0e                	jle    80044a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80043c:	8b 10                	mov    (%eax),%edx
  80043e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800441:	89 08                	mov    %ecx,(%eax)
  800443:	8b 02                	mov    (%edx),%eax
  800445:	8b 52 04             	mov    0x4(%edx),%edx
  800448:	eb 22                	jmp    80046c <getuint+0x38>
	else if (lflag)
  80044a:	85 d2                	test   %edx,%edx
  80044c:	74 10                	je     80045e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80044e:	8b 10                	mov    (%eax),%edx
  800450:	8d 4a 04             	lea    0x4(%edx),%ecx
  800453:	89 08                	mov    %ecx,(%eax)
  800455:	8b 02                	mov    (%edx),%eax
  800457:	ba 00 00 00 00       	mov    $0x0,%edx
  80045c:	eb 0e                	jmp    80046c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80045e:	8b 10                	mov    (%eax),%edx
  800460:	8d 4a 04             	lea    0x4(%edx),%ecx
  800463:	89 08                	mov    %ecx,(%eax)
  800465:	8b 02                	mov    (%edx),%eax
  800467:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80046c:	5d                   	pop    %ebp
  80046d:	c3                   	ret    

0080046e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800474:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800478:	8b 10                	mov    (%eax),%edx
  80047a:	3b 50 04             	cmp    0x4(%eax),%edx
  80047d:	73 0a                	jae    800489 <sprintputch+0x1b>
		*b->buf++ = ch;
  80047f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800482:	89 08                	mov    %ecx,(%eax)
  800484:	8b 45 08             	mov    0x8(%ebp),%eax
  800487:	88 02                	mov    %al,(%edx)
}
  800489:	5d                   	pop    %ebp
  80048a:	c3                   	ret    

0080048b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80048b:	55                   	push   %ebp
  80048c:	89 e5                	mov    %esp,%ebp
  80048e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800491:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800494:	50                   	push   %eax
  800495:	ff 75 10             	pushl  0x10(%ebp)
  800498:	ff 75 0c             	pushl  0xc(%ebp)
  80049b:	ff 75 08             	pushl  0x8(%ebp)
  80049e:	e8 05 00 00 00       	call   8004a8 <vprintfmt>
	va_end(ap);
}
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	c9                   	leave  
  8004a7:	c3                   	ret    

008004a8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004a8:	55                   	push   %ebp
  8004a9:	89 e5                	mov    %esp,%ebp
  8004ab:	57                   	push   %edi
  8004ac:	56                   	push   %esi
  8004ad:	53                   	push   %ebx
  8004ae:	83 ec 2c             	sub    $0x2c,%esp
  8004b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004ba:	eb 12                	jmp    8004ce <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004bc:	85 c0                	test   %eax,%eax
  8004be:	0f 84 89 03 00 00    	je     80084d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8004c4:	83 ec 08             	sub    $0x8,%esp
  8004c7:	53                   	push   %ebx
  8004c8:	50                   	push   %eax
  8004c9:	ff d6                	call   *%esi
  8004cb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004ce:	83 c7 01             	add    $0x1,%edi
  8004d1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004d5:	83 f8 25             	cmp    $0x25,%eax
  8004d8:	75 e2                	jne    8004bc <vprintfmt+0x14>
  8004da:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004de:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004e5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004ec:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f8:	eb 07                	jmp    800501 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004fd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800501:	8d 47 01             	lea    0x1(%edi),%eax
  800504:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800507:	0f b6 07             	movzbl (%edi),%eax
  80050a:	0f b6 c8             	movzbl %al,%ecx
  80050d:	83 e8 23             	sub    $0x23,%eax
  800510:	3c 55                	cmp    $0x55,%al
  800512:	0f 87 1a 03 00 00    	ja     800832 <vprintfmt+0x38a>
  800518:	0f b6 c0             	movzbl %al,%eax
  80051b:	ff 24 85 80 29 80 00 	jmp    *0x802980(,%eax,4)
  800522:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800525:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800529:	eb d6                	jmp    800501 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80052e:	b8 00 00 00 00       	mov    $0x0,%eax
  800533:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800536:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800539:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80053d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800540:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800543:	83 fa 09             	cmp    $0x9,%edx
  800546:	77 39                	ja     800581 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800548:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80054b:	eb e9                	jmp    800536 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8d 48 04             	lea    0x4(%eax),%ecx
  800553:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800556:	8b 00                	mov    (%eax),%eax
  800558:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80055e:	eb 27                	jmp    800587 <vprintfmt+0xdf>
  800560:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800563:	85 c0                	test   %eax,%eax
  800565:	b9 00 00 00 00       	mov    $0x0,%ecx
  80056a:	0f 49 c8             	cmovns %eax,%ecx
  80056d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800570:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800573:	eb 8c                	jmp    800501 <vprintfmt+0x59>
  800575:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800578:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80057f:	eb 80                	jmp    800501 <vprintfmt+0x59>
  800581:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800584:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800587:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058b:	0f 89 70 ff ff ff    	jns    800501 <vprintfmt+0x59>
				width = precision, precision = -1;
  800591:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800594:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800597:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80059e:	e9 5e ff ff ff       	jmp    800501 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005a3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005a9:	e9 53 ff ff ff       	jmp    800501 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 04             	lea    0x4(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	53                   	push   %ebx
  8005bb:	ff 30                	pushl  (%eax)
  8005bd:	ff d6                	call   *%esi
			break;
  8005bf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005c5:	e9 04 ff ff ff       	jmp    8004ce <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 50 04             	lea    0x4(%eax),%edx
  8005d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	99                   	cltd   
  8005d6:	31 d0                	xor    %edx,%eax
  8005d8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005da:	83 f8 0f             	cmp    $0xf,%eax
  8005dd:	7f 0b                	jg     8005ea <vprintfmt+0x142>
  8005df:	8b 14 85 e0 2a 80 00 	mov    0x802ae0(,%eax,4),%edx
  8005e6:	85 d2                	test   %edx,%edx
  8005e8:	75 18                	jne    800602 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005ea:	50                   	push   %eax
  8005eb:	68 57 28 80 00       	push   $0x802857
  8005f0:	53                   	push   %ebx
  8005f1:	56                   	push   %esi
  8005f2:	e8 94 fe ff ff       	call   80048b <printfmt>
  8005f7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005fd:	e9 cc fe ff ff       	jmp    8004ce <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800602:	52                   	push   %edx
  800603:	68 d1 2c 80 00       	push   $0x802cd1
  800608:	53                   	push   %ebx
  800609:	56                   	push   %esi
  80060a:	e8 7c fe ff ff       	call   80048b <printfmt>
  80060f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800612:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800615:	e9 b4 fe ff ff       	jmp    8004ce <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8d 50 04             	lea    0x4(%eax),%edx
  800620:	89 55 14             	mov    %edx,0x14(%ebp)
  800623:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800625:	85 ff                	test   %edi,%edi
  800627:	b8 50 28 80 00       	mov    $0x802850,%eax
  80062c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80062f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800633:	0f 8e 94 00 00 00    	jle    8006cd <vprintfmt+0x225>
  800639:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80063d:	0f 84 98 00 00 00    	je     8006db <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	ff 75 d0             	pushl  -0x30(%ebp)
  800649:	57                   	push   %edi
  80064a:	e8 86 02 00 00       	call   8008d5 <strnlen>
  80064f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800652:	29 c1                	sub    %eax,%ecx
  800654:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800657:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80065a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80065e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800661:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800664:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800666:	eb 0f                	jmp    800677 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	53                   	push   %ebx
  80066c:	ff 75 e0             	pushl  -0x20(%ebp)
  80066f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800671:	83 ef 01             	sub    $0x1,%edi
  800674:	83 c4 10             	add    $0x10,%esp
  800677:	85 ff                	test   %edi,%edi
  800679:	7f ed                	jg     800668 <vprintfmt+0x1c0>
  80067b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80067e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800681:	85 c9                	test   %ecx,%ecx
  800683:	b8 00 00 00 00       	mov    $0x0,%eax
  800688:	0f 49 c1             	cmovns %ecx,%eax
  80068b:	29 c1                	sub    %eax,%ecx
  80068d:	89 75 08             	mov    %esi,0x8(%ebp)
  800690:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800693:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800696:	89 cb                	mov    %ecx,%ebx
  800698:	eb 4d                	jmp    8006e7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80069a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80069e:	74 1b                	je     8006bb <vprintfmt+0x213>
  8006a0:	0f be c0             	movsbl %al,%eax
  8006a3:	83 e8 20             	sub    $0x20,%eax
  8006a6:	83 f8 5e             	cmp    $0x5e,%eax
  8006a9:	76 10                	jbe    8006bb <vprintfmt+0x213>
					putch('?', putdat);
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	ff 75 0c             	pushl  0xc(%ebp)
  8006b1:	6a 3f                	push   $0x3f
  8006b3:	ff 55 08             	call   *0x8(%ebp)
  8006b6:	83 c4 10             	add    $0x10,%esp
  8006b9:	eb 0d                	jmp    8006c8 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8006bb:	83 ec 08             	sub    $0x8,%esp
  8006be:	ff 75 0c             	pushl  0xc(%ebp)
  8006c1:	52                   	push   %edx
  8006c2:	ff 55 08             	call   *0x8(%ebp)
  8006c5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c8:	83 eb 01             	sub    $0x1,%ebx
  8006cb:	eb 1a                	jmp    8006e7 <vprintfmt+0x23f>
  8006cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8006d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006d6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006d9:	eb 0c                	jmp    8006e7 <vprintfmt+0x23f>
  8006db:	89 75 08             	mov    %esi,0x8(%ebp)
  8006de:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006e1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006e7:	83 c7 01             	add    $0x1,%edi
  8006ea:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006ee:	0f be d0             	movsbl %al,%edx
  8006f1:	85 d2                	test   %edx,%edx
  8006f3:	74 23                	je     800718 <vprintfmt+0x270>
  8006f5:	85 f6                	test   %esi,%esi
  8006f7:	78 a1                	js     80069a <vprintfmt+0x1f2>
  8006f9:	83 ee 01             	sub    $0x1,%esi
  8006fc:	79 9c                	jns    80069a <vprintfmt+0x1f2>
  8006fe:	89 df                	mov    %ebx,%edi
  800700:	8b 75 08             	mov    0x8(%ebp),%esi
  800703:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800706:	eb 18                	jmp    800720 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800708:	83 ec 08             	sub    $0x8,%esp
  80070b:	53                   	push   %ebx
  80070c:	6a 20                	push   $0x20
  80070e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800710:	83 ef 01             	sub    $0x1,%edi
  800713:	83 c4 10             	add    $0x10,%esp
  800716:	eb 08                	jmp    800720 <vprintfmt+0x278>
  800718:	89 df                	mov    %ebx,%edi
  80071a:	8b 75 08             	mov    0x8(%ebp),%esi
  80071d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800720:	85 ff                	test   %edi,%edi
  800722:	7f e4                	jg     800708 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800724:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800727:	e9 a2 fd ff ff       	jmp    8004ce <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80072c:	83 fa 01             	cmp    $0x1,%edx
  80072f:	7e 16                	jle    800747 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8d 50 08             	lea    0x8(%eax),%edx
  800737:	89 55 14             	mov    %edx,0x14(%ebp)
  80073a:	8b 50 04             	mov    0x4(%eax),%edx
  80073d:	8b 00                	mov    (%eax),%eax
  80073f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800742:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800745:	eb 32                	jmp    800779 <vprintfmt+0x2d1>
	else if (lflag)
  800747:	85 d2                	test   %edx,%edx
  800749:	74 18                	je     800763 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80074b:	8b 45 14             	mov    0x14(%ebp),%eax
  80074e:	8d 50 04             	lea    0x4(%eax),%edx
  800751:	89 55 14             	mov    %edx,0x14(%ebp)
  800754:	8b 00                	mov    (%eax),%eax
  800756:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800759:	89 c1                	mov    %eax,%ecx
  80075b:	c1 f9 1f             	sar    $0x1f,%ecx
  80075e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800761:	eb 16                	jmp    800779 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800763:	8b 45 14             	mov    0x14(%ebp),%eax
  800766:	8d 50 04             	lea    0x4(%eax),%edx
  800769:	89 55 14             	mov    %edx,0x14(%ebp)
  80076c:	8b 00                	mov    (%eax),%eax
  80076e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800771:	89 c1                	mov    %eax,%ecx
  800773:	c1 f9 1f             	sar    $0x1f,%ecx
  800776:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800779:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80077c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80077f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800784:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800788:	79 74                	jns    8007fe <vprintfmt+0x356>
				putch('-', putdat);
  80078a:	83 ec 08             	sub    $0x8,%esp
  80078d:	53                   	push   %ebx
  80078e:	6a 2d                	push   $0x2d
  800790:	ff d6                	call   *%esi
				num = -(long long) num;
  800792:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800795:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800798:	f7 d8                	neg    %eax
  80079a:	83 d2 00             	adc    $0x0,%edx
  80079d:	f7 da                	neg    %edx
  80079f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007a2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007a7:	eb 55                	jmp    8007fe <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007a9:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ac:	e8 83 fc ff ff       	call   800434 <getuint>
			base = 10;
  8007b1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007b6:	eb 46                	jmp    8007fe <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8007b8:	8d 45 14             	lea    0x14(%ebp),%eax
  8007bb:	e8 74 fc ff ff       	call   800434 <getuint>
			base = 8;
  8007c0:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007c5:	eb 37                	jmp    8007fe <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8007c7:	83 ec 08             	sub    $0x8,%esp
  8007ca:	53                   	push   %ebx
  8007cb:	6a 30                	push   $0x30
  8007cd:	ff d6                	call   *%esi
			putch('x', putdat);
  8007cf:	83 c4 08             	add    $0x8,%esp
  8007d2:	53                   	push   %ebx
  8007d3:	6a 78                	push   $0x78
  8007d5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007da:	8d 50 04             	lea    0x4(%eax),%edx
  8007dd:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007e0:	8b 00                	mov    (%eax),%eax
  8007e2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007e7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007ea:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007ef:	eb 0d                	jmp    8007fe <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f4:	e8 3b fc ff ff       	call   800434 <getuint>
			base = 16;
  8007f9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007fe:	83 ec 0c             	sub    $0xc,%esp
  800801:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800805:	57                   	push   %edi
  800806:	ff 75 e0             	pushl  -0x20(%ebp)
  800809:	51                   	push   %ecx
  80080a:	52                   	push   %edx
  80080b:	50                   	push   %eax
  80080c:	89 da                	mov    %ebx,%edx
  80080e:	89 f0                	mov    %esi,%eax
  800810:	e8 70 fb ff ff       	call   800385 <printnum>
			break;
  800815:	83 c4 20             	add    $0x20,%esp
  800818:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80081b:	e9 ae fc ff ff       	jmp    8004ce <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800820:	83 ec 08             	sub    $0x8,%esp
  800823:	53                   	push   %ebx
  800824:	51                   	push   %ecx
  800825:	ff d6                	call   *%esi
			break;
  800827:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80082d:	e9 9c fc ff ff       	jmp    8004ce <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800832:	83 ec 08             	sub    $0x8,%esp
  800835:	53                   	push   %ebx
  800836:	6a 25                	push   $0x25
  800838:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	eb 03                	jmp    800842 <vprintfmt+0x39a>
  80083f:	83 ef 01             	sub    $0x1,%edi
  800842:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800846:	75 f7                	jne    80083f <vprintfmt+0x397>
  800848:	e9 81 fc ff ff       	jmp    8004ce <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80084d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800850:	5b                   	pop    %ebx
  800851:	5e                   	pop    %esi
  800852:	5f                   	pop    %edi
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	83 ec 18             	sub    $0x18,%esp
  80085b:	8b 45 08             	mov    0x8(%ebp),%eax
  80085e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800861:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800864:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800868:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80086b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800872:	85 c0                	test   %eax,%eax
  800874:	74 26                	je     80089c <vsnprintf+0x47>
  800876:	85 d2                	test   %edx,%edx
  800878:	7e 22                	jle    80089c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80087a:	ff 75 14             	pushl  0x14(%ebp)
  80087d:	ff 75 10             	pushl  0x10(%ebp)
  800880:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800883:	50                   	push   %eax
  800884:	68 6e 04 80 00       	push   $0x80046e
  800889:	e8 1a fc ff ff       	call   8004a8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80088e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800891:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800894:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800897:	83 c4 10             	add    $0x10,%esp
  80089a:	eb 05                	jmp    8008a1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80089c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008a1:	c9                   	leave  
  8008a2:	c3                   	ret    

008008a3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008a9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008ac:	50                   	push   %eax
  8008ad:	ff 75 10             	pushl  0x10(%ebp)
  8008b0:	ff 75 0c             	pushl  0xc(%ebp)
  8008b3:	ff 75 08             	pushl  0x8(%ebp)
  8008b6:	e8 9a ff ff ff       	call   800855 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    

008008bd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c8:	eb 03                	jmp    8008cd <strlen+0x10>
		n++;
  8008ca:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008cd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008d1:	75 f7                	jne    8008ca <strlen+0xd>
		n++;
	return n;
}
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008db:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008de:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e3:	eb 03                	jmp    8008e8 <strnlen+0x13>
		n++;
  8008e5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e8:	39 c2                	cmp    %eax,%edx
  8008ea:	74 08                	je     8008f4 <strnlen+0x1f>
  8008ec:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008f0:	75 f3                	jne    8008e5 <strnlen+0x10>
  8008f2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	53                   	push   %ebx
  8008fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800900:	89 c2                	mov    %eax,%edx
  800902:	83 c2 01             	add    $0x1,%edx
  800905:	83 c1 01             	add    $0x1,%ecx
  800908:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80090c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80090f:	84 db                	test   %bl,%bl
  800911:	75 ef                	jne    800902 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800913:	5b                   	pop    %ebx
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	53                   	push   %ebx
  80091a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80091d:	53                   	push   %ebx
  80091e:	e8 9a ff ff ff       	call   8008bd <strlen>
  800923:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800926:	ff 75 0c             	pushl  0xc(%ebp)
  800929:	01 d8                	add    %ebx,%eax
  80092b:	50                   	push   %eax
  80092c:	e8 c5 ff ff ff       	call   8008f6 <strcpy>
	return dst;
}
  800931:	89 d8                	mov    %ebx,%eax
  800933:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800936:	c9                   	leave  
  800937:	c3                   	ret    

00800938 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	56                   	push   %esi
  80093c:	53                   	push   %ebx
  80093d:	8b 75 08             	mov    0x8(%ebp),%esi
  800940:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800943:	89 f3                	mov    %esi,%ebx
  800945:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800948:	89 f2                	mov    %esi,%edx
  80094a:	eb 0f                	jmp    80095b <strncpy+0x23>
		*dst++ = *src;
  80094c:	83 c2 01             	add    $0x1,%edx
  80094f:	0f b6 01             	movzbl (%ecx),%eax
  800952:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800955:	80 39 01             	cmpb   $0x1,(%ecx)
  800958:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80095b:	39 da                	cmp    %ebx,%edx
  80095d:	75 ed                	jne    80094c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80095f:	89 f0                	mov    %esi,%eax
  800961:	5b                   	pop    %ebx
  800962:	5e                   	pop    %esi
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	56                   	push   %esi
  800969:	53                   	push   %ebx
  80096a:	8b 75 08             	mov    0x8(%ebp),%esi
  80096d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800970:	8b 55 10             	mov    0x10(%ebp),%edx
  800973:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800975:	85 d2                	test   %edx,%edx
  800977:	74 21                	je     80099a <strlcpy+0x35>
  800979:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80097d:	89 f2                	mov    %esi,%edx
  80097f:	eb 09                	jmp    80098a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800981:	83 c2 01             	add    $0x1,%edx
  800984:	83 c1 01             	add    $0x1,%ecx
  800987:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80098a:	39 c2                	cmp    %eax,%edx
  80098c:	74 09                	je     800997 <strlcpy+0x32>
  80098e:	0f b6 19             	movzbl (%ecx),%ebx
  800991:	84 db                	test   %bl,%bl
  800993:	75 ec                	jne    800981 <strlcpy+0x1c>
  800995:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800997:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80099a:	29 f0                	sub    %esi,%eax
}
  80099c:	5b                   	pop    %ebx
  80099d:	5e                   	pop    %esi
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a9:	eb 06                	jmp    8009b1 <strcmp+0x11>
		p++, q++;
  8009ab:	83 c1 01             	add    $0x1,%ecx
  8009ae:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009b1:	0f b6 01             	movzbl (%ecx),%eax
  8009b4:	84 c0                	test   %al,%al
  8009b6:	74 04                	je     8009bc <strcmp+0x1c>
  8009b8:	3a 02                	cmp    (%edx),%al
  8009ba:	74 ef                	je     8009ab <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009bc:	0f b6 c0             	movzbl %al,%eax
  8009bf:	0f b6 12             	movzbl (%edx),%edx
  8009c2:	29 d0                	sub    %edx,%eax
}
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	53                   	push   %ebx
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d0:	89 c3                	mov    %eax,%ebx
  8009d2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009d5:	eb 06                	jmp    8009dd <strncmp+0x17>
		n--, p++, q++;
  8009d7:	83 c0 01             	add    $0x1,%eax
  8009da:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009dd:	39 d8                	cmp    %ebx,%eax
  8009df:	74 15                	je     8009f6 <strncmp+0x30>
  8009e1:	0f b6 08             	movzbl (%eax),%ecx
  8009e4:	84 c9                	test   %cl,%cl
  8009e6:	74 04                	je     8009ec <strncmp+0x26>
  8009e8:	3a 0a                	cmp    (%edx),%cl
  8009ea:	74 eb                	je     8009d7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ec:	0f b6 00             	movzbl (%eax),%eax
  8009ef:	0f b6 12             	movzbl (%edx),%edx
  8009f2:	29 d0                	sub    %edx,%eax
  8009f4:	eb 05                	jmp    8009fb <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009f6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009fb:	5b                   	pop    %ebx
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	8b 45 08             	mov    0x8(%ebp),%eax
  800a04:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a08:	eb 07                	jmp    800a11 <strchr+0x13>
		if (*s == c)
  800a0a:	38 ca                	cmp    %cl,%dl
  800a0c:	74 0f                	je     800a1d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a0e:	83 c0 01             	add    $0x1,%eax
  800a11:	0f b6 10             	movzbl (%eax),%edx
  800a14:	84 d2                	test   %dl,%dl
  800a16:	75 f2                	jne    800a0a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
  800a25:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a29:	eb 03                	jmp    800a2e <strfind+0xf>
  800a2b:	83 c0 01             	add    $0x1,%eax
  800a2e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a31:	38 ca                	cmp    %cl,%dl
  800a33:	74 04                	je     800a39 <strfind+0x1a>
  800a35:	84 d2                	test   %dl,%dl
  800a37:	75 f2                	jne    800a2b <strfind+0xc>
			break;
	return (char *) s;
}
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	57                   	push   %edi
  800a3f:	56                   	push   %esi
  800a40:	53                   	push   %ebx
  800a41:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a44:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a47:	85 c9                	test   %ecx,%ecx
  800a49:	74 36                	je     800a81 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a4b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a51:	75 28                	jne    800a7b <memset+0x40>
  800a53:	f6 c1 03             	test   $0x3,%cl
  800a56:	75 23                	jne    800a7b <memset+0x40>
		c &= 0xFF;
  800a58:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a5c:	89 d3                	mov    %edx,%ebx
  800a5e:	c1 e3 08             	shl    $0x8,%ebx
  800a61:	89 d6                	mov    %edx,%esi
  800a63:	c1 e6 18             	shl    $0x18,%esi
  800a66:	89 d0                	mov    %edx,%eax
  800a68:	c1 e0 10             	shl    $0x10,%eax
  800a6b:	09 f0                	or     %esi,%eax
  800a6d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a6f:	89 d8                	mov    %ebx,%eax
  800a71:	09 d0                	or     %edx,%eax
  800a73:	c1 e9 02             	shr    $0x2,%ecx
  800a76:	fc                   	cld    
  800a77:	f3 ab                	rep stos %eax,%es:(%edi)
  800a79:	eb 06                	jmp    800a81 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7e:	fc                   	cld    
  800a7f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a81:	89 f8                	mov    %edi,%eax
  800a83:	5b                   	pop    %ebx
  800a84:	5e                   	pop    %esi
  800a85:	5f                   	pop    %edi
  800a86:	5d                   	pop    %ebp
  800a87:	c3                   	ret    

00800a88 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	57                   	push   %edi
  800a8c:	56                   	push   %esi
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a90:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a93:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a96:	39 c6                	cmp    %eax,%esi
  800a98:	73 35                	jae    800acf <memmove+0x47>
  800a9a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a9d:	39 d0                	cmp    %edx,%eax
  800a9f:	73 2e                	jae    800acf <memmove+0x47>
		s += n;
		d += n;
  800aa1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa4:	89 d6                	mov    %edx,%esi
  800aa6:	09 fe                	or     %edi,%esi
  800aa8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aae:	75 13                	jne    800ac3 <memmove+0x3b>
  800ab0:	f6 c1 03             	test   $0x3,%cl
  800ab3:	75 0e                	jne    800ac3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ab5:	83 ef 04             	sub    $0x4,%edi
  800ab8:	8d 72 fc             	lea    -0x4(%edx),%esi
  800abb:	c1 e9 02             	shr    $0x2,%ecx
  800abe:	fd                   	std    
  800abf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac1:	eb 09                	jmp    800acc <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ac3:	83 ef 01             	sub    $0x1,%edi
  800ac6:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ac9:	fd                   	std    
  800aca:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800acc:	fc                   	cld    
  800acd:	eb 1d                	jmp    800aec <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800acf:	89 f2                	mov    %esi,%edx
  800ad1:	09 c2                	or     %eax,%edx
  800ad3:	f6 c2 03             	test   $0x3,%dl
  800ad6:	75 0f                	jne    800ae7 <memmove+0x5f>
  800ad8:	f6 c1 03             	test   $0x3,%cl
  800adb:	75 0a                	jne    800ae7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800add:	c1 e9 02             	shr    $0x2,%ecx
  800ae0:	89 c7                	mov    %eax,%edi
  800ae2:	fc                   	cld    
  800ae3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae5:	eb 05                	jmp    800aec <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ae7:	89 c7                	mov    %eax,%edi
  800ae9:	fc                   	cld    
  800aea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aec:	5e                   	pop    %esi
  800aed:	5f                   	pop    %edi
  800aee:	5d                   	pop    %ebp
  800aef:	c3                   	ret    

00800af0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800af3:	ff 75 10             	pushl  0x10(%ebp)
  800af6:	ff 75 0c             	pushl  0xc(%ebp)
  800af9:	ff 75 08             	pushl  0x8(%ebp)
  800afc:	e8 87 ff ff ff       	call   800a88 <memmove>
}
  800b01:	c9                   	leave  
  800b02:	c3                   	ret    

00800b03 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
  800b08:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0e:	89 c6                	mov    %eax,%esi
  800b10:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b13:	eb 1a                	jmp    800b2f <memcmp+0x2c>
		if (*s1 != *s2)
  800b15:	0f b6 08             	movzbl (%eax),%ecx
  800b18:	0f b6 1a             	movzbl (%edx),%ebx
  800b1b:	38 d9                	cmp    %bl,%cl
  800b1d:	74 0a                	je     800b29 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b1f:	0f b6 c1             	movzbl %cl,%eax
  800b22:	0f b6 db             	movzbl %bl,%ebx
  800b25:	29 d8                	sub    %ebx,%eax
  800b27:	eb 0f                	jmp    800b38 <memcmp+0x35>
		s1++, s2++;
  800b29:	83 c0 01             	add    $0x1,%eax
  800b2c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b2f:	39 f0                	cmp    %esi,%eax
  800b31:	75 e2                	jne    800b15 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	53                   	push   %ebx
  800b40:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b43:	89 c1                	mov    %eax,%ecx
  800b45:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b48:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b4c:	eb 0a                	jmp    800b58 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b4e:	0f b6 10             	movzbl (%eax),%edx
  800b51:	39 da                	cmp    %ebx,%edx
  800b53:	74 07                	je     800b5c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b55:	83 c0 01             	add    $0x1,%eax
  800b58:	39 c8                	cmp    %ecx,%eax
  800b5a:	72 f2                	jb     800b4e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
  800b65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b68:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6b:	eb 03                	jmp    800b70 <strtol+0x11>
		s++;
  800b6d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b70:	0f b6 01             	movzbl (%ecx),%eax
  800b73:	3c 20                	cmp    $0x20,%al
  800b75:	74 f6                	je     800b6d <strtol+0xe>
  800b77:	3c 09                	cmp    $0x9,%al
  800b79:	74 f2                	je     800b6d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b7b:	3c 2b                	cmp    $0x2b,%al
  800b7d:	75 0a                	jne    800b89 <strtol+0x2a>
		s++;
  800b7f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b82:	bf 00 00 00 00       	mov    $0x0,%edi
  800b87:	eb 11                	jmp    800b9a <strtol+0x3b>
  800b89:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b8e:	3c 2d                	cmp    $0x2d,%al
  800b90:	75 08                	jne    800b9a <strtol+0x3b>
		s++, neg = 1;
  800b92:	83 c1 01             	add    $0x1,%ecx
  800b95:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b9a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ba0:	75 15                	jne    800bb7 <strtol+0x58>
  800ba2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ba5:	75 10                	jne    800bb7 <strtol+0x58>
  800ba7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bab:	75 7c                	jne    800c29 <strtol+0xca>
		s += 2, base = 16;
  800bad:	83 c1 02             	add    $0x2,%ecx
  800bb0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bb5:	eb 16                	jmp    800bcd <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bb7:	85 db                	test   %ebx,%ebx
  800bb9:	75 12                	jne    800bcd <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bbb:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc0:	80 39 30             	cmpb   $0x30,(%ecx)
  800bc3:	75 08                	jne    800bcd <strtol+0x6e>
		s++, base = 8;
  800bc5:	83 c1 01             	add    $0x1,%ecx
  800bc8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bcd:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bd5:	0f b6 11             	movzbl (%ecx),%edx
  800bd8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bdb:	89 f3                	mov    %esi,%ebx
  800bdd:	80 fb 09             	cmp    $0x9,%bl
  800be0:	77 08                	ja     800bea <strtol+0x8b>
			dig = *s - '0';
  800be2:	0f be d2             	movsbl %dl,%edx
  800be5:	83 ea 30             	sub    $0x30,%edx
  800be8:	eb 22                	jmp    800c0c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bea:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bed:	89 f3                	mov    %esi,%ebx
  800bef:	80 fb 19             	cmp    $0x19,%bl
  800bf2:	77 08                	ja     800bfc <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bf4:	0f be d2             	movsbl %dl,%edx
  800bf7:	83 ea 57             	sub    $0x57,%edx
  800bfa:	eb 10                	jmp    800c0c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bfc:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bff:	89 f3                	mov    %esi,%ebx
  800c01:	80 fb 19             	cmp    $0x19,%bl
  800c04:	77 16                	ja     800c1c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c06:	0f be d2             	movsbl %dl,%edx
  800c09:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c0c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c0f:	7d 0b                	jge    800c1c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c11:	83 c1 01             	add    $0x1,%ecx
  800c14:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c18:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c1a:	eb b9                	jmp    800bd5 <strtol+0x76>

	if (endptr)
  800c1c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c20:	74 0d                	je     800c2f <strtol+0xd0>
		*endptr = (char *) s;
  800c22:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c25:	89 0e                	mov    %ecx,(%esi)
  800c27:	eb 06                	jmp    800c2f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c29:	85 db                	test   %ebx,%ebx
  800c2b:	74 98                	je     800bc5 <strtol+0x66>
  800c2d:	eb 9e                	jmp    800bcd <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c2f:	89 c2                	mov    %eax,%edx
  800c31:	f7 da                	neg    %edx
  800c33:	85 ff                	test   %edi,%edi
  800c35:	0f 45 c2             	cmovne %edx,%eax
}
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c43:	b8 00 00 00 00       	mov    $0x0,%eax
  800c48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4e:	89 c3                	mov    %eax,%ebx
  800c50:	89 c7                	mov    %eax,%edi
  800c52:	89 c6                	mov    %eax,%esi
  800c54:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <sys_cgetc>:

int
sys_cgetc(void)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	57                   	push   %edi
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c61:	ba 00 00 00 00       	mov    $0x0,%edx
  800c66:	b8 01 00 00 00       	mov    $0x1,%eax
  800c6b:	89 d1                	mov    %edx,%ecx
  800c6d:	89 d3                	mov    %edx,%ebx
  800c6f:	89 d7                	mov    %edx,%edi
  800c71:	89 d6                	mov    %edx,%esi
  800c73:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	57                   	push   %edi
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
  800c80:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c83:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c88:	b8 03 00 00 00       	mov    $0x3,%eax
  800c8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c90:	89 cb                	mov    %ecx,%ebx
  800c92:	89 cf                	mov    %ecx,%edi
  800c94:	89 ce                	mov    %ecx,%esi
  800c96:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c98:	85 c0                	test   %eax,%eax
  800c9a:	7e 17                	jle    800cb3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9c:	83 ec 0c             	sub    $0xc,%esp
  800c9f:	50                   	push   %eax
  800ca0:	6a 03                	push   $0x3
  800ca2:	68 3f 2b 80 00       	push   $0x802b3f
  800ca7:	6a 23                	push   $0x23
  800ca9:	68 5c 2b 80 00       	push   $0x802b5c
  800cae:	e8 e5 f5 ff ff       	call   800298 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb6:	5b                   	pop    %ebx
  800cb7:	5e                   	pop    %esi
  800cb8:	5f                   	pop    %edi
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	57                   	push   %edi
  800cbf:	56                   	push   %esi
  800cc0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc1:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc6:	b8 02 00 00 00       	mov    $0x2,%eax
  800ccb:	89 d1                	mov    %edx,%ecx
  800ccd:	89 d3                	mov    %edx,%ebx
  800ccf:	89 d7                	mov    %edx,%edi
  800cd1:	89 d6                	mov    %edx,%esi
  800cd3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_yield>:

void
sys_yield(void)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cea:	89 d1                	mov    %edx,%ecx
  800cec:	89 d3                	mov    %edx,%ebx
  800cee:	89 d7                	mov    %edx,%edi
  800cf0:	89 d6                	mov    %edx,%esi
  800cf2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d02:	be 00 00 00 00       	mov    $0x0,%esi
  800d07:	b8 04 00 00 00       	mov    $0x4,%eax
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d12:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d15:	89 f7                	mov    %esi,%edi
  800d17:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d19:	85 c0                	test   %eax,%eax
  800d1b:	7e 17                	jle    800d34 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1d:	83 ec 0c             	sub    $0xc,%esp
  800d20:	50                   	push   %eax
  800d21:	6a 04                	push   $0x4
  800d23:	68 3f 2b 80 00       	push   $0x802b3f
  800d28:	6a 23                	push   $0x23
  800d2a:	68 5c 2b 80 00       	push   $0x802b5c
  800d2f:	e8 64 f5 ff ff       	call   800298 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	57                   	push   %edi
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
  800d42:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d45:	b8 05 00 00 00       	mov    $0x5,%eax
  800d4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d50:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d53:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d56:	8b 75 18             	mov    0x18(%ebp),%esi
  800d59:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5b:	85 c0                	test   %eax,%eax
  800d5d:	7e 17                	jle    800d76 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5f:	83 ec 0c             	sub    $0xc,%esp
  800d62:	50                   	push   %eax
  800d63:	6a 05                	push   $0x5
  800d65:	68 3f 2b 80 00       	push   $0x802b3f
  800d6a:	6a 23                	push   $0x23
  800d6c:	68 5c 2b 80 00       	push   $0x802b5c
  800d71:	e8 22 f5 ff ff       	call   800298 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	57                   	push   %edi
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
  800d84:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d87:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8c:	b8 06 00 00 00       	mov    $0x6,%eax
  800d91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d94:	8b 55 08             	mov    0x8(%ebp),%edx
  800d97:	89 df                	mov    %ebx,%edi
  800d99:	89 de                	mov    %ebx,%esi
  800d9b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	7e 17                	jle    800db8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da1:	83 ec 0c             	sub    $0xc,%esp
  800da4:	50                   	push   %eax
  800da5:	6a 06                	push   $0x6
  800da7:	68 3f 2b 80 00       	push   $0x802b3f
  800dac:	6a 23                	push   $0x23
  800dae:	68 5c 2b 80 00       	push   $0x802b5c
  800db3:	e8 e0 f4 ff ff       	call   800298 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800db8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbb:	5b                   	pop    %ebx
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
  800dc6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dce:	b8 08 00 00 00       	mov    $0x8,%eax
  800dd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd9:	89 df                	mov    %ebx,%edi
  800ddb:	89 de                	mov    %ebx,%esi
  800ddd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ddf:	85 c0                	test   %eax,%eax
  800de1:	7e 17                	jle    800dfa <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de3:	83 ec 0c             	sub    $0xc,%esp
  800de6:	50                   	push   %eax
  800de7:	6a 08                	push   $0x8
  800de9:	68 3f 2b 80 00       	push   $0x802b3f
  800dee:	6a 23                	push   $0x23
  800df0:	68 5c 2b 80 00       	push   $0x802b5c
  800df5:	e8 9e f4 ff ff       	call   800298 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfd:	5b                   	pop    %ebx
  800dfe:	5e                   	pop    %esi
  800dff:	5f                   	pop    %edi
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	57                   	push   %edi
  800e06:	56                   	push   %esi
  800e07:	53                   	push   %ebx
  800e08:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e10:	b8 09 00 00 00       	mov    $0x9,%eax
  800e15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e18:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1b:	89 df                	mov    %ebx,%edi
  800e1d:	89 de                	mov    %ebx,%esi
  800e1f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e21:	85 c0                	test   %eax,%eax
  800e23:	7e 17                	jle    800e3c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e25:	83 ec 0c             	sub    $0xc,%esp
  800e28:	50                   	push   %eax
  800e29:	6a 09                	push   $0x9
  800e2b:	68 3f 2b 80 00       	push   $0x802b3f
  800e30:	6a 23                	push   $0x23
  800e32:	68 5c 2b 80 00       	push   $0x802b5c
  800e37:	e8 5c f4 ff ff       	call   800298 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3f:	5b                   	pop    %ebx
  800e40:	5e                   	pop    %esi
  800e41:	5f                   	pop    %edi
  800e42:	5d                   	pop    %ebp
  800e43:	c3                   	ret    

00800e44 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	57                   	push   %edi
  800e48:	56                   	push   %esi
  800e49:	53                   	push   %ebx
  800e4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e52:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5d:	89 df                	mov    %ebx,%edi
  800e5f:	89 de                	mov    %ebx,%esi
  800e61:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e63:	85 c0                	test   %eax,%eax
  800e65:	7e 17                	jle    800e7e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e67:	83 ec 0c             	sub    $0xc,%esp
  800e6a:	50                   	push   %eax
  800e6b:	6a 0a                	push   $0xa
  800e6d:	68 3f 2b 80 00       	push   $0x802b3f
  800e72:	6a 23                	push   $0x23
  800e74:	68 5c 2b 80 00       	push   $0x802b5c
  800e79:	e8 1a f4 ff ff       	call   800298 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e81:	5b                   	pop    %ebx
  800e82:	5e                   	pop    %esi
  800e83:	5f                   	pop    %edi
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    

00800e86 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	57                   	push   %edi
  800e8a:	56                   	push   %esi
  800e8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8c:	be 00 00 00 00       	mov    $0x0,%esi
  800e91:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e99:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ea2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	57                   	push   %edi
  800ead:	56                   	push   %esi
  800eae:	53                   	push   %ebx
  800eaf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ebc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebf:	89 cb                	mov    %ecx,%ebx
  800ec1:	89 cf                	mov    %ecx,%edi
  800ec3:	89 ce                	mov    %ecx,%esi
  800ec5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec7:	85 c0                	test   %eax,%eax
  800ec9:	7e 17                	jle    800ee2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ecb:	83 ec 0c             	sub    $0xc,%esp
  800ece:	50                   	push   %eax
  800ecf:	6a 0d                	push   $0xd
  800ed1:	68 3f 2b 80 00       	push   $0x802b3f
  800ed6:	6a 23                	push   $0x23
  800ed8:	68 5c 2b 80 00       	push   $0x802b5c
  800edd:	e8 b6 f3 ff ff       	call   800298 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ee2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee5:	5b                   	pop    %ebx
  800ee6:	5e                   	pop    %esi
  800ee7:	5f                   	pop    %edi
  800ee8:	5d                   	pop    %ebp
  800ee9:	c3                   	ret    

00800eea <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
  800eed:	57                   	push   %edi
  800eee:	56                   	push   %esi
  800eef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef5:	b8 0e 00 00 00       	mov    $0xe,%eax
  800efa:	89 d1                	mov    %edx,%ecx
  800efc:	89 d3                	mov    %edx,%ebx
  800efe:	89 d7                	mov    %edx,%edi
  800f00:	89 d6                	mov    %edx,%esi
  800f02:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f04:	5b                   	pop    %ebx
  800f05:	5e                   	pop    %esi
  800f06:	5f                   	pop    %edi
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    

00800f09 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	57                   	push   %edi
  800f0d:	56                   	push   %esi
  800f0e:	53                   	push   %ebx
  800f0f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f12:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f17:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f22:	89 df                	mov    %ebx,%edi
  800f24:	89 de                	mov    %ebx,%esi
  800f26:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f28:	85 c0                	test   %eax,%eax
  800f2a:	7e 17                	jle    800f43 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2c:	83 ec 0c             	sub    $0xc,%esp
  800f2f:	50                   	push   %eax
  800f30:	6a 0f                	push   $0xf
  800f32:	68 3f 2b 80 00       	push   $0x802b3f
  800f37:	6a 23                	push   $0x23
  800f39:	68 5c 2b 80 00       	push   $0x802b5c
  800f3e:	e8 55 f3 ff ff       	call   800298 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800f43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f46:	5b                   	pop    %ebx
  800f47:	5e                   	pop    %esi
  800f48:	5f                   	pop    %edi
  800f49:	5d                   	pop    %ebp
  800f4a:	c3                   	ret    

00800f4b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	56                   	push   %esi
  800f4f:	53                   	push   %ebx
  800f50:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f53:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800f55:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f59:	75 25                	jne    800f80 <pgfault+0x35>
  800f5b:	89 d8                	mov    %ebx,%eax
  800f5d:	c1 e8 0c             	shr    $0xc,%eax
  800f60:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f67:	f6 c4 08             	test   $0x8,%ah
  800f6a:	75 14                	jne    800f80 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800f6c:	83 ec 04             	sub    $0x4,%esp
  800f6f:	68 6c 2b 80 00       	push   $0x802b6c
  800f74:	6a 1e                	push   $0x1e
  800f76:	68 00 2c 80 00       	push   $0x802c00
  800f7b:	e8 18 f3 ff ff       	call   800298 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800f80:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800f86:	e8 30 fd ff ff       	call   800cbb <sys_getenvid>
  800f8b:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800f8d:	83 ec 04             	sub    $0x4,%esp
  800f90:	6a 07                	push   $0x7
  800f92:	68 00 f0 7f 00       	push   $0x7ff000
  800f97:	50                   	push   %eax
  800f98:	e8 5c fd ff ff       	call   800cf9 <sys_page_alloc>
	if (r < 0)
  800f9d:	83 c4 10             	add    $0x10,%esp
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	79 12                	jns    800fb6 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800fa4:	50                   	push   %eax
  800fa5:	68 98 2b 80 00       	push   $0x802b98
  800faa:	6a 33                	push   $0x33
  800fac:	68 00 2c 80 00       	push   $0x802c00
  800fb1:	e8 e2 f2 ff ff       	call   800298 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800fb6:	83 ec 04             	sub    $0x4,%esp
  800fb9:	68 00 10 00 00       	push   $0x1000
  800fbe:	53                   	push   %ebx
  800fbf:	68 00 f0 7f 00       	push   $0x7ff000
  800fc4:	e8 27 fb ff ff       	call   800af0 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800fc9:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fd0:	53                   	push   %ebx
  800fd1:	56                   	push   %esi
  800fd2:	68 00 f0 7f 00       	push   $0x7ff000
  800fd7:	56                   	push   %esi
  800fd8:	e8 5f fd ff ff       	call   800d3c <sys_page_map>
	if (r < 0)
  800fdd:	83 c4 20             	add    $0x20,%esp
  800fe0:	85 c0                	test   %eax,%eax
  800fe2:	79 12                	jns    800ff6 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800fe4:	50                   	push   %eax
  800fe5:	68 bc 2b 80 00       	push   $0x802bbc
  800fea:	6a 3b                	push   $0x3b
  800fec:	68 00 2c 80 00       	push   $0x802c00
  800ff1:	e8 a2 f2 ff ff       	call   800298 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800ff6:	83 ec 08             	sub    $0x8,%esp
  800ff9:	68 00 f0 7f 00       	push   $0x7ff000
  800ffe:	56                   	push   %esi
  800fff:	e8 7a fd ff ff       	call   800d7e <sys_page_unmap>
	if (r < 0)
  801004:	83 c4 10             	add    $0x10,%esp
  801007:	85 c0                	test   %eax,%eax
  801009:	79 12                	jns    80101d <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  80100b:	50                   	push   %eax
  80100c:	68 e0 2b 80 00       	push   $0x802be0
  801011:	6a 40                	push   $0x40
  801013:	68 00 2c 80 00       	push   $0x802c00
  801018:	e8 7b f2 ff ff       	call   800298 <_panic>
}
  80101d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801020:	5b                   	pop    %ebx
  801021:	5e                   	pop    %esi
  801022:	5d                   	pop    %ebp
  801023:	c3                   	ret    

00801024 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	57                   	push   %edi
  801028:	56                   	push   %esi
  801029:	53                   	push   %ebx
  80102a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  80102d:	68 4b 0f 80 00       	push   $0x800f4b
  801032:	e8 e8 12 00 00       	call   80231f <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801037:	b8 07 00 00 00       	mov    $0x7,%eax
  80103c:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  80103e:	83 c4 10             	add    $0x10,%esp
  801041:	85 c0                	test   %eax,%eax
  801043:	0f 88 64 01 00 00    	js     8011ad <fork+0x189>
  801049:	bb 00 00 80 00       	mov    $0x800000,%ebx
  80104e:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  801053:	85 c0                	test   %eax,%eax
  801055:	75 21                	jne    801078 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  801057:	e8 5f fc ff ff       	call   800cbb <sys_getenvid>
  80105c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801061:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801064:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801069:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  80106e:	ba 00 00 00 00       	mov    $0x0,%edx
  801073:	e9 3f 01 00 00       	jmp    8011b7 <fork+0x193>
  801078:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80107b:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  80107d:	89 d8                	mov    %ebx,%eax
  80107f:	c1 e8 16             	shr    $0x16,%eax
  801082:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801089:	a8 01                	test   $0x1,%al
  80108b:	0f 84 bd 00 00 00    	je     80114e <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  801091:	89 d8                	mov    %ebx,%eax
  801093:	c1 e8 0c             	shr    $0xc,%eax
  801096:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80109d:	f6 c2 01             	test   $0x1,%dl
  8010a0:	0f 84 a8 00 00 00    	je     80114e <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  8010a6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ad:	a8 04                	test   $0x4,%al
  8010af:	0f 84 99 00 00 00    	je     80114e <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  8010b5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010bc:	f6 c4 04             	test   $0x4,%ah
  8010bf:	74 17                	je     8010d8 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  8010c1:	83 ec 0c             	sub    $0xc,%esp
  8010c4:	68 07 0e 00 00       	push   $0xe07
  8010c9:	53                   	push   %ebx
  8010ca:	57                   	push   %edi
  8010cb:	53                   	push   %ebx
  8010cc:	6a 00                	push   $0x0
  8010ce:	e8 69 fc ff ff       	call   800d3c <sys_page_map>
  8010d3:	83 c4 20             	add    $0x20,%esp
  8010d6:	eb 76                	jmp    80114e <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8010d8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010df:	a8 02                	test   $0x2,%al
  8010e1:	75 0c                	jne    8010ef <fork+0xcb>
  8010e3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010ea:	f6 c4 08             	test   $0x8,%ah
  8010ed:	74 3f                	je     80112e <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  8010ef:	83 ec 0c             	sub    $0xc,%esp
  8010f2:	68 05 08 00 00       	push   $0x805
  8010f7:	53                   	push   %ebx
  8010f8:	57                   	push   %edi
  8010f9:	53                   	push   %ebx
  8010fa:	6a 00                	push   $0x0
  8010fc:	e8 3b fc ff ff       	call   800d3c <sys_page_map>
		if (r < 0)
  801101:	83 c4 20             	add    $0x20,%esp
  801104:	85 c0                	test   %eax,%eax
  801106:	0f 88 a5 00 00 00    	js     8011b1 <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  80110c:	83 ec 0c             	sub    $0xc,%esp
  80110f:	68 05 08 00 00       	push   $0x805
  801114:	53                   	push   %ebx
  801115:	6a 00                	push   $0x0
  801117:	53                   	push   %ebx
  801118:	6a 00                	push   $0x0
  80111a:	e8 1d fc ff ff       	call   800d3c <sys_page_map>
  80111f:	83 c4 20             	add    $0x20,%esp
  801122:	85 c0                	test   %eax,%eax
  801124:	b9 00 00 00 00       	mov    $0x0,%ecx
  801129:	0f 4f c1             	cmovg  %ecx,%eax
  80112c:	eb 1c                	jmp    80114a <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  80112e:	83 ec 0c             	sub    $0xc,%esp
  801131:	6a 05                	push   $0x5
  801133:	53                   	push   %ebx
  801134:	57                   	push   %edi
  801135:	53                   	push   %ebx
  801136:	6a 00                	push   $0x0
  801138:	e8 ff fb ff ff       	call   800d3c <sys_page_map>
  80113d:	83 c4 20             	add    $0x20,%esp
  801140:	85 c0                	test   %eax,%eax
  801142:	b9 00 00 00 00       	mov    $0x0,%ecx
  801147:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  80114a:	85 c0                	test   %eax,%eax
  80114c:	78 67                	js     8011b5 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  80114e:	83 c6 01             	add    $0x1,%esi
  801151:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801157:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  80115d:	0f 85 1a ff ff ff    	jne    80107d <fork+0x59>
  801163:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  801166:	83 ec 04             	sub    $0x4,%esp
  801169:	6a 07                	push   $0x7
  80116b:	68 00 f0 bf ee       	push   $0xeebff000
  801170:	57                   	push   %edi
  801171:	e8 83 fb ff ff       	call   800cf9 <sys_page_alloc>
	if (r < 0)
  801176:	83 c4 10             	add    $0x10,%esp
		return r;
  801179:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  80117b:	85 c0                	test   %eax,%eax
  80117d:	78 38                	js     8011b7 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80117f:	83 ec 08             	sub    $0x8,%esp
  801182:	68 66 23 80 00       	push   $0x802366
  801187:	57                   	push   %edi
  801188:	e8 b7 fc ff ff       	call   800e44 <sys_env_set_pgfault_upcall>
	if (r < 0)
  80118d:	83 c4 10             	add    $0x10,%esp
		return r;
  801190:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  801192:	85 c0                	test   %eax,%eax
  801194:	78 21                	js     8011b7 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801196:	83 ec 08             	sub    $0x8,%esp
  801199:	6a 02                	push   $0x2
  80119b:	57                   	push   %edi
  80119c:	e8 1f fc ff ff       	call   800dc0 <sys_env_set_status>
	if (r < 0)
  8011a1:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  8011a4:	85 c0                	test   %eax,%eax
  8011a6:	0f 48 f8             	cmovs  %eax,%edi
  8011a9:	89 fa                	mov    %edi,%edx
  8011ab:	eb 0a                	jmp    8011b7 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  8011ad:	89 c2                	mov    %eax,%edx
  8011af:	eb 06                	jmp    8011b7 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  8011b1:	89 c2                	mov    %eax,%edx
  8011b3:	eb 02                	jmp    8011b7 <fork+0x193>
  8011b5:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  8011b7:	89 d0                	mov    %edx,%eax
  8011b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bc:	5b                   	pop    %ebx
  8011bd:	5e                   	pop    %esi
  8011be:	5f                   	pop    %edi
  8011bf:	5d                   	pop    %ebp
  8011c0:	c3                   	ret    

008011c1 <sfork>:

// Challenge!
int
sfork(void)
{
  8011c1:	55                   	push   %ebp
  8011c2:	89 e5                	mov    %esp,%ebp
  8011c4:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011c7:	68 0b 2c 80 00       	push   $0x802c0b
  8011cc:	68 c9 00 00 00       	push   $0xc9
  8011d1:	68 00 2c 80 00       	push   $0x802c00
  8011d6:	e8 bd f0 ff ff       	call   800298 <_panic>

008011db <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011de:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e1:	05 00 00 00 30       	add    $0x30000000,%eax
  8011e6:	c1 e8 0c             	shr    $0xc,%eax
}
  8011e9:	5d                   	pop    %ebp
  8011ea:	c3                   	ret    

008011eb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f1:	05 00 00 00 30       	add    $0x30000000,%eax
  8011f6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011fb:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801200:	5d                   	pop    %ebp
  801201:	c3                   	ret    

00801202 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801202:	55                   	push   %ebp
  801203:	89 e5                	mov    %esp,%ebp
  801205:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801208:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80120d:	89 c2                	mov    %eax,%edx
  80120f:	c1 ea 16             	shr    $0x16,%edx
  801212:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801219:	f6 c2 01             	test   $0x1,%dl
  80121c:	74 11                	je     80122f <fd_alloc+0x2d>
  80121e:	89 c2                	mov    %eax,%edx
  801220:	c1 ea 0c             	shr    $0xc,%edx
  801223:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80122a:	f6 c2 01             	test   $0x1,%dl
  80122d:	75 09                	jne    801238 <fd_alloc+0x36>
			*fd_store = fd;
  80122f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801231:	b8 00 00 00 00       	mov    $0x0,%eax
  801236:	eb 17                	jmp    80124f <fd_alloc+0x4d>
  801238:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80123d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801242:	75 c9                	jne    80120d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801244:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80124a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80124f:	5d                   	pop    %ebp
  801250:	c3                   	ret    

00801251 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801251:	55                   	push   %ebp
  801252:	89 e5                	mov    %esp,%ebp
  801254:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801257:	83 f8 1f             	cmp    $0x1f,%eax
  80125a:	77 36                	ja     801292 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80125c:	c1 e0 0c             	shl    $0xc,%eax
  80125f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801264:	89 c2                	mov    %eax,%edx
  801266:	c1 ea 16             	shr    $0x16,%edx
  801269:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801270:	f6 c2 01             	test   $0x1,%dl
  801273:	74 24                	je     801299 <fd_lookup+0x48>
  801275:	89 c2                	mov    %eax,%edx
  801277:	c1 ea 0c             	shr    $0xc,%edx
  80127a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801281:	f6 c2 01             	test   $0x1,%dl
  801284:	74 1a                	je     8012a0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801286:	8b 55 0c             	mov    0xc(%ebp),%edx
  801289:	89 02                	mov    %eax,(%edx)
	return 0;
  80128b:	b8 00 00 00 00       	mov    $0x0,%eax
  801290:	eb 13                	jmp    8012a5 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801292:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801297:	eb 0c                	jmp    8012a5 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801299:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80129e:	eb 05                	jmp    8012a5 <fd_lookup+0x54>
  8012a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012a5:	5d                   	pop    %ebp
  8012a6:	c3                   	ret    

008012a7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012a7:	55                   	push   %ebp
  8012a8:	89 e5                	mov    %esp,%ebp
  8012aa:	83 ec 08             	sub    $0x8,%esp
  8012ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b0:	ba a4 2c 80 00       	mov    $0x802ca4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012b5:	eb 13                	jmp    8012ca <dev_lookup+0x23>
  8012b7:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012ba:	39 08                	cmp    %ecx,(%eax)
  8012bc:	75 0c                	jne    8012ca <dev_lookup+0x23>
			*dev = devtab[i];
  8012be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012c1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c8:	eb 2e                	jmp    8012f8 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012ca:	8b 02                	mov    (%edx),%eax
  8012cc:	85 c0                	test   %eax,%eax
  8012ce:	75 e7                	jne    8012b7 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012d0:	a1 08 40 80 00       	mov    0x804008,%eax
  8012d5:	8b 40 48             	mov    0x48(%eax),%eax
  8012d8:	83 ec 04             	sub    $0x4,%esp
  8012db:	51                   	push   %ecx
  8012dc:	50                   	push   %eax
  8012dd:	68 24 2c 80 00       	push   $0x802c24
  8012e2:	e8 8a f0 ff ff       	call   800371 <cprintf>
	*dev = 0;
  8012e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012f0:	83 c4 10             	add    $0x10,%esp
  8012f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012f8:	c9                   	leave  
  8012f9:	c3                   	ret    

008012fa <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012fa:	55                   	push   %ebp
  8012fb:	89 e5                	mov    %esp,%ebp
  8012fd:	56                   	push   %esi
  8012fe:	53                   	push   %ebx
  8012ff:	83 ec 10             	sub    $0x10,%esp
  801302:	8b 75 08             	mov    0x8(%ebp),%esi
  801305:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801308:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130b:	50                   	push   %eax
  80130c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801312:	c1 e8 0c             	shr    $0xc,%eax
  801315:	50                   	push   %eax
  801316:	e8 36 ff ff ff       	call   801251 <fd_lookup>
  80131b:	83 c4 08             	add    $0x8,%esp
  80131e:	85 c0                	test   %eax,%eax
  801320:	78 05                	js     801327 <fd_close+0x2d>
	    || fd != fd2)
  801322:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801325:	74 0c                	je     801333 <fd_close+0x39>
		return (must_exist ? r : 0);
  801327:	84 db                	test   %bl,%bl
  801329:	ba 00 00 00 00       	mov    $0x0,%edx
  80132e:	0f 44 c2             	cmove  %edx,%eax
  801331:	eb 41                	jmp    801374 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801333:	83 ec 08             	sub    $0x8,%esp
  801336:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801339:	50                   	push   %eax
  80133a:	ff 36                	pushl  (%esi)
  80133c:	e8 66 ff ff ff       	call   8012a7 <dev_lookup>
  801341:	89 c3                	mov    %eax,%ebx
  801343:	83 c4 10             	add    $0x10,%esp
  801346:	85 c0                	test   %eax,%eax
  801348:	78 1a                	js     801364 <fd_close+0x6a>
		if (dev->dev_close)
  80134a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801350:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801355:	85 c0                	test   %eax,%eax
  801357:	74 0b                	je     801364 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801359:	83 ec 0c             	sub    $0xc,%esp
  80135c:	56                   	push   %esi
  80135d:	ff d0                	call   *%eax
  80135f:	89 c3                	mov    %eax,%ebx
  801361:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801364:	83 ec 08             	sub    $0x8,%esp
  801367:	56                   	push   %esi
  801368:	6a 00                	push   $0x0
  80136a:	e8 0f fa ff ff       	call   800d7e <sys_page_unmap>
	return r;
  80136f:	83 c4 10             	add    $0x10,%esp
  801372:	89 d8                	mov    %ebx,%eax
}
  801374:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801377:	5b                   	pop    %ebx
  801378:	5e                   	pop    %esi
  801379:	5d                   	pop    %ebp
  80137a:	c3                   	ret    

0080137b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80137b:	55                   	push   %ebp
  80137c:	89 e5                	mov    %esp,%ebp
  80137e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801381:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801384:	50                   	push   %eax
  801385:	ff 75 08             	pushl  0x8(%ebp)
  801388:	e8 c4 fe ff ff       	call   801251 <fd_lookup>
  80138d:	83 c4 08             	add    $0x8,%esp
  801390:	85 c0                	test   %eax,%eax
  801392:	78 10                	js     8013a4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801394:	83 ec 08             	sub    $0x8,%esp
  801397:	6a 01                	push   $0x1
  801399:	ff 75 f4             	pushl  -0xc(%ebp)
  80139c:	e8 59 ff ff ff       	call   8012fa <fd_close>
  8013a1:	83 c4 10             	add    $0x10,%esp
}
  8013a4:	c9                   	leave  
  8013a5:	c3                   	ret    

008013a6 <close_all>:

void
close_all(void)
{
  8013a6:	55                   	push   %ebp
  8013a7:	89 e5                	mov    %esp,%ebp
  8013a9:	53                   	push   %ebx
  8013aa:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013ad:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013b2:	83 ec 0c             	sub    $0xc,%esp
  8013b5:	53                   	push   %ebx
  8013b6:	e8 c0 ff ff ff       	call   80137b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013bb:	83 c3 01             	add    $0x1,%ebx
  8013be:	83 c4 10             	add    $0x10,%esp
  8013c1:	83 fb 20             	cmp    $0x20,%ebx
  8013c4:	75 ec                	jne    8013b2 <close_all+0xc>
		close(i);
}
  8013c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c9:	c9                   	leave  
  8013ca:	c3                   	ret    

008013cb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	57                   	push   %edi
  8013cf:	56                   	push   %esi
  8013d0:	53                   	push   %ebx
  8013d1:	83 ec 2c             	sub    $0x2c,%esp
  8013d4:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013d7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013da:	50                   	push   %eax
  8013db:	ff 75 08             	pushl  0x8(%ebp)
  8013de:	e8 6e fe ff ff       	call   801251 <fd_lookup>
  8013e3:	83 c4 08             	add    $0x8,%esp
  8013e6:	85 c0                	test   %eax,%eax
  8013e8:	0f 88 c1 00 00 00    	js     8014af <dup+0xe4>
		return r;
	close(newfdnum);
  8013ee:	83 ec 0c             	sub    $0xc,%esp
  8013f1:	56                   	push   %esi
  8013f2:	e8 84 ff ff ff       	call   80137b <close>

	newfd = INDEX2FD(newfdnum);
  8013f7:	89 f3                	mov    %esi,%ebx
  8013f9:	c1 e3 0c             	shl    $0xc,%ebx
  8013fc:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801402:	83 c4 04             	add    $0x4,%esp
  801405:	ff 75 e4             	pushl  -0x1c(%ebp)
  801408:	e8 de fd ff ff       	call   8011eb <fd2data>
  80140d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80140f:	89 1c 24             	mov    %ebx,(%esp)
  801412:	e8 d4 fd ff ff       	call   8011eb <fd2data>
  801417:	83 c4 10             	add    $0x10,%esp
  80141a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80141d:	89 f8                	mov    %edi,%eax
  80141f:	c1 e8 16             	shr    $0x16,%eax
  801422:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801429:	a8 01                	test   $0x1,%al
  80142b:	74 37                	je     801464 <dup+0x99>
  80142d:	89 f8                	mov    %edi,%eax
  80142f:	c1 e8 0c             	shr    $0xc,%eax
  801432:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801439:	f6 c2 01             	test   $0x1,%dl
  80143c:	74 26                	je     801464 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80143e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801445:	83 ec 0c             	sub    $0xc,%esp
  801448:	25 07 0e 00 00       	and    $0xe07,%eax
  80144d:	50                   	push   %eax
  80144e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801451:	6a 00                	push   $0x0
  801453:	57                   	push   %edi
  801454:	6a 00                	push   $0x0
  801456:	e8 e1 f8 ff ff       	call   800d3c <sys_page_map>
  80145b:	89 c7                	mov    %eax,%edi
  80145d:	83 c4 20             	add    $0x20,%esp
  801460:	85 c0                	test   %eax,%eax
  801462:	78 2e                	js     801492 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801464:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801467:	89 d0                	mov    %edx,%eax
  801469:	c1 e8 0c             	shr    $0xc,%eax
  80146c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801473:	83 ec 0c             	sub    $0xc,%esp
  801476:	25 07 0e 00 00       	and    $0xe07,%eax
  80147b:	50                   	push   %eax
  80147c:	53                   	push   %ebx
  80147d:	6a 00                	push   $0x0
  80147f:	52                   	push   %edx
  801480:	6a 00                	push   $0x0
  801482:	e8 b5 f8 ff ff       	call   800d3c <sys_page_map>
  801487:	89 c7                	mov    %eax,%edi
  801489:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80148c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80148e:	85 ff                	test   %edi,%edi
  801490:	79 1d                	jns    8014af <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801492:	83 ec 08             	sub    $0x8,%esp
  801495:	53                   	push   %ebx
  801496:	6a 00                	push   $0x0
  801498:	e8 e1 f8 ff ff       	call   800d7e <sys_page_unmap>
	sys_page_unmap(0, nva);
  80149d:	83 c4 08             	add    $0x8,%esp
  8014a0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014a3:	6a 00                	push   $0x0
  8014a5:	e8 d4 f8 ff ff       	call   800d7e <sys_page_unmap>
	return r;
  8014aa:	83 c4 10             	add    $0x10,%esp
  8014ad:	89 f8                	mov    %edi,%eax
}
  8014af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b2:	5b                   	pop    %ebx
  8014b3:	5e                   	pop    %esi
  8014b4:	5f                   	pop    %edi
  8014b5:	5d                   	pop    %ebp
  8014b6:	c3                   	ret    

008014b7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014b7:	55                   	push   %ebp
  8014b8:	89 e5                	mov    %esp,%ebp
  8014ba:	53                   	push   %ebx
  8014bb:	83 ec 14             	sub    $0x14,%esp
  8014be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c4:	50                   	push   %eax
  8014c5:	53                   	push   %ebx
  8014c6:	e8 86 fd ff ff       	call   801251 <fd_lookup>
  8014cb:	83 c4 08             	add    $0x8,%esp
  8014ce:	89 c2                	mov    %eax,%edx
  8014d0:	85 c0                	test   %eax,%eax
  8014d2:	78 6d                	js     801541 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d4:	83 ec 08             	sub    $0x8,%esp
  8014d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014da:	50                   	push   %eax
  8014db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014de:	ff 30                	pushl  (%eax)
  8014e0:	e8 c2 fd ff ff       	call   8012a7 <dev_lookup>
  8014e5:	83 c4 10             	add    $0x10,%esp
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	78 4c                	js     801538 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014ef:	8b 42 08             	mov    0x8(%edx),%eax
  8014f2:	83 e0 03             	and    $0x3,%eax
  8014f5:	83 f8 01             	cmp    $0x1,%eax
  8014f8:	75 21                	jne    80151b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014fa:	a1 08 40 80 00       	mov    0x804008,%eax
  8014ff:	8b 40 48             	mov    0x48(%eax),%eax
  801502:	83 ec 04             	sub    $0x4,%esp
  801505:	53                   	push   %ebx
  801506:	50                   	push   %eax
  801507:	68 68 2c 80 00       	push   $0x802c68
  80150c:	e8 60 ee ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  801511:	83 c4 10             	add    $0x10,%esp
  801514:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801519:	eb 26                	jmp    801541 <read+0x8a>
	}
	if (!dev->dev_read)
  80151b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80151e:	8b 40 08             	mov    0x8(%eax),%eax
  801521:	85 c0                	test   %eax,%eax
  801523:	74 17                	je     80153c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801525:	83 ec 04             	sub    $0x4,%esp
  801528:	ff 75 10             	pushl  0x10(%ebp)
  80152b:	ff 75 0c             	pushl  0xc(%ebp)
  80152e:	52                   	push   %edx
  80152f:	ff d0                	call   *%eax
  801531:	89 c2                	mov    %eax,%edx
  801533:	83 c4 10             	add    $0x10,%esp
  801536:	eb 09                	jmp    801541 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801538:	89 c2                	mov    %eax,%edx
  80153a:	eb 05                	jmp    801541 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80153c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801541:	89 d0                	mov    %edx,%eax
  801543:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801546:	c9                   	leave  
  801547:	c3                   	ret    

00801548 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801548:	55                   	push   %ebp
  801549:	89 e5                	mov    %esp,%ebp
  80154b:	57                   	push   %edi
  80154c:	56                   	push   %esi
  80154d:	53                   	push   %ebx
  80154e:	83 ec 0c             	sub    $0xc,%esp
  801551:	8b 7d 08             	mov    0x8(%ebp),%edi
  801554:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801557:	bb 00 00 00 00       	mov    $0x0,%ebx
  80155c:	eb 21                	jmp    80157f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80155e:	83 ec 04             	sub    $0x4,%esp
  801561:	89 f0                	mov    %esi,%eax
  801563:	29 d8                	sub    %ebx,%eax
  801565:	50                   	push   %eax
  801566:	89 d8                	mov    %ebx,%eax
  801568:	03 45 0c             	add    0xc(%ebp),%eax
  80156b:	50                   	push   %eax
  80156c:	57                   	push   %edi
  80156d:	e8 45 ff ff ff       	call   8014b7 <read>
		if (m < 0)
  801572:	83 c4 10             	add    $0x10,%esp
  801575:	85 c0                	test   %eax,%eax
  801577:	78 10                	js     801589 <readn+0x41>
			return m;
		if (m == 0)
  801579:	85 c0                	test   %eax,%eax
  80157b:	74 0a                	je     801587 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80157d:	01 c3                	add    %eax,%ebx
  80157f:	39 f3                	cmp    %esi,%ebx
  801581:	72 db                	jb     80155e <readn+0x16>
  801583:	89 d8                	mov    %ebx,%eax
  801585:	eb 02                	jmp    801589 <readn+0x41>
  801587:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801589:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80158c:	5b                   	pop    %ebx
  80158d:	5e                   	pop    %esi
  80158e:	5f                   	pop    %edi
  80158f:	5d                   	pop    %ebp
  801590:	c3                   	ret    

00801591 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801591:	55                   	push   %ebp
  801592:	89 e5                	mov    %esp,%ebp
  801594:	53                   	push   %ebx
  801595:	83 ec 14             	sub    $0x14,%esp
  801598:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80159b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80159e:	50                   	push   %eax
  80159f:	53                   	push   %ebx
  8015a0:	e8 ac fc ff ff       	call   801251 <fd_lookup>
  8015a5:	83 c4 08             	add    $0x8,%esp
  8015a8:	89 c2                	mov    %eax,%edx
  8015aa:	85 c0                	test   %eax,%eax
  8015ac:	78 68                	js     801616 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ae:	83 ec 08             	sub    $0x8,%esp
  8015b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b4:	50                   	push   %eax
  8015b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b8:	ff 30                	pushl  (%eax)
  8015ba:	e8 e8 fc ff ff       	call   8012a7 <dev_lookup>
  8015bf:	83 c4 10             	add    $0x10,%esp
  8015c2:	85 c0                	test   %eax,%eax
  8015c4:	78 47                	js     80160d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015cd:	75 21                	jne    8015f0 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015cf:	a1 08 40 80 00       	mov    0x804008,%eax
  8015d4:	8b 40 48             	mov    0x48(%eax),%eax
  8015d7:	83 ec 04             	sub    $0x4,%esp
  8015da:	53                   	push   %ebx
  8015db:	50                   	push   %eax
  8015dc:	68 84 2c 80 00       	push   $0x802c84
  8015e1:	e8 8b ed ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  8015e6:	83 c4 10             	add    $0x10,%esp
  8015e9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015ee:	eb 26                	jmp    801616 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f3:	8b 52 0c             	mov    0xc(%edx),%edx
  8015f6:	85 d2                	test   %edx,%edx
  8015f8:	74 17                	je     801611 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015fa:	83 ec 04             	sub    $0x4,%esp
  8015fd:	ff 75 10             	pushl  0x10(%ebp)
  801600:	ff 75 0c             	pushl  0xc(%ebp)
  801603:	50                   	push   %eax
  801604:	ff d2                	call   *%edx
  801606:	89 c2                	mov    %eax,%edx
  801608:	83 c4 10             	add    $0x10,%esp
  80160b:	eb 09                	jmp    801616 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160d:	89 c2                	mov    %eax,%edx
  80160f:	eb 05                	jmp    801616 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801611:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801616:	89 d0                	mov    %edx,%eax
  801618:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161b:	c9                   	leave  
  80161c:	c3                   	ret    

0080161d <seek>:

int
seek(int fdnum, off_t offset)
{
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
  801620:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801623:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801626:	50                   	push   %eax
  801627:	ff 75 08             	pushl  0x8(%ebp)
  80162a:	e8 22 fc ff ff       	call   801251 <fd_lookup>
  80162f:	83 c4 08             	add    $0x8,%esp
  801632:	85 c0                	test   %eax,%eax
  801634:	78 0e                	js     801644 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801636:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801639:	8b 55 0c             	mov    0xc(%ebp),%edx
  80163c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80163f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801644:	c9                   	leave  
  801645:	c3                   	ret    

00801646 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	53                   	push   %ebx
  80164a:	83 ec 14             	sub    $0x14,%esp
  80164d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801650:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801653:	50                   	push   %eax
  801654:	53                   	push   %ebx
  801655:	e8 f7 fb ff ff       	call   801251 <fd_lookup>
  80165a:	83 c4 08             	add    $0x8,%esp
  80165d:	89 c2                	mov    %eax,%edx
  80165f:	85 c0                	test   %eax,%eax
  801661:	78 65                	js     8016c8 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801663:	83 ec 08             	sub    $0x8,%esp
  801666:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801669:	50                   	push   %eax
  80166a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166d:	ff 30                	pushl  (%eax)
  80166f:	e8 33 fc ff ff       	call   8012a7 <dev_lookup>
  801674:	83 c4 10             	add    $0x10,%esp
  801677:	85 c0                	test   %eax,%eax
  801679:	78 44                	js     8016bf <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80167b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801682:	75 21                	jne    8016a5 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801684:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801689:	8b 40 48             	mov    0x48(%eax),%eax
  80168c:	83 ec 04             	sub    $0x4,%esp
  80168f:	53                   	push   %ebx
  801690:	50                   	push   %eax
  801691:	68 44 2c 80 00       	push   $0x802c44
  801696:	e8 d6 ec ff ff       	call   800371 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80169b:	83 c4 10             	add    $0x10,%esp
  80169e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016a3:	eb 23                	jmp    8016c8 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a8:	8b 52 18             	mov    0x18(%edx),%edx
  8016ab:	85 d2                	test   %edx,%edx
  8016ad:	74 14                	je     8016c3 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016af:	83 ec 08             	sub    $0x8,%esp
  8016b2:	ff 75 0c             	pushl  0xc(%ebp)
  8016b5:	50                   	push   %eax
  8016b6:	ff d2                	call   *%edx
  8016b8:	89 c2                	mov    %eax,%edx
  8016ba:	83 c4 10             	add    $0x10,%esp
  8016bd:	eb 09                	jmp    8016c8 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016bf:	89 c2                	mov    %eax,%edx
  8016c1:	eb 05                	jmp    8016c8 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016c3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016c8:	89 d0                	mov    %edx,%eax
  8016ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cd:	c9                   	leave  
  8016ce:	c3                   	ret    

008016cf <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016cf:	55                   	push   %ebp
  8016d0:	89 e5                	mov    %esp,%ebp
  8016d2:	53                   	push   %ebx
  8016d3:	83 ec 14             	sub    $0x14,%esp
  8016d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016dc:	50                   	push   %eax
  8016dd:	ff 75 08             	pushl  0x8(%ebp)
  8016e0:	e8 6c fb ff ff       	call   801251 <fd_lookup>
  8016e5:	83 c4 08             	add    $0x8,%esp
  8016e8:	89 c2                	mov    %eax,%edx
  8016ea:	85 c0                	test   %eax,%eax
  8016ec:	78 58                	js     801746 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ee:	83 ec 08             	sub    $0x8,%esp
  8016f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f4:	50                   	push   %eax
  8016f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f8:	ff 30                	pushl  (%eax)
  8016fa:	e8 a8 fb ff ff       	call   8012a7 <dev_lookup>
  8016ff:	83 c4 10             	add    $0x10,%esp
  801702:	85 c0                	test   %eax,%eax
  801704:	78 37                	js     80173d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801706:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801709:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80170d:	74 32                	je     801741 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80170f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801712:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801719:	00 00 00 
	stat->st_isdir = 0;
  80171c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801723:	00 00 00 
	stat->st_dev = dev;
  801726:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80172c:	83 ec 08             	sub    $0x8,%esp
  80172f:	53                   	push   %ebx
  801730:	ff 75 f0             	pushl  -0x10(%ebp)
  801733:	ff 50 14             	call   *0x14(%eax)
  801736:	89 c2                	mov    %eax,%edx
  801738:	83 c4 10             	add    $0x10,%esp
  80173b:	eb 09                	jmp    801746 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173d:	89 c2                	mov    %eax,%edx
  80173f:	eb 05                	jmp    801746 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801741:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801746:	89 d0                	mov    %edx,%eax
  801748:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174b:	c9                   	leave  
  80174c:	c3                   	ret    

0080174d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80174d:	55                   	push   %ebp
  80174e:	89 e5                	mov    %esp,%ebp
  801750:	56                   	push   %esi
  801751:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801752:	83 ec 08             	sub    $0x8,%esp
  801755:	6a 00                	push   $0x0
  801757:	ff 75 08             	pushl  0x8(%ebp)
  80175a:	e8 d6 01 00 00       	call   801935 <open>
  80175f:	89 c3                	mov    %eax,%ebx
  801761:	83 c4 10             	add    $0x10,%esp
  801764:	85 c0                	test   %eax,%eax
  801766:	78 1b                	js     801783 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801768:	83 ec 08             	sub    $0x8,%esp
  80176b:	ff 75 0c             	pushl  0xc(%ebp)
  80176e:	50                   	push   %eax
  80176f:	e8 5b ff ff ff       	call   8016cf <fstat>
  801774:	89 c6                	mov    %eax,%esi
	close(fd);
  801776:	89 1c 24             	mov    %ebx,(%esp)
  801779:	e8 fd fb ff ff       	call   80137b <close>
	return r;
  80177e:	83 c4 10             	add    $0x10,%esp
  801781:	89 f0                	mov    %esi,%eax
}
  801783:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801786:	5b                   	pop    %ebx
  801787:	5e                   	pop    %esi
  801788:	5d                   	pop    %ebp
  801789:	c3                   	ret    

0080178a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	56                   	push   %esi
  80178e:	53                   	push   %ebx
  80178f:	89 c6                	mov    %eax,%esi
  801791:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801793:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80179a:	75 12                	jne    8017ae <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80179c:	83 ec 0c             	sub    $0xc,%esp
  80179f:	6a 01                	push   $0x1
  8017a1:	e8 9f 0c 00 00       	call   802445 <ipc_find_env>
  8017a6:	a3 00 40 80 00       	mov    %eax,0x804000
  8017ab:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017ae:	6a 07                	push   $0x7
  8017b0:	68 00 50 80 00       	push   $0x805000
  8017b5:	56                   	push   %esi
  8017b6:	ff 35 00 40 80 00    	pushl  0x804000
  8017bc:	e8 30 0c 00 00       	call   8023f1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017c1:	83 c4 0c             	add    $0xc,%esp
  8017c4:	6a 00                	push   $0x0
  8017c6:	53                   	push   %ebx
  8017c7:	6a 00                	push   $0x0
  8017c9:	e8 bc 0b 00 00       	call   80238a <ipc_recv>
}
  8017ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d1:	5b                   	pop    %ebx
  8017d2:	5e                   	pop    %esi
  8017d3:	5d                   	pop    %ebp
  8017d4:	c3                   	ret    

008017d5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017db:	8b 45 08             	mov    0x8(%ebp),%eax
  8017de:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f3:	b8 02 00 00 00       	mov    $0x2,%eax
  8017f8:	e8 8d ff ff ff       	call   80178a <fsipc>
}
  8017fd:	c9                   	leave  
  8017fe:	c3                   	ret    

008017ff <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801805:	8b 45 08             	mov    0x8(%ebp),%eax
  801808:	8b 40 0c             	mov    0xc(%eax),%eax
  80180b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801810:	ba 00 00 00 00       	mov    $0x0,%edx
  801815:	b8 06 00 00 00       	mov    $0x6,%eax
  80181a:	e8 6b ff ff ff       	call   80178a <fsipc>
}
  80181f:	c9                   	leave  
  801820:	c3                   	ret    

00801821 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801821:	55                   	push   %ebp
  801822:	89 e5                	mov    %esp,%ebp
  801824:	53                   	push   %ebx
  801825:	83 ec 04             	sub    $0x4,%esp
  801828:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80182b:	8b 45 08             	mov    0x8(%ebp),%eax
  80182e:	8b 40 0c             	mov    0xc(%eax),%eax
  801831:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801836:	ba 00 00 00 00       	mov    $0x0,%edx
  80183b:	b8 05 00 00 00       	mov    $0x5,%eax
  801840:	e8 45 ff ff ff       	call   80178a <fsipc>
  801845:	85 c0                	test   %eax,%eax
  801847:	78 2c                	js     801875 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801849:	83 ec 08             	sub    $0x8,%esp
  80184c:	68 00 50 80 00       	push   $0x805000
  801851:	53                   	push   %ebx
  801852:	e8 9f f0 ff ff       	call   8008f6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801857:	a1 80 50 80 00       	mov    0x805080,%eax
  80185c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801862:	a1 84 50 80 00       	mov    0x805084,%eax
  801867:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80186d:	83 c4 10             	add    $0x10,%esp
  801870:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801875:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801878:	c9                   	leave  
  801879:	c3                   	ret    

0080187a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80187a:	55                   	push   %ebp
  80187b:	89 e5                	mov    %esp,%ebp
  80187d:	83 ec 0c             	sub    $0xc,%esp
  801880:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801883:	8b 55 08             	mov    0x8(%ebp),%edx
  801886:	8b 52 0c             	mov    0xc(%edx),%edx
  801889:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80188f:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801894:	50                   	push   %eax
  801895:	ff 75 0c             	pushl  0xc(%ebp)
  801898:	68 08 50 80 00       	push   $0x805008
  80189d:	e8 e6 f1 ff ff       	call   800a88 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8018a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a7:	b8 04 00 00 00       	mov    $0x4,%eax
  8018ac:	e8 d9 fe ff ff       	call   80178a <fsipc>

}
  8018b1:	c9                   	leave  
  8018b2:	c3                   	ret    

008018b3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	56                   	push   %esi
  8018b7:	53                   	push   %ebx
  8018b8:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018be:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018c6:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d1:	b8 03 00 00 00       	mov    $0x3,%eax
  8018d6:	e8 af fe ff ff       	call   80178a <fsipc>
  8018db:	89 c3                	mov    %eax,%ebx
  8018dd:	85 c0                	test   %eax,%eax
  8018df:	78 4b                	js     80192c <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018e1:	39 c6                	cmp    %eax,%esi
  8018e3:	73 16                	jae    8018fb <devfile_read+0x48>
  8018e5:	68 b8 2c 80 00       	push   $0x802cb8
  8018ea:	68 bf 2c 80 00       	push   $0x802cbf
  8018ef:	6a 7c                	push   $0x7c
  8018f1:	68 d4 2c 80 00       	push   $0x802cd4
  8018f6:	e8 9d e9 ff ff       	call   800298 <_panic>
	assert(r <= PGSIZE);
  8018fb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801900:	7e 16                	jle    801918 <devfile_read+0x65>
  801902:	68 df 2c 80 00       	push   $0x802cdf
  801907:	68 bf 2c 80 00       	push   $0x802cbf
  80190c:	6a 7d                	push   $0x7d
  80190e:	68 d4 2c 80 00       	push   $0x802cd4
  801913:	e8 80 e9 ff ff       	call   800298 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801918:	83 ec 04             	sub    $0x4,%esp
  80191b:	50                   	push   %eax
  80191c:	68 00 50 80 00       	push   $0x805000
  801921:	ff 75 0c             	pushl  0xc(%ebp)
  801924:	e8 5f f1 ff ff       	call   800a88 <memmove>
	return r;
  801929:	83 c4 10             	add    $0x10,%esp
}
  80192c:	89 d8                	mov    %ebx,%eax
  80192e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801931:	5b                   	pop    %ebx
  801932:	5e                   	pop    %esi
  801933:	5d                   	pop    %ebp
  801934:	c3                   	ret    

00801935 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801935:	55                   	push   %ebp
  801936:	89 e5                	mov    %esp,%ebp
  801938:	53                   	push   %ebx
  801939:	83 ec 20             	sub    $0x20,%esp
  80193c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80193f:	53                   	push   %ebx
  801940:	e8 78 ef ff ff       	call   8008bd <strlen>
  801945:	83 c4 10             	add    $0x10,%esp
  801948:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80194d:	7f 67                	jg     8019b6 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80194f:	83 ec 0c             	sub    $0xc,%esp
  801952:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801955:	50                   	push   %eax
  801956:	e8 a7 f8 ff ff       	call   801202 <fd_alloc>
  80195b:	83 c4 10             	add    $0x10,%esp
		return r;
  80195e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801960:	85 c0                	test   %eax,%eax
  801962:	78 57                	js     8019bb <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801964:	83 ec 08             	sub    $0x8,%esp
  801967:	53                   	push   %ebx
  801968:	68 00 50 80 00       	push   $0x805000
  80196d:	e8 84 ef ff ff       	call   8008f6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801972:	8b 45 0c             	mov    0xc(%ebp),%eax
  801975:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80197a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80197d:	b8 01 00 00 00       	mov    $0x1,%eax
  801982:	e8 03 fe ff ff       	call   80178a <fsipc>
  801987:	89 c3                	mov    %eax,%ebx
  801989:	83 c4 10             	add    $0x10,%esp
  80198c:	85 c0                	test   %eax,%eax
  80198e:	79 14                	jns    8019a4 <open+0x6f>
		fd_close(fd, 0);
  801990:	83 ec 08             	sub    $0x8,%esp
  801993:	6a 00                	push   $0x0
  801995:	ff 75 f4             	pushl  -0xc(%ebp)
  801998:	e8 5d f9 ff ff       	call   8012fa <fd_close>
		return r;
  80199d:	83 c4 10             	add    $0x10,%esp
  8019a0:	89 da                	mov    %ebx,%edx
  8019a2:	eb 17                	jmp    8019bb <open+0x86>
	}

	return fd2num(fd);
  8019a4:	83 ec 0c             	sub    $0xc,%esp
  8019a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8019aa:	e8 2c f8 ff ff       	call   8011db <fd2num>
  8019af:	89 c2                	mov    %eax,%edx
  8019b1:	83 c4 10             	add    $0x10,%esp
  8019b4:	eb 05                	jmp    8019bb <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019b6:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019bb:	89 d0                	mov    %edx,%eax
  8019bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c0:	c9                   	leave  
  8019c1:	c3                   	ret    

008019c2 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019c2:	55                   	push   %ebp
  8019c3:	89 e5                	mov    %esp,%ebp
  8019c5:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8019cd:	b8 08 00 00 00       	mov    $0x8,%eax
  8019d2:	e8 b3 fd ff ff       	call   80178a <fsipc>
}
  8019d7:	c9                   	leave  
  8019d8:	c3                   	ret    

008019d9 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019d9:	55                   	push   %ebp
  8019da:	89 e5                	mov    %esp,%ebp
  8019dc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019df:	68 eb 2c 80 00       	push   $0x802ceb
  8019e4:	ff 75 0c             	pushl  0xc(%ebp)
  8019e7:	e8 0a ef ff ff       	call   8008f6 <strcpy>
	return 0;
}
  8019ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f1:	c9                   	leave  
  8019f2:	c3                   	ret    

008019f3 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8019f3:	55                   	push   %ebp
  8019f4:	89 e5                	mov    %esp,%ebp
  8019f6:	53                   	push   %ebx
  8019f7:	83 ec 10             	sub    $0x10,%esp
  8019fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019fd:	53                   	push   %ebx
  8019fe:	e8 7b 0a 00 00       	call   80247e <pageref>
  801a03:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a06:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a0b:	83 f8 01             	cmp    $0x1,%eax
  801a0e:	75 10                	jne    801a20 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a10:	83 ec 0c             	sub    $0xc,%esp
  801a13:	ff 73 0c             	pushl  0xc(%ebx)
  801a16:	e8 c0 02 00 00       	call   801cdb <nsipc_close>
  801a1b:	89 c2                	mov    %eax,%edx
  801a1d:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a20:	89 d0                	mov    %edx,%eax
  801a22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a25:	c9                   	leave  
  801a26:	c3                   	ret    

00801a27 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a27:	55                   	push   %ebp
  801a28:	89 e5                	mov    %esp,%ebp
  801a2a:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a2d:	6a 00                	push   $0x0
  801a2f:	ff 75 10             	pushl  0x10(%ebp)
  801a32:	ff 75 0c             	pushl  0xc(%ebp)
  801a35:	8b 45 08             	mov    0x8(%ebp),%eax
  801a38:	ff 70 0c             	pushl  0xc(%eax)
  801a3b:	e8 78 03 00 00       	call   801db8 <nsipc_send>
}
  801a40:	c9                   	leave  
  801a41:	c3                   	ret    

00801a42 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a42:	55                   	push   %ebp
  801a43:	89 e5                	mov    %esp,%ebp
  801a45:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a48:	6a 00                	push   $0x0
  801a4a:	ff 75 10             	pushl  0x10(%ebp)
  801a4d:	ff 75 0c             	pushl  0xc(%ebp)
  801a50:	8b 45 08             	mov    0x8(%ebp),%eax
  801a53:	ff 70 0c             	pushl  0xc(%eax)
  801a56:	e8 f1 02 00 00       	call   801d4c <nsipc_recv>
}
  801a5b:	c9                   	leave  
  801a5c:	c3                   	ret    

00801a5d <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a5d:	55                   	push   %ebp
  801a5e:	89 e5                	mov    %esp,%ebp
  801a60:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a63:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a66:	52                   	push   %edx
  801a67:	50                   	push   %eax
  801a68:	e8 e4 f7 ff ff       	call   801251 <fd_lookup>
  801a6d:	83 c4 10             	add    $0x10,%esp
  801a70:	85 c0                	test   %eax,%eax
  801a72:	78 17                	js     801a8b <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a77:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a7d:	39 08                	cmp    %ecx,(%eax)
  801a7f:	75 05                	jne    801a86 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a81:	8b 40 0c             	mov    0xc(%eax),%eax
  801a84:	eb 05                	jmp    801a8b <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a86:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a8b:	c9                   	leave  
  801a8c:	c3                   	ret    

00801a8d <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a8d:	55                   	push   %ebp
  801a8e:	89 e5                	mov    %esp,%ebp
  801a90:	56                   	push   %esi
  801a91:	53                   	push   %ebx
  801a92:	83 ec 1c             	sub    $0x1c,%esp
  801a95:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a9a:	50                   	push   %eax
  801a9b:	e8 62 f7 ff ff       	call   801202 <fd_alloc>
  801aa0:	89 c3                	mov    %eax,%ebx
  801aa2:	83 c4 10             	add    $0x10,%esp
  801aa5:	85 c0                	test   %eax,%eax
  801aa7:	78 1b                	js     801ac4 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801aa9:	83 ec 04             	sub    $0x4,%esp
  801aac:	68 07 04 00 00       	push   $0x407
  801ab1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab4:	6a 00                	push   $0x0
  801ab6:	e8 3e f2 ff ff       	call   800cf9 <sys_page_alloc>
  801abb:	89 c3                	mov    %eax,%ebx
  801abd:	83 c4 10             	add    $0x10,%esp
  801ac0:	85 c0                	test   %eax,%eax
  801ac2:	79 10                	jns    801ad4 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801ac4:	83 ec 0c             	sub    $0xc,%esp
  801ac7:	56                   	push   %esi
  801ac8:	e8 0e 02 00 00       	call   801cdb <nsipc_close>
		return r;
  801acd:	83 c4 10             	add    $0x10,%esp
  801ad0:	89 d8                	mov    %ebx,%eax
  801ad2:	eb 24                	jmp    801af8 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801ad4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801add:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ae9:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801aec:	83 ec 0c             	sub    $0xc,%esp
  801aef:	50                   	push   %eax
  801af0:	e8 e6 f6 ff ff       	call   8011db <fd2num>
  801af5:	83 c4 10             	add    $0x10,%esp
}
  801af8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801afb:	5b                   	pop    %ebx
  801afc:	5e                   	pop    %esi
  801afd:	5d                   	pop    %ebp
  801afe:	c3                   	ret    

00801aff <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b05:	8b 45 08             	mov    0x8(%ebp),%eax
  801b08:	e8 50 ff ff ff       	call   801a5d <fd2sockid>
		return r;
  801b0d:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b0f:	85 c0                	test   %eax,%eax
  801b11:	78 1f                	js     801b32 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b13:	83 ec 04             	sub    $0x4,%esp
  801b16:	ff 75 10             	pushl  0x10(%ebp)
  801b19:	ff 75 0c             	pushl  0xc(%ebp)
  801b1c:	50                   	push   %eax
  801b1d:	e8 12 01 00 00       	call   801c34 <nsipc_accept>
  801b22:	83 c4 10             	add    $0x10,%esp
		return r;
  801b25:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b27:	85 c0                	test   %eax,%eax
  801b29:	78 07                	js     801b32 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b2b:	e8 5d ff ff ff       	call   801a8d <alloc_sockfd>
  801b30:	89 c1                	mov    %eax,%ecx
}
  801b32:	89 c8                	mov    %ecx,%eax
  801b34:	c9                   	leave  
  801b35:	c3                   	ret    

00801b36 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b36:	55                   	push   %ebp
  801b37:	89 e5                	mov    %esp,%ebp
  801b39:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3f:	e8 19 ff ff ff       	call   801a5d <fd2sockid>
  801b44:	85 c0                	test   %eax,%eax
  801b46:	78 12                	js     801b5a <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801b48:	83 ec 04             	sub    $0x4,%esp
  801b4b:	ff 75 10             	pushl  0x10(%ebp)
  801b4e:	ff 75 0c             	pushl  0xc(%ebp)
  801b51:	50                   	push   %eax
  801b52:	e8 2d 01 00 00       	call   801c84 <nsipc_bind>
  801b57:	83 c4 10             	add    $0x10,%esp
}
  801b5a:	c9                   	leave  
  801b5b:	c3                   	ret    

00801b5c <shutdown>:

int
shutdown(int s, int how)
{
  801b5c:	55                   	push   %ebp
  801b5d:	89 e5                	mov    %esp,%ebp
  801b5f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b62:	8b 45 08             	mov    0x8(%ebp),%eax
  801b65:	e8 f3 fe ff ff       	call   801a5d <fd2sockid>
  801b6a:	85 c0                	test   %eax,%eax
  801b6c:	78 0f                	js     801b7d <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b6e:	83 ec 08             	sub    $0x8,%esp
  801b71:	ff 75 0c             	pushl  0xc(%ebp)
  801b74:	50                   	push   %eax
  801b75:	e8 3f 01 00 00       	call   801cb9 <nsipc_shutdown>
  801b7a:	83 c4 10             	add    $0x10,%esp
}
  801b7d:	c9                   	leave  
  801b7e:	c3                   	ret    

00801b7f <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b7f:	55                   	push   %ebp
  801b80:	89 e5                	mov    %esp,%ebp
  801b82:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b85:	8b 45 08             	mov    0x8(%ebp),%eax
  801b88:	e8 d0 fe ff ff       	call   801a5d <fd2sockid>
  801b8d:	85 c0                	test   %eax,%eax
  801b8f:	78 12                	js     801ba3 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b91:	83 ec 04             	sub    $0x4,%esp
  801b94:	ff 75 10             	pushl  0x10(%ebp)
  801b97:	ff 75 0c             	pushl  0xc(%ebp)
  801b9a:	50                   	push   %eax
  801b9b:	e8 55 01 00 00       	call   801cf5 <nsipc_connect>
  801ba0:	83 c4 10             	add    $0x10,%esp
}
  801ba3:	c9                   	leave  
  801ba4:	c3                   	ret    

00801ba5 <listen>:

int
listen(int s, int backlog)
{
  801ba5:	55                   	push   %ebp
  801ba6:	89 e5                	mov    %esp,%ebp
  801ba8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bab:	8b 45 08             	mov    0x8(%ebp),%eax
  801bae:	e8 aa fe ff ff       	call   801a5d <fd2sockid>
  801bb3:	85 c0                	test   %eax,%eax
  801bb5:	78 0f                	js     801bc6 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801bb7:	83 ec 08             	sub    $0x8,%esp
  801bba:	ff 75 0c             	pushl  0xc(%ebp)
  801bbd:	50                   	push   %eax
  801bbe:	e8 67 01 00 00       	call   801d2a <nsipc_listen>
  801bc3:	83 c4 10             	add    $0x10,%esp
}
  801bc6:	c9                   	leave  
  801bc7:	c3                   	ret    

00801bc8 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801bc8:	55                   	push   %ebp
  801bc9:	89 e5                	mov    %esp,%ebp
  801bcb:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bce:	ff 75 10             	pushl  0x10(%ebp)
  801bd1:	ff 75 0c             	pushl  0xc(%ebp)
  801bd4:	ff 75 08             	pushl  0x8(%ebp)
  801bd7:	e8 3a 02 00 00       	call   801e16 <nsipc_socket>
  801bdc:	83 c4 10             	add    $0x10,%esp
  801bdf:	85 c0                	test   %eax,%eax
  801be1:	78 05                	js     801be8 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801be3:	e8 a5 fe ff ff       	call   801a8d <alloc_sockfd>
}
  801be8:	c9                   	leave  
  801be9:	c3                   	ret    

00801bea <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801bea:	55                   	push   %ebp
  801beb:	89 e5                	mov    %esp,%ebp
  801bed:	53                   	push   %ebx
  801bee:	83 ec 04             	sub    $0x4,%esp
  801bf1:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801bf3:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801bfa:	75 12                	jne    801c0e <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801bfc:	83 ec 0c             	sub    $0xc,%esp
  801bff:	6a 02                	push   $0x2
  801c01:	e8 3f 08 00 00       	call   802445 <ipc_find_env>
  801c06:	a3 04 40 80 00       	mov    %eax,0x804004
  801c0b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c0e:	6a 07                	push   $0x7
  801c10:	68 00 60 80 00       	push   $0x806000
  801c15:	53                   	push   %ebx
  801c16:	ff 35 04 40 80 00    	pushl  0x804004
  801c1c:	e8 d0 07 00 00       	call   8023f1 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c21:	83 c4 0c             	add    $0xc,%esp
  801c24:	6a 00                	push   $0x0
  801c26:	6a 00                	push   $0x0
  801c28:	6a 00                	push   $0x0
  801c2a:	e8 5b 07 00 00       	call   80238a <ipc_recv>
}
  801c2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c32:	c9                   	leave  
  801c33:	c3                   	ret    

00801c34 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
  801c37:	56                   	push   %esi
  801c38:	53                   	push   %ebx
  801c39:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c44:	8b 06                	mov    (%esi),%eax
  801c46:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c4b:	b8 01 00 00 00       	mov    $0x1,%eax
  801c50:	e8 95 ff ff ff       	call   801bea <nsipc>
  801c55:	89 c3                	mov    %eax,%ebx
  801c57:	85 c0                	test   %eax,%eax
  801c59:	78 20                	js     801c7b <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c5b:	83 ec 04             	sub    $0x4,%esp
  801c5e:	ff 35 10 60 80 00    	pushl  0x806010
  801c64:	68 00 60 80 00       	push   $0x806000
  801c69:	ff 75 0c             	pushl  0xc(%ebp)
  801c6c:	e8 17 ee ff ff       	call   800a88 <memmove>
		*addrlen = ret->ret_addrlen;
  801c71:	a1 10 60 80 00       	mov    0x806010,%eax
  801c76:	89 06                	mov    %eax,(%esi)
  801c78:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c7b:	89 d8                	mov    %ebx,%eax
  801c7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c80:	5b                   	pop    %ebx
  801c81:	5e                   	pop    %esi
  801c82:	5d                   	pop    %ebp
  801c83:	c3                   	ret    

00801c84 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c84:	55                   	push   %ebp
  801c85:	89 e5                	mov    %esp,%ebp
  801c87:	53                   	push   %ebx
  801c88:	83 ec 08             	sub    $0x8,%esp
  801c8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c91:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c96:	53                   	push   %ebx
  801c97:	ff 75 0c             	pushl  0xc(%ebp)
  801c9a:	68 04 60 80 00       	push   $0x806004
  801c9f:	e8 e4 ed ff ff       	call   800a88 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801ca4:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801caa:	b8 02 00 00 00       	mov    $0x2,%eax
  801caf:	e8 36 ff ff ff       	call   801bea <nsipc>
}
  801cb4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cb7:	c9                   	leave  
  801cb8:	c3                   	ret    

00801cb9 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801cb9:	55                   	push   %ebp
  801cba:	89 e5                	mov    %esp,%ebp
  801cbc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801cbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801cc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cca:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801ccf:	b8 03 00 00 00       	mov    $0x3,%eax
  801cd4:	e8 11 ff ff ff       	call   801bea <nsipc>
}
  801cd9:	c9                   	leave  
  801cda:	c3                   	ret    

00801cdb <nsipc_close>:

int
nsipc_close(int s)
{
  801cdb:	55                   	push   %ebp
  801cdc:	89 e5                	mov    %esp,%ebp
  801cde:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ce1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce4:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801ce9:	b8 04 00 00 00       	mov    $0x4,%eax
  801cee:	e8 f7 fe ff ff       	call   801bea <nsipc>
}
  801cf3:	c9                   	leave  
  801cf4:	c3                   	ret    

00801cf5 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cf5:	55                   	push   %ebp
  801cf6:	89 e5                	mov    %esp,%ebp
  801cf8:	53                   	push   %ebx
  801cf9:	83 ec 08             	sub    $0x8,%esp
  801cfc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cff:	8b 45 08             	mov    0x8(%ebp),%eax
  801d02:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d07:	53                   	push   %ebx
  801d08:	ff 75 0c             	pushl  0xc(%ebp)
  801d0b:	68 04 60 80 00       	push   $0x806004
  801d10:	e8 73 ed ff ff       	call   800a88 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d15:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d1b:	b8 05 00 00 00       	mov    $0x5,%eax
  801d20:	e8 c5 fe ff ff       	call   801bea <nsipc>
}
  801d25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d28:	c9                   	leave  
  801d29:	c3                   	ret    

00801d2a <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d2a:	55                   	push   %ebp
  801d2b:	89 e5                	mov    %esp,%ebp
  801d2d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d30:	8b 45 08             	mov    0x8(%ebp),%eax
  801d33:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d38:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d3b:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d40:	b8 06 00 00 00       	mov    $0x6,%eax
  801d45:	e8 a0 fe ff ff       	call   801bea <nsipc>
}
  801d4a:	c9                   	leave  
  801d4b:	c3                   	ret    

00801d4c <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
  801d4f:	56                   	push   %esi
  801d50:	53                   	push   %ebx
  801d51:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d54:	8b 45 08             	mov    0x8(%ebp),%eax
  801d57:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d5c:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d62:	8b 45 14             	mov    0x14(%ebp),%eax
  801d65:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d6a:	b8 07 00 00 00       	mov    $0x7,%eax
  801d6f:	e8 76 fe ff ff       	call   801bea <nsipc>
  801d74:	89 c3                	mov    %eax,%ebx
  801d76:	85 c0                	test   %eax,%eax
  801d78:	78 35                	js     801daf <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d7a:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d7f:	7f 04                	jg     801d85 <nsipc_recv+0x39>
  801d81:	39 c6                	cmp    %eax,%esi
  801d83:	7d 16                	jge    801d9b <nsipc_recv+0x4f>
  801d85:	68 f7 2c 80 00       	push   $0x802cf7
  801d8a:	68 bf 2c 80 00       	push   $0x802cbf
  801d8f:	6a 62                	push   $0x62
  801d91:	68 0c 2d 80 00       	push   $0x802d0c
  801d96:	e8 fd e4 ff ff       	call   800298 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d9b:	83 ec 04             	sub    $0x4,%esp
  801d9e:	50                   	push   %eax
  801d9f:	68 00 60 80 00       	push   $0x806000
  801da4:	ff 75 0c             	pushl  0xc(%ebp)
  801da7:	e8 dc ec ff ff       	call   800a88 <memmove>
  801dac:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801daf:	89 d8                	mov    %ebx,%eax
  801db1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801db4:	5b                   	pop    %ebx
  801db5:	5e                   	pop    %esi
  801db6:	5d                   	pop    %ebp
  801db7:	c3                   	ret    

00801db8 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801db8:	55                   	push   %ebp
  801db9:	89 e5                	mov    %esp,%ebp
  801dbb:	53                   	push   %ebx
  801dbc:	83 ec 04             	sub    $0x4,%esp
  801dbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801dc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc5:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801dca:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801dd0:	7e 16                	jle    801de8 <nsipc_send+0x30>
  801dd2:	68 18 2d 80 00       	push   $0x802d18
  801dd7:	68 bf 2c 80 00       	push   $0x802cbf
  801ddc:	6a 6d                	push   $0x6d
  801dde:	68 0c 2d 80 00       	push   $0x802d0c
  801de3:	e8 b0 e4 ff ff       	call   800298 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801de8:	83 ec 04             	sub    $0x4,%esp
  801deb:	53                   	push   %ebx
  801dec:	ff 75 0c             	pushl  0xc(%ebp)
  801def:	68 0c 60 80 00       	push   $0x80600c
  801df4:	e8 8f ec ff ff       	call   800a88 <memmove>
	nsipcbuf.send.req_size = size;
  801df9:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801dff:	8b 45 14             	mov    0x14(%ebp),%eax
  801e02:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e07:	b8 08 00 00 00       	mov    $0x8,%eax
  801e0c:	e8 d9 fd ff ff       	call   801bea <nsipc>
}
  801e11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e14:	c9                   	leave  
  801e15:	c3                   	ret    

00801e16 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e16:	55                   	push   %ebp
  801e17:	89 e5                	mov    %esp,%ebp
  801e19:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e24:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e27:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e2c:	8b 45 10             	mov    0x10(%ebp),%eax
  801e2f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e34:	b8 09 00 00 00       	mov    $0x9,%eax
  801e39:	e8 ac fd ff ff       	call   801bea <nsipc>
}
  801e3e:	c9                   	leave  
  801e3f:	c3                   	ret    

00801e40 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e40:	55                   	push   %ebp
  801e41:	89 e5                	mov    %esp,%ebp
  801e43:	56                   	push   %esi
  801e44:	53                   	push   %ebx
  801e45:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e48:	83 ec 0c             	sub    $0xc,%esp
  801e4b:	ff 75 08             	pushl  0x8(%ebp)
  801e4e:	e8 98 f3 ff ff       	call   8011eb <fd2data>
  801e53:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e55:	83 c4 08             	add    $0x8,%esp
  801e58:	68 24 2d 80 00       	push   $0x802d24
  801e5d:	53                   	push   %ebx
  801e5e:	e8 93 ea ff ff       	call   8008f6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e63:	8b 46 04             	mov    0x4(%esi),%eax
  801e66:	2b 06                	sub    (%esi),%eax
  801e68:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e6e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e75:	00 00 00 
	stat->st_dev = &devpipe;
  801e78:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e7f:	30 80 00 
	return 0;
}
  801e82:	b8 00 00 00 00       	mov    $0x0,%eax
  801e87:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e8a:	5b                   	pop    %ebx
  801e8b:	5e                   	pop    %esi
  801e8c:	5d                   	pop    %ebp
  801e8d:	c3                   	ret    

00801e8e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e8e:	55                   	push   %ebp
  801e8f:	89 e5                	mov    %esp,%ebp
  801e91:	53                   	push   %ebx
  801e92:	83 ec 0c             	sub    $0xc,%esp
  801e95:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e98:	53                   	push   %ebx
  801e99:	6a 00                	push   $0x0
  801e9b:	e8 de ee ff ff       	call   800d7e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ea0:	89 1c 24             	mov    %ebx,(%esp)
  801ea3:	e8 43 f3 ff ff       	call   8011eb <fd2data>
  801ea8:	83 c4 08             	add    $0x8,%esp
  801eab:	50                   	push   %eax
  801eac:	6a 00                	push   $0x0
  801eae:	e8 cb ee ff ff       	call   800d7e <sys_page_unmap>
}
  801eb3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eb6:	c9                   	leave  
  801eb7:	c3                   	ret    

00801eb8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801eb8:	55                   	push   %ebp
  801eb9:	89 e5                	mov    %esp,%ebp
  801ebb:	57                   	push   %edi
  801ebc:	56                   	push   %esi
  801ebd:	53                   	push   %ebx
  801ebe:	83 ec 1c             	sub    $0x1c,%esp
  801ec1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ec4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ec6:	a1 08 40 80 00       	mov    0x804008,%eax
  801ecb:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ece:	83 ec 0c             	sub    $0xc,%esp
  801ed1:	ff 75 e0             	pushl  -0x20(%ebp)
  801ed4:	e8 a5 05 00 00       	call   80247e <pageref>
  801ed9:	89 c3                	mov    %eax,%ebx
  801edb:	89 3c 24             	mov    %edi,(%esp)
  801ede:	e8 9b 05 00 00       	call   80247e <pageref>
  801ee3:	83 c4 10             	add    $0x10,%esp
  801ee6:	39 c3                	cmp    %eax,%ebx
  801ee8:	0f 94 c1             	sete   %cl
  801eeb:	0f b6 c9             	movzbl %cl,%ecx
  801eee:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ef1:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ef7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801efa:	39 ce                	cmp    %ecx,%esi
  801efc:	74 1b                	je     801f19 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801efe:	39 c3                	cmp    %eax,%ebx
  801f00:	75 c4                	jne    801ec6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f02:	8b 42 58             	mov    0x58(%edx),%eax
  801f05:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f08:	50                   	push   %eax
  801f09:	56                   	push   %esi
  801f0a:	68 2b 2d 80 00       	push   $0x802d2b
  801f0f:	e8 5d e4 ff ff       	call   800371 <cprintf>
  801f14:	83 c4 10             	add    $0x10,%esp
  801f17:	eb ad                	jmp    801ec6 <_pipeisclosed+0xe>
	}
}
  801f19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f1f:	5b                   	pop    %ebx
  801f20:	5e                   	pop    %esi
  801f21:	5f                   	pop    %edi
  801f22:	5d                   	pop    %ebp
  801f23:	c3                   	ret    

00801f24 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f24:	55                   	push   %ebp
  801f25:	89 e5                	mov    %esp,%ebp
  801f27:	57                   	push   %edi
  801f28:	56                   	push   %esi
  801f29:	53                   	push   %ebx
  801f2a:	83 ec 28             	sub    $0x28,%esp
  801f2d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f30:	56                   	push   %esi
  801f31:	e8 b5 f2 ff ff       	call   8011eb <fd2data>
  801f36:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f38:	83 c4 10             	add    $0x10,%esp
  801f3b:	bf 00 00 00 00       	mov    $0x0,%edi
  801f40:	eb 4b                	jmp    801f8d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f42:	89 da                	mov    %ebx,%edx
  801f44:	89 f0                	mov    %esi,%eax
  801f46:	e8 6d ff ff ff       	call   801eb8 <_pipeisclosed>
  801f4b:	85 c0                	test   %eax,%eax
  801f4d:	75 48                	jne    801f97 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f4f:	e8 86 ed ff ff       	call   800cda <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f54:	8b 43 04             	mov    0x4(%ebx),%eax
  801f57:	8b 0b                	mov    (%ebx),%ecx
  801f59:	8d 51 20             	lea    0x20(%ecx),%edx
  801f5c:	39 d0                	cmp    %edx,%eax
  801f5e:	73 e2                	jae    801f42 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f63:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f67:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f6a:	89 c2                	mov    %eax,%edx
  801f6c:	c1 fa 1f             	sar    $0x1f,%edx
  801f6f:	89 d1                	mov    %edx,%ecx
  801f71:	c1 e9 1b             	shr    $0x1b,%ecx
  801f74:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f77:	83 e2 1f             	and    $0x1f,%edx
  801f7a:	29 ca                	sub    %ecx,%edx
  801f7c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f80:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f84:	83 c0 01             	add    $0x1,%eax
  801f87:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f8a:	83 c7 01             	add    $0x1,%edi
  801f8d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f90:	75 c2                	jne    801f54 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f92:	8b 45 10             	mov    0x10(%ebp),%eax
  801f95:	eb 05                	jmp    801f9c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f97:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f9f:	5b                   	pop    %ebx
  801fa0:	5e                   	pop    %esi
  801fa1:	5f                   	pop    %edi
  801fa2:	5d                   	pop    %ebp
  801fa3:	c3                   	ret    

00801fa4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fa4:	55                   	push   %ebp
  801fa5:	89 e5                	mov    %esp,%ebp
  801fa7:	57                   	push   %edi
  801fa8:	56                   	push   %esi
  801fa9:	53                   	push   %ebx
  801faa:	83 ec 18             	sub    $0x18,%esp
  801fad:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fb0:	57                   	push   %edi
  801fb1:	e8 35 f2 ff ff       	call   8011eb <fd2data>
  801fb6:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fb8:	83 c4 10             	add    $0x10,%esp
  801fbb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fc0:	eb 3d                	jmp    801fff <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801fc2:	85 db                	test   %ebx,%ebx
  801fc4:	74 04                	je     801fca <devpipe_read+0x26>
				return i;
  801fc6:	89 d8                	mov    %ebx,%eax
  801fc8:	eb 44                	jmp    80200e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fca:	89 f2                	mov    %esi,%edx
  801fcc:	89 f8                	mov    %edi,%eax
  801fce:	e8 e5 fe ff ff       	call   801eb8 <_pipeisclosed>
  801fd3:	85 c0                	test   %eax,%eax
  801fd5:	75 32                	jne    802009 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801fd7:	e8 fe ec ff ff       	call   800cda <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801fdc:	8b 06                	mov    (%esi),%eax
  801fde:	3b 46 04             	cmp    0x4(%esi),%eax
  801fe1:	74 df                	je     801fc2 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fe3:	99                   	cltd   
  801fe4:	c1 ea 1b             	shr    $0x1b,%edx
  801fe7:	01 d0                	add    %edx,%eax
  801fe9:	83 e0 1f             	and    $0x1f,%eax
  801fec:	29 d0                	sub    %edx,%eax
  801fee:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ff3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ff6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ff9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ffc:	83 c3 01             	add    $0x1,%ebx
  801fff:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802002:	75 d8                	jne    801fdc <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802004:	8b 45 10             	mov    0x10(%ebp),%eax
  802007:	eb 05                	jmp    80200e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802009:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80200e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802011:	5b                   	pop    %ebx
  802012:	5e                   	pop    %esi
  802013:	5f                   	pop    %edi
  802014:	5d                   	pop    %ebp
  802015:	c3                   	ret    

00802016 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802016:	55                   	push   %ebp
  802017:	89 e5                	mov    %esp,%ebp
  802019:	56                   	push   %esi
  80201a:	53                   	push   %ebx
  80201b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80201e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802021:	50                   	push   %eax
  802022:	e8 db f1 ff ff       	call   801202 <fd_alloc>
  802027:	83 c4 10             	add    $0x10,%esp
  80202a:	89 c2                	mov    %eax,%edx
  80202c:	85 c0                	test   %eax,%eax
  80202e:	0f 88 2c 01 00 00    	js     802160 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802034:	83 ec 04             	sub    $0x4,%esp
  802037:	68 07 04 00 00       	push   $0x407
  80203c:	ff 75 f4             	pushl  -0xc(%ebp)
  80203f:	6a 00                	push   $0x0
  802041:	e8 b3 ec ff ff       	call   800cf9 <sys_page_alloc>
  802046:	83 c4 10             	add    $0x10,%esp
  802049:	89 c2                	mov    %eax,%edx
  80204b:	85 c0                	test   %eax,%eax
  80204d:	0f 88 0d 01 00 00    	js     802160 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802053:	83 ec 0c             	sub    $0xc,%esp
  802056:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802059:	50                   	push   %eax
  80205a:	e8 a3 f1 ff ff       	call   801202 <fd_alloc>
  80205f:	89 c3                	mov    %eax,%ebx
  802061:	83 c4 10             	add    $0x10,%esp
  802064:	85 c0                	test   %eax,%eax
  802066:	0f 88 e2 00 00 00    	js     80214e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80206c:	83 ec 04             	sub    $0x4,%esp
  80206f:	68 07 04 00 00       	push   $0x407
  802074:	ff 75 f0             	pushl  -0x10(%ebp)
  802077:	6a 00                	push   $0x0
  802079:	e8 7b ec ff ff       	call   800cf9 <sys_page_alloc>
  80207e:	89 c3                	mov    %eax,%ebx
  802080:	83 c4 10             	add    $0x10,%esp
  802083:	85 c0                	test   %eax,%eax
  802085:	0f 88 c3 00 00 00    	js     80214e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80208b:	83 ec 0c             	sub    $0xc,%esp
  80208e:	ff 75 f4             	pushl  -0xc(%ebp)
  802091:	e8 55 f1 ff ff       	call   8011eb <fd2data>
  802096:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802098:	83 c4 0c             	add    $0xc,%esp
  80209b:	68 07 04 00 00       	push   $0x407
  8020a0:	50                   	push   %eax
  8020a1:	6a 00                	push   $0x0
  8020a3:	e8 51 ec ff ff       	call   800cf9 <sys_page_alloc>
  8020a8:	89 c3                	mov    %eax,%ebx
  8020aa:	83 c4 10             	add    $0x10,%esp
  8020ad:	85 c0                	test   %eax,%eax
  8020af:	0f 88 89 00 00 00    	js     80213e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020b5:	83 ec 0c             	sub    $0xc,%esp
  8020b8:	ff 75 f0             	pushl  -0x10(%ebp)
  8020bb:	e8 2b f1 ff ff       	call   8011eb <fd2data>
  8020c0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020c7:	50                   	push   %eax
  8020c8:	6a 00                	push   $0x0
  8020ca:	56                   	push   %esi
  8020cb:	6a 00                	push   $0x0
  8020cd:	e8 6a ec ff ff       	call   800d3c <sys_page_map>
  8020d2:	89 c3                	mov    %eax,%ebx
  8020d4:	83 c4 20             	add    $0x20,%esp
  8020d7:	85 c0                	test   %eax,%eax
  8020d9:	78 55                	js     802130 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020db:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020f0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020f9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020fe:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802105:	83 ec 0c             	sub    $0xc,%esp
  802108:	ff 75 f4             	pushl  -0xc(%ebp)
  80210b:	e8 cb f0 ff ff       	call   8011db <fd2num>
  802110:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802113:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802115:	83 c4 04             	add    $0x4,%esp
  802118:	ff 75 f0             	pushl  -0x10(%ebp)
  80211b:	e8 bb f0 ff ff       	call   8011db <fd2num>
  802120:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802123:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802126:	83 c4 10             	add    $0x10,%esp
  802129:	ba 00 00 00 00       	mov    $0x0,%edx
  80212e:	eb 30                	jmp    802160 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802130:	83 ec 08             	sub    $0x8,%esp
  802133:	56                   	push   %esi
  802134:	6a 00                	push   $0x0
  802136:	e8 43 ec ff ff       	call   800d7e <sys_page_unmap>
  80213b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80213e:	83 ec 08             	sub    $0x8,%esp
  802141:	ff 75 f0             	pushl  -0x10(%ebp)
  802144:	6a 00                	push   $0x0
  802146:	e8 33 ec ff ff       	call   800d7e <sys_page_unmap>
  80214b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80214e:	83 ec 08             	sub    $0x8,%esp
  802151:	ff 75 f4             	pushl  -0xc(%ebp)
  802154:	6a 00                	push   $0x0
  802156:	e8 23 ec ff ff       	call   800d7e <sys_page_unmap>
  80215b:	83 c4 10             	add    $0x10,%esp
  80215e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802160:	89 d0                	mov    %edx,%eax
  802162:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802165:	5b                   	pop    %ebx
  802166:	5e                   	pop    %esi
  802167:	5d                   	pop    %ebp
  802168:	c3                   	ret    

00802169 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802169:	55                   	push   %ebp
  80216a:	89 e5                	mov    %esp,%ebp
  80216c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80216f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802172:	50                   	push   %eax
  802173:	ff 75 08             	pushl  0x8(%ebp)
  802176:	e8 d6 f0 ff ff       	call   801251 <fd_lookup>
  80217b:	83 c4 10             	add    $0x10,%esp
  80217e:	85 c0                	test   %eax,%eax
  802180:	78 18                	js     80219a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802182:	83 ec 0c             	sub    $0xc,%esp
  802185:	ff 75 f4             	pushl  -0xc(%ebp)
  802188:	e8 5e f0 ff ff       	call   8011eb <fd2data>
	return _pipeisclosed(fd, p);
  80218d:	89 c2                	mov    %eax,%edx
  80218f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802192:	e8 21 fd ff ff       	call   801eb8 <_pipeisclosed>
  802197:	83 c4 10             	add    $0x10,%esp
}
  80219a:	c9                   	leave  
  80219b:	c3                   	ret    

0080219c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80219c:	55                   	push   %ebp
  80219d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80219f:	b8 00 00 00 00       	mov    $0x0,%eax
  8021a4:	5d                   	pop    %ebp
  8021a5:	c3                   	ret    

008021a6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021a6:	55                   	push   %ebp
  8021a7:	89 e5                	mov    %esp,%ebp
  8021a9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021ac:	68 3e 2d 80 00       	push   $0x802d3e
  8021b1:	ff 75 0c             	pushl  0xc(%ebp)
  8021b4:	e8 3d e7 ff ff       	call   8008f6 <strcpy>
	return 0;
}
  8021b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8021be:	c9                   	leave  
  8021bf:	c3                   	ret    

008021c0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021c0:	55                   	push   %ebp
  8021c1:	89 e5                	mov    %esp,%ebp
  8021c3:	57                   	push   %edi
  8021c4:	56                   	push   %esi
  8021c5:	53                   	push   %ebx
  8021c6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021cc:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021d1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021d7:	eb 2d                	jmp    802206 <devcons_write+0x46>
		m = n - tot;
  8021d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021dc:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8021de:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8021e1:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8021e6:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021e9:	83 ec 04             	sub    $0x4,%esp
  8021ec:	53                   	push   %ebx
  8021ed:	03 45 0c             	add    0xc(%ebp),%eax
  8021f0:	50                   	push   %eax
  8021f1:	57                   	push   %edi
  8021f2:	e8 91 e8 ff ff       	call   800a88 <memmove>
		sys_cputs(buf, m);
  8021f7:	83 c4 08             	add    $0x8,%esp
  8021fa:	53                   	push   %ebx
  8021fb:	57                   	push   %edi
  8021fc:	e8 3c ea ff ff       	call   800c3d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802201:	01 de                	add    %ebx,%esi
  802203:	83 c4 10             	add    $0x10,%esp
  802206:	89 f0                	mov    %esi,%eax
  802208:	3b 75 10             	cmp    0x10(%ebp),%esi
  80220b:	72 cc                	jb     8021d9 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80220d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802210:	5b                   	pop    %ebx
  802211:	5e                   	pop    %esi
  802212:	5f                   	pop    %edi
  802213:	5d                   	pop    %ebp
  802214:	c3                   	ret    

00802215 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802215:	55                   	push   %ebp
  802216:	89 e5                	mov    %esp,%ebp
  802218:	83 ec 08             	sub    $0x8,%esp
  80221b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802220:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802224:	74 2a                	je     802250 <devcons_read+0x3b>
  802226:	eb 05                	jmp    80222d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802228:	e8 ad ea ff ff       	call   800cda <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80222d:	e8 29 ea ff ff       	call   800c5b <sys_cgetc>
  802232:	85 c0                	test   %eax,%eax
  802234:	74 f2                	je     802228 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802236:	85 c0                	test   %eax,%eax
  802238:	78 16                	js     802250 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80223a:	83 f8 04             	cmp    $0x4,%eax
  80223d:	74 0c                	je     80224b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80223f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802242:	88 02                	mov    %al,(%edx)
	return 1;
  802244:	b8 01 00 00 00       	mov    $0x1,%eax
  802249:	eb 05                	jmp    802250 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80224b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802250:	c9                   	leave  
  802251:	c3                   	ret    

00802252 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802252:	55                   	push   %ebp
  802253:	89 e5                	mov    %esp,%ebp
  802255:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802258:	8b 45 08             	mov    0x8(%ebp),%eax
  80225b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80225e:	6a 01                	push   $0x1
  802260:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802263:	50                   	push   %eax
  802264:	e8 d4 e9 ff ff       	call   800c3d <sys_cputs>
}
  802269:	83 c4 10             	add    $0x10,%esp
  80226c:	c9                   	leave  
  80226d:	c3                   	ret    

0080226e <getchar>:

int
getchar(void)
{
  80226e:	55                   	push   %ebp
  80226f:	89 e5                	mov    %esp,%ebp
  802271:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802274:	6a 01                	push   $0x1
  802276:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802279:	50                   	push   %eax
  80227a:	6a 00                	push   $0x0
  80227c:	e8 36 f2 ff ff       	call   8014b7 <read>
	if (r < 0)
  802281:	83 c4 10             	add    $0x10,%esp
  802284:	85 c0                	test   %eax,%eax
  802286:	78 0f                	js     802297 <getchar+0x29>
		return r;
	if (r < 1)
  802288:	85 c0                	test   %eax,%eax
  80228a:	7e 06                	jle    802292 <getchar+0x24>
		return -E_EOF;
	return c;
  80228c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802290:	eb 05                	jmp    802297 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802292:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802297:	c9                   	leave  
  802298:	c3                   	ret    

00802299 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802299:	55                   	push   %ebp
  80229a:	89 e5                	mov    %esp,%ebp
  80229c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80229f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022a2:	50                   	push   %eax
  8022a3:	ff 75 08             	pushl  0x8(%ebp)
  8022a6:	e8 a6 ef ff ff       	call   801251 <fd_lookup>
  8022ab:	83 c4 10             	add    $0x10,%esp
  8022ae:	85 c0                	test   %eax,%eax
  8022b0:	78 11                	js     8022c3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b5:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022bb:	39 10                	cmp    %edx,(%eax)
  8022bd:	0f 94 c0             	sete   %al
  8022c0:	0f b6 c0             	movzbl %al,%eax
}
  8022c3:	c9                   	leave  
  8022c4:	c3                   	ret    

008022c5 <opencons>:

int
opencons(void)
{
  8022c5:	55                   	push   %ebp
  8022c6:	89 e5                	mov    %esp,%ebp
  8022c8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022ce:	50                   	push   %eax
  8022cf:	e8 2e ef ff ff       	call   801202 <fd_alloc>
  8022d4:	83 c4 10             	add    $0x10,%esp
		return r;
  8022d7:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022d9:	85 c0                	test   %eax,%eax
  8022db:	78 3e                	js     80231b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022dd:	83 ec 04             	sub    $0x4,%esp
  8022e0:	68 07 04 00 00       	push   $0x407
  8022e5:	ff 75 f4             	pushl  -0xc(%ebp)
  8022e8:	6a 00                	push   $0x0
  8022ea:	e8 0a ea ff ff       	call   800cf9 <sys_page_alloc>
  8022ef:	83 c4 10             	add    $0x10,%esp
		return r;
  8022f2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022f4:	85 c0                	test   %eax,%eax
  8022f6:	78 23                	js     80231b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022f8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802301:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802303:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802306:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80230d:	83 ec 0c             	sub    $0xc,%esp
  802310:	50                   	push   %eax
  802311:	e8 c5 ee ff ff       	call   8011db <fd2num>
  802316:	89 c2                	mov    %eax,%edx
  802318:	83 c4 10             	add    $0x10,%esp
}
  80231b:	89 d0                	mov    %edx,%eax
  80231d:	c9                   	leave  
  80231e:	c3                   	ret    

0080231f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80231f:	55                   	push   %ebp
  802320:	89 e5                	mov    %esp,%ebp
  802322:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802325:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80232c:	75 2e                	jne    80235c <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  80232e:	e8 88 e9 ff ff       	call   800cbb <sys_getenvid>
  802333:	83 ec 04             	sub    $0x4,%esp
  802336:	68 07 0e 00 00       	push   $0xe07
  80233b:	68 00 f0 bf ee       	push   $0xeebff000
  802340:	50                   	push   %eax
  802341:	e8 b3 e9 ff ff       	call   800cf9 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802346:	e8 70 e9 ff ff       	call   800cbb <sys_getenvid>
  80234b:	83 c4 08             	add    $0x8,%esp
  80234e:	68 66 23 80 00       	push   $0x802366
  802353:	50                   	push   %eax
  802354:	e8 eb ea ff ff       	call   800e44 <sys_env_set_pgfault_upcall>
  802359:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80235c:	8b 45 08             	mov    0x8(%ebp),%eax
  80235f:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802364:	c9                   	leave  
  802365:	c3                   	ret    

00802366 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802366:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802367:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80236c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80236e:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  802371:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  802375:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802379:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  80237c:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  80237f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  802380:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  802383:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  802384:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  802385:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802389:	c3                   	ret    

0080238a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80238a:	55                   	push   %ebp
  80238b:	89 e5                	mov    %esp,%ebp
  80238d:	56                   	push   %esi
  80238e:	53                   	push   %ebx
  80238f:	8b 75 08             	mov    0x8(%ebp),%esi
  802392:	8b 45 0c             	mov    0xc(%ebp),%eax
  802395:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802398:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  80239a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80239f:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8023a2:	83 ec 0c             	sub    $0xc,%esp
  8023a5:	50                   	push   %eax
  8023a6:	e8 fe ea ff ff       	call   800ea9 <sys_ipc_recv>

	if (from_env_store != NULL)
  8023ab:	83 c4 10             	add    $0x10,%esp
  8023ae:	85 f6                	test   %esi,%esi
  8023b0:	74 14                	je     8023c6 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8023b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8023b7:	85 c0                	test   %eax,%eax
  8023b9:	78 09                	js     8023c4 <ipc_recv+0x3a>
  8023bb:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8023c1:	8b 52 74             	mov    0x74(%edx),%edx
  8023c4:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8023c6:	85 db                	test   %ebx,%ebx
  8023c8:	74 14                	je     8023de <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8023ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8023cf:	85 c0                	test   %eax,%eax
  8023d1:	78 09                	js     8023dc <ipc_recv+0x52>
  8023d3:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8023d9:	8b 52 78             	mov    0x78(%edx),%edx
  8023dc:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8023de:	85 c0                	test   %eax,%eax
  8023e0:	78 08                	js     8023ea <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8023e2:	a1 08 40 80 00       	mov    0x804008,%eax
  8023e7:	8b 40 70             	mov    0x70(%eax),%eax
}
  8023ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023ed:	5b                   	pop    %ebx
  8023ee:	5e                   	pop    %esi
  8023ef:	5d                   	pop    %ebp
  8023f0:	c3                   	ret    

008023f1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023f1:	55                   	push   %ebp
  8023f2:	89 e5                	mov    %esp,%ebp
  8023f4:	57                   	push   %edi
  8023f5:	56                   	push   %esi
  8023f6:	53                   	push   %ebx
  8023f7:	83 ec 0c             	sub    $0xc,%esp
  8023fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023fd:	8b 75 0c             	mov    0xc(%ebp),%esi
  802400:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  802403:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802405:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80240a:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80240d:	ff 75 14             	pushl  0x14(%ebp)
  802410:	53                   	push   %ebx
  802411:	56                   	push   %esi
  802412:	57                   	push   %edi
  802413:	e8 6e ea ff ff       	call   800e86 <sys_ipc_try_send>

		if (err < 0) {
  802418:	83 c4 10             	add    $0x10,%esp
  80241b:	85 c0                	test   %eax,%eax
  80241d:	79 1e                	jns    80243d <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  80241f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802422:	75 07                	jne    80242b <ipc_send+0x3a>
				sys_yield();
  802424:	e8 b1 e8 ff ff       	call   800cda <sys_yield>
  802429:	eb e2                	jmp    80240d <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  80242b:	50                   	push   %eax
  80242c:	68 4a 2d 80 00       	push   $0x802d4a
  802431:	6a 49                	push   $0x49
  802433:	68 57 2d 80 00       	push   $0x802d57
  802438:	e8 5b de ff ff       	call   800298 <_panic>
		}

	} while (err < 0);

}
  80243d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802440:	5b                   	pop    %ebx
  802441:	5e                   	pop    %esi
  802442:	5f                   	pop    %edi
  802443:	5d                   	pop    %ebp
  802444:	c3                   	ret    

00802445 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802445:	55                   	push   %ebp
  802446:	89 e5                	mov    %esp,%ebp
  802448:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80244b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802450:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802453:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802459:	8b 52 50             	mov    0x50(%edx),%edx
  80245c:	39 ca                	cmp    %ecx,%edx
  80245e:	75 0d                	jne    80246d <ipc_find_env+0x28>
			return envs[i].env_id;
  802460:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802463:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802468:	8b 40 48             	mov    0x48(%eax),%eax
  80246b:	eb 0f                	jmp    80247c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80246d:	83 c0 01             	add    $0x1,%eax
  802470:	3d 00 04 00 00       	cmp    $0x400,%eax
  802475:	75 d9                	jne    802450 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802477:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80247c:	5d                   	pop    %ebp
  80247d:	c3                   	ret    

0080247e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80247e:	55                   	push   %ebp
  80247f:	89 e5                	mov    %esp,%ebp
  802481:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802484:	89 d0                	mov    %edx,%eax
  802486:	c1 e8 16             	shr    $0x16,%eax
  802489:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802490:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802495:	f6 c1 01             	test   $0x1,%cl
  802498:	74 1d                	je     8024b7 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80249a:	c1 ea 0c             	shr    $0xc,%edx
  80249d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8024a4:	f6 c2 01             	test   $0x1,%dl
  8024a7:	74 0e                	je     8024b7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024a9:	c1 ea 0c             	shr    $0xc,%edx
  8024ac:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8024b3:	ef 
  8024b4:	0f b7 c0             	movzwl %ax,%eax
}
  8024b7:	5d                   	pop    %ebp
  8024b8:	c3                   	ret    
  8024b9:	66 90                	xchg   %ax,%ax
  8024bb:	66 90                	xchg   %ax,%ax
  8024bd:	66 90                	xchg   %ax,%ax
  8024bf:	90                   	nop

008024c0 <__udivdi3>:
  8024c0:	55                   	push   %ebp
  8024c1:	57                   	push   %edi
  8024c2:	56                   	push   %esi
  8024c3:	53                   	push   %ebx
  8024c4:	83 ec 1c             	sub    $0x1c,%esp
  8024c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8024cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8024cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8024d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024d7:	85 f6                	test   %esi,%esi
  8024d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024dd:	89 ca                	mov    %ecx,%edx
  8024df:	89 f8                	mov    %edi,%eax
  8024e1:	75 3d                	jne    802520 <__udivdi3+0x60>
  8024e3:	39 cf                	cmp    %ecx,%edi
  8024e5:	0f 87 c5 00 00 00    	ja     8025b0 <__udivdi3+0xf0>
  8024eb:	85 ff                	test   %edi,%edi
  8024ed:	89 fd                	mov    %edi,%ebp
  8024ef:	75 0b                	jne    8024fc <__udivdi3+0x3c>
  8024f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8024f6:	31 d2                	xor    %edx,%edx
  8024f8:	f7 f7                	div    %edi
  8024fa:	89 c5                	mov    %eax,%ebp
  8024fc:	89 c8                	mov    %ecx,%eax
  8024fe:	31 d2                	xor    %edx,%edx
  802500:	f7 f5                	div    %ebp
  802502:	89 c1                	mov    %eax,%ecx
  802504:	89 d8                	mov    %ebx,%eax
  802506:	89 cf                	mov    %ecx,%edi
  802508:	f7 f5                	div    %ebp
  80250a:	89 c3                	mov    %eax,%ebx
  80250c:	89 d8                	mov    %ebx,%eax
  80250e:	89 fa                	mov    %edi,%edx
  802510:	83 c4 1c             	add    $0x1c,%esp
  802513:	5b                   	pop    %ebx
  802514:	5e                   	pop    %esi
  802515:	5f                   	pop    %edi
  802516:	5d                   	pop    %ebp
  802517:	c3                   	ret    
  802518:	90                   	nop
  802519:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802520:	39 ce                	cmp    %ecx,%esi
  802522:	77 74                	ja     802598 <__udivdi3+0xd8>
  802524:	0f bd fe             	bsr    %esi,%edi
  802527:	83 f7 1f             	xor    $0x1f,%edi
  80252a:	0f 84 98 00 00 00    	je     8025c8 <__udivdi3+0x108>
  802530:	bb 20 00 00 00       	mov    $0x20,%ebx
  802535:	89 f9                	mov    %edi,%ecx
  802537:	89 c5                	mov    %eax,%ebp
  802539:	29 fb                	sub    %edi,%ebx
  80253b:	d3 e6                	shl    %cl,%esi
  80253d:	89 d9                	mov    %ebx,%ecx
  80253f:	d3 ed                	shr    %cl,%ebp
  802541:	89 f9                	mov    %edi,%ecx
  802543:	d3 e0                	shl    %cl,%eax
  802545:	09 ee                	or     %ebp,%esi
  802547:	89 d9                	mov    %ebx,%ecx
  802549:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80254d:	89 d5                	mov    %edx,%ebp
  80254f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802553:	d3 ed                	shr    %cl,%ebp
  802555:	89 f9                	mov    %edi,%ecx
  802557:	d3 e2                	shl    %cl,%edx
  802559:	89 d9                	mov    %ebx,%ecx
  80255b:	d3 e8                	shr    %cl,%eax
  80255d:	09 c2                	or     %eax,%edx
  80255f:	89 d0                	mov    %edx,%eax
  802561:	89 ea                	mov    %ebp,%edx
  802563:	f7 f6                	div    %esi
  802565:	89 d5                	mov    %edx,%ebp
  802567:	89 c3                	mov    %eax,%ebx
  802569:	f7 64 24 0c          	mull   0xc(%esp)
  80256d:	39 d5                	cmp    %edx,%ebp
  80256f:	72 10                	jb     802581 <__udivdi3+0xc1>
  802571:	8b 74 24 08          	mov    0x8(%esp),%esi
  802575:	89 f9                	mov    %edi,%ecx
  802577:	d3 e6                	shl    %cl,%esi
  802579:	39 c6                	cmp    %eax,%esi
  80257b:	73 07                	jae    802584 <__udivdi3+0xc4>
  80257d:	39 d5                	cmp    %edx,%ebp
  80257f:	75 03                	jne    802584 <__udivdi3+0xc4>
  802581:	83 eb 01             	sub    $0x1,%ebx
  802584:	31 ff                	xor    %edi,%edi
  802586:	89 d8                	mov    %ebx,%eax
  802588:	89 fa                	mov    %edi,%edx
  80258a:	83 c4 1c             	add    $0x1c,%esp
  80258d:	5b                   	pop    %ebx
  80258e:	5e                   	pop    %esi
  80258f:	5f                   	pop    %edi
  802590:	5d                   	pop    %ebp
  802591:	c3                   	ret    
  802592:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802598:	31 ff                	xor    %edi,%edi
  80259a:	31 db                	xor    %ebx,%ebx
  80259c:	89 d8                	mov    %ebx,%eax
  80259e:	89 fa                	mov    %edi,%edx
  8025a0:	83 c4 1c             	add    $0x1c,%esp
  8025a3:	5b                   	pop    %ebx
  8025a4:	5e                   	pop    %esi
  8025a5:	5f                   	pop    %edi
  8025a6:	5d                   	pop    %ebp
  8025a7:	c3                   	ret    
  8025a8:	90                   	nop
  8025a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025b0:	89 d8                	mov    %ebx,%eax
  8025b2:	f7 f7                	div    %edi
  8025b4:	31 ff                	xor    %edi,%edi
  8025b6:	89 c3                	mov    %eax,%ebx
  8025b8:	89 d8                	mov    %ebx,%eax
  8025ba:	89 fa                	mov    %edi,%edx
  8025bc:	83 c4 1c             	add    $0x1c,%esp
  8025bf:	5b                   	pop    %ebx
  8025c0:	5e                   	pop    %esi
  8025c1:	5f                   	pop    %edi
  8025c2:	5d                   	pop    %ebp
  8025c3:	c3                   	ret    
  8025c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025c8:	39 ce                	cmp    %ecx,%esi
  8025ca:	72 0c                	jb     8025d8 <__udivdi3+0x118>
  8025cc:	31 db                	xor    %ebx,%ebx
  8025ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8025d2:	0f 87 34 ff ff ff    	ja     80250c <__udivdi3+0x4c>
  8025d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8025dd:	e9 2a ff ff ff       	jmp    80250c <__udivdi3+0x4c>
  8025e2:	66 90                	xchg   %ax,%ax
  8025e4:	66 90                	xchg   %ax,%ax
  8025e6:	66 90                	xchg   %ax,%ax
  8025e8:	66 90                	xchg   %ax,%ax
  8025ea:	66 90                	xchg   %ax,%ax
  8025ec:	66 90                	xchg   %ax,%ax
  8025ee:	66 90                	xchg   %ax,%ax

008025f0 <__umoddi3>:
  8025f0:	55                   	push   %ebp
  8025f1:	57                   	push   %edi
  8025f2:	56                   	push   %esi
  8025f3:	53                   	push   %ebx
  8025f4:	83 ec 1c             	sub    $0x1c,%esp
  8025f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8025fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8025ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802603:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802607:	85 d2                	test   %edx,%edx
  802609:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80260d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802611:	89 f3                	mov    %esi,%ebx
  802613:	89 3c 24             	mov    %edi,(%esp)
  802616:	89 74 24 04          	mov    %esi,0x4(%esp)
  80261a:	75 1c                	jne    802638 <__umoddi3+0x48>
  80261c:	39 f7                	cmp    %esi,%edi
  80261e:	76 50                	jbe    802670 <__umoddi3+0x80>
  802620:	89 c8                	mov    %ecx,%eax
  802622:	89 f2                	mov    %esi,%edx
  802624:	f7 f7                	div    %edi
  802626:	89 d0                	mov    %edx,%eax
  802628:	31 d2                	xor    %edx,%edx
  80262a:	83 c4 1c             	add    $0x1c,%esp
  80262d:	5b                   	pop    %ebx
  80262e:	5e                   	pop    %esi
  80262f:	5f                   	pop    %edi
  802630:	5d                   	pop    %ebp
  802631:	c3                   	ret    
  802632:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802638:	39 f2                	cmp    %esi,%edx
  80263a:	89 d0                	mov    %edx,%eax
  80263c:	77 52                	ja     802690 <__umoddi3+0xa0>
  80263e:	0f bd ea             	bsr    %edx,%ebp
  802641:	83 f5 1f             	xor    $0x1f,%ebp
  802644:	75 5a                	jne    8026a0 <__umoddi3+0xb0>
  802646:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80264a:	0f 82 e0 00 00 00    	jb     802730 <__umoddi3+0x140>
  802650:	39 0c 24             	cmp    %ecx,(%esp)
  802653:	0f 86 d7 00 00 00    	jbe    802730 <__umoddi3+0x140>
  802659:	8b 44 24 08          	mov    0x8(%esp),%eax
  80265d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802661:	83 c4 1c             	add    $0x1c,%esp
  802664:	5b                   	pop    %ebx
  802665:	5e                   	pop    %esi
  802666:	5f                   	pop    %edi
  802667:	5d                   	pop    %ebp
  802668:	c3                   	ret    
  802669:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802670:	85 ff                	test   %edi,%edi
  802672:	89 fd                	mov    %edi,%ebp
  802674:	75 0b                	jne    802681 <__umoddi3+0x91>
  802676:	b8 01 00 00 00       	mov    $0x1,%eax
  80267b:	31 d2                	xor    %edx,%edx
  80267d:	f7 f7                	div    %edi
  80267f:	89 c5                	mov    %eax,%ebp
  802681:	89 f0                	mov    %esi,%eax
  802683:	31 d2                	xor    %edx,%edx
  802685:	f7 f5                	div    %ebp
  802687:	89 c8                	mov    %ecx,%eax
  802689:	f7 f5                	div    %ebp
  80268b:	89 d0                	mov    %edx,%eax
  80268d:	eb 99                	jmp    802628 <__umoddi3+0x38>
  80268f:	90                   	nop
  802690:	89 c8                	mov    %ecx,%eax
  802692:	89 f2                	mov    %esi,%edx
  802694:	83 c4 1c             	add    $0x1c,%esp
  802697:	5b                   	pop    %ebx
  802698:	5e                   	pop    %esi
  802699:	5f                   	pop    %edi
  80269a:	5d                   	pop    %ebp
  80269b:	c3                   	ret    
  80269c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026a0:	8b 34 24             	mov    (%esp),%esi
  8026a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8026a8:	89 e9                	mov    %ebp,%ecx
  8026aa:	29 ef                	sub    %ebp,%edi
  8026ac:	d3 e0                	shl    %cl,%eax
  8026ae:	89 f9                	mov    %edi,%ecx
  8026b0:	89 f2                	mov    %esi,%edx
  8026b2:	d3 ea                	shr    %cl,%edx
  8026b4:	89 e9                	mov    %ebp,%ecx
  8026b6:	09 c2                	or     %eax,%edx
  8026b8:	89 d8                	mov    %ebx,%eax
  8026ba:	89 14 24             	mov    %edx,(%esp)
  8026bd:	89 f2                	mov    %esi,%edx
  8026bf:	d3 e2                	shl    %cl,%edx
  8026c1:	89 f9                	mov    %edi,%ecx
  8026c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8026c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8026cb:	d3 e8                	shr    %cl,%eax
  8026cd:	89 e9                	mov    %ebp,%ecx
  8026cf:	89 c6                	mov    %eax,%esi
  8026d1:	d3 e3                	shl    %cl,%ebx
  8026d3:	89 f9                	mov    %edi,%ecx
  8026d5:	89 d0                	mov    %edx,%eax
  8026d7:	d3 e8                	shr    %cl,%eax
  8026d9:	89 e9                	mov    %ebp,%ecx
  8026db:	09 d8                	or     %ebx,%eax
  8026dd:	89 d3                	mov    %edx,%ebx
  8026df:	89 f2                	mov    %esi,%edx
  8026e1:	f7 34 24             	divl   (%esp)
  8026e4:	89 d6                	mov    %edx,%esi
  8026e6:	d3 e3                	shl    %cl,%ebx
  8026e8:	f7 64 24 04          	mull   0x4(%esp)
  8026ec:	39 d6                	cmp    %edx,%esi
  8026ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026f2:	89 d1                	mov    %edx,%ecx
  8026f4:	89 c3                	mov    %eax,%ebx
  8026f6:	72 08                	jb     802700 <__umoddi3+0x110>
  8026f8:	75 11                	jne    80270b <__umoddi3+0x11b>
  8026fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8026fe:	73 0b                	jae    80270b <__umoddi3+0x11b>
  802700:	2b 44 24 04          	sub    0x4(%esp),%eax
  802704:	1b 14 24             	sbb    (%esp),%edx
  802707:	89 d1                	mov    %edx,%ecx
  802709:	89 c3                	mov    %eax,%ebx
  80270b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80270f:	29 da                	sub    %ebx,%edx
  802711:	19 ce                	sbb    %ecx,%esi
  802713:	89 f9                	mov    %edi,%ecx
  802715:	89 f0                	mov    %esi,%eax
  802717:	d3 e0                	shl    %cl,%eax
  802719:	89 e9                	mov    %ebp,%ecx
  80271b:	d3 ea                	shr    %cl,%edx
  80271d:	89 e9                	mov    %ebp,%ecx
  80271f:	d3 ee                	shr    %cl,%esi
  802721:	09 d0                	or     %edx,%eax
  802723:	89 f2                	mov    %esi,%edx
  802725:	83 c4 1c             	add    $0x1c,%esp
  802728:	5b                   	pop    %ebx
  802729:	5e                   	pop    %esi
  80272a:	5f                   	pop    %edi
  80272b:	5d                   	pop    %ebp
  80272c:	c3                   	ret    
  80272d:	8d 76 00             	lea    0x0(%esi),%esi
  802730:	29 f9                	sub    %edi,%ecx
  802732:	19 d6                	sbb    %edx,%esi
  802734:	89 74 24 04          	mov    %esi,0x4(%esp)
  802738:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80273c:	e9 18 ff ff ff       	jmp    802659 <__umoddi3+0x69>
