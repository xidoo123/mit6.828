
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
  80004c:	e8 b5 14 00 00       	call   801506 <readn>
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
  800068:	68 20 27 80 00       	push   $0x802720
  80006d:	6a 15                	push   $0x15
  80006f:	68 4f 27 80 00       	push   $0x80274f
  800074:	e8 1f 02 00 00       	call   800298 <_panic>

	cprintf("%d\n", p);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	ff 75 e0             	pushl  -0x20(%ebp)
  80007f:	68 61 27 80 00       	push   $0x802761
  800084:	e8 e8 02 00 00       	call   800371 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800089:	89 3c 24             	mov    %edi,(%esp)
  80008c:	e8 43 1f 00 00       	call   801fd4 <pipe>
  800091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	85 c0                	test   %eax,%eax
  800099:	79 12                	jns    8000ad <primeproc+0x7a>
		panic("pipe: %e", i);
  80009b:	50                   	push   %eax
  80009c:	68 65 27 80 00       	push   $0x802765
  8000a1:	6a 1b                	push   $0x1b
  8000a3:	68 4f 27 80 00       	push   $0x80274f
  8000a8:	e8 eb 01 00 00       	call   800298 <_panic>
	if ((id = fork()) < 0)
  8000ad:	e8 30 0f 00 00       	call   800fe2 <fork>
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	79 12                	jns    8000c8 <primeproc+0x95>
		panic("fork: %e", id);
  8000b6:	50                   	push   %eax
  8000b7:	68 6e 27 80 00       	push   $0x80276e
  8000bc:	6a 1d                	push   $0x1d
  8000be:	68 4f 27 80 00       	push   $0x80274f
  8000c3:	e8 d0 01 00 00       	call   800298 <_panic>
	if (id == 0) {
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	75 1f                	jne    8000eb <primeproc+0xb8>
		close(fd);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	53                   	push   %ebx
  8000d0:	e8 64 12 00 00       	call   801339 <close>
		close(pfd[1]);
  8000d5:	83 c4 04             	add    $0x4,%esp
  8000d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000db:	e8 59 12 00 00       	call   801339 <close>
		fd = pfd[0];
  8000e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	e9 5a ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f1:	e8 43 12 00 00       	call   801339 <close>
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
  800106:	e8 fb 13 00 00       	call   801506 <readn>
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
  800126:	68 77 27 80 00       	push   $0x802777
  80012b:	6a 2b                	push   $0x2b
  80012d:	68 4f 27 80 00       	push   $0x80274f
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
  800149:	e8 01 14 00 00       	call   80154f <write>
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
  800168:	68 93 27 80 00       	push   $0x802793
  80016d:	6a 2e                	push   $0x2e
  80016f:	68 4f 27 80 00       	push   $0x80274f
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
  800180:	c7 05 00 30 80 00 ad 	movl   $0x8027ad,0x803000
  800187:	27 80 00 

	if ((i=pipe(p)) < 0)
  80018a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	e8 41 1e 00 00       	call   801fd4 <pipe>
  800193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	85 c0                	test   %eax,%eax
  80019b:	79 12                	jns    8001af <umain+0x36>
		panic("pipe: %e", i);
  80019d:	50                   	push   %eax
  80019e:	68 65 27 80 00       	push   $0x802765
  8001a3:	6a 3a                	push   $0x3a
  8001a5:	68 4f 27 80 00       	push   $0x80274f
  8001aa:	e8 e9 00 00 00       	call   800298 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001af:	e8 2e 0e 00 00       	call   800fe2 <fork>
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	79 12                	jns    8001ca <umain+0x51>
		panic("fork: %e", id);
  8001b8:	50                   	push   %eax
  8001b9:	68 6e 27 80 00       	push   $0x80276e
  8001be:	6a 3e                	push   $0x3e
  8001c0:	68 4f 27 80 00       	push   $0x80274f
  8001c5:	e8 ce 00 00 00       	call   800298 <_panic>

	if (id == 0) {
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	75 16                	jne    8001e4 <umain+0x6b>
		close(p[1]);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d4:	e8 60 11 00 00       	call   801339 <close>
		primeproc(p[0]);
  8001d9:	83 c4 04             	add    $0x4,%esp
  8001dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8001df:	e8 4f fe ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ea:	e8 4a 11 00 00       	call   801339 <close>

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
  800205:	e8 45 13 00 00       	call   80154f <write>
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
  800221:	68 b8 27 80 00       	push   $0x8027b8
  800226:	6a 4a                	push   $0x4a
  800228:	68 4f 27 80 00       	push   $0x80274f
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
  800284:	e8 db 10 00 00       	call   801364 <close_all>
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
  8002b6:	68 dc 27 80 00       	push   $0x8027dc
  8002bb:	e8 b1 00 00 00       	call   800371 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002c0:	83 c4 18             	add    $0x18,%esp
  8002c3:	53                   	push   %ebx
  8002c4:	ff 75 10             	pushl  0x10(%ebp)
  8002c7:	e8 54 00 00 00       	call   800320 <vcprintf>
	cprintf("\n");
  8002cc:	c7 04 24 63 27 80 00 	movl   $0x802763,(%esp)
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
  8003d4:	e8 a7 20 00 00       	call   802480 <__udivdi3>
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
  800417:	e8 94 21 00 00       	call   8025b0 <__umoddi3>
  80041c:	83 c4 14             	add    $0x14,%esp
  80041f:	0f be 80 ff 27 80 00 	movsbl 0x8027ff(%eax),%eax
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
  80051b:	ff 24 85 40 29 80 00 	jmp    *0x802940(,%eax,4)
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
  8005df:	8b 14 85 a0 2a 80 00 	mov    0x802aa0(,%eax,4),%edx
  8005e6:	85 d2                	test   %edx,%edx
  8005e8:	75 18                	jne    800602 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005ea:	50                   	push   %eax
  8005eb:	68 17 28 80 00       	push   $0x802817
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
  800603:	68 91 2c 80 00       	push   $0x802c91
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
  800627:	b8 10 28 80 00       	mov    $0x802810,%eax
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
  800ca2:	68 ff 2a 80 00       	push   $0x802aff
  800ca7:	6a 23                	push   $0x23
  800ca9:	68 1c 2b 80 00       	push   $0x802b1c
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
  800d23:	68 ff 2a 80 00       	push   $0x802aff
  800d28:	6a 23                	push   $0x23
  800d2a:	68 1c 2b 80 00       	push   $0x802b1c
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
  800d65:	68 ff 2a 80 00       	push   $0x802aff
  800d6a:	6a 23                	push   $0x23
  800d6c:	68 1c 2b 80 00       	push   $0x802b1c
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
  800da7:	68 ff 2a 80 00       	push   $0x802aff
  800dac:	6a 23                	push   $0x23
  800dae:	68 1c 2b 80 00       	push   $0x802b1c
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
  800de9:	68 ff 2a 80 00       	push   $0x802aff
  800dee:	6a 23                	push   $0x23
  800df0:	68 1c 2b 80 00       	push   $0x802b1c
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
  800e2b:	68 ff 2a 80 00       	push   $0x802aff
  800e30:	6a 23                	push   $0x23
  800e32:	68 1c 2b 80 00       	push   $0x802b1c
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
  800e6d:	68 ff 2a 80 00       	push   $0x802aff
  800e72:	6a 23                	push   $0x23
  800e74:	68 1c 2b 80 00       	push   $0x802b1c
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
  800ed1:	68 ff 2a 80 00       	push   $0x802aff
  800ed6:	6a 23                	push   $0x23
  800ed8:	68 1c 2b 80 00       	push   $0x802b1c
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

00800f09 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	56                   	push   %esi
  800f0d:	53                   	push   %ebx
  800f0e:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f11:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800f13:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f17:	75 25                	jne    800f3e <pgfault+0x35>
  800f19:	89 d8                	mov    %ebx,%eax
  800f1b:	c1 e8 0c             	shr    $0xc,%eax
  800f1e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f25:	f6 c4 08             	test   $0x8,%ah
  800f28:	75 14                	jne    800f3e <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800f2a:	83 ec 04             	sub    $0x4,%esp
  800f2d:	68 2c 2b 80 00       	push   $0x802b2c
  800f32:	6a 1e                	push   $0x1e
  800f34:	68 c0 2b 80 00       	push   $0x802bc0
  800f39:	e8 5a f3 ff ff       	call   800298 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800f3e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800f44:	e8 72 fd ff ff       	call   800cbb <sys_getenvid>
  800f49:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800f4b:	83 ec 04             	sub    $0x4,%esp
  800f4e:	6a 07                	push   $0x7
  800f50:	68 00 f0 7f 00       	push   $0x7ff000
  800f55:	50                   	push   %eax
  800f56:	e8 9e fd ff ff       	call   800cf9 <sys_page_alloc>
	if (r < 0)
  800f5b:	83 c4 10             	add    $0x10,%esp
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	79 12                	jns    800f74 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800f62:	50                   	push   %eax
  800f63:	68 58 2b 80 00       	push   $0x802b58
  800f68:	6a 33                	push   $0x33
  800f6a:	68 c0 2b 80 00       	push   $0x802bc0
  800f6f:	e8 24 f3 ff ff       	call   800298 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800f74:	83 ec 04             	sub    $0x4,%esp
  800f77:	68 00 10 00 00       	push   $0x1000
  800f7c:	53                   	push   %ebx
  800f7d:	68 00 f0 7f 00       	push   $0x7ff000
  800f82:	e8 69 fb ff ff       	call   800af0 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800f87:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f8e:	53                   	push   %ebx
  800f8f:	56                   	push   %esi
  800f90:	68 00 f0 7f 00       	push   $0x7ff000
  800f95:	56                   	push   %esi
  800f96:	e8 a1 fd ff ff       	call   800d3c <sys_page_map>
	if (r < 0)
  800f9b:	83 c4 20             	add    $0x20,%esp
  800f9e:	85 c0                	test   %eax,%eax
  800fa0:	79 12                	jns    800fb4 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800fa2:	50                   	push   %eax
  800fa3:	68 7c 2b 80 00       	push   $0x802b7c
  800fa8:	6a 3b                	push   $0x3b
  800faa:	68 c0 2b 80 00       	push   $0x802bc0
  800faf:	e8 e4 f2 ff ff       	call   800298 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800fb4:	83 ec 08             	sub    $0x8,%esp
  800fb7:	68 00 f0 7f 00       	push   $0x7ff000
  800fbc:	56                   	push   %esi
  800fbd:	e8 bc fd ff ff       	call   800d7e <sys_page_unmap>
	if (r < 0)
  800fc2:	83 c4 10             	add    $0x10,%esp
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	79 12                	jns    800fdb <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800fc9:	50                   	push   %eax
  800fca:	68 a0 2b 80 00       	push   $0x802ba0
  800fcf:	6a 40                	push   $0x40
  800fd1:	68 c0 2b 80 00       	push   $0x802bc0
  800fd6:	e8 bd f2 ff ff       	call   800298 <_panic>
}
  800fdb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fde:	5b                   	pop    %ebx
  800fdf:	5e                   	pop    %esi
  800fe0:	5d                   	pop    %ebp
  800fe1:	c3                   	ret    

00800fe2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fe2:	55                   	push   %ebp
  800fe3:	89 e5                	mov    %esp,%ebp
  800fe5:	57                   	push   %edi
  800fe6:	56                   	push   %esi
  800fe7:	53                   	push   %ebx
  800fe8:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800feb:	68 09 0f 80 00       	push   $0x800f09
  800ff0:	e8 e8 12 00 00       	call   8022dd <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ff5:	b8 07 00 00 00       	mov    $0x7,%eax
  800ffa:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800ffc:	83 c4 10             	add    $0x10,%esp
  800fff:	85 c0                	test   %eax,%eax
  801001:	0f 88 64 01 00 00    	js     80116b <fork+0x189>
  801007:	bb 00 00 80 00       	mov    $0x800000,%ebx
  80100c:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  801011:	85 c0                	test   %eax,%eax
  801013:	75 21                	jne    801036 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  801015:	e8 a1 fc ff ff       	call   800cbb <sys_getenvid>
  80101a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80101f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801022:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801027:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  80102c:	ba 00 00 00 00       	mov    $0x0,%edx
  801031:	e9 3f 01 00 00       	jmp    801175 <fork+0x193>
  801036:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801039:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  80103b:	89 d8                	mov    %ebx,%eax
  80103d:	c1 e8 16             	shr    $0x16,%eax
  801040:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801047:	a8 01                	test   $0x1,%al
  801049:	0f 84 bd 00 00 00    	je     80110c <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  80104f:	89 d8                	mov    %ebx,%eax
  801051:	c1 e8 0c             	shr    $0xc,%eax
  801054:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80105b:	f6 c2 01             	test   $0x1,%dl
  80105e:	0f 84 a8 00 00 00    	je     80110c <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  801064:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80106b:	a8 04                	test   $0x4,%al
  80106d:	0f 84 99 00 00 00    	je     80110c <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  801073:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80107a:	f6 c4 04             	test   $0x4,%ah
  80107d:	74 17                	je     801096 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  80107f:	83 ec 0c             	sub    $0xc,%esp
  801082:	68 07 0e 00 00       	push   $0xe07
  801087:	53                   	push   %ebx
  801088:	57                   	push   %edi
  801089:	53                   	push   %ebx
  80108a:	6a 00                	push   $0x0
  80108c:	e8 ab fc ff ff       	call   800d3c <sys_page_map>
  801091:	83 c4 20             	add    $0x20,%esp
  801094:	eb 76                	jmp    80110c <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801096:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80109d:	a8 02                	test   $0x2,%al
  80109f:	75 0c                	jne    8010ad <fork+0xcb>
  8010a1:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010a8:	f6 c4 08             	test   $0x8,%ah
  8010ab:	74 3f                	je     8010ec <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  8010ad:	83 ec 0c             	sub    $0xc,%esp
  8010b0:	68 05 08 00 00       	push   $0x805
  8010b5:	53                   	push   %ebx
  8010b6:	57                   	push   %edi
  8010b7:	53                   	push   %ebx
  8010b8:	6a 00                	push   $0x0
  8010ba:	e8 7d fc ff ff       	call   800d3c <sys_page_map>
		if (r < 0)
  8010bf:	83 c4 20             	add    $0x20,%esp
  8010c2:	85 c0                	test   %eax,%eax
  8010c4:	0f 88 a5 00 00 00    	js     80116f <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  8010ca:	83 ec 0c             	sub    $0xc,%esp
  8010cd:	68 05 08 00 00       	push   $0x805
  8010d2:	53                   	push   %ebx
  8010d3:	6a 00                	push   $0x0
  8010d5:	53                   	push   %ebx
  8010d6:	6a 00                	push   $0x0
  8010d8:	e8 5f fc ff ff       	call   800d3c <sys_page_map>
  8010dd:	83 c4 20             	add    $0x20,%esp
  8010e0:	85 c0                	test   %eax,%eax
  8010e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010e7:	0f 4f c1             	cmovg  %ecx,%eax
  8010ea:	eb 1c                	jmp    801108 <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  8010ec:	83 ec 0c             	sub    $0xc,%esp
  8010ef:	6a 05                	push   $0x5
  8010f1:	53                   	push   %ebx
  8010f2:	57                   	push   %edi
  8010f3:	53                   	push   %ebx
  8010f4:	6a 00                	push   $0x0
  8010f6:	e8 41 fc ff ff       	call   800d3c <sys_page_map>
  8010fb:	83 c4 20             	add    $0x20,%esp
  8010fe:	85 c0                	test   %eax,%eax
  801100:	b9 00 00 00 00       	mov    $0x0,%ecx
  801105:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  801108:	85 c0                	test   %eax,%eax
  80110a:	78 67                	js     801173 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  80110c:	83 c6 01             	add    $0x1,%esi
  80110f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801115:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  80111b:	0f 85 1a ff ff ff    	jne    80103b <fork+0x59>
  801121:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  801124:	83 ec 04             	sub    $0x4,%esp
  801127:	6a 07                	push   $0x7
  801129:	68 00 f0 bf ee       	push   $0xeebff000
  80112e:	57                   	push   %edi
  80112f:	e8 c5 fb ff ff       	call   800cf9 <sys_page_alloc>
	if (r < 0)
  801134:	83 c4 10             	add    $0x10,%esp
		return r;
  801137:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  801139:	85 c0                	test   %eax,%eax
  80113b:	78 38                	js     801175 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80113d:	83 ec 08             	sub    $0x8,%esp
  801140:	68 24 23 80 00       	push   $0x802324
  801145:	57                   	push   %edi
  801146:	e8 f9 fc ff ff       	call   800e44 <sys_env_set_pgfault_upcall>
	if (r < 0)
  80114b:	83 c4 10             	add    $0x10,%esp
		return r;
  80114e:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  801150:	85 c0                	test   %eax,%eax
  801152:	78 21                	js     801175 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801154:	83 ec 08             	sub    $0x8,%esp
  801157:	6a 02                	push   $0x2
  801159:	57                   	push   %edi
  80115a:	e8 61 fc ff ff       	call   800dc0 <sys_env_set_status>
	if (r < 0)
  80115f:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801162:	85 c0                	test   %eax,%eax
  801164:	0f 48 f8             	cmovs  %eax,%edi
  801167:	89 fa                	mov    %edi,%edx
  801169:	eb 0a                	jmp    801175 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  80116b:	89 c2                	mov    %eax,%edx
  80116d:	eb 06                	jmp    801175 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  80116f:	89 c2                	mov    %eax,%edx
  801171:	eb 02                	jmp    801175 <fork+0x193>
  801173:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  801175:	89 d0                	mov    %edx,%eax
  801177:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117a:	5b                   	pop    %ebx
  80117b:	5e                   	pop    %esi
  80117c:	5f                   	pop    %edi
  80117d:	5d                   	pop    %ebp
  80117e:	c3                   	ret    

0080117f <sfork>:

// Challenge!
int
sfork(void)
{
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801185:	68 cb 2b 80 00       	push   $0x802bcb
  80118a:	68 c9 00 00 00       	push   $0xc9
  80118f:	68 c0 2b 80 00       	push   $0x802bc0
  801194:	e8 ff f0 ff ff       	call   800298 <_panic>

00801199 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801199:	55                   	push   %ebp
  80119a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80119c:	8b 45 08             	mov    0x8(%ebp),%eax
  80119f:	05 00 00 00 30       	add    $0x30000000,%eax
  8011a4:	c1 e8 0c             	shr    $0xc,%eax
}
  8011a7:	5d                   	pop    %ebp
  8011a8:	c3                   	ret    

008011a9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011a9:	55                   	push   %ebp
  8011aa:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8011af:	05 00 00 00 30       	add    $0x30000000,%eax
  8011b4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011b9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011be:	5d                   	pop    %ebp
  8011bf:	c3                   	ret    

008011c0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011c6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011cb:	89 c2                	mov    %eax,%edx
  8011cd:	c1 ea 16             	shr    $0x16,%edx
  8011d0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011d7:	f6 c2 01             	test   $0x1,%dl
  8011da:	74 11                	je     8011ed <fd_alloc+0x2d>
  8011dc:	89 c2                	mov    %eax,%edx
  8011de:	c1 ea 0c             	shr    $0xc,%edx
  8011e1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011e8:	f6 c2 01             	test   $0x1,%dl
  8011eb:	75 09                	jne    8011f6 <fd_alloc+0x36>
			*fd_store = fd;
  8011ed:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f4:	eb 17                	jmp    80120d <fd_alloc+0x4d>
  8011f6:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011fb:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801200:	75 c9                	jne    8011cb <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801202:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801208:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80120d:	5d                   	pop    %ebp
  80120e:	c3                   	ret    

0080120f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80120f:	55                   	push   %ebp
  801210:	89 e5                	mov    %esp,%ebp
  801212:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801215:	83 f8 1f             	cmp    $0x1f,%eax
  801218:	77 36                	ja     801250 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80121a:	c1 e0 0c             	shl    $0xc,%eax
  80121d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801222:	89 c2                	mov    %eax,%edx
  801224:	c1 ea 16             	shr    $0x16,%edx
  801227:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80122e:	f6 c2 01             	test   $0x1,%dl
  801231:	74 24                	je     801257 <fd_lookup+0x48>
  801233:	89 c2                	mov    %eax,%edx
  801235:	c1 ea 0c             	shr    $0xc,%edx
  801238:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80123f:	f6 c2 01             	test   $0x1,%dl
  801242:	74 1a                	je     80125e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801244:	8b 55 0c             	mov    0xc(%ebp),%edx
  801247:	89 02                	mov    %eax,(%edx)
	return 0;
  801249:	b8 00 00 00 00       	mov    $0x0,%eax
  80124e:	eb 13                	jmp    801263 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801250:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801255:	eb 0c                	jmp    801263 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801257:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80125c:	eb 05                	jmp    801263 <fd_lookup+0x54>
  80125e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801263:	5d                   	pop    %ebp
  801264:	c3                   	ret    

00801265 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801265:	55                   	push   %ebp
  801266:	89 e5                	mov    %esp,%ebp
  801268:	83 ec 08             	sub    $0x8,%esp
  80126b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80126e:	ba 64 2c 80 00       	mov    $0x802c64,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801273:	eb 13                	jmp    801288 <dev_lookup+0x23>
  801275:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801278:	39 08                	cmp    %ecx,(%eax)
  80127a:	75 0c                	jne    801288 <dev_lookup+0x23>
			*dev = devtab[i];
  80127c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80127f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801281:	b8 00 00 00 00       	mov    $0x0,%eax
  801286:	eb 2e                	jmp    8012b6 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801288:	8b 02                	mov    (%edx),%eax
  80128a:	85 c0                	test   %eax,%eax
  80128c:	75 e7                	jne    801275 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80128e:	a1 08 40 80 00       	mov    0x804008,%eax
  801293:	8b 40 48             	mov    0x48(%eax),%eax
  801296:	83 ec 04             	sub    $0x4,%esp
  801299:	51                   	push   %ecx
  80129a:	50                   	push   %eax
  80129b:	68 e4 2b 80 00       	push   $0x802be4
  8012a0:	e8 cc f0 ff ff       	call   800371 <cprintf>
	*dev = 0;
  8012a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012a8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012ae:	83 c4 10             	add    $0x10,%esp
  8012b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012b6:	c9                   	leave  
  8012b7:	c3                   	ret    

008012b8 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
  8012bb:	56                   	push   %esi
  8012bc:	53                   	push   %ebx
  8012bd:	83 ec 10             	sub    $0x10,%esp
  8012c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8012c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c9:	50                   	push   %eax
  8012ca:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012d0:	c1 e8 0c             	shr    $0xc,%eax
  8012d3:	50                   	push   %eax
  8012d4:	e8 36 ff ff ff       	call   80120f <fd_lookup>
  8012d9:	83 c4 08             	add    $0x8,%esp
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	78 05                	js     8012e5 <fd_close+0x2d>
	    || fd != fd2)
  8012e0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012e3:	74 0c                	je     8012f1 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012e5:	84 db                	test   %bl,%bl
  8012e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ec:	0f 44 c2             	cmove  %edx,%eax
  8012ef:	eb 41                	jmp    801332 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012f1:	83 ec 08             	sub    $0x8,%esp
  8012f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f7:	50                   	push   %eax
  8012f8:	ff 36                	pushl  (%esi)
  8012fa:	e8 66 ff ff ff       	call   801265 <dev_lookup>
  8012ff:	89 c3                	mov    %eax,%ebx
  801301:	83 c4 10             	add    $0x10,%esp
  801304:	85 c0                	test   %eax,%eax
  801306:	78 1a                	js     801322 <fd_close+0x6a>
		if (dev->dev_close)
  801308:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80130e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801313:	85 c0                	test   %eax,%eax
  801315:	74 0b                	je     801322 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801317:	83 ec 0c             	sub    $0xc,%esp
  80131a:	56                   	push   %esi
  80131b:	ff d0                	call   *%eax
  80131d:	89 c3                	mov    %eax,%ebx
  80131f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801322:	83 ec 08             	sub    $0x8,%esp
  801325:	56                   	push   %esi
  801326:	6a 00                	push   $0x0
  801328:	e8 51 fa ff ff       	call   800d7e <sys_page_unmap>
	return r;
  80132d:	83 c4 10             	add    $0x10,%esp
  801330:	89 d8                	mov    %ebx,%eax
}
  801332:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801335:	5b                   	pop    %ebx
  801336:	5e                   	pop    %esi
  801337:	5d                   	pop    %ebp
  801338:	c3                   	ret    

00801339 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801339:	55                   	push   %ebp
  80133a:	89 e5                	mov    %esp,%ebp
  80133c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80133f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801342:	50                   	push   %eax
  801343:	ff 75 08             	pushl  0x8(%ebp)
  801346:	e8 c4 fe ff ff       	call   80120f <fd_lookup>
  80134b:	83 c4 08             	add    $0x8,%esp
  80134e:	85 c0                	test   %eax,%eax
  801350:	78 10                	js     801362 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801352:	83 ec 08             	sub    $0x8,%esp
  801355:	6a 01                	push   $0x1
  801357:	ff 75 f4             	pushl  -0xc(%ebp)
  80135a:	e8 59 ff ff ff       	call   8012b8 <fd_close>
  80135f:	83 c4 10             	add    $0x10,%esp
}
  801362:	c9                   	leave  
  801363:	c3                   	ret    

00801364 <close_all>:

void
close_all(void)
{
  801364:	55                   	push   %ebp
  801365:	89 e5                	mov    %esp,%ebp
  801367:	53                   	push   %ebx
  801368:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80136b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801370:	83 ec 0c             	sub    $0xc,%esp
  801373:	53                   	push   %ebx
  801374:	e8 c0 ff ff ff       	call   801339 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801379:	83 c3 01             	add    $0x1,%ebx
  80137c:	83 c4 10             	add    $0x10,%esp
  80137f:	83 fb 20             	cmp    $0x20,%ebx
  801382:	75 ec                	jne    801370 <close_all+0xc>
		close(i);
}
  801384:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801387:	c9                   	leave  
  801388:	c3                   	ret    

00801389 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801389:	55                   	push   %ebp
  80138a:	89 e5                	mov    %esp,%ebp
  80138c:	57                   	push   %edi
  80138d:	56                   	push   %esi
  80138e:	53                   	push   %ebx
  80138f:	83 ec 2c             	sub    $0x2c,%esp
  801392:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801395:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801398:	50                   	push   %eax
  801399:	ff 75 08             	pushl  0x8(%ebp)
  80139c:	e8 6e fe ff ff       	call   80120f <fd_lookup>
  8013a1:	83 c4 08             	add    $0x8,%esp
  8013a4:	85 c0                	test   %eax,%eax
  8013a6:	0f 88 c1 00 00 00    	js     80146d <dup+0xe4>
		return r;
	close(newfdnum);
  8013ac:	83 ec 0c             	sub    $0xc,%esp
  8013af:	56                   	push   %esi
  8013b0:	e8 84 ff ff ff       	call   801339 <close>

	newfd = INDEX2FD(newfdnum);
  8013b5:	89 f3                	mov    %esi,%ebx
  8013b7:	c1 e3 0c             	shl    $0xc,%ebx
  8013ba:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013c0:	83 c4 04             	add    $0x4,%esp
  8013c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013c6:	e8 de fd ff ff       	call   8011a9 <fd2data>
  8013cb:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013cd:	89 1c 24             	mov    %ebx,(%esp)
  8013d0:	e8 d4 fd ff ff       	call   8011a9 <fd2data>
  8013d5:	83 c4 10             	add    $0x10,%esp
  8013d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013db:	89 f8                	mov    %edi,%eax
  8013dd:	c1 e8 16             	shr    $0x16,%eax
  8013e0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013e7:	a8 01                	test   $0x1,%al
  8013e9:	74 37                	je     801422 <dup+0x99>
  8013eb:	89 f8                	mov    %edi,%eax
  8013ed:	c1 e8 0c             	shr    $0xc,%eax
  8013f0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013f7:	f6 c2 01             	test   $0x1,%dl
  8013fa:	74 26                	je     801422 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013fc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801403:	83 ec 0c             	sub    $0xc,%esp
  801406:	25 07 0e 00 00       	and    $0xe07,%eax
  80140b:	50                   	push   %eax
  80140c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80140f:	6a 00                	push   $0x0
  801411:	57                   	push   %edi
  801412:	6a 00                	push   $0x0
  801414:	e8 23 f9 ff ff       	call   800d3c <sys_page_map>
  801419:	89 c7                	mov    %eax,%edi
  80141b:	83 c4 20             	add    $0x20,%esp
  80141e:	85 c0                	test   %eax,%eax
  801420:	78 2e                	js     801450 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801422:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801425:	89 d0                	mov    %edx,%eax
  801427:	c1 e8 0c             	shr    $0xc,%eax
  80142a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801431:	83 ec 0c             	sub    $0xc,%esp
  801434:	25 07 0e 00 00       	and    $0xe07,%eax
  801439:	50                   	push   %eax
  80143a:	53                   	push   %ebx
  80143b:	6a 00                	push   $0x0
  80143d:	52                   	push   %edx
  80143e:	6a 00                	push   $0x0
  801440:	e8 f7 f8 ff ff       	call   800d3c <sys_page_map>
  801445:	89 c7                	mov    %eax,%edi
  801447:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80144a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80144c:	85 ff                	test   %edi,%edi
  80144e:	79 1d                	jns    80146d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801450:	83 ec 08             	sub    $0x8,%esp
  801453:	53                   	push   %ebx
  801454:	6a 00                	push   $0x0
  801456:	e8 23 f9 ff ff       	call   800d7e <sys_page_unmap>
	sys_page_unmap(0, nva);
  80145b:	83 c4 08             	add    $0x8,%esp
  80145e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801461:	6a 00                	push   $0x0
  801463:	e8 16 f9 ff ff       	call   800d7e <sys_page_unmap>
	return r;
  801468:	83 c4 10             	add    $0x10,%esp
  80146b:	89 f8                	mov    %edi,%eax
}
  80146d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801470:	5b                   	pop    %ebx
  801471:	5e                   	pop    %esi
  801472:	5f                   	pop    %edi
  801473:	5d                   	pop    %ebp
  801474:	c3                   	ret    

00801475 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801475:	55                   	push   %ebp
  801476:	89 e5                	mov    %esp,%ebp
  801478:	53                   	push   %ebx
  801479:	83 ec 14             	sub    $0x14,%esp
  80147c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80147f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801482:	50                   	push   %eax
  801483:	53                   	push   %ebx
  801484:	e8 86 fd ff ff       	call   80120f <fd_lookup>
  801489:	83 c4 08             	add    $0x8,%esp
  80148c:	89 c2                	mov    %eax,%edx
  80148e:	85 c0                	test   %eax,%eax
  801490:	78 6d                	js     8014ff <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801492:	83 ec 08             	sub    $0x8,%esp
  801495:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801498:	50                   	push   %eax
  801499:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149c:	ff 30                	pushl  (%eax)
  80149e:	e8 c2 fd ff ff       	call   801265 <dev_lookup>
  8014a3:	83 c4 10             	add    $0x10,%esp
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	78 4c                	js     8014f6 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014aa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014ad:	8b 42 08             	mov    0x8(%edx),%eax
  8014b0:	83 e0 03             	and    $0x3,%eax
  8014b3:	83 f8 01             	cmp    $0x1,%eax
  8014b6:	75 21                	jne    8014d9 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014b8:	a1 08 40 80 00       	mov    0x804008,%eax
  8014bd:	8b 40 48             	mov    0x48(%eax),%eax
  8014c0:	83 ec 04             	sub    $0x4,%esp
  8014c3:	53                   	push   %ebx
  8014c4:	50                   	push   %eax
  8014c5:	68 28 2c 80 00       	push   $0x802c28
  8014ca:	e8 a2 ee ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  8014cf:	83 c4 10             	add    $0x10,%esp
  8014d2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014d7:	eb 26                	jmp    8014ff <read+0x8a>
	}
	if (!dev->dev_read)
  8014d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014dc:	8b 40 08             	mov    0x8(%eax),%eax
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	74 17                	je     8014fa <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014e3:	83 ec 04             	sub    $0x4,%esp
  8014e6:	ff 75 10             	pushl  0x10(%ebp)
  8014e9:	ff 75 0c             	pushl  0xc(%ebp)
  8014ec:	52                   	push   %edx
  8014ed:	ff d0                	call   *%eax
  8014ef:	89 c2                	mov    %eax,%edx
  8014f1:	83 c4 10             	add    $0x10,%esp
  8014f4:	eb 09                	jmp    8014ff <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f6:	89 c2                	mov    %eax,%edx
  8014f8:	eb 05                	jmp    8014ff <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014fa:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014ff:	89 d0                	mov    %edx,%eax
  801501:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801504:	c9                   	leave  
  801505:	c3                   	ret    

00801506 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801506:	55                   	push   %ebp
  801507:	89 e5                	mov    %esp,%ebp
  801509:	57                   	push   %edi
  80150a:	56                   	push   %esi
  80150b:	53                   	push   %ebx
  80150c:	83 ec 0c             	sub    $0xc,%esp
  80150f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801512:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801515:	bb 00 00 00 00       	mov    $0x0,%ebx
  80151a:	eb 21                	jmp    80153d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80151c:	83 ec 04             	sub    $0x4,%esp
  80151f:	89 f0                	mov    %esi,%eax
  801521:	29 d8                	sub    %ebx,%eax
  801523:	50                   	push   %eax
  801524:	89 d8                	mov    %ebx,%eax
  801526:	03 45 0c             	add    0xc(%ebp),%eax
  801529:	50                   	push   %eax
  80152a:	57                   	push   %edi
  80152b:	e8 45 ff ff ff       	call   801475 <read>
		if (m < 0)
  801530:	83 c4 10             	add    $0x10,%esp
  801533:	85 c0                	test   %eax,%eax
  801535:	78 10                	js     801547 <readn+0x41>
			return m;
		if (m == 0)
  801537:	85 c0                	test   %eax,%eax
  801539:	74 0a                	je     801545 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80153b:	01 c3                	add    %eax,%ebx
  80153d:	39 f3                	cmp    %esi,%ebx
  80153f:	72 db                	jb     80151c <readn+0x16>
  801541:	89 d8                	mov    %ebx,%eax
  801543:	eb 02                	jmp    801547 <readn+0x41>
  801545:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801547:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80154a:	5b                   	pop    %ebx
  80154b:	5e                   	pop    %esi
  80154c:	5f                   	pop    %edi
  80154d:	5d                   	pop    %ebp
  80154e:	c3                   	ret    

0080154f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80154f:	55                   	push   %ebp
  801550:	89 e5                	mov    %esp,%ebp
  801552:	53                   	push   %ebx
  801553:	83 ec 14             	sub    $0x14,%esp
  801556:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801559:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80155c:	50                   	push   %eax
  80155d:	53                   	push   %ebx
  80155e:	e8 ac fc ff ff       	call   80120f <fd_lookup>
  801563:	83 c4 08             	add    $0x8,%esp
  801566:	89 c2                	mov    %eax,%edx
  801568:	85 c0                	test   %eax,%eax
  80156a:	78 68                	js     8015d4 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156c:	83 ec 08             	sub    $0x8,%esp
  80156f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801572:	50                   	push   %eax
  801573:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801576:	ff 30                	pushl  (%eax)
  801578:	e8 e8 fc ff ff       	call   801265 <dev_lookup>
  80157d:	83 c4 10             	add    $0x10,%esp
  801580:	85 c0                	test   %eax,%eax
  801582:	78 47                	js     8015cb <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801584:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801587:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80158b:	75 21                	jne    8015ae <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80158d:	a1 08 40 80 00       	mov    0x804008,%eax
  801592:	8b 40 48             	mov    0x48(%eax),%eax
  801595:	83 ec 04             	sub    $0x4,%esp
  801598:	53                   	push   %ebx
  801599:	50                   	push   %eax
  80159a:	68 44 2c 80 00       	push   $0x802c44
  80159f:	e8 cd ed ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  8015a4:	83 c4 10             	add    $0x10,%esp
  8015a7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015ac:	eb 26                	jmp    8015d4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b1:	8b 52 0c             	mov    0xc(%edx),%edx
  8015b4:	85 d2                	test   %edx,%edx
  8015b6:	74 17                	je     8015cf <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015b8:	83 ec 04             	sub    $0x4,%esp
  8015bb:	ff 75 10             	pushl  0x10(%ebp)
  8015be:	ff 75 0c             	pushl  0xc(%ebp)
  8015c1:	50                   	push   %eax
  8015c2:	ff d2                	call   *%edx
  8015c4:	89 c2                	mov    %eax,%edx
  8015c6:	83 c4 10             	add    $0x10,%esp
  8015c9:	eb 09                	jmp    8015d4 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015cb:	89 c2                	mov    %eax,%edx
  8015cd:	eb 05                	jmp    8015d4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015cf:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015d4:	89 d0                	mov    %edx,%eax
  8015d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d9:	c9                   	leave  
  8015da:	c3                   	ret    

008015db <seek>:

int
seek(int fdnum, off_t offset)
{
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015e1:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015e4:	50                   	push   %eax
  8015e5:	ff 75 08             	pushl  0x8(%ebp)
  8015e8:	e8 22 fc ff ff       	call   80120f <fd_lookup>
  8015ed:	83 c4 08             	add    $0x8,%esp
  8015f0:	85 c0                	test   %eax,%eax
  8015f2:	78 0e                	js     801602 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015fa:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801602:	c9                   	leave  
  801603:	c3                   	ret    

00801604 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
  801607:	53                   	push   %ebx
  801608:	83 ec 14             	sub    $0x14,%esp
  80160b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80160e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801611:	50                   	push   %eax
  801612:	53                   	push   %ebx
  801613:	e8 f7 fb ff ff       	call   80120f <fd_lookup>
  801618:	83 c4 08             	add    $0x8,%esp
  80161b:	89 c2                	mov    %eax,%edx
  80161d:	85 c0                	test   %eax,%eax
  80161f:	78 65                	js     801686 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801621:	83 ec 08             	sub    $0x8,%esp
  801624:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801627:	50                   	push   %eax
  801628:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162b:	ff 30                	pushl  (%eax)
  80162d:	e8 33 fc ff ff       	call   801265 <dev_lookup>
  801632:	83 c4 10             	add    $0x10,%esp
  801635:	85 c0                	test   %eax,%eax
  801637:	78 44                	js     80167d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801639:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801640:	75 21                	jne    801663 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801642:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801647:	8b 40 48             	mov    0x48(%eax),%eax
  80164a:	83 ec 04             	sub    $0x4,%esp
  80164d:	53                   	push   %ebx
  80164e:	50                   	push   %eax
  80164f:	68 04 2c 80 00       	push   $0x802c04
  801654:	e8 18 ed ff ff       	call   800371 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801659:	83 c4 10             	add    $0x10,%esp
  80165c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801661:	eb 23                	jmp    801686 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801663:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801666:	8b 52 18             	mov    0x18(%edx),%edx
  801669:	85 d2                	test   %edx,%edx
  80166b:	74 14                	je     801681 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80166d:	83 ec 08             	sub    $0x8,%esp
  801670:	ff 75 0c             	pushl  0xc(%ebp)
  801673:	50                   	push   %eax
  801674:	ff d2                	call   *%edx
  801676:	89 c2                	mov    %eax,%edx
  801678:	83 c4 10             	add    $0x10,%esp
  80167b:	eb 09                	jmp    801686 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167d:	89 c2                	mov    %eax,%edx
  80167f:	eb 05                	jmp    801686 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801681:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801686:	89 d0                	mov    %edx,%eax
  801688:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80168b:	c9                   	leave  
  80168c:	c3                   	ret    

0080168d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80168d:	55                   	push   %ebp
  80168e:	89 e5                	mov    %esp,%ebp
  801690:	53                   	push   %ebx
  801691:	83 ec 14             	sub    $0x14,%esp
  801694:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801697:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80169a:	50                   	push   %eax
  80169b:	ff 75 08             	pushl  0x8(%ebp)
  80169e:	e8 6c fb ff ff       	call   80120f <fd_lookup>
  8016a3:	83 c4 08             	add    $0x8,%esp
  8016a6:	89 c2                	mov    %eax,%edx
  8016a8:	85 c0                	test   %eax,%eax
  8016aa:	78 58                	js     801704 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ac:	83 ec 08             	sub    $0x8,%esp
  8016af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b2:	50                   	push   %eax
  8016b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b6:	ff 30                	pushl  (%eax)
  8016b8:	e8 a8 fb ff ff       	call   801265 <dev_lookup>
  8016bd:	83 c4 10             	add    $0x10,%esp
  8016c0:	85 c0                	test   %eax,%eax
  8016c2:	78 37                	js     8016fb <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016cb:	74 32                	je     8016ff <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016cd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016d0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016d7:	00 00 00 
	stat->st_isdir = 0;
  8016da:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016e1:	00 00 00 
	stat->st_dev = dev;
  8016e4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016ea:	83 ec 08             	sub    $0x8,%esp
  8016ed:	53                   	push   %ebx
  8016ee:	ff 75 f0             	pushl  -0x10(%ebp)
  8016f1:	ff 50 14             	call   *0x14(%eax)
  8016f4:	89 c2                	mov    %eax,%edx
  8016f6:	83 c4 10             	add    $0x10,%esp
  8016f9:	eb 09                	jmp    801704 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fb:	89 c2                	mov    %eax,%edx
  8016fd:	eb 05                	jmp    801704 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016ff:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801704:	89 d0                	mov    %edx,%eax
  801706:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801709:	c9                   	leave  
  80170a:	c3                   	ret    

0080170b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80170b:	55                   	push   %ebp
  80170c:	89 e5                	mov    %esp,%ebp
  80170e:	56                   	push   %esi
  80170f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801710:	83 ec 08             	sub    $0x8,%esp
  801713:	6a 00                	push   $0x0
  801715:	ff 75 08             	pushl  0x8(%ebp)
  801718:	e8 d6 01 00 00       	call   8018f3 <open>
  80171d:	89 c3                	mov    %eax,%ebx
  80171f:	83 c4 10             	add    $0x10,%esp
  801722:	85 c0                	test   %eax,%eax
  801724:	78 1b                	js     801741 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801726:	83 ec 08             	sub    $0x8,%esp
  801729:	ff 75 0c             	pushl  0xc(%ebp)
  80172c:	50                   	push   %eax
  80172d:	e8 5b ff ff ff       	call   80168d <fstat>
  801732:	89 c6                	mov    %eax,%esi
	close(fd);
  801734:	89 1c 24             	mov    %ebx,(%esp)
  801737:	e8 fd fb ff ff       	call   801339 <close>
	return r;
  80173c:	83 c4 10             	add    $0x10,%esp
  80173f:	89 f0                	mov    %esi,%eax
}
  801741:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801744:	5b                   	pop    %ebx
  801745:	5e                   	pop    %esi
  801746:	5d                   	pop    %ebp
  801747:	c3                   	ret    

00801748 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801748:	55                   	push   %ebp
  801749:	89 e5                	mov    %esp,%ebp
  80174b:	56                   	push   %esi
  80174c:	53                   	push   %ebx
  80174d:	89 c6                	mov    %eax,%esi
  80174f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801751:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801758:	75 12                	jne    80176c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80175a:	83 ec 0c             	sub    $0xc,%esp
  80175d:	6a 01                	push   $0x1
  80175f:	e8 9f 0c 00 00       	call   802403 <ipc_find_env>
  801764:	a3 00 40 80 00       	mov    %eax,0x804000
  801769:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80176c:	6a 07                	push   $0x7
  80176e:	68 00 50 80 00       	push   $0x805000
  801773:	56                   	push   %esi
  801774:	ff 35 00 40 80 00    	pushl  0x804000
  80177a:	e8 30 0c 00 00       	call   8023af <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80177f:	83 c4 0c             	add    $0xc,%esp
  801782:	6a 00                	push   $0x0
  801784:	53                   	push   %ebx
  801785:	6a 00                	push   $0x0
  801787:	e8 bc 0b 00 00       	call   802348 <ipc_recv>
}
  80178c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80178f:	5b                   	pop    %ebx
  801790:	5e                   	pop    %esi
  801791:	5d                   	pop    %ebp
  801792:	c3                   	ret    

00801793 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801799:	8b 45 08             	mov    0x8(%ebp),%eax
  80179c:	8b 40 0c             	mov    0xc(%eax),%eax
  80179f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a7:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b1:	b8 02 00 00 00       	mov    $0x2,%eax
  8017b6:	e8 8d ff ff ff       	call   801748 <fsipc>
}
  8017bb:	c9                   	leave  
  8017bc:	c3                   	ret    

008017bd <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c9:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d3:	b8 06 00 00 00       	mov    $0x6,%eax
  8017d8:	e8 6b ff ff ff       	call   801748 <fsipc>
}
  8017dd:	c9                   	leave  
  8017de:	c3                   	ret    

008017df <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017df:	55                   	push   %ebp
  8017e0:	89 e5                	mov    %esp,%ebp
  8017e2:	53                   	push   %ebx
  8017e3:	83 ec 04             	sub    $0x4,%esp
  8017e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ec:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ef:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f9:	b8 05 00 00 00       	mov    $0x5,%eax
  8017fe:	e8 45 ff ff ff       	call   801748 <fsipc>
  801803:	85 c0                	test   %eax,%eax
  801805:	78 2c                	js     801833 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801807:	83 ec 08             	sub    $0x8,%esp
  80180a:	68 00 50 80 00       	push   $0x805000
  80180f:	53                   	push   %ebx
  801810:	e8 e1 f0 ff ff       	call   8008f6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801815:	a1 80 50 80 00       	mov    0x805080,%eax
  80181a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801820:	a1 84 50 80 00       	mov    0x805084,%eax
  801825:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80182b:	83 c4 10             	add    $0x10,%esp
  80182e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801833:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801836:	c9                   	leave  
  801837:	c3                   	ret    

00801838 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801838:	55                   	push   %ebp
  801839:	89 e5                	mov    %esp,%ebp
  80183b:	83 ec 0c             	sub    $0xc,%esp
  80183e:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801841:	8b 55 08             	mov    0x8(%ebp),%edx
  801844:	8b 52 0c             	mov    0xc(%edx),%edx
  801847:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80184d:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801852:	50                   	push   %eax
  801853:	ff 75 0c             	pushl  0xc(%ebp)
  801856:	68 08 50 80 00       	push   $0x805008
  80185b:	e8 28 f2 ff ff       	call   800a88 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801860:	ba 00 00 00 00       	mov    $0x0,%edx
  801865:	b8 04 00 00 00       	mov    $0x4,%eax
  80186a:	e8 d9 fe ff ff       	call   801748 <fsipc>

}
  80186f:	c9                   	leave  
  801870:	c3                   	ret    

00801871 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801871:	55                   	push   %ebp
  801872:	89 e5                	mov    %esp,%ebp
  801874:	56                   	push   %esi
  801875:	53                   	push   %ebx
  801876:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801879:	8b 45 08             	mov    0x8(%ebp),%eax
  80187c:	8b 40 0c             	mov    0xc(%eax),%eax
  80187f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801884:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80188a:	ba 00 00 00 00       	mov    $0x0,%edx
  80188f:	b8 03 00 00 00       	mov    $0x3,%eax
  801894:	e8 af fe ff ff       	call   801748 <fsipc>
  801899:	89 c3                	mov    %eax,%ebx
  80189b:	85 c0                	test   %eax,%eax
  80189d:	78 4b                	js     8018ea <devfile_read+0x79>
		return r;
	assert(r <= n);
  80189f:	39 c6                	cmp    %eax,%esi
  8018a1:	73 16                	jae    8018b9 <devfile_read+0x48>
  8018a3:	68 78 2c 80 00       	push   $0x802c78
  8018a8:	68 7f 2c 80 00       	push   $0x802c7f
  8018ad:	6a 7c                	push   $0x7c
  8018af:	68 94 2c 80 00       	push   $0x802c94
  8018b4:	e8 df e9 ff ff       	call   800298 <_panic>
	assert(r <= PGSIZE);
  8018b9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018be:	7e 16                	jle    8018d6 <devfile_read+0x65>
  8018c0:	68 9f 2c 80 00       	push   $0x802c9f
  8018c5:	68 7f 2c 80 00       	push   $0x802c7f
  8018ca:	6a 7d                	push   $0x7d
  8018cc:	68 94 2c 80 00       	push   $0x802c94
  8018d1:	e8 c2 e9 ff ff       	call   800298 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018d6:	83 ec 04             	sub    $0x4,%esp
  8018d9:	50                   	push   %eax
  8018da:	68 00 50 80 00       	push   $0x805000
  8018df:	ff 75 0c             	pushl  0xc(%ebp)
  8018e2:	e8 a1 f1 ff ff       	call   800a88 <memmove>
	return r;
  8018e7:	83 c4 10             	add    $0x10,%esp
}
  8018ea:	89 d8                	mov    %ebx,%eax
  8018ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ef:	5b                   	pop    %ebx
  8018f0:	5e                   	pop    %esi
  8018f1:	5d                   	pop    %ebp
  8018f2:	c3                   	ret    

008018f3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018f3:	55                   	push   %ebp
  8018f4:	89 e5                	mov    %esp,%ebp
  8018f6:	53                   	push   %ebx
  8018f7:	83 ec 20             	sub    $0x20,%esp
  8018fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018fd:	53                   	push   %ebx
  8018fe:	e8 ba ef ff ff       	call   8008bd <strlen>
  801903:	83 c4 10             	add    $0x10,%esp
  801906:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80190b:	7f 67                	jg     801974 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80190d:	83 ec 0c             	sub    $0xc,%esp
  801910:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801913:	50                   	push   %eax
  801914:	e8 a7 f8 ff ff       	call   8011c0 <fd_alloc>
  801919:	83 c4 10             	add    $0x10,%esp
		return r;
  80191c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80191e:	85 c0                	test   %eax,%eax
  801920:	78 57                	js     801979 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801922:	83 ec 08             	sub    $0x8,%esp
  801925:	53                   	push   %ebx
  801926:	68 00 50 80 00       	push   $0x805000
  80192b:	e8 c6 ef ff ff       	call   8008f6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801930:	8b 45 0c             	mov    0xc(%ebp),%eax
  801933:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801938:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80193b:	b8 01 00 00 00       	mov    $0x1,%eax
  801940:	e8 03 fe ff ff       	call   801748 <fsipc>
  801945:	89 c3                	mov    %eax,%ebx
  801947:	83 c4 10             	add    $0x10,%esp
  80194a:	85 c0                	test   %eax,%eax
  80194c:	79 14                	jns    801962 <open+0x6f>
		fd_close(fd, 0);
  80194e:	83 ec 08             	sub    $0x8,%esp
  801951:	6a 00                	push   $0x0
  801953:	ff 75 f4             	pushl  -0xc(%ebp)
  801956:	e8 5d f9 ff ff       	call   8012b8 <fd_close>
		return r;
  80195b:	83 c4 10             	add    $0x10,%esp
  80195e:	89 da                	mov    %ebx,%edx
  801960:	eb 17                	jmp    801979 <open+0x86>
	}

	return fd2num(fd);
  801962:	83 ec 0c             	sub    $0xc,%esp
  801965:	ff 75 f4             	pushl  -0xc(%ebp)
  801968:	e8 2c f8 ff ff       	call   801199 <fd2num>
  80196d:	89 c2                	mov    %eax,%edx
  80196f:	83 c4 10             	add    $0x10,%esp
  801972:	eb 05                	jmp    801979 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801974:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801979:	89 d0                	mov    %edx,%eax
  80197b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80197e:	c9                   	leave  
  80197f:	c3                   	ret    

00801980 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801986:	ba 00 00 00 00       	mov    $0x0,%edx
  80198b:	b8 08 00 00 00       	mov    $0x8,%eax
  801990:	e8 b3 fd ff ff       	call   801748 <fsipc>
}
  801995:	c9                   	leave  
  801996:	c3                   	ret    

00801997 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801997:	55                   	push   %ebp
  801998:	89 e5                	mov    %esp,%ebp
  80199a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80199d:	68 ab 2c 80 00       	push   $0x802cab
  8019a2:	ff 75 0c             	pushl  0xc(%ebp)
  8019a5:	e8 4c ef ff ff       	call   8008f6 <strcpy>
	return 0;
}
  8019aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8019af:	c9                   	leave  
  8019b0:	c3                   	ret    

008019b1 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8019b1:	55                   	push   %ebp
  8019b2:	89 e5                	mov    %esp,%ebp
  8019b4:	53                   	push   %ebx
  8019b5:	83 ec 10             	sub    $0x10,%esp
  8019b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019bb:	53                   	push   %ebx
  8019bc:	e8 7b 0a 00 00       	call   80243c <pageref>
  8019c1:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8019c4:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8019c9:	83 f8 01             	cmp    $0x1,%eax
  8019cc:	75 10                	jne    8019de <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8019ce:	83 ec 0c             	sub    $0xc,%esp
  8019d1:	ff 73 0c             	pushl  0xc(%ebx)
  8019d4:	e8 c0 02 00 00       	call   801c99 <nsipc_close>
  8019d9:	89 c2                	mov    %eax,%edx
  8019db:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8019de:	89 d0                	mov    %edx,%eax
  8019e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e3:	c9                   	leave  
  8019e4:	c3                   	ret    

008019e5 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8019e5:	55                   	push   %ebp
  8019e6:	89 e5                	mov    %esp,%ebp
  8019e8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019eb:	6a 00                	push   $0x0
  8019ed:	ff 75 10             	pushl  0x10(%ebp)
  8019f0:	ff 75 0c             	pushl  0xc(%ebp)
  8019f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f6:	ff 70 0c             	pushl  0xc(%eax)
  8019f9:	e8 78 03 00 00       	call   801d76 <nsipc_send>
}
  8019fe:	c9                   	leave  
  8019ff:	c3                   	ret    

00801a00 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a06:	6a 00                	push   $0x0
  801a08:	ff 75 10             	pushl  0x10(%ebp)
  801a0b:	ff 75 0c             	pushl  0xc(%ebp)
  801a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a11:	ff 70 0c             	pushl  0xc(%eax)
  801a14:	e8 f1 02 00 00       	call   801d0a <nsipc_recv>
}
  801a19:	c9                   	leave  
  801a1a:	c3                   	ret    

00801a1b <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a1b:	55                   	push   %ebp
  801a1c:	89 e5                	mov    %esp,%ebp
  801a1e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a21:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a24:	52                   	push   %edx
  801a25:	50                   	push   %eax
  801a26:	e8 e4 f7 ff ff       	call   80120f <fd_lookup>
  801a2b:	83 c4 10             	add    $0x10,%esp
  801a2e:	85 c0                	test   %eax,%eax
  801a30:	78 17                	js     801a49 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a35:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a3b:	39 08                	cmp    %ecx,(%eax)
  801a3d:	75 05                	jne    801a44 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a3f:	8b 40 0c             	mov    0xc(%eax),%eax
  801a42:	eb 05                	jmp    801a49 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a44:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a49:	c9                   	leave  
  801a4a:	c3                   	ret    

00801a4b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a4b:	55                   	push   %ebp
  801a4c:	89 e5                	mov    %esp,%ebp
  801a4e:	56                   	push   %esi
  801a4f:	53                   	push   %ebx
  801a50:	83 ec 1c             	sub    $0x1c,%esp
  801a53:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a55:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a58:	50                   	push   %eax
  801a59:	e8 62 f7 ff ff       	call   8011c0 <fd_alloc>
  801a5e:	89 c3                	mov    %eax,%ebx
  801a60:	83 c4 10             	add    $0x10,%esp
  801a63:	85 c0                	test   %eax,%eax
  801a65:	78 1b                	js     801a82 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a67:	83 ec 04             	sub    $0x4,%esp
  801a6a:	68 07 04 00 00       	push   $0x407
  801a6f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a72:	6a 00                	push   $0x0
  801a74:	e8 80 f2 ff ff       	call   800cf9 <sys_page_alloc>
  801a79:	89 c3                	mov    %eax,%ebx
  801a7b:	83 c4 10             	add    $0x10,%esp
  801a7e:	85 c0                	test   %eax,%eax
  801a80:	79 10                	jns    801a92 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801a82:	83 ec 0c             	sub    $0xc,%esp
  801a85:	56                   	push   %esi
  801a86:	e8 0e 02 00 00       	call   801c99 <nsipc_close>
		return r;
  801a8b:	83 c4 10             	add    $0x10,%esp
  801a8e:	89 d8                	mov    %ebx,%eax
  801a90:	eb 24                	jmp    801ab6 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a92:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a9b:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801aa7:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801aaa:	83 ec 0c             	sub    $0xc,%esp
  801aad:	50                   	push   %eax
  801aae:	e8 e6 f6 ff ff       	call   801199 <fd2num>
  801ab3:	83 c4 10             	add    $0x10,%esp
}
  801ab6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab9:	5b                   	pop    %ebx
  801aba:	5e                   	pop    %esi
  801abb:	5d                   	pop    %ebp
  801abc:	c3                   	ret    

00801abd <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801abd:	55                   	push   %ebp
  801abe:	89 e5                	mov    %esp,%ebp
  801ac0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ac3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac6:	e8 50 ff ff ff       	call   801a1b <fd2sockid>
		return r;
  801acb:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801acd:	85 c0                	test   %eax,%eax
  801acf:	78 1f                	js     801af0 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ad1:	83 ec 04             	sub    $0x4,%esp
  801ad4:	ff 75 10             	pushl  0x10(%ebp)
  801ad7:	ff 75 0c             	pushl  0xc(%ebp)
  801ada:	50                   	push   %eax
  801adb:	e8 12 01 00 00       	call   801bf2 <nsipc_accept>
  801ae0:	83 c4 10             	add    $0x10,%esp
		return r;
  801ae3:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	78 07                	js     801af0 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801ae9:	e8 5d ff ff ff       	call   801a4b <alloc_sockfd>
  801aee:	89 c1                	mov    %eax,%ecx
}
  801af0:	89 c8                	mov    %ecx,%eax
  801af2:	c9                   	leave  
  801af3:	c3                   	ret    

00801af4 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801af4:	55                   	push   %ebp
  801af5:	89 e5                	mov    %esp,%ebp
  801af7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801afa:	8b 45 08             	mov    0x8(%ebp),%eax
  801afd:	e8 19 ff ff ff       	call   801a1b <fd2sockid>
  801b02:	85 c0                	test   %eax,%eax
  801b04:	78 12                	js     801b18 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801b06:	83 ec 04             	sub    $0x4,%esp
  801b09:	ff 75 10             	pushl  0x10(%ebp)
  801b0c:	ff 75 0c             	pushl  0xc(%ebp)
  801b0f:	50                   	push   %eax
  801b10:	e8 2d 01 00 00       	call   801c42 <nsipc_bind>
  801b15:	83 c4 10             	add    $0x10,%esp
}
  801b18:	c9                   	leave  
  801b19:	c3                   	ret    

00801b1a <shutdown>:

int
shutdown(int s, int how)
{
  801b1a:	55                   	push   %ebp
  801b1b:	89 e5                	mov    %esp,%ebp
  801b1d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b20:	8b 45 08             	mov    0x8(%ebp),%eax
  801b23:	e8 f3 fe ff ff       	call   801a1b <fd2sockid>
  801b28:	85 c0                	test   %eax,%eax
  801b2a:	78 0f                	js     801b3b <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b2c:	83 ec 08             	sub    $0x8,%esp
  801b2f:	ff 75 0c             	pushl  0xc(%ebp)
  801b32:	50                   	push   %eax
  801b33:	e8 3f 01 00 00       	call   801c77 <nsipc_shutdown>
  801b38:	83 c4 10             	add    $0x10,%esp
}
  801b3b:	c9                   	leave  
  801b3c:	c3                   	ret    

00801b3d <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b43:	8b 45 08             	mov    0x8(%ebp),%eax
  801b46:	e8 d0 fe ff ff       	call   801a1b <fd2sockid>
  801b4b:	85 c0                	test   %eax,%eax
  801b4d:	78 12                	js     801b61 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b4f:	83 ec 04             	sub    $0x4,%esp
  801b52:	ff 75 10             	pushl  0x10(%ebp)
  801b55:	ff 75 0c             	pushl  0xc(%ebp)
  801b58:	50                   	push   %eax
  801b59:	e8 55 01 00 00       	call   801cb3 <nsipc_connect>
  801b5e:	83 c4 10             	add    $0x10,%esp
}
  801b61:	c9                   	leave  
  801b62:	c3                   	ret    

00801b63 <listen>:

int
listen(int s, int backlog)
{
  801b63:	55                   	push   %ebp
  801b64:	89 e5                	mov    %esp,%ebp
  801b66:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b69:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6c:	e8 aa fe ff ff       	call   801a1b <fd2sockid>
  801b71:	85 c0                	test   %eax,%eax
  801b73:	78 0f                	js     801b84 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b75:	83 ec 08             	sub    $0x8,%esp
  801b78:	ff 75 0c             	pushl  0xc(%ebp)
  801b7b:	50                   	push   %eax
  801b7c:	e8 67 01 00 00       	call   801ce8 <nsipc_listen>
  801b81:	83 c4 10             	add    $0x10,%esp
}
  801b84:	c9                   	leave  
  801b85:	c3                   	ret    

00801b86 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
  801b89:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b8c:	ff 75 10             	pushl  0x10(%ebp)
  801b8f:	ff 75 0c             	pushl  0xc(%ebp)
  801b92:	ff 75 08             	pushl  0x8(%ebp)
  801b95:	e8 3a 02 00 00       	call   801dd4 <nsipc_socket>
  801b9a:	83 c4 10             	add    $0x10,%esp
  801b9d:	85 c0                	test   %eax,%eax
  801b9f:	78 05                	js     801ba6 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801ba1:	e8 a5 fe ff ff       	call   801a4b <alloc_sockfd>
}
  801ba6:	c9                   	leave  
  801ba7:	c3                   	ret    

00801ba8 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ba8:	55                   	push   %ebp
  801ba9:	89 e5                	mov    %esp,%ebp
  801bab:	53                   	push   %ebx
  801bac:	83 ec 04             	sub    $0x4,%esp
  801baf:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801bb1:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801bb8:	75 12                	jne    801bcc <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801bba:	83 ec 0c             	sub    $0xc,%esp
  801bbd:	6a 02                	push   $0x2
  801bbf:	e8 3f 08 00 00       	call   802403 <ipc_find_env>
  801bc4:	a3 04 40 80 00       	mov    %eax,0x804004
  801bc9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bcc:	6a 07                	push   $0x7
  801bce:	68 00 60 80 00       	push   $0x806000
  801bd3:	53                   	push   %ebx
  801bd4:	ff 35 04 40 80 00    	pushl  0x804004
  801bda:	e8 d0 07 00 00       	call   8023af <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801bdf:	83 c4 0c             	add    $0xc,%esp
  801be2:	6a 00                	push   $0x0
  801be4:	6a 00                	push   $0x0
  801be6:	6a 00                	push   $0x0
  801be8:	e8 5b 07 00 00       	call   802348 <ipc_recv>
}
  801bed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf0:	c9                   	leave  
  801bf1:	c3                   	ret    

00801bf2 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bf2:	55                   	push   %ebp
  801bf3:	89 e5                	mov    %esp,%ebp
  801bf5:	56                   	push   %esi
  801bf6:	53                   	push   %ebx
  801bf7:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801bfa:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfd:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c02:	8b 06                	mov    (%esi),%eax
  801c04:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c09:	b8 01 00 00 00       	mov    $0x1,%eax
  801c0e:	e8 95 ff ff ff       	call   801ba8 <nsipc>
  801c13:	89 c3                	mov    %eax,%ebx
  801c15:	85 c0                	test   %eax,%eax
  801c17:	78 20                	js     801c39 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c19:	83 ec 04             	sub    $0x4,%esp
  801c1c:	ff 35 10 60 80 00    	pushl  0x806010
  801c22:	68 00 60 80 00       	push   $0x806000
  801c27:	ff 75 0c             	pushl  0xc(%ebp)
  801c2a:	e8 59 ee ff ff       	call   800a88 <memmove>
		*addrlen = ret->ret_addrlen;
  801c2f:	a1 10 60 80 00       	mov    0x806010,%eax
  801c34:	89 06                	mov    %eax,(%esi)
  801c36:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c39:	89 d8                	mov    %ebx,%eax
  801c3b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c3e:	5b                   	pop    %ebx
  801c3f:	5e                   	pop    %esi
  801c40:	5d                   	pop    %ebp
  801c41:	c3                   	ret    

00801c42 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	53                   	push   %ebx
  801c46:	83 ec 08             	sub    $0x8,%esp
  801c49:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4f:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c54:	53                   	push   %ebx
  801c55:	ff 75 0c             	pushl  0xc(%ebp)
  801c58:	68 04 60 80 00       	push   $0x806004
  801c5d:	e8 26 ee ff ff       	call   800a88 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c62:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c68:	b8 02 00 00 00       	mov    $0x2,%eax
  801c6d:	e8 36 ff ff ff       	call   801ba8 <nsipc>
}
  801c72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c75:	c9                   	leave  
  801c76:	c3                   	ret    

00801c77 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c80:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c85:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c88:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c8d:	b8 03 00 00 00       	mov    $0x3,%eax
  801c92:	e8 11 ff ff ff       	call   801ba8 <nsipc>
}
  801c97:	c9                   	leave  
  801c98:	c3                   	ret    

00801c99 <nsipc_close>:

int
nsipc_close(int s)
{
  801c99:	55                   	push   %ebp
  801c9a:	89 e5                	mov    %esp,%ebp
  801c9c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca2:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801ca7:	b8 04 00 00 00       	mov    $0x4,%eax
  801cac:	e8 f7 fe ff ff       	call   801ba8 <nsipc>
}
  801cb1:	c9                   	leave  
  801cb2:	c3                   	ret    

00801cb3 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cb3:	55                   	push   %ebp
  801cb4:	89 e5                	mov    %esp,%ebp
  801cb6:	53                   	push   %ebx
  801cb7:	83 ec 08             	sub    $0x8,%esp
  801cba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cbd:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc0:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801cc5:	53                   	push   %ebx
  801cc6:	ff 75 0c             	pushl  0xc(%ebp)
  801cc9:	68 04 60 80 00       	push   $0x806004
  801cce:	e8 b5 ed ff ff       	call   800a88 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801cd3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801cd9:	b8 05 00 00 00       	mov    $0x5,%eax
  801cde:	e8 c5 fe ff ff       	call   801ba8 <nsipc>
}
  801ce3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ce6:	c9                   	leave  
  801ce7:	c3                   	ret    

00801ce8 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801cee:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801cf6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf9:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801cfe:	b8 06 00 00 00       	mov    $0x6,%eax
  801d03:	e8 a0 fe ff ff       	call   801ba8 <nsipc>
}
  801d08:	c9                   	leave  
  801d09:	c3                   	ret    

00801d0a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d0a:	55                   	push   %ebp
  801d0b:	89 e5                	mov    %esp,%ebp
  801d0d:	56                   	push   %esi
  801d0e:	53                   	push   %ebx
  801d0f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d12:	8b 45 08             	mov    0x8(%ebp),%eax
  801d15:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d1a:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d20:	8b 45 14             	mov    0x14(%ebp),%eax
  801d23:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d28:	b8 07 00 00 00       	mov    $0x7,%eax
  801d2d:	e8 76 fe ff ff       	call   801ba8 <nsipc>
  801d32:	89 c3                	mov    %eax,%ebx
  801d34:	85 c0                	test   %eax,%eax
  801d36:	78 35                	js     801d6d <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d38:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d3d:	7f 04                	jg     801d43 <nsipc_recv+0x39>
  801d3f:	39 c6                	cmp    %eax,%esi
  801d41:	7d 16                	jge    801d59 <nsipc_recv+0x4f>
  801d43:	68 b7 2c 80 00       	push   $0x802cb7
  801d48:	68 7f 2c 80 00       	push   $0x802c7f
  801d4d:	6a 62                	push   $0x62
  801d4f:	68 cc 2c 80 00       	push   $0x802ccc
  801d54:	e8 3f e5 ff ff       	call   800298 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d59:	83 ec 04             	sub    $0x4,%esp
  801d5c:	50                   	push   %eax
  801d5d:	68 00 60 80 00       	push   $0x806000
  801d62:	ff 75 0c             	pushl  0xc(%ebp)
  801d65:	e8 1e ed ff ff       	call   800a88 <memmove>
  801d6a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d6d:	89 d8                	mov    %ebx,%eax
  801d6f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d72:	5b                   	pop    %ebx
  801d73:	5e                   	pop    %esi
  801d74:	5d                   	pop    %ebp
  801d75:	c3                   	ret    

00801d76 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d76:	55                   	push   %ebp
  801d77:	89 e5                	mov    %esp,%ebp
  801d79:	53                   	push   %ebx
  801d7a:	83 ec 04             	sub    $0x4,%esp
  801d7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d80:	8b 45 08             	mov    0x8(%ebp),%eax
  801d83:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d88:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d8e:	7e 16                	jle    801da6 <nsipc_send+0x30>
  801d90:	68 d8 2c 80 00       	push   $0x802cd8
  801d95:	68 7f 2c 80 00       	push   $0x802c7f
  801d9a:	6a 6d                	push   $0x6d
  801d9c:	68 cc 2c 80 00       	push   $0x802ccc
  801da1:	e8 f2 e4 ff ff       	call   800298 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801da6:	83 ec 04             	sub    $0x4,%esp
  801da9:	53                   	push   %ebx
  801daa:	ff 75 0c             	pushl  0xc(%ebp)
  801dad:	68 0c 60 80 00       	push   $0x80600c
  801db2:	e8 d1 ec ff ff       	call   800a88 <memmove>
	nsipcbuf.send.req_size = size;
  801db7:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801dbd:	8b 45 14             	mov    0x14(%ebp),%eax
  801dc0:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801dc5:	b8 08 00 00 00       	mov    $0x8,%eax
  801dca:	e8 d9 fd ff ff       	call   801ba8 <nsipc>
}
  801dcf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dd2:	c9                   	leave  
  801dd3:	c3                   	ret    

00801dd4 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801dd4:	55                   	push   %ebp
  801dd5:	89 e5                	mov    %esp,%ebp
  801dd7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801dda:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddd:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801de2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de5:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801dea:	8b 45 10             	mov    0x10(%ebp),%eax
  801ded:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801df2:	b8 09 00 00 00       	mov    $0x9,%eax
  801df7:	e8 ac fd ff ff       	call   801ba8 <nsipc>
}
  801dfc:	c9                   	leave  
  801dfd:	c3                   	ret    

00801dfe <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801dfe:	55                   	push   %ebp
  801dff:	89 e5                	mov    %esp,%ebp
  801e01:	56                   	push   %esi
  801e02:	53                   	push   %ebx
  801e03:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e06:	83 ec 0c             	sub    $0xc,%esp
  801e09:	ff 75 08             	pushl  0x8(%ebp)
  801e0c:	e8 98 f3 ff ff       	call   8011a9 <fd2data>
  801e11:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e13:	83 c4 08             	add    $0x8,%esp
  801e16:	68 e4 2c 80 00       	push   $0x802ce4
  801e1b:	53                   	push   %ebx
  801e1c:	e8 d5 ea ff ff       	call   8008f6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e21:	8b 46 04             	mov    0x4(%esi),%eax
  801e24:	2b 06                	sub    (%esi),%eax
  801e26:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e2c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e33:	00 00 00 
	stat->st_dev = &devpipe;
  801e36:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e3d:	30 80 00 
	return 0;
}
  801e40:	b8 00 00 00 00       	mov    $0x0,%eax
  801e45:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e48:	5b                   	pop    %ebx
  801e49:	5e                   	pop    %esi
  801e4a:	5d                   	pop    %ebp
  801e4b:	c3                   	ret    

00801e4c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
  801e4f:	53                   	push   %ebx
  801e50:	83 ec 0c             	sub    $0xc,%esp
  801e53:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e56:	53                   	push   %ebx
  801e57:	6a 00                	push   $0x0
  801e59:	e8 20 ef ff ff       	call   800d7e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e5e:	89 1c 24             	mov    %ebx,(%esp)
  801e61:	e8 43 f3 ff ff       	call   8011a9 <fd2data>
  801e66:	83 c4 08             	add    $0x8,%esp
  801e69:	50                   	push   %eax
  801e6a:	6a 00                	push   $0x0
  801e6c:	e8 0d ef ff ff       	call   800d7e <sys_page_unmap>
}
  801e71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e74:	c9                   	leave  
  801e75:	c3                   	ret    

00801e76 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e76:	55                   	push   %ebp
  801e77:	89 e5                	mov    %esp,%ebp
  801e79:	57                   	push   %edi
  801e7a:	56                   	push   %esi
  801e7b:	53                   	push   %ebx
  801e7c:	83 ec 1c             	sub    $0x1c,%esp
  801e7f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e82:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e84:	a1 08 40 80 00       	mov    0x804008,%eax
  801e89:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801e8c:	83 ec 0c             	sub    $0xc,%esp
  801e8f:	ff 75 e0             	pushl  -0x20(%ebp)
  801e92:	e8 a5 05 00 00       	call   80243c <pageref>
  801e97:	89 c3                	mov    %eax,%ebx
  801e99:	89 3c 24             	mov    %edi,(%esp)
  801e9c:	e8 9b 05 00 00       	call   80243c <pageref>
  801ea1:	83 c4 10             	add    $0x10,%esp
  801ea4:	39 c3                	cmp    %eax,%ebx
  801ea6:	0f 94 c1             	sete   %cl
  801ea9:	0f b6 c9             	movzbl %cl,%ecx
  801eac:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801eaf:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801eb5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801eb8:	39 ce                	cmp    %ecx,%esi
  801eba:	74 1b                	je     801ed7 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ebc:	39 c3                	cmp    %eax,%ebx
  801ebe:	75 c4                	jne    801e84 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ec0:	8b 42 58             	mov    0x58(%edx),%eax
  801ec3:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ec6:	50                   	push   %eax
  801ec7:	56                   	push   %esi
  801ec8:	68 eb 2c 80 00       	push   $0x802ceb
  801ecd:	e8 9f e4 ff ff       	call   800371 <cprintf>
  801ed2:	83 c4 10             	add    $0x10,%esp
  801ed5:	eb ad                	jmp    801e84 <_pipeisclosed+0xe>
	}
}
  801ed7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801eda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801edd:	5b                   	pop    %ebx
  801ede:	5e                   	pop    %esi
  801edf:	5f                   	pop    %edi
  801ee0:	5d                   	pop    %ebp
  801ee1:	c3                   	ret    

00801ee2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ee2:	55                   	push   %ebp
  801ee3:	89 e5                	mov    %esp,%ebp
  801ee5:	57                   	push   %edi
  801ee6:	56                   	push   %esi
  801ee7:	53                   	push   %ebx
  801ee8:	83 ec 28             	sub    $0x28,%esp
  801eeb:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801eee:	56                   	push   %esi
  801eef:	e8 b5 f2 ff ff       	call   8011a9 <fd2data>
  801ef4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ef6:	83 c4 10             	add    $0x10,%esp
  801ef9:	bf 00 00 00 00       	mov    $0x0,%edi
  801efe:	eb 4b                	jmp    801f4b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f00:	89 da                	mov    %ebx,%edx
  801f02:	89 f0                	mov    %esi,%eax
  801f04:	e8 6d ff ff ff       	call   801e76 <_pipeisclosed>
  801f09:	85 c0                	test   %eax,%eax
  801f0b:	75 48                	jne    801f55 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f0d:	e8 c8 ed ff ff       	call   800cda <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f12:	8b 43 04             	mov    0x4(%ebx),%eax
  801f15:	8b 0b                	mov    (%ebx),%ecx
  801f17:	8d 51 20             	lea    0x20(%ecx),%edx
  801f1a:	39 d0                	cmp    %edx,%eax
  801f1c:	73 e2                	jae    801f00 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f21:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f25:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f28:	89 c2                	mov    %eax,%edx
  801f2a:	c1 fa 1f             	sar    $0x1f,%edx
  801f2d:	89 d1                	mov    %edx,%ecx
  801f2f:	c1 e9 1b             	shr    $0x1b,%ecx
  801f32:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f35:	83 e2 1f             	and    $0x1f,%edx
  801f38:	29 ca                	sub    %ecx,%edx
  801f3a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f3e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f42:	83 c0 01             	add    $0x1,%eax
  801f45:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f48:	83 c7 01             	add    $0x1,%edi
  801f4b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f4e:	75 c2                	jne    801f12 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f50:	8b 45 10             	mov    0x10(%ebp),%eax
  801f53:	eb 05                	jmp    801f5a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f55:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f5d:	5b                   	pop    %ebx
  801f5e:	5e                   	pop    %esi
  801f5f:	5f                   	pop    %edi
  801f60:	5d                   	pop    %ebp
  801f61:	c3                   	ret    

00801f62 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f62:	55                   	push   %ebp
  801f63:	89 e5                	mov    %esp,%ebp
  801f65:	57                   	push   %edi
  801f66:	56                   	push   %esi
  801f67:	53                   	push   %ebx
  801f68:	83 ec 18             	sub    $0x18,%esp
  801f6b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f6e:	57                   	push   %edi
  801f6f:	e8 35 f2 ff ff       	call   8011a9 <fd2data>
  801f74:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f76:	83 c4 10             	add    $0x10,%esp
  801f79:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f7e:	eb 3d                	jmp    801fbd <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f80:	85 db                	test   %ebx,%ebx
  801f82:	74 04                	je     801f88 <devpipe_read+0x26>
				return i;
  801f84:	89 d8                	mov    %ebx,%eax
  801f86:	eb 44                	jmp    801fcc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f88:	89 f2                	mov    %esi,%edx
  801f8a:	89 f8                	mov    %edi,%eax
  801f8c:	e8 e5 fe ff ff       	call   801e76 <_pipeisclosed>
  801f91:	85 c0                	test   %eax,%eax
  801f93:	75 32                	jne    801fc7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f95:	e8 40 ed ff ff       	call   800cda <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f9a:	8b 06                	mov    (%esi),%eax
  801f9c:	3b 46 04             	cmp    0x4(%esi),%eax
  801f9f:	74 df                	je     801f80 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fa1:	99                   	cltd   
  801fa2:	c1 ea 1b             	shr    $0x1b,%edx
  801fa5:	01 d0                	add    %edx,%eax
  801fa7:	83 e0 1f             	and    $0x1f,%eax
  801faa:	29 d0                	sub    %edx,%eax
  801fac:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801fb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fb4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801fb7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fba:	83 c3 01             	add    $0x1,%ebx
  801fbd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801fc0:	75 d8                	jne    801f9a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801fc2:	8b 45 10             	mov    0x10(%ebp),%eax
  801fc5:	eb 05                	jmp    801fcc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fc7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801fcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fcf:	5b                   	pop    %ebx
  801fd0:	5e                   	pop    %esi
  801fd1:	5f                   	pop    %edi
  801fd2:	5d                   	pop    %ebp
  801fd3:	c3                   	ret    

00801fd4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fd4:	55                   	push   %ebp
  801fd5:	89 e5                	mov    %esp,%ebp
  801fd7:	56                   	push   %esi
  801fd8:	53                   	push   %ebx
  801fd9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fdf:	50                   	push   %eax
  801fe0:	e8 db f1 ff ff       	call   8011c0 <fd_alloc>
  801fe5:	83 c4 10             	add    $0x10,%esp
  801fe8:	89 c2                	mov    %eax,%edx
  801fea:	85 c0                	test   %eax,%eax
  801fec:	0f 88 2c 01 00 00    	js     80211e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ff2:	83 ec 04             	sub    $0x4,%esp
  801ff5:	68 07 04 00 00       	push   $0x407
  801ffa:	ff 75 f4             	pushl  -0xc(%ebp)
  801ffd:	6a 00                	push   $0x0
  801fff:	e8 f5 ec ff ff       	call   800cf9 <sys_page_alloc>
  802004:	83 c4 10             	add    $0x10,%esp
  802007:	89 c2                	mov    %eax,%edx
  802009:	85 c0                	test   %eax,%eax
  80200b:	0f 88 0d 01 00 00    	js     80211e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802011:	83 ec 0c             	sub    $0xc,%esp
  802014:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802017:	50                   	push   %eax
  802018:	e8 a3 f1 ff ff       	call   8011c0 <fd_alloc>
  80201d:	89 c3                	mov    %eax,%ebx
  80201f:	83 c4 10             	add    $0x10,%esp
  802022:	85 c0                	test   %eax,%eax
  802024:	0f 88 e2 00 00 00    	js     80210c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80202a:	83 ec 04             	sub    $0x4,%esp
  80202d:	68 07 04 00 00       	push   $0x407
  802032:	ff 75 f0             	pushl  -0x10(%ebp)
  802035:	6a 00                	push   $0x0
  802037:	e8 bd ec ff ff       	call   800cf9 <sys_page_alloc>
  80203c:	89 c3                	mov    %eax,%ebx
  80203e:	83 c4 10             	add    $0x10,%esp
  802041:	85 c0                	test   %eax,%eax
  802043:	0f 88 c3 00 00 00    	js     80210c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802049:	83 ec 0c             	sub    $0xc,%esp
  80204c:	ff 75 f4             	pushl  -0xc(%ebp)
  80204f:	e8 55 f1 ff ff       	call   8011a9 <fd2data>
  802054:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802056:	83 c4 0c             	add    $0xc,%esp
  802059:	68 07 04 00 00       	push   $0x407
  80205e:	50                   	push   %eax
  80205f:	6a 00                	push   $0x0
  802061:	e8 93 ec ff ff       	call   800cf9 <sys_page_alloc>
  802066:	89 c3                	mov    %eax,%ebx
  802068:	83 c4 10             	add    $0x10,%esp
  80206b:	85 c0                	test   %eax,%eax
  80206d:	0f 88 89 00 00 00    	js     8020fc <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802073:	83 ec 0c             	sub    $0xc,%esp
  802076:	ff 75 f0             	pushl  -0x10(%ebp)
  802079:	e8 2b f1 ff ff       	call   8011a9 <fd2data>
  80207e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802085:	50                   	push   %eax
  802086:	6a 00                	push   $0x0
  802088:	56                   	push   %esi
  802089:	6a 00                	push   $0x0
  80208b:	e8 ac ec ff ff       	call   800d3c <sys_page_map>
  802090:	89 c3                	mov    %eax,%ebx
  802092:	83 c4 20             	add    $0x20,%esp
  802095:	85 c0                	test   %eax,%eax
  802097:	78 55                	js     8020ee <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802099:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80209f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020ae:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020b7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020bc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020c3:	83 ec 0c             	sub    $0xc,%esp
  8020c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8020c9:	e8 cb f0 ff ff       	call   801199 <fd2num>
  8020ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020d1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020d3:	83 c4 04             	add    $0x4,%esp
  8020d6:	ff 75 f0             	pushl  -0x10(%ebp)
  8020d9:	e8 bb f0 ff ff       	call   801199 <fd2num>
  8020de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020e1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020e4:	83 c4 10             	add    $0x10,%esp
  8020e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8020ec:	eb 30                	jmp    80211e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8020ee:	83 ec 08             	sub    $0x8,%esp
  8020f1:	56                   	push   %esi
  8020f2:	6a 00                	push   $0x0
  8020f4:	e8 85 ec ff ff       	call   800d7e <sys_page_unmap>
  8020f9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8020fc:	83 ec 08             	sub    $0x8,%esp
  8020ff:	ff 75 f0             	pushl  -0x10(%ebp)
  802102:	6a 00                	push   $0x0
  802104:	e8 75 ec ff ff       	call   800d7e <sys_page_unmap>
  802109:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80210c:	83 ec 08             	sub    $0x8,%esp
  80210f:	ff 75 f4             	pushl  -0xc(%ebp)
  802112:	6a 00                	push   $0x0
  802114:	e8 65 ec ff ff       	call   800d7e <sys_page_unmap>
  802119:	83 c4 10             	add    $0x10,%esp
  80211c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80211e:	89 d0                	mov    %edx,%eax
  802120:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802123:	5b                   	pop    %ebx
  802124:	5e                   	pop    %esi
  802125:	5d                   	pop    %ebp
  802126:	c3                   	ret    

00802127 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802127:	55                   	push   %ebp
  802128:	89 e5                	mov    %esp,%ebp
  80212a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80212d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802130:	50                   	push   %eax
  802131:	ff 75 08             	pushl  0x8(%ebp)
  802134:	e8 d6 f0 ff ff       	call   80120f <fd_lookup>
  802139:	83 c4 10             	add    $0x10,%esp
  80213c:	85 c0                	test   %eax,%eax
  80213e:	78 18                	js     802158 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802140:	83 ec 0c             	sub    $0xc,%esp
  802143:	ff 75 f4             	pushl  -0xc(%ebp)
  802146:	e8 5e f0 ff ff       	call   8011a9 <fd2data>
	return _pipeisclosed(fd, p);
  80214b:	89 c2                	mov    %eax,%edx
  80214d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802150:	e8 21 fd ff ff       	call   801e76 <_pipeisclosed>
  802155:	83 c4 10             	add    $0x10,%esp
}
  802158:	c9                   	leave  
  802159:	c3                   	ret    

0080215a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80215a:	55                   	push   %ebp
  80215b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80215d:	b8 00 00 00 00       	mov    $0x0,%eax
  802162:	5d                   	pop    %ebp
  802163:	c3                   	ret    

00802164 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802164:	55                   	push   %ebp
  802165:	89 e5                	mov    %esp,%ebp
  802167:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80216a:	68 fe 2c 80 00       	push   $0x802cfe
  80216f:	ff 75 0c             	pushl  0xc(%ebp)
  802172:	e8 7f e7 ff ff       	call   8008f6 <strcpy>
	return 0;
}
  802177:	b8 00 00 00 00       	mov    $0x0,%eax
  80217c:	c9                   	leave  
  80217d:	c3                   	ret    

0080217e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80217e:	55                   	push   %ebp
  80217f:	89 e5                	mov    %esp,%ebp
  802181:	57                   	push   %edi
  802182:	56                   	push   %esi
  802183:	53                   	push   %ebx
  802184:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80218a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80218f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802195:	eb 2d                	jmp    8021c4 <devcons_write+0x46>
		m = n - tot;
  802197:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80219a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80219c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80219f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8021a4:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021a7:	83 ec 04             	sub    $0x4,%esp
  8021aa:	53                   	push   %ebx
  8021ab:	03 45 0c             	add    0xc(%ebp),%eax
  8021ae:	50                   	push   %eax
  8021af:	57                   	push   %edi
  8021b0:	e8 d3 e8 ff ff       	call   800a88 <memmove>
		sys_cputs(buf, m);
  8021b5:	83 c4 08             	add    $0x8,%esp
  8021b8:	53                   	push   %ebx
  8021b9:	57                   	push   %edi
  8021ba:	e8 7e ea ff ff       	call   800c3d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021bf:	01 de                	add    %ebx,%esi
  8021c1:	83 c4 10             	add    $0x10,%esp
  8021c4:	89 f0                	mov    %esi,%eax
  8021c6:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021c9:	72 cc                	jb     802197 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021ce:	5b                   	pop    %ebx
  8021cf:	5e                   	pop    %esi
  8021d0:	5f                   	pop    %edi
  8021d1:	5d                   	pop    %ebp
  8021d2:	c3                   	ret    

008021d3 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021d3:	55                   	push   %ebp
  8021d4:	89 e5                	mov    %esp,%ebp
  8021d6:	83 ec 08             	sub    $0x8,%esp
  8021d9:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8021de:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021e2:	74 2a                	je     80220e <devcons_read+0x3b>
  8021e4:	eb 05                	jmp    8021eb <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021e6:	e8 ef ea ff ff       	call   800cda <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021eb:	e8 6b ea ff ff       	call   800c5b <sys_cgetc>
  8021f0:	85 c0                	test   %eax,%eax
  8021f2:	74 f2                	je     8021e6 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8021f4:	85 c0                	test   %eax,%eax
  8021f6:	78 16                	js     80220e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021f8:	83 f8 04             	cmp    $0x4,%eax
  8021fb:	74 0c                	je     802209 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8021fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  802200:	88 02                	mov    %al,(%edx)
	return 1;
  802202:	b8 01 00 00 00       	mov    $0x1,%eax
  802207:	eb 05                	jmp    80220e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802209:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80220e:	c9                   	leave  
  80220f:	c3                   	ret    

00802210 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802210:	55                   	push   %ebp
  802211:	89 e5                	mov    %esp,%ebp
  802213:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802216:	8b 45 08             	mov    0x8(%ebp),%eax
  802219:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80221c:	6a 01                	push   $0x1
  80221e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802221:	50                   	push   %eax
  802222:	e8 16 ea ff ff       	call   800c3d <sys_cputs>
}
  802227:	83 c4 10             	add    $0x10,%esp
  80222a:	c9                   	leave  
  80222b:	c3                   	ret    

0080222c <getchar>:

int
getchar(void)
{
  80222c:	55                   	push   %ebp
  80222d:	89 e5                	mov    %esp,%ebp
  80222f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802232:	6a 01                	push   $0x1
  802234:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802237:	50                   	push   %eax
  802238:	6a 00                	push   $0x0
  80223a:	e8 36 f2 ff ff       	call   801475 <read>
	if (r < 0)
  80223f:	83 c4 10             	add    $0x10,%esp
  802242:	85 c0                	test   %eax,%eax
  802244:	78 0f                	js     802255 <getchar+0x29>
		return r;
	if (r < 1)
  802246:	85 c0                	test   %eax,%eax
  802248:	7e 06                	jle    802250 <getchar+0x24>
		return -E_EOF;
	return c;
  80224a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80224e:	eb 05                	jmp    802255 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802250:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802255:	c9                   	leave  
  802256:	c3                   	ret    

00802257 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802257:	55                   	push   %ebp
  802258:	89 e5                	mov    %esp,%ebp
  80225a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80225d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802260:	50                   	push   %eax
  802261:	ff 75 08             	pushl  0x8(%ebp)
  802264:	e8 a6 ef ff ff       	call   80120f <fd_lookup>
  802269:	83 c4 10             	add    $0x10,%esp
  80226c:	85 c0                	test   %eax,%eax
  80226e:	78 11                	js     802281 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802270:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802273:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802279:	39 10                	cmp    %edx,(%eax)
  80227b:	0f 94 c0             	sete   %al
  80227e:	0f b6 c0             	movzbl %al,%eax
}
  802281:	c9                   	leave  
  802282:	c3                   	ret    

00802283 <opencons>:

int
opencons(void)
{
  802283:	55                   	push   %ebp
  802284:	89 e5                	mov    %esp,%ebp
  802286:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802289:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80228c:	50                   	push   %eax
  80228d:	e8 2e ef ff ff       	call   8011c0 <fd_alloc>
  802292:	83 c4 10             	add    $0x10,%esp
		return r;
  802295:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802297:	85 c0                	test   %eax,%eax
  802299:	78 3e                	js     8022d9 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80229b:	83 ec 04             	sub    $0x4,%esp
  80229e:	68 07 04 00 00       	push   $0x407
  8022a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8022a6:	6a 00                	push   $0x0
  8022a8:	e8 4c ea ff ff       	call   800cf9 <sys_page_alloc>
  8022ad:	83 c4 10             	add    $0x10,%esp
		return r;
  8022b0:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022b2:	85 c0                	test   %eax,%eax
  8022b4:	78 23                	js     8022d9 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022b6:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022bf:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022c4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022cb:	83 ec 0c             	sub    $0xc,%esp
  8022ce:	50                   	push   %eax
  8022cf:	e8 c5 ee ff ff       	call   801199 <fd2num>
  8022d4:	89 c2                	mov    %eax,%edx
  8022d6:	83 c4 10             	add    $0x10,%esp
}
  8022d9:	89 d0                	mov    %edx,%eax
  8022db:	c9                   	leave  
  8022dc:	c3                   	ret    

008022dd <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022dd:	55                   	push   %ebp
  8022de:	89 e5                	mov    %esp,%ebp
  8022e0:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8022e3:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8022ea:	75 2e                	jne    80231a <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8022ec:	e8 ca e9 ff ff       	call   800cbb <sys_getenvid>
  8022f1:	83 ec 04             	sub    $0x4,%esp
  8022f4:	68 07 0e 00 00       	push   $0xe07
  8022f9:	68 00 f0 bf ee       	push   $0xeebff000
  8022fe:	50                   	push   %eax
  8022ff:	e8 f5 e9 ff ff       	call   800cf9 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802304:	e8 b2 e9 ff ff       	call   800cbb <sys_getenvid>
  802309:	83 c4 08             	add    $0x8,%esp
  80230c:	68 24 23 80 00       	push   $0x802324
  802311:	50                   	push   %eax
  802312:	e8 2d eb ff ff       	call   800e44 <sys_env_set_pgfault_upcall>
  802317:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80231a:	8b 45 08             	mov    0x8(%ebp),%eax
  80231d:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802322:	c9                   	leave  
  802323:	c3                   	ret    

00802324 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802324:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802325:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80232a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80232c:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  80232f:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  802333:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802337:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  80233a:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  80233d:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  80233e:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  802341:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  802342:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  802343:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802347:	c3                   	ret    

00802348 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802348:	55                   	push   %ebp
  802349:	89 e5                	mov    %esp,%ebp
  80234b:	56                   	push   %esi
  80234c:	53                   	push   %ebx
  80234d:	8b 75 08             	mov    0x8(%ebp),%esi
  802350:	8b 45 0c             	mov    0xc(%ebp),%eax
  802353:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802356:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802358:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80235d:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802360:	83 ec 0c             	sub    $0xc,%esp
  802363:	50                   	push   %eax
  802364:	e8 40 eb ff ff       	call   800ea9 <sys_ipc_recv>

	if (from_env_store != NULL)
  802369:	83 c4 10             	add    $0x10,%esp
  80236c:	85 f6                	test   %esi,%esi
  80236e:	74 14                	je     802384 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802370:	ba 00 00 00 00       	mov    $0x0,%edx
  802375:	85 c0                	test   %eax,%eax
  802377:	78 09                	js     802382 <ipc_recv+0x3a>
  802379:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80237f:	8b 52 74             	mov    0x74(%edx),%edx
  802382:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802384:	85 db                	test   %ebx,%ebx
  802386:	74 14                	je     80239c <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802388:	ba 00 00 00 00       	mov    $0x0,%edx
  80238d:	85 c0                	test   %eax,%eax
  80238f:	78 09                	js     80239a <ipc_recv+0x52>
  802391:	8b 15 08 40 80 00    	mov    0x804008,%edx
  802397:	8b 52 78             	mov    0x78(%edx),%edx
  80239a:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80239c:	85 c0                	test   %eax,%eax
  80239e:	78 08                	js     8023a8 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8023a0:	a1 08 40 80 00       	mov    0x804008,%eax
  8023a5:	8b 40 70             	mov    0x70(%eax),%eax
}
  8023a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023ab:	5b                   	pop    %ebx
  8023ac:	5e                   	pop    %esi
  8023ad:	5d                   	pop    %ebp
  8023ae:	c3                   	ret    

008023af <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023af:	55                   	push   %ebp
  8023b0:	89 e5                	mov    %esp,%ebp
  8023b2:	57                   	push   %edi
  8023b3:	56                   	push   %esi
  8023b4:	53                   	push   %ebx
  8023b5:	83 ec 0c             	sub    $0xc,%esp
  8023b8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023bb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023be:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8023c1:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8023c3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8023c8:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8023cb:	ff 75 14             	pushl  0x14(%ebp)
  8023ce:	53                   	push   %ebx
  8023cf:	56                   	push   %esi
  8023d0:	57                   	push   %edi
  8023d1:	e8 b0 ea ff ff       	call   800e86 <sys_ipc_try_send>

		if (err < 0) {
  8023d6:	83 c4 10             	add    $0x10,%esp
  8023d9:	85 c0                	test   %eax,%eax
  8023db:	79 1e                	jns    8023fb <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8023dd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023e0:	75 07                	jne    8023e9 <ipc_send+0x3a>
				sys_yield();
  8023e2:	e8 f3 e8 ff ff       	call   800cda <sys_yield>
  8023e7:	eb e2                	jmp    8023cb <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8023e9:	50                   	push   %eax
  8023ea:	68 0a 2d 80 00       	push   $0x802d0a
  8023ef:	6a 49                	push   $0x49
  8023f1:	68 17 2d 80 00       	push   $0x802d17
  8023f6:	e8 9d de ff ff       	call   800298 <_panic>
		}

	} while (err < 0);

}
  8023fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023fe:	5b                   	pop    %ebx
  8023ff:	5e                   	pop    %esi
  802400:	5f                   	pop    %edi
  802401:	5d                   	pop    %ebp
  802402:	c3                   	ret    

00802403 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802403:	55                   	push   %ebp
  802404:	89 e5                	mov    %esp,%ebp
  802406:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802409:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80240e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802411:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802417:	8b 52 50             	mov    0x50(%edx),%edx
  80241a:	39 ca                	cmp    %ecx,%edx
  80241c:	75 0d                	jne    80242b <ipc_find_env+0x28>
			return envs[i].env_id;
  80241e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802421:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802426:	8b 40 48             	mov    0x48(%eax),%eax
  802429:	eb 0f                	jmp    80243a <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80242b:	83 c0 01             	add    $0x1,%eax
  80242e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802433:	75 d9                	jne    80240e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802435:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80243a:	5d                   	pop    %ebp
  80243b:	c3                   	ret    

0080243c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80243c:	55                   	push   %ebp
  80243d:	89 e5                	mov    %esp,%ebp
  80243f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802442:	89 d0                	mov    %edx,%eax
  802444:	c1 e8 16             	shr    $0x16,%eax
  802447:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80244e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802453:	f6 c1 01             	test   $0x1,%cl
  802456:	74 1d                	je     802475 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802458:	c1 ea 0c             	shr    $0xc,%edx
  80245b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802462:	f6 c2 01             	test   $0x1,%dl
  802465:	74 0e                	je     802475 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802467:	c1 ea 0c             	shr    $0xc,%edx
  80246a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802471:	ef 
  802472:	0f b7 c0             	movzwl %ax,%eax
}
  802475:	5d                   	pop    %ebp
  802476:	c3                   	ret    
  802477:	66 90                	xchg   %ax,%ax
  802479:	66 90                	xchg   %ax,%ax
  80247b:	66 90                	xchg   %ax,%ax
  80247d:	66 90                	xchg   %ax,%ax
  80247f:	90                   	nop

00802480 <__udivdi3>:
  802480:	55                   	push   %ebp
  802481:	57                   	push   %edi
  802482:	56                   	push   %esi
  802483:	53                   	push   %ebx
  802484:	83 ec 1c             	sub    $0x1c,%esp
  802487:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80248b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80248f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802493:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802497:	85 f6                	test   %esi,%esi
  802499:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80249d:	89 ca                	mov    %ecx,%edx
  80249f:	89 f8                	mov    %edi,%eax
  8024a1:	75 3d                	jne    8024e0 <__udivdi3+0x60>
  8024a3:	39 cf                	cmp    %ecx,%edi
  8024a5:	0f 87 c5 00 00 00    	ja     802570 <__udivdi3+0xf0>
  8024ab:	85 ff                	test   %edi,%edi
  8024ad:	89 fd                	mov    %edi,%ebp
  8024af:	75 0b                	jne    8024bc <__udivdi3+0x3c>
  8024b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8024b6:	31 d2                	xor    %edx,%edx
  8024b8:	f7 f7                	div    %edi
  8024ba:	89 c5                	mov    %eax,%ebp
  8024bc:	89 c8                	mov    %ecx,%eax
  8024be:	31 d2                	xor    %edx,%edx
  8024c0:	f7 f5                	div    %ebp
  8024c2:	89 c1                	mov    %eax,%ecx
  8024c4:	89 d8                	mov    %ebx,%eax
  8024c6:	89 cf                	mov    %ecx,%edi
  8024c8:	f7 f5                	div    %ebp
  8024ca:	89 c3                	mov    %eax,%ebx
  8024cc:	89 d8                	mov    %ebx,%eax
  8024ce:	89 fa                	mov    %edi,%edx
  8024d0:	83 c4 1c             	add    $0x1c,%esp
  8024d3:	5b                   	pop    %ebx
  8024d4:	5e                   	pop    %esi
  8024d5:	5f                   	pop    %edi
  8024d6:	5d                   	pop    %ebp
  8024d7:	c3                   	ret    
  8024d8:	90                   	nop
  8024d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024e0:	39 ce                	cmp    %ecx,%esi
  8024e2:	77 74                	ja     802558 <__udivdi3+0xd8>
  8024e4:	0f bd fe             	bsr    %esi,%edi
  8024e7:	83 f7 1f             	xor    $0x1f,%edi
  8024ea:	0f 84 98 00 00 00    	je     802588 <__udivdi3+0x108>
  8024f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8024f5:	89 f9                	mov    %edi,%ecx
  8024f7:	89 c5                	mov    %eax,%ebp
  8024f9:	29 fb                	sub    %edi,%ebx
  8024fb:	d3 e6                	shl    %cl,%esi
  8024fd:	89 d9                	mov    %ebx,%ecx
  8024ff:	d3 ed                	shr    %cl,%ebp
  802501:	89 f9                	mov    %edi,%ecx
  802503:	d3 e0                	shl    %cl,%eax
  802505:	09 ee                	or     %ebp,%esi
  802507:	89 d9                	mov    %ebx,%ecx
  802509:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80250d:	89 d5                	mov    %edx,%ebp
  80250f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802513:	d3 ed                	shr    %cl,%ebp
  802515:	89 f9                	mov    %edi,%ecx
  802517:	d3 e2                	shl    %cl,%edx
  802519:	89 d9                	mov    %ebx,%ecx
  80251b:	d3 e8                	shr    %cl,%eax
  80251d:	09 c2                	or     %eax,%edx
  80251f:	89 d0                	mov    %edx,%eax
  802521:	89 ea                	mov    %ebp,%edx
  802523:	f7 f6                	div    %esi
  802525:	89 d5                	mov    %edx,%ebp
  802527:	89 c3                	mov    %eax,%ebx
  802529:	f7 64 24 0c          	mull   0xc(%esp)
  80252d:	39 d5                	cmp    %edx,%ebp
  80252f:	72 10                	jb     802541 <__udivdi3+0xc1>
  802531:	8b 74 24 08          	mov    0x8(%esp),%esi
  802535:	89 f9                	mov    %edi,%ecx
  802537:	d3 e6                	shl    %cl,%esi
  802539:	39 c6                	cmp    %eax,%esi
  80253b:	73 07                	jae    802544 <__udivdi3+0xc4>
  80253d:	39 d5                	cmp    %edx,%ebp
  80253f:	75 03                	jne    802544 <__udivdi3+0xc4>
  802541:	83 eb 01             	sub    $0x1,%ebx
  802544:	31 ff                	xor    %edi,%edi
  802546:	89 d8                	mov    %ebx,%eax
  802548:	89 fa                	mov    %edi,%edx
  80254a:	83 c4 1c             	add    $0x1c,%esp
  80254d:	5b                   	pop    %ebx
  80254e:	5e                   	pop    %esi
  80254f:	5f                   	pop    %edi
  802550:	5d                   	pop    %ebp
  802551:	c3                   	ret    
  802552:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802558:	31 ff                	xor    %edi,%edi
  80255a:	31 db                	xor    %ebx,%ebx
  80255c:	89 d8                	mov    %ebx,%eax
  80255e:	89 fa                	mov    %edi,%edx
  802560:	83 c4 1c             	add    $0x1c,%esp
  802563:	5b                   	pop    %ebx
  802564:	5e                   	pop    %esi
  802565:	5f                   	pop    %edi
  802566:	5d                   	pop    %ebp
  802567:	c3                   	ret    
  802568:	90                   	nop
  802569:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802570:	89 d8                	mov    %ebx,%eax
  802572:	f7 f7                	div    %edi
  802574:	31 ff                	xor    %edi,%edi
  802576:	89 c3                	mov    %eax,%ebx
  802578:	89 d8                	mov    %ebx,%eax
  80257a:	89 fa                	mov    %edi,%edx
  80257c:	83 c4 1c             	add    $0x1c,%esp
  80257f:	5b                   	pop    %ebx
  802580:	5e                   	pop    %esi
  802581:	5f                   	pop    %edi
  802582:	5d                   	pop    %ebp
  802583:	c3                   	ret    
  802584:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802588:	39 ce                	cmp    %ecx,%esi
  80258a:	72 0c                	jb     802598 <__udivdi3+0x118>
  80258c:	31 db                	xor    %ebx,%ebx
  80258e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802592:	0f 87 34 ff ff ff    	ja     8024cc <__udivdi3+0x4c>
  802598:	bb 01 00 00 00       	mov    $0x1,%ebx
  80259d:	e9 2a ff ff ff       	jmp    8024cc <__udivdi3+0x4c>
  8025a2:	66 90                	xchg   %ax,%ax
  8025a4:	66 90                	xchg   %ax,%ax
  8025a6:	66 90                	xchg   %ax,%ax
  8025a8:	66 90                	xchg   %ax,%ax
  8025aa:	66 90                	xchg   %ax,%ax
  8025ac:	66 90                	xchg   %ax,%ax
  8025ae:	66 90                	xchg   %ax,%ax

008025b0 <__umoddi3>:
  8025b0:	55                   	push   %ebp
  8025b1:	57                   	push   %edi
  8025b2:	56                   	push   %esi
  8025b3:	53                   	push   %ebx
  8025b4:	83 ec 1c             	sub    $0x1c,%esp
  8025b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8025bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8025bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025c7:	85 d2                	test   %edx,%edx
  8025c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025d1:	89 f3                	mov    %esi,%ebx
  8025d3:	89 3c 24             	mov    %edi,(%esp)
  8025d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025da:	75 1c                	jne    8025f8 <__umoddi3+0x48>
  8025dc:	39 f7                	cmp    %esi,%edi
  8025de:	76 50                	jbe    802630 <__umoddi3+0x80>
  8025e0:	89 c8                	mov    %ecx,%eax
  8025e2:	89 f2                	mov    %esi,%edx
  8025e4:	f7 f7                	div    %edi
  8025e6:	89 d0                	mov    %edx,%eax
  8025e8:	31 d2                	xor    %edx,%edx
  8025ea:	83 c4 1c             	add    $0x1c,%esp
  8025ed:	5b                   	pop    %ebx
  8025ee:	5e                   	pop    %esi
  8025ef:	5f                   	pop    %edi
  8025f0:	5d                   	pop    %ebp
  8025f1:	c3                   	ret    
  8025f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025f8:	39 f2                	cmp    %esi,%edx
  8025fa:	89 d0                	mov    %edx,%eax
  8025fc:	77 52                	ja     802650 <__umoddi3+0xa0>
  8025fe:	0f bd ea             	bsr    %edx,%ebp
  802601:	83 f5 1f             	xor    $0x1f,%ebp
  802604:	75 5a                	jne    802660 <__umoddi3+0xb0>
  802606:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80260a:	0f 82 e0 00 00 00    	jb     8026f0 <__umoddi3+0x140>
  802610:	39 0c 24             	cmp    %ecx,(%esp)
  802613:	0f 86 d7 00 00 00    	jbe    8026f0 <__umoddi3+0x140>
  802619:	8b 44 24 08          	mov    0x8(%esp),%eax
  80261d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802621:	83 c4 1c             	add    $0x1c,%esp
  802624:	5b                   	pop    %ebx
  802625:	5e                   	pop    %esi
  802626:	5f                   	pop    %edi
  802627:	5d                   	pop    %ebp
  802628:	c3                   	ret    
  802629:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802630:	85 ff                	test   %edi,%edi
  802632:	89 fd                	mov    %edi,%ebp
  802634:	75 0b                	jne    802641 <__umoddi3+0x91>
  802636:	b8 01 00 00 00       	mov    $0x1,%eax
  80263b:	31 d2                	xor    %edx,%edx
  80263d:	f7 f7                	div    %edi
  80263f:	89 c5                	mov    %eax,%ebp
  802641:	89 f0                	mov    %esi,%eax
  802643:	31 d2                	xor    %edx,%edx
  802645:	f7 f5                	div    %ebp
  802647:	89 c8                	mov    %ecx,%eax
  802649:	f7 f5                	div    %ebp
  80264b:	89 d0                	mov    %edx,%eax
  80264d:	eb 99                	jmp    8025e8 <__umoddi3+0x38>
  80264f:	90                   	nop
  802650:	89 c8                	mov    %ecx,%eax
  802652:	89 f2                	mov    %esi,%edx
  802654:	83 c4 1c             	add    $0x1c,%esp
  802657:	5b                   	pop    %ebx
  802658:	5e                   	pop    %esi
  802659:	5f                   	pop    %edi
  80265a:	5d                   	pop    %ebp
  80265b:	c3                   	ret    
  80265c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802660:	8b 34 24             	mov    (%esp),%esi
  802663:	bf 20 00 00 00       	mov    $0x20,%edi
  802668:	89 e9                	mov    %ebp,%ecx
  80266a:	29 ef                	sub    %ebp,%edi
  80266c:	d3 e0                	shl    %cl,%eax
  80266e:	89 f9                	mov    %edi,%ecx
  802670:	89 f2                	mov    %esi,%edx
  802672:	d3 ea                	shr    %cl,%edx
  802674:	89 e9                	mov    %ebp,%ecx
  802676:	09 c2                	or     %eax,%edx
  802678:	89 d8                	mov    %ebx,%eax
  80267a:	89 14 24             	mov    %edx,(%esp)
  80267d:	89 f2                	mov    %esi,%edx
  80267f:	d3 e2                	shl    %cl,%edx
  802681:	89 f9                	mov    %edi,%ecx
  802683:	89 54 24 04          	mov    %edx,0x4(%esp)
  802687:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80268b:	d3 e8                	shr    %cl,%eax
  80268d:	89 e9                	mov    %ebp,%ecx
  80268f:	89 c6                	mov    %eax,%esi
  802691:	d3 e3                	shl    %cl,%ebx
  802693:	89 f9                	mov    %edi,%ecx
  802695:	89 d0                	mov    %edx,%eax
  802697:	d3 e8                	shr    %cl,%eax
  802699:	89 e9                	mov    %ebp,%ecx
  80269b:	09 d8                	or     %ebx,%eax
  80269d:	89 d3                	mov    %edx,%ebx
  80269f:	89 f2                	mov    %esi,%edx
  8026a1:	f7 34 24             	divl   (%esp)
  8026a4:	89 d6                	mov    %edx,%esi
  8026a6:	d3 e3                	shl    %cl,%ebx
  8026a8:	f7 64 24 04          	mull   0x4(%esp)
  8026ac:	39 d6                	cmp    %edx,%esi
  8026ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026b2:	89 d1                	mov    %edx,%ecx
  8026b4:	89 c3                	mov    %eax,%ebx
  8026b6:	72 08                	jb     8026c0 <__umoddi3+0x110>
  8026b8:	75 11                	jne    8026cb <__umoddi3+0x11b>
  8026ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8026be:	73 0b                	jae    8026cb <__umoddi3+0x11b>
  8026c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8026c4:	1b 14 24             	sbb    (%esp),%edx
  8026c7:	89 d1                	mov    %edx,%ecx
  8026c9:	89 c3                	mov    %eax,%ebx
  8026cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8026cf:	29 da                	sub    %ebx,%edx
  8026d1:	19 ce                	sbb    %ecx,%esi
  8026d3:	89 f9                	mov    %edi,%ecx
  8026d5:	89 f0                	mov    %esi,%eax
  8026d7:	d3 e0                	shl    %cl,%eax
  8026d9:	89 e9                	mov    %ebp,%ecx
  8026db:	d3 ea                	shr    %cl,%edx
  8026dd:	89 e9                	mov    %ebp,%ecx
  8026df:	d3 ee                	shr    %cl,%esi
  8026e1:	09 d0                	or     %edx,%eax
  8026e3:	89 f2                	mov    %esi,%edx
  8026e5:	83 c4 1c             	add    $0x1c,%esp
  8026e8:	5b                   	pop    %ebx
  8026e9:	5e                   	pop    %esi
  8026ea:	5f                   	pop    %edi
  8026eb:	5d                   	pop    %ebp
  8026ec:	c3                   	ret    
  8026ed:	8d 76 00             	lea    0x0(%esi),%esi
  8026f0:	29 f9                	sub    %edi,%ecx
  8026f2:	19 d6                	sbb    %edx,%esi
  8026f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026fc:	e9 18 ff ff ff       	jmp    802619 <__umoddi3+0x69>
