
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
  80004c:	e8 99 14 00 00       	call   8014ea <readn>
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
  800068:	68 a0 22 80 00       	push   $0x8022a0
  80006d:	6a 15                	push   $0x15
  80006f:	68 cf 22 80 00       	push   $0x8022cf
  800074:	e8 1f 02 00 00       	call   800298 <_panic>

	cprintf("%d\n", p);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	ff 75 e0             	pushl  -0x20(%ebp)
  80007f:	68 e1 22 80 00       	push   $0x8022e1
  800084:	e8 e8 02 00 00       	call   800371 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800089:	89 3c 24             	mov    %edi,(%esp)
  80008c:	e8 c0 1a 00 00       	call   801b51 <pipe>
  800091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	85 c0                	test   %eax,%eax
  800099:	79 12                	jns    8000ad <primeproc+0x7a>
		panic("pipe: %e", i);
  80009b:	50                   	push   %eax
  80009c:	68 e5 22 80 00       	push   $0x8022e5
  8000a1:	6a 1b                	push   $0x1b
  8000a3:	68 cf 22 80 00       	push   $0x8022cf
  8000a8:	e8 eb 01 00 00       	call   800298 <_panic>
	if ((id = fork()) < 0)
  8000ad:	e8 11 0f 00 00       	call   800fc3 <fork>
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	79 12                	jns    8000c8 <primeproc+0x95>
		panic("fork: %e", id);
  8000b6:	50                   	push   %eax
  8000b7:	68 ee 22 80 00       	push   $0x8022ee
  8000bc:	6a 1d                	push   $0x1d
  8000be:	68 cf 22 80 00       	push   $0x8022cf
  8000c3:	e8 d0 01 00 00       	call   800298 <_panic>
	if (id == 0) {
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	75 1f                	jne    8000eb <primeproc+0xb8>
		close(fd);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	53                   	push   %ebx
  8000d0:	e8 48 12 00 00       	call   80131d <close>
		close(pfd[1]);
  8000d5:	83 c4 04             	add    $0x4,%esp
  8000d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000db:	e8 3d 12 00 00       	call   80131d <close>
		fd = pfd[0];
  8000e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	e9 5a ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f1:	e8 27 12 00 00       	call   80131d <close>
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
  800106:	e8 df 13 00 00       	call   8014ea <readn>
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
  800126:	68 f7 22 80 00       	push   $0x8022f7
  80012b:	6a 2b                	push   $0x2b
  80012d:	68 cf 22 80 00       	push   $0x8022cf
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
  800149:	e8 e5 13 00 00       	call   801533 <write>
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
  800168:	68 13 23 80 00       	push   $0x802313
  80016d:	6a 2e                	push   $0x2e
  80016f:	68 cf 22 80 00       	push   $0x8022cf
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
  800180:	c7 05 00 30 80 00 2d 	movl   $0x80232d,0x803000
  800187:	23 80 00 

	if ((i=pipe(p)) < 0)
  80018a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	e8 be 19 00 00       	call   801b51 <pipe>
  800193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	85 c0                	test   %eax,%eax
  80019b:	79 12                	jns    8001af <umain+0x36>
		panic("pipe: %e", i);
  80019d:	50                   	push   %eax
  80019e:	68 e5 22 80 00       	push   $0x8022e5
  8001a3:	6a 3a                	push   $0x3a
  8001a5:	68 cf 22 80 00       	push   $0x8022cf
  8001aa:	e8 e9 00 00 00       	call   800298 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001af:	e8 0f 0e 00 00       	call   800fc3 <fork>
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	79 12                	jns    8001ca <umain+0x51>
		panic("fork: %e", id);
  8001b8:	50                   	push   %eax
  8001b9:	68 ee 22 80 00       	push   $0x8022ee
  8001be:	6a 3e                	push   $0x3e
  8001c0:	68 cf 22 80 00       	push   $0x8022cf
  8001c5:	e8 ce 00 00 00       	call   800298 <_panic>

	if (id == 0) {
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	75 16                	jne    8001e4 <umain+0x6b>
		close(p[1]);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d4:	e8 44 11 00 00       	call   80131d <close>
		primeproc(p[0]);
  8001d9:	83 c4 04             	add    $0x4,%esp
  8001dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8001df:	e8 4f fe ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ea:	e8 2e 11 00 00       	call   80131d <close>

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
  800205:	e8 29 13 00 00       	call   801533 <write>
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
  800221:	68 38 23 80 00       	push   $0x802338
  800226:	6a 4a                	push   $0x4a
  800228:	68 cf 22 80 00       	push   $0x8022cf
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
  800255:	a3 04 40 80 00       	mov    %eax,0x804004

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
  800284:	e8 bf 10 00 00       	call   801348 <close_all>
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
  8002b6:	68 5c 23 80 00       	push   $0x80235c
  8002bb:	e8 b1 00 00 00       	call   800371 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002c0:	83 c4 18             	add    $0x18,%esp
  8002c3:	53                   	push   %ebx
  8002c4:	ff 75 10             	pushl  0x10(%ebp)
  8002c7:	e8 54 00 00 00       	call   800320 <vcprintf>
	cprintf("\n");
  8002cc:	c7 04 24 e3 22 80 00 	movl   $0x8022e3,(%esp)
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
  8003d4:	e8 27 1c 00 00       	call   802000 <__udivdi3>
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
  800417:	e8 14 1d 00 00       	call   802130 <__umoddi3>
  80041c:	83 c4 14             	add    $0x14,%esp
  80041f:	0f be 80 7f 23 80 00 	movsbl 0x80237f(%eax),%eax
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
  80051b:	ff 24 85 c0 24 80 00 	jmp    *0x8024c0(,%eax,4)
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
  8005df:	8b 14 85 20 26 80 00 	mov    0x802620(,%eax,4),%edx
  8005e6:	85 d2                	test   %edx,%edx
  8005e8:	75 18                	jne    800602 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005ea:	50                   	push   %eax
  8005eb:	68 97 23 80 00       	push   $0x802397
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
  800603:	68 0d 28 80 00       	push   $0x80280d
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
  800627:	b8 90 23 80 00       	mov    $0x802390,%eax
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
  800ca2:	68 7f 26 80 00       	push   $0x80267f
  800ca7:	6a 23                	push   $0x23
  800ca9:	68 9c 26 80 00       	push   $0x80269c
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
  800d23:	68 7f 26 80 00       	push   $0x80267f
  800d28:	6a 23                	push   $0x23
  800d2a:	68 9c 26 80 00       	push   $0x80269c
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
  800d65:	68 7f 26 80 00       	push   $0x80267f
  800d6a:	6a 23                	push   $0x23
  800d6c:	68 9c 26 80 00       	push   $0x80269c
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
  800da7:	68 7f 26 80 00       	push   $0x80267f
  800dac:	6a 23                	push   $0x23
  800dae:	68 9c 26 80 00       	push   $0x80269c
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
  800de9:	68 7f 26 80 00       	push   $0x80267f
  800dee:	6a 23                	push   $0x23
  800df0:	68 9c 26 80 00       	push   $0x80269c
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
  800e2b:	68 7f 26 80 00       	push   $0x80267f
  800e30:	6a 23                	push   $0x23
  800e32:	68 9c 26 80 00       	push   $0x80269c
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
  800e6d:	68 7f 26 80 00       	push   $0x80267f
  800e72:	6a 23                	push   $0x23
  800e74:	68 9c 26 80 00       	push   $0x80269c
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
  800ed1:	68 7f 26 80 00       	push   $0x80267f
  800ed6:	6a 23                	push   $0x23
  800ed8:	68 9c 26 80 00       	push   $0x80269c
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

00800eea <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
  800eed:	56                   	push   %esi
  800eee:	53                   	push   %ebx
  800eef:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ef2:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800ef4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ef8:	75 25                	jne    800f1f <pgfault+0x35>
  800efa:	89 d8                	mov    %ebx,%eax
  800efc:	c1 e8 0c             	shr    $0xc,%eax
  800eff:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f06:	f6 c4 08             	test   $0x8,%ah
  800f09:	75 14                	jne    800f1f <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800f0b:	83 ec 04             	sub    $0x4,%esp
  800f0e:	68 ac 26 80 00       	push   $0x8026ac
  800f13:	6a 1e                	push   $0x1e
  800f15:	68 40 27 80 00       	push   $0x802740
  800f1a:	e8 79 f3 ff ff       	call   800298 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800f1f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800f25:	e8 91 fd ff ff       	call   800cbb <sys_getenvid>
  800f2a:	89 c6                	mov    %eax,%esi

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800f2c:	83 ec 04             	sub    $0x4,%esp
  800f2f:	6a 07                	push   $0x7
  800f31:	68 00 f0 7f 00       	push   $0x7ff000
  800f36:	50                   	push   %eax
  800f37:	e8 bd fd ff ff       	call   800cf9 <sys_page_alloc>
	if (r < 0)
  800f3c:	83 c4 10             	add    $0x10,%esp
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	79 12                	jns    800f55 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800f43:	50                   	push   %eax
  800f44:	68 d8 26 80 00       	push   $0x8026d8
  800f49:	6a 31                	push   $0x31
  800f4b:	68 40 27 80 00       	push   $0x802740
  800f50:	e8 43 f3 ff ff       	call   800298 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800f55:	83 ec 04             	sub    $0x4,%esp
  800f58:	68 00 10 00 00       	push   $0x1000
  800f5d:	53                   	push   %ebx
  800f5e:	68 00 f0 7f 00       	push   $0x7ff000
  800f63:	e8 88 fb ff ff       	call   800af0 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800f68:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f6f:	53                   	push   %ebx
  800f70:	56                   	push   %esi
  800f71:	68 00 f0 7f 00       	push   $0x7ff000
  800f76:	56                   	push   %esi
  800f77:	e8 c0 fd ff ff       	call   800d3c <sys_page_map>
	if (r < 0)
  800f7c:	83 c4 20             	add    $0x20,%esp
  800f7f:	85 c0                	test   %eax,%eax
  800f81:	79 12                	jns    800f95 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800f83:	50                   	push   %eax
  800f84:	68 fc 26 80 00       	push   $0x8026fc
  800f89:	6a 39                	push   $0x39
  800f8b:	68 40 27 80 00       	push   $0x802740
  800f90:	e8 03 f3 ff ff       	call   800298 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800f95:	83 ec 08             	sub    $0x8,%esp
  800f98:	68 00 f0 7f 00       	push   $0x7ff000
  800f9d:	56                   	push   %esi
  800f9e:	e8 db fd ff ff       	call   800d7e <sys_page_unmap>
	if (r < 0)
  800fa3:	83 c4 10             	add    $0x10,%esp
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	79 12                	jns    800fbc <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800faa:	50                   	push   %eax
  800fab:	68 20 27 80 00       	push   $0x802720
  800fb0:	6a 3e                	push   $0x3e
  800fb2:	68 40 27 80 00       	push   $0x802740
  800fb7:	e8 dc f2 ff ff       	call   800298 <_panic>
}
  800fbc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fbf:	5b                   	pop    %ebx
  800fc0:	5e                   	pop    %esi
  800fc1:	5d                   	pop    %ebp
  800fc2:	c3                   	ret    

00800fc3 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fc3:	55                   	push   %ebp
  800fc4:	89 e5                	mov    %esp,%ebp
  800fc6:	57                   	push   %edi
  800fc7:	56                   	push   %esi
  800fc8:	53                   	push   %ebx
  800fc9:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800fcc:	68 ea 0e 80 00       	push   $0x800eea
  800fd1:	e8 84 0e 00 00       	call   801e5a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fd6:	b8 07 00 00 00       	mov    $0x7,%eax
  800fdb:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800fdd:	83 c4 10             	add    $0x10,%esp
  800fe0:	85 c0                	test   %eax,%eax
  800fe2:	0f 88 67 01 00 00    	js     80114f <fork+0x18c>
  800fe8:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800fed:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	75 21                	jne    801017 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ff6:	e8 c0 fc ff ff       	call   800cbb <sys_getenvid>
  800ffb:	25 ff 03 00 00       	and    $0x3ff,%eax
  801000:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801003:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801008:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  80100d:	ba 00 00 00 00       	mov    $0x0,%edx
  801012:	e9 42 01 00 00       	jmp    801159 <fork+0x196>
  801017:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80101a:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  80101c:	89 d8                	mov    %ebx,%eax
  80101e:	c1 e8 16             	shr    $0x16,%eax
  801021:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801028:	a8 01                	test   $0x1,%al
  80102a:	0f 84 c0 00 00 00    	je     8010f0 <fork+0x12d>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  801030:	89 d8                	mov    %ebx,%eax
  801032:	c1 e8 0c             	shr    $0xc,%eax
  801035:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80103c:	f6 c2 01             	test   $0x1,%dl
  80103f:	0f 84 ab 00 00 00    	je     8010f0 <fork+0x12d>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
  801045:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80104c:	a9 02 08 00 00       	test   $0x802,%eax
  801051:	0f 84 99 00 00 00    	je     8010f0 <fork+0x12d>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  801057:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80105e:	f6 c4 04             	test   $0x4,%ah
  801061:	74 17                	je     80107a <fork+0xb7>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  801063:	83 ec 0c             	sub    $0xc,%esp
  801066:	68 07 0e 00 00       	push   $0xe07
  80106b:	53                   	push   %ebx
  80106c:	57                   	push   %edi
  80106d:	53                   	push   %ebx
  80106e:	6a 00                	push   $0x0
  801070:	e8 c7 fc ff ff       	call   800d3c <sys_page_map>
  801075:	83 c4 20             	add    $0x20,%esp
  801078:	eb 76                	jmp    8010f0 <fork+0x12d>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  80107a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801081:	a8 02                	test   $0x2,%al
  801083:	75 0c                	jne    801091 <fork+0xce>
  801085:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80108c:	f6 c4 08             	test   $0x8,%ah
  80108f:	74 3f                	je     8010d0 <fork+0x10d>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801091:	83 ec 0c             	sub    $0xc,%esp
  801094:	68 05 08 00 00       	push   $0x805
  801099:	53                   	push   %ebx
  80109a:	57                   	push   %edi
  80109b:	53                   	push   %ebx
  80109c:	6a 00                	push   $0x0
  80109e:	e8 99 fc ff ff       	call   800d3c <sys_page_map>
		if (r < 0)
  8010a3:	83 c4 20             	add    $0x20,%esp
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	0f 88 a5 00 00 00    	js     801153 <fork+0x190>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  8010ae:	83 ec 0c             	sub    $0xc,%esp
  8010b1:	68 05 08 00 00       	push   $0x805
  8010b6:	53                   	push   %ebx
  8010b7:	6a 00                	push   $0x0
  8010b9:	53                   	push   %ebx
  8010ba:	6a 00                	push   $0x0
  8010bc:	e8 7b fc ff ff       	call   800d3c <sys_page_map>
  8010c1:	83 c4 20             	add    $0x20,%esp
  8010c4:	85 c0                	test   %eax,%eax
  8010c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010cb:	0f 4f c1             	cmovg  %ecx,%eax
  8010ce:	eb 1c                	jmp    8010ec <fork+0x129>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  8010d0:	83 ec 0c             	sub    $0xc,%esp
  8010d3:	6a 05                	push   $0x5
  8010d5:	53                   	push   %ebx
  8010d6:	57                   	push   %edi
  8010d7:	53                   	push   %ebx
  8010d8:	6a 00                	push   $0x0
  8010da:	e8 5d fc ff ff       	call   800d3c <sys_page_map>
  8010df:	83 c4 20             	add    $0x20,%esp
  8010e2:	85 c0                	test   %eax,%eax
  8010e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010e9:	0f 4f c1             	cmovg  %ecx,%eax
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  8010ec:	85 c0                	test   %eax,%eax
  8010ee:	78 67                	js     801157 <fork+0x194>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  8010f0:	83 c6 01             	add    $0x1,%esi
  8010f3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010f9:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  8010ff:	0f 85 17 ff ff ff    	jne    80101c <fork+0x59>
  801105:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  801108:	83 ec 04             	sub    $0x4,%esp
  80110b:	6a 07                	push   $0x7
  80110d:	68 00 f0 bf ee       	push   $0xeebff000
  801112:	57                   	push   %edi
  801113:	e8 e1 fb ff ff       	call   800cf9 <sys_page_alloc>
	if (r < 0)
  801118:	83 c4 10             	add    $0x10,%esp
		return r;
  80111b:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  80111d:	85 c0                	test   %eax,%eax
  80111f:	78 38                	js     801159 <fork+0x196>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801121:	83 ec 08             	sub    $0x8,%esp
  801124:	68 a1 1e 80 00       	push   $0x801ea1
  801129:	57                   	push   %edi
  80112a:	e8 15 fd ff ff       	call   800e44 <sys_env_set_pgfault_upcall>
	if (r < 0)
  80112f:	83 c4 10             	add    $0x10,%esp
		return r;
  801132:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  801134:	85 c0                	test   %eax,%eax
  801136:	78 21                	js     801159 <fork+0x196>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801138:	83 ec 08             	sub    $0x8,%esp
  80113b:	6a 02                	push   $0x2
  80113d:	57                   	push   %edi
  80113e:	e8 7d fc ff ff       	call   800dc0 <sys_env_set_status>
	if (r < 0)
  801143:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801146:	85 c0                	test   %eax,%eax
  801148:	0f 48 f8             	cmovs  %eax,%edi
  80114b:	89 fa                	mov    %edi,%edx
  80114d:	eb 0a                	jmp    801159 <fork+0x196>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  80114f:	89 c2                	mov    %eax,%edx
  801151:	eb 06                	jmp    801159 <fork+0x196>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801153:	89 c2                	mov    %eax,%edx
  801155:	eb 02                	jmp    801159 <fork+0x196>
  801157:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  801159:	89 d0                	mov    %edx,%eax
  80115b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115e:	5b                   	pop    %ebx
  80115f:	5e                   	pop    %esi
  801160:	5f                   	pop    %edi
  801161:	5d                   	pop    %ebp
  801162:	c3                   	ret    

00801163 <sfork>:

// Challenge!
int
sfork(void)
{
  801163:	55                   	push   %ebp
  801164:	89 e5                	mov    %esp,%ebp
  801166:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801169:	68 4b 27 80 00       	push   $0x80274b
  80116e:	68 c6 00 00 00       	push   $0xc6
  801173:	68 40 27 80 00       	push   $0x802740
  801178:	e8 1b f1 ff ff       	call   800298 <_panic>

0080117d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80117d:	55                   	push   %ebp
  80117e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801180:	8b 45 08             	mov    0x8(%ebp),%eax
  801183:	05 00 00 00 30       	add    $0x30000000,%eax
  801188:	c1 e8 0c             	shr    $0xc,%eax
}
  80118b:	5d                   	pop    %ebp
  80118c:	c3                   	ret    

0080118d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80118d:	55                   	push   %ebp
  80118e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801190:	8b 45 08             	mov    0x8(%ebp),%eax
  801193:	05 00 00 00 30       	add    $0x30000000,%eax
  801198:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80119d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011a2:	5d                   	pop    %ebp
  8011a3:	c3                   	ret    

008011a4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011aa:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011af:	89 c2                	mov    %eax,%edx
  8011b1:	c1 ea 16             	shr    $0x16,%edx
  8011b4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011bb:	f6 c2 01             	test   $0x1,%dl
  8011be:	74 11                	je     8011d1 <fd_alloc+0x2d>
  8011c0:	89 c2                	mov    %eax,%edx
  8011c2:	c1 ea 0c             	shr    $0xc,%edx
  8011c5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011cc:	f6 c2 01             	test   $0x1,%dl
  8011cf:	75 09                	jne    8011da <fd_alloc+0x36>
			*fd_store = fd;
  8011d1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d8:	eb 17                	jmp    8011f1 <fd_alloc+0x4d>
  8011da:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011df:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011e4:	75 c9                	jne    8011af <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011e6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011ec:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011f1:	5d                   	pop    %ebp
  8011f2:	c3                   	ret    

008011f3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011f9:	83 f8 1f             	cmp    $0x1f,%eax
  8011fc:	77 36                	ja     801234 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011fe:	c1 e0 0c             	shl    $0xc,%eax
  801201:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801206:	89 c2                	mov    %eax,%edx
  801208:	c1 ea 16             	shr    $0x16,%edx
  80120b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801212:	f6 c2 01             	test   $0x1,%dl
  801215:	74 24                	je     80123b <fd_lookup+0x48>
  801217:	89 c2                	mov    %eax,%edx
  801219:	c1 ea 0c             	shr    $0xc,%edx
  80121c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801223:	f6 c2 01             	test   $0x1,%dl
  801226:	74 1a                	je     801242 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801228:	8b 55 0c             	mov    0xc(%ebp),%edx
  80122b:	89 02                	mov    %eax,(%edx)
	return 0;
  80122d:	b8 00 00 00 00       	mov    $0x0,%eax
  801232:	eb 13                	jmp    801247 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801234:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801239:	eb 0c                	jmp    801247 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80123b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801240:	eb 05                	jmp    801247 <fd_lookup+0x54>
  801242:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801247:	5d                   	pop    %ebp
  801248:	c3                   	ret    

00801249 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	83 ec 08             	sub    $0x8,%esp
  80124f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801252:	ba e4 27 80 00       	mov    $0x8027e4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801257:	eb 13                	jmp    80126c <dev_lookup+0x23>
  801259:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80125c:	39 08                	cmp    %ecx,(%eax)
  80125e:	75 0c                	jne    80126c <dev_lookup+0x23>
			*dev = devtab[i];
  801260:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801263:	89 01                	mov    %eax,(%ecx)
			return 0;
  801265:	b8 00 00 00 00       	mov    $0x0,%eax
  80126a:	eb 2e                	jmp    80129a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80126c:	8b 02                	mov    (%edx),%eax
  80126e:	85 c0                	test   %eax,%eax
  801270:	75 e7                	jne    801259 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801272:	a1 04 40 80 00       	mov    0x804004,%eax
  801277:	8b 40 48             	mov    0x48(%eax),%eax
  80127a:	83 ec 04             	sub    $0x4,%esp
  80127d:	51                   	push   %ecx
  80127e:	50                   	push   %eax
  80127f:	68 64 27 80 00       	push   $0x802764
  801284:	e8 e8 f0 ff ff       	call   800371 <cprintf>
	*dev = 0;
  801289:	8b 45 0c             	mov    0xc(%ebp),%eax
  80128c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801292:	83 c4 10             	add    $0x10,%esp
  801295:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80129a:	c9                   	leave  
  80129b:	c3                   	ret    

0080129c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	56                   	push   %esi
  8012a0:	53                   	push   %ebx
  8012a1:	83 ec 10             	sub    $0x10,%esp
  8012a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ad:	50                   	push   %eax
  8012ae:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012b4:	c1 e8 0c             	shr    $0xc,%eax
  8012b7:	50                   	push   %eax
  8012b8:	e8 36 ff ff ff       	call   8011f3 <fd_lookup>
  8012bd:	83 c4 08             	add    $0x8,%esp
  8012c0:	85 c0                	test   %eax,%eax
  8012c2:	78 05                	js     8012c9 <fd_close+0x2d>
	    || fd != fd2)
  8012c4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012c7:	74 0c                	je     8012d5 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012c9:	84 db                	test   %bl,%bl
  8012cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d0:	0f 44 c2             	cmove  %edx,%eax
  8012d3:	eb 41                	jmp    801316 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012d5:	83 ec 08             	sub    $0x8,%esp
  8012d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012db:	50                   	push   %eax
  8012dc:	ff 36                	pushl  (%esi)
  8012de:	e8 66 ff ff ff       	call   801249 <dev_lookup>
  8012e3:	89 c3                	mov    %eax,%ebx
  8012e5:	83 c4 10             	add    $0x10,%esp
  8012e8:	85 c0                	test   %eax,%eax
  8012ea:	78 1a                	js     801306 <fd_close+0x6a>
		if (dev->dev_close)
  8012ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ef:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012f2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	74 0b                	je     801306 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012fb:	83 ec 0c             	sub    $0xc,%esp
  8012fe:	56                   	push   %esi
  8012ff:	ff d0                	call   *%eax
  801301:	89 c3                	mov    %eax,%ebx
  801303:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801306:	83 ec 08             	sub    $0x8,%esp
  801309:	56                   	push   %esi
  80130a:	6a 00                	push   $0x0
  80130c:	e8 6d fa ff ff       	call   800d7e <sys_page_unmap>
	return r;
  801311:	83 c4 10             	add    $0x10,%esp
  801314:	89 d8                	mov    %ebx,%eax
}
  801316:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801319:	5b                   	pop    %ebx
  80131a:	5e                   	pop    %esi
  80131b:	5d                   	pop    %ebp
  80131c:	c3                   	ret    

0080131d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80131d:	55                   	push   %ebp
  80131e:	89 e5                	mov    %esp,%ebp
  801320:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801323:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801326:	50                   	push   %eax
  801327:	ff 75 08             	pushl  0x8(%ebp)
  80132a:	e8 c4 fe ff ff       	call   8011f3 <fd_lookup>
  80132f:	83 c4 08             	add    $0x8,%esp
  801332:	85 c0                	test   %eax,%eax
  801334:	78 10                	js     801346 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801336:	83 ec 08             	sub    $0x8,%esp
  801339:	6a 01                	push   $0x1
  80133b:	ff 75 f4             	pushl  -0xc(%ebp)
  80133e:	e8 59 ff ff ff       	call   80129c <fd_close>
  801343:	83 c4 10             	add    $0x10,%esp
}
  801346:	c9                   	leave  
  801347:	c3                   	ret    

00801348 <close_all>:

void
close_all(void)
{
  801348:	55                   	push   %ebp
  801349:	89 e5                	mov    %esp,%ebp
  80134b:	53                   	push   %ebx
  80134c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80134f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801354:	83 ec 0c             	sub    $0xc,%esp
  801357:	53                   	push   %ebx
  801358:	e8 c0 ff ff ff       	call   80131d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80135d:	83 c3 01             	add    $0x1,%ebx
  801360:	83 c4 10             	add    $0x10,%esp
  801363:	83 fb 20             	cmp    $0x20,%ebx
  801366:	75 ec                	jne    801354 <close_all+0xc>
		close(i);
}
  801368:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80136b:	c9                   	leave  
  80136c:	c3                   	ret    

0080136d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80136d:	55                   	push   %ebp
  80136e:	89 e5                	mov    %esp,%ebp
  801370:	57                   	push   %edi
  801371:	56                   	push   %esi
  801372:	53                   	push   %ebx
  801373:	83 ec 2c             	sub    $0x2c,%esp
  801376:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801379:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80137c:	50                   	push   %eax
  80137d:	ff 75 08             	pushl  0x8(%ebp)
  801380:	e8 6e fe ff ff       	call   8011f3 <fd_lookup>
  801385:	83 c4 08             	add    $0x8,%esp
  801388:	85 c0                	test   %eax,%eax
  80138a:	0f 88 c1 00 00 00    	js     801451 <dup+0xe4>
		return r;
	close(newfdnum);
  801390:	83 ec 0c             	sub    $0xc,%esp
  801393:	56                   	push   %esi
  801394:	e8 84 ff ff ff       	call   80131d <close>

	newfd = INDEX2FD(newfdnum);
  801399:	89 f3                	mov    %esi,%ebx
  80139b:	c1 e3 0c             	shl    $0xc,%ebx
  80139e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013a4:	83 c4 04             	add    $0x4,%esp
  8013a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013aa:	e8 de fd ff ff       	call   80118d <fd2data>
  8013af:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013b1:	89 1c 24             	mov    %ebx,(%esp)
  8013b4:	e8 d4 fd ff ff       	call   80118d <fd2data>
  8013b9:	83 c4 10             	add    $0x10,%esp
  8013bc:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013bf:	89 f8                	mov    %edi,%eax
  8013c1:	c1 e8 16             	shr    $0x16,%eax
  8013c4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013cb:	a8 01                	test   $0x1,%al
  8013cd:	74 37                	je     801406 <dup+0x99>
  8013cf:	89 f8                	mov    %edi,%eax
  8013d1:	c1 e8 0c             	shr    $0xc,%eax
  8013d4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013db:	f6 c2 01             	test   $0x1,%dl
  8013de:	74 26                	je     801406 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013e0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e7:	83 ec 0c             	sub    $0xc,%esp
  8013ea:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ef:	50                   	push   %eax
  8013f0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013f3:	6a 00                	push   $0x0
  8013f5:	57                   	push   %edi
  8013f6:	6a 00                	push   $0x0
  8013f8:	e8 3f f9 ff ff       	call   800d3c <sys_page_map>
  8013fd:	89 c7                	mov    %eax,%edi
  8013ff:	83 c4 20             	add    $0x20,%esp
  801402:	85 c0                	test   %eax,%eax
  801404:	78 2e                	js     801434 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801406:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801409:	89 d0                	mov    %edx,%eax
  80140b:	c1 e8 0c             	shr    $0xc,%eax
  80140e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801415:	83 ec 0c             	sub    $0xc,%esp
  801418:	25 07 0e 00 00       	and    $0xe07,%eax
  80141d:	50                   	push   %eax
  80141e:	53                   	push   %ebx
  80141f:	6a 00                	push   $0x0
  801421:	52                   	push   %edx
  801422:	6a 00                	push   $0x0
  801424:	e8 13 f9 ff ff       	call   800d3c <sys_page_map>
  801429:	89 c7                	mov    %eax,%edi
  80142b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80142e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801430:	85 ff                	test   %edi,%edi
  801432:	79 1d                	jns    801451 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801434:	83 ec 08             	sub    $0x8,%esp
  801437:	53                   	push   %ebx
  801438:	6a 00                	push   $0x0
  80143a:	e8 3f f9 ff ff       	call   800d7e <sys_page_unmap>
	sys_page_unmap(0, nva);
  80143f:	83 c4 08             	add    $0x8,%esp
  801442:	ff 75 d4             	pushl  -0x2c(%ebp)
  801445:	6a 00                	push   $0x0
  801447:	e8 32 f9 ff ff       	call   800d7e <sys_page_unmap>
	return r;
  80144c:	83 c4 10             	add    $0x10,%esp
  80144f:	89 f8                	mov    %edi,%eax
}
  801451:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801454:	5b                   	pop    %ebx
  801455:	5e                   	pop    %esi
  801456:	5f                   	pop    %edi
  801457:	5d                   	pop    %ebp
  801458:	c3                   	ret    

00801459 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801459:	55                   	push   %ebp
  80145a:	89 e5                	mov    %esp,%ebp
  80145c:	53                   	push   %ebx
  80145d:	83 ec 14             	sub    $0x14,%esp
  801460:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801463:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801466:	50                   	push   %eax
  801467:	53                   	push   %ebx
  801468:	e8 86 fd ff ff       	call   8011f3 <fd_lookup>
  80146d:	83 c4 08             	add    $0x8,%esp
  801470:	89 c2                	mov    %eax,%edx
  801472:	85 c0                	test   %eax,%eax
  801474:	78 6d                	js     8014e3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801476:	83 ec 08             	sub    $0x8,%esp
  801479:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147c:	50                   	push   %eax
  80147d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801480:	ff 30                	pushl  (%eax)
  801482:	e8 c2 fd ff ff       	call   801249 <dev_lookup>
  801487:	83 c4 10             	add    $0x10,%esp
  80148a:	85 c0                	test   %eax,%eax
  80148c:	78 4c                	js     8014da <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80148e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801491:	8b 42 08             	mov    0x8(%edx),%eax
  801494:	83 e0 03             	and    $0x3,%eax
  801497:	83 f8 01             	cmp    $0x1,%eax
  80149a:	75 21                	jne    8014bd <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80149c:	a1 04 40 80 00       	mov    0x804004,%eax
  8014a1:	8b 40 48             	mov    0x48(%eax),%eax
  8014a4:	83 ec 04             	sub    $0x4,%esp
  8014a7:	53                   	push   %ebx
  8014a8:	50                   	push   %eax
  8014a9:	68 a8 27 80 00       	push   $0x8027a8
  8014ae:	e8 be ee ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  8014b3:	83 c4 10             	add    $0x10,%esp
  8014b6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014bb:	eb 26                	jmp    8014e3 <read+0x8a>
	}
	if (!dev->dev_read)
  8014bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c0:	8b 40 08             	mov    0x8(%eax),%eax
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	74 17                	je     8014de <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014c7:	83 ec 04             	sub    $0x4,%esp
  8014ca:	ff 75 10             	pushl  0x10(%ebp)
  8014cd:	ff 75 0c             	pushl  0xc(%ebp)
  8014d0:	52                   	push   %edx
  8014d1:	ff d0                	call   *%eax
  8014d3:	89 c2                	mov    %eax,%edx
  8014d5:	83 c4 10             	add    $0x10,%esp
  8014d8:	eb 09                	jmp    8014e3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014da:	89 c2                	mov    %eax,%edx
  8014dc:	eb 05                	jmp    8014e3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014de:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014e3:	89 d0                	mov    %edx,%eax
  8014e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e8:	c9                   	leave  
  8014e9:	c3                   	ret    

008014ea <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014ea:	55                   	push   %ebp
  8014eb:	89 e5                	mov    %esp,%ebp
  8014ed:	57                   	push   %edi
  8014ee:	56                   	push   %esi
  8014ef:	53                   	push   %ebx
  8014f0:	83 ec 0c             	sub    $0xc,%esp
  8014f3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014f6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014fe:	eb 21                	jmp    801521 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801500:	83 ec 04             	sub    $0x4,%esp
  801503:	89 f0                	mov    %esi,%eax
  801505:	29 d8                	sub    %ebx,%eax
  801507:	50                   	push   %eax
  801508:	89 d8                	mov    %ebx,%eax
  80150a:	03 45 0c             	add    0xc(%ebp),%eax
  80150d:	50                   	push   %eax
  80150e:	57                   	push   %edi
  80150f:	e8 45 ff ff ff       	call   801459 <read>
		if (m < 0)
  801514:	83 c4 10             	add    $0x10,%esp
  801517:	85 c0                	test   %eax,%eax
  801519:	78 10                	js     80152b <readn+0x41>
			return m;
		if (m == 0)
  80151b:	85 c0                	test   %eax,%eax
  80151d:	74 0a                	je     801529 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80151f:	01 c3                	add    %eax,%ebx
  801521:	39 f3                	cmp    %esi,%ebx
  801523:	72 db                	jb     801500 <readn+0x16>
  801525:	89 d8                	mov    %ebx,%eax
  801527:	eb 02                	jmp    80152b <readn+0x41>
  801529:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80152b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80152e:	5b                   	pop    %ebx
  80152f:	5e                   	pop    %esi
  801530:	5f                   	pop    %edi
  801531:	5d                   	pop    %ebp
  801532:	c3                   	ret    

00801533 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801533:	55                   	push   %ebp
  801534:	89 e5                	mov    %esp,%ebp
  801536:	53                   	push   %ebx
  801537:	83 ec 14             	sub    $0x14,%esp
  80153a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80153d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801540:	50                   	push   %eax
  801541:	53                   	push   %ebx
  801542:	e8 ac fc ff ff       	call   8011f3 <fd_lookup>
  801547:	83 c4 08             	add    $0x8,%esp
  80154a:	89 c2                	mov    %eax,%edx
  80154c:	85 c0                	test   %eax,%eax
  80154e:	78 68                	js     8015b8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801550:	83 ec 08             	sub    $0x8,%esp
  801553:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801556:	50                   	push   %eax
  801557:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155a:	ff 30                	pushl  (%eax)
  80155c:	e8 e8 fc ff ff       	call   801249 <dev_lookup>
  801561:	83 c4 10             	add    $0x10,%esp
  801564:	85 c0                	test   %eax,%eax
  801566:	78 47                	js     8015af <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801568:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80156f:	75 21                	jne    801592 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801571:	a1 04 40 80 00       	mov    0x804004,%eax
  801576:	8b 40 48             	mov    0x48(%eax),%eax
  801579:	83 ec 04             	sub    $0x4,%esp
  80157c:	53                   	push   %ebx
  80157d:	50                   	push   %eax
  80157e:	68 c4 27 80 00       	push   $0x8027c4
  801583:	e8 e9 ed ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  801588:	83 c4 10             	add    $0x10,%esp
  80158b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801590:	eb 26                	jmp    8015b8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801592:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801595:	8b 52 0c             	mov    0xc(%edx),%edx
  801598:	85 d2                	test   %edx,%edx
  80159a:	74 17                	je     8015b3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80159c:	83 ec 04             	sub    $0x4,%esp
  80159f:	ff 75 10             	pushl  0x10(%ebp)
  8015a2:	ff 75 0c             	pushl  0xc(%ebp)
  8015a5:	50                   	push   %eax
  8015a6:	ff d2                	call   *%edx
  8015a8:	89 c2                	mov    %eax,%edx
  8015aa:	83 c4 10             	add    $0x10,%esp
  8015ad:	eb 09                	jmp    8015b8 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015af:	89 c2                	mov    %eax,%edx
  8015b1:	eb 05                	jmp    8015b8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015b3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015b8:	89 d0                	mov    %edx,%eax
  8015ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bd:	c9                   	leave  
  8015be:	c3                   	ret    

008015bf <seek>:

int
seek(int fdnum, off_t offset)
{
  8015bf:	55                   	push   %ebp
  8015c0:	89 e5                	mov    %esp,%ebp
  8015c2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015c5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015c8:	50                   	push   %eax
  8015c9:	ff 75 08             	pushl  0x8(%ebp)
  8015cc:	e8 22 fc ff ff       	call   8011f3 <fd_lookup>
  8015d1:	83 c4 08             	add    $0x8,%esp
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	78 0e                	js     8015e6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015de:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015e6:	c9                   	leave  
  8015e7:	c3                   	ret    

008015e8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015e8:	55                   	push   %ebp
  8015e9:	89 e5                	mov    %esp,%ebp
  8015eb:	53                   	push   %ebx
  8015ec:	83 ec 14             	sub    $0x14,%esp
  8015ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f5:	50                   	push   %eax
  8015f6:	53                   	push   %ebx
  8015f7:	e8 f7 fb ff ff       	call   8011f3 <fd_lookup>
  8015fc:	83 c4 08             	add    $0x8,%esp
  8015ff:	89 c2                	mov    %eax,%edx
  801601:	85 c0                	test   %eax,%eax
  801603:	78 65                	js     80166a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801605:	83 ec 08             	sub    $0x8,%esp
  801608:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160b:	50                   	push   %eax
  80160c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160f:	ff 30                	pushl  (%eax)
  801611:	e8 33 fc ff ff       	call   801249 <dev_lookup>
  801616:	83 c4 10             	add    $0x10,%esp
  801619:	85 c0                	test   %eax,%eax
  80161b:	78 44                	js     801661 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80161d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801620:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801624:	75 21                	jne    801647 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801626:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80162b:	8b 40 48             	mov    0x48(%eax),%eax
  80162e:	83 ec 04             	sub    $0x4,%esp
  801631:	53                   	push   %ebx
  801632:	50                   	push   %eax
  801633:	68 84 27 80 00       	push   $0x802784
  801638:	e8 34 ed ff ff       	call   800371 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80163d:	83 c4 10             	add    $0x10,%esp
  801640:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801645:	eb 23                	jmp    80166a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801647:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80164a:	8b 52 18             	mov    0x18(%edx),%edx
  80164d:	85 d2                	test   %edx,%edx
  80164f:	74 14                	je     801665 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801651:	83 ec 08             	sub    $0x8,%esp
  801654:	ff 75 0c             	pushl  0xc(%ebp)
  801657:	50                   	push   %eax
  801658:	ff d2                	call   *%edx
  80165a:	89 c2                	mov    %eax,%edx
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	eb 09                	jmp    80166a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801661:	89 c2                	mov    %eax,%edx
  801663:	eb 05                	jmp    80166a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801665:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80166a:	89 d0                	mov    %edx,%eax
  80166c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166f:	c9                   	leave  
  801670:	c3                   	ret    

00801671 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	53                   	push   %ebx
  801675:	83 ec 14             	sub    $0x14,%esp
  801678:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80167b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80167e:	50                   	push   %eax
  80167f:	ff 75 08             	pushl  0x8(%ebp)
  801682:	e8 6c fb ff ff       	call   8011f3 <fd_lookup>
  801687:	83 c4 08             	add    $0x8,%esp
  80168a:	89 c2                	mov    %eax,%edx
  80168c:	85 c0                	test   %eax,%eax
  80168e:	78 58                	js     8016e8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801690:	83 ec 08             	sub    $0x8,%esp
  801693:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801696:	50                   	push   %eax
  801697:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169a:	ff 30                	pushl  (%eax)
  80169c:	e8 a8 fb ff ff       	call   801249 <dev_lookup>
  8016a1:	83 c4 10             	add    $0x10,%esp
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	78 37                	js     8016df <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ab:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016af:	74 32                	je     8016e3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016b1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016b4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016bb:	00 00 00 
	stat->st_isdir = 0;
  8016be:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016c5:	00 00 00 
	stat->st_dev = dev;
  8016c8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016ce:	83 ec 08             	sub    $0x8,%esp
  8016d1:	53                   	push   %ebx
  8016d2:	ff 75 f0             	pushl  -0x10(%ebp)
  8016d5:	ff 50 14             	call   *0x14(%eax)
  8016d8:	89 c2                	mov    %eax,%edx
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	eb 09                	jmp    8016e8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016df:	89 c2                	mov    %eax,%edx
  8016e1:	eb 05                	jmp    8016e8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016e3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016e8:	89 d0                	mov    %edx,%eax
  8016ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ed:	c9                   	leave  
  8016ee:	c3                   	ret    

008016ef <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	56                   	push   %esi
  8016f3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016f4:	83 ec 08             	sub    $0x8,%esp
  8016f7:	6a 00                	push   $0x0
  8016f9:	ff 75 08             	pushl  0x8(%ebp)
  8016fc:	e8 d6 01 00 00       	call   8018d7 <open>
  801701:	89 c3                	mov    %eax,%ebx
  801703:	83 c4 10             	add    $0x10,%esp
  801706:	85 c0                	test   %eax,%eax
  801708:	78 1b                	js     801725 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80170a:	83 ec 08             	sub    $0x8,%esp
  80170d:	ff 75 0c             	pushl  0xc(%ebp)
  801710:	50                   	push   %eax
  801711:	e8 5b ff ff ff       	call   801671 <fstat>
  801716:	89 c6                	mov    %eax,%esi
	close(fd);
  801718:	89 1c 24             	mov    %ebx,(%esp)
  80171b:	e8 fd fb ff ff       	call   80131d <close>
	return r;
  801720:	83 c4 10             	add    $0x10,%esp
  801723:	89 f0                	mov    %esi,%eax
}
  801725:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801728:	5b                   	pop    %ebx
  801729:	5e                   	pop    %esi
  80172a:	5d                   	pop    %ebp
  80172b:	c3                   	ret    

0080172c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80172c:	55                   	push   %ebp
  80172d:	89 e5                	mov    %esp,%ebp
  80172f:	56                   	push   %esi
  801730:	53                   	push   %ebx
  801731:	89 c6                	mov    %eax,%esi
  801733:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801735:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80173c:	75 12                	jne    801750 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80173e:	83 ec 0c             	sub    $0xc,%esp
  801741:	6a 01                	push   $0x1
  801743:	e8 38 08 00 00       	call   801f80 <ipc_find_env>
  801748:	a3 00 40 80 00       	mov    %eax,0x804000
  80174d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801750:	6a 07                	push   $0x7
  801752:	68 00 50 80 00       	push   $0x805000
  801757:	56                   	push   %esi
  801758:	ff 35 00 40 80 00    	pushl  0x804000
  80175e:	e8 c9 07 00 00       	call   801f2c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801763:	83 c4 0c             	add    $0xc,%esp
  801766:	6a 00                	push   $0x0
  801768:	53                   	push   %ebx
  801769:	6a 00                	push   $0x0
  80176b:	e8 55 07 00 00       	call   801ec5 <ipc_recv>
}
  801770:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801773:	5b                   	pop    %ebx
  801774:	5e                   	pop    %esi
  801775:	5d                   	pop    %ebp
  801776:	c3                   	ret    

00801777 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801777:	55                   	push   %ebp
  801778:	89 e5                	mov    %esp,%ebp
  80177a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80177d:	8b 45 08             	mov    0x8(%ebp),%eax
  801780:	8b 40 0c             	mov    0xc(%eax),%eax
  801783:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801788:	8b 45 0c             	mov    0xc(%ebp),%eax
  80178b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801790:	ba 00 00 00 00       	mov    $0x0,%edx
  801795:	b8 02 00 00 00       	mov    $0x2,%eax
  80179a:	e8 8d ff ff ff       	call   80172c <fsipc>
}
  80179f:	c9                   	leave  
  8017a0:	c3                   	ret    

008017a1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017a1:	55                   	push   %ebp
  8017a2:	89 e5                	mov    %esp,%ebp
  8017a4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ad:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b7:	b8 06 00 00 00       	mov    $0x6,%eax
  8017bc:	e8 6b ff ff ff       	call   80172c <fsipc>
}
  8017c1:	c9                   	leave  
  8017c2:	c3                   	ret    

008017c3 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017c3:	55                   	push   %ebp
  8017c4:	89 e5                	mov    %esp,%ebp
  8017c6:	53                   	push   %ebx
  8017c7:	83 ec 04             	sub    $0x4,%esp
  8017ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017dd:	b8 05 00 00 00       	mov    $0x5,%eax
  8017e2:	e8 45 ff ff ff       	call   80172c <fsipc>
  8017e7:	85 c0                	test   %eax,%eax
  8017e9:	78 2c                	js     801817 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017eb:	83 ec 08             	sub    $0x8,%esp
  8017ee:	68 00 50 80 00       	push   $0x805000
  8017f3:	53                   	push   %ebx
  8017f4:	e8 fd f0 ff ff       	call   8008f6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017f9:	a1 80 50 80 00       	mov    0x805080,%eax
  8017fe:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801804:	a1 84 50 80 00       	mov    0x805084,%eax
  801809:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80180f:	83 c4 10             	add    $0x10,%esp
  801812:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801817:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80181a:	c9                   	leave  
  80181b:	c3                   	ret    

0080181c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	83 ec 0c             	sub    $0xc,%esp
  801822:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801825:	8b 55 08             	mov    0x8(%ebp),%edx
  801828:	8b 52 0c             	mov    0xc(%edx),%edx
  80182b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801831:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801836:	50                   	push   %eax
  801837:	ff 75 0c             	pushl  0xc(%ebp)
  80183a:	68 08 50 80 00       	push   $0x805008
  80183f:	e8 44 f2 ff ff       	call   800a88 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801844:	ba 00 00 00 00       	mov    $0x0,%edx
  801849:	b8 04 00 00 00       	mov    $0x4,%eax
  80184e:	e8 d9 fe ff ff       	call   80172c <fsipc>

}
  801853:	c9                   	leave  
  801854:	c3                   	ret    

00801855 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	56                   	push   %esi
  801859:	53                   	push   %ebx
  80185a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80185d:	8b 45 08             	mov    0x8(%ebp),%eax
  801860:	8b 40 0c             	mov    0xc(%eax),%eax
  801863:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801868:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80186e:	ba 00 00 00 00       	mov    $0x0,%edx
  801873:	b8 03 00 00 00       	mov    $0x3,%eax
  801878:	e8 af fe ff ff       	call   80172c <fsipc>
  80187d:	89 c3                	mov    %eax,%ebx
  80187f:	85 c0                	test   %eax,%eax
  801881:	78 4b                	js     8018ce <devfile_read+0x79>
		return r;
	assert(r <= n);
  801883:	39 c6                	cmp    %eax,%esi
  801885:	73 16                	jae    80189d <devfile_read+0x48>
  801887:	68 f4 27 80 00       	push   $0x8027f4
  80188c:	68 fb 27 80 00       	push   $0x8027fb
  801891:	6a 7c                	push   $0x7c
  801893:	68 10 28 80 00       	push   $0x802810
  801898:	e8 fb e9 ff ff       	call   800298 <_panic>
	assert(r <= PGSIZE);
  80189d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018a2:	7e 16                	jle    8018ba <devfile_read+0x65>
  8018a4:	68 1b 28 80 00       	push   $0x80281b
  8018a9:	68 fb 27 80 00       	push   $0x8027fb
  8018ae:	6a 7d                	push   $0x7d
  8018b0:	68 10 28 80 00       	push   $0x802810
  8018b5:	e8 de e9 ff ff       	call   800298 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018ba:	83 ec 04             	sub    $0x4,%esp
  8018bd:	50                   	push   %eax
  8018be:	68 00 50 80 00       	push   $0x805000
  8018c3:	ff 75 0c             	pushl  0xc(%ebp)
  8018c6:	e8 bd f1 ff ff       	call   800a88 <memmove>
	return r;
  8018cb:	83 c4 10             	add    $0x10,%esp
}
  8018ce:	89 d8                	mov    %ebx,%eax
  8018d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d3:	5b                   	pop    %ebx
  8018d4:	5e                   	pop    %esi
  8018d5:	5d                   	pop    %ebp
  8018d6:	c3                   	ret    

008018d7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018d7:	55                   	push   %ebp
  8018d8:	89 e5                	mov    %esp,%ebp
  8018da:	53                   	push   %ebx
  8018db:	83 ec 20             	sub    $0x20,%esp
  8018de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018e1:	53                   	push   %ebx
  8018e2:	e8 d6 ef ff ff       	call   8008bd <strlen>
  8018e7:	83 c4 10             	add    $0x10,%esp
  8018ea:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018ef:	7f 67                	jg     801958 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018f1:	83 ec 0c             	sub    $0xc,%esp
  8018f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f7:	50                   	push   %eax
  8018f8:	e8 a7 f8 ff ff       	call   8011a4 <fd_alloc>
  8018fd:	83 c4 10             	add    $0x10,%esp
		return r;
  801900:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801902:	85 c0                	test   %eax,%eax
  801904:	78 57                	js     80195d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801906:	83 ec 08             	sub    $0x8,%esp
  801909:	53                   	push   %ebx
  80190a:	68 00 50 80 00       	push   $0x805000
  80190f:	e8 e2 ef ff ff       	call   8008f6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801914:	8b 45 0c             	mov    0xc(%ebp),%eax
  801917:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80191c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80191f:	b8 01 00 00 00       	mov    $0x1,%eax
  801924:	e8 03 fe ff ff       	call   80172c <fsipc>
  801929:	89 c3                	mov    %eax,%ebx
  80192b:	83 c4 10             	add    $0x10,%esp
  80192e:	85 c0                	test   %eax,%eax
  801930:	79 14                	jns    801946 <open+0x6f>
		fd_close(fd, 0);
  801932:	83 ec 08             	sub    $0x8,%esp
  801935:	6a 00                	push   $0x0
  801937:	ff 75 f4             	pushl  -0xc(%ebp)
  80193a:	e8 5d f9 ff ff       	call   80129c <fd_close>
		return r;
  80193f:	83 c4 10             	add    $0x10,%esp
  801942:	89 da                	mov    %ebx,%edx
  801944:	eb 17                	jmp    80195d <open+0x86>
	}

	return fd2num(fd);
  801946:	83 ec 0c             	sub    $0xc,%esp
  801949:	ff 75 f4             	pushl  -0xc(%ebp)
  80194c:	e8 2c f8 ff ff       	call   80117d <fd2num>
  801951:	89 c2                	mov    %eax,%edx
  801953:	83 c4 10             	add    $0x10,%esp
  801956:	eb 05                	jmp    80195d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801958:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80195d:	89 d0                	mov    %edx,%eax
  80195f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801962:	c9                   	leave  
  801963:	c3                   	ret    

00801964 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80196a:	ba 00 00 00 00       	mov    $0x0,%edx
  80196f:	b8 08 00 00 00       	mov    $0x8,%eax
  801974:	e8 b3 fd ff ff       	call   80172c <fsipc>
}
  801979:	c9                   	leave  
  80197a:	c3                   	ret    

0080197b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80197b:	55                   	push   %ebp
  80197c:	89 e5                	mov    %esp,%ebp
  80197e:	56                   	push   %esi
  80197f:	53                   	push   %ebx
  801980:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801983:	83 ec 0c             	sub    $0xc,%esp
  801986:	ff 75 08             	pushl  0x8(%ebp)
  801989:	e8 ff f7 ff ff       	call   80118d <fd2data>
  80198e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801990:	83 c4 08             	add    $0x8,%esp
  801993:	68 27 28 80 00       	push   $0x802827
  801998:	53                   	push   %ebx
  801999:	e8 58 ef ff ff       	call   8008f6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80199e:	8b 46 04             	mov    0x4(%esi),%eax
  8019a1:	2b 06                	sub    (%esi),%eax
  8019a3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019a9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019b0:	00 00 00 
	stat->st_dev = &devpipe;
  8019b3:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019ba:	30 80 00 
	return 0;
}
  8019bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c5:	5b                   	pop    %ebx
  8019c6:	5e                   	pop    %esi
  8019c7:	5d                   	pop    %ebp
  8019c8:	c3                   	ret    

008019c9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019c9:	55                   	push   %ebp
  8019ca:	89 e5                	mov    %esp,%ebp
  8019cc:	53                   	push   %ebx
  8019cd:	83 ec 0c             	sub    $0xc,%esp
  8019d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019d3:	53                   	push   %ebx
  8019d4:	6a 00                	push   $0x0
  8019d6:	e8 a3 f3 ff ff       	call   800d7e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019db:	89 1c 24             	mov    %ebx,(%esp)
  8019de:	e8 aa f7 ff ff       	call   80118d <fd2data>
  8019e3:	83 c4 08             	add    $0x8,%esp
  8019e6:	50                   	push   %eax
  8019e7:	6a 00                	push   $0x0
  8019e9:	e8 90 f3 ff ff       	call   800d7e <sys_page_unmap>
}
  8019ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f1:	c9                   	leave  
  8019f2:	c3                   	ret    

008019f3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019f3:	55                   	push   %ebp
  8019f4:	89 e5                	mov    %esp,%ebp
  8019f6:	57                   	push   %edi
  8019f7:	56                   	push   %esi
  8019f8:	53                   	push   %ebx
  8019f9:	83 ec 1c             	sub    $0x1c,%esp
  8019fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019ff:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a01:	a1 04 40 80 00       	mov    0x804004,%eax
  801a06:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a09:	83 ec 0c             	sub    $0xc,%esp
  801a0c:	ff 75 e0             	pushl  -0x20(%ebp)
  801a0f:	e8 a5 05 00 00       	call   801fb9 <pageref>
  801a14:	89 c3                	mov    %eax,%ebx
  801a16:	89 3c 24             	mov    %edi,(%esp)
  801a19:	e8 9b 05 00 00       	call   801fb9 <pageref>
  801a1e:	83 c4 10             	add    $0x10,%esp
  801a21:	39 c3                	cmp    %eax,%ebx
  801a23:	0f 94 c1             	sete   %cl
  801a26:	0f b6 c9             	movzbl %cl,%ecx
  801a29:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a2c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a32:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a35:	39 ce                	cmp    %ecx,%esi
  801a37:	74 1b                	je     801a54 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a39:	39 c3                	cmp    %eax,%ebx
  801a3b:	75 c4                	jne    801a01 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a3d:	8b 42 58             	mov    0x58(%edx),%eax
  801a40:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a43:	50                   	push   %eax
  801a44:	56                   	push   %esi
  801a45:	68 2e 28 80 00       	push   $0x80282e
  801a4a:	e8 22 e9 ff ff       	call   800371 <cprintf>
  801a4f:	83 c4 10             	add    $0x10,%esp
  801a52:	eb ad                	jmp    801a01 <_pipeisclosed+0xe>
	}
}
  801a54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a5a:	5b                   	pop    %ebx
  801a5b:	5e                   	pop    %esi
  801a5c:	5f                   	pop    %edi
  801a5d:	5d                   	pop    %ebp
  801a5e:	c3                   	ret    

00801a5f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	57                   	push   %edi
  801a63:	56                   	push   %esi
  801a64:	53                   	push   %ebx
  801a65:	83 ec 28             	sub    $0x28,%esp
  801a68:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a6b:	56                   	push   %esi
  801a6c:	e8 1c f7 ff ff       	call   80118d <fd2data>
  801a71:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a73:	83 c4 10             	add    $0x10,%esp
  801a76:	bf 00 00 00 00       	mov    $0x0,%edi
  801a7b:	eb 4b                	jmp    801ac8 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a7d:	89 da                	mov    %ebx,%edx
  801a7f:	89 f0                	mov    %esi,%eax
  801a81:	e8 6d ff ff ff       	call   8019f3 <_pipeisclosed>
  801a86:	85 c0                	test   %eax,%eax
  801a88:	75 48                	jne    801ad2 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a8a:	e8 4b f2 ff ff       	call   800cda <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a8f:	8b 43 04             	mov    0x4(%ebx),%eax
  801a92:	8b 0b                	mov    (%ebx),%ecx
  801a94:	8d 51 20             	lea    0x20(%ecx),%edx
  801a97:	39 d0                	cmp    %edx,%eax
  801a99:	73 e2                	jae    801a7d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a9e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801aa2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801aa5:	89 c2                	mov    %eax,%edx
  801aa7:	c1 fa 1f             	sar    $0x1f,%edx
  801aaa:	89 d1                	mov    %edx,%ecx
  801aac:	c1 e9 1b             	shr    $0x1b,%ecx
  801aaf:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ab2:	83 e2 1f             	and    $0x1f,%edx
  801ab5:	29 ca                	sub    %ecx,%edx
  801ab7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801abb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801abf:	83 c0 01             	add    $0x1,%eax
  801ac2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac5:	83 c7 01             	add    $0x1,%edi
  801ac8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801acb:	75 c2                	jne    801a8f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801acd:	8b 45 10             	mov    0x10(%ebp),%eax
  801ad0:	eb 05                	jmp    801ad7 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ad2:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ad7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ada:	5b                   	pop    %ebx
  801adb:	5e                   	pop    %esi
  801adc:	5f                   	pop    %edi
  801add:	5d                   	pop    %ebp
  801ade:	c3                   	ret    

00801adf <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	57                   	push   %edi
  801ae3:	56                   	push   %esi
  801ae4:	53                   	push   %ebx
  801ae5:	83 ec 18             	sub    $0x18,%esp
  801ae8:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801aeb:	57                   	push   %edi
  801aec:	e8 9c f6 ff ff       	call   80118d <fd2data>
  801af1:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801af3:	83 c4 10             	add    $0x10,%esp
  801af6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801afb:	eb 3d                	jmp    801b3a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801afd:	85 db                	test   %ebx,%ebx
  801aff:	74 04                	je     801b05 <devpipe_read+0x26>
				return i;
  801b01:	89 d8                	mov    %ebx,%eax
  801b03:	eb 44                	jmp    801b49 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b05:	89 f2                	mov    %esi,%edx
  801b07:	89 f8                	mov    %edi,%eax
  801b09:	e8 e5 fe ff ff       	call   8019f3 <_pipeisclosed>
  801b0e:	85 c0                	test   %eax,%eax
  801b10:	75 32                	jne    801b44 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b12:	e8 c3 f1 ff ff       	call   800cda <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b17:	8b 06                	mov    (%esi),%eax
  801b19:	3b 46 04             	cmp    0x4(%esi),%eax
  801b1c:	74 df                	je     801afd <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b1e:	99                   	cltd   
  801b1f:	c1 ea 1b             	shr    $0x1b,%edx
  801b22:	01 d0                	add    %edx,%eax
  801b24:	83 e0 1f             	and    $0x1f,%eax
  801b27:	29 d0                	sub    %edx,%eax
  801b29:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b31:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b34:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b37:	83 c3 01             	add    $0x1,%ebx
  801b3a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b3d:	75 d8                	jne    801b17 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b3f:	8b 45 10             	mov    0x10(%ebp),%eax
  801b42:	eb 05                	jmp    801b49 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b44:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b4c:	5b                   	pop    %ebx
  801b4d:	5e                   	pop    %esi
  801b4e:	5f                   	pop    %edi
  801b4f:	5d                   	pop    %ebp
  801b50:	c3                   	ret    

00801b51 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	56                   	push   %esi
  801b55:	53                   	push   %ebx
  801b56:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b5c:	50                   	push   %eax
  801b5d:	e8 42 f6 ff ff       	call   8011a4 <fd_alloc>
  801b62:	83 c4 10             	add    $0x10,%esp
  801b65:	89 c2                	mov    %eax,%edx
  801b67:	85 c0                	test   %eax,%eax
  801b69:	0f 88 2c 01 00 00    	js     801c9b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b6f:	83 ec 04             	sub    $0x4,%esp
  801b72:	68 07 04 00 00       	push   $0x407
  801b77:	ff 75 f4             	pushl  -0xc(%ebp)
  801b7a:	6a 00                	push   $0x0
  801b7c:	e8 78 f1 ff ff       	call   800cf9 <sys_page_alloc>
  801b81:	83 c4 10             	add    $0x10,%esp
  801b84:	89 c2                	mov    %eax,%edx
  801b86:	85 c0                	test   %eax,%eax
  801b88:	0f 88 0d 01 00 00    	js     801c9b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b8e:	83 ec 0c             	sub    $0xc,%esp
  801b91:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b94:	50                   	push   %eax
  801b95:	e8 0a f6 ff ff       	call   8011a4 <fd_alloc>
  801b9a:	89 c3                	mov    %eax,%ebx
  801b9c:	83 c4 10             	add    $0x10,%esp
  801b9f:	85 c0                	test   %eax,%eax
  801ba1:	0f 88 e2 00 00 00    	js     801c89 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba7:	83 ec 04             	sub    $0x4,%esp
  801baa:	68 07 04 00 00       	push   $0x407
  801baf:	ff 75 f0             	pushl  -0x10(%ebp)
  801bb2:	6a 00                	push   $0x0
  801bb4:	e8 40 f1 ff ff       	call   800cf9 <sys_page_alloc>
  801bb9:	89 c3                	mov    %eax,%ebx
  801bbb:	83 c4 10             	add    $0x10,%esp
  801bbe:	85 c0                	test   %eax,%eax
  801bc0:	0f 88 c3 00 00 00    	js     801c89 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bc6:	83 ec 0c             	sub    $0xc,%esp
  801bc9:	ff 75 f4             	pushl  -0xc(%ebp)
  801bcc:	e8 bc f5 ff ff       	call   80118d <fd2data>
  801bd1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bd3:	83 c4 0c             	add    $0xc,%esp
  801bd6:	68 07 04 00 00       	push   $0x407
  801bdb:	50                   	push   %eax
  801bdc:	6a 00                	push   $0x0
  801bde:	e8 16 f1 ff ff       	call   800cf9 <sys_page_alloc>
  801be3:	89 c3                	mov    %eax,%ebx
  801be5:	83 c4 10             	add    $0x10,%esp
  801be8:	85 c0                	test   %eax,%eax
  801bea:	0f 88 89 00 00 00    	js     801c79 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf0:	83 ec 0c             	sub    $0xc,%esp
  801bf3:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf6:	e8 92 f5 ff ff       	call   80118d <fd2data>
  801bfb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c02:	50                   	push   %eax
  801c03:	6a 00                	push   $0x0
  801c05:	56                   	push   %esi
  801c06:	6a 00                	push   $0x0
  801c08:	e8 2f f1 ff ff       	call   800d3c <sys_page_map>
  801c0d:	89 c3                	mov    %eax,%ebx
  801c0f:	83 c4 20             	add    $0x20,%esp
  801c12:	85 c0                	test   %eax,%eax
  801c14:	78 55                	js     801c6b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c16:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c24:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c2b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c34:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c36:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c39:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c40:	83 ec 0c             	sub    $0xc,%esp
  801c43:	ff 75 f4             	pushl  -0xc(%ebp)
  801c46:	e8 32 f5 ff ff       	call   80117d <fd2num>
  801c4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c4e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c50:	83 c4 04             	add    $0x4,%esp
  801c53:	ff 75 f0             	pushl  -0x10(%ebp)
  801c56:	e8 22 f5 ff ff       	call   80117d <fd2num>
  801c5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c5e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c61:	83 c4 10             	add    $0x10,%esp
  801c64:	ba 00 00 00 00       	mov    $0x0,%edx
  801c69:	eb 30                	jmp    801c9b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c6b:	83 ec 08             	sub    $0x8,%esp
  801c6e:	56                   	push   %esi
  801c6f:	6a 00                	push   $0x0
  801c71:	e8 08 f1 ff ff       	call   800d7e <sys_page_unmap>
  801c76:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c79:	83 ec 08             	sub    $0x8,%esp
  801c7c:	ff 75 f0             	pushl  -0x10(%ebp)
  801c7f:	6a 00                	push   $0x0
  801c81:	e8 f8 f0 ff ff       	call   800d7e <sys_page_unmap>
  801c86:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c89:	83 ec 08             	sub    $0x8,%esp
  801c8c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c8f:	6a 00                	push   $0x0
  801c91:	e8 e8 f0 ff ff       	call   800d7e <sys_page_unmap>
  801c96:	83 c4 10             	add    $0x10,%esp
  801c99:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c9b:	89 d0                	mov    %edx,%eax
  801c9d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ca0:	5b                   	pop    %ebx
  801ca1:	5e                   	pop    %esi
  801ca2:	5d                   	pop    %ebp
  801ca3:	c3                   	ret    

00801ca4 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ca4:	55                   	push   %ebp
  801ca5:	89 e5                	mov    %esp,%ebp
  801ca7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801caa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cad:	50                   	push   %eax
  801cae:	ff 75 08             	pushl  0x8(%ebp)
  801cb1:	e8 3d f5 ff ff       	call   8011f3 <fd_lookup>
  801cb6:	83 c4 10             	add    $0x10,%esp
  801cb9:	85 c0                	test   %eax,%eax
  801cbb:	78 18                	js     801cd5 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cbd:	83 ec 0c             	sub    $0xc,%esp
  801cc0:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc3:	e8 c5 f4 ff ff       	call   80118d <fd2data>
	return _pipeisclosed(fd, p);
  801cc8:	89 c2                	mov    %eax,%edx
  801cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ccd:	e8 21 fd ff ff       	call   8019f3 <_pipeisclosed>
  801cd2:	83 c4 10             	add    $0x10,%esp
}
  801cd5:	c9                   	leave  
  801cd6:	c3                   	ret    

00801cd7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cd7:	55                   	push   %ebp
  801cd8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cda:	b8 00 00 00 00       	mov    $0x0,%eax
  801cdf:	5d                   	pop    %ebp
  801ce0:	c3                   	ret    

00801ce1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ce1:	55                   	push   %ebp
  801ce2:	89 e5                	mov    %esp,%ebp
  801ce4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ce7:	68 41 28 80 00       	push   $0x802841
  801cec:	ff 75 0c             	pushl  0xc(%ebp)
  801cef:	e8 02 ec ff ff       	call   8008f6 <strcpy>
	return 0;
}
  801cf4:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf9:	c9                   	leave  
  801cfa:	c3                   	ret    

00801cfb <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	57                   	push   %edi
  801cff:	56                   	push   %esi
  801d00:	53                   	push   %ebx
  801d01:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d07:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d0c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d12:	eb 2d                	jmp    801d41 <devcons_write+0x46>
		m = n - tot;
  801d14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d17:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d19:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d1c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d21:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d24:	83 ec 04             	sub    $0x4,%esp
  801d27:	53                   	push   %ebx
  801d28:	03 45 0c             	add    0xc(%ebp),%eax
  801d2b:	50                   	push   %eax
  801d2c:	57                   	push   %edi
  801d2d:	e8 56 ed ff ff       	call   800a88 <memmove>
		sys_cputs(buf, m);
  801d32:	83 c4 08             	add    $0x8,%esp
  801d35:	53                   	push   %ebx
  801d36:	57                   	push   %edi
  801d37:	e8 01 ef ff ff       	call   800c3d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d3c:	01 de                	add    %ebx,%esi
  801d3e:	83 c4 10             	add    $0x10,%esp
  801d41:	89 f0                	mov    %esi,%eax
  801d43:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d46:	72 cc                	jb     801d14 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d4b:	5b                   	pop    %ebx
  801d4c:	5e                   	pop    %esi
  801d4d:	5f                   	pop    %edi
  801d4e:	5d                   	pop    %ebp
  801d4f:	c3                   	ret    

00801d50 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
  801d53:	83 ec 08             	sub    $0x8,%esp
  801d56:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d5b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d5f:	74 2a                	je     801d8b <devcons_read+0x3b>
  801d61:	eb 05                	jmp    801d68 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d63:	e8 72 ef ff ff       	call   800cda <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d68:	e8 ee ee ff ff       	call   800c5b <sys_cgetc>
  801d6d:	85 c0                	test   %eax,%eax
  801d6f:	74 f2                	je     801d63 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d71:	85 c0                	test   %eax,%eax
  801d73:	78 16                	js     801d8b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d75:	83 f8 04             	cmp    $0x4,%eax
  801d78:	74 0c                	je     801d86 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d7d:	88 02                	mov    %al,(%edx)
	return 1;
  801d7f:	b8 01 00 00 00       	mov    $0x1,%eax
  801d84:	eb 05                	jmp    801d8b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d86:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d8b:	c9                   	leave  
  801d8c:	c3                   	ret    

00801d8d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d8d:	55                   	push   %ebp
  801d8e:	89 e5                	mov    %esp,%ebp
  801d90:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d93:	8b 45 08             	mov    0x8(%ebp),%eax
  801d96:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d99:	6a 01                	push   $0x1
  801d9b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d9e:	50                   	push   %eax
  801d9f:	e8 99 ee ff ff       	call   800c3d <sys_cputs>
}
  801da4:	83 c4 10             	add    $0x10,%esp
  801da7:	c9                   	leave  
  801da8:	c3                   	ret    

00801da9 <getchar>:

int
getchar(void)
{
  801da9:	55                   	push   %ebp
  801daa:	89 e5                	mov    %esp,%ebp
  801dac:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801daf:	6a 01                	push   $0x1
  801db1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801db4:	50                   	push   %eax
  801db5:	6a 00                	push   $0x0
  801db7:	e8 9d f6 ff ff       	call   801459 <read>
	if (r < 0)
  801dbc:	83 c4 10             	add    $0x10,%esp
  801dbf:	85 c0                	test   %eax,%eax
  801dc1:	78 0f                	js     801dd2 <getchar+0x29>
		return r;
	if (r < 1)
  801dc3:	85 c0                	test   %eax,%eax
  801dc5:	7e 06                	jle    801dcd <getchar+0x24>
		return -E_EOF;
	return c;
  801dc7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801dcb:	eb 05                	jmp    801dd2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801dcd:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801dd2:	c9                   	leave  
  801dd3:	c3                   	ret    

00801dd4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801dd4:	55                   	push   %ebp
  801dd5:	89 e5                	mov    %esp,%ebp
  801dd7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ddd:	50                   	push   %eax
  801dde:	ff 75 08             	pushl  0x8(%ebp)
  801de1:	e8 0d f4 ff ff       	call   8011f3 <fd_lookup>
  801de6:	83 c4 10             	add    $0x10,%esp
  801de9:	85 c0                	test   %eax,%eax
  801deb:	78 11                	js     801dfe <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ded:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801df6:	39 10                	cmp    %edx,(%eax)
  801df8:	0f 94 c0             	sete   %al
  801dfb:	0f b6 c0             	movzbl %al,%eax
}
  801dfe:	c9                   	leave  
  801dff:	c3                   	ret    

00801e00 <opencons>:

int
opencons(void)
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e06:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e09:	50                   	push   %eax
  801e0a:	e8 95 f3 ff ff       	call   8011a4 <fd_alloc>
  801e0f:	83 c4 10             	add    $0x10,%esp
		return r;
  801e12:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e14:	85 c0                	test   %eax,%eax
  801e16:	78 3e                	js     801e56 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e18:	83 ec 04             	sub    $0x4,%esp
  801e1b:	68 07 04 00 00       	push   $0x407
  801e20:	ff 75 f4             	pushl  -0xc(%ebp)
  801e23:	6a 00                	push   $0x0
  801e25:	e8 cf ee ff ff       	call   800cf9 <sys_page_alloc>
  801e2a:	83 c4 10             	add    $0x10,%esp
		return r;
  801e2d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e2f:	85 c0                	test   %eax,%eax
  801e31:	78 23                	js     801e56 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e33:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e41:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e48:	83 ec 0c             	sub    $0xc,%esp
  801e4b:	50                   	push   %eax
  801e4c:	e8 2c f3 ff ff       	call   80117d <fd2num>
  801e51:	89 c2                	mov    %eax,%edx
  801e53:	83 c4 10             	add    $0x10,%esp
}
  801e56:	89 d0                	mov    %edx,%eax
  801e58:	c9                   	leave  
  801e59:	c3                   	ret    

00801e5a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e5a:	55                   	push   %ebp
  801e5b:	89 e5                	mov    %esp,%ebp
  801e5d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e60:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e67:	75 2e                	jne    801e97 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801e69:	e8 4d ee ff ff       	call   800cbb <sys_getenvid>
  801e6e:	83 ec 04             	sub    $0x4,%esp
  801e71:	68 07 0e 00 00       	push   $0xe07
  801e76:	68 00 f0 bf ee       	push   $0xeebff000
  801e7b:	50                   	push   %eax
  801e7c:	e8 78 ee ff ff       	call   800cf9 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801e81:	e8 35 ee ff ff       	call   800cbb <sys_getenvid>
  801e86:	83 c4 08             	add    $0x8,%esp
  801e89:	68 a1 1e 80 00       	push   $0x801ea1
  801e8e:	50                   	push   %eax
  801e8f:	e8 b0 ef ff ff       	call   800e44 <sys_env_set_pgfault_upcall>
  801e94:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e97:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9a:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e9f:	c9                   	leave  
  801ea0:	c3                   	ret    

00801ea1 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801ea1:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801ea2:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801ea7:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801ea9:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  801eac:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  801eb0:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  801eb4:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  801eb7:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  801eba:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  801ebb:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  801ebe:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  801ebf:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  801ec0:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801ec4:	c3                   	ret    

00801ec5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ec5:	55                   	push   %ebp
  801ec6:	89 e5                	mov    %esp,%ebp
  801ec8:	56                   	push   %esi
  801ec9:	53                   	push   %ebx
  801eca:	8b 75 08             	mov    0x8(%ebp),%esi
  801ecd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ed0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801ed3:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801ed5:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801eda:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801edd:	83 ec 0c             	sub    $0xc,%esp
  801ee0:	50                   	push   %eax
  801ee1:	e8 c3 ef ff ff       	call   800ea9 <sys_ipc_recv>

	if (from_env_store != NULL)
  801ee6:	83 c4 10             	add    $0x10,%esp
  801ee9:	85 f6                	test   %esi,%esi
  801eeb:	74 14                	je     801f01 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801eed:	ba 00 00 00 00       	mov    $0x0,%edx
  801ef2:	85 c0                	test   %eax,%eax
  801ef4:	78 09                	js     801eff <ipc_recv+0x3a>
  801ef6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801efc:	8b 52 74             	mov    0x74(%edx),%edx
  801eff:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801f01:	85 db                	test   %ebx,%ebx
  801f03:	74 14                	je     801f19 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801f05:	ba 00 00 00 00       	mov    $0x0,%edx
  801f0a:	85 c0                	test   %eax,%eax
  801f0c:	78 09                	js     801f17 <ipc_recv+0x52>
  801f0e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801f14:	8b 52 78             	mov    0x78(%edx),%edx
  801f17:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801f19:	85 c0                	test   %eax,%eax
  801f1b:	78 08                	js     801f25 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801f1d:	a1 04 40 80 00       	mov    0x804004,%eax
  801f22:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f25:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f28:	5b                   	pop    %ebx
  801f29:	5e                   	pop    %esi
  801f2a:	5d                   	pop    %ebp
  801f2b:	c3                   	ret    

00801f2c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f2c:	55                   	push   %ebp
  801f2d:	89 e5                	mov    %esp,%ebp
  801f2f:	57                   	push   %edi
  801f30:	56                   	push   %esi
  801f31:	53                   	push   %ebx
  801f32:	83 ec 0c             	sub    $0xc,%esp
  801f35:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f38:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f3e:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f40:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f45:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f48:	ff 75 14             	pushl  0x14(%ebp)
  801f4b:	53                   	push   %ebx
  801f4c:	56                   	push   %esi
  801f4d:	57                   	push   %edi
  801f4e:	e8 33 ef ff ff       	call   800e86 <sys_ipc_try_send>

		if (err < 0) {
  801f53:	83 c4 10             	add    $0x10,%esp
  801f56:	85 c0                	test   %eax,%eax
  801f58:	79 1e                	jns    801f78 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801f5a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f5d:	75 07                	jne    801f66 <ipc_send+0x3a>
				sys_yield();
  801f5f:	e8 76 ed ff ff       	call   800cda <sys_yield>
  801f64:	eb e2                	jmp    801f48 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f66:	50                   	push   %eax
  801f67:	68 4d 28 80 00       	push   $0x80284d
  801f6c:	6a 49                	push   $0x49
  801f6e:	68 5a 28 80 00       	push   $0x80285a
  801f73:	e8 20 e3 ff ff       	call   800298 <_panic>
		}

	} while (err < 0);

}
  801f78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f7b:	5b                   	pop    %ebx
  801f7c:	5e                   	pop    %esi
  801f7d:	5f                   	pop    %edi
  801f7e:	5d                   	pop    %ebp
  801f7f:	c3                   	ret    

00801f80 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f80:	55                   	push   %ebp
  801f81:	89 e5                	mov    %esp,%ebp
  801f83:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f86:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f8b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f8e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f94:	8b 52 50             	mov    0x50(%edx),%edx
  801f97:	39 ca                	cmp    %ecx,%edx
  801f99:	75 0d                	jne    801fa8 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f9b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f9e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fa3:	8b 40 48             	mov    0x48(%eax),%eax
  801fa6:	eb 0f                	jmp    801fb7 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fa8:	83 c0 01             	add    $0x1,%eax
  801fab:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fb0:	75 d9                	jne    801f8b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fb2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fb7:	5d                   	pop    %ebp
  801fb8:	c3                   	ret    

00801fb9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fb9:	55                   	push   %ebp
  801fba:	89 e5                	mov    %esp,%ebp
  801fbc:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fbf:	89 d0                	mov    %edx,%eax
  801fc1:	c1 e8 16             	shr    $0x16,%eax
  801fc4:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fcb:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fd0:	f6 c1 01             	test   $0x1,%cl
  801fd3:	74 1d                	je     801ff2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fd5:	c1 ea 0c             	shr    $0xc,%edx
  801fd8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fdf:	f6 c2 01             	test   $0x1,%dl
  801fe2:	74 0e                	je     801ff2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fe4:	c1 ea 0c             	shr    $0xc,%edx
  801fe7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fee:	ef 
  801fef:	0f b7 c0             	movzwl %ax,%eax
}
  801ff2:	5d                   	pop    %ebp
  801ff3:	c3                   	ret    
  801ff4:	66 90                	xchg   %ax,%ax
  801ff6:	66 90                	xchg   %ax,%ax
  801ff8:	66 90                	xchg   %ax,%ax
  801ffa:	66 90                	xchg   %ax,%ax
  801ffc:	66 90                	xchg   %ax,%ax
  801ffe:	66 90                	xchg   %ax,%ax

00802000 <__udivdi3>:
  802000:	55                   	push   %ebp
  802001:	57                   	push   %edi
  802002:	56                   	push   %esi
  802003:	53                   	push   %ebx
  802004:	83 ec 1c             	sub    $0x1c,%esp
  802007:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80200b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80200f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802013:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802017:	85 f6                	test   %esi,%esi
  802019:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80201d:	89 ca                	mov    %ecx,%edx
  80201f:	89 f8                	mov    %edi,%eax
  802021:	75 3d                	jne    802060 <__udivdi3+0x60>
  802023:	39 cf                	cmp    %ecx,%edi
  802025:	0f 87 c5 00 00 00    	ja     8020f0 <__udivdi3+0xf0>
  80202b:	85 ff                	test   %edi,%edi
  80202d:	89 fd                	mov    %edi,%ebp
  80202f:	75 0b                	jne    80203c <__udivdi3+0x3c>
  802031:	b8 01 00 00 00       	mov    $0x1,%eax
  802036:	31 d2                	xor    %edx,%edx
  802038:	f7 f7                	div    %edi
  80203a:	89 c5                	mov    %eax,%ebp
  80203c:	89 c8                	mov    %ecx,%eax
  80203e:	31 d2                	xor    %edx,%edx
  802040:	f7 f5                	div    %ebp
  802042:	89 c1                	mov    %eax,%ecx
  802044:	89 d8                	mov    %ebx,%eax
  802046:	89 cf                	mov    %ecx,%edi
  802048:	f7 f5                	div    %ebp
  80204a:	89 c3                	mov    %eax,%ebx
  80204c:	89 d8                	mov    %ebx,%eax
  80204e:	89 fa                	mov    %edi,%edx
  802050:	83 c4 1c             	add    $0x1c,%esp
  802053:	5b                   	pop    %ebx
  802054:	5e                   	pop    %esi
  802055:	5f                   	pop    %edi
  802056:	5d                   	pop    %ebp
  802057:	c3                   	ret    
  802058:	90                   	nop
  802059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802060:	39 ce                	cmp    %ecx,%esi
  802062:	77 74                	ja     8020d8 <__udivdi3+0xd8>
  802064:	0f bd fe             	bsr    %esi,%edi
  802067:	83 f7 1f             	xor    $0x1f,%edi
  80206a:	0f 84 98 00 00 00    	je     802108 <__udivdi3+0x108>
  802070:	bb 20 00 00 00       	mov    $0x20,%ebx
  802075:	89 f9                	mov    %edi,%ecx
  802077:	89 c5                	mov    %eax,%ebp
  802079:	29 fb                	sub    %edi,%ebx
  80207b:	d3 e6                	shl    %cl,%esi
  80207d:	89 d9                	mov    %ebx,%ecx
  80207f:	d3 ed                	shr    %cl,%ebp
  802081:	89 f9                	mov    %edi,%ecx
  802083:	d3 e0                	shl    %cl,%eax
  802085:	09 ee                	or     %ebp,%esi
  802087:	89 d9                	mov    %ebx,%ecx
  802089:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80208d:	89 d5                	mov    %edx,%ebp
  80208f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802093:	d3 ed                	shr    %cl,%ebp
  802095:	89 f9                	mov    %edi,%ecx
  802097:	d3 e2                	shl    %cl,%edx
  802099:	89 d9                	mov    %ebx,%ecx
  80209b:	d3 e8                	shr    %cl,%eax
  80209d:	09 c2                	or     %eax,%edx
  80209f:	89 d0                	mov    %edx,%eax
  8020a1:	89 ea                	mov    %ebp,%edx
  8020a3:	f7 f6                	div    %esi
  8020a5:	89 d5                	mov    %edx,%ebp
  8020a7:	89 c3                	mov    %eax,%ebx
  8020a9:	f7 64 24 0c          	mull   0xc(%esp)
  8020ad:	39 d5                	cmp    %edx,%ebp
  8020af:	72 10                	jb     8020c1 <__udivdi3+0xc1>
  8020b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020b5:	89 f9                	mov    %edi,%ecx
  8020b7:	d3 e6                	shl    %cl,%esi
  8020b9:	39 c6                	cmp    %eax,%esi
  8020bb:	73 07                	jae    8020c4 <__udivdi3+0xc4>
  8020bd:	39 d5                	cmp    %edx,%ebp
  8020bf:	75 03                	jne    8020c4 <__udivdi3+0xc4>
  8020c1:	83 eb 01             	sub    $0x1,%ebx
  8020c4:	31 ff                	xor    %edi,%edi
  8020c6:	89 d8                	mov    %ebx,%eax
  8020c8:	89 fa                	mov    %edi,%edx
  8020ca:	83 c4 1c             	add    $0x1c,%esp
  8020cd:	5b                   	pop    %ebx
  8020ce:	5e                   	pop    %esi
  8020cf:	5f                   	pop    %edi
  8020d0:	5d                   	pop    %ebp
  8020d1:	c3                   	ret    
  8020d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020d8:	31 ff                	xor    %edi,%edi
  8020da:	31 db                	xor    %ebx,%ebx
  8020dc:	89 d8                	mov    %ebx,%eax
  8020de:	89 fa                	mov    %edi,%edx
  8020e0:	83 c4 1c             	add    $0x1c,%esp
  8020e3:	5b                   	pop    %ebx
  8020e4:	5e                   	pop    %esi
  8020e5:	5f                   	pop    %edi
  8020e6:	5d                   	pop    %ebp
  8020e7:	c3                   	ret    
  8020e8:	90                   	nop
  8020e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	89 d8                	mov    %ebx,%eax
  8020f2:	f7 f7                	div    %edi
  8020f4:	31 ff                	xor    %edi,%edi
  8020f6:	89 c3                	mov    %eax,%ebx
  8020f8:	89 d8                	mov    %ebx,%eax
  8020fa:	89 fa                	mov    %edi,%edx
  8020fc:	83 c4 1c             	add    $0x1c,%esp
  8020ff:	5b                   	pop    %ebx
  802100:	5e                   	pop    %esi
  802101:	5f                   	pop    %edi
  802102:	5d                   	pop    %ebp
  802103:	c3                   	ret    
  802104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802108:	39 ce                	cmp    %ecx,%esi
  80210a:	72 0c                	jb     802118 <__udivdi3+0x118>
  80210c:	31 db                	xor    %ebx,%ebx
  80210e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802112:	0f 87 34 ff ff ff    	ja     80204c <__udivdi3+0x4c>
  802118:	bb 01 00 00 00       	mov    $0x1,%ebx
  80211d:	e9 2a ff ff ff       	jmp    80204c <__udivdi3+0x4c>
  802122:	66 90                	xchg   %ax,%ax
  802124:	66 90                	xchg   %ax,%ax
  802126:	66 90                	xchg   %ax,%ax
  802128:	66 90                	xchg   %ax,%ax
  80212a:	66 90                	xchg   %ax,%ax
  80212c:	66 90                	xchg   %ax,%ax
  80212e:	66 90                	xchg   %ax,%ax

00802130 <__umoddi3>:
  802130:	55                   	push   %ebp
  802131:	57                   	push   %edi
  802132:	56                   	push   %esi
  802133:	53                   	push   %ebx
  802134:	83 ec 1c             	sub    $0x1c,%esp
  802137:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80213b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80213f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802143:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802147:	85 d2                	test   %edx,%edx
  802149:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80214d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802151:	89 f3                	mov    %esi,%ebx
  802153:	89 3c 24             	mov    %edi,(%esp)
  802156:	89 74 24 04          	mov    %esi,0x4(%esp)
  80215a:	75 1c                	jne    802178 <__umoddi3+0x48>
  80215c:	39 f7                	cmp    %esi,%edi
  80215e:	76 50                	jbe    8021b0 <__umoddi3+0x80>
  802160:	89 c8                	mov    %ecx,%eax
  802162:	89 f2                	mov    %esi,%edx
  802164:	f7 f7                	div    %edi
  802166:	89 d0                	mov    %edx,%eax
  802168:	31 d2                	xor    %edx,%edx
  80216a:	83 c4 1c             	add    $0x1c,%esp
  80216d:	5b                   	pop    %ebx
  80216e:	5e                   	pop    %esi
  80216f:	5f                   	pop    %edi
  802170:	5d                   	pop    %ebp
  802171:	c3                   	ret    
  802172:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802178:	39 f2                	cmp    %esi,%edx
  80217a:	89 d0                	mov    %edx,%eax
  80217c:	77 52                	ja     8021d0 <__umoddi3+0xa0>
  80217e:	0f bd ea             	bsr    %edx,%ebp
  802181:	83 f5 1f             	xor    $0x1f,%ebp
  802184:	75 5a                	jne    8021e0 <__umoddi3+0xb0>
  802186:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80218a:	0f 82 e0 00 00 00    	jb     802270 <__umoddi3+0x140>
  802190:	39 0c 24             	cmp    %ecx,(%esp)
  802193:	0f 86 d7 00 00 00    	jbe    802270 <__umoddi3+0x140>
  802199:	8b 44 24 08          	mov    0x8(%esp),%eax
  80219d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021a1:	83 c4 1c             	add    $0x1c,%esp
  8021a4:	5b                   	pop    %ebx
  8021a5:	5e                   	pop    %esi
  8021a6:	5f                   	pop    %edi
  8021a7:	5d                   	pop    %ebp
  8021a8:	c3                   	ret    
  8021a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	85 ff                	test   %edi,%edi
  8021b2:	89 fd                	mov    %edi,%ebp
  8021b4:	75 0b                	jne    8021c1 <__umoddi3+0x91>
  8021b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021bb:	31 d2                	xor    %edx,%edx
  8021bd:	f7 f7                	div    %edi
  8021bf:	89 c5                	mov    %eax,%ebp
  8021c1:	89 f0                	mov    %esi,%eax
  8021c3:	31 d2                	xor    %edx,%edx
  8021c5:	f7 f5                	div    %ebp
  8021c7:	89 c8                	mov    %ecx,%eax
  8021c9:	f7 f5                	div    %ebp
  8021cb:	89 d0                	mov    %edx,%eax
  8021cd:	eb 99                	jmp    802168 <__umoddi3+0x38>
  8021cf:	90                   	nop
  8021d0:	89 c8                	mov    %ecx,%eax
  8021d2:	89 f2                	mov    %esi,%edx
  8021d4:	83 c4 1c             	add    $0x1c,%esp
  8021d7:	5b                   	pop    %ebx
  8021d8:	5e                   	pop    %esi
  8021d9:	5f                   	pop    %edi
  8021da:	5d                   	pop    %ebp
  8021db:	c3                   	ret    
  8021dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	8b 34 24             	mov    (%esp),%esi
  8021e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021e8:	89 e9                	mov    %ebp,%ecx
  8021ea:	29 ef                	sub    %ebp,%edi
  8021ec:	d3 e0                	shl    %cl,%eax
  8021ee:	89 f9                	mov    %edi,%ecx
  8021f0:	89 f2                	mov    %esi,%edx
  8021f2:	d3 ea                	shr    %cl,%edx
  8021f4:	89 e9                	mov    %ebp,%ecx
  8021f6:	09 c2                	or     %eax,%edx
  8021f8:	89 d8                	mov    %ebx,%eax
  8021fa:	89 14 24             	mov    %edx,(%esp)
  8021fd:	89 f2                	mov    %esi,%edx
  8021ff:	d3 e2                	shl    %cl,%edx
  802201:	89 f9                	mov    %edi,%ecx
  802203:	89 54 24 04          	mov    %edx,0x4(%esp)
  802207:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80220b:	d3 e8                	shr    %cl,%eax
  80220d:	89 e9                	mov    %ebp,%ecx
  80220f:	89 c6                	mov    %eax,%esi
  802211:	d3 e3                	shl    %cl,%ebx
  802213:	89 f9                	mov    %edi,%ecx
  802215:	89 d0                	mov    %edx,%eax
  802217:	d3 e8                	shr    %cl,%eax
  802219:	89 e9                	mov    %ebp,%ecx
  80221b:	09 d8                	or     %ebx,%eax
  80221d:	89 d3                	mov    %edx,%ebx
  80221f:	89 f2                	mov    %esi,%edx
  802221:	f7 34 24             	divl   (%esp)
  802224:	89 d6                	mov    %edx,%esi
  802226:	d3 e3                	shl    %cl,%ebx
  802228:	f7 64 24 04          	mull   0x4(%esp)
  80222c:	39 d6                	cmp    %edx,%esi
  80222e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802232:	89 d1                	mov    %edx,%ecx
  802234:	89 c3                	mov    %eax,%ebx
  802236:	72 08                	jb     802240 <__umoddi3+0x110>
  802238:	75 11                	jne    80224b <__umoddi3+0x11b>
  80223a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80223e:	73 0b                	jae    80224b <__umoddi3+0x11b>
  802240:	2b 44 24 04          	sub    0x4(%esp),%eax
  802244:	1b 14 24             	sbb    (%esp),%edx
  802247:	89 d1                	mov    %edx,%ecx
  802249:	89 c3                	mov    %eax,%ebx
  80224b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80224f:	29 da                	sub    %ebx,%edx
  802251:	19 ce                	sbb    %ecx,%esi
  802253:	89 f9                	mov    %edi,%ecx
  802255:	89 f0                	mov    %esi,%eax
  802257:	d3 e0                	shl    %cl,%eax
  802259:	89 e9                	mov    %ebp,%ecx
  80225b:	d3 ea                	shr    %cl,%edx
  80225d:	89 e9                	mov    %ebp,%ecx
  80225f:	d3 ee                	shr    %cl,%esi
  802261:	09 d0                	or     %edx,%eax
  802263:	89 f2                	mov    %esi,%edx
  802265:	83 c4 1c             	add    $0x1c,%esp
  802268:	5b                   	pop    %ebx
  802269:	5e                   	pop    %esi
  80226a:	5f                   	pop    %edi
  80226b:	5d                   	pop    %ebp
  80226c:	c3                   	ret    
  80226d:	8d 76 00             	lea    0x0(%esi),%esi
  802270:	29 f9                	sub    %edi,%ecx
  802272:	19 d6                	sbb    %edx,%esi
  802274:	89 74 24 04          	mov    %esi,0x4(%esp)
  802278:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80227c:	e9 18 ff ff ff       	jmp    802199 <__umoddi3+0x69>
